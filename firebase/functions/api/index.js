const { ensureFirebaseAdminInitialized } = require('../lib/firebaseAdmin');
const { routeRequest } = require('../lib/router');

ensureFirebaseAdminInitialized();

module.exports = async function handler(req, res) {
  const query = { ...(req.query || {}) };
  const rewrittenRoute =
    typeof query.__sehatRoute === 'string' ? query.__sehatRoute : undefined;
  delete query.__sehatRoute;

  const urlPath = rewrittenRoute
    ? `/${rewrittenRoute}`
    : new URL(req.url || '/', 'http://localhost').pathname;

  await routeRequest(
    urlPath,
    {
      method: req.method || 'GET',
      headers: req.headers || {},
      query,
      body: req.body,
      rawBody: req.rawBody,
    },
    res,
  );
};

