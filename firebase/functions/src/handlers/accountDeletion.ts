import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import {
  AuthDependencies,
  HttpError,
  HttpRequest,
  HttpResponse,
  assertOwnerMatchesCaller,
  authenticateRequest,
  defaultAuthDependencies,
  parseJsonBodyObject,
  readHeader,
  requireBoundedId,
  sendHttpError,
  sha256Hex,
} from '../auth';
import { ensureFirebaseAdminInitialized } from '../firebaseAdmin';

const MAX_DELETION_BODY_BYTES = 8 * 1024;

export interface DeletionReceipt {
  ownerId: string;
  requestId: string;
  accepted: true;
  acceptedAtUtc: string;
}

export interface AccountDeletionDeps {
  auth: AuthDependencies;
  readReceipt: (receiptDocId: string) => Promise<DeletionReceipt | null>;
  saveReceipt: (receiptDocId: string, receipt: DeletionReceipt) => Promise<void>;
  revokeTokens: (uid: string) => Promise<void>;
  deleteUserData: (uid: string) => Promise<void>;
  deleteAuthUser: (uid: string) => Promise<void>;
  nowUtc: () => Date;
}

function isAuthUserNotFound(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    (error as { code?: unknown }).code === 'auth/user-not-found'
  );
}

export function defaultAccountDeletionDeps(): AccountDeletionDeps {
  ensureFirebaseAdminInitialized();
  const auth = getAuth();
  const db = getFirestore();
  return {
    auth: defaultAuthDependencies(),
    readReceipt: async (receiptDocId) => {
      const snap = await db
        .collection('accountDeletionRequests')
        .doc(receiptDocId)
        .get();
      if (!snap.exists) return null;
      return snap.data() as DeletionReceipt;
    },
    saveReceipt: async (receiptDocId, receipt) => {
      await db
        .collection('accountDeletionRequests')
        .doc(receiptDocId)
        .set(receipt, { merge: false });
    },
    revokeTokens: async (uid) => {
      try {
        await auth.revokeRefreshTokens(uid);
      } catch (error) {
        if (!isAuthUserNotFound(error)) throw error;
      }
    },
    deleteUserData: async (uid) => {
      await db.recursiveDelete(db.collection('users').doc(uid));
    },
    deleteAuthUser: async (uid) => {
      try {
        await auth.deleteUser(uid);
      } catch (error) {
        if (!isAuthUserNotFound(error)) throw error;
      }
    },
    nowUtc: () => new Date(),
  };
}

export async function handleAccountDeletion(
  req: HttpRequest,
  res: HttpResponse,
  deps: AccountDeletionDeps = defaultAccountDeletionDeps(),
): Promise<void> {
  try {
    const caller = await authenticateRequest(req, 'POST', deps.auth);
    const body = parseJsonBodyObject(req, MAX_DELETION_BODY_BYTES);
    const ownerId = requireBoundedId(body.ownerId, 'invalid_owner', 128);
    assertOwnerMatchesCaller(caller.uid, ownerId);

    const requestId = requireBoundedId(body.requestId, 'invalid_request_id', 128);
    const headerKey = readHeader(req.headers, 'x-idempotency-key');
    if (headerKey !== undefined && headerKey !== requestId) {
      throw new HttpError(400, 'idempotency_key_mismatch');
    }

    const receiptDocId = sha256Hex(`${ownerId}\0${requestId}`);
    const existing = await deps.readReceipt(receiptDocId);
    if (existing !== null) {
      res.status(202).json(existing);
      return;
    }

    // Revoke tokens, remove user subcollections, and delete auth identity before
    // recording the durable receipt so transient failures can safely retry.
    await deps.revokeTokens(ownerId);
    await deps.deleteUserData(ownerId);
    await deps.deleteAuthUser(ownerId);

    const receipt: DeletionReceipt = {
      ownerId,
      requestId,
      accepted: true,
      acceptedAtUtc: deps.nowUtc().toISOString(),
    };
    await deps.saveReceipt(receiptDocId, receipt);
    res.status(202).json(receipt);
  } catch (error) {
    sendHttpError(res, error);
  }
}

