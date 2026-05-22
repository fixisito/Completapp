import puppeteer from 'puppeteer-extra';
import StealthPlugin from 'puppeteer-extra-plugin-stealth';

puppeteer.use(StealthPlugin());

/**
 * Clase base para scrapers de supermercados chilenos.
 * Maneja el ciclo de vida de Puppeteer y provee métodos comunes.
 */
export class BaseScraper {
  constructor(name, baseUrl) {
    this.name = name;
    this.baseUrl = baseUrl;
    this.browser = null;
    this.page = null;
  }

  async init() {
    console.log(`[${this.name}] Iniciando navegador...`);
    this.browser = await puppeteer.launch({
      headless: true,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
      ],
    });
    this.page = await this.browser.newPage();

    // Configurar un user-agent realista
    await this.page.setUserAgent(
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
    );

    // Viewport estándar
    await this.page.setViewport({ width: 1366, height: 768 });
  }

  /**
   * Navega a una URL y espera a que la red esté inactiva.
   * @param {string} url
   * @param {number} timeout - Timeout en ms (default: 30s)
   */
  async navigateTo(url, timeout = 30000) {
    console.log(`[${this.name}] Navegando a: ${url}`);
    await this.page.goto(url, {
      waitUntil: 'networkidle2',
      timeout,
    });
  }

  /**
   * Espera a que aparezcan productos en la página.
   * @param {number} timeout
   */
  async waitForProducts(timeout = 15000) {
    await this.page.waitForFunction(
      () => document.body.innerText.includes('$'),
      { timeout }
    );
  }

  /**
   * Extrae textos crudos de las cards de productos de la página.
   * Debe ser implementado por cada scraper hijo.
   * @param {string} searchTerm - Término de búsqueda para filtrar resultados
   * @returns {Promise<string[]>}
   */
  async extractRawCards(searchTerm) {
    throw new Error(`[${this.name}] extractRawCards() no implementado`);
  }

  /**
   * Busca un producto en el supermercado y extrae las cards.
   * @param {string} query - Término de búsqueda
   * @returns {Promise<string[]>} - Textos crudos de las cards
   */
  async search(query) {
    const url = this.buildSearchUrl(query);
    try {
      await this.navigateTo(url);
      await this.waitForProducts();
      const cards = await this.extractRawCards(query);
      console.log(`[${this.name}] "${query}" → ${cards.length} resultados`);
      return cards;
    } catch (error) {
      console.error(`[${this.name}] Error buscando "${query}": ${error.message}`);
      return [];
    }
  }

  /**
   * Construye la URL de búsqueda. Implementar en cada hijo.
   * @param {string} query
   * @returns {string}
   */
  buildSearchUrl(query) {
    throw new Error(`[${this.name}] buildSearchUrl() no implementado`);
  }

  /**
   * Cierra el navegador de forma segura.
   */
  async close() {
    if (this.browser) {
      console.log(`[${this.name}] Cerrando navegador...`);
      await this.browser.close();
      this.browser = null;
      this.page = null;
    }
  }
}
