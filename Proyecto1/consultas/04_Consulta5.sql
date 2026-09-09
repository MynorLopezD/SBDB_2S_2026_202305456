--------------------------------------------------------------------------------
-- Consulta 5: Clientes con mayor compra
-- Cliente, municipio de residencia, cantidad de ventas pagadas y monto total
-- comprado. Se restringe a estado PAGADA (esto ya excluye REGISTRADA y
-- ANULADA por construccion, sin necesidad de un filtro <> adicional).
-- El GROUP BY incluye cl.id_cliente: existen clientes distintos con el mismo
-- nombre y municipio de residencia en los datos de prueba (verificado:
-- "Estuardo Chavez" en Guadalajara y "Pedro Martinez" en Chiquimula
-- corresponden cada uno a dos personas distintas). Agrupar solo por
-- nombre+municipio fusionaria sus compras en una sola fila incorrecta.
--------------------------------------------------------------------------------
SELECT
    per.nombres || ' ' || per.apellidos AS cliente,
    m.nombre_municipio                  AS municipio_residencia,
    COUNT(DISTINCT v.id_venta)          AS cantidad_ventas_pagadas,
    SUM(dv.subtotal)                    AS monto_total_comprado
FROM cliente cl
JOIN persona per       ON per.id_persona = cl.id_persona
JOIN municipio m        ON m.id_municipio = per.id_municipio
JOIN venta v            ON v.id_cliente = cl.id_cliente
JOIN estado_venta ev    ON ev.id_estado_venta = v.id_estado_venta
JOIN detalle_venta dv   ON dv.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'PAGADA'
GROUP BY cl.id_cliente, per.nombres, per.apellidos, m.nombre_municipio
ORDER BY monto_total_comprado DESC;
