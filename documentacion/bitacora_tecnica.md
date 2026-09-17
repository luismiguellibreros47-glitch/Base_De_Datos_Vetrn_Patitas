# Bitácora Técnica: Procedimientos Almacenados y Triggers
**Proyecto:** Base de Datos Veterinaria Patitas  
**Integrantes:** Luis Miguel Libreros, Camilo Amézquita, Popocho  

---

## 1. Ajustes en la Estructura de la Base de Datos
Para poder implementar la lógica solicitada por el profesor en esta entrega, revisamos el modelo relacional y agregamos los componentes necesarios:

1. **Tabla `citas`:** La creamos para gestionar la programación de atención médica de los pacientes. Cuenta con llaves foráneas hacia `mascotas` y `terceros` (veterinario que atiende), además de campos para `Fecha_Cita`, `Motivo`, `Diagnostico` y un `Estado` con valores `'Pendiente'`, `'Atendido'` o `'Cancelado'`.
2. **Tabla `tratamientos`:** Creada para registrar los procedimientos y cuidados clínicos aplicados a cada mascota, almacenando el `Costo`, la descripción y el `Estado_Pago` (`'No Pagado'`, `'Pendiente'`, `'Pagado'`).
3. **Columna `Total_Deuda` en `terceros`:** Añadimos un campo numérico decimal con valor por defecto en `0.00` en la tabla de terceros para llevar el control acumulado de lo que adeuda cada cliente.

---

## 2. Lógica de los Procedimientos Almacenados

A continuación explicamos cómo desarrollamos la lógica de cada uno de los 6 procedimientos asignados:

### 1. `listar_citas_pendientes()`
* **Objetivo:** Mostrar las citas pendientes con los nombres legibles de la mascota y de su dueño.
* **Cómo lo resolvimos:** Como el procedimiento no recibe parámetros, hicimos una consulta directa usando dos `INNER JOIN`: uniendo la tabla `citas` con `mascotas` a través del `ID_Mascota`, y luego con `terceros` a través del `ID_Tercero` del dueño. Filtramos la consulta con `WHERE Estado = 'Pendiente'` para traer únicamente las citas por atender junto con su fecha programada.

### 2. `mascotas_por_especie(IN p_especie)`
* **Objetivo:** Filtrar el listado de mascotas según una especie en específico (por ejemplo: 'Felino', 'Canino').
* **Cómo lo resolvimos:** Definimos el parámetro de entrada `p_especie VARCHAR(50)`. Realizamos el cruce entre `mascotas` y `especie` por su llave primaria/foránea (`ID_Especie`), y sumamos `terceros` para mostrar el nombre del dueño y su teléfono. La condición `WHERE e.Tipo_Especie = p_especie` devuelve solo los registros de esa categoría.

### 3. `registrar_nueva_mascota(IN p_nombre, IN p_especie, IN p_id_dueno)`
* **Objetivo:** Dar de alta un nuevo paciente relacionándolo con la llave de su dueño.
* **Cómo lo resolvimos:** Para evitar errores si el usuario ingresa el nombre de la especie en texto (ej. 'Felino') o el ID numérico directo, programamos una validación con una variable local `v_id_especie`. Si recibe texto, busca el ID en la tabla `especie` y, si la especie no existiera en el catálogo, la inserta automáticamente para obtener su `LAST_INSERT_ID()`. Con el ID resuelto, se ejecuta el `INSERT INTO mascotas` asociando el nombre, la especie y el `ID_Tercero` del dueño.

### 4. `calcular_deuda_cliente(IN p_id_cliente, OUT p_total_deuda)`
* **Objetivo:** Obtener la suma total de tratamientos que un cliente específico aún no ha pagado.
* **Cómo lo resolvimos:** Recibimos el código del cliente por parámetro `IN` y declaramos `p_total_deuda` como `OUT`. Hacemos un `SUM(t.Costo)` cruzando la tabla `tratamientos` con `mascotas` para ubicar cuáles animales pertenecen a ese cliente (`m.ID_Tercero = p_id_cliente`). Filtramos donde el estado de pago sea `'No Pagado'` o `'Pendiente'`, y usamos la función `IFNULL(..., 0.00)` para que, si el cliente no debe nada o no tiene tratamientos pendientes, el procedimiento retorne `0.00` y no un valor nulo.

### 5. `aplicar_descuento_vacuna(INOUT p_precio_vacuna, IN p_descuento_promo)`
* **Objetivo:** Modificar el precio de una vacuna restando un porcentaje de descuento promocional.
* **Cómo lo resolvimos:** Definimos `p_precio_vacuna` como `INOUT` porque el mismo parámetro recibe el precio original y debe devolver el precio con el descuento aplicado. En el cuerpo del procedimiento calculamos el valor a descontar multiplicando el precio por `(p_descuento_promo / 100)` y restándoselo directamente a la variable.

### 6. `atender_cita(IN p_id_cita, IN p_diagnostico, OUT p_estado_final)`
* **Objetivo:** Finalizar la cita médica guardando el diagnóstico y cambiando el estado a 'Atendido'.
* **Cómo lo resolvimos:** Recibimos por `IN` el ID de la cita y el texto con el diagnóstico veterinario. Con un `UPDATE` modificamos el registro de la cita asignando el nuevo diagnóstico y cambiando el campo `Estado = 'Atendido'`. Finalmente, por el parámetro `OUT p_estado_final` retornamos un mensaje confirmando que la cita fue atendida exitosamente.

---

## 3. Lógica de los Triggers Implementados

### 1. `trg_validar_fecha_cita` (BEFORE INSERT en tabla `citas`)
* **Momento y Evento:** `BEFORE INSERT` sobre la tabla `citas`.
* **Lógica aplicada:** Antes de que se guarde cualquier cita nueva, evaluamos si la fecha ingresada (`NEW.Fecha_Cita`) es anterior al día actual utilizando la función `CURDATE()`. Si `DATE(NEW.Fecha_Cita) < CURDATE()`, el disparador interrumpe la operación lanzando una excepción con `SIGNAL SQLSTATE '45000'` y un mensaje de error claro, evitando que queden registradas citas con fechas en el pasado.

### 2. `trg_sumar_deuda_cliente` (AFTER INSERT en tabla `tratamientos`)
* **Momento y Evento:** `AFTER INSERT` sobre la tabla `tratamientos`.
* **Lógica aplicada:** Una vez que se registra un tratamiento para una mascota, el disparador toma el `NEW.ID_Mascota` para buscar en la tabla `mascotas` a qué dueño (`ID_Tercero`) corresponde. Luego ejecuta un `UPDATE` sobre la tabla `terceros` sumando el costo del tratamiento (`NEW.Costo`) a la columna `Total_Deuda` del dueño correspondiente, manteniendo la cartera de clientes actualizada en tiempo real de forma automática.

---

## 4. Guía de Ejecución y Pruebas
1. Ejecutar en MySQL Workbench el archivo `/ddl/02_procedimientos_y_triggers.sql` sobre la base de datos `veterinaria_patitas`.
2. Ejecutar el archivo `/dml/03_pruebas_procedimientos_y_triggers.sql` para validar mediante llamadas `CALL` y consultas `SELECT` el funcionamiento correcto de cada procedimiento y disparador.
