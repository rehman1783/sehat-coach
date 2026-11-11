import { HttpRequest, HttpResponse, sendHttpError } from './auth';
import { MAX_HTTP_BODY_BYTES, searchParamsToQuery } from './httpAdapter';
import { RouterDeps, routeRequest } from './router';

const JSON_HEADERS = {
  'content-type': 'application/json; charset=utf-8',
  'cache-control': 'no-store',
};

export async function handleFetchRequest(
  request: Request,
  deps: RouterDeps = {},
): Promise<Response> {
  let statusCode = 200;
  let responseBody: unknown = { error: 'internal_error' };
  const captureRes: HttpResponse = {
    status(code: number) {
      statusCode = code;
      return this;
    },
    json(body: unknown) {
      responseBody = body;
    },
  };

  try {
    const url = new URL(request.url);
    const method = request.method.toUpperCase();
    const headers: Record<string, string> = {};
    request.headers.forEach((value, key) => {
      headers[key.toLowerCase()] = value;
    });

    let rawBody: Buffer | undefined;
    if (method === 'POST') {
      const buffer = await request.arrayBuffer();
      if (buffer.byteLength > MAX_HTTP_BODY_BYTES) {
        return new Response(JSON.stringify({ error: 'payload_too_large' }), {
          status: 413,
          headers: JSON_HEADERS,
        });
      }
      rawBody = Buffer.from(buffer);
    }

    const httpReq: HttpRequest = {
      method,
      headers,
      query: searchParamsToQuery(url.searchParams),
      body: rawBody,
      rawBody,
    };
    await routeRequest(url.pathname, httpReq, captureRes, deps);
    return new Response(JSON.stringify(responseBody), {
      status: statusCode,
      headers: JSON_HEADERS,
    });
  } catch (error) {
    sendHttpError(captureRes, error);
    return new Response(JSON.stringify(responseBody), {
      status: statusCode,
      headers: JSON_HEADERS,
    });
  }
}

