--------------------------------------------------------------------------------
-- Consulta 7: Uso de metodos de pago
-- Metodo de pago, cantidad de pagos y monto total recibido.
-- No se filtra por estado de venta: se verifico contra los datos de prueba
-- que ninguna venta ANULADA tiene pagos asociados (una venta cancelada no
-- deberia tener dinero recibido), asi que el filtro no cambia el resultado
-- pero tampoco hace falta agregarlo. LEFT JOIN para que un metodo de pago sin
-- ningun uso todavia aparezca en el reporte con 0.
--------------------------------------------------------------------------------
SELECT
    mp.nombre_metodo_pago        AS metodo_pago,
    COUNT(pg.id_pago)            AS cantidad_pagos,
    NVL(SUM(pg.monto_pagado), 0) AS monto_total_recibido
FROM metodo_pago mp
LEFT JOIN pago pg ON pg.id_metodo_pago = mp.id_metodo_pago
GROUP BY mp.nombre_metodo_pago
ORDER BY monto_total_recibido DESC;
