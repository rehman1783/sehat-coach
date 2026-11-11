import assert from 'node:assert/strict';
import http from 'node:http';
import test from 'node:test';
import { AuthDependencies, HttpRequest, HttpResponse } from '../auth';
import { handleFetchRequest } from '../fetchHandler';
import { handleAccountDeletion } from '../handlers/accountDeletion';
import { handleAdultEligibility } from '../handlers/adultEligibility';
import {
  SyncRecordDoc,
  handleSyncPull,
  handleSyncUpload,
} from '../handlers/sync';
import { stripWrappingQuotes } from '../httpAdapter';
import { routeRequest } from '../router';
import { createNodeHttpServer } from '../server';

function captureResponse(): {
  res: HttpResponse;
  status: () => number;
  body: () => unknown;
} {
  let code = 0;
  let payload: unknown;
  return {
    res: {
      status(nextCode: number) {
        code = nextCode;
        return this;
      },
      json(body: unknown) {
        payload = body;
      },
    },
    status: () => code,
    body: () => payload,
  };
}

function validAuth(uid = 'uid-1'): AuthDependencies {
  return {
    verifyIdToken: async () => ({ uid }),
    verifyAppCheckToken: async () => ({ appId: 'app-1' }),
  };
}

function baseHeaders(): Record<string, string> {
  return {
    authorization: 'Bearer id-token',
    'x-firebase-appcheck': 'appcheck-token',
  };
}

test('adultEligibility requires App Check token and matching owner', async () => {
  const missingCheck = captureResponse();
  await handleAdultEligibility(
    {
      method: 'POST',
      headers: { authorization: 'Bearer id-token' },
      query: {},
      body: {},
    },
    missingCheck.res,
    {
      auth: validAuth(),
      getUser: async () => ({}),
      setCustomUserClaims: async () => {},
      saveEligibilityRecord: async () => {},
      nowUtc: () => new Date('2026-11-11T00:00:00Z'),
    },
  );
  assert.equal(missingCheck.status(), 401);

  const wrongOwner = captureResponse();
  await handleAdultEligibility(
    {
      method: 'POST',
      headers: baseHeaders(),
      query: {},
      body: {
        ownerId: 'uid-other',
        declaredAge: 25,
        minimumAge: 18,
        confirmed: true,
        policyVersion: 'v1',
      },
    },
    wrongOwner.res,
    {
      auth: validAuth('uid-1'),
      getUser: async () => ({}),
      setCustomUserClaims: async () => {},
      saveEligibilityRecord: async () => {},
      nowUtc: () => new Date('2026-11-11T00:00:00Z'),
    },
  );
  assert.equal(wrongOwner.status(), 403);
});

test('adultEligibility sets adult_eligible claim preserving existing claims', async () => {
  let savedClaims: Record<string, unknown> | undefined;
  const out = captureResponse();
  await handleAdultEligibility(
    {
      method: 'POST',
      headers: baseHeaders(),
      query: {},
      body: {
        ownerId: 'uid-1',
        declaredAge: 24,
        minimumAge: 18,
        confirmed: true,
        policyVersion: 'pk-adult-v1',
      },
    },
    out.res,
    {
      auth: validAuth('uid-1'),
      getUser: async () => ({ customClaims: { role: 'user' } }),
      setCustomUserClaims: async (_uid, claims) => {
        savedClaims = claims;
      },
      saveEligibilityRecord: async () => {},
      nowUtc: () => new Date('2026-11-11T10:00:00Z'),
    },
  );
  assert.equal(out.status(), 200);
  assert.deepEqual(savedClaims, { role: 'user', adult_eligible: true });
  assert.deepEqual(out.body(), {
    ownerId: 'uid-1',
    adultEligible: true,
    minimumAge: 18,
    policyVersion: 'pk-adult-v1',
    registeredAtUtc: '2026-11-11T10:00:00.000Z',
  });
});

test('accountDeletion deletes user and returns idempotent 202 receipt', async () => {
  const calls: string[] = [];
  let storedReceipt: {
    ownerId: string;
    requestId: string;
    accepted: true;
    acceptedAtUtc: string;
  } | null = null;

  const req: HttpRequest = {
    method: 'POST',
    headers: { ...baseHeaders(), 'x-idempotency-key': 'del-1' },
    query: {},
    body: { ownerId: 'uid-1', requestId: 'del-1' },
  };
  const deps = {
    auth: validAuth('uid-1'),
    readReceipt: async () => storedReceipt,
    saveReceipt: async (_id: string, r: typeof storedReceipt) => {
      storedReceipt = r;
    },
    revokeTokens: async () => {
      calls.push('revoke');
    },
    deleteUserData: async () => {
      calls.push('data');
    },
    deleteAuthUser: async () => {
      calls.push('auth');
    },
    nowUtc: () => new Date('2026-11-11T12:00:00Z'),
  };

  const first = captureResponse();
  await handleAccountDeletion(req, first.res, deps);
  assert.equal(first.status(), 202);
  assert.deepEqual(calls, ['revoke', 'data', 'auth']);

  const retry = captureResponse();
  await handleAccountDeletion(req, retry.res, deps);
  assert.equal(retry.status(), 202);
  assert.deepEqual(calls, ['revoke', 'data', 'auth']);
  assert.deepEqual(retry.body(), first.body());
});

test('syncUpload and syncPull validate revisions, cursors, and pagination', async () => {
  const uploaded: SyncRecordDoc[] = [];
  const deps = {
    auth: validAuth('uid-1'),
    nowUtc: () => new Date('2026-11-11T14:00:00Z'),
    store: {
      uploadChange: async (input: {
        ownerId: string;
        operationId: string;
        entityType: string;
        entityKey: string;
        baseRevision: number;
        newRevision: number;
        payload: Record<string, unknown>;
        nowIso: string;
      }) => {
        uploaded.push({
          ownerId: input.ownerId,
          entityType: input.entityType,
          entityKey: input.entityKey,
          serverRevision: input.newRevision,
          changeSeq: uploaded.length + 1,
          deleted: false,
          payload: input.payload,
          updatedAtUtc: input.nowIso,
        });
        return {
          ownerId: input.ownerId,
          operationId: input.operationId,
          serverRevision: input.newRevision,
        };
      },
      pullChanges: async (_ownerId: string, sinceSeq: number) =>
        uploaded.filter((row) => row.changeSeq > sinceSeq),
    },
  };

  const uploadRes = captureResponse();
  await handleSyncUpload(
    {
      method: 'POST',
      headers: { ...baseHeaders(), 'x-idempotency-key': 'op-1' },
      query: {},
      body: {
        ownerId: 'uid-1',
        operationId: 'op-1',
        entityType: 'meal',
        entityKey: 'm-1',
        baseRevision: 0,
        newRevision: 1,
        payload: { kcal: 300 },
      },
    },
    uploadRes.res,
    deps,
  );
  assert.equal(uploadRes.status(), 200);
  assert.deepEqual(uploadRes.body(), {
    ownerId: 'uid-1',
    operationId: 'op-1',
    serverRevision: 1,
  });

  const pullFirst = captureResponse();
  await handleSyncPull(
    {
      method: 'GET',
      headers: baseHeaders(),
      query: { ownerId: 'uid-1' },
      body: undefined,
    },
    pullFirst.res,
    deps,
  );
  assert.equal(pullFirst.status(), 200);
  assert.deepEqual(pullFirst.body(), {
    ownerId: 'uid-1',
    requestCursor: null,
    nextCursor: '1',
    hasMore: false,
    changes: [
      {
        ownerId: 'uid-1',
        entityType: 'meal',
        entityKey: 'm-1',
        serverRevision: 1,
        deleted: false,
        payload: { kcal: 300 },
      },
    ],
  });

  const pullEmpty = captureResponse();
  await handleSyncPull(
    {
      method: 'GET',
      headers: baseHeaders(),
      query: { ownerId: 'uid-1', cursor: '1' },
      body: undefined,
    },
    pullEmpty.res,
    deps,
  );
  assert.equal(pullEmpty.status(), 200);
  assert.deepEqual(pullEmpty.body(), {
    ownerId: 'uid-1',
    requestCursor: '1',
    nextCursor: '1',
    hasMore: false,
    changes: [],
  });
});

test('createNodeHttpServer routes healthz, eligibility, syncPull, and 404 over HTTP', async () => {
  const server = createNodeHttpServer({
    ensureAdmin: () => ({ ready: true, configStatus: 'ready' }),
    adultEligibility: () => ({
      auth: validAuth('uid-http'),
      getUser: async () => ({}),
      setCustomUserClaims: async () => {},
      saveEligibilityRecord: async () => {},
      nowUtc: () => new Date('2026-11-11T18:00:00Z'),
    }),
    sync: () => ({
      auth: validAuth('uid-http'),
      nowUtc: () => new Date('2026-11-11T18:00:00Z'),
      store: {
        uploadChange: async (input) => ({
          ownerId: input.ownerId,
          operationId: input.operationId,
          serverRevision: input.newRevision,
        }),
        pullChanges: async () => [],
      },
    }),
  });

  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  try {
    const address = server.address();
    assert.ok(address && typeof address === 'object');
    const baseUrl = `http://127.0.0.1:${address.port}`;

    const requestJson = (
      path: string,
      method: 'GET' | 'POST',
      headers: Record<string, string> = {},
      body?: string,
    ): Promise<{ status: number; json: unknown }> =>
      new Promise((resolve, reject) => {
        const req = http.request(
          `${baseUrl}${path}`,
          { method, headers },
          (res) => {
            const chunks: Buffer[] = [];
            res.on('data', (chunk: Buffer) => chunks.push(chunk));
            res.on('end', () => {
              resolve({
                status: res.statusCode ?? 0,
                json: JSON.parse(Buffer.concat(chunks).toString('utf8')),
              });
            });
          },
        );
        req.on('error', reject);
        if (body !== undefined) req.write(body);
        req.end();
      });

    const health = await requestJson('/healthz', 'GET');
    assert.equal(health.status, 200);
    assert.deepEqual(health.json, {
      ok: true,
      service: 'sehat-coach-backend',
      firebaseAdminConfigured: true,
      configStatus: 'ready',
    });

    const eligibility = await requestJson(
      '/adultEligibility',
      'POST',
      { ...baseHeaders(), 'content-type': 'application/json' },
      JSON.stringify({
        ownerId: 'uid-http',
        declaredAge: 25,
        minimumAge: 18,
        confirmed: true,
        policyVersion: 'v1',
      }),
    );
    assert.equal(eligibility.status, 200);

    const pull = await requestJson(
      '/syncPull?ownerId=uid-http',
      'GET',
      baseHeaders(),
    );
    assert.equal(pull.status, 200);

    const missing = await requestJson('/unknown', 'GET');
    assert.equal(missing.status, 404);
  } finally {
    await new Promise<void>((resolve, reject) =>
      server.close((err) => (err ? reject(err) : resolve())),
    );
  }
});

test('router returns 503 safely when Firebase Admin env vars are missing', async () => {
  const out = captureResponse();
  await routeRequest(
    '/adultEligibility',
    {
      method: 'POST',
      headers: baseHeaders(),
      query: {},
      body: {},
    },
    out.res,
    {
      ensureAdmin: () => ({
        ready: false,
        configStatus: 'missing_service_account_env',
      }),
    },
  );
  assert.equal(out.status(), 503);
  assert.deepEqual(out.body(), {
    error: 'backend_not_configured',
    configStatus: 'missing_service_account_env',
  });
});

test('handleFetchRequest handles Web Request/Response for Vercel root entrypoint', async () => {
  assert.equal(stripWrappingQuotes('"hello"'), 'hello');
  const deps = {
    ensureAdmin: () => ({ ready: true, configStatus: 'ready' }),
    adultEligibility: () => ({
      auth: validAuth('uid-web'),
      getUser: async () => ({}),
      setCustomUserClaims: async () => {},
      saveEligibilityRecord: async () => {},
      nowUtc: () => new Date('2026-11-11T19:00:00Z'),
    }),
  };

  const healthRes = await handleFetchRequest(
    new Request('https://sehat-coach.vercel.app/healthz', { method: 'GET' }),
    deps,
  );
  assert.equal(healthRes.status, 200);
  assert.deepEqual(await healthRes.json(), {
    ok: true,
    service: 'sehat-coach-backend',
    firebaseAdminConfigured: true,
    configStatus: 'ready',
  });

  const postRes = await handleFetchRequest(
    new Request('https://sehat-coach.vercel.app/adultEligibility', {
      method: 'POST',
      headers: { ...baseHeaders(), 'content-type': 'application/json' },
      body: JSON.stringify({
        ownerId: 'uid-web',
        declaredAge: 22,
        minimumAge: 18,
        confirmed: true,
        policyVersion: 'v1',
      }),
    }),
    deps,
  );
  assert.equal(postRes.status, 200);
});

