# Informe Técnico: Base de Datos Veterinaria Patitas

## 1. Descripción del Proyecto
Este proyecto implementa el diseño, construcción y programación de una base de datos relacional para la gestión clínica de la Veterinaria Patitas. La arquitectura garantiza la integridad de la información y automatiza procesos críticos mediante el uso de Triggers (Disparadores).

## 2. Estructura de la Base de Datos
La base de datos se encuentra normalizada y consta de 8 tablas interrelacionadas:
- **Entidades de actores:** `duenos`, `veterinarios`, `mascotas`, `especie`.
- **Entidades de proceso clínico:** `consultas`, `consulta_detalle`, `medicamentos`.
- **Entidad de control (Auditoría):** `auditoria_stock`.

## 3. Lógica de los Triggers Implementados

Para satisfacer las reglas de negocio y los requisitos de calidad del sistema, se desarrollaron 3 Triggers estratégicos:

### A. Trigger de Validación (Regla de Negocio)
- **Nombre:** `tr_validar_precio_insert`
- **Tabla y Evento:** `consulta_detalle` (BEFORE INSERT)
- **Lógica:** Protege la integridad financiera de la veterinaria comprobando que el `Precio_Unitario` no sea un valor negativo antes de permitir el registro del detalle de la consulta. Si se detecta un valor < 0, la base de datos aborta la operación emitiendo un error (`SIGNAL SQLSTATE '45000'`).

### B. Trigger de Automatización (Descuento de Inventario)
- **Nombre:** `tr_descontar_stock`
- **Tabla y Evento:** `consulta_detalle` (AFTER INSERT)
- **Lógica:** Conecta el área de consultas con la de farmacia. Cada vez que se receta un medicamento (insertando una fila en `consulta_detalle`), el trigger toma la cantidad recetada (`NEW.Cantidad`) y automáticamente ejecuta un UPDATE en la tabla `medicamentos`, restando esa cantidad del stock disponible.

### C. Trigger de Auditoría (Historial)
- **Nombre:** `tr_auditoria_stock`
- **Tabla y Evento:** `medicamentos` (AFTER UPDATE)
- **Lógica:** Funciona como un historial de vigilancia sobre el inventario. Se dispara inmediatamente después de que el trigger anterior (o cualquier usuario manual) modifica el stock de un medicamento. Captura en la tabla de auditoría el ID del medicamento afectado, el stock original (`OLD.Stock`), el nuevo stock (`NEW.Stock`), y registra al responsable de la base de datos que desencadenó el cambio mediante la función `CURRENT_USER()`.

## 4. Pruebas y Validación (DML)
Se incluyen en la carpeta `/dml` los scripts correspondientes para:
1. Población de las tablas con registros reales.
2. Sentencias `SELECT` con `INNER JOIN` para validar la correcta relación de las llaves primarias y foráneas de manera bidireccional en el esquema relacional.
