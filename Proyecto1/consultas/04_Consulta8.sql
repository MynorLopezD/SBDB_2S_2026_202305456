--------------------------------------------------------------------------------
-- Consulta 8: Ventas pendientes de pago
-- Ventas en estado REGISTRADA: total de venta, total pagado (si existe, via
-- LEFT JOIN + NVL) y diferencia pendiente. Sirve tambien como consulta de
-- validacion de la regla "la suma de pagos de una venta PAGADA debe igualar
-- el total de sus detalles": aqui se ve el caso complementario (REGISTRADA),
-- donde la diferencia pendiente puede ser total o parcial.
--------------------------------------------------------------------------------
WITH totales_venta AS (
    SELECT dv.id_venta, SUM(dv.subtotal) AS total_venta
    FROM detalle_venta dv
    GROUP BY dv.id_venta
),
totales_pago AS (
    SELECT pg.id_venta, SUM(pg.monto_pagado) AS total_pagado
    FROM pago pg
    GROUP BY pg.id_venta
)
SELECT
    v.id_venta                               AS numero_venta,
    v.fecha_venta                            AS fecha_venta,
    tv.total_venta                           AS total_venta,
    NVL(tp.total_pagado, 0)                  AS total_pagado,
    tv.total_venta - NVL(tp.total_pagado, 0) AS diferencia_pendiente
FROM venta v
JOIN estado_venta ev      ON ev.id_estado_venta = v.id_estado_venta
JOIN totales_venta tv     ON tv.id_venta = v.id_venta
LEFT JOIN totales_pago tp ON tp.id_venta = v.id_venta
WHERE ev.nombre_estado_venta = 'REGISTRADA'
ORDER BY diferencia_pendiente DESC;
