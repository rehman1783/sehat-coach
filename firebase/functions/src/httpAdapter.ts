import http from 'node:http';
import { HttpError, HttpRequest, HttpResponse } from './auth';

// Slightly exceeds the 256 KiB upload cap so auth/sync checks handle bounds cleanly.
export const MAX_HTTP_BODY_BYTES = 260 * 1024;

export function stripWrappingQuotes(value: string): string {
  const trimmed = value.trim();
  if (
    trimmed.length >= 2 &&
    ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
      (trimmed.startsWith("'") && trimmed.endsWith("'")))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

export function extractQueryParams(
  rawUrl: string | undefined,
): Record<string, string | string[]> {
  const url = new URL(rawUrl ?? '/', 'http://localhost');
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
  return query;
}

export function readRequestBody(
  req: http.IncomingMessage,
  maxBytes: number = MAX_HTTP_BODY_BYTES,
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

export interface NodeOrFrameworkResponse extends http.ServerResponse {
  status?: (code: number) => NodeOrFrameworkResponse;
  json?: (body: unknown) => void;
}

export function createJsonResponseAdapter(
  res: NodeOrFrameworkResponse,
): HttpResponse {
  if (typeof res.status === 'function' && typeof res.json === 'function') {
    const frameworkRes = res;
    let currentCode = 200;
    return {
      status(code: number) {
        currentCode = code;
        frameworkRes.status!(code);
        return this;
      },
      json(body: unknown) {
        if (!frameworkRes.headersSent) {
          frameworkRes.setHeader?.('cache-control', 'no-store');
        }
        frameworkRes.status!(currentCode).json!(body);
      },
    };
  }

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

export type IncomingNodeRequest = http.IncomingMessage & {
  query?: Record<string, unknown>;
  body?: unknown;
  rawBody?: Buffer;
};

export async function toHttpRequest(
  nodeReq: IncomingNodeRequest,
): Promise<{ pathname: string; request: HttpRequest }> {
  const url = new URL(nodeReq.url ?? '/', 'http://localhost');
  const method = (nodeReq.method ?? 'GET').toUpperCase();
  const query = nodeReq.query ?? extractQueryParams(nodeReq.url);

  let body = nodeReq.body;
  let rawBody = nodeReq.rawBody;
  if (method === 'POST' && body === undefined && rawBody === undefined) {
    rawBody = await readRequestBody(nodeReq, MAX_HTTP_BODY_BYTES);
    body = rawBody;
  }

  return {
    pathname: url.pathname,
    request: {
      method,
      headers: nodeReq.headers ?? {},
      query,
      body,
      rawBody,
    },
  };
}

