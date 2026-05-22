import http from 'node:http';
import { URL } from 'node:url';
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PRECIOS_FILE = join(__dirname, 'data', 'precios.json');
const PORT = Number(process.env.PORT || 8787);

/**
 * Carga los precios desde el archivo JSON generado por el scraper.
 * @returns {object}
 */
function loadPrices() {
  if (!existsSync(PRECIOS_FILE)) return { precios: {} };
  try {
    return JSON.parse(readFileSync(PRECIOS_FILE, 'utf8'));
  } catch {
    return { precios: {} };
  }
}

function json(res, status, payload) {
  const data = JSON.stringify(payload);
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
    'access-control-allow-headers': 'content-type',
  });
  res.end(data);
}

function normalizeItemName(name) {
  return name.trim().toLowerCase();
}

/**
 * GET /getPrices?items=mayonesa,pan de completo&segmento=lider
 *
 * Segmentos válidos: lider, jumbo, economico (menor), promedio (media)
 * Si no se especifica segmento, retorna el precio más bajo disponible.
 */
async function handleGetPrices(req, res, url) {
  const rawItems = url.searchParams.get('items') ?? '';
  const segmento = url.searchParams.get('segmento') ?? 'mejor';
  const items = rawItems
    .split(',')
    .map((it) => normalizeItemName(it))
    .filter(Boolean);

  if (items.length === 0) {
    json(res, 400, {
      error: 'Missing query param items. Example: /getPrices?items=mayonesa,vienesa',
    });
    return;
  }

  const cache = loadPrices();
  const results = [];

  for (const itemName of items) {
    // Buscar todas las entradas que matcheen este ingrediente
    const matches = Object.values(cache.precios || {}).filter(
      (p) => p.ingrediente === itemName
    );

    if (matches.length === 0) {
      results.push({
        itemName,
        price: null,
        formatName: null,
        source: 'none',
        status: 'unavailable',
      });
      continue;
    }

    // Para cada formato encontrado, seleccionar el precio según segmento
    for (const match of matches) {
      const fuentes = match.fuentes || {};
      let price = null;
      let source = 'none';

      if (segmento === 'lider' && fuentes.lider) {
        price = fuentes.lider.price;
        source = 'lider';
      } else if (segmento === 'jumbo' && fuentes.jumbo) {
        price = fuentes.jumbo.price;
        source = 'jumbo';
      } else if (segmento === 'economico') {
        // El más barato de todos
        const prices = Object.entries(fuentes)
          .map(([s, d]) => ({ source: s, price: d.price }))
          .sort((a, b) => a.price - b.price);
        if (prices.length > 0) {
          price = prices[0].price;
          source = prices[0].source;
        }
      } else if (segmento === 'promedio') {
        // Promedio de todas las fuentes
        const allPrices = Object.values(fuentes).map((d) => d.price);
        if (allPrices.length > 0) {
          price = Math.round(allPrices.reduce((a, b) => a + b, 0) / allPrices.length);
          source = 'promedio';
        }
      } else {
        // "mejor" = el más barato
        const prices = Object.entries(fuentes)
          .map(([s, d]) => ({ source: s, price: d.price }))
          .sort((a, b) => a.price - b.price);
        if (prices.length > 0) {
          price = prices[0].price;
          source = prices[0].source;
        }
      }

      if (price !== null) {
        results.push({
          itemName,
          formatName: match.formatoApp,
          gramaje: match.gramaje,
          marca: match.marca,
          price,
          currency: 'CLP',
          source,
          stale: !!match.stale,
          status: match.stale ? 'stale' : 'fresh',
          updatedAt: cache.updatedAt,
        });
      }
    }
  }

  json(res, 200, {
    updatedAt: cache.updatedAt,
    segmento,
    count: results.length,
    items: results,
  });
}

const server = http.createServer(async (req, res) => {
  const method = req.method ?? 'GET';
  const url = new URL(req.url ?? '/', `http://localhost:${PORT}`);

  if (method === 'OPTIONS') {
    json(res, 204, {});
    return;
  }

  if (method === 'GET' && url.pathname === '/health') {
    const cache = loadPrices();
    json(res, 200, {
      ok: true,
      mode: existsSync(PRECIOS_FILE) ? 'scraped' : 'empty',
      port: PORT,
      lastUpdate: cache.updatedAt || null,
      productCount: Object.keys(cache.precios || {}).length,
    });
    return;
  }

  if (method === 'GET' && url.pathname === '/getPrices') {
    await handleGetPrices(req, res, url);
    return;
  }

  json(res, 404, { error: 'Not found' });
});

server.listen(PORT, () => {
  console.log(`\n🌭 CompletApp API corriendo en http://localhost:${PORT}`);
  console.log(`   GET /health              → Estado del servicio`);
  console.log(`   GET /getPrices?items=...  → Consultar precios\n`);
});
