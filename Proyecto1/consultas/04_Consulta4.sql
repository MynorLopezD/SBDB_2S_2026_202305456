--------------------------------------------------------------------------------
-- Consulta 4: Desempeno de empleados
-- Empleado, cargo, tienda, cantidad de ventas atendidas y total facturado.
-- Excluye ventas ANULADA. LEFT JOIN para que un empleado sin ventas en el
-- periodo siga apareciendo con 0 (util para un reporte de desempeno: tambien
-- interesa ver quien no ha vendido).
-- El GROUP BY incluye e.id_empleado (no solo nombre+cargo+tienda) para que
-- dos empleados homonimos en la misma tienda y cargo nunca se fusionen en
-- una sola fila.
--------------------------------------------------------------------------------
WITH ventas_validas AS (
    SELECT v.id_venta, v.id_empleado, dv.subtotal
    FROM venta v
    JOIN estado_venta ev  ON ev.id_estado_venta = v.id_estado_venta
    JOIN detalle_venta dv ON dv.id_venta = v.id_venta
    WHERE ev.nombre_estado_venta <> 'ANULADA'
)
SELECT
    per.nombres || ' ' || per.apellidos AS empleado,
    ca.nombre_cargo                     AS cargo,
    t.nombre_tienda                     AS tienda,
    COUNT(DISTINCT vv.id_venta)         AS cantidad_ventas_atendidas,
    NVL(SUM(vv.subtotal), 0)            AS total_facturado
FROM empleado e
JOIN persona per            ON per.id_persona = e.id_persona
JOIN cargo ca                ON ca.id_cargo = e.id_cargo
JOIN tienda t                ON t.id_tienda = e.id_tienda
LEFT JOIN ventas_validas vv ON vv.id_empleado = e.id_empleado
GROUP BY e.id_empleado, per.nombres, per.apellidos, ca.nombre_cargo, t.nombre_tienda
ORDER BY total_facturado DESC;
