// Reportes: el API no hace JOINs, solo consulta las vistas creadas en SQL Server.
const express = require('express');
const { getPool } = require('../db');
const { asyncHandler } = require('../errors');
const { normalizarFilas } = require('../util');

const router = express.Router();

const consulta = (sqlTexto) => asyncHandler(async (req, res) => {
  const r = await (await getPool()).request().query(sqlTexto);
  res.json(normalizarFilas(r.recordset));
});

router.get('/ventas-ubicacion', consulta('SELECT * FROM dbo.Vista_Ventas_Ubicacion ORDER BY total_facturado DESC'));
router.get('/top-productos', consulta('SELECT * FROM dbo.Vista_Top_Productos ORDER BY unidades_vendidas DESC'));
router.get('/saldos-pendientes', consulta('SELECT * FROM dbo.Vista_Saldos_Pendientes ORDER BY saldo_pendiente DESC'));

module.exports = router;
