-- ============================================================
-- Consulta 3: Carga de Validacion por Contacto Empresarial
-- Para el rango julio-agosto 2026, muestra el contacto, la
-- empresa a la que pertenece, y la suma total de horas que ha
-- validado en las bitacoras de los estudiantes.
-- ============================================================

SELECT
    con.nombre                 AS contacto,
    emp.nombre                 AS empresa,
    SUM(b.horas_trabajadas)    AS horas_validadas
FROM bitacora b
INNER JOIN contacto con
    ON con.id_contacto = b.validado_por
INNER JOIN empresa emp
    ON emp.id_empresa = con.empresa_id
WHERE b.fecha BETWEEN TO_DATE('2026-07-01','YYYY-MM-DD')
                   AND TO_DATE('2026-08-31','YYYY-MM-DD')
GROUP BY con.nombre, emp.nombre
ORDER BY horas_validadas DESC;
