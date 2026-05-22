/**
 * Normalización y matching de textos scrapeados contra el catálogo.
 */

/**
 * Extrae el precio en CLP de un texto crudo.
 * Soporta formatos como "$4.290", "$ 4290", "$4,290".
 * @param {string} text
 * @returns {number|null}
 */
export function extractPrice(text) {
  // Busca patrones como $4.290 o $4290 (el primer match suele ser el precio principal)
  const match = text.match(/\$\s*([\d.,]+)/);
  if (!match) return null;
  // Quitar separadores de miles (puntos y comas) para obtener el número
  const cleaned = match[1].replace(/[.,]/g, '');
  const price = parseInt(cleaned, 10);
  return Number.isFinite(price) && price > 0 ? price : null;
}

/**
 * Extrae el gramaje en gramos de un texto crudo.
 * Soporta "372 g", "1 kg", "1Kg", "500g", etc.
 * @param {string} text
 * @returns {number|null}
 */
export function extractGramaje(text) {
  // Primero intentar kg
  const kgMatch = text.match(/(\d+(?:[.,]\d+)?)\s*kg/i);
  if (kgMatch) {
    const kg = parseFloat(kgMatch[1].replace(',', '.'));
    return Math.round(kg * 1000);
  }
  // Luego intentar gramos
  const gMatch = text.match(/(\d+)\s*g(?:r|ramos)?/i);
  if (gMatch) {
    return parseInt(gMatch[1], 10);
  }
  return null;
}

/**
 * Extrae la cantidad de unidades de un texto.
 * Soporta "5 un", "8 unidades", "x 10", "6 uds", etc.
 * @param {string} text
 * @returns {number|null}
 */
export function extractUnidades(text) {
  const match = text.match(/(\d+)\s*(?:un(?:idad(?:es)?)?|uds)/i);
  if (match) return parseInt(match[1], 10);
  // También "x 10" o "x10"
  const xMatch = text.match(/x\s*(\d+)/i);
  if (xMatch) return parseInt(xMatch[1], 10);
  return null;
}

/**
 * Normaliza un texto para matching (lowercase, sin tildes, sin caracteres especiales).
 * @param {string} text
 * @returns {string}
 */
export function normalize(text) {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // quitar tildes
    .replace(/[^a-z0-9\s]/g, ' ')   // reemplazar símbolos por espacio
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Intenta matchear un texto crudo contra las entradas del catálogo.
 * Retorna la entrada del catálogo que mejor coincide, o null.
 * 
 * @param {string} rawText - Texto crudo extraído del scraper
 * @param {Array} catalogoEntries - Entradas del catálogo para este ingrediente
 * @returns {{ entry: object, price: number } | null}
 */
export function matchProducto(rawText, catalogoEntries) {
  const normalizedText = normalize(rawText);
  const price = extractPrice(rawText);

  if (!price) return null;

  let bestMatch = null;
  let bestScore = 0;

  for (const entry of catalogoEntries) {
    // Verificar que ninguna excludeKeyword esté presente
    const excluded = entry.excludeKeywords.some((kw) =>
      normalizedText.includes(normalize(kw))
    );
    if (excluded) continue;

    // Contar cuántas keywords hacen match
    let score = 0;
    for (const kw of entry.keywords) {
      if (normalizedText.includes(normalize(kw))) {
        score++;
      }
    }

    // Verificar gramaje si está disponible en el texto
    const gramaje = extractGramaje(rawText);
    if (gramaje && gramaje === entry.gramaje) {
      score += 2; // Bonus fuerte por gramaje exacto
    }

    // Verificar unidades
    const unidades = extractUnidades(rawText);
    if (unidades && unidades === entry.rendimiento) {
      score += 2; // Bonus por unidades exactas
    }

    // Necesitamos al menos 2 keywords para considerar un match válido
    const keywordMatches = entry.keywords.filter((kw) =>
      normalizedText.includes(normalize(kw))
    ).length;

    if (keywordMatches >= 2 && score > bestScore) {
      bestScore = score;
      bestMatch = { entry, price };
    }
  }

  return bestMatch;
}
