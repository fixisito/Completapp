import { BaseScraper } from './base_scraper.js';

/**
 * Scraper para super.lider.cl
 * Lider usa una SPA React/Next.js con renderizado dinámico.
 */
export class LiderScraper extends BaseScraper {
  constructor() {
    super('Lider', 'https://super.lider.cl');
  }

  buildSearchUrl(query) {
    return `${this.baseUrl}/search?q=${encodeURIComponent(query)}`;
  }

  async extractRawCards(_searchTerm) {
    return await this.page.evaluate(() => {
      const results = [];
      // Estrategia: buscar divs que contengan el signo $ y texto de producto.
      // Lider usa clases autogeneradas, así que buscamos por contenido.
      const allDivs = Array.from(document.querySelectorAll('div, li, article'));
      const seen = new Set();

      for (const el of allDivs) {
        const text = el.innerText;
        if (!text || !text.includes('$')) continue;

        // Filtrar cards de tamaño razonable (no toda la página, no un span)
        if (text.length < 30 || text.length > 300) continue;

        // Verificar que tenga estructura de producto (nombre + precio)
        const lines = text.split('\n').filter((l) => l.trim().length > 0);
        if (lines.length < 2) continue;

        // Evitar duplicados
        const key = text.substring(0, 80);
        if (seen.has(key)) continue;
        seen.add(key);

        results.push(text.replace(/\n/g, ' | '));
      }

      return results.slice(0, 15); // Limitar para no saturar
    });
  }
}
