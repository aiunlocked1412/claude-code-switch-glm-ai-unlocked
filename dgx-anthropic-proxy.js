"use strict";

const http = require("node:http");
const { Readable } = require("node:stream");

const listenHost = "127.0.0.1";
const listenPort = 18150;
const upstreamBaseUrl = "http://192.168.1.150:8080";

function asSystemBlocks(system) {
  if (Array.isArray(system)) return system;
  if (typeof system === "string" && system.length > 0) {
    return [{ type: "text", text: system }];
  }
  return [];
}

function normalizeAnthropicBody(body) {
  if (!Array.isArray(body.messages)) return body;

  const movedSystemBlocks = [];
  body.messages = body.messages.filter((message) => {
    if (message?.role !== "system" && message?.role !== "developer") return true;
    if (Array.isArray(message.content)) {
      movedSystemBlocks.push(...message.content);
    } else if (typeof message.content === "string") {
      movedSystemBlocks.push({ type: "text", text: message.content });
    }
    return false;
  });

  if (movedSystemBlocks.length > 0) {
    body.system = [...asSystemBlocks(body.system), ...movedSystemBlocks];
  }
  return body;
}

function readRequestBody(request) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    request.on("data", (chunk) => chunks.push(chunk));
    request.on("end", () => resolve(Buffer.concat(chunks)));
    request.on("error", reject);
  });
}

const server = http.createServer(async (request, response) => {
  if (request.method === "GET" && request.url === "/health") {
    response.writeHead(200, { "content-type": "application/json" });
    response.end(JSON.stringify({ ok: true, upstream: upstreamBaseUrl }));
    return;
  }

  try {
    let bodyBuffer = await readRequestBody(request);
    if (
      request.method === "POST" &&
      request.url?.startsWith("/v1/messages") &&
      bodyBuffer.length > 0
    ) {
      const body = JSON.parse(bodyBuffer.toString("utf8"));
      bodyBuffer = Buffer.from(JSON.stringify(normalizeAnthropicBody(body)));
    }

    const headers = { ...request.headers };
    delete headers.host;
    delete headers.connection;
    delete headers["content-length"];

    const upstream = await fetch(new URL(request.url, upstreamBaseUrl), {
      method: request.method,
      headers,
      body: request.method === "GET" || request.method === "HEAD" ? undefined : bodyBuffer,
    });

    const responseHeaders = {};
    upstream.headers.forEach((value, name) => {
      if (!["connection", "content-length", "transfer-encoding"].includes(name)) {
        responseHeaders[name] = value;
      }
    });
    response.writeHead(upstream.status, responseHeaders);

    if (upstream.body) {
      Readable.fromWeb(upstream.body).pipe(response);
    } else {
      response.end();
    }
  } catch (error) {
    if (!response.headersSent) {
      response.writeHead(502, { "content-type": "application/json" });
    }
    response.end(JSON.stringify({ error: "DGX proxy error: " + error.message }));
  }
});

server.listen(listenPort, listenHost);
