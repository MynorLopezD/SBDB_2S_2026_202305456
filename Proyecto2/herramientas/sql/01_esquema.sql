--------------------------------------------------------------------------------
-- Comercial La Estrella - Fase 2 - init.sql
-- Motor: Microsoft SQL Server 2022 (contenedor Docker, ver docker-compose.yml)
--
-- Este archivo lo genera herramientas/generar_init.py y se ejecuta de forma
-- automatica al levantar el contenedor (servicio db-init). Orden interno:
--   1) base de datos y tablas (este bloque)
--   2) datos iniciales del dataset Excel (bloque generado)
--   3) vistas analiticas y triggers (se crean al final, a proposito: asi la
--      carga historica no dispara el descuento de inventario)
--
-- Todo el contenido es ASCII puro (los caracteres con tilde o enie del Excel se
-- escriben con NCHAR) para que no dependa de la codificacion del cliente.
--------------------------------------------------------------------------------
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- Reinicia la base si ya existia (el servicio db-init solo corre este archivo
-- cuando la base aun no esta inicializada).
IF DB_ID(N'ComercialLaEstrella') IS NOT NULL
BEGIN
    ALTER DATABASE ComercialLaEstrella SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ComercialLaEstrella;
END
GO

CREATE DATABASE ComercialLaEstrella;
GO

USE ComercialLaEstrella;
GO

--------------------------------------------------------------------------------
-- 1. UBICACION GEOGRAFICA
--------------------------------------------------------------------------------
CREATE TABLE dbo.pais (
    id_pais      INT IDENTITY(1,1) NOT NULL,
    nombre_pais  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_pais PRIMARY KEY (id_pais),
    CONSTRAINT uq_pais_nombre UNIQUE (nombre_pais)
);
GO

CREATE TABLE dbo.departamento (
    id_departamento      INT IDENTITY(1,1) NOT NULL,
    nombre_departamento  NVARCHAR(50) NOT NULL,
    id_pais              INT NOT NULL,
    CONSTRAINT pk_departamento PRIMARY KEY (id_departamento),
    CONSTRAINT fk_departamento_pais FOREIGN KEY (id_pais) REFERENCES dbo.pais (id_pais),
    CONSTRAINT uq_departamento_nombre_pais UNIQUE (nombre_departamento, id_pais)
);
GO

CREATE TABLE dbo.municipio (
    id_municipio      INT IDENTITY(1,1) NOT NULL,
    nombre_municipio  NVARCHAR(60) NOT NULL,
    id_departamento   INT NOT NULL,
    CONSTRAINT pk_municipio PRIMARY KEY (id_municipio),
    CONSTRAINT fk_municipio_departamento FOREIGN KEY (id_departamento) REFERENCES dbo.departamento (id_departamento),
    CONSTRAINT uq_municipio_nombre_depto UNIQUE (nombre_municipio, id_departamento)
);
GO

--------------------------------------------------------------------------------
-- 2. CATALOGOS GENERALES
--------------------------------------------------------------------------------
CREATE TABLE dbo.tipo_tienda (
    id_tipo_tienda      INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_tienda  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_tipo_tienda PRIMARY KEY (id_tipo_tienda),
    CONSTRAINT uq_tipo_tienda_nombre UNIQUE (nombre_tipo_tienda)
);
GO

CREATE TABLE dbo.tipo_identificacion (
    id_tipo_identificacion      INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_identificacion  NVARCHAR(30) NOT NULL,
    CONSTRAINT pk_tipo_identificacion PRIMARY KEY (id_tipo_identificacion),
    CONSTRAINT uq_tipo_identificacion_nombre UNIQUE (nombre_tipo_identificacion)
);
GO

CREATE TABLE dbo.cargo (
    id_cargo      INT IDENTITY(1,1) NOT NULL,
    nombre_cargo  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_cargo PRIMARY KEY (id_cargo),
    CONSTRAINT uq_cargo_nombre UNIQUE (nombre_cargo)
);
GO

CREATE TABLE dbo.categoria (
    id_categoria      INT IDENTITY(1,1) NOT NULL,
    nombre_categoria  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre_categoria)
);
GO

CREATE TABLE dbo.marca (
    id_marca      INT IDENTITY(1,1) NOT NULL,
    nombre_marca  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_marca PRIMARY KEY (id_marca),
    CONSTRAINT uq_marca_nombre UNIQUE (nombre_marca)
);
GO

CREATE TABLE dbo.estado_venta (
    id_estado_venta      INT IDENTITY(1,1) NOT NULL,
    nombre_estado_venta  NVARCHAR(20) NOT NULL,
    CONSTRAINT pk_estado_venta PRIMARY KEY (id_estado_venta),
    CONSTRAINT uq_estado_venta_nombre UNIQUE (nombre_estado_venta),
    CONSTRAINT ck_estado_venta_valores CHECK (nombre_estado_venta IN ('REGISTRADA', 'PAGADA', 'ANULADA'))
);
GO

CREATE TABLE dbo.metodo_pago (
    id_metodo_pago      INT IDENTITY(1,1) NOT NULL,
    nombre_metodo_pago  NVARCHAR(30) NOT NULL,
    CONSTRAINT pk_metodo_pago PRIMARY KEY (id_metodo_pago),
    CONSTRAINT uq_metodo_pago_nombre UNIQUE (nombre_metodo_pago)
);
GO

--------------------------------------------------------------------------------
-- 3. TIENDAS Y PERSONAS
--------------------------------------------------------------------------------
CREATE TABLE dbo.tienda (
    id_tienda         INT IDENTITY(1,1) NOT NULL,
    nombre_tienda     NVARCHAR(100) NOT NULL,
    direccion_tienda  NVARCHAR(150) NOT NULL,
    telefono_tienda   NVARCHAR(20) NOT NULL,
    id_municipio      INT NOT NULL,
    id_tipo_tienda    INT NOT NULL,
    CONSTRAINT pk_tienda PRIMARY KEY (id_tienda),
    CONSTRAINT fk_tienda_municipio FOREIGN KEY (id_municipio) REFERENCES dbo.municipio (id_municipio),
    CONSTRAINT fk_tienda_tipo_tienda FOREIGN KEY (id_tipo_tienda) REFERENCES dbo.tipo_tienda (id_tipo_tienda)
);
GO

-- Supertipo de empleado y cliente (especializacion disjunta y total).
CREATE TABLE dbo.persona (
    id_persona    INT IDENTITY(1,1) NOT NULL,
    nombres       NVARCHAR(50) NOT NULL,
    apellidos     NVARCHAR(50) NOT NULL,
    telefono      NVARCHAR(20) NOT NULL,
    correo        NVARCHAR(100) NULL,
    direccion     NVARCHAR(150) NOT NULL,
    id_municipio  INT NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona),
    CONSTRAINT fk_persona_municipio FOREIGN KEY (id_municipio) REFERENCES dbo.municipio (id_municipio)
);
GO

-- Diferencia con Oracle: un UNIQUE de SQL Server admite UN solo NULL por columna,
-- y el dataset trae clientes sin correo. Un indice unico filtrado exige unicidad
-- solo entre los correos registrados ("unico cuando se encuentre registrado").
CREATE UNIQUE INDEX uq_persona_correo ON dbo.persona (correo) WHERE correo IS NOT NULL;
GO

CREATE TABLE dbo.empleado (
    id_empleado         INT IDENTITY(1,1) NOT NULL,
    id_persona          INT NOT NULL,
    fecha_contratacion  DATE NOT NULL,
    id_tienda           INT NOT NULL,
    id_cargo            INT NOT NULL,
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT fk_empleado_persona FOREIGN KEY (id_persona) REFERENCES dbo.persona (id_persona),
    CONSTRAINT uq_empleado_persona UNIQUE (id_persona),
    CONSTRAINT fk_empleado_tienda FOREIGN KEY (id_tienda) REFERENCES dbo.tienda (id_tienda),
    CONSTRAINT fk_empleado_cargo FOREIGN KEY (id_cargo) REFERENCES dbo.cargo (id_cargo),
    -- En Oracle esta regla no podia ser un CHECK (SYSDATE no esta permitido);
    -- en SQL Server GETDATE() si se admite.
    CONSTRAINT ck_empleado_fecha_contratacion CHECK (fecha_contratacion <= CAST(GETDATE() AS DATE))
);
GO

CREATE TABLE dbo.cliente (
    id_cliente              INT IDENTITY(1,1) NOT NULL,
    id_persona              INT NOT NULL,
    id_tipo_identificacion  INT NOT NULL,
    numero_identificacion   NVARCHAR(20) NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_persona FOREIGN KEY (id_persona) REFERENCES dbo.persona (id_persona),
    CONSTRAINT uq_cliente_persona UNIQUE (id_persona),
    CONSTRAINT fk_cliente_tipo_ident FOREIGN KEY (id_tipo_identificacion) REFERENCES dbo.tipo_identificacion (id_tipo_identificacion),
    CONSTRAINT uq_cliente_tipo_numero UNIQUE (id_tipo_identificacion, numero_identificacion)
);
GO

--------------------------------------------------------------------------------
-- 4. PRODUCTOS
--------------------------------------------------------------------------------
CREATE TABLE dbo.producto (
    id_producto           INT IDENTITY(1,1) NOT NULL,
    nombre_producto       NVARCHAR(100) NOT NULL,
    descripcion_producto  NVARCHAR(300) NULL,
    id_categoria          INT NOT NULL,
    id_marca              INT NOT NULL,
    CONSTRAINT pk_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES dbo.categoria (id_categoria),
    CONSTRAINT fk_producto_marca FOREIGN KEY (id_marca) REFERENCES dbo.marca (id_marca)
);
GO

-- Precio vigente y existencia dependen de la pareja (tienda, producto).
CREATE TABLE dbo.catalogo_tienda_producto (
    id_tienda          INT NOT NULL,
    id_producto        INT NOT NULL,
    precio_vigente     DECIMAL(10,2) NOT NULL,
    existencia_actual  INT NOT NULL,
    CONSTRAINT pk_catalogo_tienda_producto PRIMARY KEY (id_tienda, id_producto),
    CONSTRAINT fk_catprod_tienda FOREIGN KEY (id_tienda) REFERENCES dbo.tienda (id_tienda),
    CONSTRAINT fk_catprod_producto FOREIGN KEY (id_producto) REFERENCES dbo.producto (id_producto),
    CONSTRAINT ck_catprod_precio CHECK (precio_vigente > 0),
    CONSTRAINT ck_catprod_existencia CHECK (existencia_actual >= 0)
);
GO

--------------------------------------------------------------------------------
-- 5. VENTAS Y PAGOS
--------------------------------------------------------------------------------
CREATE TABLE dbo.venta (
    id_venta         INT IDENTITY(1,1) NOT NULL,
    fecha_venta      DATE NOT NULL,
    id_tienda        INT NOT NULL,
    id_empleado      INT NOT NULL,
    id_cliente       INT NOT NULL,
    id_estado_venta  INT NOT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta),
    CONSTRAINT fk_venta_tienda FOREIGN KEY (id_tienda) REFERENCES dbo.tienda (id_tienda),
    CONSTRAINT fk_venta_empleado FOREIGN KEY (id_empleado) REFERENCES dbo.empleado (id_empleado),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) REFERENCES dbo.cliente (id_cliente),
    CONSTRAINT fk_venta_estado FOREIGN KEY (id_estado_venta) REFERENCES dbo.estado_venta (id_estado_venta)
);
GO

-- subtotal es una columna calculada y persistida: la regla "subtotal = cantidad
-- por precio unitario" queda garantizada por el motor y la API no la calcula.
CREATE TABLE dbo.detalle_venta (
    id_venta         INT NOT NULL,
    id_producto      INT NOT NULL,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    subtotal         AS (CAST(cantidad * precio_unitario AS DECIMAL(10,2))) PERSISTED NOT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
    CONSTRAINT fk_detventa_venta FOREIGN KEY (id_venta) REFERENCES dbo.venta (id_venta),
    CONSTRAINT fk_detventa_producto FOREIGN KEY (id_producto) REFERENCES dbo.producto (id_producto),
    CONSTRAINT ck_detventa_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detventa_precio CHECK (precio_unitario > 0)
);
GO

CREATE TABLE dbo.pago (
    id_pago         INT IDENTITY(1,1) NOT NULL,
    id_venta        INT NOT NULL,
    id_metodo_pago  INT NOT NULL,
    monto_pagado    DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_venta FOREIGN KEY (id_venta) REFERENCES dbo.venta (id_venta),
    CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo_pago) REFERENCES dbo.metodo_pago (id_metodo_pago),
    CONSTRAINT ck_pago_monto CHECK (monto_pagado > 0)
);
GO
