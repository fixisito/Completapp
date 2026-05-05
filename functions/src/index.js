const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const CACHE_COLLECTION = "priceCache";
const MANUAL_COLLECTION = "manualPrices";
const CONFIG_COLLECTION = "config";
const DEFAULT_ITEMS = [
  "pan de completo",
  "vienesa",
  "palta",
  "tomate",
  "mayonesa",
];
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

function normalizeItemName(name) {
  return name.trim().toLowerCase();
}

function toDocId(itemName) {
  return normalizeItemName(itemName).replace(/[^a-z0-9]+/g, "_");
}

function extractPriceCandidates(text) {
  const matches = text.match(/\$\s?(\d{1,3}(?:\.\d{3})+)/g) ?? [];
  return matches
    .map((raw) => Number(raw.replace(/[^0-9]/g, "")))
    .filter((n) => Number.isFinite(n) && n > 100);
}

async function scrapeLiderPrice(itemName) {
  const query = encodeURIComponent(itemName);
  const url = `https://super.lider.cl/search?q=${query}`;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 12000);

  try {
    const response = await fetch(url, { signal: controller.signal });
    if (!response.ok) {
      throw new Error(`Lider HTTP ${response.status}`);
    }

    const html = await response.text();
    const prices = extractPriceCandidates(html);
    if (prices.length === 0) {
      throw new Error("No se encontraron precios en la respuesta");
    }

    const best = Math.min(...prices);
    return {
      provider: "lider",
      price: best,
      currency: "CLP",
      url,
      scrapedAt: Date.now(),
    };
  } finally {
    clearTimeout(timeoutId);
  }
}

async function getManualPrice(itemKey) {
  const doc = await db.collection(MANUAL_COLLECTION).doc(itemKey).get();
  if (!doc.exists) return null;
  return doc.data() ?? null;
}

async function getCacheDoc(itemKey) {
  return db.collection(CACHE_COLLECTION).doc(itemKey).get();
}

function isFresh(updatedAtMs) {
  return Date.now() - updatedAtMs < CACHE_TTL_MS;
}

function parseUpdatedAt(data) {
  if (!data?.updatedAt) return 0;
  if (typeof data.updatedAt === "number") return data.updatedAt;
  if (typeof data.updatedAt?.toMillis === "function") {
    return data.updatedAt.toMillis();
  }
  return 0;
}

async function refreshItemPrice(itemName) {
  const itemKey = toDocId(itemName);
  const itemNormalized = normalizeItemName(itemName);
  const cacheRef = db.collection(CACHE_COLLECTION).doc(itemKey);
  const cacheSnap = await getCacheDoc(itemKey);
  const oldCache = cacheSnap.exists ? cacheSnap.data() : null;

  const manual = await getManualPrice(itemKey);
  if (manual && typeof manual.price === "number" && manual.price > 0) {
    const payload = {
      itemKey,
      itemName: itemNormalized,
      price: manual.price,
      currency: manual.currency || "CLP",
      source: "manual",
      status: "fresh",
      stale: false,
      updatedAt: Date.now(),
      providerData: {
        manual: {
          note: manual.note || "manual override",
        },
      },
    };
    await cacheRef.set(payload, { merge: true });
    return payload;
  }

  try {
    const scraped = await scrapeLiderPrice(itemName);
    const payload = {
      itemKey,
      itemName: itemNormalized,
      price: scraped.price,
      currency: scraped.currency,
      source: "scrape",
      status: "fresh",
      stale: false,
      updatedAt: Date.now(),
      providerData: {
        lider: {
          price: scraped.price,
          url: scraped.url,
          scrapedAt: scraped.scrapedAt,
        },
      },
    };
    await cacheRef.set(payload, { merge: true });
    return payload;
  } catch (error) {
    logger.error("Scraping error", { itemName: itemNormalized, error: String(error) });
    if (oldCache) {
      return {
        ...oldCache,
        stale: true,
        status: "stale",
        reason: "scrape_failed_using_cached",
      };
    }
    return {
      itemKey,
      itemName: itemNormalized,
      price: null,
      currency: "CLP",
      source: "none",
      status: "unavailable",
      stale: true,
      reason: "scrape_failed_no_cache",
      updatedAt: Date.now(),
    };
  }
}

async function getPriceForItem(itemName, forceRefresh = false) {
  const itemKey = toDocId(itemName);
  const cacheSnap = await getCacheDoc(itemKey);
  if (!forceRefresh && cacheSnap.exists) {
    const data = cacheSnap.data() ?? {};
    const updatedAtMs = parseUpdatedAt(data);
    if (updatedAtMs > 0 && isFresh(updatedAtMs)) {
      return { ...data, stale: false, status: "fresh" };
    }
  }
  return refreshItemPrice(itemName);
}

async function getCatalogItems() {
  const doc = await db.collection(CONFIG_COLLECTION).doc("pricingCatalog").get();
  if (!doc.exists) return DEFAULT_ITEMS;
  const data = doc.data() ?? {};
  const items = Array.isArray(data.items) ? data.items : DEFAULT_ITEMS;
  return items.filter((item) => typeof item === "string" && item.trim().length > 0);
}

exports.getPrices = onRequest(async (req, res) => {
  if (req.method !== "GET") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const itemsRaw = req.query.items;
  const forceRefresh = req.query.refresh === "1";
  const items = (typeof itemsRaw === "string" ? itemsRaw.split(",") : [])
    .map((item) => item.trim())
    .filter(Boolean);

  if (items.length === 0) {
    res.status(400).json({
      error: "Missing query param items. Example: /prices?items=pan,vienesa",
    });
    return;
  }

  const results = await Promise.all(
    items.map((item) => getPriceForItem(item, forceRefresh)),
  );

  res.status(200).json({
    updatedAt: Date.now(),
    count: results.length,
    items: results,
  });
});

exports.refreshPrices = onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const configuredToken = process.env.REFRESH_TOKEN;
  const incomingToken = req.get("x-refresh-token");
  if (configuredToken && incomingToken !== configuredToken) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const bodyItems = Array.isArray(req.body?.items) ? req.body.items : [];
  const items = bodyItems.length > 0 ? bodyItems : await getCatalogItems();

  const refreshed = await Promise.all(items.map((item) => refreshItemPrice(item)));
  res.status(200).json({
    updatedAt: Date.now(),
    count: refreshed.length,
    items: refreshed,
  });
});

exports.dailyPriceRefresh = onSchedule(
  {
    schedule: "every day 06:00",
    timeZone: "America/Santiago",
    retryCount: 2,
  },
  async () => {
    const items = await getCatalogItems();
    logger.info("Running daily price refresh", { count: items.length });
    await Promise.all(items.map((item) => refreshItemPrice(item)));
  },
);
