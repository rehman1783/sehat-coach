import { getFirestore } from 'firebase-admin/firestore';
import {
  AuthDependencies,
  HttpError,
  HttpRequest,
  HttpResponse,
  assertOwnerMatchesCaller,
  authenticateRequest,
  canonicalJson,
  defaultAuthDependencies,
  isPlainObject,
  parseJsonBodyObject,
  readHeader,
  requireBoundedId,
  sendHttpError,
  sha256Hex,
} from '../auth';

const MAX_UPLOAD_BODY_BYTES = 256 * 1024;
const MAX_PULL_CHANGES = 100;
const MAX_CURSOR_LENGTH = 512;

export interface SyncRecordDoc {
  ownerId: string;
  entityType: string;
  entityKey: string;
  serverRevision: number;
  changeSeq: number;
  deleted: boolean;
  payload: Record<string, unknown>;
  updatedAtUtc: string;
}

export interface SyncUploadReceipt {
  ownerId: string;
  operationId: string;
  serverRevision: number;
}

export interface SyncStorePort {
  uploadChange: (input: {
    ownerId: string;
    operationId: string;
    entityType: string;
    entityKey: string;
    baseRevision: number;
    newRevision: number;
    payload: Record<string, unknown>;
    payloadHash: string;
    nowIso: string;
  }) => Promise<SyncUploadReceipt>;
  pullChanges: (
    ownerId: string,
    sinceSeq: number,
    limitPlusOne: number,
  ) => Promise<SyncRecordDoc[]>;
}

export interface SyncDeps {
  auth: AuthDependencies;
  store: SyncStorePort;
  nowUtc: () => Date;
}

interface StoredOperationDoc {
  ownerId: string;
  operationId: string;
  entityType: string;
  entityKey: string;
  baseRevision: number;
  serverRevision: number;
  payloadHash: string;
}

export function defaultSyncDeps(): SyncDeps {
  const db = getFirestore();
  return {
    auth: defaultAuthDependencies(),
    nowUtc: () => new Date(),
    store: {
      uploadChange: async (input) => {
        const userRef = db.collection('users').doc(input.ownerId);
        const opRef = userRef
          .collection('syncOps')
          .doc(sha256Hex(input.operationId));
        const metaRef = userRef.collection('metadata').doc('syncState');
        const recordRef = userRef
          .collection('records')
          .doc(sha256Hex(`${input.entityType}\0${input.entityKey}`));

        return db.runTransaction(async (tx) => {
          const [opSnap, metaSnap, recordSnap] = await Promise.all([
            tx.get(opRef),
            tx.get(metaRef),
            tx.get(recordRef),
          ]);

          if (opSnap.exists) {
            const existing = opSnap.data() as StoredOperationDoc;
            if (
              existing.entityType !== input.entityType ||
              existing.entityKey !== input.entityKey ||
              existing.baseRevision !== input.baseRevision ||
              existing.payloadHash !== input.payloadHash
            ) {
              throw new HttpError(409, 'operation_id_conflict');
            }
            return {
              ownerId: input.ownerId,
              operationId: input.operationId,
              serverRevision: existing.serverRevision,
            };
          }

          const currentRevision = recordSnap.exists
            ? ((recordSnap.data()?.serverRevision as number) ?? 0)
            : 0;
          if (input.baseRevision !== currentRevision) {
            throw new HttpError(409, 'revision_conflict');
          }

          const lastSeq = metaSnap.exists
            ? ((metaSnap.data()?.lastChangeSeq as number) ?? 0)
            : 0;
          const nextSeq = lastSeq + 1;

          tx.set(
            metaRef,
            { lastChangeSeq: nextSeq, updatedAtUtc: input.nowIso },
            { merge: true },
          );
          tx.set(recordRef, {
            ownerId: input.ownerId,
            entityType: input.entityType,
            entityKey: input.entityKey,
            serverRevision: input.newRevision,
            changeSeq: nextSeq,
            deleted: input.payload.deleted === true,
            payload: input.payload,
            updatedAtUtc: input.nowIso,
          } satisfies SyncRecordDoc);
          tx.set(opRef, {
            ownerId: input.ownerId,
            operationId: input.operationId,
            entityType: input.entityType,
            entityKey: input.entityKey,
            baseRevision: input.baseRevision,
            serverRevision: input.newRevision,
            payloadHash: input.payloadHash,
          } satisfies StoredOperationDoc);

          return {
            ownerId: input.ownerId,
            operationId: input.operationId,
            serverRevision: input.newRevision,
          };
        });
      },
      pullChanges: async (ownerId, sinceSeq, limitPlusOne) => {
        const snapshot = await db
          .collection('users')
          .doc(ownerId)
          .collection('records')
          .where('changeSeq', '>', sinceSeq)
          .orderBy('changeSeq', 'asc')
          .limit(limitPlusOne)
          .get();
        return snapshot.docs.map((doc) => doc.data() as SyncRecordDoc);
      },
    },
  };
}

export async function handleSyncUpload(
  req: HttpRequest,
  res: HttpResponse,
  deps: SyncDeps = defaultSyncDeps(),
): Promise<void> {
  try {
    const caller = await authenticateRequest(req, 'POST', deps.auth);
    const body = parseJsonBodyObject(req, MAX_UPLOAD_BODY_BYTES);
    const ownerId = requireBoundedId(body.ownerId, 'invalid_owner', 128);
    assertOwnerMatchesCaller(caller.uid, ownerId);

    const operationId = requireBoundedId(
      body.operationId,
      'invalid_operation_id',
      128,
    );
    const headerKey = readHeader(req.headers, 'x-idempotency-key');
    if (headerKey !== undefined && headerKey !== operationId) {
      throw new HttpError(400, 'idempotency_key_mismatch');
    }

    const entityType = requireBoundedId(
      body.entityType,
      'invalid_entity_type',
      64,
    );
    const entityKey = requireBoundedId(
      body.entityKey,
      'invalid_entity_key',
      256,
    );
    const baseRevision = body.baseRevision;
    const newRevision = body.newRevision;
    if (
      !Number.isInteger(baseRevision) ||
      (baseRevision as number) < 0 ||
      !Number.isInteger(newRevision) ||
      (newRevision as number) <= (baseRevision as number)
    ) {
      throw new HttpError(400, 'invalid_revisions');
    }
    if (!isPlainObject(body.payload)) {
      throw new HttpError(400, 'invalid_payload');
    }

    const receipt = await deps.store.uploadChange({
      ownerId,
      operationId,
      entityType,
      entityKey,
      baseRevision: baseRevision as number,
      newRevision: newRevision as number,
      payload: body.payload,
      payloadHash: sha256Hex(canonicalJson(body.payload)),
      nowIso: deps.nowUtc().toISOString(),
    });
    res.status(200).json(receipt);
  } catch (error) {
    sendHttpError(res, error);
  }
}

function parsePullCursor(rawCursor: unknown): {
  requestCursor: string | null;
  sinceSeq: number;
} {
  if (rawCursor === undefined) {
    return { requestCursor: null, sinceSeq: 0 };
  }
  if (typeof rawCursor !== 'string') {
    throw new HttpError(400, 'invalid_cursor');
  }
  const normalized = rawCursor.trim();
  if (
    normalized.length === 0 ||
    normalized.length > MAX_CURSOR_LENGTH ||
    !/^\d+$/.test(normalized)
  ) {
    throw new HttpError(400, 'invalid_cursor');
  }
  const sinceSeq = Number(normalized);
  if (!Number.isSafeInteger(sinceSeq) || sinceSeq < 0) {
    throw new HttpError(400, 'invalid_cursor');
  }
  return { requestCursor: rawCursor, sinceSeq };
}

export async function handleSyncPull(
  req: HttpRequest,
  res: HttpResponse,
  deps: SyncDeps = defaultSyncDeps(),
): Promise<void> {
  try {
    const caller = await authenticateRequest(req, 'GET', deps.auth);
    const ownerId = requireBoundedId(req.query.ownerId, 'invalid_owner', 128);
    assertOwnerMatchesCaller(caller.uid, ownerId);

    const { requestCursor, sinceSeq } = parsePullCursor(req.query.cursor);
    const rows = await deps.store.pullChanges(
      ownerId,
      sinceSeq,
      MAX_PULL_CHANGES + 1,
    );
    const hasMore = rows.length > MAX_PULL_CHANGES;
    const pageRows = hasMore ? rows.slice(0, MAX_PULL_CHANGES) : rows;
    const lastRow = pageRows.length > 0 ? pageRows[pageRows.length - 1] : null;
    const nextCursor = lastRow
      ? String(lastRow.changeSeq)
      : (requestCursor ?? '0');

    res.status(200).json({
      ownerId,
      requestCursor,
      nextCursor,
      hasMore,
      changes: pageRows.map((row) => ({
        ownerId: row.ownerId,
        entityType: row.entityType,
        entityKey: row.entityKey,
        serverRevision: row.serverRevision,
        deleted: Boolean(row.deleted),
        payload: row.payload,
      })),
    });
  } catch (error) {
    sendHttpError(res, error);
  }
}

