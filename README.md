# CompletApp 🌭

App Android para calcular completos chilenos y criar tu propio Completito virtual. Hecha en Flutter desde cero.

---

## ¿Qué es esto?

CompletApp nació de una idea simple: necesitaba una app que me ayudara a calcular cuántos completos hacer para una reunión, y de paso quería algo entretenido. El resultado fue esto — una calculadora de completos con precios reales en CLP y un Tamagotchi en forma de 🌭.

---

## Funcionalidades

**Calculadora**

- Agrega las personas que van a comer y cuántos completos quiere cada una
- Activa o desactiva ingredientes según lo que vas a usar
- Los precios de cada ingrediente son editables y se guardan en el dispositivo
- El resumen muestra el costo por completo y el total en pesos chilenos

**Mi Completito**

- Tamagotchi en forma de completo que necesita que lo alimentes
- Tiene barras de hambre, felicidad y experiencia que cambian con el tiempo real
- Sube de nivel y desbloquea accesorios (galera, lentes, corona, y más)
- El estado se guarda aunque cierres la app

**Mini Juego — Atrapa el Completo**

- Caen completos desde arriba y los tienes que tocar antes de que lleguen al fondo
- La velocidad aumenta según tu puntaje
- Tienes 3 vidas
- Cada completo atrapado da experiencia al pet
- El mejor puntaje se guarda localmente

---

## Stack

- Flutter 3 + Dart
- shared_preferences (persistencia local)
- Android Studio

---

## Instalación

```bash
git clone https://github.com/fixisito/Completapp.git
cd Completapp
flutter pub get
flutter run
```

Para generar el APK:

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

---

## Estado del proyecto

En desarrollo activo. Primera versión funcional instalable como APK.

Backend de precios en evolución:

- Se agregó base de API en `functions/` para Firebase Cloud Functions.
- Estrategia híbrida: scraping + fallback a caché + override manual.
- Refresco diario por scheduler y endpoint manual de refresco.

## Modo local (sin costos)

Puedes desarrollar toda la API de precios en local, sin Firebase ni plan de pago.

1) Levantar API local:

```bash
cd backend
npm install
npm run start:local-api
```

2) Ejecutar Flutter apuntando al backend local:

- Android Emulator:

```bash
flutter run --dart-define=PRICES_API_URL=http://10.0.2.2:8787
```

- Desktop/Web:

```bash
flutter run --dart-define=PRICES_API_URL=http://localhost:8787
```

Endpoints disponibles en local:
- `GET /health`
- `GET /getPrices?items=pan de completo,vienesa` (retorna `formatName` para aplicar el precio al empaque correcto)
- `POST /refreshPrices` (permite overrides manuales en body JSON)

**Lo que viene:**

- Fuentes e ícono personalizado
- Más mini juegos
- Modo evento en la calculadora (lista de compras exportable)
- Notificaciones de hambre del pet
- Publicación en Play Store

---

## Autor

A. Leiva — estudiante de Ingeniería en Informática.
