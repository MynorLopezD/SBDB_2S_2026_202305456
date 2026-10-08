// CRUD generico para las tablas del registro (GET lista, GET uno, POST, PUT, DELETE).
const express = require('express');
const { sql, getPool } = require('./db');
const { HttpError, asyncHandler } = require('./errors');
const { normalizarFilas, entero } = require('./util');

function leerLlave(def, params) {
  const llave = {};
  for (const k of def.pk) llave[k] = entero(params[k], k);
  return llave;
}

const condicion = (def) => def.pk.map((k) => `${k} = @${k}`).join(' AND ');

function enlazar(request, def, llave) {
  def.pk.forEach((k) => request.input(k, sql.Int, llave[k]));
}

async function buscarUno(def, llave) {
  const request = (await getPool()).request();
  enlazar(request, def, llave);
  const r = await request.query(`SELECT * FROM dbo.${def.table} WHERE ${condicion(def)}`);
  return r.recordset.length ? normalizarFilas(r.recordset)[0] : null;
}

function crudRouter(def) {
  const router = express.Router();
  const rutaLlave = '/' + def.pk.map((k) => ':' + k).join('/');
  const columnas = def.columns;
  const columnasInsertables = def.identity ? Object.keys(columnas) : [...def.pk, ...Object.keys(columnas)];
  const tipos = { ...Object.fromEntries(def.pk.map((k) => [k, sql.Int])), ...columnas };

  // GET /  -> listado completo
  router.get('/', asyncHandler(async (req, res) => {
    const r = await (await getPool()).request()
      .query(`SELECT * FROM dbo.${def.table} ORDER BY ${def.pk.join(', ')}`);
    res.json(normalizarFilas(r.recordset));
  }));

  // GET /:id  -> un registro
  router.get(rutaLlave, asyncHandler(async (req, res) => {
    const fila = await buscarUno(def, leerLlave(def, req.params));
    if (!fila) throw new HttpError(404, 'Registro no encontrado');
    res.json(fila);
  }));

  // POST /  -> crear
  router.post('/', asyncHandler(async (req, res) => {
    const cuerpo = req.body || {};
    const cols = columnasInsertables.filter((c) => cuerpo[c] !== undefined);
    if (!cols.length) throw new HttpError(400, 'El cuerpo de la peticion esta vacio');
    const request = (await getPool()).request();
    cols.forEach((c) => request.input(c, tipos[c], cuerpo[c]));
    const cierre = def.identity ? ' SELECT SCOPE_IDENTITY() AS id;' : '';
    const r = await request.query(
      `INSERT INTO dbo.${def.table} (${cols.join(', ')}) VALUES (${cols.map((c) => '@' + c).join(', ')});${cierre}`);
    const llave = def.identity
      ? { [def.pk[0]]: Number(r.recordset[0].id) }
      : Object.fromEntries(def.pk.map((k) => [k, Number(cuerpo[k])]));
    res.status(201).json(await buscarUno(def, llave));
  }));

  // PUT /:id  -> actualizar (solo los campos enviados)
  router.put(rutaLlave, asyncHandler(async (req, res) => {
    const llave = leerLlave(def, req.params);
    const cuerpo = req.body || {};
    const cols = Object.keys(columnas).filter((c) => cuerpo[c] !== undefined);
    if (!cols.length) throw new HttpError(400, 'No se enviaron campos para actualizar');
    const request = (await getPool()).request();
    enlazar(request, def, llave);
    cols.forEach((c) => request.input(c, tipos[c], cuerpo[c]));
    const r = await request.query(
      `UPDATE dbo.${def.table} SET ${cols.map((c) => `${c} = @${c}`).join(', ')} WHERE ${condicion(def)}`);
    if (!r.rowsAffected[0]) throw new HttpError(404, 'Registro no encontrado');
    res.json(await buscarUno(def, llave));
  }));

  // DELETE /:id  -> eliminar
  router.delete(rutaLlave, asyncHandler(async (req, res) => {
    const llave = leerLlave(def, req.params);
    const request = (await getPool()).request();
    enlazar(request, def, llave);
    const r = await request.query(`DELETE FROM dbo.${def.table} WHERE ${condicion(def)}`);
    if (!r.rowsAffected[0]) throw new HttpError(404, 'Registro no encontrado');
    res.json({ mensaje: 'Registro eliminado', ...llave });
  }));

  return router;
}

module.exports = { crudRouter, buscarUno };
