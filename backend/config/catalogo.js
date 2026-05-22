/**
 * Catálogo canónico de productos para scraping.
 *
 * Cada entrada define:
 *  - ingrediente:       nombre en minúsculas usado como clave en la app
 *  - marca:             marca objetivo
 *  - variedad:          línea del producto (Regular, Sureña, etc.)
 *  - formatoApp:        nombre exacto del FormatoCompra en Flutter
 *  - gramaje:           peso neto en gramos
 *  - rendimiento:       cuántos completos rinde este formato
 *  - keywords:          palabras que DEBEN aparecer en el texto scrapeado
 *  - excludeKeywords:   palabras que DESCARTAN un resultado
 *  - searchQuery:       término de búsqueda para el buscador del supermercado
 */

export const CATALOGO = [
  // ── Pan de completo ──────────────────────────────────────────
  {
    ingrediente: 'pan de completo',
    marca: 'Castaño',
    variedad: 'Hot Dog',
    formatoApp: 'Bolsa 5 uds',
    gramaje: 300,
    rendimiento: 5,
    keywords: ['castaño', 'hot dog', '5'],
    excludeKeywords: ['xl', 'brioche', 'integral'],
    searchQuery: 'pan completo castaño',
  },
  {
    ingrediente: 'pan de completo',
    marca: 'Castaño',
    variedad: 'Hot Dog',
    formatoApp: 'Bolsa 8 uds',
    gramaje: 480,
    rendimiento: 8,
    keywords: ['castaño', 'hot dog', '8'],
    excludeKeywords: ['xl', 'brioche', 'integral'],
    searchQuery: 'pan completo castaño',
  },
  {
    ingrediente: 'pan de completo',
    marca: 'Ideal',
    variedad: 'XL',
    formatoApp: 'Bolsa 6 uds XL',
    gramaje: 528,
    rendimiento: 6,
    keywords: ['ideal', 'xl', '6'],
    excludeKeywords: ['brioche', 'artesano'],
    searchQuery: 'pan completo ideal',
  },
  {
    ingrediente: 'pan de completo',
    marca: 'Ideal',
    variedad: 'Hot Dog',
    formatoApp: 'Bolsa 8 uds',
    gramaje: 480,
    rendimiento: 8,
    keywords: ['ideal', '8'],
    excludeKeywords: ['brioche', 'artesano', 'xl'],
    searchQuery: 'pan completo ideal',
  },

  // ── Vienesa ──────────────────────────────────────────────────
  {
    ingrediente: 'vienesa',
    marca: 'PF',
    variedad: 'Sureña',
    formatoApp: 'Paquete 250g (5 uds)',
    gramaje: 250,
    rendimiento: 5,
    keywords: ['pf', 'sureña', '250'],
    excludeKeywords: ['pavo', 'pollo'],
    searchQuery: 'vienesa PF sureña',
  },
  {
    ingrediente: 'vienesa',
    marca: 'PF',
    variedad: 'Tradicional',
    formatoApp: 'Paquete 1Kg (20 uds)',
    gramaje: 1000,
    rendimiento: 20,
    keywords: ['pf', '1', 'kg'],
    excludeKeywords: ['pavo', 'pollo'],
    searchQuery: 'vienesa PF 1kg',
  },
  {
    ingrediente: 'vienesa',
    marca: 'Llanquihue',
    variedad: 'Tradicional',
    formatoApp: 'Paquete 500g (10 uds)',
    gramaje: 500,
    rendimiento: 10,
    keywords: ['llanquihue', '500'],
    excludeKeywords: ['pavo', 'pollo'],
    searchQuery: 'vienesa llanquihue 500',
  },

  // ── Palta ────────────────────────────────────────────────────
  {
    ingrediente: 'palta',
    marca: 'Hass',
    variedad: 'Malla',
    formatoApp: 'Malla 1 Kg',
    gramaje: 1000,
    rendimiento: 15,
    keywords: ['palta', 'hass', 'malla'],
    excludeKeywords: [],
    searchQuery: 'palta hass malla',
  },

  // ── Tomate ───────────────────────────────────────────────────
  {
    ingrediente: 'tomate',
    marca: 'Genérico',
    variedad: 'Larga Vida',
    formatoApp: 'Malla 1 Kg',
    gramaje: 1000,
    rendimiento: 15,
    keywords: ['tomate', 'larga vida'],
    excludeKeywords: ['cherry', 'deshidratado', 'salsa'],
    searchQuery: 'tomate larga vida',
  },

  // ── Mayonesa ─────────────────────────────────────────────────
  {
    ingrediente: 'mayonesa',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 372g',
    gramaje: 372,
    rendimiento: 22,
    keywords: ['hellmann', 'regular', '372'],
    excludeKeywords: ['light', 'supreme', 'churrasco', 'ajo', 'tocino'],
    searchQuery: 'mayonesa hellmanns regular',
  },
  {
    ingrediente: 'mayonesa',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 630g',
    gramaje: 630,
    rendimiento: 38,
    keywords: ['hellmann', 'regular', '630'],
    excludeKeywords: ['light', 'supreme', 'churrasco', 'ajo', 'tocino'],
    searchQuery: 'mayonesa hellmanns regular',
  },
  {
    ingrediente: 'mayonesa',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 1 Kg',
    gramaje: 1000,
    rendimiento: 60,
    keywords: ['hellmann', 'regular', '1'],
    excludeKeywords: ['light', 'supreme', 'churrasco', 'ajo', 'tocino'],
    searchQuery: 'mayonesa hellmanns regular 1kg',
  },

  // ── Mostaza ──────────────────────────────────────────────────
  {
    ingrediente: 'mostaza',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 250g',
    gramaje: 250,
    rendimiento: 16,
    keywords: ['hellmann', 'mostaza', '250'],
    excludeKeywords: ['miel', 'dijon'],
    searchQuery: 'mostaza hellmanns',
  },
  {
    ingrediente: 'mostaza',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 470g',
    gramaje: 470,
    rendimiento: 30,
    keywords: ['hellmann', 'mostaza', '470'],
    excludeKeywords: ['miel', 'dijon'],
    searchQuery: 'mostaza hellmanns',
  },

  // ── Ketchup ──────────────────────────────────────────────────
  {
    ingrediente: 'ketchup',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 250g',
    gramaje: 250,
    rendimiento: 16,
    keywords: ['hellmann', 'ketchup', '250'],
    excludeKeywords: ['light'],
    searchQuery: 'ketchup hellmanns',
  },
  {
    ingrediente: 'ketchup',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 500g',
    gramaje: 500,
    rendimiento: 33,
    keywords: ['hellmann', 'ketchup', '500'],
    excludeKeywords: ['light'],
    searchQuery: 'ketchup hellmanns',
  },
  {
    ingrediente: 'ketchup',
    marca: 'Hellmanns',
    variedad: 'Regular',
    formatoApp: 'Doypack 900g',
    gramaje: 900,
    rendimiento: 60,
    keywords: ['hellmann', 'ketchup', '900'],
    excludeKeywords: ['light'],
    searchQuery: 'ketchup hellmanns 900',
  },

  // ── Chucrut ──────────────────────────────────────────────────
  {
    ingrediente: 'chucrut',
    marca: 'Traverso',
    variedad: 'Normal',
    formatoApp: 'Doypack 200g',
    gramaje: 200,
    rendimiento: 13,
    keywords: ['traverso', 'chucrut', '200'],
    excludeKeywords: [],
    searchQuery: 'chucrut traverso',
  },
  {
    ingrediente: 'chucrut',
    marca: 'Traverso',
    variedad: 'Normal',
    formatoApp: 'Doypack 500g',
    gramaje: 500,
    rendimiento: 33,
    keywords: ['traverso', 'chucrut', '500'],
    excludeKeywords: [],
    searchQuery: 'chucrut traverso',
  },

  // ── Salsa americana ──────────────────────────────────────────
  {
    ingrediente: 'salsa americana',
    marca: 'Traverso',
    variedad: 'Normal',
    formatoApp: 'Doypack 200g',
    gramaje: 200,
    rendimiento: 13,
    keywords: ['traverso', 'americana', '200'],
    excludeKeywords: [],
    searchQuery: 'salsa americana traverso',
  },
  {
    ingrediente: 'salsa americana',
    marca: 'Traverso',
    variedad: 'Normal',
    formatoApp: 'Doypack 500g',
    gramaje: 500,
    rendimiento: 33,
    keywords: ['traverso', 'americana', '500'],
    excludeKeywords: [],
    searchQuery: 'salsa americana traverso',
  },

  // ── Ají ──────────────────────────────────────────────────────
  {
    ingrediente: 'ají',
    marca: 'Traverso',
    variedad: 'Chileno',
    formatoApp: 'Squeeze 350g',
    gramaje: 350,
    rendimiento: 23,
    keywords: ['traverso', 'ají', '350'],
    excludeKeywords: ['pebre'],
    searchQuery: 'aji chileno traverso',
  },
  {
    ingrediente: 'ají',
    marca: 'JB',
    variedad: 'Chileno',
    formatoApp: 'Botella 240g',
    gramaje: 240,
    rendimiento: 16,
    keywords: ['jb', 'ají', '240'],
    excludeKeywords: ['pebre'],
    searchQuery: 'aji chileno JB',
  },

  // ── Queso laminado ───────────────────────────────────────────
  {
    ingrediente: 'queso laminado',
    marca: 'Colun',
    variedad: 'Gauda',
    formatoApp: 'Laminado 150g',
    gramaje: 150,
    rendimiento: 8,
    keywords: ['colun', 'laminado', '150'],
    excludeKeywords: ['light', 'sin lactosa'],
    searchQuery: 'queso laminado colun',
  },
  {
    ingrediente: 'queso laminado',
    marca: 'Colun',
    variedad: 'Gauda',
    formatoApp: 'Laminado 250g',
    gramaje: 250,
    rendimiento: 14,
    keywords: ['colun', 'laminado', '250'],
    excludeKeywords: ['light', 'sin lactosa'],
    searchQuery: 'queso laminado colun',
  },
  {
    ingrediente: 'queso laminado',
    marca: 'Colun',
    variedad: 'Gauda',
    formatoApp: 'Laminado 500g',
    gramaje: 500,
    rendimiento: 28,
    keywords: ['colun', 'laminado', '500'],
    excludeKeywords: ['light', 'sin lactosa'],
    searchQuery: 'queso laminado colun',
  },
];

/**
 * Agrupa el catálogo por ingrediente para consultas rápidas.
 * @returns {Map<string, Array>}
 */
export function catalogoPorIngrediente() {
  const map = new Map();
  for (const item of CATALOGO) {
    if (!map.has(item.ingrediente)) map.set(item.ingrediente, []);
    map.get(item.ingrediente).push(item);
  }
  return map;
}

/**
 * Devuelve las queries únicas de búsqueda para un supermercado.
 * @returns {string[]}
 */
export function queriesUnicas() {
  return [...new Set(CATALOGO.map((p) => p.searchQuery))];
}
