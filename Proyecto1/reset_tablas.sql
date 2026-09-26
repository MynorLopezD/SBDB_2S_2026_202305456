--------------------------------------------------------------------------------
-- Comercial La Estrella - Eliminacion de las 19 tablas (esquema estrella)
-- Uso: correr esto ANTES de volver a ejecutar 03_creacion_DB.sql, cuando se
-- quiere recrear el esquema desde cero sin borrar el usuario/conexion.
-- CASCADE CONSTRAINTS evita errores de FK aunque no se respete el orden;
-- PURGE libera el nombre de inmediato (no lo deja en la papelera de Oracle),
-- que es justo lo que evita el problema de "ORA-00955 nombre ya utilizado"
-- que tuvimos antes con un esquema compartido.
--------------------------------------------------------------------------------

DROP TABLE pago CASCADE CONSTRAINTS PURGE;
DROP TABLE detalle_venta CASCADE CONSTRAINTS PURGE;
DROP TABLE venta CASCADE CONSTRAINTS PURGE;
DROP TABLE catalogo_tienda_producto CASCADE CONSTRAINTS PURGE;
DROP TABLE producto CASCADE CONSTRAINTS PURGE;
DROP TABLE cliente CASCADE CONSTRAINTS PURGE;
DROP TABLE empleado CASCADE CONSTRAINTS PURGE;
DROP TABLE persona CASCADE CONSTRAINTS PURGE;
DROP TABLE tienda CASCADE CONSTRAINTS PURGE;
DROP TABLE metodo_pago CASCADE CONSTRAINTS PURGE;
DROP TABLE estado_venta CASCADE CONSTRAINTS PURGE;
DROP TABLE marca CASCADE CONSTRAINTS PURGE;
DROP TABLE categoria CASCADE CONSTRAINTS PURGE;
DROP TABLE cargo CASCADE CONSTRAINTS PURGE;
DROP TABLE tipo_identificacion CASCADE CONSTRAINTS PURGE;
DROP TABLE tipo_tienda CASCADE CONSTRAINTS PURGE;
DROP TABLE municipio CASCADE CONSTRAINTS PURGE;
DROP TABLE departamento CASCADE CONSTRAINTS PURGE;
DROP TABLE pais CASCADE CONSTRAINTS PURGE;