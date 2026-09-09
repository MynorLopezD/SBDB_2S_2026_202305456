--------------------------------------------------------------------------------
-- Consulta 2: Ventas por tipo de tienda
-- Tipo de tienda, cantidad de tiendas, cantidad de ventas y monto facturado.
-- Excluye ventas ANULADA. Se calculan primero las ventas validas en un CTE y
-- se hace LEFT JOIN desde tipo_tienda/tienda para que un tipo de tienda con
-- alguna sucursal sin ventas siga contando esa sucursal en "cantidad_tiendas".
--------------------------------------------------------------------------------
WITH ventas_validas AS (
    SELECT v.id_tienda, v.id_venta, dv.subtotal
    FROM venta v
    JOIN estado_venta ev  ON ev.id_estado_venta = v.id_estado_venta
    JOIN detalle_venta dv ON dv.id_venta = v.id_venta
    WHERE ev.nombre_estado_venta <> 'ANULADA'
)
SELECT
    tt.nombre_tipo_tienda        AS tipo_tienda,
    COUNT(DISTINCT t.id_tienda)  AS cantidad_tiendas,
    COUNT(DISTINCT vv.id_venta)  AS cantidad_ventas,
    NVL(SUM(vv.subtotal), 0)     AS monto_facturado
FROM tipo_tienda tt
JOIN tienda t              ON t.id_tipo_tienda = tt.id_tipo_tienda
LEFT JOIN ventas_validas vv ON vv.id_tienda = t.id_tienda
GROUP BY tt.nombre_tipo_tienda
ORDER BY monto_facturado DESC;
