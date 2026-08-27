-- ============================================================
-- Consulta 2: Oferta de Plazas por Empresa
-- Muestra cada empresa afiliada junto con la cantidad total de
-- plazas que ofrece, ordenado de mayor a menor.
-- LEFT JOIN para incluir tambien empresas sin plazas registradas
-- (apareceria con 0).
-- ============================================================

SELECT
    emp.nombre           AS empresa,
    COUNT(p.id_plaza)    AS cantidad_plazas
FROM empresa emp
LEFT JOIN plaza p
    ON p.empresa_id = emp.id_empresa
GROUP BY emp.nombre
ORDER BY cantidad_plazas DESC;
