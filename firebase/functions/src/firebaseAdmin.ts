import { App, cert, getApps, initializeApp } from 'firebase-admin/app';

interface ServiceAccountEnvShape {
  projectId: string;
  clientEmail: string;
  privateKey: string;
}

function readServiceAccountFromEnv(): ServiceAccountEnvShape | null {
  const rawJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (rawJson) {
    const parsed = JSON.parse(rawJson) as Record<string, unknown>;
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
      throw new Error(
        'FIREBASE_SERVICE_ACCOUNT_JSON is missing required credential fields.',
      );
    }
    return {
      projectId,
      clientEmail,
      privateKey: privateKeyRaw.replace(/\\n/g, '\n'),
    };
  }

  const projectId = process.env.FIREBASE_PROJECT_ID?.trim();
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL?.trim();
  const privateKeyRaw = process.env.FIREBASE_PRIVATE_KEY?.trim();
  if (projectId || clientEmail || privateKeyRaw) {
    if (!projectId || !clientEmail || !privateKeyRaw) {
      throw new Error(
        'FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY must be set together.',
      );
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

