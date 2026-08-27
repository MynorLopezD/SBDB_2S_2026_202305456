-- ============================================================
-- Consulta 4: Estudiantes en Repitencia
-- Lista estudiantes con primera_practica = 0 (equivalente a
-- ES_REPITENCIA = 1 del dataset original), mostrando instituto,
-- el contacto empresarial responsable de su plaza (quien valida
-- sus bitacoras) y el estado actual de su colocacion.
-- ============================================================

SELECT
    e.nombre_completo  AS estudiante,
    i.nombre           AS instituto,
    con.nombre         AS contacto_validador,
    ec.nombre          AS estado_colocacion
FROM estudiante e
INNER JOIN colocacion c
    ON c.estudiante_id = e.carnet
INNER JOIN instituto i
    ON i.id_instituto = e.instituto_id
INNER JOIN plaza p
    ON p.id_plaza = c.plaza_id
INNER JOIN contacto con
    ON con.id_contacto = p.contacto_id
INNER JOIN estado_colocacion ec
    ON ec.id_estado = c.estado_id
WHERE e.primera_practica = 0
ORDER BY e.nombre_completo;
