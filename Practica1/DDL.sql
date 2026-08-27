-- ============================================================
-- Sistema de Control del Programa de Practicas Profesionales
-- Supervisadas (EPS)
-- Generado con Oracle SQL Developer Data Modeler 24.3.1
-- Corregido manualmente: tamanos de VARCHAR2 faltantes,
-- nombres de constraint > 30 caracteres, nulabilidad segun
-- diccionario de datos, CHECK constraints e indices unicos
-- funcionales para reglas de negocio.
-- ============================================================

-- ------------------------------------------------------------
-- TABLAS
-- ------------------------------------------------------------

CREATE TABLE empresa (
    id_empresa       INTEGER NOT NULL,
    nombre           VARCHAR2(150) NOT NULL,
    direccion        VARCHAR2(200) NOT NULL,
    sector_economico VARCHAR2(20) NOT NULL
);

ALTER TABLE empresa ADD CONSTRAINT empresa_pk PRIMARY KEY ( id_empresa );

CREATE TABLE especialidad (
    id_especialidad INTEGER NOT NULL,
    nombre          VARCHAR2(100) NOT NULL
);

ALTER TABLE especialidad ADD CONSTRAINT especialidad_pk PRIMARY KEY ( id_especialidad );

CREATE TABLE instituto (
    id_instituto        INTEGER NOT NULL,
    nombre              VARCHAR2(150) NOT NULL,
    direccion           VARCHAR2(200) NOT NULL,
    codigo_autorizacion VARCHAR2(30) NOT NULL
);

ALTER TABLE instituto ADD CONSTRAINT instituto_pk PRIMARY KEY ( id_instituto );

CREATE TABLE criterio (
    id_criterio INTEGER NOT NULL,
    nombre      VARCHAR2(100) NOT NULL
);

ALTER TABLE criterio ADD CONSTRAINT criterio_pk PRIMARY KEY ( id_criterio );

CREATE TABLE contacto (
    id_contacto        INTEGER NOT NULL,
    nombre             VARCHAR2(150) NOT NULL,
    telefono           VARCHAR2(20) NOT NULL,
    correo             VARCHAR2(100) NOT NULL,
    empresa_id_empresa INTEGER NOT NULL
);

ALTER TABLE contacto ADD CONSTRAINT contacto_pk PRIMARY KEY ( id_contacto );

CREATE TABLE catedratico (
    id_catedratico               INTEGER NOT NULL,
    nombre                       VARCHAR2(150) NOT NULL,
    identificacion               VARCHAR2(20) NOT NULL,
    telefono                     VARCHAR2(20) NOT NULL,
    especialidad_id_especialidad INTEGER NOT NULL,
    instituto_id_instituto       INTEGER NOT NULL
);

ALTER TABLE catedratico ADD CONSTRAINT catedratico_pk PRIMARY KEY ( id_catedratico );

CREATE TABLE estudiante (
    id_estudiante                INTEGER NOT NULL,
    nombre_completo              VARCHAR2(150) NOT NULL,
    carnet                       VARCHAR2(20) NOT NULL,
    direccion                    VARCHAR2(200) NOT NULL,
    telefono                     VARCHAR2(20) NOT NULL,
    fecha_nacimiento             DATE NOT NULL,
    genero                       VARCHAR2(1) NOT NULL,
    departamento_residencia      VARCHAR2(150) NOT NULL,
    municipio_residencia         VARCHAR2(50) NOT NULL,
    primera_practica             NUMBER(1) NOT NULL,
    especialidad_id_especialidad INTEGER NOT NULL,
    instituto_id_instituto       INTEGER NOT NULL
);

ALTER TABLE estudiante ADD CONSTRAINT estudiante_pk PRIMARY KEY ( id_estudiante );

CREATE TABLE plaza (
    id_plaza                     INTEGER NOT NULL,
    especialidad_id_especialidad INTEGER NOT NULL,
    empresa_id_empresa           INTEGER NOT NULL,
    contacto_id_contacto         INTEGER NOT NULL
);

ALTER TABLE plaza ADD CONSTRAINT plaza_pk PRIMARY KEY ( id_plaza );

CREATE TABLE colocacion (
    id_colocacion              INTEGER NOT NULL,
    fecha_inicio               DATE NOT NULL,
    fecha_fin                  DATE,
    estado                     VARCHAR2(15) NOT NULL,
    activo                     CHAR(1) NOT NULL,
    estudiante_id_estudiante   INTEGER NOT NULL,
    plaza_id_plaza             INTEGER NOT NULL,
    catedratico_id_catedratico INTEGER NOT NULL
);

ALTER TABLE colocacion ADD CONSTRAINT colocacion_pk PRIMARY KEY ( id_colocacion );

CREATE TABLE bitacora (
    id_bitacora              INTEGER NOT NULL,
    correlativo              INTEGER NOT NULL,
    fecha                    DATE NOT NULL,
    horas_trabajadas         NUMBER(4, 2) NOT NULL,
    actividades_realizadas   VARCHAR2(1000) NOT NULL,
    observaciones            VARCHAR2(500),
    colocacion_id_colocacion INTEGER NOT NULL,
    contacto_id_contacto     INTEGER NOT NULL
);

ALTER TABLE bitacora ADD CONSTRAINT bitacora_pk PRIMARY KEY ( id_bitacora );

CREATE TABLE evaluacion (
    id_evaluacion              INTEGER NOT NULL,
    horas                      INTEGER NOT NULL,
    fecha                      DATE NOT NULL,
    colocacion_id_colocacion   INTEGER NOT NULL,
    catedratico_id_catedratico INTEGER NOT NULL
);

ALTER TABLE evaluacion ADD CONSTRAINT evaluacion_pk PRIMARY KEY ( id_evaluacion );

CREATE TABLE evaluacion_criterio (
    puntaje                  INTEGER NOT NULL,
    evaluacion_id_evaluacion INTEGER NOT NULL,
    criterio_id_criterio     INTEGER NOT NULL
);

ALTER TABLE evaluacion_criterio ADD CONSTRAINT evaluacion_criterio_pk
    PRIMARY KEY ( evaluacion_id_evaluacion, criterio_id_criterio );

-- ------------------------------------------------------------
-- LLAVES FORANEAS
-- ------------------------------------------------------------

ALTER TABLE contacto
    ADD CONSTRAINT contacto_empresa_fk FOREIGN KEY ( empresa_id_empresa )
        REFERENCES empresa ( id_empresa );

ALTER TABLE catedratico
    ADD CONSTRAINT catedratico_especialidad_fk FOREIGN KEY ( especialidad_id_especialidad )
        REFERENCES especialidad ( id_especialidad );

ALTER TABLE catedratico
    ADD CONSTRAINT catedratico_instituto_fk FOREIGN KEY ( instituto_id_instituto )
        REFERENCES instituto ( id_instituto );

ALTER TABLE estudiante
    ADD CONSTRAINT estudiante_especialidad_fk FOREIGN KEY ( especialidad_id_especialidad )
        REFERENCES especialidad ( id_especialidad );

ALTER TABLE estudiante
    ADD CONSTRAINT estudiante_instituto_fk FOREIGN KEY ( instituto_id_instituto )
        REFERENCES instituto ( id_instituto );

ALTER TABLE plaza
    ADD CONSTRAINT plaza_especialidad_fk FOREIGN KEY ( especialidad_id_especialidad )
        REFERENCES especialidad ( id_especialidad );

ALTER TABLE plaza
    ADD CONSTRAINT plaza_empresa_fk FOREIGN KEY ( empresa_id_empresa )
        REFERENCES empresa ( id_empresa );

ALTER TABLE plaza
    ADD CONSTRAINT plaza_contacto_fk FOREIGN KEY ( contacto_id_contacto )
        REFERENCES contacto ( id_contacto );

ALTER TABLE colocacion
    ADD CONSTRAINT colocacion_estudiante_fk FOREIGN KEY ( estudiante_id_estudiante )
        REFERENCES estudiante ( id_estudiante );

ALTER TABLE colocacion
    ADD CONSTRAINT colocacion_plaza_fk FOREIGN KEY ( plaza_id_plaza )
        REFERENCES plaza ( id_plaza );

ALTER TABLE colocacion
    ADD CONSTRAINT colocacion_catedratico_fk FOREIGN KEY ( catedratico_id_catedratico )
        REFERENCES catedratico ( id_catedratico );

ALTER TABLE bitacora
    ADD CONSTRAINT bitacora_colocacion_fk FOREIGN KEY ( colocacion_id_colocacion )
        REFERENCES colocacion ( id_colocacion );

ALTER TABLE bitacora
    ADD CONSTRAINT bitacora_contacto_fk FOREIGN KEY ( contacto_id_contacto )
        REFERENCES contacto ( id_contacto );

ALTER TABLE evaluacion
    ADD CONSTRAINT evaluacion_colocacion_fk FOREIGN KEY ( colocacion_id_colocacion )
        REFERENCES colocacion ( id_colocacion );

ALTER TABLE evaluacion
    ADD CONSTRAINT evaluacion_catedratico_fk FOREIGN KEY ( catedratico_id_catedratico )
        REFERENCES catedratico ( id_catedratico );

-- Nombres acortados (< 30 caracteres) respecto al original generado,
-- que excedia el limite de Oracle:
ALTER TABLE evaluacion_criterio
    ADD CONSTRAINT evcrit_evaluacion_fk FOREIGN KEY ( evaluacion_id_evaluacion )
        REFERENCES evaluacion ( id_evaluacion );

ALTER TABLE evaluacion_criterio
    ADD CONSTRAINT evcrit_criterio_fk FOREIGN KEY ( criterio_id_criterio )
        REFERENCES criterio ( id_criterio );

-- ------------------------------------------------------------
-- CHECK CONSTRAINTS (dominios cerrados del diccionario de datos)
-- ------------------------------------------------------------

ALTER TABLE empresa ADD CONSTRAINT chk_empresa_sector
    CHECK ( sector_economico IN ('Industria','Servicios','Comercio','Tecnologia') );

ALTER TABLE estudiante ADD CONSTRAINT chk_estudiante_genero
    CHECK ( genero IN ('M','F') );

ALTER TABLE estudiante ADD CONSTRAINT chk_estudiante_primera_practica
    CHECK ( primera_practica IN (0,1) );

ALTER TABLE colocacion ADD CONSTRAINT chk_colocacion_estado
    CHECK ( estado IN ('activa','finalizada','cancelada') );

ALTER TABLE colocacion ADD CONSTRAINT chk_colocacion_activo
    CHECK ( activo IN ('0','1') );

ALTER TABLE evaluacion ADD CONSTRAINT chk_evaluacion_horas
    CHECK ( horas IN (100,200) );

ALTER TABLE evaluacion_criterio ADD CONSTRAINT chk_evalcriterio_puntaje
    CHECK ( puntaje BETWEEN 1 AND 5 );

-- ------------------------------------------------------------
-- INDICES UNICOS FUNCIONALES (reglas de integridad de negocio)
-- ------------------------------------------------------------

-- Un estudiante solo puede tener UNA colocacion activa a la vez.
-- El CASE produce NULL para las filas con activo = '0', y Oracle
-- no aplica unicidad sobre valores NULL, por lo que solo se
-- restringe la fila donde activo = '1'.
CREATE UNIQUE INDEX ux_colocacion_activa
    ON colocacion ( CASE WHEN activo = '1' THEN estudiante_id_estudiante END );

-- El correlativo de bitacora reinicia en 1 cada mes de practica,
-- por lo que debe ser unico por colocacion + mes calendario.
CREATE UNIQUE INDEX ux_bitacora_correlativo_mes
    ON bitacora ( colocacion_id_colocacion, TRUNC(fecha,'MM'), correlativo );
