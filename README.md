# BanexCoin - Panel de Trading (Prueba Técnica)

**BanexCoin** es una aplicación de trading de criptomonedas desarrollada en Flutter como parte de una prueba técnica. La aplicación se conecta a la API pública de Binance a través de WebSockets y REST para mostrar información del mercado en tiempo real, simulando un panel de trading profesional.

Este proyecto no solo cumple con todos los requisitos funcionales, sino que también implementa una solución de backend robusta utilizando **Firebase Cloud Functions** para actuar como un servidor proxy, resolviendo el desafío común de **CORS (Cross-Origin Resource Sharing)** en aplicaciones web desplegadas.

### 🚀 Demo en Vivo

Puedes probar la aplicación desplegada aquí: **[https://banexcoin-6a811.web.app](https://banexcoin-6a811.web.app)**

_(GIF de la aplicación en funcionamiento)_

## ✨ Funcionalidades Implementadas

A continuación se detalla cómo se cumplió con cada uno de los requisitos de la prueba técnica:

### 1. Dashboard Principal

El panel principal ofrece una vista general y en tiempo real del mercado.

- **Lista de Pares de Trading:** Se muestra una lista configurable de pares (`BTC/USDT`, `ETH/USDT`, etc.) en el widget `TradingPairsWidget`.
- **Datos en Tiempo Real:** Se utilizan **WebSockets** a través del `MarketDataBloc` para recibir actualizaciones de precios, cambio porcentual y volumen. Los cambios se reflejan instantáneamente en la UI con indicadores de color (verde/rojo) para las subidas y bajadas.
- **Navegación Rápida:** La navegación entre el Dashboard y la Vista Detallada se gestiona con `go_router`, permitiendo una transición fluida y manteniendo el estado de la aplicación.

### 2. Vista Detallada de Par

Al seleccionar un par, el usuario accede a una pantalla dedicada con análisis en profundidad.

- **Precio Destacado con Animación:** El widget `PriceDisplayWidget` muestra el precio actual con una animación de "pulso" y un cambio de color sutil cada vez que el precio se actualiza, proporcionando un feedback visual inmediato.
- **Estadísticas del Día:** El `PairStatisticsWidget` presenta las métricas clave de las últimas 24h: precio de apertura, máximo, mínimo y el volumen.
- **Gráfico de Precios:** Se implementó un gráfico interactivo (`TradingChartTwoWidget`) usando el paquete `fl_chart`. Permite cambiar de temporalidad (15m, 1h, 4h, etc.) y tipo de gráfico (línea, área).
- **Indicador de Tendencia Visual:** Se muestra un indicador claro (ej. `TrendingUp` o `TrendingDown`) basado en el cambio de precio de las últimas 24 horas.

### 3. Libro de Órdenes (Order Book)

Una visualización en tiempo real de la profundidad del mercado.

- **Órdenes en Tiempo Real:** La página `OrderBookPage` se suscribe al stream de `depth` del WebSocket de Binance para mostrar las órdenes de compra (bids) y venta (asks).
- **Visualización en Tabla:** Los datos se presentan en una tabla clara que incluye precio, cantidad y el total acumulado para cada nivel.
- **Colores Diferenciados y Spread:** Las órdenes de compra se muestran en verde y las de venta en rojo. Se calcula y muestra el **spread** (diferencia entre el mejor bid y el mejor ask) en tiempo real.
- **Actualización Fluida:** Se implementó un `StreamBuilder` gestionado por el BLoC para actualizar la UI sin parpadeos, asegurando una experiencia de usuario fluida.

### 4. Calculadora de Trading

Una herramienta práctica para simular operaciones.

- **Cálculo de Operaciones:** El `TradingCalculatorPage` permite al usuario introducir una cantidad (en moneda base o cotizada) y seleccionar si desea comprar o vender.
- **Cálculo Automático y Fees:** La calculadora determina automáticamente cuánto se recibirá, incluyendo una simulación de las **fees de trading (0.1%)**.
- **Actualización en Tiempo Real:** El campo de precio se puede actualizar con el precio de mercado actual con un solo clic, permitiendo cálculos precisos basados en la información más reciente.

## 🏛️ Arquitectura

El proyecto está construido siguiendo los principios de la **Arquitectura Limpia**, separando las responsabilidades en capas de **Presentación, Dominio y Datos**.

### Arquitectura de Conexión y Solución a CORS

Un desafío clave en las aplicaciones web que consumen APIs de terceros es la **Política del Mismo Origen (Same-Origin Policy)**. Para resolver el error de **CORS** resultante, se implementó un **servidor proxy inverso** utilizando **Firebase Cloud Functions**.

**Flujo de la Solución:**

1.  La aplicación Flutter envía todas las solicitudes HTTP a nuestra propia Cloud Function.
2.  La Cloud Function (proxy) reenvía la solicitud a la API de Binance desde el lado del servidor.
3.  El proxy recibe la respuesta de Binance y la devuelve a la app Flutter con las cabeceras CORS correctas (`Access-Control-Allow-Origin: *`).

Este enfoque profesional garantiza que la aplicación funcione correctamente en cualquier navegador sin comprometer la seguridad.

```mermaid
graph TD
    subgraph Navegador del Usuario
        A[App Flutter Web]
    end

    subgraph Google Cloud
        B[Firebase Cloud Function (Proxy)]
    end

    subgraph Internet
        C[API de Binance]
    end

    A -- 1. Petición API (Permitida) --> B
    B -- 2. Reenvío de la petición (Servidor a Servidor) --> C
    C -- 3. Respuesta de Binance --> B
    B -- 4. Respuesta con cabeceras CORS --> A

    style A fill:#BDEBFF
    style B fill:#FFC3A0
    style C fill:#C3FFC3
```

> **Nota:** Las conexiones **WebSocket** no sufren de las mismas restricciones CORS, por lo que se conectan directamente a Binance para una latencia mínima.

## 🛠️ Stack Tecnológico

- **Framework:** [Flutter](https://flutter.dev/)
- **Lenguaje:** [Dart](https://dart.dev/)
- **Backend (Proxy):** [Firebase Cloud Functions](https://firebase.google.com/docs/functions) con [Node.js](https://nodejs.org/) y [Axios](https://axios-http.com/).
- **Hosting:** [Firebase Hosting](https://firebase.google.com/docs/hosting)
- **Arquitectura:** Clean Architecture
- **Manejo de Estado:** [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Inyección de Dependencias:** [get_it](https://pub.dev/packages/get_it)
- **Networking (REST):** [dio](https://pub.dev/packages/dio)
- **Networking (WebSocket):** [web_socket_channel](https://pub.dev/packages/web_socket_channel)
- **Routing:** [go_router](https://pub.dev/packages/go_router)
- **Gráficos:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Diseño Responsivo:** [responsive_framework](https://pub.dev/packages/responsive_framework)

## 🚀 Cómo Empezar

### Prerrequisitos

- Tener [Flutter](https://flutter.dev/docs/get-started/install) instalado.
- Tener [Node.js](https://nodejs.org/en) instalado (para gestionar las Firebase Functions).
- Tener la [Firebase CLI](https://firebase.google.com/docs/cli) instalada: `npm install -g firebase-tools`.

### Instalación y Ejecución

1.  **Clona el repositorio:**

    ```sh
    git clone https://github.com/tu-usuario/banexcoin-test.git
    cd banexcoin-test
    ```

2.  **Instala las dependencias de Flutter:**

    ```sh
    flutter pub get
    ```

3.  **Instala las dependencias de la Cloud Function:**

    ```sh
    cd functions
    npm install
    cd ..
    ```

4.  **Ejecuta la aplicación en modo local:**
    ```sh
    flutter run -d chrome
    ```
    > Gracias al servidor proxy, ya no es necesaria la bandera `--disable-web-security`. La aplicación funcionará en local tal y como lo hará en producción.
