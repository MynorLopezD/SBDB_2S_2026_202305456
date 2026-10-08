// GET /api/productos/:id incluye las existencias por tienda (en este modelo el
// stock vive en catalogo_tienda_producto). Con ?tienda=ID agrega ademas
// existencia_actual y precio_vigente de esa tienda, util para comprobar el
// descuento de inventario despues de registrar un detalle de venta.
const express = require('express');
const { sql, getPool } = require('../db');
const { HttpError, asyncHandler } = require('../errors');
const { normalizarFilas, entero } = require('../util');

const router = express.Router();

router.get('/:id_producto', asyncHandler(async (req, res) => {
  const id = entero(req.params.id_producto, 'id_producto');
  const pool = await getPool();

  const p = await pool.request().input('id', sql.Int, id).query(`
    SELECT p.*, c.nombre_categoria AS categoria, m.nombre_marca AS marca
    FROM dbo.producto p
    JOIN dbo.categoria c ON c.id_categoria = p.id_categoria
    JOIN dbo.marca m ON m.id_marca = p.id_marca
    WHERE p.id_producto = @id`);
  if (!p.recordset.length) throw new HttpError(404, 'Registro no encontrado');

  const ex = await pool.request().input('id', sql.Int, id).query(`
    SELECT ct.id_tienda, t.nombre_tienda AS tienda, ct.precio_vigente, ct.existencia_actual
    FROM dbo.catalogo_tienda_producto ct
    JOIN dbo.tienda t ON t.id_tienda = ct.id_tienda
    WHERE ct.id_producto = @id
    ORDER BY ct.id_tienda`);

  const producto = { ...normalizarFilas(p.recordset)[0], existencias: ex.recordset };
  if (req.query.tienda !== undefined) {
    const idTienda = entero(req.query.tienda, 'tienda');
    const fila = ex.recordset.find((e) => e.id_tienda === idTienda);
    producto.id_tienda = idTienda;
    producto.existencia_actual = fila ? fila.existencia_actual : null;
    producto.precio_vigente = fila ? fila.precio_vigente : null;
  }
  res.json(producto);
}));

module.exports = router;
