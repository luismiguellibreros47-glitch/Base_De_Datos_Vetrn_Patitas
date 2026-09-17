-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: veterinaria_patita
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `compras`
--

DROP TABLE IF EXISTS `compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras`
--

LOCK TABLES `compras` WRITE;
/*!40000 ALTER TABLE `compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consulta_detalle`
--

DROP TABLE IF EXISTS `consulta_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consulta_detalle`
--

LOCK TABLES `consulta_detalle` WRITE;
/*!40000 ALTER TABLE `consulta_detalle` DISABLE KEYS */;
INSERT INTO `consulta_detalle` VALUES (1,1,1,1,45000.00,45000.00),(2,1,3,1,15000.00,15000.00),(3,2,4,1,25000.00,25000.00),(4,2,2,3,5000.00,15000.00),(5,3,2,5,5000.00,25000.00),(6,5,3,2,15000.00,30000.00),(7,6,5,1,35000.00,35000.00);
/*!40000 ALTER TABLE `consulta_detalle` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `consulta_detalle_AFTER_INSERT` AFTER INSERT ON `consulta_detalle` FOR EACH ROW BEGIN
DECLARE v_id_dueno INT;

    -- Localizar el ID del cliente (dueño) cruzando las tablas consultas y mascotas
    SELECT m.ID_Tercero INTO v_id_dueno
    FROM consultas c
    INNER JOIN mascotas m ON c.ID_Mascotas = m.ID_Mascotas
    WHERE c.ID_Consultas = NEW.ID_Consulta;

    -- Actualizar el saldo adeudado sumando el subtotal del nuevo detalle ingresado
    UPDATE terceros
    SET Deuda_Total = Deuda_Total + NEW.Subtotal
    WHERE ID_Tercero = v_id_dueno;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `consultas`
--

DROP TABLE IF EXISTS `consultas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consultas` (
  `ID_Consultas` int NOT NULL AUTO_INCREMENT,
  `ID_Mascotas` int NOT NULL,
  `ID_Veterinario` int NOT NULL,
  `Fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Descripcion` varchar(200) DEFAULT NULL,
  `Total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `Estado` varchar(45) DEFAULT 'Pendiente',
  `Estado_Pago` varchar(45) DEFAULT 'Pendiente',
  PRIMARY KEY (`ID_Consultas`),
  KEY `ID_Mascotas` (`ID_Mascotas`),
  KEY `ID_Veterinario` (`ID_Veterinario`),
  CONSTRAINT `consultas_ibfk_1` FOREIGN KEY (`ID_Mascotas`) REFERENCES `mascotas` (`ID_Mascotas`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `consultas_ibfk_2` FOREIGN KEY (`ID_Veterinario`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consultas`
--

LOCK TABLES `consultas` WRITE;
/*!40000 ALTER TABLE `consultas` DISABLE KEYS */;
INSERT INTO `consultas` VALUES (1,1,6,'2026-09-10 00:59:48','Control general y vacunación anual.',60000.00,'Pendiente','Pendiente'),(2,2,7,'2026-09-10 00:59:48','Problemas digestivos, presenta vómito constante desde ayer.',40000.00,'Pendiente','Pendiente'),(3,3,6,'2026-09-10 00:59:48','Revisión por cojera en la pata delantera derecha tras una caída.',25000.00,'Pendiente','Pendiente'),(4,4,8,'2026-09-10 00:59:48','Corte de pico, uñas y revisión general de plumaje.',0.00,'Pendiente','Pendiente'),(5,5,7,'2026-09-10 00:59:48','Chequeo de rutina y desparasitación preventiva.',30000.00,'Pendiente','Pendiente'),(6,6,8,'2026-09-10 00:59:48','Consulta de urgencia por pérdida de apetito y letargo.',35000.00,'Pendiente','Pendiente');
/*!40000 ALTER TABLE `consultas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `consultas_BEFORE_INSERT` BEFORE INSERT ON `consultas` FOR EACH ROW BEGIN
	-- Se evalúa si la fecha ingresada es anterior a la fecha actual del sistema
    IF DATE(NEW.Fecha) < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error de Negocio: No se pueden registrar citas en fechas pasadas.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `detalle_compras`
--

DROP TABLE IF EXISTS `detalle_compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_compras`
--

LOCK TABLES `detalle_compras` WRITE;
/*!40000 ALTER TABLE `detalle_compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalle_compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `especie`
--

DROP TABLE IF EXISTS `especie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `especie` (
  `ID_Especie` int NOT NULL AUTO_INCREMENT,
  `Tipo_Especie` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Especie`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `especie`
--

LOCK TABLES `especie` WRITE;
/*!40000 ALTER TABLE `especie` DISABLE KEYS */;
INSERT INTO `especie` VALUES (1,'Canino'),(2,'Felino'),(3,'Ave'),(4,'Roedor'),(5,'Reptil');
/*!40000 ALTER TABLE `especie` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mascotas`
--

DROP TABLE IF EXISTS `mascotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mascotas`
--

LOCK TABLES `mascotas` WRITE;
/*!40000 ALTER TABLE `mascotas` DISABLE KEYS */;
INSERT INTO `mascotas` VALUES (1,1,1,'Max'),(2,1,2,'Luna'),(3,2,1,'Rocky'),(4,3,3,'Paco'),(5,4,2,'Simba'),(6,5,4,'Copo');
/*!40000 ALTER TABLE `mascotas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medicamentos`
--

DROP TABLE IF EXISTS `medicamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicamentos` (
  `ID_Medicamentos` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` text,
  `Stock` int NOT NULL DEFAULT '50',
  `Estado` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID_Medicamentos`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicamentos`
--

LOCK TABLES `medicamentos` WRITE;
/*!40000 ALTER TABLE `medicamentos` DISABLE KEYS */;
INSERT INTO `medicamentos` VALUES (1,'Vacuna Séxtuple','Inmunización contra moquillo, parvovirus, hepatitis, adenovirus, parainfluenza y leptospira.',50,1),(2,'Meloxicam 1mg','Antiinflamatorio no esteroideo para el control del dolor y la inflamación.',50,1),(3,'Desparasitante Interno','Tableta masticable de amplio espectro contra nematodos y cestodos.',50,1),(4,'Antiemético Inyectable','Control de náuseas y vómitos agudos en perros y gatos.',50,1),(5,'Suplemento Vitamínico','Gotas multivitamínicas para aves, roedores y reptiles.',50,1);
/*!40000 ALTER TABLE `medicamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `ID_Rol` int NOT NULL AUTO_INCREMENT,
  `Nombre_Rol` varchar(50) NOT NULL,
  PRIMARY KEY (`ID_Rol`),
  UNIQUE KEY `Nombre_Rol` (`Nombre_Rol`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Dueño'),(3,'Proveedor'),(2,'Veterinario');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terceros`
--

DROP TABLE IF EXISTS `terceros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `terceros` (
  `ID_Tercero` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Cedula` varchar(100) NOT NULL,
  `Correo` varchar(100) NOT NULL,
  `Direccion` varchar(100) NOT NULL,
  `Contacto` varchar(100) NOT NULL,
  `Estado` tinyint NOT NULL DEFAULT '1',
  `Deuda_Total` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`ID_Tercero`),
  UNIQUE KEY `Cedula` (`Cedula`),
  UNIQUE KEY `Correo` (`Correo`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terceros`
--

LOCK TABLES `terceros` WRITE;
/*!40000 ALTER TABLE `terceros` DISABLE KEYS */;
INSERT INTO `terceros` VALUES (1,'Carlos Alberto Ramírez','1088123456','carlos.ramirez@email.com','Calle 10 # 4-56, Cartago','3101234567',1,0.00),(2,'María Fernanda López','1004987654','mafe.lopez@email.com','Cra 5 # 14-23, Cartago','3129876543',1,0.00),(3,'Andrés Felipe Gómez','1111222333','andres.gomez@email.com','Barrio El Prado, Cartago','3005554433',1,0.00),(4,'Laura Sofía Martínez','1088555666','laura.martinez@email.com','Av. Santa Ana # 8-12, Cartago','3157778899',1,0.00),(5,'Jorge Hernán Pérez','1002333444','jorge.perez@email.com','Calle 20 # 6-10, Cartago','3201112233',1,0.00),(6,'Dr. Alejandro Ruiz','2000000001','aruiz.vet@email.com','Centro Veterinario Salud Animal','3145558899',1,0.00),(7,'Dra. Camila Torres','2000000002','ctorres.vet@email.com','Clínica Veterinaria Huellitas','3187776655',1,0.00),(8,'Dr. Sebastián Castro','2000000003','scastro.vet@email.com','Hospital Veterinario Central','3214445566',1,0.00);
/*!40000 ALTER TABLE `terceros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `terceros_rol`
--

DROP TABLE IF EXISTS `terceros_rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `terceros_rol` (
  `ID_Tercero` int NOT NULL,
  `ID_Rol` int NOT NULL,
  PRIMARY KEY (`ID_Tercero`,`ID_Rol`),
  KEY `ID_Rol` (`ID_Rol`),
  CONSTRAINT `terceros_rol_ibfk_1` FOREIGN KEY (`ID_Tercero`) REFERENCES `terceros` (`ID_Tercero`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `terceros_rol_ibfk_2` FOREIGN KEY (`ID_Rol`) REFERENCES `roles` (`ID_Rol`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `terceros_rol`
--

LOCK TABLES `terceros_rol` WRITE;
/*!40000 ALTER TABLE `terceros_rol` DISABLE KEYS */;
INSERT INTO `terceros_rol` VALUES (1,1),(2,1),(3,1),(4,1),(5,1),(6,2),(7,2),(8,2);
/*!40000 ALTER TABLE `terceros_rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'veterinaria_patita'
--

--
-- Dumping routines for database 'veterinaria_patita'
--
/*!50003 DROP PROCEDURE IF EXISTS `aplicar_descuento_vacuna` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `aplicar_descuento_vacuna`(INOUT p_precio_vacuna DECIMAL(10,2),IN p_descuento_promo DECIMAL(5,2))
BEGIN
	SET p_precio_vacuna = p_precio_vacuna - (p_precio_vacuna * (p_descuento_promo / 100));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `atender_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `atender_cita`(IN p_id_cita INT,IN p_diagnostico VARCHAR(200),OUT p_estado_final VARCHAR(100))
BEGIN
	DECLARE v_existe INT DEFAULT 0;
   
    SELECT COUNT(*) INTO v_existe 
    FROM consultas 
    WHERE ID_Consultas = p_id_cita;

    IF v_existe > 0 THEN
        UPDATE consultas 
        SET Descripcion = p_diagnostico,
            Estado = 'Atendido'
        WHERE ID_Consultas = p_id_cita;
        
        SET p_estado_final = 'Operación exitosa: Cita actualizada y marcada como Atendida.';
    ELSE
        SET p_estado_final = 'Error: No se encontró una cita con el ID proporcionado.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `calcular_deuda_cliente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `calcular_deuda_cliente`(IN p_id_cliente INT, OUT p_total_deuda DECIMAL(10,2))
BEGIN
	SELECT SUM(c.Total) INTO p_total_deuda
    FROM consultas c
    INNER JOIN mascotas m ON c.ID_Mascotas = m.ID_Mascotas
    WHERE m.ID_Tercero = p_id_cliente 
      AND c.Estado_Pago = 'Pendiente';

    IF p_total_deuda IS NULL THEN
        SET p_total_deuda = 0.00;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `listar_citas_pendientes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_citas_pendientes`()
BEGIN
	SELECT 
	m.Nombre AS Nombre_Mascota, 
	t.Nombre AS Nombre_Dueno, 
	c.Fecha AS Fecha_Cita
    FROM consultas c
    INNER JOIN mascotas m ON c.ID_Mascotas = m.ID_Mascotas
    INNER JOIN terceros t ON m.ID_Tercero = t.ID_Tercero
    WHERE c.Estado = 'Pendiente';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `mascotas_por_especie` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `mascotas_por_especie`(IN p_especie VARCHAR(50))
BEGIN
	SELECT 
	m.Nombre AS Nombre_Mascota,
	t.Nombre AS Nombre_Dueno,
	e.Tipo_Especie
    FROM mascotas m
    INNER JOIN especie e ON m.ID_Especie = e.ID_Especie
    INNER JOIN terceros t ON m.ID_Tercero = t.ID_Tercero
    WHERE e.Tipo_Especie = p_especie;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `registrar_nueva_mascota` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_nueva_mascota`(IN p_nombre VARCHAR(100),IN p_especie VARCHAR(50),IN p_id_dueno INT)
BEGIN
	DECLARE v_id_especie INT;

    
    SELECT ID_Especie INTO v_id_especie 
    FROM especie 
    WHERE Tipo_Especie = p_especie 
    LIMIT 1; -- Estringe el resultado de una consulta y devuelve como máximo un solo registro

    
    IF v_id_especie IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La especie indicada no se encuentra registrada.';
    ELSE

        INSERT INTO mascotas (ID_Tercero, ID_Especie, Nombre) 
        VALUES (p_id_dueno, v_id_especie, p_nombre);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-17 10:17:31
