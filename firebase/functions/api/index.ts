import { sendHttpError } from '../src/auth';
import {
  IncomingNodeRequest,
  NodeOrFrameworkResponse,
  createJsonResponseAdapter,
  toHttpRequest,
} from '../src/httpAdapter';
import { RouterDeps, routeRequest } from '../src/router';

export async function handleVercelRequest(
  nodeReq: IncomingNodeRequest,
  nodeRes: NodeOrFrameworkResponse,
  deps: RouterDeps = {},
): Promise<void> {
  const res = createJsonResponseAdapter(nodeRes);
  try {
    const { pathname, request } = await toHttpRequest(nodeReq);
    const query = { ...request.query };
    const rewrittenRoute =
      typeof query.__sehatRoute === 'string'
        ? query.__sehatRoute.trim()
        : undefined;
    delete query.__sehatRoute;

    const effectivePath = rewrittenRoute ? `/${rewrittenRoute}` : pathname;
    await routeRequest(effectivePath, { ...request, query }, res, deps);
  } catch (error) {
    sendHttpError(res, error);
  }
}

export default async function handler(
  req: IncomingNodeRequest,
  res: NodeOrFrameworkResponse,
): Promise<void> {
  await handleVercelRequest(req, res);
}

