# Firebase Functions - API de Precios v1

## Endpoints

- `GET /getPrices?items=pan de completo,vienesa`
  - Retorna precios por ítem usando cache + scraping cuando corresponde.
  - Query opcional: `refresh=1` para forzar actualización.
- `POST /refreshPrices`
  - Fuerza refresco de catálogo.
  - Header opcional de seguridad: `x-refresh-token`.
  - Body opcional:
    ```json
    { "items": ["pan de completo", "mayonesa"] }
    ```

## Colecciones Firestore

- `priceCache/{itemKey}`
  - Último resultado utilizable por la app (`fresh` o `stale`).
- `manualPrices/{itemKey}`
  - Override manual para estrategia híbrida.
- `config/pricingCatalog`
  - Documento con `items: string[]` para scheduler.

## Scheduler

- `dailyPriceRefresh` corre diariamente a las `06:00` (America/Santiago).

## Variables de entorno

- `REFRESH_TOKEN` (opcional): protege endpoint manual de refresco.
