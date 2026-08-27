-- DDL: Estructura de la Base de Datos y Triggers
-- Base de datos: veterinariapatitas11

CREATE DATABASE IF NOT EXISTS `veterinariapatitas11`;
USE `veterinariapatitas11`;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Tablas Principales
CREATE TABLE IF NOT EXISTS `duenos` (
  `ID_Dueno` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Cedula` varchar(20) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `Direccion` varchar(100) DEFAULT NULL,
  `Contacto` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID_Dueno`),
  UNIQUE KEY `Cedula` (`Cedula`),
  UNIQUE KEY `Correo` (`Correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `especie` (
  `ID_Especie` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo_Especie` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Especie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mascotas` (
  `ID_Mascota` int(11) NOT NULL AUTO_INCREMENT,
  `ID_Dueno` int(11) NOT NULL,
  `ID_Especie` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  PRIMARY KEY (`ID_Mascota`),
  CONSTRAINT `fk_mascota_dueno` FOREIGN KEY (`ID_Dueno`) REFERENCES `duenos` (`ID_Dueno`),
  CONSTRAINT `fk_mascota_especie` FOREIGN KEY (`ID_Especie`) REFERENCES `especie` (`ID_Especie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `veterinarios` (
  `ID_Veterinario` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Direccion` varchar(100) DEFAULT NULL,
  `Contacto` varchar(20) DEFAULT NULL,
  `Correo` varchar(100) NOT NULL,
  PRIMARY KEY (`ID_Veterinario`),
  UNIQUE KEY `Correo` (`Correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `medicamentos` (
  `ID_Medicamento` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` text DEFAULT NULL,
  `Stock` int(11) NOT NULL DEFAULT 50,
  PRIMARY KEY (`ID_Medicamento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `consultas` (
  `ID_Consulta` int(11) NOT NULL AUTO_INCREMENT,
  `ID_Mascota` int(11) NOT NULL,
  `ID_Veterinario` int(11) NOT NULL,
  `Fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `Descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`ID_Consulta`),
  CONSTRAINT `fk_consulta_mascota` FOREIGN KEY (`ID_Mascota`) REFERENCES `mascotas` (`ID_Mascota`),
  CONSTRAINT `fk_consulta_vet` FOREIGN KEY (`ID_Veterinario`) REFERENCES `veterinarios` (`ID_Veterinario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `consulta_detalle` (
  `ID_Consulta_Detalle` int(11) NOT NULL AUTO_INCREMENT,
  `ID_Consulta` int(11) NOT NULL,
  `ID_Medicamento` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Precio_Unitario` decimal(10,2) NOT NULL,
  `Subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ID_Consulta_Detalle`),
  CONSTRAINT `fk_detalle_consulta` FOREIGN KEY (`ID_Consulta`) REFERENCES `consultas` (`ID_Consulta`),
  CONSTRAINT `fk_detalle_med` FOREIGN KEY (`ID_Medicamento`) REFERENCES `medicamentos` (`ID_Medicamento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `auditoria_stock` (
  `id_auditoria` int(11) NOT NULL AUTO_INCREMENT,
  `id_medicamento` int(11) DEFAULT NULL,
  `stock_viejo` int(11) DEFAULT NULL,
  `stock_nuevo` int(11) DEFAULT NULL,
  `usuario_modifico` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- 2. Triggers (Reglas de Negocio y Auditoría)

DELIMITER $$

-- Trigger 1: Regla de Negocio (Validar precio negativo)
CREATE TRIGGER `tr_validar_precio_insert`
BEFORE INSERT ON `consulta_detalle`
FOR EACH ROW
BEGIN
    IF NEW.Precio_Unitario < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Violacion de regla de negocio: El precio unitario no puede ser negativo.';
    END IF;
END$$

-- Trigger 2: Automatizacion (Descontar Inventario)
CREATE TRIGGER `tr_descontar_stock`
AFTER INSERT ON `consulta_detalle`
FOR EACH ROW
BEGIN
    UPDATE `medicamentos`
    SET Stock = Stock - NEW.Cantidad
    WHERE ID_Medicamento = NEW.ID_Medicamento;
END$$

-- Trigger 3: Auditoría (Historial de Stock)
CREATE TRIGGER `tr_auditoria_stock`
AFTER UPDATE ON `medicamentos`
FOR EACH ROW
BEGIN
    INSERT INTO `auditoria_stock` 
    (`id_medicamento`, `stock_viejo`, `stock_nuevo`, `usuario_modifico`)
    VALUES 
    (OLD.ID_Medicamento, OLD.Stock, NEW.Stock, CURRENT_USER());
END$$

DELIMITER ;
