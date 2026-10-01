--------------------------------------
Vista_Historial_Clinico
--------------------------------------

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `vista_historial_clinico` AS
    SELECT 
        `t`.`Nombre` AS Nombre_Dueño,  -- seleccionamos los campos que queremos y le ponemos un nombre.
        m.Nombre AS Nombre_Mascota,
        MAX(c.Fecha) AS Fecha_Ultima_Cita  -- Devuelve la fecha más reciente de cada cita.
    FROM
        (((mascotas m
        JOIN terceros t ON ((m.ID_Tercero = t.ID_Tercero)))    -- hacemos los inner join necesarios.
        JOIN terceros_rol tr ON ((t.ID_Tercero = tr.ID_Tercero)))
        JOIN consultas c ON ((m.ID_Mascotas = c.ID_Mascotas)))   -- El mismo WorkBench quita la palabra INNER porque le es redudante, ya que son lo mismo (solo con el INNER pasa).
    WHERE
        (tr.ID_Rol = 1)  -- Filtramos solo los que tengan el id_rol = 1, o sea los que son los Dueños de las Mascotas.

    GROUP BY m.ID_Mascotas , t.Nombre , m.Nombre  -- Agrupamos las filas.



---------------------------------------
Función_Clasificar_Edad
---------------------------------------


DELIMITER //

CREATE DEFINER=`root`@`localhost` FUNCTION `funcion_clasificar_edad`(Edad_En_Meses INT) RETURNS varchar(40) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE Tipo_Edad VARCHAR(100);	
    
    if Edad_En_Meses < 0 THEN
    set Tipo_Edad = 'Edad invalida (El numero no puede ser Negativo)'; -- Primero validamos que la edad no sea negativa :/.
    
    Elseif Edad_En_Meses >= 0 and Edad_En_Meses <= 12 THEN
    set Tipo_Edad = 'Es un Cachorro';
    
    Elseif Edad_En_Meses > 12 and Edad_En_Meses <= 84 THEN
    set Tipo_Edad = 'Ya es Adulto';
    
    Else
     set Tipo_Edad = 'Esta Anciano :<';
	END IF;
     
	Return Tipo_Edad; 

END //

DELIMITER ;



-------------------------------------------------
Consulta con la mezcla de la Vista y la Función	
-------------------------------------------------

SELECT Nombre_Dueño, Nombre_Mascota, m.Meses_De_Edad, Fecha_Ultima_Cita, funcion_clasificar_edad(m.Meses_De_Edad) As Clasificacion
From vista_historial_clinico V INNER JOIN  mascotas m ON m.Nombre = V.Nombre_Mascota; 
-- Consulta que muestra la combinación de la vista
-- Más la función, agregando los Meses de Edad (Es un campo nuevo que se creo en Mascotas).



