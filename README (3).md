# 📘 Documentación de masCapital

Este documento describe los componentes principales relacionados con los **productos financieros** y **servicios comunes** de la aplicación **masCapital**. Se incluyen pantallas, proveedores, widgets, modelos y servicios externos organizados por módulo funcional.

---

## 🔐 RefreshTokenExternal

Clase encargada de renovar el token de acceso (`access_token`) utilizando un `refresh_token` previamente almacenado. Esto permite mantener sesiones activas sin necesidad de volver a autenticarse manualmente.

### 📁 Archivo
`lib/refresh_token_external.dart`

### 🚀 Método principal

```dart
Future<String> refreshToken({required String stripChat});
```

### 🔄 Flujo resumido

1. **Encriptación**:
   - Se encripta el `refresh_token` mediante `EncryptService.encryptJson`.
   - La clase `EncryptService` implementa AES en modo ECB sobre cadenas JSON.
   - Clave utilizada: `UsersPrefs.usersPrefs` (se asume previamente configurada).

2. **Solicitud HTTP**:
   - Se realiza un `POST` a `${BaseUrl.baseUrl}auth/refresh`.
   - Se incluyen headers y un JSON con el token encriptado.

3. **Desencriptación**:
   - La respuesta contiene un `encrypted_message` que se desencripta usando `EncryptService.decryptJson`.

4. **Control de errores**:
   - En caso de fallo (status >= 400), se redirige con `Navigations.navigationToScreenOffAll()` hacia `SyncScreen`, inyectado con `SyncInjection.injection()`.
   - Se muestra una alerta visual usando `toastError()`.

### 🧱 Archivos relacionados

- **`EncryptService`** (`lib/encrypt_service.dart`):
  - Utiliza AES para encriptar y desencriptar datos sensibles.
- **`MainProvider`** (`lib/main_provider.dart`):
  - Provider que almacena valores como `stripChat`, `dialCode`, geolocalización, etc.
- **`BaseUrl`** (`lib/base_url.dart`):
  - Contiene URL base del backend: `https://time2hire.me/api/v1/`.
- **`Navigations`** (`lib/navigations.dart`):
  - Clase para navegar entre pantallas. Utiliza `Get.context`.
- **`SyncInjection`** (`lib/sync_injection.dart`):
  - Crea el `SyncScreen` con su correspondiente `SyncProvider`.
- **`toastError`** (`lib/toastification.dart`):
  - Muestra toasts personalizados para errores.

### 📦 Ejemplo de uso

```dart
final tokenService = RefreshTokenExternal();
String newToken = await tokenService.refreshToken(stripChat: 'your_refresh_token_here');
```

---

## 💱 ExchangesExternal

Clase que obtiene las tasas de cambio actualizadas entre USD y PEN del backend, utilizando un token JWT renovado.

### 📁 Archivo
`lib/exchanges_external.dart`

### 🚀 Método principal

```dart
Future<ExchangesRateModel?> getExchangesRates();
```

### 🔄 Flujo resumido

1. **Autenticación**:
   - Se obtiene el `access_token` mediante `RefreshTokenExternal`.

2. **Solicitud GET**:
   - Se realiza a `${BaseUrl.baseUrl}exchange-rates/`.

3. **Respuesta**:
   - Se desencripta la propiedad `encrypted_message` y se convierte en modelo `ExchangesRateModel`.

### 📦 Modelo: ExchangesRateModel

```dart
class ExchangesRateModel {
  final double usdToPen;
  final double penToUsd;

  ExchangesRateModel({
    required this.usdToPen,
    required this.penToUsd,
  });

  factory ExchangesRateModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

Representa las tasas de cambio entre USD y PEN.

### 📦 Ejemplo de uso

```dart
final exchangeService = ExchangesExternal();
final rates = await exchangeService.getExchangesRates();

if (rates != null) {
  print('USD to PEN: \${rates.usdToPen}');
  print('PEN to USD: \${rates.penToUsd}');
}
```

---



---

## 💼 GanaFijoScreen

Pantalla principal del flujo de producto "GanaFijo Más", un simulador de inversión de ahorro con intereses mensuales.

### 📁 Archivo
`lib/gana_fijo_screen.dart`

### 🎯 Funcionalidad

`GanaFijoScreen` es un `StatelessWidget` que usa `PageView` vertical para gestionar tres pasos:

1. **Condiciones del producto** (`GfConditionsWidget`)
2. **Simulación de rentabilidad** (`GfSimulationWidget`)
3. **Presentación e introducción del producto** (`GfPresentationWidget`)

### 📦 Controlador de estado

- **`GanaFijoProvider`** (archivo: `gana_fijo_provider.dart`)
  - Controla la lógica de negocio y el estado para todo el flujo.
  - Maneja:
    - Valores seleccionados de inversión (`deposit`, `percent`)
    - Simulaciones (`simulateGanafijoMas`)
    - Pago del producto (`payProduct`)
    - Visualización de contratos PDF (`downloadSavingContractPdf`, etc.)
    - Navegación (`setCurrentPage`)
    - Flags visuales (`isLoading`, `isButtonEnabled`, etc.)

---

## 🧩 Componentes visuales del flujo

### 📘 `GfConditionsWidget`
- Muestra beneficios y condiciones del producto.
- Permite seleccionar cuenta de origen, aceptar contrato/términos.
- Dispara `payProduct()` si se cumplen los requisitos.

### 📘 `GfSimulationWidget`
- Muestra en tabla los resultados simulados: periodo, rentabilidad y rescate.
- Permite reiniciar la simulación o continuar a contratar el producto.

### 📘 `GfPresentationWidget`
- Introduce el producto con métricas visuales y permite elegir monto y porcentaje.
- Incluye un botón para simular que lleva al siguiente paso (`simulateGanafijoMas`).

---

## 🎨 CapitalColors

Utilizado para mantener consistencia visual en todos los componentes.

```dart
static const blue = Color(0xFF00416B);
static const lightBlue = Color(0xFF6EC1E4);
static const whiteBlue = Color(0xFFF0F8FF);
static const grey = Color(0xFF909090);
```

Usado en fondos, textos, bordes, botones y gradientes (ej: `linearGradient`).

---

## 🧪 Ejemplo de navegación entre pasos

```dart
// Simular inversión y avanzar al paso de simulación
ganaFijoProvider.simulateGanafijoMas();
ganaFijoProvider.setCurrentPage(1);

// Volver al paso inicial
ganaFijoProvider.setCurrentPage(2);
```

---



---

## 🌐 GanaFijoExternal

Clase encargada de gestionar todas las **operaciones remotas** relacionadas con el módulo GanaFijo Más. Incluye solicitudes HTTP, cifrado de datos y manejo de contratos PDF.

### 📁 Archivo
`lib/gana_fijo_external.dart`

---

### 🔧 Funcionalidades principales

| Método | Descripción |
|--------|-------------|
| `openGFProduct()` | Crea un nuevo producto GanaFijo usando `GfInvestmentModel` |
| `payGfmProduct()` | Realiza un pago desde cuenta de ahorros usando `PayGfModel` |
| `payWithCard()` | Realiza un pago con tarjeta vía `CcAvenueGfmModel` |
| `getAccountInfo()` | Obtiene cuentas disponibles del usuario |
| `fetchSavingContract()` | Descarga contrato de ahorro (PDF) |
| `fetchTermsContract()` | Descarga contrato de términos (PDF) |

---

### 📦 Modelos involucrados

- `GfInvestmentModel`: Representa la inversión con `goalAmount`, `trea`, `currency`, `typeOfInterest`, `duration`
- `PayGfModel`: Contiene los datos para ejecutar pagos desde una cuenta
- `CcAvenueGfmModel`: Estructura usada para iniciar un pago con tarjeta
- `Accounts` / `Account`: Detalle de cuentas bancarias del usuario
- `CurrencyEnum`: Define PEN y USD como monedas
- `GFMInterestTypeEnum`: Define `simple` y `compound` como tipos de interés
- `ProfileModel`: Datos de usuario usados en pagos con tarjeta

---

### 📲 Flujos de navegación y pantallas relacionadas

| Situación | Navegación |
|----------|-------------|
| Error de sesión o autenticación | `LoginInjection.injection()` |
| Error al abrir producto o balance insuficiente | `HomeInjection.injection()` |
| Visualización de contratos PDF | `PdfViewerInjection.injection(File)` |
| Producto creado correctamente | `ConsultProductInjection.injection(productId)` |
| Pago procesado con éxito | `PaymentOverviewInjection.injection(...)` |
| Volver al lobby GanaFijo | `LobbyGanaFijoInjection.injection()` |

---

### 🔐 Seguridad

- Todos los datos enviados al backend se encriptan usando `EncryptService.encryptJson(...)`
- Las respuestas encriptadas se desencriptan con `EncryptService.decryptJson(...)`
- Uso de tokens JWT renovables por medio de `RefreshTokenExternal`

---

### 📁 Ejemplo para abrir producto

```dart
final GfInvestmentModel model = GfInvestmentModel(
  goalAmount: 5000,
  trea: 0.12,
  currency: CurrencyEnum.PEN,
  typeOfInterest: GFMInterestTypeEnum.simple,
  duration: 12,
);

final response = await GanaFijoExternal().openGFProduct(gfInvestmentModel: model);
```

---

_(Documento en construcción. Puedes continuar con más bloques cuando quieras)_

---

## 🗂️ LobbyGanaFijoScreen

Pantalla que lista todos los productos GanaFijo del usuario. Sirve como punto de entrada al módulo y permite tanto consultar detalles como crear nuevos productos.

### 📁 Archivo
`lib/lobby_gana_fijo_screen.dart`

---

### 🎯 Funcionalidad principal

- Usa `LobbyGanaFijoProvider` para obtener productos desde `LobbyGanaFijoExternal`.
- Renderiza la lista usando un `ListView.builder`.
- Cada producto se presenta mediante `GanaFijoProductCard`.
- Permite:
  - Crear nuevos productos con un FAB (`GanaFijoInjection`)
  - Consultar productos existentes (`ConsultProductInjection`)

---

### 🔄 Flujo de carga

```dart
await lobbyGanaFijoProvider.getEarnProduct();
```

Este método se activa también al hacer "pull-to-refresh".

---

### 📦 Provider: LobbyGanaFijoProvider

```dart
final earnProduct = ValueNotifier<List<LobbyGanaFijoModel>?>(null);
```

- Obtiene productos desde `LobbyGanaFijoExternal`.
- Usa `currencyFormat` y `currencyFormat2` para mostrar montos.
- Determina colores con `getBackgroundColor()`.

---

### 🌐 Servicios: LobbyGanaFijoExternal

```dart
Future<List<LobbyGanaFijoModel>> getEarnProduct()
```

- Llama a `${BaseUrl.baseUrl}gfm-product/all/by-user/`
- Encripta y desencripta datos usando `EncryptService`
- Autenticación mediante token JWT (renovable con `RefreshTokenExternal`)

---

### 📦 Modelo: LobbyGanaFijoModel

```dart
class LobbyGanaFijoModel {
  final String id;
  final DateTime createdAt;
  final double savingsGoalAmount;
  final GFMAccountStatusEnum status;
  ...
}
```

Incluye formatos personalizados como:
- `formattedCreatedAt`
- `formattedNextScheduledPayment`
- `formattedStatus` (según `GFMAccountStatusEnum`)

---

### 🚦 Navegaciones clave

| Acción | Navegación |
|--------|------------|
| FAB para nuevo producto | `GanaFijoInjection.injection()` |
| Consultar producto existente | `ConsultProductInjection.injection(productId)` |
| Pantalla inicial del módulo | `LobbyGanaFijoInjection.injection()` |

---

### 🧪 Ejemplo de uso del FAB

```dart
FloatingActionButton(
  onPressed: () {
    Navigations.navigationToScreen(screen: GanaFijoInjection.injection());
  },
)
```

---

_(Documento en construcción. Puedes continuar enviando más partes del sistema si deseas seguir extendiéndolo)_

---

## 🌟 TuFuturoMasScreen

Pantalla principal del producto **Tu Futuro Más**, que permite simular, visualizar beneficios y abrir un producto de ahorro con capitalización compuesta.

### 📁 Archivo
`lib/tu_futuro_mas_screen.dart`

---

### 📊 Flujo de navegación

Utiliza un `PageView` vertical con 3 pasos principales:

1. **Presentación del producto** – `TfmPresentationWidget`
2. **Simulación de rentabilidad** – `TfmSimulationWidget`
3. **Condiciones de contratación** – `TfmConditionsWidget`

La navegación entre ellos se maneja desde el `TuFuturoMasProvider`.

---

### 🔧 Proveedor: TuFuturoMasProvider

Controla:

- Cuentas, selección, y validación de fondos (`Accounts`)
- Simulador con cálculos financieros personalizados
- Envío de pagos: desde cuenta o pasarela (`CCAvenue`)
- Manejo de contratos (`downloadSavingContractPdf`, `downloadTermsContractPdf`)
- Estados visuales (`isLoading`, `contractCheck`, `termsCheck`, etc.)

También contiene lógica para:

- `simulateTuFuturoMas()`: realiza cálculos anuales (inversión, rentabilidad, rescate)
- `payProduct()`: realiza validaciones y apertura del producto

---

### 📦 Modelos utilizados

- `TfmInvestmentModel`: Para abrir el producto
- `PayTfmModel`: Para enviar pagos desde cuentas
- `CcAvenueTfmModel`: Para pagos desde tarjeta
- `Accounts` y `Account`: Cuentas del usuario

---

### 🌐 Servicios remotos: TuFuturoMasExternal

| Método | Función |
|--------|---------|
| `openTfmProduct()` | Apertura del producto |
| `payTfmProduct()` | Pago desde cuenta |
| `getAccountInfo()` | Trae las cuentas activas del usuario |
| `fetchSavingContract()` | Descarga contrato de ahorro |
| `fetchTermsContract()` | Descarga contrato de términos y condiciones |

Autenticación con tokens encriptados a través de `EncryptService` y `RefreshTokenExternal`.

---

### 🧩 Componentes visuales

#### `TfmPresentationWidget`
- Presenta el producto y permite seleccionar monto y período para simular.

#### `TfmSimulationWidget`
- Muestra una tabla con rentabilidad estimada por año.

#### `TfmConditionsWidget`
- Permite seleccionar la cuenta y aceptar los contratos. Luego activa la apertura del producto.

---

### 🔀 Navegaciones relevantes

| Acción | Navegación |
|--------|------------|
| Pago exitoso | `PaymentOverviewInjection.injection(...)` |
| Producto abierto correctamente | `TfmConsultProductInjection.injection(...)` |
| Volver a inicio o lobby | `LobbyTfmInjection.injection()` |
| Error o sesión expirada | `LoginInjection.injection()` / `HomeInjection.injection()` |
| Ver contrato PDF | `PdfViewerInjection.injection(file)` |

---

### 🧪 Ejemplo: Simulación

```dart
tuFuturoMasProvider.depositValue.value = '100';
tuFuturoMasProvider.selectedPeriod.value = '10';
tuFuturoMasProvider.simulateTuFuturoMas();
```

---



---

## 📄 TfmConsultProductScreen

Pantalla de **detalle del producto Tu Futuro Más**, donde el usuario puede consultar información completa sobre su inversión, hacer pagos adicionales, y revisar su historial de abonos.

### 📁 Archivo
`lib/tfm_consult_product_screen.dart`

---

### 🔍 ¿Qué muestra?

- **Monto total invertido**
- **Rentabilidad proyectada (capitalización total)**
- **ID del producto** con opción de copia
- **Tasa de interés (TREA)**
- **Monto mensual**
- **Fechas de pagos**: próximo, último y de rescate
- **Botón para abonar más** (`PayTfmInjection`)
- **Historial de pagos recientes** (hasta 5)

---

### 📦 Estado manejado con `TfmConsultProductProvider`

- `productDetails`: información completa del producto (balance, TREA, fechas)
- `progressBar`: para mostrar avance de capitalización
- `historiesDetails`: lista de abonos pasados (`PayHistoryWidget`)
- Métodos clave:
  - `fetchProductDetails()`
  - `getHistoryPayments()`
  - `capitalizacionTotal(...)`: simula acumulado futuro

---

### 🔀 Navegaciones importantes

| Acción | Navegación |
|--------|------------|
| Abrir pantalla de abono | `PayTfmInjection.injection(...)` |
| Ver historial completo de pagos | `TfmHistoryInjection.injection(...)` |

Estas navegaciones se refrescan automáticamente con `onPop`.

---

### 🧪 Ejemplo de pago

```dart
Navigations.navigationToScreen(
  screen: PayTfmInjection.injection(
    productID: consultProductProvider.productIdDetails,
    goalAmount: consultProductProvider.productDetails.value?.goalAmount.toString() ?? 'Error',
  ),
  onPop: () async {
    await consultProductProvider.fetchProductDetails();
    await consultProductProvider.getHistoryPayments();
  },
);
```

---

_(Documento en construcción. Puedes continuar enviando más partes del sistema si deseas seguir extendiéndolo)_

---

## 📄 TfmConsultProductScreen (detallado)

Pantalla que permite consultar un producto existente de **Tu Futuro Más**, mostrando el progreso, el plan de pagos, y opciones de abono adicional.

### 📁 Archivo
`lib/tfm_consult_product_screen.dart`

---

### 🧠 Lógica de estado: `TfmConsultProductProvider`

- Administra los datos del producto y su historial.
- Propiedades:
  - `productDetails`: datos principales del producto (`TfmConsultProductModel`)
  - `historiesDetails`: lista de pagos realizados (`TfmPaymentHistoryModel`)
  - `progressBar`, `progress`: progreso acumulado
- Funciones:
  - `fetchProductDetails()`: obtiene los datos actuales del producto.
  - `getHistoryPayments()`: recupera la lista de pagos realizados.
  - `capitalizacionTotal(...)`: simula la rentabilidad acumulada con interés compuesto.

```dart
double capitalizacionTotal(double monthlyDeposit, int months) {
  return (monthlyDeposit * (pow(1 + 0.0079741404, months) - 1) / 0.0079741404) *
         (1 + 0.0079741404);
}
```

---

### 🌐 Servicios externos: `TfmConsultProductExternal`

- `getProductDetail(...)`: llama a `/tfm-product/{productId}` y desencripta la respuesta
- `getHistoryPayments(...)`: llama a `/tfm-product/payments-history/{productId}` y parsea lista de pagos

---

### 💡 Inyección del Provider: `TfmConsultProductInjection`

```dart
static Widget injection({required String productId}) {
  return ListenableProvider(
    create: (_) => TfmConsultProductProvider(productId)
      ..fetchProductDetails()
      ..getHistoryPayments(),
    child: const TfmConsultProductScreen(),
  );
}
```

Permite inyectar la pantalla con un `Provider` inicializado con un `productId`.

---

### 📋 Historial visual: `PayHistoryWidget`

Widget utilizado para mostrar de forma resumida los pagos más recientes:

- Fecha (`date`)
- Hora (`time`)
- Monto pagado (`value`)
- ID de pago (`paymentID`)

Decorado con iconos e información visual jerarquizada.

---

### 🔀 Navegaciones dentro de la pantalla

| Acción | Destino |
|--------|---------|
| Abrir pantalla de abono | `PayTfmInjection.injection(...)` |
| Ver historial completo | `TfmHistoryInjection.injection(...)` |
| Falla en producto inválido | `HomeInjection.injection()` |

---



---

## 🧾 TfmHistoryScreen

Pantalla que muestra el historial completo de pagos realizados en un producto **Tu Futuro Más**. Proporciona una visión detallada, incluyendo la fecha, hora, monto y código de transacción.

### 📁 Archivo
`lib/tfm_history_screen.dart`

---

### 🧠 Provider: `TfmHistoryProvider`

- Inicializa con el `productIdDetails`.
- Administra:
  - `historiesDetails`: lista de pagos (`TfmHistoryModel`)
- Método principal:
  - `getHistoryPayments()`: consulta todos los pagos usando `TfmHistoryExternal`.

---

### 🌐 Servicios externos: `TfmHistoryExternal`

- Endpoint: `GET /tfm-product/payments-history/{productId}`
- Seguridad: Token JWT renovado con `RefreshTokenExternal`
- Datos desencriptados con `EncryptService`
- Resultado: lista de `TfmHistoryModel`

---

### 📦 Modelo: `TfmHistoryModel`

Campos que describen cada transacción:
- `transactionId`: ID de transacción
- `amount`: Monto abonado
- `transactionDate`: Fecha
- `transactionTime`: Hora
- `transactionDateTime`: Marca temporal completa
- `id`: ID interno

---

### 🎨 Widget: `TfmHistoryCard`

Diseño visual para cada ítem del historial. Muestra:
- Icono y tipo de transacción (`HugeIcons`)
- Descripción (`pay_date`)
- Fecha y hora
- Monto (`Monto: S/`)
- Destino (`Destino: transactionID`)

---

### 🔄 Flujo visual

```dart
ListView.builder(
  itemCount: historiesCards.length,
  itemBuilder: (context, index) {
    final histories = historiesCards[index];
    return TfmHistoryCard(
      transactionType: ez.tr('pays_tufuturomas'),
      transactionIcon: HugeIcons.strokeRoundedPayment01,
      description: ez.tr('pay_date'),
      dateTime: histories.transactionDate,
      transactionID: histories.transactionId,
      transactionValue: histories.amount.toString(),
    );
  },
);
```

---



---

## 💳 PayTfmScreen

Pantalla para **abonar a un producto Tu Futuro Más**. Permite seleccionar cuenta, ingresar monto, y realizar pagos con validaciones visuales y mensajes dinámicos.

### 📁 Archivo
`lib/pay_tfm_screen.dart`

---

### 📦 Provider: `PayTfmProvider`

Controla todo el estado, validaciones, flujo de pago y carga de cuentas:

- Campos como:
  - `amount`, `originAccount`, `originAccounts`, `goalAmount`
  - `isLoading`, `transactionId`, `overviewAmount`, etc.
- Métodos:
  - `payTfmProduct()`: lógica principal de abono (desde cuenta o tarjeta)
  - `initiatePayment()`: realiza pago con CCAvenue si se usa tarjeta
  - `getAccountInfo()`: carga cuentas asociadas al usuario
  - `getProfile()`: obtiene datos del usuario para rellenar info de tarjeta

---

### 🌐 Servicios externos: `PayTfmExternal`

- `payTfmProduct(...)`: realiza POST a `/tfm-product/pay-from-accounts`
- `getAccountInfo()`: obtiene lista de cuentas del usuario
- Encriptación con `EncryptService`, autenticación con token de `RefreshTokenExternal`

---

### 📦 Modelo: `PayTfmModel`

Contiene:
- `productGfmId`, `amount`, `description`, `sourceAccountType`

Se usa como payload para realizar abonos desde cuenta de ahorros.

---

### ✍️ Input formatter: `InputFormatter`

Personaliza el ingreso del campo `amount`, permitiendo solo números y formateando automáticamente con comas para mayor claridad visual.

```dart
1234567 → 1,234,567
```

---

### 🆘 Botón de ayuda: `HelpButton`

Botón interactivo al final de la pantalla que lanza un chat de WhatsApp con soporte técnico:

```dart
await EasyLauncher.sendToWhatsApp(
  phone: '+51940009410',
  message: ez.tr('hello_mascapital'),
);
```

---

### 🧪 Validación y acción principal

```dart
if (payTfmProvider.key.value.currentState!.validate()) {
  await payTfmProvider.payTfmProduct();
} else {
  toastError(...);
}
```

---

### 🔀 Navegaciones post pago

| Caso | Navegación |
|------|------------|
| Pago con tarjeta exitoso | `TfmConsultProductInjection.injection(...)` |
| Pago desde cuenta exitoso | `PaymentOverviewInjection.injection(...)`, con redirección opcional al `LobbyTfmInjection` |
| Sesión expirada | `LoginInjection.injection()` |

---



---

## 🗂️ LobbyTfmScreen

Pantalla principal del módulo **Tu Futuro Más**, donde el usuario puede visualizar todos sus productos de ahorro abiertos, ver detalles o crear uno nuevo.

### 📁 Archivo
`lib/lobby_tfm_screen.dart`

---

### 🧠 Provider: `LobbyTfmProvider`

- Maneja la lista de productos:
  - `earnProduct`: lista de productos (`LobbyTuFuturoModel`)
- Métodos clave:
  - `getEarnProduct()`: consulta los productos desde el backend
  - `getBackgroundColor(...)`: retorna color rojo o verde según la fecha del próximo pago
- Formateadores:
  - `currencyFormat` y `currencyFormat2` usados para mostrar montos

---

### 🌐 Modelo: `LobbyTuFuturoModel`

Incluye:
- `savingsGoalAmount`
- `nextScheduledPaymentDate`
- `expirationDate`
- `status` → convertido a texto mediante `formattedStatus`

Permite visualizar el estado y calendario de cada producto.

---

### 🧩 Widget visual: `TfmProductCard`

Renderiza cada producto con:
- Estado de la cuenta (`Activo`, `Bloqueado`, etc.)
- Fecha de próximo abono y de vencimiento
- Monto mensual ahorrado
- Botón visual de "Ver" con ícono

Los colores son dinámicos según la cercanía del próximo pago.

---

### 🔄 Navegación y acciones

| Acción | Navegación |
|--------|------------|
| FAB (+) | `TuFuturoMasInjection.injection()` (crear nuevo producto) |
| Tocar tarjeta | `TfmConsultProductInjection.injection(productId)` |

Incluye `onPop` para refrescar lista tras cerrar el detalle.

---

### 🧪 Ejemplo de formato visual

```dart
TfmProductCard(
  accountState: product.formattedStatus,
  nextPay: product.nextScheduledPaymentDate,
  investment: lobbyTuFuturoProvider.currencyFormat2.format(product.savingsGoalAmount),
  expirationDate: product.expirationDate,
  backgroundColor: lobbyTuFuturoProvider.getBackgroundColor(product.nextScheduledPayment),
)
```

---



---
📝 Fin del documento de servicios y productos de masCapital.