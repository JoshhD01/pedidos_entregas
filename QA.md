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
| QA-08 | Cuentas de los tres roles; app sin sesión | cliente, operador, repartidor | 1. Iniciar sesión con cada cuenta. 2. Cerrar la app por completo y volver a abrirla. 3. Cerrar sesión | Cada rol entra a su inicio: cliente a "Catálogo", operador a "Bandeja del operador", repartidor a "Mis entregas". Al reabrir sigue la sesión; al cerrarla vuelve al inicio de sesión | | Pendiente | | |
| QA-09 | App sin sesión | — | 1. Correo existente con contraseña equivocada. 2. Correo sin formato válido. 3. Activar modo avión e intentar entrar | 1: "Correo o contraseña incorrectos." 2: mensaje de correo inválido. 3: "Sin conexión. Revisa tu internet e inténtalo de nuevo." En ningún caso entra ni aparece texto técnico | | Pendiente | | |
| QA-10 | App sin sesión | cliente nuevo | 1. Registrar una cuenta en "Crear una cuenta". 2. Revisar `perfiles/{uid}` en Firebase Console. 3. Recorrer la app | El perfil queda con rol `cliente`. Solo ve catálogo, carrito y Mis pedidos; no hay bandeja de operador ni de repartidor. El rol solo cambia desde Console | | Pendiente | | |
| QA-11 | Dos cuentas de cliente (A y B); A tiene un pedido sincronizado | cliente A, cliente B | 1. Con A, activar modo avión y crear un pedido. 2. Cerrar sesión. 3. Quitar modo avión y entrar con B. 4. Abrir Mis pedidos y tocar Sincronizar. 5. Volver a entrar con A | B no ve ningún pedido de A, y el pendiente de A no se envía con la cuenta de B. Al volver a A, su pedido sigue ahí y se envía | | Pendiente | | |
| QA-12 | Cliente con sesión y conexión | cliente | 1. Abrir el catálogo. 2. Tocar un producto | Aparece el indicador de carga y luego 8 productos con nombre, categoría y precio. El detalle muestra el producto con "Precio de referencia" | | Pendiente | | |
| QA-13 | El endpoint responde una lista vacía (no se puede forzar en el dispositivo porque la URL es fija) | — | 1. Ejecutar `flutter test test/catalogo_vista_test.dart test/producto_repository_test.dart` | Pasan "catálogo vacío muestra su mensaje, no un error" ("No hay productos en el catálogo.", sin botón Reintentar) y "un catálogo vacío deja la copia vacía y no da aviso" | | Pendiente | | |
| QA-14 | Cliente con sesión; el catálogo ya cargó una vez (copia guardada) | cliente | 1. Activar modo avión. 2. Volver a abrir el catálogo. 3. Tocar Reintentar. 4. Quitar modo avión y tocar Reintentar | 2 y 3: muestra los productos guardados con el aviso "… Mostrando la última copia guardada." y el botón Reintentar. 4: el aviso desaparece y carga el catálogo actual. Sin copia guardada, la prueba "un error conocido muestra su mensaje y reintentar" cubre el error con Reintentar | | Pendiente | | |
| QA-15 | Dos pedidos `LISTO` asignados al mismo repartidor; `repartidores/{uid}` con `pedidoEnCamino: null`; el cliente dicta su código | repartidor, cliente | 1. Iniciar recorrido del primero. 2. Iniciar recorrido del segundo. 3. Entregar el primero con un código equivocado. 4. Entregarlo con el código correcto. 5. Iniciar recorrido del segundo | 2: "Ya tienes un pedido en camino. Entrégalo antes de iniciar otro." 3: "Código incorrecto." y el pedido sigue `EN_CAMINO`. 4: "Pedido entregado.", queda `ENTREGADO` y el cliente lo ve como "Entregado". 5: el segundo sí sale | | Pendiente | | |
| QA-16 | Build debug con repartidor con sesión | repartidor | 1. Tocar el botón de error de prueba en la barra. 2. Cerrar y volver a abrir la app. 3. Revisar Firebase Console → Crashlytics, filtrando eventos no fatales | 1: "Error de prueba registrado." 3: aparece "Bad state: Error de prueba de Crashlytics" con la versión de la app y el dispositivo. En el APK release el botón no aparece | | Pendiente | | |

## Registro de defectos

| ID | Caso | Descripción | Corrección o limitación | Estado |
|---|---|---|---|---|
| | | | | |
