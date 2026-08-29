-- ============================================================
-- PRACTICA 2 - Reset de datos
-- Elimina todas las filas de las 17 tablas en orden INVERSO de
-- dependencia (primero las tablas hijas, al final los catalogos
-- base), para poder volver a correr Import_Practica2.sql sin
-- errores de llave duplicada ni de integridad referencial.
--
-- NOTA: esto NO elimina las tablas (DROP), solo su contenido.
-- La estructura (DDL_Practica2.sql) se mantiene intacta.
-- ============================================================

DELETE FROM evaluacion_criterio;
DELETE FROM evaluacion;
DELETE FROM bitacora;
DELETE FROM colocacion;
DELETE FROM plaza;
DELETE FROM estudiante;
DELETE FROM catedratico;
DELETE FROM contacto;
DELETE FROM empresa;
DELETE FROM municipio;
DELETE FROM especialidad;
DELETE FROM instituto;
DELETE FROM criterio;
DELETE FROM tipo_evaluacion;
DELETE FROM estado_colocacion;
DELETE FROM departamento;
DELETE FROM sector_economico;

COMMIT;