import http from 'node:http';
import { sendHttpError } from './auth';
import { ensureFirebaseAdminInitialized } from './firebaseAdmin';
import {
  NodeOrFrameworkResponse,
  createJsonResponseAdapter,
  toHttpRequest,
} from './httpAdapter';
import { RouterDeps, routeRequest } from './router';

export function createNodeHttpServer(deps: RouterDeps = {}): http.Server {
  return http.createServer(async (nodeReq, nodeRes) => {
    const res = createJsonResponseAdapter(nodeRes as NodeOrFrameworkResponse);
    try {
      const { pathname, request } = await toHttpRequest(nodeReq);
      await routeRequest(pathname, request, res, deps);
    } catch (error) {
      sendHttpError(res, error);
    }
  });
}

if (require.main === module) {
  ensureFirebaseAdminInitialized();
  const parsedPort = Number(process.env.PORT ?? '8080');
  const port = Number.isFinite(parsedPort) && parsedPort > 0 ? parsedPort : 8080;
  const server = createNodeHttpServer();
  server.listen(port, '0.0.0.0', () => {
    console.log(`Sehat Coach backend listening on port ${port}`);
  });
}
