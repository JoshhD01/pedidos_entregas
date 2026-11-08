# Matriz de QA

Versión probada: _pendiente (APK release final)_. Los casos se ejecutan en debug después de publicar las reglas de Firestore, y el recorrido final sobre el APK release.

Estado: `Pendiente`, `Pasa` o `Falla`. Un caso que falla se anota en el registro de defectos.

## Casos

| ID | Precondición | Cuenta / rol | Pasos | Resultado esperado | Resultado obtenido | Estado | Versión | Evidencia |
|---|---|---|---|---|---|---|---|---|
| QA-01 | Cliente con sesión iniciada y catálogo cargado | cliente | 1. Crear un pedido. 2. Cerrar la app por completo. 3. Volver a abrirla e ir a Mis pedidos | El pedido sigue ahí con sus líneas, total, dirección y código de recepción | | Pendiente | | |
| QA-02 | Cliente con sesión y catálogo cargado | cliente | 1. Activar modo avión. 2. Crear un pedido. 3. Abrir Mis pedidos | El pedido aparece como "Pendiente de envío", con "Total estimado" y el código de recepción | | Pendiente | | |
| QA-03 | QA-02 terminado (pedido pendiente) | cliente, operador | 1. Desactivar modo avión con la app abierta. 2. Tocar Sincronizar varias veces. 3. Revisar Firestore y la bandeja del operador | El pedido pasa a "Enviado" sin tocar nada; en Firestore hay un solo documento con ese id; el operador lo ve una sola vez | | Pendiente | | |
| QA-04 | Cliente con sesión | cliente | 1. Agregar 6 productos diferentes. 2. Intentar subir una cantidad por encima de 10. 3. Crear sin dirección | El sexto producto no entra ("máximo 5 productos diferentes"); el selector no pasa de 10; sin dirección aparece "Indica la dirección de entrega." y no se crea ningún pedido | | Pendiente | | |
| QA-05 | Producto con stock 1 en Firestore; dos pedidos `CREADO` de ese producto con cantidad 1 | operador (dos dispositivos o dos sesiones) | 1. Confirmar el primer pedido. 2. Confirmar el segundo | El primero queda `CONFIRMADO` con stock 0; el segundo muestra "No hay stock suficiente de … (disponible: 0)" y sigue `CREADO`; el stock nunca queda negativo | | Pendiente | | |
| QA-06 | Pedido `CREADO` sincronizado | cliente, operador | 1. El operador confirma el pedido. 2. El cliente, sin refrescar, toca "Cancelar pedido" | El cliente ve "El pedido ya cambió de estado." y el pedido queda `CONFIRMADO`; en Mis pedidos aparece "Confirmado" | | Pendiente | | |
| QA-07 | Pedido `CONFIRMADO` | operador, cliente | 1. Empezar preparación. 2. Marcar listo. 3. Asignar un repartidor | El pedido pasa por `PREPARANDO` y `LISTO` con repartidor; el cliente ve cada estado en Mis pedidos sin tocar nada | | Pendiente | | |

_Casos de Josué: login correcto e incorrecto, restricción por rol, datos de otra cuenta y cambio de usuario, HTTP exitoso, vacío y con fallo, código de entrega, Crashlytics y recorrido sobre el APK._

## Registro de defectos

| ID | Caso | Descripción | Corrección o limitación | Estado |
|---|---|---|---|---|
| | | | | |
