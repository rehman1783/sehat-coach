import type {
  IncomingNodeRequest,
  NodeOrFrameworkResponse,
} from '../src/httpAdapter';

function writeFallbackJson(
  res: NodeOrFrameworkResponse,
  statusCode: number,
  payload: unknown,
): void {
  if (typeof res.status === 'function' && typeof res.json === 'function') {
    const statusResult = res.status(statusCode);
    if (typeof statusResult?.json === 'function') {
      statusResult.json(payload);
      return;
    }
    res.statusCode = statusCode;
    res.json(payload);
    return;
  }
  if (!res.headersSent) {
    res.writeHead(statusCode, {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store',
    });
    res.end(JSON.stringify(payload));
  }
}

export default async function handler(
  nodeReq: IncomingNodeRequest,
  nodeRes: NodeOrFrameworkResponse,
): Promise<void> {
  try {
    const [{ sendHttpError }, httpAdapter, { routeRequest }] = await Promise.all([
      import('../src/auth'),
      import('../src/httpAdapter'),
      import('../src/router'),
    ]);

    const res = httpAdapter.createJsonResponseAdapter(nodeRes);
    try {
      const { pathname, request } = await httpAdapter.toHttpRequest(nodeReq);
      const query = { ...request.query };
      const rewrittenRoute =
        typeof query.__sehatRoute === 'string'
          ? query.__sehatRoute.trim()
          : undefined;
      delete query.__sehatRoute;

      const effectivePath = rewrittenRoute ? `/${rewrittenRoute}` : pathname;
      await routeRequest(effectivePath, { ...request, query }, res);
    } catch (error) {
      sendHttpError(res, error);
    }
  } catch (error) {
    const err = error as { name?: unknown; code?: unknown; message?: unknown };
    writeFallbackJson(nodeRes, 500, {
      error: 'bootstrap_failed',
      name: typeof err?.name === 'string' ? err.name : 'Error',
      code: typeof err?.code === 'string' ? err.code : null,
      message: typeof err?.message === 'string' ? err.message : 'unknown_error',
    });
  }
}
