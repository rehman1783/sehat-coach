import http from 'node:http';
import { HttpError, HttpRequest, HttpResponse, sendHttpError } from './auth';
import { ensureFirebaseAdminInitialized } from './firebaseAdmin';
import { RouterDeps, routeRequest } from './router';

// Slightly exceeds the 256 KiB upload cap so auth/sync checks handle bounds cleanly.
const MAX_HTTP_BODY_BYTES = 260 * 1024;

function readRequestBody(
  req: http.IncomingMessage,
  maxBytes: number,
): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    let total = 0;
    let settled = false;

    req.on('data', (chunk: Buffer | string) => {
      if (settled) return;
      const buf = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk, 'utf8');
      total += buf.byteLength;
      if (total > maxBytes) {
        settled = true;
        reject(new HttpError(413, 'payload_too_large'));
        req.destroy();
        return;
      }
      chunks.push(buf);
    });
    req.on('end', () => {
      if (settled) return;
      settled = true;
      resolve(Buffer.concat(chunks));
    });
    req.on('error', (err) => {
      if (settled) return;
      settled = true;
      reject(err);
    });
  });
}

function createJsonResponseAdapter(res: http.ServerResponse): HttpResponse {
  let statusCode = 200;
  return {
    status(code: number) {
      statusCode = code;
      return this;
    },
    json(body: unknown) {
      if (res.headersSent) return;
      res.writeHead(statusCode, {
        'content-type': 'application/json; charset=utf-8',
        'cache-control': 'no-store',
      });
      res.end(JSON.stringify(body));
    },
  };
}

export function createNodeHttpServer(deps: RouterDeps = {}): http.Server {
  return http.createServer(async (nodeReq, nodeRes) => {
    const res = createJsonResponseAdapter(nodeRes);
    try {
      const url = new URL(nodeReq.url ?? '/', 'http://localhost');
      const query: Record<string, string | string[]> = {};
      for (const [key, value] of url.searchParams.entries()) {
        const existing = query[key];
        if (existing === undefined) {
          query[key] = value;
        } else if (Array.isArray(existing)) {
          existing.push(value);
        } else {
          query[key] = [existing, value];
        }
      }

      const method = (nodeReq.method ?? 'GET').toUpperCase();
      const rawBody =
        method === 'POST'
          ? await readRequestBody(nodeReq, MAX_HTTP_BODY_BYTES)
          : undefined;
      const req: HttpRequest = {
        method,
        headers: nodeReq.headers,
        query,
        body: rawBody,
        rawBody,
      };
      await routeRequest(url.pathname, req, res, deps);
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

