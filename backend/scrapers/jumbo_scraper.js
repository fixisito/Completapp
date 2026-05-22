import { BaseScraper } from './base_scraper.js';

/**
 * Scraper para jumbo.cl
 * Jumbo también usa una SPA React/Next.js similar a Lider (misma empresa Cencosud).
 */
export class JumboScraper extends BaseScraper {
  constructor() {
    super('Jumbo', 'https://www.jumbo.cl');
  }

  buildSearchUrl(query) {
    return `${this.baseUrl}/search?q=${encodeURIComponent(query)}`;
  }

  async extractRawCards(_searchTerm) {
    return await this.page.evaluate(() => {
      const results = [];
      const allDivs = Array.from(document.querySelectorAll('div, li, article'));
      const seen = new Set();

      for (const el of allDivs) {
        const text = el.innerText;
        if (!text || !text.includes('$')) continue;

        if (text.length < 30 || text.length > 300) continue;

        const lines = text.split('\n').filter((l) => l.trim().length > 0);
        if (lines.length < 2) continue;

        const key = text.substring(0, 80);
        if (seen.has(key)) continue;
        seen.add(key);

        results.push(text.replace(/\n/g, ' | '));
      }

      return results.slice(0, 15);
    });
  }
}
