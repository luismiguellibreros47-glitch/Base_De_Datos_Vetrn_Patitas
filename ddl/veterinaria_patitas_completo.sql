-- ==============================================================================
-- Base de Datos: veterinaria_patitas
-- Volcado completo: Estructura, Datos, Procedimientos Almacenados y Triggers
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS `veterinaria_patitas` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `veterinaria_patitas`;

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------------------------
-- 1. ESTRUCTURA DE TABLAS
-- ------------------------------------------------------------------------------

-- Tabla: roles
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `ID_Rol` int NOT NULL AUTO_INCREMENT,
  `Nombre_Rol` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Rol`),
  UNIQUE KEY `Nombre_Rol` (`Nombre_Rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: terceros (Dueños, Veterinarios, Proveedores)
DROP TABLE IF EXISTS `terceros`;
CREATE TABLE `terceros` (
  `ID_Tercero` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Cedula` varchar(100) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `Direccion` varchar(100) NOT NULL,
  `Contacto` varchar(100) NOT NULL,
  `Estado` tinyint NOT NULL DEFAULT '1',
  `Total_Deuda` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`ID_Tercero`),
  UNIQUE KEY `Cedula` (`Cedula`),
  UNIQUE KEY `Correo` (`Correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: terceros_rol (Relación muchos a muchos)
DROP TABLE IF EXISTS `terceros_rol`;
CREATE TABLE `terceros_rol` (
  `ID_Tercero` int NOT NULL,
  `ID_Rol` int NOT NULL,
  PRIMARY KEY (`ID_Tercero`,`ID_Rol`),
  KEY `ID_Rol` (`ID_Rol`),
  CONSTRAINT `terceros_rol_ibfk_1` FOREIGN KEY (`ID_Tercero`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `terceros_rol_ibfk_2` FOREIGN KEY (`ID_Rol`) REFERENCES `roles` (`ID_Rol`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: especie
DROP TABLE IF EXISTS `especie`;
CREATE TABLE `especie` (
  `ID_Especie` int NOT NULL AUTO_INCREMENT,
  `Tipo_Especie` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Especie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: mascotas
DROP TABLE IF EXISTS `mascotas`;
CREATE TABLE `mascotas` (
  `ID_Mascotas` int NOT NULL AUTO_INCREMENT,
  `ID_Tercero` int NOT NULL,
  `ID_Especie` int NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`ID_Mascotas`),
  KEY `ID_Tercero` (`ID_Tercero`),
  KEY `ID_Especie` (`ID_Especie`),
  CONSTRAINT `mascotas_ibfk_1` FOREIGN KEY (`ID_Tercero`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `mascotas_ibfk_2` FOREIGN KEY (`ID_Especie`) REFERENCES `especie` (`ID_Especie`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: categoria_medicamentos
DROP TABLE IF EXISTS `categoria_medicamentos`;
CREATE TABLE `categoria_medicamentos` (
  `ID_Categoria` int NOT NULL AUTO_INCREMENT,
  `Nombre_Categoria` varchar(100) NOT NULL,
  `Descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID_Categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: medicamentos
DROP TABLE IF EXISTS `medicamentos`;
CREATE TABLE `medicamentos` (
  `ID_Medicamentos` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` text,
  `Stock` int NOT NULL DEFAULT '50',
  `Estado` tinyint NOT NULL DEFAULT '1',
  `Precio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `ID_Categoria` int NOT NULL,
  PRIMARY KEY (`ID_Medicamentos`),
  KEY `fk_medicamento_categoria` (`ID_Categoria`),
  CONSTRAINT `fk_medicamento_categoria` FOREIGN KEY (`ID_Categoria`) REFERENCES `categoria_medicamentos` (`ID_Categoria`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: consultas
DROP TABLE IF EXISTS `consultas`;
CREATE TABLE `consultas` (
  `ID_Consultas` int NOT NULL AUTO_INCREMENT,
  `ID_Mascotas` int NOT NULL,
  `ID_Veterinario` int NOT NULL,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Descripcion` varchar(200) DEFAULT NULL,
  `Total` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`ID_Consultas`),
  KEY `ID_Mascotas` (`ID_Mascotas`),
  KEY `ID_Veterinario` (`ID_Veterinario`),
  CONSTRAINT `consultas_ibfk_1` FOREIGN KEY (`ID_Mascotas`) REFERENCES `mascotas` (`ID_Mascotas`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `consultas_ibfk_2` FOREIGN KEY (`ID_Veterinario`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: consulta_detalle
DROP TABLE IF EXISTS `consulta_detalle`;
CREATE TABLE `consulta_detalle` (
  `ID_Consulta_Detalle` int NOT NULL AUTO_INCREMENT,
  `ID_Consulta` int NOT NULL,
  `ID_Medicamento` int NOT NULL,
  `Cantidad` int NOT NULL,
  `Precio_Unitario` decimal(10,2) NOT NULL,
  `Subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ID_Consulta_Detalle`),
  KEY `ID_Consulta` (`ID_Consulta`),
  KEY `ID_Medicamento` (`ID_Medicamento`),
  CONSTRAINT `consulta_detalle_ibfk_1` FOREIGN KEY (`ID_Consulta`) REFERENCES `consultas` (`ID_Consultas`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `consulta_detalle_ibfk_2` FOREIGN KEY (`ID_Medicamento`) REFERENCES `medicamentos` (`ID_Medicamentos`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: compras
DROP TABLE IF EXISTS `compras`;
CREATE TABLE `compras` (
  `ID_Compra` int NOT NULL AUTO_INCREMENT,
  `Numero_Factura` varchar(50) NOT NULL,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ID_Tercero` int NOT NULL,
  `Estado_Pago` enum('Pendiente','Pagado','Cancelado') NOT NULL DEFAULT 'Pendiente',
  `Total` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`ID_Compra`),
  KEY `ID_Tercero` (`ID_Tercero`),
  CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`ID_Tercero`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: detalle_compras
DROP TABLE IF EXISTS `detalle_compras`;
CREATE TABLE `detalle_compras` (
  `ID_Detalle_Compra` int NOT NULL AUTO_INCREMENT,
  `ID_Compra` int NOT NULL,
  `ID_Medicamento` int NOT NULL,
  `Cantidad` int NOT NULL,
  `Precio_Compra` decimal(10,2) NOT NULL,
  `Subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ID_Detalle_Compra`),
  KEY `ID_Compra` (`ID_Compra`),
  KEY `ID_Medicamento` (`ID_Medicamento`),
  CONSTRAINT `detalle_compras_ibfk_1` FOREIGN KEY (`ID_Compra`) REFERENCES `compras` (`ID_Compra`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_compras_ibfk_2` FOREIGN KEY (`ID_Medicamento`) REFERENCES `medicamentos` (`ID_Medicamentos`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: citas
DROP TABLE IF EXISTS `citas`;
CREATE TABLE `citas` (
  `ID_Cita` int NOT NULL AUTO_INCREMENT,
  `ID_Mascota` int NOT NULL,
  `ID_Veterinario` int DEFAULT NULL,
  `Fecha_Cita` datetime NOT NULL,
  `Motivo` varchar(255) DEFAULT NULL,
  `Diagnostico` text DEFAULT NULL,
  `Estado` enum('Pendiente','Atendido','Cancelado') NOT NULL DEFAULT 'Pendiente',
  PRIMARY KEY (`ID_Cita`),
  KEY `fk_citas_mascota` (`ID_Mascota`),
  KEY `fk_citas_veterinario` (`ID_Veterinario`),
  CONSTRAINT `fk_citas_mascota` FOREIGN KEY (`ID_Mascota`) REFERENCES `mascotas` (`ID_Mascotas`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_citas_veterinario` FOREIGN KEY (`ID_Veterinario`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: tratamientos
DROP TABLE IF EXISTS `tratamientos`;
CREATE TABLE `tratamientos` (
  `ID_Tratamiento` int NOT NULL AUTO_INCREMENT,
  `ID_Mascota` int NOT NULL,
  `Descripcion` varchar(255) NOT NULL,
  `Costo` decimal(10,2) NOT NULL DEFAULT '0.00',
  `Estado_Pago` enum('Pendiente','Pagado','No Pagado') NOT NULL DEFAULT 'No Pagado',
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID_Tratamiento`),
  KEY `fk_tratamiento_mascota` (`ID_Mascota`),
  CONSTRAINT `fk_tratamiento_mascota` FOREIGN KEY (`ID_Mascota`) REFERENCES `mascotas` (`ID_Mascotas`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla: auditoria_medicamentos
DROP TABLE IF EXISTS `auditoria_medicamentos`;
CREATE TABLE `auditoria_medicamentos` (
  `ID_Auditoria` int NOT NULL AUTO_INCREMENT,
  `ID_Medicamento` int NOT NULL,
  `Accion` varchar(20) NOT NULL,
  `Stock_Anterior` int DEFAULT NULL,
  `Stock_Nuevo` int DEFAULT NULL,
  `Usuario` varchar(100) NOT NULL,
  `Fecha_Hora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Detalle` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID_Auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;


-- ------------------------------------------------------------------------------
-- 2. DATOS DE EJEMPLO
-- ------------------------------------------------------------------------------

INSERT INTO `roles` (`ID_Rol`, `Nombre_Rol`) VALUES 
(1,'Dueño'), (2,'Veterinario'), (3,'Proveedor');

INSERT INTO `terceros` (`ID_Tercero`, `Nombre`, `Cedula`, `Correo`, `Direccion`, `Contacto`, `Estado`, `Total_Deuda`) VALUES 
(1,'Carlos Alberto Ramírez','1088123456','carlos.ramirez@email.com','Calle 10 # 4-56, Cartago','3101234567',1,0.00),
(2,'María Fernanda López','1004987654','mafe.lopez@email.com','Cra 5 # 14-23, Cartago','3129876543',1,0.00),
(3,'Andrés Felipe Gómez','1111222333','andres.gomez@email.com','Barrio El Prado, Cartago','3005554433',1,0.00),
(4,'Laura Sofía Martínez','1088555666','laura.martinez@email.com','Av. Santa Ana # 8-12, Cartago','3157778899',1,0.00),
(5,'Jorge Hernán Pérez','1002333444','jorge.perez@email.com','Calle 20 # 6-10, Cartago','3201112233',1,0.00),
(6,'Dr. Alejandro Ruiz','2000000001','aruiz.vet@email.com','Centro Veterinario Salud Animal','3145558899',1,0.00),
(7,'Dra. Camila Torres','2000000002','ctorres.vet@email.com','Clínica Veterinaria Huellitas','3187776655',1,0.00),
(8,'Dr. Sebastián Castro','2000000003','scastro.vet@email.com','Hospital Veterinario Central','3214445566',1,0.00);

INSERT INTO `terceros_rol` (`ID_Tercero`, `ID_Rol`) VALUES 
(1,1),(2,1),(3,1),(4,1),(5,1),(6,2),(7,2),(8,2);

INSERT INTO `especie` (`ID_Especie`, `Tipo_Especie`) VALUES 
(1,'Canino'),(2,'Felino'),(3,'Ave'),(4,'Roedor'),(5,'Reptil');

INSERT INTO `mascotas` (`ID_Mascotas`, `ID_Tercero`, `ID_Especie`, `Nombre`) VALUES 
(1,1,1,'Max'),
(2,1,2,'Luna'),
(3,2,1,'Rocky'),
(4,3,3,'Paco'),
(5,4,2,'Simba'),
(6,5,4,'Copo');

INSERT INTO `categoria_medicamentos` (`ID_Categoria`, `Nombre_Categoria`, `Descripcion`) VALUES 
(1,'Biológicos y Vacunas','Vacunas preventivas para distintas especies'),
(2,'Antiinflamatorios y Analgésicos','Control del dolor y la inflamación'),
(3,'Antiparasitarios','Control de pulgas, garrapatas y parásitos internos'),
(4,'Antibióticos y Antieméticos','Tratamiento de infecciones y problemas gástricos'),
(5,'Suplementos y Vitaminas','Refuerzo nutricional');

INSERT INTO `medicamentos` (`ID_Medicamentos`, `Nombre`, `Descripcion`, `Stock`, `Estado`, `Precio`, `ID_Categoria`) VALUES 
(1,'Vacuna Séxtuple','Inmunización contra moquillo, parvovirus, hepatitis, etc.',50,1,45000.00,1),
(2,'Meloxicam 1mg','Antiinflamatorio no esteroideo para control del dolor.',50,1,5000.00,2),
(3,'Desparasitante Interno','Tableta masticable de amplio espectro.',50,1,15000.00,3),
(4,'Antiemético Inyectable','Control de náuseas y vómitos agudos.',50,1,25000.00,4),
(5,'Suplemento Vitamínico','Gotas multivitamínicas.',50,1,35000.00,5);

INSERT INTO `consultas` (`ID_Consultas`, `ID_Mascotas`, `ID_Veterinario`, `Fecha`, `Descripcion`, `Total`) VALUES 
(1,1,6,'2026-09-10 00:59:48','Control general y vacunación anual.',60000.00),
(2,2,7,'2026-09-10 00:59:48','Problemas digestivos, presenta vómito constante.',40000.00),
(3,3,6,'2026-09-10 00:59:48','Revisión por cojera en la pata delantera.',25000.00),
(4,4,8,'2026-09-10 00:59:48','Corte de pico, uñas y revisión de plumaje.',0.00),
(5,5,7,'2026-09-10 00:59:48','Chequeo de rutina y desparasitación.',30000.00),
(6,6,8,'2026-09-10 00:59:48','Consulta de urgencia por letargo.',35000.00);

INSERT INTO `consulta_detalle` (`ID_Consulta_Detalle`, `ID_Consulta`, `ID_Medicamento`, `Cantidad`, `Precio_Unitario`, `Subtotal`) VALUES 
(1,1,1,1,45000.00,45000.00),
(2,1,3,1,15000.00,15000.00),
(3,2,4,1,25000.00,25000.00),
(4,2,2,3,5000.00,15000.00),
(5,3,2,5,5000.00,25000.00),
(6,5,3,2,15000.00,30000.00),
(7,6,5,1,35000.00,35000.00);

-- Citas de ejemplo iniciales
INSERT INTO `citas` (`ID_Cita`, `ID_Mascota`, `ID_Veterinario`, `Fecha_Cita`, `Motivo`, `Estado`) VALUES
(1, 1, 6, DATE_ADD(NOW(), INTERVAL 1 DAY), 'Control general y vacunación', 'Pendiente'),
(2, 2, 7, DATE_ADD(NOW(), INTERVAL 2 DAY), 'Revisión por inapetencia', 'Pendiente'),
(3, 3, 6, DATE_ADD(NOW(), INTERVAL 3 DAY), 'Chequeo post-quirúrgico', 'Pendiente');


-- ==============================================================================
-- 3. PROCEDIMIENTOS ALMACENADOS
-- ==============================================================================

DELIMITER $$

-- 1. listar_citas_pendientes()
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

-- 2. mascotas_por_especie(IN p_especie)
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

-- 3. registrar_nueva_mascota(IN p_nombre, IN p_especie, IN p_id_dueno)
DROP PROCEDURE IF EXISTS `registrar_nueva_mascota`$$
CREATE PROCEDURE `registrar_nueva_mascota`(
    IN p_nombre VARCHAR(100),
    IN p_especie VARCHAR(50),
    IN p_id_dueno INT
)
BEGIN
    DECLARE v_id_especie INT;
    
    IF p_especie REGEXP '^[0-9]+$' THEN
        SET v_id_especie = CAST(p_especie AS UNSIGNED);
    ELSE
        SELECT ID_Especie INTO v_id_especie 
        FROM especie 
        WHERE LOWER(Tipo_Especie) = LOWER(p_especie) 
        LIMIT 1;
        
        IF v_id_especie IS NULL THEN
            INSERT INTO especie (Tipo_Especie) VALUES (p_especie);
            SET v_id_especie = LAST_INSERT_ID();
        END IF;
    END IF;
    
    INSERT INTO mascotas (Nombre, ID_Especie, ID_Tercero)
    VALUES (p_nombre, v_id_especie, p_id_dueno);
END$$

-- 4. calcular_deuda_cliente(IN p_id_cliente, OUT p_total_deuda)
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

-- 5. aplicar_descuento_vacuna(INOUT p_precio_vacuna, IN p_descuento_promo)
DROP PROCEDURE IF EXISTS `aplicar_descuento_vacuna`$$
CREATE PROCEDURE `aplicar_descuento_vacuna`(
    INOUT p_precio_vacuna DECIMAL(10,2),
    IN p_descuento_promo DECIMAL(5,2)
)
BEGIN
    SET p_precio_vacuna = p_precio_vacuna - (p_precio_vacuna * (p_descuento_promo / 100));
END$$

-- 6. atender_cita(IN p_id_cita, IN p_diagnostico, OUT p_estado_final)
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

-- Procedimiento adicional previo: aumentar_precios_categoria
DROP PROCEDURE IF EXISTS `aumentar_precios_categoria`$$
CREATE PROCEDURE `aumentar_precios_categoria`(
    IN p_id_categoria INT,
    IN p_porcentaje DECIMAL(5,2)
)
BEGIN
    UPDATE medicamentos
    SET Precio = Precio + (Precio * (p_porcentaje / 100))
    WHERE ID_Categoria = p_id_categoria;
END$$


-- ==============================================================================
-- 4. TRIGGERS
-- ==============================================================================

-- Trigger: trg_validar_fecha_cita (BEFORE INSERT en Citas)
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

-- Trigger: trg_sumar_deuda_cliente (AFTER INSERT en Tratamientos)
DROP TRIGGER IF EXISTS `trg_sumar_deuda_cliente`$$
CREATE TRIGGER `trg_sumar_deuda_cliente`
AFTER INSERT ON `tratamientos`
FOR EACH ROW
BEGIN
    DECLARE v_id_dueno INT;

    SELECT ID_Tercero INTO v_id_dueno
    FROM mascotas
    WHERE ID_Mascotas = NEW.ID_Mascota;

    UPDATE terceros
    SET Total_Deuda = Total_Deuda + NEW.Costo
    WHERE ID_Tercero = v_id_dueno;
END$$

-- Triggers preexistentes de inventario y auditoría
DROP TRIGGER IF EXISTS `trg_validar_precio_consulta_detalle`$$
CREATE TRIGGER `trg_validar_precio_consulta_detalle`
BEFORE INSERT ON `consulta_detalle`
FOR EACH ROW
BEGIN
    IF NEW.Precio_Unitario < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Negocio: El precio unitario no puede ser negativo.';
    END IF;

    IF NEW.Cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Negocio: La cantidad ingresada debe ser mayor a cero.';
    END IF;

    SET NEW.Subtotal = NEW.Cantidad * NEW.Precio_Unitario;
END$$

DROP TRIGGER IF EXISTS `trg_descontar_stock_consulta`$$
CREATE TRIGGER `trg_descontar_stock_consulta`
AFTER INSERT ON `consulta_detalle`
FOR EACH ROW
BEGIN
    UPDATE `medicamentos`
    SET `Stock` = `Stock` - NEW.Cantidad
    WHERE `ID_Medicamentos` = NEW.ID_Medicamento;

    UPDATE `consultas`
    SET `Total` = `Total` + NEW.Subtotal
    WHERE `ID_Consultas` = NEW.ID_Consulta;
END$$

DROP TRIGGER IF EXISTS `trg_auditoria_stock_medicamentos`$$
CREATE TRIGGER `trg_auditoria_stock_medicamentos`
AFTER UPDATE ON `medicamentos`
FOR EACH ROW
BEGIN
    IF OLD.Stock <> NEW.Stock THEN
        INSERT INTO `auditoria_medicamentos` (`ID_Medicamento`,`Accion`,`Stock_Anterior`,`Stock_Nuevo`,`Usuario`,`Fecha_Hora`,`Detalle`)
        VALUES (
            OLD.ID_Medicamentos,
            'UPDATE',
            OLD.Stock,
            NEW.Stock,
            CURRENT_USER(),
            NOW(),
            CONCAT('Modificación de stock para: ', OLD.Nombre)
        );
    END IF;
END$$

DROP TRIGGER IF EXISTS `trg_auditoria_eliminar_medicamentos`$$
CREATE TRIGGER `trg_auditoria_eliminar_medicamentos`
AFTER DELETE ON `medicamentos`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_medicamentos` (`ID_Medicamento`, `Accion`,`Stock_Anterior`,`Stock_Nuevo`,`Usuario`,`Fecha_Hora`,`Detalle`)
    VALUES (
        OLD.ID_Medicamentos,
        'DELETE',
        OLD.Stock,
        NULL,
        CURRENT_USER(),
        NOW(),
        CONCAT('Medicamento eliminado del catálogo: ', OLD.Nombre)
    );
END$$

DELIMITER ;
