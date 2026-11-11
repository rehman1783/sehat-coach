import { HttpError, HttpRequest, HttpResponse, sendHttpError } from './auth';
import { tryEnsureFirebaseAdminInitialized } from './firebaseAdmin';
import {
  AccountDeletionDeps,
  handleAccountDeletion,
} from './handlers/accountDeletion';
import {
  AdultEligibilityDeps,
  handleAdultEligibility,
} from './handlers/adultEligibility';
import { SyncDeps, handleSyncPull, handleSyncUpload } from './handlers/sync';

export interface RouterDeps {
  adultEligibility?: () => AdultEligibilityDeps;
  accountDeletion?: () => AccountDeletionDeps;
  sync?: () => SyncDeps;
  ensureAdmin?: () => { ready: boolean; configStatus: string };
}

export function normalizeRoutePath(pathname: string): string {
  const withoutTrailingSlash = pathname.replace(/\/+$/, '') || '/';
  if (withoutTrailingSlash.startsWith('/api/')) {
    return withoutTrailingSlash.slice(4) || '/';
  }
  return withoutTrailingSlash;
}

export async function routeRequest(
  pathname: string,
  req: HttpRequest,
  res: HttpResponse,
  deps: RouterDeps = {},
): Promise<void> {
  const normalized = normalizeRoutePath(pathname);

  if (normalized === '/' || normalized === '/healthz') {
    if (req.method.toUpperCase() !== 'GET') {
      sendHttpError(res, new HttpError(405, 'method_not_allowed'));
      return;
    }
    const status = (deps.ensureAdmin ?? tryEnsureFirebaseAdminInitialized)();
    res.status(200).json({
      ok: true,
      service: 'sehat-coach-backend',
      firebaseAdminConfigured: status.ready,
      configStatus: status.configStatus,
    });
    return;
  }

  const ensureConfigured = (): boolean => {
    if (
      (normalized === '/adultEligibility' && deps.adultEligibility) ||
      (normalized === '/accountDeletion' && deps.accountDeletion) ||
      ((normalized === '/syncUpload' || normalized === '/syncPull') && deps.sync)
    ) {
      return true;
    }
    const status = (deps.ensureAdmin ?? tryEnsureFirebaseAdminInitialized)();
    if (!status.ready) {
      res.status(503).json({
        error: 'backend_not_configured',
        configStatus: status.configStatus,
      });
      return false;
    }
    return true;
  };

  switch (normalized) {
    case '/adultEligibility':
      if (!ensureConfigured()) return;
      await handleAdultEligibility(req, res, deps.adultEligibility?.());
      return;
    case '/accountDeletion':
      if (!ensureConfigured()) return;
      await handleAccountDeletion(req, res, deps.accountDeletion?.());
      return;
    case '/syncUpload':
      if (!ensureConfigured()) return;
      await handleSyncUpload(req, res, deps.sync?.());
      return;
    case '/syncPull':
      if (!ensureConfigured()) return;
      await handleSyncPull(req, res, deps.sync?.());
      return;
    default:
      res.status(404).json({ error: 'not_found' });
  }
}
