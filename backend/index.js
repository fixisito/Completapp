import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { CATALOGO, catalogoPorIngrediente, queriesUnicas } from './config/catalogo.js';
import { matchProducto } from './utils/normalizer.js';
import { LiderScraper } from './scrapers/lider_scraper.js';
import { JumboScraper } from './scrapers/jumbo_scraper.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DATA_DIR = join(__dirname, 'data');
const PRECIOS_FILE = join(DATA_DIR, 'precios.json');

/**
 * Orquestador: ejecuta todos los scrapers y guarda los resultados.
 */
async function run() {
  console.log('═══════════════════════════════════════════════');
  console.log('  CompletApp Scraper - Inicio de extracción');
  console.log(`  Fecha: ${new Date().toLocaleString('es-CL')}`);
  console.log('═══════════════════════════════════════════════\n');

  // Cargar precios previos (para mantener los que no se actualicen)
  let prevData = {};
  if (existsSync(PRECIOS_FILE)) {
    try {
      prevData = JSON.parse(readFileSync(PRECIOS_FILE, 'utf8'));
    } catch { /* archivo corrupto, empezar de cero */ }
  }

  const catalogo = catalogoPorIngrediente();
  const queries = queriesUnicas();

  // Resultados por supermercado
  const resultados = {
    lider: {},
    jumbo: {},
  };

  // ── Scraper Lider ──────────────────────────────────────────
  const lider = new LiderScraper();
  try {
    await lider.init();

    for (const query of queries) {
      // Pequeña pausa entre búsquedas para no parecer bot
      await sleep(2000 + Math.random() * 2000);

      const cards = await lider.search(query);

      // Intentar matchear cada card contra el catálogo
      for (const cardText of cards) {
        for (const [ingrediente, entries] of catalogo) {
          const match = matchProducto(cardText, entries);
          if (match) {
            const key = `${ingrediente}|${match.entry.formatoApp}`;
            if (!resultados.lider[key] || match.price < resultados.lider[key].price) {
              resultados.lider[key] = {
                ingrediente,
                marca: match.entry.marca,
                formatoApp: match.entry.formatoApp,
                gramaje: match.entry.gramaje,
                price: match.price,
                source: 'lider',
                scrapedAt: Date.now(),
              };
            }
          }
        }
      }
    }
  } catch (error) {
    console.error(`[Lider] Error general: ${error.message}`);
  } finally {
    await lider.close();
  }

  // ── Scraper Jumbo ──────────────────────────────────────────
  console.log('[Jumbo] Saltando extracción por ahora (Protección Anti-Bot activa).');


  // ── Consolidar resultados ──────────────────────────────────
  const consolidated = {
    updatedAt: Date.now(),
    updatedAtHuman: new Date().toLocaleString('es-CL'),
    precios: {},
  };

  // Fusionar resultados de ambos supermercados
  for (const [source, data] of Object.entries(resultados)) {
    for (const [key, item] of Object.entries(data)) {
      if (!consolidated.precios[key]) {
        consolidated.precios[key] = {
          ingrediente: item.ingrediente,
          formatoApp: item.formatoApp,
          gramaje: item.gramaje,
          marca: item.marca,
          fuentes: {},
        };
      }
      consolidated.precios[key].fuentes[source] = {
        price: item.price,
        scrapedAt: item.scrapedAt,
      };
    }
  }

  // Mantener precios previos para productos que no se pudieron scrapear hoy
  if (prevData.precios) {
    for (const [key, prev] of Object.entries(prevData.precios)) {
      if (!consolidated.precios[key]) {
        consolidated.precios[key] = {
          ...prev,
          stale: true, // Marcar como datos viejos
        };
      }
    }
  }

  // ── Guardar resultados ─────────────────────────────────────
  if (!existsSync(DATA_DIR)) mkdirSync(DATA_DIR, { recursive: true });
  writeFileSync(PRECIOS_FILE, JSON.stringify(consolidated, null, 2), 'utf8');

  // ── Resumen ────────────────────────────────────────────────
  const liderCount = Object.keys(resultados.lider).length;
  const jumboCount = Object.keys(resultados.jumbo).length;
  const totalCount = Object.keys(consolidated.precios).length;

  console.log('\n═══════════════════════════════════════════════');
  console.log('  Resumen de extracción');
  console.log('═══════════════════════════════════════════════');
  console.log(`  Lider:  ${liderCount} productos encontrados`);
  console.log(`  Jumbo:  ${jumboCount} productos encontrados`);
  console.log(`  Total:  ${totalCount} productos en cache`);
  console.log(`  Archivo: ${PRECIOS_FILE}`);
  console.log('═══════════════════════════════════════════════\n');

  // Mostrar detalle
  for (const [key, data] of Object.entries(consolidated.precios)) {
    const fuentes = Object.entries(data.fuentes || {})
      .map(([s, d]) => `${s}: $${d.price.toLocaleString('es-CL')}`)
      .join(' | ');
    console.log(`  ${data.ingrediente} → ${data.formatoApp}: ${fuentes}${data.stale ? ' (stale)' : ''}`);
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

run().catch(console.error);
