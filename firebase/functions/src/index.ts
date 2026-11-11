import { onRequest } from 'firebase-functions/v2/https';
import { handleFetchRequest } from './fetchHandler';
import { handleAccountDeletion } from './handlers/accountDeletion';
import { handleAdultEligibility } from './handlers/adultEligibility';
import { handleSyncPull, handleSyncUpload } from './handlers/sync';

const REGION = 'asia-south1';

export const adultEligibility = onRequest(
  { region: REGION, maxInstances: 10 },
  (req, res) => handleAdultEligibility(req, res),
);

export const accountDeletion = onRequest(
  { region: REGION, maxInstances: 10 },
  (req, res) => handleAccountDeletion(req, res),
);

export const syncUpload = onRequest(
  { region: REGION, maxInstances: 20 },
  (req, res) => handleSyncUpload(req, res),
);

export const syncPull = onRequest(
  { region: REGION, maxInstances: 20 },
  (req, res) => handleSyncPull(req, res),
);

// Web-standard entrypoint used by Vercel zero-config backend deployments.
export default {
  async fetch(request: Request): Promise<Response> {
    return handleFetchRequest(request);
  },
};
