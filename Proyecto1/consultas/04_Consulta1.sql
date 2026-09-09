--------------------------------------------------------------------------------
-- Consulta 1: Ventas por tienda y ubicacion
-- Tienda, municipio, departamento, pais, cantidad de ventas y total facturado.
-- Excluye ventas ANULADA (regla de negocio: no se consideran en reportes de
-- facturacion).
-- El GROUP BY incluye t.id_tienda (no solo el nombre) para que dos tiendas
-- que llegaran a compartir el mismo nombre nunca se fusionen en una sola
-- fila; nombre_tienda no tiene restriccion UNIQUE en el modelo.
--------------------------------------------------------------------------------
SELECT
    t.nombre_tienda            AS tienda,
    m.nombre_municipio         AS municipio,
    d.nombre_departamento      AS departamento,
    p.nombre_pais              AS pais,
    COUNT(DISTINCT v.id_venta) AS cantidad_ventas,
    SUM(dv.subtotal)           AS total_facturado
FROM tienda t
JOIN municipio m       ON m.id_municipio = t.id_municipio
JOIN departamento d    ON d.id_departamento = m.id_departamento
JOIN pais p            ON p.id_pais = d.id_pais
JOIN venta v           ON v.id_tienda = t.id_tienda
JOIN estado_venta ev   ON ev.id_estado_venta = v.id_estado_venta
JOIN detalle_venta dv  ON dv.id_venta = v.id_venta
WHERE ev.nombre_estado_venta <> 'ANULADA'
GROUP BY t.id_tienda, t.nombre_tienda, m.nombre_municipio, d.nombre_departamento, p.nombre_pais
ORDER BY total_facturado DESC;
