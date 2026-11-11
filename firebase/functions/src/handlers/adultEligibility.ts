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
  requireBoundedId,
  sendHttpError,
} from '../auth';
import { ensureFirebaseAdminInitialized } from '../firebaseAdmin';

const MAX_ELIGIBILITY_BODY_BYTES = 8 * 1024;

export interface AdultEligibilityDeps {
  auth: AuthDependencies;
  getUser: (uid: string) => Promise<{ customClaims?: Record<string, unknown> }>;
  setCustomUserClaims: (
    uid: string,
    claims: Record<string, unknown>,
  ) => Promise<void>;
  saveEligibilityRecord: (
    uid: string,
    record: {
      adultEligible: true;
      minimumAge: number;
      policyVersion: string;
      registeredAtUtc: string;
    },
  ) => Promise<void>;
  nowUtc: () => Date;
}

export function defaultAdultEligibilityDeps(): AdultEligibilityDeps {
  ensureFirebaseAdminInitialized();
  const auth = getAuth();
  const db = getFirestore();
  return {
    auth: defaultAuthDependencies(),
    getUser: (uid) => auth.getUser(uid),
    setCustomUserClaims: (uid, claims) => auth.setCustomUserClaims(uid, claims),
    saveEligibilityRecord: async (uid, record) => {
      await db
        .collection('users')
        .doc(uid)
        .collection('metadata')
        .doc('eligibility')
        .set(record, { merge: true });
    },
    nowUtc: () => new Date(),
  };
}

export async function handleAdultEligibility(
  req: HttpRequest,
  res: HttpResponse,
  deps: AdultEligibilityDeps = defaultAdultEligibilityDeps(),
): Promise<void> {
  try {
    const caller = await authenticateRequest(req, 'POST', deps.auth);
    const body = parseJsonBodyObject(req, MAX_ELIGIBILITY_BODY_BYTES);
    const ownerId = requireBoundedId(body.ownerId, 'invalid_owner', 128);
    assertOwnerMatchesCaller(caller.uid, ownerId);

    const confirmed = body.confirmed;
    const minimumAge = body.minimumAge;
    const declaredAge = body.declaredAge;
    const policyVersion = requireBoundedId(
      body.policyVersion,
      'invalid_policy_version',
      64,
    );

    if (
      confirmed !== true ||
      !Number.isInteger(minimumAge) ||
      minimumAge !== 18 ||
      !Number.isInteger(declaredAge) ||
      (declaredAge as number) < 18 ||
      (declaredAge as number) > 100
    ) {
      throw new HttpError(400, 'invalid_attestation');
    }

    const user = await deps.getUser(ownerId);
    await deps.setCustomUserClaims(ownerId, {
      ...(user.customClaims ?? {}),
      adult_eligible: true,
    });

    const registeredAtUtc = deps.nowUtc().toISOString();
    await deps.saveEligibilityRecord(ownerId, {
      adultEligible: true,
      minimumAge: 18,
      policyVersion,
      registeredAtUtc,
    });

    res.status(200).json({
      ownerId,
      adultEligible: true,
      minimumAge: 18,
      policyVersion,
      registeredAtUtc,
    });
  } catch (error) {
    sendHttpError(res, error);
  }
}

