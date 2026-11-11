import { HttpError, HttpRequest, HttpResponse, sendHttpError } from './auth';
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

  switch (normalized) {
    case '/':
    case '/healthz':
      if (req.method.toUpperCase() !== 'GET') {
        sendHttpError(res, new HttpError(405, 'method_not_allowed'));
        return;
      }
      res.status(200).json({ ok: true, service: 'sehat-coach-backend' });
      return;
    case '/adultEligibility':
      await handleAdultEligibility(req, res, deps.adultEligibility?.());
      return;
    case '/accountDeletion':
      await handleAccountDeletion(req, res, deps.accountDeletion?.());
      return;
    case '/syncUpload':
      await handleSyncUpload(req, res, deps.sync?.());
      return;
    case '/syncPull':
      await handleSyncPull(req, res, deps.sync?.());
      return;
    default:
      res.status(404).json({ error: 'not_found' });
  }
}

