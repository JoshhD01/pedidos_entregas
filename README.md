# Pedidos y entregas (G61-3)

App Flutter para Android con tres roles: el cliente arma y sigue sus pedidos, el operador los confirma, prepara y asigna, y el repartidor los entrega con el código de recepción del cliente.

Versión: `1.0.0+1` (se actualiza al generar el APK final).

## Integrantes

_Pendiente (Josué)._

## Roles

_Pendiente (Josué)._

## Ejecución

_Pendiente (Josué): `flutter pub get`, `build_runner`, `google-services.json`, `flutter run`._

## Firebase

_Pendiente (Josué): proyecto, Authentication, Firestore, reglas y Crashlytics._

## Endpoint HTTP

_Pendiente (Josué)._

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

_Pendiente (Josué)._

## Firma del APK

_Pendiente (Josué)._

## Límites conocidos

- El reenvío automático solo ocurre con la app abierta y una sesión de cliente; no hay tarea en segundo plano.
- Mis pedidos muestra solo los pedidos creados en este teléfono: si se reinstala la app, los anteriores no se importan desde Firestore.
- Un pedido rechazado por el servidor no se puede corregir y reenviar; se descarta y se crea otro.
- Cancelar requiere conexión: un pedido que aún no llegó al servidor no se puede cancelar sin red.
- Si una transacción no responde a tiempo, puede haberse completado en el servidor. La interfaz pide revisar el estado antes de reintentar, y reintentar es seguro porque la transacción relee el estado.
