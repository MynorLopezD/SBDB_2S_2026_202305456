-- ============================================================
-- PRACTICA 2 - Esquema final adaptado
-- Combina los catalogos normalizados del dataset
-- (sector_economico, departamento, municipio, estado_colocacion,
-- tipo_evaluacion) con las decisiones propias de la Practica 1
-- (catalogo compartido "especialidad", PK natural "carnet" en
-- estudiante, atributo "primera_practica").
--
-- Nota: catedratico, plaza y estudiante incluyen una columna de
-- texto TEMPORAL (sufijo _temp) para poder importar el dato crudo
-- del Excel con el asistente. Esa columna se elimina despues de
-- ejecutar el script de transformacion (paso siguiente).
-- ============================================================

-- ------------------------------------------------------------
-- CATALOGOS (estructura tomada del dataset)
-- ------------------------------------------------------------

CREATE TABLE sector_economico (
    id_sector INTEGER NOT NULL,
    nombre    VARCHAR2(50) NOT NULL
);
ALTER TABLE sector_economico ADD CONSTRAINT sector_economico_pk PRIMARY KEY ( id_sector );

CREATE TABLE departamento (
    id_departamento INTEGER NOT NULL,
    nombre          VARCHAR2(50) NOT NULL
);
ALTER TABLE departamento ADD CONSTRAINT departamento_pk PRIMARY KEY ( id_departamento );

CREATE TABLE municipio (
    id_municipio    INTEGER NOT NULL,
    nombre          VARCHAR2(50) NOT NULL,
    departamento_id INTEGER NOT NULL
);
ALTER TABLE municipio ADD CONSTRAINT municipio_pk PRIMARY KEY ( id_municipio );

CREATE TABLE estado_colocacion (
    id_estado INTEGER NOT NULL,
    nombre    VARCHAR2(20) NOT NULL
);
ALTER TABLE estado_colocacion ADD CONSTRAINT estado_colocacion_pk PRIMARY KEY ( id_estado );

CREATE TABLE tipo_evaluacion (
    id_tipo_evaluacion INTEGER NOT NULL,
    nombre             VARCHAR2(20) NOT NULL
);
ALTER TABLE tipo_evaluacion ADD CONSTRAINT tipo_evaluacion_pk PRIMARY KEY ( id_tipo_evaluacion );

CREATE TABLE criterio (
    id_criterio INTEGER NOT NULL,
    nombre      VARCHAR2(100) NOT NULL
);
ALTER TABLE criterio ADD CONSTRAINT criterio_pk PRIMARY KEY ( id_criterio );

-- ------------------------------------------------------------
-- CATALOGO PROPIO (no viene en el dataset, se construye a partir
-- de los valores unicos de texto en catedratico/plaza/estudiante)
-- ------------------------------------------------------------

CREATE TABLE especialidad (
    id_especialidad INTEGER NOT NULL,
    nombre          VARCHAR2(150) NOT NULL
);
ALTER TABLE especialidad ADD CONSTRAINT especialidad_pk PRIMARY KEY ( id_especialidad );
ALTER TABLE especialidad ADD CONSTRAINT especialidad_nombre_uk UNIQUE ( nombre );

-- ------------------------------------------------------------
-- INSTITUTO (sin cambios respecto a la Practica 1)
-- ------------------------------------------------------------

CREATE TABLE instituto (
    id_instituto        INTEGER NOT NULL,
    nombre              VARCHAR2(150) NOT NULL,
    direccion           VARCHAR2(200) NOT NULL,
    codigo_autorizacion VARCHAR2(30) NOT NULL
);
ALTER TABLE instituto ADD CONSTRAINT instituto_pk PRIMARY KEY ( id_instituto );

-- ------------------------------------------------------------
-- EMPRESA (sector_economico ahora es FK, ya no CHECK)
-- ------------------------------------------------------------

CREATE TABLE empresa (
    id_empresa INTEGER NOT NULL,
    nombre     VARCHAR2(150) NOT NULL,
    direccion  VARCHAR2(200) NOT NULL,
    sector_id  INTEGER NOT NULL
);
ALTER TABLE empresa ADD CONSTRAINT empresa_pk PRIMARY KEY ( id_empresa );
ALTER TABLE empresa ADD CONSTRAINT empresa_sector_fk
    FOREIGN KEY ( sector_id ) REFERENCES sector_economico ( id_sector );

-- ------------------------------------------------------------
-- CONTACTO
-- ------------------------------------------------------------

CREATE TABLE contacto (
    id_contacto INTEGER NOT NULL,
    nombre      VARCHAR2(150) NOT NULL,
    telefono    VARCHAR2(20) NOT NULL,
    correo      VARCHAR2(100) NOT NULL,
    empresa_id  INTEGER NOT NULL
);
ALTER TABLE contacto ADD CONSTRAINT contacto_pk PRIMARY KEY ( id_contacto );
ALTER TABLE contacto ADD CONSTRAINT contacto_empresa_fk
    FOREIGN KEY ( empresa_id ) REFERENCES empresa ( id_empresa );

-- ------------------------------------------------------------
-- CATEDRATICO (especialidad_id se llena por transformacion)
-- ------------------------------------------------------------

CREATE TABLE catedratico (
    id_catedratico    INTEGER NOT NULL,
    identificacion    VARCHAR2(20) NOT NULL,
    nombre            VARCHAR2(150) NOT NULL,
    telefono          VARCHAR2(20) NOT NULL,
    especialidad_id   INTEGER,              -- se completa en la transformacion
    especialidad_temp VARCHAR2(150),        -- columna temporal para el import crudo
    instituto_id      INTEGER NOT NULL
);
ALTER TABLE catedratico ADD CONSTRAINT catedratico_pk PRIMARY KEY ( id_catedratico );
ALTER TABLE catedratico ADD CONSTRAINT catedratico_instituto_fk
    FOREIGN KEY ( instituto_id ) REFERENCES instituto ( id_instituto );
ALTER TABLE catedratico ADD CONSTRAINT catedratico_especialidad_fk
    FOREIGN KEY ( especialidad_id ) REFERENCES especialidad ( id_especialidad );

-- ------------------------------------------------------------
-- ESTUDIANTE (PK = carnet, primera_practica derivado de
-- es_repitencia, especialidad_id se llena por transformacion)
-- ------------------------------------------------------------

CREATE TABLE estudiante (
    carnet             INTEGER NOT NULL,
    nombre_completo    VARCHAR2(150) NOT NULL,
    direccion          VARCHAR2(200) NOT NULL,
    telefono           VARCHAR2(20) NOT NULL,
    fecha_nacimiento   DATE NOT NULL,
    genero             VARCHAR2(1) NOT NULL,
    primera_practica   NUMBER(1),           -- se completa en la transformacion
    carrera_temp       VARCHAR2(150),       -- columna temporal para el import crudo
    es_repitencia_temp NUMBER(1),           -- columna temporal para el import crudo
    especialidad_id    INTEGER,             -- se completa en la transformacion
    municipio_id       INTEGER NOT NULL,
    instituto_id       INTEGER NOT NULL
);
ALTER TABLE estudiante ADD CONSTRAINT estudiante_pk PRIMARY KEY ( carnet );
ALTER TABLE estudiante ADD CONSTRAINT estudiante_municipio_fk
    FOREIGN KEY ( municipio_id ) REFERENCES municipio ( id_municipio );
ALTER TABLE estudiante ADD CONSTRAINT estudiante_instituto_fk
    FOREIGN KEY ( instituto_id ) REFERENCES instituto ( id_instituto );
ALTER TABLE estudiante ADD CONSTRAINT estudiante_especialidad_fk
    FOREIGN KEY ( especialidad_id ) REFERENCES especialidad ( id_especialidad );
ALTER TABLE estudiante ADD CONSTRAINT chk_estudiante_genero CHECK ( genero IN ('M','F') );

-- ------------------------------------------------------------
-- PLAZA (especialidad_id se llena por transformacion)
-- ------------------------------------------------------------

CREATE TABLE plaza (
    id_plaza          INTEGER NOT NULL,
    especialidad_id   INTEGER,              -- se completa en la transformacion
    especialidad_temp VARCHAR2(150),        -- columna temporal para el import crudo
    empresa_id        INTEGER NOT NULL,
    contacto_id       INTEGER NOT NULL
);
ALTER TABLE plaza ADD CONSTRAINT plaza_pk PRIMARY KEY ( id_plaza );
ALTER TABLE plaza ADD CONSTRAINT plaza_empresa_fk
    FOREIGN KEY ( empresa_id ) REFERENCES empresa ( id_empresa );
ALTER TABLE plaza ADD CONSTRAINT plaza_contacto_fk
    FOREIGN KEY ( contacto_id ) REFERENCES contacto ( id_contacto );
ALTER TABLE plaza ADD CONSTRAINT plaza_especialidad_fk
    FOREIGN KEY ( especialidad_id ) REFERENCES especialidad ( id_especialidad );

-- ------------------------------------------------------------
-- COLOCACION (estado ahora es FK; "activo" se deriva por
-- transformacion a partir del estado)
-- ------------------------------------------------------------

CREATE TABLE colocacion (
    id_colocacion  INTEGER NOT NULL,
    fecha_inicio   DATE NOT NULL,
    fecha_fin      DATE,
    estudiante_id  INTEGER NOT NULL,
    plaza_id       INTEGER NOT NULL,
    catedratico_id INTEGER NOT NULL,
    estado_id      INTEGER NOT NULL,
    activo         CHAR(1)               -- se completa en la transformacion
);
ALTER TABLE colocacion ADD CONSTRAINT colocacion_pk PRIMARY KEY ( id_colocacion );
ALTER TABLE colocacion ADD CONSTRAINT colocacion_estudiante_fk
    FOREIGN KEY ( estudiante_id ) REFERENCES estudiante ( carnet );
ALTER TABLE colocacion ADD CONSTRAINT colocacion_plaza_fk
    FOREIGN KEY ( plaza_id ) REFERENCES plaza ( id_plaza );
ALTER TABLE colocacion ADD CONSTRAINT colocacion_catedratico_fk
    FOREIGN KEY ( catedratico_id ) REFERENCES catedratico ( id_catedratico );
ALTER TABLE colocacion ADD CONSTRAINT colocacion_estado_fk
    FOREIGN KEY ( estado_id ) REFERENCES estado_colocacion ( id_estado );
ALTER TABLE colocacion ADD CONSTRAINT chk_colocacion_activo CHECK ( activo IN ('0','1') );

-- ------------------------------------------------------------
-- BITACORA
-- ------------------------------------------------------------

CREATE TABLE bitacora (
    id_bitacora            INTEGER NOT NULL,
    correlativo            INTEGER NOT NULL,
    fecha                  DATE NOT NULL,
    horas_trabajadas       NUMBER(4, 2) NOT NULL,
    actividades_realizadas VARCHAR2(1000) NOT NULL,
    observaciones          VARCHAR2(500),
    colocacion_id          INTEGER NOT NULL,
    validado_por           INTEGER NOT NULL
);
ALTER TABLE bitacora ADD CONSTRAINT bitacora_pk PRIMARY KEY ( id_bitacora );
ALTER TABLE bitacora ADD CONSTRAINT bitacora_colocacion_fk
    FOREIGN KEY ( colocacion_id ) REFERENCES colocacion ( id_colocacion );
ALTER TABLE bitacora ADD CONSTRAINT bitacora_contacto_fk
    FOREIGN KEY ( validado_por ) REFERENCES contacto ( id_contacto );

-- ------------------------------------------------------------
-- EVALUACION (tipo de evaluacion ahora es FK, ya no "horas")
-- ------------------------------------------------------------

CREATE TABLE evaluacion (
    id_evaluacion      INTEGER NOT NULL,
    fecha              DATE NOT NULL,
    colocacion_id      INTEGER NOT NULL,
    catedratico_id     INTEGER NOT NULL,
    tipo_evaluacion_id INTEGER NOT NULL
);
ALTER TABLE evaluacion ADD CONSTRAINT evaluacion_pk PRIMARY KEY ( id_evaluacion );
ALTER TABLE evaluacion ADD CONSTRAINT evaluacion_colocacion_fk
    FOREIGN KEY ( colocacion_id ) REFERENCES colocacion ( id_colocacion );
ALTER TABLE evaluacion ADD CONSTRAINT evaluacion_catedratico_fk
    FOREIGN KEY ( catedratico_id ) REFERENCES catedratico ( id_catedratico );
ALTER TABLE evaluacion ADD CONSTRAINT evaluacion_tipo_fk
    FOREIGN KEY ( tipo_evaluacion_id ) REFERENCES tipo_evaluacion ( id_tipo_evaluacion );

-- ------------------------------------------------------------
-- EVALUACION_CRITERIO (equivale a DETALLE_EVALUACION del dataset)
-- ------------------------------------------------------------

CREATE TABLE evaluacion_criterio (
    evaluacion_id INTEGER NOT NULL,
    criterio_id   INTEGER NOT NULL,
    puntaje       INTEGER NOT NULL
);
ALTER TABLE evaluacion_criterio ADD CONSTRAINT evaluacion_criterio_pk
    PRIMARY KEY ( evaluacion_id, criterio_id );
ALTER TABLE evaluacion_criterio ADD CONSTRAINT evcrit_evaluacion_fk
    FOREIGN KEY ( evaluacion_id ) REFERENCES evaluacion ( id_evaluacion );
ALTER TABLE evaluacion_criterio ADD CONSTRAINT evcrit_criterio_fk
    FOREIGN KEY ( criterio_id ) REFERENCES criterio ( id_criterio );
ALTER TABLE evaluacion_criterio ADD CONSTRAINT chk_evalcriterio_puntaje
    CHECK ( puntaje BETWEEN 1 AND 5 );

-- FK jerarquica de municipio -> departamento (declarada al final
-- porque departamento ya debe existir)
ALTER TABLE municipio ADD CONSTRAINT municipio_departamento_fk
    FOREIGN KEY ( departamento_id ) REFERENCES departamento ( id_departamento );
