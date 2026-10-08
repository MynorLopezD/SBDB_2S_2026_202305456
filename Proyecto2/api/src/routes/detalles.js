// POST /api/detalles-venta: registra un producto en una venta. Si no se envia
// precio_unitario se usa el precio vigente del producto en la tienda de la venta.
// El descuento de inventario y el rechazo por falta de stock los hace el
// trigger Insert_Detalle en la base de datos: aqui solo se traduce su error.
const express = require('express');
const { sql, getPool } = require('../db');
const { HttpError, asyncHandler } = require('../errors');
const { entero } = require('../util');
const { buscarUno } = require('../crud');
const { detalleVenta } = require('../registry');

const router = express.Router();

router.post('/', asyncHandler(async (req, res) => {
  const b = req.body || {};
  const idVenta = entero(b.id_venta, 'id_venta');
  const idProducto = entero(b.id_producto, 'id_producto');
  const cantidad = entero(b.cantidad, 'cantidad');

  const request = (await getPool()).request();
  request.input('id_venta', sql.Int, idVenta);
  request.input('id_producto', sql.Int, idProducto);
  request.input('cantidad', sql.Int, cantidad);
  request.input('precio_unitario', sql.Decimal(10, 2), b.precio_unitario ?? null);
  await request.query(`
    INSERT INTO dbo.detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    SELECT @id_venta, @id_producto, @cantidad, COALESCE(@precio_unitario, c.precio_vigente)
    FROM dbo.venta v
    LEFT JOIN dbo.catalogo_tienda_producto c
           ON c.id_tienda = v.id_tienda AND c.id_producto = @id_producto
    WHERE v.id_venta = @id_venta;`);

  const fila = await buscarUno(detalleVenta, { id_venta: idVenta, id_producto: idProducto });
  if (!fila) throw new HttpError(404, 'La venta indicada no existe');
  res.status(201).json(fila);
}));

module.exports = router;
