# Backend de Precios (Roadmap)

Este backend se mantiene dentro del repo como base para una API de precios de ingredientes.

## Estrategia definida

- Modelo: **híbrido**.
  - Fuente primaria: scraping por proveedor.
  - Respaldo: carga manual en base de datos.
- Plataforma inicial: **Firebase Cloud Functions (HTTP)**.
- Actualización: **diaria** por scheduler y **manual** por endpoint protegido.
- Fallback en consumo: si falla el scraping, devolver el **último precio válido** (`stale: true`).
- La app solo aplica precios remotos cuando el resultado incluye `formatName`, para evitar pisar un empaque distinto.

## Alcance actual

- `scraper.js` sigue siendo un prototipo local para pruebas rápidas.
- La implementación productiva vive en `functions/` para integración con Firebase.

## Próximos pasos

1. Definir catálogo canónico de productos consultables por la app.
2. Agregar proveedores por supermercado con normalización de resultados.
3. Añadir auth para endpoint de refresco manual.
4. Integrar consumo remoto en Flutter con fallback local.
