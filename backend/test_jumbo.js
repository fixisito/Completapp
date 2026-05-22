import { JumboScraper } from './scrapers/jumbo_scraper.js';
import { writeFileSync } from 'node:fs';

async function test() {
  const scraper = new JumboScraper();
  try {
    await scraper.init();
    await scraper.navigateTo(scraper.buildSearchUrl('pan completo castaño'));
    
    console.log('Esperando 10 segundos para carga inicial...');
    await new Promise(r => setTimeout(r, 10000));
    
    const html = await scraper.page.content();
    writeFileSync('jumbo_dump.html', html);
    
    const cards = await scraper.extractRawCards('pan completo castaño');
    console.log(`Cards encontradas: ${cards.length}`);
    console.log(cards);
    
  } catch (error) {
    console.error(error);
  } finally {
    await scraper.close();
  }
}

test();
