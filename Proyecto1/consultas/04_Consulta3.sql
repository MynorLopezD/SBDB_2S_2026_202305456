--------------------------------------------------------------------------------
-- Consulta 3: Productos mas vendidos
-- Codigo, producto, categoria, marca, unidades vendidas y monto generado.
-- Excluye ventas ANULADA. El id_producto cumple el rol de "codigo" (ver
-- diccionario de datos: no existe un campo codigo separado del id).
--------------------------------------------------------------------------------
SELECT
    pr.id_producto      AS codigo,
    pr.nombre_producto  AS producto,
    c.nombre_categoria  AS categoria,
    ma.nombre_marca     AS marca,
    SUM(dv.cantidad)    AS unidades_vendidas,
    SUM(dv.subtotal)    AS monto_generado
FROM producto pr
JOIN categoria c       ON c.id_categoria = pr.id_categoria
JOIN marca ma          ON ma.id_marca = pr.id_marca
JOIN detalle_venta dv  ON dv.id_producto = pr.id_producto
JOIN venta v           ON v.id_venta = dv.id_venta
JOIN estado_venta ev   ON ev.id_estado_venta = v.id_estado_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY pr.id_producto, pr.nombre_producto, c.nombre_categoria, ma.nombre_marca
ORDER BY unidades_vendidas DESC;
