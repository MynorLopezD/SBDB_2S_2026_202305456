// Clientes y Empleados: cada uno es una fila de su tabla + una fila de persona
// (supertipo). Crear, actualizar y borrar tocan ambas tablas dentro de una
// transaccion (SET XACT_ABORT ON la revierte completa ante cualquier error).
const express = require('express');
const { sql, getPool } = require('../db');
const { HttpError, asyncHandler } = require('../errors');
const { normalizarFilas, entero } = require('../util');

const PERSONA = {
  nombres: sql.NVarChar, apellidos: sql.NVarChar, telefono: sql.NVarChar,
  correo: sql.NVarChar, direccion: sql.NVarChar, id_municipio: sql.Int,
};

function subtipoRouter(cfg) {
  const router = express.Router();
  const base = `
    SELECT s.${cfg.pk}, p.id_persona, p.nombres, p.apellidos, p.telefono, p.correo, p.direccion,
           p.id_municipio, m.nombre_municipio AS municipio, ${cfg.seleccion}
    FROM dbo.${cfg.table} s
    JOIN dbo.persona p ON p.id_persona = s.id_persona
    JOIN dbo.municipio m ON m.id_municipio = p.id_municipio
    ${cfg.joins}`;

  async function buscar(id) {
    const r = await (await getPool()).request().input('id', sql.Int, id)
      .query(`${base} WHERE s.${cfg.pk} = @id`);
    return r.recordset.length ? normalizarFilas(r.recordset)[0] : null;
  }

  const columnasEnviadas = (cuerpo) => ({
    p: Object.keys(PERSONA).filter((c) => cuerpo[c] !== undefined),
    s: Object.keys(cfg.propias).filter((c) => cuerpo[c] !== undefined),
  });

  function enlazar(request, cuerpo, cols) {
    cols.p.forEach((c) => request.input(c, PERSONA[c], cuerpo[c]));
    cols.s.forEach((c) => request.input(c, cfg.propias[c], cuerpo[c]));
  }

  router.get('/', asyncHandler(async (req, res) => {
    const r = await (await getPool()).request().query(`${base} ORDER BY s.${cfg.pk}`);
    res.json(normalizarFilas(r.recordset));
  }));

  router.get('/:id', asyncHandler(async (req, res) => {
    const fila = await buscar(entero(req.params.id, 'id'));
    if (!fila) throw new HttpError(404, `${cfg.etiqueta} no encontrado`);
    res.json(fila);
  }));

  router.post('/', asyncHandler(async (req, res) => {
    const cuerpo = req.body || {};
    const cols = columnasEnviadas(cuerpo);
    if (!cols.p.length || !cols.s.length) {
      throw new HttpError(400, `Faltan campos obligatorios de persona y de ${cfg.etiqueta.toLowerCase()}`);
    }
    const request = (await getPool()).request();
    enlazar(request, cuerpo, cols);
    const r = await request.query(`
      SET XACT_ABORT ON;
      BEGIN TRANSACTION;
      INSERT INTO dbo.persona (${cols.p.join(', ')}) VALUES (${cols.p.map((c) => '@' + c).join(', ')});
      DECLARE @id_persona INT = SCOPE_IDENTITY();
      INSERT INTO dbo.${cfg.table} (id_persona, ${cols.s.join(', ')})
      VALUES (@id_persona, ${cols.s.map((c) => '@' + c).join(', ')});
      DECLARE @nuevo INT = SCOPE_IDENTITY();
      COMMIT TRANSACTION;
      SELECT @nuevo AS id;`);
    res.status(201).json(await buscar(Number(r.recordset[0].id)));
  }));

  router.put('/:id', asyncHandler(async (req, res) => {
    const id = entero(req.params.id, 'id');
    const cuerpo = req.body || {};
    const cols = columnasEnviadas(cuerpo);
    if (!cols.p.length && !cols.s.length) throw new HttpError(400, 'No se enviaron campos para actualizar');
    const pool = await getPool();
    const actual = await pool.request().input('id', sql.Int, id)
      .query(`SELECT id_persona FROM dbo.${cfg.table} WHERE ${cfg.pk} = @id`);
    if (!actual.recordset.length) throw new HttpError(404, `${cfg.etiqueta} no encontrado`);

    const request = pool.request();
    request.input('id', sql.Int, id);
    request.input('id_persona', sql.Int, actual.recordset[0].id_persona);
    enlazar(request, cuerpo, cols);
    const partes = ['SET XACT_ABORT ON;', 'BEGIN TRANSACTION;'];
    if (cols.p.length) {
      partes.push(`UPDATE dbo.persona SET ${cols.p.map((c) => `${c} = @${c}`).join(', ')} WHERE id_persona = @id_persona;`);
    }
    if (cols.s.length) {
      partes.push(`UPDATE dbo.${cfg.table} SET ${cols.s.map((c) => `${c} = @${c}`).join(', ')} WHERE ${cfg.pk} = @id;`);
    }
    partes.push('COMMIT TRANSACTION;');
    await request.query(partes.join('\n'));
    res.json(await buscar(id));
  }));

  router.delete('/:id', asyncHandler(async (req, res) => {
    const id = entero(req.params.id, 'id');
    const r = await (await getPool()).request().input('id', sql.Int, id).query(`
      SET XACT_ABORT ON;
      DECLARE @id_persona INT = (SELECT id_persona FROM dbo.${cfg.table} WHERE ${cfg.pk} = @id);
      IF @id_persona IS NULL
      BEGIN
        SELECT 0 AS borrado;
        RETURN;
      END;
      BEGIN TRANSACTION;
      DELETE FROM dbo.${cfg.table} WHERE ${cfg.pk} = @id;
      DELETE FROM dbo.persona WHERE id_persona = @id_persona;
      COMMIT TRANSACTION;
      SELECT 1 AS borrado;`);
    if (!r.recordset[0].borrado) throw new HttpError(404, `${cfg.etiqueta} no encontrado`);
    res.json({ mensaje: `${cfg.etiqueta} eliminado`, [cfg.pk]: id });
  }));

  return router;
}

const clientes = subtipoRouter({
  etiqueta: 'Cliente', table: 'cliente', pk: 'id_cliente',
  propias: { id_tipo_identificacion: sql.Int, numero_identificacion: sql.NVarChar },
  seleccion: 's.id_tipo_identificacion, ti.nombre_tipo_identificacion AS tipo_identificacion, s.numero_identificacion',
  joins: 'JOIN dbo.tipo_identificacion ti ON ti.id_tipo_identificacion = s.id_tipo_identificacion',
});

const empleados = subtipoRouter({
  etiqueta: 'Empleado', table: 'empleado', pk: 'id_empleado',
  propias: { fecha_contratacion: sql.Date, id_tienda: sql.Int, id_cargo: sql.Int },
  seleccion: 's.fecha_contratacion, s.id_tienda, t.nombre_tienda AS tienda, s.id_cargo, ca.nombre_cargo AS cargo',
  joins: `JOIN dbo.tienda t ON t.id_tienda = s.id_tienda
          JOIN dbo.cargo ca ON ca.id_cargo = s.id_cargo`,
});

module.exports = { clientes, empleados };
