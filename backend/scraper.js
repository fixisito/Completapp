import puppeteer from 'puppeteer-extra';
import StealthPlugin from 'puppeteer-extra-plugin-stealth';

// Usar el plugin stealth para evitar que Cloudflare bloquee nuestro bot
puppeteer.use(StealthPlugin());

async function runScraper() {
  console.log('Iniciando el robot scraper (Puppeteer)...');
  
  // Abrimos el navegador en modo "headless" (invisible)
  // Cambia headless a false si quieres ver cómo se mueve el robot
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  // Vamos a la página que buscó el usuario en sesiones anteriores
  const url = 'https://super.lider.cl/search?q=mayonesa+hellmans';
  console.log(`Navegando a: ${url}`);
  
  try {
    // Lider es una app pesada (React/Next), esperamos a que la red esté inactiva (networkidle2)
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
    
    console.log('Página cargada. Buscando los productos...');
    
    // Esperamos a que los contenedores de los productos aparezcan en el DOM
    // Buscamos algo genérico que identifique la caja del producto. 
    // Lider suele usar clases autogeneradas, pero generalmente hay etiquetas <a> o divs con data-testids.
    // Una forma infalible es esperar a que se renderice el símbolo de peso "$".
    await page.waitForFunction(() => document.body.innerText.includes('$'), { timeout: 10000 });

    // Extraemos los datos ejecutando código Javascript dentro del navegador virtual
    const productos = await page.evaluate(() => {
      const results = [];
      // Intentamos capturar los elementos de la lista (Lider suele usar divs contenedores)
      // La estrategia general: buscar elementos que contengan texto con el precio
      const cards = Array.from(document.querySelectorAll('div, li')).filter(el => {
        return el.innerText && el.innerText.includes('Hellmann') && el.innerText.includes('$');
      });

      // Lider estructura sus cards con el nombre de la marca, descripción y precio.
      // Ya que las clases cambian, tomaremos el approach más agresivo: extraeremos el texto de los primeros 5 contenedores grandes.
      const uniqueCards = [...new Set(cards.map(c => c.innerText))];
      
      for (const text of uniqueCards) {
        if (text.length < 200 && text.includes('Hellmann')) {
            results.push(text.replace(/\n/g, ' | ')); // Limpiamos saltos de línea
        }
      }
      return results.slice(0, 5); // Traemos solo 5 resultados para analizar
    });

    console.log('¡Éxito! Estos son los datos extraídos en crudo:');
    productos.forEach((p, i) => console.log(`${i + 1}. ${p}`));

  } catch (error) {
    console.error('Hubo un error raspando la página:', error.message);
  } finally {
    console.log('Cerrando el robot...');
    await browser.close();
  }
}

runScraper();
