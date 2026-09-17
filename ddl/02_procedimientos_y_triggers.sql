-- ==============================================================================
-- PROYECTO: Veterinaria Patitas
-- ARCHIVO: 02_procedimientos_y_triggers.sql
-- DESCRIPCIÓN: Creación de tablas complementarias (citas, tratamientos),
--              los 6 Procedimientos Almacenados y los 2 Triggers requeridos.
-- ==============================================================================

USE `veterinaria_patitas`;

-- ------------------------------------------------------------------------------
-- 1. TABLAS COMPLEMENTARIAS NECESARIAS PARA CITAS, TRATAMIENTOS Y DEUDAS
-- ------------------------------------------------------------------------------

-- Agregar columna Total_Deuda a terceros si no existe
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'terceros' 
      AND COLUMN_NAME = 'Total_Deuda'
);

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `terceros` ADD COLUMN `Total_Deuda` DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `Estado`', 
    'SELECT "Columna Total_Deuda ya existe"'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Tabla Citas: requerida para listar citas, atenderlas y validar fechas
CREATE TABLE IF NOT EXISTS `citas` (
    `ID_Cita` INT NOT NULL AUTO_INCREMENT,
    `ID_Mascota` INT NOT NULL,
    `ID_Veterinario` INT DEFAULT NULL,
    `Fecha_Cita` DATETIME NOT NULL,
    `Motivo` VARCHAR(255) DEFAULT NULL,
    `Diagnostico` TEXT DEFAULT NULL,
    `Estado` ENUM('Pendiente', 'Atendido', 'Cancelado') NOT NULL DEFAULT 'Pendiente',
    PRIMARY KEY (`ID_Cita`),
    KEY `fk_citas_mascota` (`ID_Mascota`),
    KEY `fk_citas_veterinario` (`ID_Veterinario`),
    CONSTRAINT `fk_citas_mascota` FOREIGN KEY (`ID_Mascota`) REFERENCES `mascotas` (`ID_Mascotas`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_citas_veterinario` FOREIGN KEY (`ID_Veterinario`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla Tratamientos: requerida para calcular deudas y el trigger de sumar deuda
CREATE TABLE IF NOT EXISTS `tratamientos` (
    `ID_Tratamiento` INT NOT NULL AUTO_INCREMENT,
    `ID_Mascota` INT NOT NULL,
    `Descripcion` VARCHAR(255) NOT NULL,
    `Costo` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `Estado_Pago` ENUM('Pendiente', 'Pagado', 'No Pagado') NOT NULL DEFAULT 'No Pagado',
    `Fecha` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ID_Tratamiento`),
    KEY `fk_tratamiento_mascota` (`ID_Mascota`),
    CONSTRAINT `fk_tratamiento_mascota` FOREIGN KEY (`ID_Mascota`) REFERENCES `mascotas` (`ID_Mascotas`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==============================================================================
-- 2. PROCEDIMIENTOS ALMACENADOS (6 REQUERIDOS)
-- ==============================================================================

DELIMITER $$

-- ------------------------------------------------------------------------------
-- Procedimiento 1: listar_citas_pendientes()
-- Sin parámetros. Muestra mascota, dueño y fecha de citas en estado 'Pendiente'.
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `listar_citas_pendientes`$$
CREATE PROCEDURE `listar_citas_pendientes`()
BEGIN
    SELECT 
        m.Nombre AS Nombre_Mascota,
        t.Nombre AS Nombre_Dueno,
        c.Fecha_Cita AS Fecha_Cita,
        c.Motivo,
        c.Estado
    FROM citas c
    INNER JOIN mascotas m ON c.ID_Mascota = m.ID_Mascotas
    INNER JOIN terceros t ON m.ID_Tercero = t.ID_Tercero
    WHERE c.Estado = 'Pendiente';
END$$

-- ------------------------------------------------------------------------------
-- Procedimiento 2: mascotas_por_especie(IN p_especie)
-- Recibe una especie (ej: 'Felino') y lista todas las mascotas registradas.
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `mascotas_por_especie`$$
CREATE PROCEDURE `mascotas_por_especie`(
    IN p_especie VARCHAR(50)
)
BEGIN
    SELECT 
        m.ID_Mascotas AS ID_Mascota,
        m.Nombre AS Nombre_Mascota,
        e.Tipo_Especie AS Especie,
        t.Nombre AS Nombre_Dueno,
        t.Contacto AS Telefono_Dueno
    FROM mascotas m
    INNER JOIN especie e ON m.ID_Especie = e.ID_Especie
    INNER JOIN terceros t ON m.ID_Tercero = t.ID_Tercero
    WHERE e.Tipo_Especie = p_especie;
END$$

-- ------------------------------------------------------------------------------
-- Procedimiento 3: registrar_nueva_mascota(IN p_nombre, IN p_especie, IN p_id_dueno)
-- Inserta un nuevo paciente asociándolo a la llave foránea del dueño.
-- Permite recibir el nombre de la especie o su ID numérico.
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `registrar_nueva_mascota`$$
CREATE PROCEDURE `registrar_nueva_mascota`(
    IN p_nombre VARCHAR(100),
    IN p_especie VARCHAR(50),
    IN p_id_dueno INT
)
BEGIN
    DECLARE v_id_especie INT;
    
    -- Si el parámetro recibido es numérico, lo tomamos como ID directo
    IF p_especie REGEXP '^[0-9]+$' THEN
        SET v_id_especie = CAST(p_especie AS UNSIGNED);
    ELSE
        -- Si es texto, buscamos el ID correspondiente en la tabla especie
        SELECT ID_Especie INTO v_id_especie 
        FROM especie 
        WHERE LOWER(Tipo_Especie) = LOWER(p_especie) 
        LIMIT 1;
        
        -- Si la especie aún no existe, se inserta en el catálogo
        IF v_id_especie IS NULL THEN
            INSERT INTO especie (Tipo_Especie) VALUES (p_especie);
            SET v_id_especie = LAST_INSERT_ID();
        END IF;
    END IF;
    
    -- Inserción de la nueva mascota asociada a su dueño
    INSERT INTO mascotas (Nombre, ID_Especie, ID_Tercero)
    VALUES (p_nombre, v_id_especie, p_id_dueno);
END$$

-- ------------------------------------------------------------------------------
-- Procedimiento 4: calcular_deuda_cliente(IN p_id_cliente, OUT p_total_deuda)
-- Suma el costo de todos los tratamientos no pagados de las mascotas del cliente.
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `calcular_deuda_cliente`$$
CREATE PROCEDURE `calcular_deuda_cliente`(
    IN p_id_cliente INT,
    OUT p_total_deuda DECIMAL(10,2)
)
BEGIN
    SELECT IFNULL(SUM(t.Costo), 0.00)
    INTO p_total_deuda
    FROM tratamientos t
    INNER JOIN mascotas m ON t.ID_Mascota = m.ID_Mascotas
    WHERE m.ID_Tercero = p_id_cliente
      AND t.Estado_Pago IN ('No Pagado', 'Pendiente');
END$$

-- ------------------------------------------------------------------------------
-- Procedimiento 5: aplicar_descuento_vacuna(INOUT p_precio_vacuna, IN p_descuento_promo)
-- Toma el precio de una vacuna, le resta el descuento y devuelve el valor final.
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `aplicar_descuento_vacuna`$$
CREATE PROCEDURE `aplicar_descuento_vacuna`(
    INOUT p_precio_vacuna DECIMAL(10,2),
    IN p_descuento_promo DECIMAL(5,2)
)
BEGIN
    SET p_precio_vacuna = p_precio_vacuna - (p_precio_vacuna * (p_descuento_promo / 100));
END$$

-- ------------------------------------------------------------------------------
-- Procedimiento 6: atender_cita(IN p_id_cita, IN p_diagnostico, OUT p_estado_final)
-- Registra el diagnóstico médico, pasa el estado a 'Atendido' y retorna confirmación.
-- ------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `atender_cita`$$
CREATE PROCEDURE `atender_cita`(
    IN p_id_cita INT,
    IN p_diagnostico TEXT,
    OUT p_estado_final VARCHAR(100)
)
BEGIN
    UPDATE citas
    SET Diagnostico = p_diagnostico,
        Estado = 'Atendido'
    WHERE ID_Cita = p_id_cita;
    
    SET p_estado_final = CONCAT('Cita #', p_id_cita, ' atendida con exito');
END$$


-- ==============================================================================
-- 3. TRIGGERS (2 REQUERIDOS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Trigger 1: trg_validar_fecha_cita (BEFORE INSERT en tabla Citas)
-- Verifica que la fecha ingresada sea mayor o igual a la fecha actual (CURDATE()).
-- ------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_validar_fecha_cita`$$
CREATE TRIGGER `trg_validar_fecha_cita`
BEFORE INSERT ON `citas`
FOR EACH ROW
BEGIN
    IF DATE(NEW.Fecha_Cita) < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La fecha de la cita no puede ser anterior a la fecha actual.';
    END IF;
END$$

-- ------------------------------------------------------------------------------
-- Trigger 2: trg_sumar_deuda_cliente (AFTER INSERT en tabla Tratamientos)
-- Cada vez que se agrega un tratamiento a una mascota, suma el costo a la deuda del dueño.
-- ------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_sumar_deuda_cliente`$$
CREATE TRIGGER `trg_sumar_deuda_cliente`
AFTER INSERT ON `tratamientos`
FOR EACH ROW
BEGIN
    DECLARE v_id_dueno INT;

    -- Localizamos el dueño responsable de la mascota tratada
    SELECT ID_Tercero INTO v_id_dueno
    FROM mascotas
    WHERE ID_Mascotas = NEW.ID_Mascota;

    -- Sumamos el valor del tratamiento al total adeudado del cliente
    UPDATE terceros
    SET Total_Deuda = Total_Deuda + NEW.Costo
    WHERE ID_Tercero = v_id_dueno;
END$$

DELIMITER ;
