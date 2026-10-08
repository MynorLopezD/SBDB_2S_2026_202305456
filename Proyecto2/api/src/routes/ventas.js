// Ventas: el listado y el detalle de una venta incluyen su estado, el total de
// la venta y el total pagado, para poder comprobar el cambio automatico a PAGADA
// (lo hace el trigger Insert_Pago en la base de datos, no esta API).
const express = require('express');
const { sql, getPool } = require('../db');
const { HttpError, asyncHandler } = require('../errors');
const { normalizarFilas, entero } = require('../util');

const router = express.Router();

const BASE = `
  SELECT v.id_venta, v.fecha_venta, v.id_tienda, t.nombre_tienda AS tienda, v.id_empleado, v.id_cliente,
         v.id_estado_venta, ev.nombre_estado_venta AS estado,
         ISNULL(tv.total_venta, 0) AS total_venta, ISNULL(tp.total_pagado, 0) AS total_pagado
  FROM dbo.venta v
  JOIN dbo.tienda t ON t.id_tienda = v.id_tienda
  JOIN dbo.estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
  LEFT JOIN (SELECT id_venta, SUM(subtotal) AS total_venta FROM dbo.detalle_venta GROUP BY id_venta) tv
         ON tv.id_venta = v.id_venta
  LEFT JOIN (SELECT id_venta, SUM(monto_pagado) AS total_pagado FROM dbo.pago GROUP BY id_venta) tp
         ON tp.id_venta = v.id_venta`;

const TIPOS = {
  fecha_venta: sql.Date, id_tienda: sql.Int, id_empleado: sql.Int, id_cliente: sql.Int, id_estado_venta: sql.Int,
};

async function buscar(id) {
  const pool = await getPool();
  const v = await pool.request().input('id', sql.Int, id).query(`${BASE} WHERE v.id_venta = @id`);
  if (!v.recordset.length) return null;
  const detalles = await pool.request().input('id', sql.Int, id).query(`
    SELECT d.id_producto, p.nombre_producto AS producto, d.cantidad, d.precio_unitario, d.subtotal
    FROM dbo.detalle_venta d JOIN dbo.producto p ON p.id_producto = d.id_producto
    WHERE d.id_venta = @id ORDER BY d.id_producto`);
  const pagos = await pool.request().input('id', sql.Int, id).query(`
    SELECT pg.id_pago, pg.id_metodo_pago, mp.nombre_metodo_pago AS metodo_pago, pg.monto_pagado
    FROM dbo.pago pg JOIN dbo.metodo_pago mp ON mp.id_metodo_pago = pg.id_metodo_pago
    WHERE pg.id_venta = @id ORDER BY pg.id_pago`);
  return { ...normalizarFilas(v.recordset)[0], detalles: detalles.recordset, pagos: pagos.recordset };
}

router.get('/', asyncHandler(async (req, res) => {
  const r = await (await getPool()).request().query(`${BASE} ORDER BY v.id_venta`);
  res.json(normalizarFilas(r.recordset));
}));

router.get('/:id', asyncHandler(async (req, res) => {
  const venta = await buscar(entero(req.params.id, 'id'));
  if (!venta) throw new HttpError(404, 'Venta no encontrada');
  res.json(venta);
}));

// Estado: se acepta por nombre ("estado": "REGISTRADA") o por id (id_estado_venta).
function valorEstado(cuerpo) {
  return cuerpo.id_estado_venta !== undefined
    ? '@id_estado_venta'
    : '(SELECT id_estado_venta FROM dbo.estado_venta WHERE nombre_estado_venta = @estado)';
}

router.post('/', asyncHandler(async (req, res) => {
  const b = req.body || {};
  const request = (await getPool()).request();
  request.input('fecha_venta', sql.Date, b.fecha_venta ?? null);
  request.input('id_tienda', sql.Int, b.id_tienda ?? null);
  request.input('id_empleado', sql.Int, b.id_empleado ?? null);
  request.input('id_cliente', sql.Int, b.id_cliente ?? null);
  if (b.id_estado_venta !== undefined) request.input('id_estado_venta', sql.Int, b.id_estado_venta);
  else request.input('estado', sql.NVarChar, b.estado ?? 'REGISTRADA');
  const r = await request.query(`
    INSERT INTO dbo.venta (fecha_venta, id_tienda, id_empleado, id_cliente, id_estado_venta)
    VALUES (ISNULL(@fecha_venta, CAST(GETDATE() AS DATE)), @id_tienda, @id_empleado, @id_cliente, ${valorEstado(b)});
    SELECT SCOPE_IDENTITY() AS id;`);
  res.status(201).json(await buscar(Number(r.recordset[0].id)));
}));

router.put('/:id', asyncHandler(async (req, res) => {
  const id = entero(req.params.id, 'id');
  const b = req.body || {};
  const sets = [];
  const request = (await getPool()).request();
  request.input('id', sql.Int, id);
  for (const col of ['fecha_venta', 'id_tienda', 'id_empleado', 'id_cliente']) {
    if (b[col] !== undefined) { sets.push(`${col} = @${col}`); request.input(col, TIPOS[col], b[col]); }
  }
  if (b.id_estado_venta !== undefined) {
    sets.push('id_estado_venta = @id_estado_venta');
    request.input('id_estado_venta', sql.Int, b.id_estado_venta);
  } else if (b.estado !== undefined) {
    sets.push(`id_estado_venta = ${valorEstado(b)}`);
    request.input('estado', sql.NVarChar, b.estado);
  }
  if (!sets.length) throw new HttpError(400, 'No se enviaron campos para actualizar');
  const r = await request.query(`UPDATE dbo.venta SET ${sets.join(', ')} WHERE id_venta = @id`);
  if (!r.rowsAffected[0]) throw new HttpError(404, 'Venta no encontrada');
  res.json(await buscar(id));
}));

// Eliminacion LOGICA: el enunciado permite "cambiar su estado logico". Una venta
// no se borra (tiene detalles y pagos): pasa a ANULADA y deja de contar en los
// reportes de facturacion.
router.delete('/:id', asyncHandler(async (req, res) => {
  const id = entero(req.params.id, 'id');
  const r = await (await getPool()).request().input('id', sql.Int, id).query(`
    UPDATE dbo.venta
    SET id_estado_venta = (SELECT id_estado_venta FROM dbo.estado_venta WHERE nombre_estado_venta = 'ANULADA')
    WHERE id_venta = @id`);
  if (!r.rowsAffected[0]) throw new HttpError(404, 'Venta no encontrada');
  res.json({ mensaje: 'Venta anulada (eliminacion logica)', id_venta: id, estado: 'ANULADA' });
}));

module.exports = router;
