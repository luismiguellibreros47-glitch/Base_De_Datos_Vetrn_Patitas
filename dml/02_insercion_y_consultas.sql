-- DML: Inserción de datos reales y consultas de validación
USE `veterinariapatitas11`;

-- 1. Inserción de Datos (Registros Reales)

INSERT IGNORE INTO `duenos` (`ID_Dueno`, `Nombre`, `Cedula`, `Correo`, `Direccion`, `Contacto`) VALUES
(1, 'Luis Miguel Libreros', '111222', 'luis@mail.com', 'Calle 10 Cartago', '310123'),
(2, 'Ana Maria Gomez', '333444', 'ana@mail.com', 'Cra 4 Obando', '311456'),
(3, 'Santiago Rodriguez', '555666', 'santi@mail.com', 'Av Central', '312789'),
(4, 'Laura Restrepo', '777888', 'laura@mail.com', 'Calle 8 Pereira', '313012');

INSERT IGNORE INTO `especie` (`ID_Especie`, `Tipo_Especie`) VALUES
(1, 'Perro'), (2, 'Gato'), (3, 'Loro'), (4, 'Conejo'), (5, 'Hamster');

INSERT IGNORE INTO `mascotas` (`ID_Mascota`, `ID_Dueno`, `ID_Especie`, `Nombre`) VALUES
(1, 1, 1, 'Rex'), (2, 2, 2, 'Michi'), (3, 3, 3, 'Pico');

INSERT IGNORE INTO `veterinarios` (`ID_Veterinario`, `Nombre`, `Direccion`, `Contacto`, `Correo`) VALUES
(1, 'Dr. Ricardo Gomez', 'Sede Norte - Calle 20', '3001112233', 'rgomez@patitas.com'),
(2, 'Dra. Elena Ortiz', 'Sede Sur - Carrera 5', '3004445566', 'eortiz@patitas.com');

INSERT IGNORE INTO `medicamentos` (`ID_Medicamento`, `Nombre`, `Descripcion`, `Stock`) VALUES
(1, 'Amoxicilina', 'Antibiótico de amplio espectro', 50),
(2, 'Meloxicam', 'Analgésico y antiinflamatorio', 50);

INSERT IGNORE INTO `consultas` (`ID_Consulta`, `ID_Mascota`, `ID_Veterinario`, `Fecha`, `Descripcion`) VALUES
(6, 1, 1, '2026-04-17 01:43:31', 'Control de vacuna anual'),
(7, 2, 2, '2026-04-17 01:43:31', 'Limpieza dental profunda');

INSERT IGNORE INTO `consulta_detalle` (`ID_Consulta_Detalle`, `ID_Consulta`, `ID_Medicamento`, `Cantidad`, `Precio_Unitario`, `Subtotal`) VALUES
(6, 6, 1, 1, 15000.00, 15000.00),
(7, 7, 2, 2, 12000.00, 24000.00);

-- 2. Consultas SELECT para Validación (JOINs)

-- A. Relación de Mascotas con sus Dueños y Especie
SELECT 
    m.Nombre AS Nombre_Mascota, 
    e.Tipo_Especie AS Especie, 
    d.Nombre AS Nombre_Dueno, 
    d.Contacto AS Telefono_Dueno
FROM mascotas m
JOIN duenos d ON m.ID_Dueno = d.ID_Dueno
JOIN especie e ON m.ID_Especie = e.ID_Especie;

-- B. Relación de Consultas con Mascotas y Veterinarios
SELECT 
    c.ID_Consulta, 
    DATE_FORMAT(c.Fecha, '%Y-%m-%d') AS Fecha, 
    m.Nombre AS Paciente_Mascota, 
    v.Nombre AS Veterinario_Atiende, 
    c.Descripcion AS Motivo_Consulta
FROM consultas c
JOIN mascotas m ON c.ID_Mascota = m.ID_Mascota
JOIN veterinarios v ON c.ID_Veterinario = v.ID_Veterinario;

-- C. Auditoría y Relación de Detalles de Consulta
SELECT 
    cd.ID_Consulta,
    c.Descripcion AS Motivo_Consulta,
    med.Nombre AS Medicamento_Recetado,
    cd.Cantidad,
    cd.Precio_Unitario
FROM consulta_detalle cd
JOIN consultas c ON cd.ID_Consulta = c.ID_Consulta
JOIN medicamentos med ON cd.ID_Medicamento = med.ID_Medicamento;
