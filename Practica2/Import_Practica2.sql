-- ============================================================
-- PRACTICA 2 - Script de importacion de datos
-- Generado a partir de Dataset_Practica2.xlsx
-- Ejecutar como Script (F5) sobre la conexion 'practica2'
-- Respeta el orden de dependencia de llaves foraneas.
-- ============================================================

-- 1. sector_economico
INSERT INTO sector_economico (id_sector, nombre) VALUES (1, 'Industria');
INSERT INTO sector_economico (id_sector, nombre) VALUES (2, 'Servicios');
INSERT INTO sector_economico (id_sector, nombre) VALUES (3, 'Comercio');
INSERT INTO sector_economico (id_sector, nombre) VALUES (4, 'Tecnología');
INSERT INTO sector_economico (id_sector, nombre) VALUES (5, 'Agricultura y Agroindustria');

-- 2. departamento
INSERT INTO departamento (id_departamento, nombre) VALUES (1, 'Guatemala');
INSERT INTO departamento (id_departamento, nombre) VALUES (2, 'Sacatepéquez');
INSERT INTO departamento (id_departamento, nombre) VALUES (3, 'Quetzaltenango');
INSERT INTO departamento (id_departamento, nombre) VALUES (4, 'Escuintla');

-- 3. estado_colocacion
INSERT INTO estado_colocacion (id_estado, nombre) VALUES (1, 'Activa');
INSERT INTO estado_colocacion (id_estado, nombre) VALUES (2, 'Finalizada');
INSERT INTO estado_colocacion (id_estado, nombre) VALUES (3, 'Cancelada');

-- 4. tipo_evaluacion
INSERT INTO tipo_evaluacion (id_tipo_evaluacion, nombre) VALUES (1, 'Parcial');
INSERT INTO tipo_evaluacion (id_tipo_evaluacion, nombre) VALUES (2, 'Final');

-- 5. criterio
INSERT INTO criterio (id_criterio, nombre) VALUES (1, 'Puntualidad y Asistencia');
INSERT INTO criterio (id_criterio, nombre) VALUES (2, 'Calidad del Trabajo');
INSERT INTO criterio (id_criterio, nombre) VALUES (3, 'Actitud y Proactividad');
INSERT INTO criterio (id_criterio, nombre) VALUES (4, 'Dominio Técnico');
INSERT INTO criterio (id_criterio, nombre) VALUES (5, 'Trabajo en Equipo');

-- 6. instituto
INSERT INTO instituto (id_instituto, nombre, direccion, codigo_autorizacion) VALUES (1, 'Instituto Técnico de Computación (ITC)', 'Zona 1 Guatemala', 'MINEDUC-001A');
INSERT INTO instituto (id_instituto, nombre, direccion, codigo_autorizacion) VALUES (2, 'Escuela Nacional Central Industrial (ENCI)', 'Zona 12 Guatemala', 'MINEDUC-002B');
INSERT INTO instituto (id_instituto, nombre, direccion, codigo_autorizacion) VALUES (3, 'Instituto Tecnológico del Sur', 'Zona 1 Escuintla', 'MINEDUC-003C');

-- 7. especialidad (catalogo propio: valores unicos tomados de
--    PLAZA.ESPECIALIDAD_TECNICA + CATEDRATICO.ESPECIALIDAD + ESTUDIANTE.CARRERA_TECNICA)
INSERT INTO especialidad (id_especialidad, nombre) VALUES (1, 'Desarrollo de Software Web');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (2, 'Soporte de Infraestructura de Redes');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (3, 'Mantenimiento Eléctrico Industrial');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (4, 'Asistente Contable y Auditoría');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (5, 'Mantenimiento de Maquinaria Agrícola');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (6, 'Analista de Datos Trainee');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (7, 'Desarrollador Backend Junior');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (8, 'Ingeniería en Sistemas');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (9, 'Electricidad Industrial');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (10, 'Ciencias Económicas');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (11, 'Mecánica Automotriz e Industrial');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (12, 'Ciencias de la Computación');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (13, 'Perito en Computación');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (14, 'Perito en Electrónica');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (15, 'Perito Contador');
INSERT INTO especialidad (id_especialidad, nombre) VALUES (16, 'Perito en Mecánica');

-- 8. municipio
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (1, 'Guatemala', 1);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (2, 'Villa Nueva', 1);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (3, 'Mixco', 1);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (4, 'Antigua Guatemala', 2);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (5, 'Quetzaltenango', 3);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (6, 'Escuintla', 4);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (7, 'Palín', 4);
INSERT INTO municipio (id_municipio, nombre, departamento_id) VALUES (8, 'Santa Lucía Cotzumalguapa', 4);

-- 9. empresa
INSERT INTO empresa (id_empresa, nombre, direccion, sector_id) VALUES (1, 'TechNova Solutions', 'Km 15 Carretera a El Salvador', 4);
INSERT INTO empresa (id_empresa, nombre, direccion, sector_id) VALUES (2, 'Industrias La Aurora', 'Zona 4 de Mixco', 1);
INSERT INTO empresa (id_empresa, nombre, direccion, sector_id) VALUES (3, 'Servicios Contables GT', 'Zona 10 Guatemala', 2);
INSERT INTO empresa (id_empresa, nombre, direccion, sector_id) VALUES (4, 'Agropecuaria El Sol', 'Km 50 Autopista Palín-Escuintla', 5);
INSERT INTO empresa (id_empresa, nombre, direccion, sector_id) VALUES (5, 'FinTech Guatemala', 'Zona 15 Edificio Avante', 4);

-- 10. contacto
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (1, 'Ana Morales', '55551111', 'ana.morales@technova.gt', 1);
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (2, 'Carlos Fuentes', '55552222', 'cfuentes@aurora.com', 2);
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (3, 'Lucía Méndez', '55553333', 'lmendez@serviciosgt.com', 3);
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (4, 'Jorge Cifuentes', '55554444', 'jcifuentes@technova.gt', 1);
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (5, 'Sofía Valdez', '55556666', 'svaldez@agroelsol.com', 4);
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (6, 'Mario Pineda', '55557777', 'mpineda@fintech.gt', 5);
INSERT INTO contacto (id_contacto, nombre, telefono, correo, empresa_id) VALUES (7, 'Diana Rosales', '55558888', 'drosales@fintech.gt', 5);

-- 11. catedratico (especialidad_id resuelto via el catalogo generado arriba)
INSERT INTO catedratico (id_catedratico, identificacion, nombre, telefono, especialidad_id, instituto_id) VALUES (1, '2500123450101', 'Julio César Pérez', '44441111', 8, 1);
INSERT INTO catedratico (id_catedratico, identificacion, nombre, telefono, especialidad_id, instituto_id) VALUES (2, '2600987650101', 'Marta Estrada', '44442222', 9, 2);
INSERT INTO catedratico (id_catedratico, identificacion, nombre, telefono, especialidad_id, instituto_id) VALUES (3, '2700555550101', 'Roberto Gómez', '44443333', 10, 1);
INSERT INTO catedratico (id_catedratico, identificacion, nombre, telefono, especialidad_id, instituto_id) VALUES (4, '2800111110101', 'Karen Reyes', '44445555', 11, 3);
INSERT INTO catedratico (id_catedratico, identificacion, nombre, telefono, especialidad_id, instituto_id) VALUES (5, '2900222220101', 'Luis Álvarez', '44446666', 12, 1);

-- 12. estudiante (PK=carnet, especialidad_id resuelto, primera_practica = 1 - es_repitencia)
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024001, 'Diego López', 'Zona 5 Guatemala', '33331111', TO_DATE('2005-04-12','YYYY-MM-DD'), 'M', 1, 13, 1, 1);
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024002, 'María Aguilar', 'Colonia El Milagro Mixco', '33332222', TO_DATE('2006-08-25','YYYY-MM-DD'), 'F', 1, 14, 3, 2);
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024003, 'Pedro Samayoa', 'Zona 4 Villa Nueva', '33333333', TO_DATE('2005-11-03','YYYY-MM-DD'), 'M', 0, 13, 2, 1);
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024004, 'Sara Pinzón', 'Zona 10 Guatemala', '33334444', TO_DATE('2006-01-15','YYYY-MM-DD'), 'F', 1, 15, 1, 1);
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024005, 'Fernando Cruz', 'Zona 1 Palín', '33335555', TO_DATE('2005-09-10','YYYY-MM-DD'), 'M', 1, 16, 7, 3);
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024006, 'Gabriela Soto', 'Zona 15 Guatemala', '33336666', TO_DATE('2006-03-22','YYYY-MM-DD'), 'F', 1, 13, 1, 1);
INSERT INTO estudiante (carnet, nombre_completo, direccion, telefono, fecha_nacimiento, genero, primera_practica, especialidad_id, municipio_id, instituto_id) VALUES (2024007, 'Andrés Barrios', 'Residenciales San José', '33337777', TO_DATE('2005-12-05','YYYY-MM-DD'), 'M', 1, 13, 2, 1);

-- 13. plaza (especialidad_id resuelto)
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (1, 1, 1, 1);
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (2, 2, 1, 4);
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (3, 3, 2, 2);
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (4, 4, 3, 3);
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (5, 5, 4, 5);
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (6, 6, 5, 6);
INSERT INTO plaza (id_plaza, especialidad_id, empresa_id, contacto_id) VALUES (7, 7, 5, 7);

-- 14. colocacion (activo derivado: '1' si estado = Activa (id 1), '0' en otro caso)
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (1, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_DATE('2026-08-30','YYYY-MM-DD'), 2024001, 1, 1, 1, '1');
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (2, TO_DATE('2026-07-15','YYYY-MM-DD'), TO_DATE('2026-09-15','YYYY-MM-DD'), 2024002, 3, 2, 1, '1');
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (3, TO_DATE('2025-01-10','YYYY-MM-DD'), TO_DATE('2025-03-10','YYYY-MM-DD'), 2024003, 2, 1, 2, '0');
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (4, TO_DATE('2026-08-01','YYYY-MM-DD'), NULL, 2024004, 4, 3, 1, '1');
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (5, TO_DATE('2026-08-01','YYYY-MM-DD'), NULL, 2024005, 5, 4, 1, '1');
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (6, TO_DATE('2026-07-01','YYYY-MM-DD'), TO_DATE('2026-08-10','YYYY-MM-DD'), 2024006, 6, 5, 2, '0');
INSERT INTO colocacion (id_colocacion, fecha_inicio, fecha_fin, estudiante_id, plaza_id, catedratico_id, estado_id, activo) VALUES (7, TO_DATE('2026-08-15','YYYY-MM-DD'), NULL, 2024007, 7, 5, 1, '1');

-- 15. bitacora
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (1, 1, TO_DATE('2026-07-01','YYYY-MM-DD'), 8, 'Configuración de entorno de desarrollo para el proyecto web', 'Ninguna', 1, 1);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (2, 2, TO_DATE('2026-07-02','YYYY-MM-DD'), 8, 'Desarrollo de módulo de autenticación de usuarios', 'Se requirió apoyo en DB', 1, 1);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (3, 1, TO_DATE('2026-07-15','YYYY-MM-DD'), 6, 'Revisión y mantenimiento de tableros eléctricos zona B', NULL, 2, 2);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (4, 2, TO_DATE('2026-07-16','YYYY-MM-DD'), 8, 'Cambio de fusibles de alta tensión', NULL, 2, 2);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (5, 1, TO_DATE('2026-08-01','YYYY-MM-DD'), 8, 'Revisión de tractores y calibración de motores', 'Todo en orden', 5, 5);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (6, 2, TO_DATE('2026-08-02','YYYY-MM-DD'), 8, 'Cambio de aceite y filtros en maquinaria pesada', 'Faltó repuesto del filtro de aire', 5, 5);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (7, 1, TO_DATE('2026-07-30','YYYY-MM-DD'), 8, 'Limpieza de base de datos de clientes', 'Uso de scripts SQL', 6, 6);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (8, 2, TO_DATE('2026-07-31','YYYY-MM-DD'), 8, 'Creación de dashboard en PowerBI', 'Terminado con éxito', 6, 6);
INSERT INTO bitacora (id_bitacora, correlativo, fecha, horas_trabajadas, actividades_realizadas, observaciones, colocacion_id, validado_por) VALUES (9, 1, TO_DATE('2026-08-15','YYYY-MM-DD'), 6, 'Inducción a la arquitectura del sistema y repositorios', NULL, 7, 7);

-- 16. evaluacion
INSERT INTO evaluacion (id_evaluacion, fecha, colocacion_id, catedratico_id, tipo_evaluacion_id) VALUES (1, TO_DATE('2026-07-16','YYYY-MM-DD'), 1, 1, 1);
INSERT INTO evaluacion (id_evaluacion, fecha, colocacion_id, catedratico_id, tipo_evaluacion_id) VALUES (2, TO_DATE('2025-03-10','YYYY-MM-DD'), 3, 1, 2);
INSERT INTO evaluacion (id_evaluacion, fecha, colocacion_id, catedratico_id, tipo_evaluacion_id) VALUES (3, TO_DATE('2026-07-30','YYYY-MM-DD'), 2, 2, 1);
INSERT INTO evaluacion (id_evaluacion, fecha, colocacion_id, catedratico_id, tipo_evaluacion_id) VALUES (4, TO_DATE('2026-08-10','YYYY-MM-DD'), 6, 5, 2);

-- 17. evaluacion_criterio
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (1, 1, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (1, 2, 4);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (1, 3, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (1, 4, 3);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (1, 5, 4);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (2, 1, 4);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (2, 2, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (2, 4, 4);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (3, 1, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (3, 2, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (3, 3, 4);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (3, 5, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (4, 1, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (4, 2, 4);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (4, 3, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (4, 4, 5);
INSERT INTO evaluacion_criterio (evaluacion_id, criterio_id, puntaje) VALUES (4, 5, 4);

COMMIT;

-- Limpieza: las columnas _temp ya no son necesarias porque este script
-- resolvio especialidad_id directamente. Puedes eliminarlas:
ALTER TABLE catedratico DROP COLUMN especialidad_temp;
ALTER TABLE plaza DROP COLUMN especialidad_temp;
ALTER TABLE estudiante DROP COLUMN carrera_temp;
ALTER TABLE estudiante DROP COLUMN es_repitencia_temp;