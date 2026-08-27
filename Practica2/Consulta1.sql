-- ============================================================
-- Consulta 1: Directorio de Estudiantes Activos
-- Muestra carne, nombre completo, empresa y especialidad de la
-- plaza, filtrando unicamente colocaciones en estado 'Activa'.
-- ============================================================

SELECT
    e.carnet,
    e.nombre_completo,
    emp.nombre  AS empresa,
    esp.nombre  AS especialidad
FROM colocacion c
INNER JOIN estudiante e
    ON e.carnet = c.estudiante_id
INNER JOIN plaza p
    ON p.id_plaza = c.plaza_id
INNER JOIN empresa emp
    ON emp.id_empresa = p.empresa_id
INNER JOIN especialidad esp
    ON esp.id_especialidad = p.especialidad_id
INNER JOIN estado_colocacion ec
    ON ec.id_estado = c.estado_id
WHERE ec.nombre = 'Activa'
ORDER BY e.nombre_completo;
