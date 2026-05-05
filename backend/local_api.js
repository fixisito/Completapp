import http from "node:http";
import { URL } from "node:url";

const PORT = Number(process.env.PORT || 8787);

// Base local data so development works without scraping.
const localCache = new Map(
  Object.entries({
    "pan de completo": { price: 2300, formatName: "Bolsa 10 uds" },
    vienesa: { price: 2600, formatName: "Paquete 500g (10 uds)" },
    palta: { price: 3000, formatName: "Malla 1 Kg" },
    tomate: { price: 1500, formatName: "A granel 1 Kg" },
    mayonesa: { price: 2200, formatName: "Doypack 400g" },
    mostaza: { price: 1600, formatName: "Squeeze 400g" },
    chucrut: { price: 1500, formatName: "Frasco 250g" },
    ketchup: { price: 1800, formatName: "Doypack 400g" },
    "salsa americana": { price: 1300, formatName: "Frasco 250g" },
    "queso laminado": { price: 2600, formatName: "Paquete 250g (10 lams)" },
    "ají": { price: 1000, formatName: "Frasco 100g" },
  })
);

function normalizeItemName(name) {
  return name.trim().toLowerCase();
}

function json(res, status, payload) {
  const data = JSON.stringify(payload);
  res.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "access-control-allow-origin": "*",
    "access-control-allow-methods": "GET,POST,OPTIONS",
    "access-control-allow-headers": "content-type,x-refresh-token",
  });
  res.end(data);
}

function getItemsFromQuery(url) {
  const raw = url.searchParams.get("items") ?? "";
  return raw
    .split(",")
    .map((it) => normalizeItemName(it))
    .filter(Boolean);
}

function buildPriceItem(itemName) {
  const cached = localCache.get(itemName);
  if (cached && typeof cached.price === "number" && cached.price > 0) {
    return {
      itemName,
      formatName: cached.formatName,
      price: cached.price,
      currency: "CLP",
      source: "local",
      stale: false,
      status: "fresh",
      updatedAt: Date.now(),
    };
  }

  return {
    itemName,
    price: null,
    currency: "CLP",
    source: "none",
    stale: true,
    status: "unavailable",
    updatedAt: Date.now(),
  };
}

async function handleGetPrices(req, res, url) {
  const items = getItemsFromQuery(url);
  if (items.length === 0) {
    json(res, 400, {
      error: "Missing query param items. Example: /getPrices?items=pan,vienesa",
    });
    return;
  }

  const results = items.map((itemName) => buildPriceItem(itemName));
  json(res, 200, {
    updatedAt: Date.now(),
    count: results.length,
    items: results,
  });
}

async function readJsonBody(req) {
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(chunk);
  }
  if (chunks.length === 0) return {};
  const text = Buffer.concat(chunks).toString("utf8");
  if (!text) return {};
  return JSON.parse(text);
}

async function handleRefreshPrices(req, res) {
  try {
    const body = await readJsonBody(req);
    const items = Array.isArray(body.items)
      ? body.items.map((it) => normalizeItemName(String(it))).filter(Boolean)
      : [];

    // Local mode: optional manual overrides.
    for (const row of Array.isArray(body.overrides) ? body.overrides : []) {
      if (!row || typeof row !== "object") continue;
      const itemName = normalizeItemName(String(row.itemName ?? ""));
      const price = Number(row.price);
      const formatName = String(row.formatName ?? "").trim();
      if (!itemName || !Number.isFinite(price) || price <= 0) continue;
      localCache.set(itemName, { price, formatName });
    }

    const targetItems = items.length > 0 ? items : [...localCache.keys()];
    const refreshed = targetItems.map((itemName) => buildPriceItem(itemName));
    json(res, 200, {
      updatedAt: Date.now(),
      count: refreshed.length,
      items: refreshed,
      mode: "local",
    });
  } catch (error) {
    json(res, 400, { error: `Invalid JSON body: ${error}` });
  }
}

const server = http.createServer(async (req, res) => {
  const method = req.method ?? "GET";
  const url = new URL(req.url ?? "/", `http://localhost:${PORT}`);

  if (method === "OPTIONS") {
    json(res, 204, {});
    return;
  }

  if (method === "GET" && url.pathname === "/health") {
    json(res, 200, { ok: true, mode: "local", port: PORT });
    return;
  }

  if (method === "GET" && url.pathname === "/getPrices") {
    await handleGetPrices(req, res, url);
    return;
  }

  if (method === "POST" && url.pathname === "/refreshPrices") {
    await handleRefreshPrices(req, res);
    return;
  }

  json(res, 404, { error: "Not found" });
});

server.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Local Prices API running on http://localhost:${PORT}`);
});
