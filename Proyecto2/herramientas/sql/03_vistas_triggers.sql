--------------------------------------------------------------------------------
-- 3. VISTAS ANALITICAS
-- La API solo hace SELECT * sobre estas vistas. Un ORDER BY dentro de una vista
-- no esta permitido en T-SQL, asi que el orden lo aplica cada endpoint.
-- Todas agrupan por el id real de la entidad (no solo por nombre) para no
-- fusionar registros distintos que compartan nombre.
--------------------------------------------------------------------------------

-- Vista 1: tienda, municipio, departamento, pais, cantidad de ventas y total
-- facturado (excluye ventas ANULADA).
CREATE VIEW dbo.Vista_Ventas_Ubicacion AS
SELECT
    t.nombre_tienda            AS tienda,
    m.nombre_municipio         AS municipio,
    d.nombre_departamento      AS departamento,
    p.nombre_pais              AS pais,
    COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
    SUM(dv.subtotal)           AS total_facturado
FROM dbo.tienda t
JOIN dbo.municipio m       ON m.id_municipio = t.id_municipio
JOIN dbo.departamento d    ON d.id_departamento = m.id_departamento
JOIN dbo.pais p            ON p.id_pais = d.id_pais
JOIN dbo.venta v           ON v.id_tienda = t.id_tienda
JOIN dbo.estado_venta ev   ON ev.id_estado_venta = v.id_estado_venta
JOIN dbo.detalle_venta dv  ON dv.id_venta = v.id_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY t.id_tienda, t.nombre_tienda, m.nombre_municipio, d.nombre_departamento, p.nombre_pais;
GO

-- Vista 2: codigo, nombre, categoria, marca, unidades vendidas y monto generado
-- por producto (excluye ventas ANULADA).
CREATE VIEW dbo.Vista_Top_Productos AS
SELECT
    pr.id_producto      AS codigo,
    pr.nombre_producto  AS producto,
    c.nombre_categoria  AS categoria,
    ma.nombre_marca     AS marca,
    SUM(dv.cantidad)    AS unidades_vendidas,
    SUM(dv.subtotal)    AS monto_generado
FROM dbo.producto pr
JOIN dbo.categoria c       ON c.id_categoria = pr.id_categoria
JOIN dbo.marca ma          ON ma.id_marca = pr.id_marca
JOIN dbo.detalle_venta dv  ON dv.id_producto = pr.id_producto
JOIN dbo.venta v           ON v.id_venta = dv.id_venta
JOIN dbo.estado_venta ev   ON ev.id_estado_venta = v.id_estado_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY pr.id_producto, pr.nombre_producto, c.nombre_categoria, ma.nombre_marca;
GO

-- Vista 3: ventas en estado REGISTRADA con su total, el total pagado (0 si no
-- hay abonos) y el saldo pendiente.
CREATE VIEW dbo.Vista_Saldos_Pendientes AS
SELECT
    v.id_venta                                  AS numero_venta,
    v.fecha_venta                               AS fecha_venta,
    tv.total_venta                              AS total_venta,
    ISNULL(tp.total_pagado, 0)                  AS total_pagado,
    tv.total_venta - ISNULL(tp.total_pagado, 0) AS saldo_pendiente
FROM dbo.venta v
JOIN dbo.estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
JOIN (SELECT id_venta, SUM(subtotal) AS total_venta
      FROM dbo.detalle_venta
      GROUP BY id_venta) tv ON tv.id_venta = v.id_venta
LEFT JOIN (SELECT id_venta, SUM(monto_pagado) AS total_pagado
           FROM dbo.pago
           GROUP BY id_venta) tp ON tp.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'REGISTRADA';
GO

--------------------------------------------------------------------------------
-- 4. TRIGGERS
-- En SQL Server un trigger se dispara una vez por sentencia (no por fila), asi
-- que ambos trabajan por conjuntos sobre la tabla "inserted".
-- Los errores usan numeros propios (>= 50000) para que la API los distinga.
--------------------------------------------------------------------------------

-- Trigger Insert_Detalle: protege el inventario.
-- El stock vive por tienda en catalogo_tienda_producto, asi que se valida y se
-- descuenta el de la tienda donde se registro la venta.
--   50001 = Stock insuficiente
--   50002 = el producto no esta en el catalogo de la tienda de la venta
CREATE TRIGGER dbo.Insert_Detalle
ON dbo.detalle_venta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cantidad total pedida por (tienda, producto) en esta sentencia.
    DECLARE @pedido TABLE (
        id_tienda       INT NOT NULL,
        id_producto     INT NOT NULL,
        cantidad_total  INT NOT NULL,
        PRIMARY KEY (id_tienda, id_producto)
    );

    INSERT INTO @pedido (id_tienda, id_producto, cantidad_total)
    SELECT v.id_tienda, i.id_producto, SUM(i.cantidad)
    FROM inserted i
    JOIN dbo.venta v ON v.id_venta = i.id_venta
    GROUP BY v.id_tienda, i.id_producto;

    -- 1) El producto debe existir en el catalogo de la tienda.
    IF EXISTS (
        SELECT 1
        FROM @pedido p
        LEFT JOIN dbo.catalogo_tienda_producto AS c
               ON c.id_tienda = p.id_tienda AND c.id_producto = p.id_producto
        WHERE c.id_tienda IS NULL
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'Producto no disponible en la tienda de la venta', 1;
    END;

    -- 2) Debe haber existencia suficiente (UPDLOCK/HOLDLOCK evita que dos ventas
    --    simultaneas lean el mismo stock).
    IF EXISTS (
        SELECT 1
        FROM @pedido p
        JOIN dbo.catalogo_tienda_producto AS c WITH (UPDLOCK, HOLDLOCK)
          ON c.id_tienda = p.id_tienda AND c.id_producto = p.id_producto
        WHERE p.cantidad_total > c.existencia_actual
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Stock insuficiente', 1;
    END;

    -- 3) Transaccion valida: descuenta del inventario.
    UPDATE c
    SET    c.existencia_actual = c.existencia_actual - p.cantidad_total
    FROM   dbo.catalogo_tienda_producto c
    JOIN   @pedido p ON p.id_tienda = c.id_tienda AND p.id_producto = c.id_producto;
END;
GO

-- Trigger Insert_Pago: estado automatico de la venta.
-- Si la suma de los pagos alcanza o supera el total de la venta y esta en
-- REGISTRADA, pasa a PAGADA. Los estados se buscan por nombre, no por id fijo.
CREATE TRIGGER dbo.Insert_Pago
ON dbo.pago
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_registrada INT = (SELECT id_estado_venta FROM dbo.estado_venta WHERE nombre_estado_venta = 'REGISTRADA');
    DECLARE @id_pagada     INT = (SELECT id_estado_venta FROM dbo.estado_venta WHERE nombre_estado_venta = 'PAGADA');

    UPDATE v
    SET    v.id_estado_venta = @id_pagada
    FROM   dbo.venta v
    WHERE  v.id_estado_venta = @id_registrada
      AND  v.id_venta IN (SELECT id_venta FROM inserted)
      AND  (SELECT SUM(d.subtotal) FROM dbo.detalle_venta d WHERE d.id_venta = v.id_venta) > 0
      AND  (SELECT ISNULL(SUM(p.monto_pagado), 0) FROM dbo.pago p WHERE p.id_venta = v.id_venta)
           >= (SELECT SUM(d.subtotal) FROM dbo.detalle_venta d WHERE d.id_venta = v.id_venta);
END;
GO
