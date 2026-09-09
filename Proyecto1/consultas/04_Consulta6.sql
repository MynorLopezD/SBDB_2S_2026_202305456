--------------------------------------------------------------------------------
-- Consulta 6: Facturacion por categoria y marca
-- Categoria, marca, unidades vendidas y total facturado.
-- Excluye ventas ANULADA. Solo aparecen combinaciones categoria-marca que
-- tuvieron al menos una venta valida (INNER JOIN), consistente con que es un
-- reporte de facturacion real, no un catalogo completo.
--------------------------------------------------------------------------------
SELECT
    c.nombre_categoria  AS categoria,
    ma.nombre_marca     AS marca,
    SUM(dv.cantidad)    AS unidades_vendidas,
    SUM(dv.subtotal)    AS total_facturado
FROM categoria c
JOIN producto pr       ON pr.id_categoria = c.id_categoria
JOIN marca ma          ON ma.id_marca = pr.id_marca
JOIN detalle_venta dv  ON dv.id_producto = pr.id_producto
JOIN venta v           ON v.id_venta = dv.id_venta
JOIN estado_venta ev   ON ev.id_estado_venta = v.id_estado_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY c.nombre_categoria, ma.nombre_marca
ORDER BY total_facturado DESC;
