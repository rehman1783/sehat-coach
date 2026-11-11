import { createHash } from 'node:crypto';
import { getAppCheck } from 'firebase-admin/app-check';
import { getAuth } from 'firebase-admin/auth';
import { ensureFirebaseAdminInitialized } from './firebaseAdmin';

export interface HttpRequest {
  method: string;
  headers: Record<string, string | string[] | undefined>;
  query: Record<string, unknown>;
  body: unknown;
  rawBody?: Buffer;
}

export interface HttpResponse {
  status(code: number): HttpResponse;
  json(body: unknown): void;
}

export interface VerifiedCaller {
  uid: string;
}

export interface AuthDependencies {
  verifyIdToken: (idToken: string) => Promise<{ uid: string }>;
  verifyAppCheckToken: (appCheckToken: string) => Promise<unknown>;
}

export class HttpError extends Error {
  constructor(
    public readonly statusCode: number,
    public readonly code: string,
  ) {
    super(code);
  }
}

export function defaultAuthDependencies(): AuthDependencies {
  ensureFirebaseAdminInitialized();
  return {
    verifyIdToken: (idToken) => getAuth().verifyIdToken(idToken, true),
    verifyAppCheckToken: (appCheckToken) =>
      getAppCheck().verifyToken(appCheckToken),
  };
}

export function sha256Hex(value: string): string {
  return createHash('sha256').update(value, 'utf8').digest('hex');
}

export function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map((item) => canonicalJson(item)).join(',')}]`;
  }
  if (value !== null && typeof value === 'object') {
    const entries = Object.entries(value as Record<string, unknown>).sort(
      ([left], [right]) => left.localeCompare(right),
    );
    return `{${entries
      .map(([key, val]) => `${JSON.stringify(key)}:${canonicalJson(val)}`)
      .join(',')}}`;
  }
  return JSON.stringify(value);
}

export function readHeader(
  headers: Record<string, string | string[] | undefined>,
  name: string,
): string | undefined {
  const target = name.toLowerCase();
  for (const [key, value] of Object.entries(headers)) {
    if (key.toLowerCase() !== target) continue;
    if (typeof value === 'string') return value.trim();
    if (Array.isArray(value) && value.length > 0 && typeof value[0] === 'string') {
      return value[0].trim();
    }
  }
  return undefined;
}

export function isPlainObject(
  value: unknown,
): value is Record<string, unknown> {
  return (
    value !== null &&
    typeof value === 'object' &&
    !Array.isArray(value) &&
    !Buffer.isBuffer(value)
  );
}

export function requireBoundedId(
  value: unknown,
  code: string,
  maxLength: number,
): string {
  if (typeof value !== 'string') throw new HttpError(400, code);
  const trimmed = value.trim();
  if (trimmed.length === 0 || trimmed.length > maxLength) {
    throw new HttpError(400, code);
  }
  return trimmed;
}

export function parseJsonBodyObject(
  req: HttpRequest,
  maxBodyBytes: number,
): Record<string, unknown> {
  if (req.rawBody !== undefined && req.rawBody.byteLength > maxBodyBytes) {
    throw new HttpError(413, 'payload_too_large');
  }
  let parsed: unknown = req.body;
  if (Buffer.isBuffer(parsed)) {
    if (parsed.byteLength > maxBodyBytes) {
      throw new HttpError(413, 'payload_too_large');
    }
    parsed = parsed.toString('utf8');
  }
  if (typeof parsed === 'string') {
    if (Buffer.byteLength(parsed, 'utf8') > maxBodyBytes) {
      throw new HttpError(413, 'payload_too_large');
    }
    try {
      parsed = JSON.parse(parsed);
    } catch {
      throw new HttpError(400, 'invalid_json');
    }
  }
  if (!isPlainObject(parsed)) {
    throw new HttpError(400, 'invalid_json_object');
  }
  if (
    req.rawBody === undefined &&
    Buffer.byteLength(JSON.stringify(parsed), 'utf8') > maxBodyBytes
  ) {
    throw new HttpError(413, 'payload_too_large');
  }
  return parsed;
}

export async function authenticateRequest(
  req: HttpRequest,
  expectedMethod: 'GET' | 'POST',
  deps: AuthDependencies = defaultAuthDependencies(),
): Promise<VerifiedCaller> {
  if (req.method.toUpperCase() !== expectedMethod) {
    throw new HttpError(405, 'method_not_allowed');
  }
  const authorization = readHeader(req.headers, 'authorization');
  if (!authorization || !authorization.toLowerCase().startsWith('bearer ')) {
    throw new HttpError(401, 'missing_id_token');
  }
  const idToken = authorization.slice(7).trim();
  const appCheckToken = readHeader(req.headers, 'x-firebase-appcheck');
  if (!idToken || !appCheckToken) {
    throw new HttpError(401, 'missing_trusted_credentials');
  }

  let uid: string;
  try {
    const decoded = await deps.verifyIdToken(idToken);
    uid = decoded.uid.trim();
    if (!uid) throw new Error('empty_uid');
  } catch {
    throw new HttpError(401, 'invalid_id_token');
  }

  try {
    await deps.verifyAppCheckToken(appCheckToken);
  } catch {
    throw new HttpError(401, 'invalid_app_check_token');
  }

  return { uid };
}

export function assertOwnerMatchesCaller(
  callerUid: string,
  ownerId: string,
): void {
  if (ownerId !== callerUid) {
    throw new HttpError(403, 'owner_mismatch');
  }
}

export function sendHttpError(res: HttpResponse, error: unknown): void {
  if (error instanceof HttpError) {
    res.status(error.statusCode).json({ error: error.code });
    return;
  }
  res.status(500).json({ error: 'internal_error' });
}

