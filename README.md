# Pedidos y entregas (G61-3)

App Flutter para Android con tres roles: el cliente arma y sigue sus pedidos, el operador los confirma, prepara y asigna, y el repartidor los entrega con el código de recepción del cliente.

Versión: `1.0.0+2`. APK: `G61-3_pedidos_entregas_1.0.0+2.apk`.

## Integrantes

Tomás Córdoba Urquijo y Josué Gómez Granda. Desarrollo Móvil, Universidad de Medellín, 2026-2. Caso G61-3.

## Roles

| Rol | Qué hace |
|---|---|
| Cliente | Consulta el catálogo, arma un pedido, lo sigue en Mis pedidos y lo cancela mientras esté `CREADO` |
| Operador | Confirma o rechaza pedidos, registra la preparación y asigna repartidor |
| Repartidor | Ve los pedidos que le asignaron, inicia el recorrido y registra la entrega con el código del cliente |

Quien se registra en la app queda como `cliente`. Operador y repartidor se asignan a mano en Firebase Console, cambiando `rol` en `perfiles/{uid}`. El repartidor además necesita el documento `repartidores/{uid}` con `pedidoEnCamino: null`.

## Ejecución

Requiere Flutter 3.44.9 y un emulador o dispositivo Android con internet.

```sh
flutter pub get
flutter run -d <id-del-dispositivo>
```

- `android/app/google-services.json` y `lib/firebase_options.dart` ya están en el repositorio: son configuración de cliente, no secretos.
- `lib/local/app_database.g.dart` también está incluido. `build_runner` solo hace falta al cambiar tablas de Drift:

  ```sh
  dart run build_runner build --delete-conflicting-outputs
  ```

- Validación: `flutter analyze` y `flutter test`.

## Firebase

Proyecto `pedidosentregas`:

- **Authentication** con correo y contraseña.
- **Cloud Firestore** con las colecciones del modelo de datos.
- **Reglas** en `firestore.rules`, por rol, dueño y campos: cada transición de estado solo acepta los campos de su acción, nadie cambia su rol ni el `clienteUid`, no hay lectura ni escritura global y no se borra nada. Se publican pegando el archivo en Firebase Console → Firestore → Reglas.
- **Crashlytics** para errores (ver Datos y Crashlytics).

## Endpoint HTTP

`GET https://dummyjson.com/c/59f3-0f90-41f6-952e` devuelve el catálogo: 8 productos con `id`, `nombre`, `categoria`, `precio` y `descripcion` (copia en `datos/productos.json`).

- Tiempo límite de 10 segundos.
- 404, error del servidor, sin conexión, tiempo agotado o formato inválido muestran un mensaje y el botón Reintentar.
- La última respuesta se guarda en Drift para ver el catálogo sin conexión.
- El precio del catálogo es solo referencia: el precio y el stock que valen son los de `productos/{id}` en Firestore (`datos/productos_firestore.json`).

## Modelo de datos

Cada producto tiene el mismo `id` (`p001`) en HTTP, Firestore y Drift.

### Firestore

| Ruta | Campos | Uso |
|---|---|---|
| `perfiles/{uid}` | `nombre`, `email`, `rol` | Rol de cada cuenta. Solo se asigna en Firebase Console |
| `productos/{id}` | `nombre`, `precio`, `stock` | Valores vigentes. Solo la confirmación del operador descuenta stock |
| `pedidos/{id}` | `clienteUid`, `lineas`, `total`, `direccion`, `estado`, `repartidorUid`, `createdAt`, `updatedAt` | El pedido. El `id` es un UUID generado en el teléfono |
| `pedidos/{id}/privado/codigo` | `codigo` | Código de recepción: solo lo ve el cliente dueño |
| `pedidos/{id}/entrega/codigo` | `codigo` | Código que digita el repartidor; la regla lo compara con `privado/codigo` |
| `repartidores/{uid}` | `pedidoEnCamino` | Habilita al repartidor y limita a un pedido en camino |

Cada línea guarda `productoId`, `nombreProducto`, `cantidad` y `precioUnitario`.

### Drift (local)

| Tabla | Para qué |
|---|---|
| `pedidos` | Copia local de los pedidos del cliente, con `estadoSync` (`PENDIENTE`, `SINCRONIZADO`, `RECHAZADO`), `lastError` y el código de recepción |
| `lineas_pedido` | Líneas de cada pedido. Se borran con su pedido |
| `productos_cache` | Última copia del catálogo HTTP, para comprar sin conexión |

El total no se guarda en Drift: siempre se calcula desde las líneas.

## Reglas del negocio

- Un pedido tiene de 1 a 5 productos diferentes, cantidades de 1 a 10 y dirección obligatoria.
- El precio del catálogo HTTP es solo referencia. Al confirmar, el operador lee en una transacción el precio y el stock vigentes de todas las líneas, recalcula el total y descuenta el stock. Si falta stock, no se confirma nada.
- Estados: `CREADO → CONFIRMADO → PREPARANDO → LISTO → EN_CAMINO → ENTREGADO`. Desde `CREADO` también puede pasar a `RECHAZADO` (operador) o `CANCELADO` (cliente). `ENTREGADO`, `RECHAZADO` y `CANCELADO` son terminales.
- Cada cambio de estado se hace en una transacción que vuelve a leer el estado actual: si otro rol se adelantó, la acción se rechaza con un mensaje. Por ejemplo, si el operador confirma mientras el cliente cancela, gana el operador.
- El cliente solo cancela en `CREADO` y necesita conexión para hacerlo.
- El operador asigna un repartidor solo a pedidos `LISTO`, y puede cambiarlo mientras el pedido siga `LISTO`. Sin repartidor, el pedido no sale de `LISTO`.
- Un repartidor tiene como máximo un pedido `EN_CAMINO`, y solo lo entrega con el código correcto.

## Operación local-first

1. **Crear:** el pedido se guarda primero en Drift, con UUID, código de recepción y `estadoSync = PENDIENTE`. El cliente lo ve en Mis pedidos aunque no haya red.
2. **Enviar:** se intenta enviar al crearlo, al abrir Mis pedidos, con el botón Sincronizar y cada vez que Firestore responde desde el servidor (al volver la conexión). El envío crea el documento en una transacción solo si no existe, así que reintentar nunca duplica ni sobrescribe lo que hizo otro rol.
3. **Resultado:**
   - Si el servidor confirma, la fila queda `SINCRONIZADO`, siempre que no haya cambiado durante el envío.
   - Un fallo temporal o sin conexión deja la fila `PENDIENTE` con el error, y se reintenta.
   - Un rechazo del servidor la deja `RECHAZADO`. No se reenvía: el cliente la descarta.
4. **Seguimiento:** mientras el cliente tiene sesión, la app escucha sus pedidos en Firestore y copia a Drift el estado, el repartidor y las líneas con el precio vigente. Mis pedidos siempre lee de Drift, así que sin red muestra el último estado conocido.
5. **Cuentas:** toda consulta local se filtra por el `uid`. Al cambiar de cuenta no se muestran ni se envían pedidos de otra.

El filtro de Mis pedidos (todos, activos, terminados) se guarda con SharedPreferences.

## Datos y Crashlytics

**Datos:** todos son ficticios. Los productos de Firestore se cargan desde `datos/productos_firestore.json`; `p001` tiene stock 1 para probar la falta de stock. Las cuentas de prueba (una por rol) se entregan solo por el medio privado del docente y no están en este repositorio.

**Datos de prueba en Firestore** (estado al entregar `1.0.0+2`). Hay pedidos en los ocho estados, para recorrer el flujo sin preparar nada:

| Estado | Dirección del pedido | Qué se puede probar |
|---|---|---|
| `CREADO` | QA05 Pedido 2 (Hamburguesa clásica) | El operador lo confirma: consume el único stock de `p001`. Un segundo pedido de `p001` muestra la falta de stock |
| `CONFIRMADO` | QA02 Calle 3 | Empezar preparación |
| `PREPARANDO` | QA01 Calle 2 | Marcar listo |
| `LISTO` sin repartidor | QA11 Calle 1 | Asignar repartidor |
| `EN_CAMINO` | QA05 Pedido 1 | El repartidor lo entrega con el código; mientras tanto no puede iniciar otro recorrido |
| `ENTREGADO` | Calle Release 1, entre otros | Estado final |
| `CANCELADO` | Calle 76 | Cancelado por el cliente |
| `RECHAZADO` | a | Rechazado por el operador |

Para volver a empezar: crear un pedido con la cuenta de cliente y llevarlo por los tres roles; para probar la falta de stock, poner `stock: 1` en `productos/p001` desde Firebase Console. El operador y el repartidor ven estos pedidos desde cualquier teléfono. En Mis pedidos, el cliente solo ve los que se crearon en ese teléfono (ver Límites conocidos).

**Crashlytics:**

- `main.dart` envía a Crashlytics los errores de Flutter (`FlutterError.onError`) y los que no se capturan (`PlatformDispatcher.onError`).
- Los errores inesperados que la app sí maneja (por ejemplo, un documento con formato inválido o un fallo raro al sincronizar) se registran como no fatales con `registrarError()`, en `lib/core/registro_errores.dart`.
- Los errores de negocio y de red no se envían: se muestran al usuario con un mensaje.
- En debug, la barra del repartidor tiene un botón de error de prueba. No aparece en release. Los reportes se suben al volver a abrir la app y se ven en Firebase Console → Crashlytics, filtrando por eventos no fatales.

## Firma del APK

```sh
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`; para entregarlo se renombra con el código del caso y la versión (`G61-3_pedidos_entregas_1.0.0+2.apk`). Se firma con la clave de depuración de Android (`signingConfig = debug` en `android/app/build.gradle.kts`), así que se instala en cualquier dispositivo sin configurar claves.

## Límites conocidos

- El reenvío automático solo ocurre con la app abierta y una sesión de cliente; no hay tarea en segundo plano.
- Mis pedidos muestra solo los pedidos creados en este teléfono: si se reinstala la app, los anteriores no se importan desde Firestore.
- Un pedido rechazado por el servidor no se puede corregir y reenviar; se descarta y se crea otro.
- Cancelar requiere conexión: un pedido que aún no llegó al servidor no se puede cancelar sin red.
- Si una transacción no responde a tiempo, puede haberse completado en el servidor. La interfaz pide revisar el estado antes de reintentar, y reintentar es seguro porque la transacción relee el estado.
