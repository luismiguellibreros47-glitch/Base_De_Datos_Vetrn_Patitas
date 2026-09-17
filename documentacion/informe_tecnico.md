# Informe Técnico: Base de Datos Veterinaria Patitas
**Integrantes:** Luis Miguel Libreros, Camilo Amézquita, Popocho  

## 1. Descripción del Proyecto
Este proyecto implementa el diseño, construcción y programación de una base de datos relacional para la gestión clínica de la Veterinaria Patitas. La arquitectura garantiza la integridad de la información y automatiza procesos críticos mediante el uso de Procedimientos Almacenados y Triggers (Disparadores).

## 2. Estructura de la Base de Datos
La base de datos se encuentra normalizada y consta de las siguientes tablas interrelacionadas:
- **Entidades de actores y roles:** `terceros` (dueños, veterinarios, proveedores), `roles`, `terceros_rol`.
- **Entidades de pacientes:** `mascotas`, `especie`.
- **Entidades clínicas y citas:** `citas`, `consultas`, `consulta_detalle`, `tratamientos`.
- **Entidades de farmacia y compras:** `medicamentos`, `categoria_medicamentos`, `compras`, `detalle_compras`.
- **Entidad de control (Auditoría):** `auditoria_medicamentos`.

## 3. Lógica de los Procedimientos Almacenados Implementados

Para cubrir los requerimientos operativos de la veterinaria, se crearon 6 procedimientos almacenados:

### A. Procedimiento: `listar_citas_pendientes()`
- **Parámetros:** Ninguno.
- **Lógica:** Realiza un `INNER JOIN` entre la tabla `citas`, la tabla `mascotas` (por `ID_Mascota`) y la tabla `terceros` (por `ID_Tercero` del dueño). Filtra los registros donde el campo `Estado = 'Pendiente'`, permitiendo consultar de forma inmediata las citas que faltan por atender con los nombres de la mascota y del dueño.

### B. Procedimiento: `mascotas_por_especie(IN p_especie)`
- **Parámetros:** `IN p_especie VARCHAR(50)`.
- **Lógica:** Recibe el nombre de la especie (ejemplo: 'Felino', 'Canino') y hace una consulta cruzando `mascotas` con `especie` y `terceros`. Compara el parámetro recibido con `Tipo_Especie` para listar únicamente las mascotas de esa categoría con los datos de contacto de su dueño.

### C. Procedimiento: `registrar_nueva_mascota(IN p_nombre, IN p_especie, IN p_id_dueno)`
- **Parámetros:** `IN p_nombre VARCHAR(100)`, `IN p_especie VARCHAR(50)`, `IN p_id_dueno INT`.
- **Lógica:** Permite registrar un nuevo paciente. Incluye una validación interna para verificar si `p_especie` fue enviado como número (ID directo) o como texto (nombre de la especie). Si se ingresó el texto, consulta el `ID_Especie` correspondiente en la tabla `especie` (y si no existe lo inserta en el catálogo). Con el ID resuelto, inserta la fila en `mascotas` relacionándola con la llave foránea del dueño.

### D. Procedimiento: `calcular_deuda_cliente(IN p_id_cliente, OUT p_total_deuda)`
- **Parámetros:** `IN p_id_cliente INT`, `OUT p_total_deuda DECIMAL(10,2)`.
- **Lógica:** Calcula la suma de los costos de todos los tratamientos médicos no pagados pertenecientes a las mascotas del cliente. Utiliza `SUM(t.Costo)` con `IFNULL(..., 0.00)` uniendo `tratamientos` con `mascotas` donde `m.ID_Tercero = p_id_cliente` y el `Estado_Pago` es `'No Pagado'` o `'Pendiente'`, retornando el resultado en el parámetro de salida.

### E. Procedimiento: `aplicar_descuento_vacuna(INOUT p_precio_vacuna, IN p_descuento_promo)`
- **Parámetros:** `INOUT p_precio_vacuna DECIMAL(10,2)`, `IN p_descuento_promo DECIMAL(5,2)`.
- **Lógica:** Se utiliza el modo `INOUT` para que el parámetro ingrese con el precio normal de la vacuna y salga con el valor rebajado. Multiplica el precio recibido por el porcentaje `(p_descuento_promo / 100)` y lo resta directamente sobre la misma variable.

### F. Procedimiento: `atender_cita(IN p_id_cita, IN p_diagnostico, OUT p_estado_final)`
- **Parámetros:** `IN p_id_cita INT`, `IN p_diagnostico TEXT`, `OUT p_estado_final VARCHAR(100)`.
- **Lógica:** Ejecuta un `UPDATE` en la tabla `citas` para guardar el diagnóstico médico suministrado y actualizar el campo `Estado` a `'Atendido'`. En el parámetro de salida `p_estado_final` devuelve un mensaje confirmando que la atención fue guardada.

## 4. Lógica de los Triggers Implementados

### A. Trigger: `trg_validar_fecha_cita`
- **Tabla y Evento:** `citas` (BEFORE INSERT).
- **Lógica:** Antes de registrar una cita, evalúa si `DATE(NEW.Fecha_Cita) < CURDATE()`. En caso de que la fecha sea en el pasado, interrumpe el registro lanzando un error con `SIGNAL SQLSTATE '45000'`, asegurando que solo se agenden citas para el día actual o días futuros.

### B. Trigger: `trg_sumar_deuda_cliente`
- **Tabla y Evento:** `tratamientos` (AFTER INSERT).
- **Lógica:** Tras insertar un tratamiento a una mascota, el disparador busca en la tabla `mascotas` el `ID_Tercero` correspondiente al dueño y ejecuta un `UPDATE` en `terceros`, acumulando el costo (`NEW.Costo`) al campo `Total_Deuda`.

### C. Triggers de Farmacia y Auditoría
- **`trg_validar_precio_consulta_detalle` (BEFORE INSERT en `consulta_detalle`):** Impide precios negativos o cantidades menores o iguales a cero, calculando el subtotal automáticamente.
- **`trg_descontar_stock_consulta` (AFTER INSERT en `consulta_detalle`):** Descuenta el stock del medicamento recetado y suma el subtotal al Total de la consulta.
- **`trg_auditoria_stock_medicamentos` (AFTER UPDATE en `medicamentos`):** Registra en `auditoria_medicamentos` cualquier cambio de existencias con fecha, usuario y valores anterior y nuevo.

## 5. Pruebas y Validación (DML)
En la carpeta `/dml` se encuentran:
1. `02_insercion_y_consultas.sql`: Población inicial y pruebas de joins relacionales.
2. `03_pruebas_procedimientos_y_triggers.sql`: Script de pruebas ejecutables que valida cada uno de los 6 procedimientos y la respuesta de los triggers.
