import { App, cert, getApps, initializeApp } from 'firebase-admin/app';
import { stripWrappingQuotes } from './httpAdapter';

interface ServiceAccountEnvShape {
  projectId: string;
  clientEmail: string;
  privateKey: string;
}

export class FirebaseAdminConfigError extends Error {
  constructor(public readonly code: string) {
    super(code);
  }
}

function readServiceAccountFromEnv(): ServiceAccountEnvShape | null {
  const rawJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (rawJson) {
    let parsed: Record<string, unknown>;
    try {
      parsed = JSON.parse(rawJson) as Record<string, unknown>;
    } catch {
      throw new FirebaseAdminConfigError('invalid_service_account_json');
    }
    const projectId =
      typeof parsed.project_id === 'string'
        ? parsed.project_id
        : typeof parsed.projectId === 'string'
          ? parsed.projectId
          : '';
    const clientEmail =
      typeof parsed.client_email === 'string'
        ? parsed.client_email
        : typeof parsed.clientEmail === 'string'
          ? parsed.clientEmail
          : '';
    const privateKeyRaw =
      typeof parsed.private_key === 'string'
        ? parsed.private_key
        : typeof parsed.privateKey === 'string'
          ? parsed.privateKey
          : '';
    if (!projectId || !clientEmail || !privateKeyRaw) {
      throw new FirebaseAdminConfigError('incomplete_service_account_json');
    }
    return {
      projectId: stripWrappingQuotes(projectId),
      clientEmail: stripWrappingQuotes(clientEmail),
      privateKey: stripWrappingQuotes(privateKeyRaw).replace(/\\n/g, '\n'),
    };
  }

  const projectId = stripWrappingQuotes(process.env.FIREBASE_PROJECT_ID ?? '');
  const clientEmail = stripWrappingQuotes(
    process.env.FIREBASE_CLIENT_EMAIL ?? '',
  );
  const privateKeyRaw = stripWrappingQuotes(
    process.env.FIREBASE_PRIVATE_KEY ?? '',
  );
  if (projectId || clientEmail || privateKeyRaw) {
    if (!projectId || !clientEmail || !privateKeyRaw) {
      throw new FirebaseAdminConfigError('incomplete_firebase_env_vars');
    }
    return {
      projectId,
      clientEmail,
      privateKey: privateKeyRaw.replace(/\\n/g, '\n'),
    };
  }
  return null;
}

export function ensureFirebaseAdminInitialized(): App {
  if (getApps().length > 0) {
    return getApps()[0];
  }
  const credentials = readServiceAccountFromEnv();
  if (credentials) {
    return initializeApp({
      credential: cert({
        projectId: credentials.projectId,
        clientEmail: credentials.clientEmail,
        privateKey: credentials.privateKey,
      }),
      projectId: credentials.projectId,
    });
  }
  return initializeApp();
}

export function tryEnsureFirebaseAdminInitialized(): {
  ready: boolean;
  configStatus: string;
} {
  try {
    ensureFirebaseAdminInitialized();
    const hasEnvCredentials =
      Boolean(process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim()) ||
      Boolean(
        process.env.FIREBASE_CLIENT_EMAIL?.trim() &&
          process.env.FIREBASE_PRIVATE_KEY?.trim(),
      ) ||
      Boolean(process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim()) ||
      Boolean(process.env.K_SERVICE || process.env.FUNCTION_TARGET);
    return {
      ready: hasEnvCredentials,
      configStatus: hasEnvCredentials ? 'ready' : 'missing_service_account_env',
    };
  } catch (error) {
    if (error instanceof FirebaseAdminConfigError) {
      return { ready: false, configStatus: error.code };
    }
    return { ready: false, configStatus: 'firebase_admin_init_error' };
  }
}
