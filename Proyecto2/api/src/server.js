// Servidor Express: API REST de Comercial La Estrella.
const express = require('express');
const { getPool } = require('./db');
const { errorHandler, notFound, asyncHandler } = require('./errors');
const { crudRouter } = require('./crud');
const { entidades, detalleVenta } = require('./registry');
const { clientes, empleados } = require('./routes/subtipos');
const productosGet = require('./routes/productos');
const ventas = require('./routes/ventas');
const detallesPost = require('./routes/detalles');
const reportes = require('./routes/reportes');

function crearApp() {
  const app = express();
  app.use(express.json());

  app.get('/api/health', asyncHandler(async (req, res) => {
    const r = await (await getPool()).request().query('SELECT DB_NAME() AS base');
    res.json({ estado: 'ok', base_de_datos: r.recordset[0].base });
  }));

  // Rutas personalizadas primero: tienen prioridad sobre el CRUD generico.
  app.use('/api/clientes', clientes);
  app.use('/api/empleados', empleados);
  app.use('/api/ventas', ventas);
  app.use('/api/detalles-venta', detallesPost, crudRouter(detalleVenta));
  app.use('/api/productos', productosGet);
  app.use('/api/reportes', reportes);

  // CRUD generico (GET, POST, PUT, DELETE) para el resto de las tablas.
  for (const def of entidades) app.use(`/api/${def.path}`, crudRouter(def));

  app.use(notFound);
  app.use(errorHandler);
  return app;
}

async function conectarConReintentos(intentos = 10) {
  for (let i = 1; i <= intentos; i += 1) {
    try {
      await getPool();
      console.log('Conectado a SQL Server.');
      return;
    } catch (err) {
      console.log(`No se pudo conectar a SQL Server (intento ${i}/${intentos}): ${err.message}`);
      await new Promise((r) => setTimeout(r, 3000));
    }
  }
  console.error('No hay conexion con SQL Server. Revisa que el contenedor este arriba: docker compose ps');
}

if (require.main === module) {
  const puerto = parseInt(process.env.API_PORT || process.env.PORT || '3000', 10);
  crearApp().listen(puerto, () => console.log(`API escuchando en http://localhost:${puerto}/api`));
  conectarConReintentos();
}

module.exports = { crearApp };
