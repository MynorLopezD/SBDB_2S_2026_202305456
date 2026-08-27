-- ============================================================
-- Consulta 5: Auditoria de Bitacoras
-- Colocaciones en estado 'Activa' que NO tienen ningun registro
-- de bitacora durante el mes calendario actual (desde el dia 1
-- del mes hasta hoy), mostrando al catedratico supervisor
-- responsable para su llamado de atencion.
-- ============================================================

SELECT
    c.id_colocacion,
    e.nombre_completo   AS estudiante,
    cat.nombre           AS catedratico_responsable
FROM colocacion c
INNER JOIN estado_colocacion ec
    ON ec.id_estado = c.estado_id
INNER JOIN estudiante e
    ON e.carnet = c.estudiante_id
INNER JOIN catedratico cat
    ON cat.id_catedratico = c.catedratico_id
WHERE ec.nombre = 'Activa'
  AND NOT EXISTS (
        SELECT 1
        FROM bitacora b
        WHERE b.colocacion_id = c.id_colocacion
          AND b.fecha >= TRUNC(SYSDATE, 'MM')
      )
ORDER BY cat.nombre;
