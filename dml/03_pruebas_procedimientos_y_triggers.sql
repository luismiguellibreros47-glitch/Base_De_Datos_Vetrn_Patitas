-- ==============================================================================
-- PROYECTO: Veterinaria Patitas
-- ARCHIVO: 03_pruebas_procedimientos_y_triggers.sql
-- DESCRIPCIÓN: Pruebas de ejecución y validación de los 6 Procedimientos
--              Almacenados y los 2 Triggers implementados.
-- ==============================================================================

USE `veterinaria_patitas`;

-- ------------------------------------------------------------------------------
-- 1. PRUEBA DE REGISTRO DE MASCOTA (Procedimiento 3)
-- ------------------------------------------------------------------------------
-- Registramos un nuevo paciente asociado al dueño con ID 1 (Carlos Alberto Ramírez)
CALL registrar_nueva_mascota('Zeus', 'Canino', 1);
CALL registrar_nueva_mascota('Kira', 'Felino', 2);

-- Validamos que las mascotas se hayan registrado correctamente
SELECT m.ID_Mascotas, m.Nombre, e.Tipo_Especie AS Especie, t.Nombre AS Dueno
FROM mascotas m
JOIN especie e ON m.ID_Especie = e.ID_Especie
JOIN terceros t ON m.ID_Tercero = t.ID_Tercero
WHERE m.Nombre IN ('Zeus', 'Kira');

-- ------------------------------------------------------------------------------
-- 2. PRUEBA DE CONSULTA POR ESPECIE (Procedimiento 2)
-- ------------------------------------------------------------------------------
-- Listamos todas las mascotas registradas de la categoría 'Felino'
CALL mascotas_por_especie('Felino');

-- ------------------------------------------------------------------------------
-- 3. PRUEBA DEL TRIGGER 1 (trg_validar_fecha_cita) Y REGISTRO DE CITAS
-- ------------------------------------------------------------------------------
-- Inserción de citas con fechas válidas (hoy o futuras)
INSERT INTO citas (ID_Mascota, ID_Veterinario, Fecha_Cita, Motivo, Estado)
VALUES (1, 6, NOW() + INTERVAL 1 DAY, 'Control de vacunas anual', 'Pendiente');

INSERT INTO citas (ID_Mascota, ID_Veterinario, Fecha_Cita, Motivo, Estado)
VALUES (2, 7, NOW() + INTERVAL 2 DAY, 'Revisión por decaimiento', 'Pendiente');

-- Nota de prueba de error: si se intenta registrar una fecha pasada, el trigger bloquea el insert:
-- INSERT INTO citas (ID_Mascota, Fecha_Cita, Motivo, Estado) VALUES (1, '2023-01-01', 'Cita vieja', 'Pendiente');
-- Error esperado: SIGNAL SQLSTATE '45000' -> "Error: La fecha de la cita no puede ser anterior a la fecha actual."

-- ------------------------------------------------------------------------------
-- 4. PRUEBA DE LISTAR CITAS PENDIENTES (Procedimiento 1)
-- ------------------------------------------------------------------------------
-- Consulta de todas las citas en estado 'Pendiente' con INNER JOIN de mascota y dueño
CALL listar_citas_pendientes();

-- ------------------------------------------------------------------------------
-- 5. PRUEBA DE ATENDER CITA (Procedimiento 6)
-- ------------------------------------------------------------------------------
-- Atendemos la cita con ID 1, agregamos el diagnóstico y capturamos el mensaje de confirmación
CALL atender_cita(1, 'Paciente con excelente peso, se aplica refuerzo de vacuna séxtuple.', @mensaje_salida);
SELECT @mensaje_salida AS Confirmacion_Atencion;

-- Verificamos que la cita cambió su estado a 'Atendido' y guardó el diagnóstico
SELECT ID_Cita, Fecha_Cita, Diagnostico, Estado 
FROM citas 
WHERE ID_Cita = 1;

-- ------------------------------------------------------------------------------
-- 6. PRUEBA DEL TRIGGER 2 (trg_sumar_deuda_cliente) AL REGISTRAR TRATAMIENTO
-- ------------------------------------------------------------------------------
-- Revisamos la deuda inicial del cliente 1
SELECT ID_Tercero, Nombre, Total_Deuda AS Deuda_Inicial 
FROM terceros 
WHERE ID_Tercero = 1;

-- Registramos tratamientos para la mascota 1 (cuyo dueño es el cliente 1)
INSERT INTO tratamientos (ID_Mascota, Descripcion, Costo, Estado_Pago)
VALUES (1, 'Limpieza dental con ultrasonido', 60000.00, 'No Pagado');

INSERT INTO tratamientos (ID_Mascota, Descripcion, Costo, Estado_Pago)
VALUES (1, 'Tratamiento analgésico post-operatorio', 25000.00, 'No Pagado');

-- Comprobamos que el trigger actualizó automáticamente la deuda del cliente (60000 + 25000 = 85000)
SELECT ID_Tercero, Nombre, Total_Deuda AS Deuda_Actualizada 
FROM terceros 
WHERE ID_Tercero = 1;

-- ------------------------------------------------------------------------------
-- 7. PRUEBA DE CÁLCULO DE DEUDA DE CLIENTE (Procedimiento 4)
-- ------------------------------------------------------------------------------
-- Obtenemos el total adeudado por tratamientos no pagados del cliente 1 mediante el parámetro OUT
CALL calcular_deuda_cliente(1, @deuda_calculada);
SELECT @deuda_calculada AS Deuda_Pendiente_Cliente_1;

-- ------------------------------------------------------------------------------
-- 8. PRUEBA DE DESCUENTO EN VACUNA (Procedimiento 5)
-- ------------------------------------------------------------------------------
-- Configuramos el precio base de una vacuna en una variable de sesión
SET @precio_vacuna = 45000.00;
SELECT @precio_vacuna AS Precio_Sin_Descuento;

-- Aplicamos un 15% de descuento promocional (INOUT devuelve el valor modificado)
CALL aplicar_descuento_vacuna(@precio_vacuna, 15.00);
SELECT @precio_vacuna AS Precio_Final_Con_Descuento; -- Resultado: 38250.00
