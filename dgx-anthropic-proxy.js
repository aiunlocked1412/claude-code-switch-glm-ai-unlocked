"use strict";

/**
 * Anthropic-API shim in front of a local OpenAI-compatible server.
 *
 * Two jobs, both of which Claude Code cannot do for itself:
 *
 * 1. Move `system` / `developer` turns out of `messages` and into `system`,
 *    which is where the chat templates on these servers expect them.
 *
 * 2. Turn off the model's thinking mode by default.
 *
 * The second one is the reason this matters for speed. Qwen3's template has
 * thinking on unless the request says otherwise, and on a trivial prompt the
 * whole token budget goes to reasoning before any answer appears:
 *
 *     /v1/messages, max_tokens 32, default   32 output tokens, all reasoning,
 *                                            visible answer: ""
 *     ... with enable_thinking false          2 output tokens, answer: "OK"
 *
 * Claude Code takes many small turns -- read a file, run a command, decide the
 * next step -- and paying a full reasoning block for each one is what makes a
 * local session feel stuck. The toggle is a per-request field the Anthropic API
 * has no way to express, so it gets injected here.
 *
 * Set DGX_THINKING=1 to keep thinking on for work that is worth it.
 *
 *   DGX_PROXY_UPSTREAM   default http://192.168.1.150:8888   (vLLM on dgx1)
 *   DGX_PROXY_PORT       default 18151
 *   DGX_THINKING         1 = leave thinking enabled
 */

const http = require("node:http");
const { Readable } = require("node:stream");

const listenHost = "127.0.0.1";
const listenPort = Number(process.env.DGX_PROXY_PORT || 18151);
const upstreamBaseUrl = process.env.DGX_PROXY_UPSTREAM || "http://192.168.1.150:8888";
const thinking = process.env.DGX_THINKING === "1";

function asSystemBlocks(system) {
  if (Array.isArray(system)) return system;
  if (typeof system === "string" && system.length > 0) {
    return [{ type: "text", text: system }];
  }
  return [];
}

function normalizeAnthropicBody(body) {
  if (Array.isArray(body.messages)) {
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
  }

  // Only set when the caller has not: an explicit choice upstream wins.
  if (!thinking && body.chat_template_kwargs === undefined) {
    body.chat_template_kwargs = { enable_thinking: false };
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
    response.end(JSON.stringify({ ok: true, upstream: upstreamBaseUrl, thinking }));
    return;
  }

  try {
    let bodyBuffer = await readRequestBody(request);
    if (
      request.method === "POST" &&
      (request.url?.startsWith("/v1/messages") || request.url?.startsWith("/v1/chat/completions")) &&
      bodyBuffer.length > 0
    ) {
      try {
        const body = JSON.parse(bodyBuffer.toString("utf8"));
        bodyBuffer = Buffer.from(JSON.stringify(normalizeAnthropicBody(body)));
      } catch {
        // Not JSON we understand: pass it through untouched rather than 500.
      }
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
