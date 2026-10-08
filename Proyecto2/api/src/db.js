// Conexion a SQL Server (pool unico y reutilizable).
const path = require('path');
const sql = require('mssql');

// Lee primero el .env de la raiz del proyecto (el mismo que usa docker-compose)
// y luego, si existe, un .env dentro de api/. Las variables ya definidas no se pisan.
require('dotenv').config({ path: path.join(__dirname, '..', '..', '.env'), quiet: true });
require('dotenv').config({ quiet: true });

const config = {
  server: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '1433', 10),
  user: process.env.DB_USER || 'sa',
  password: process.env.MSSQL_SA_PASSWORD || process.env.DB_PASSWORD || 'Estrella2026!',
  database: process.env.DB_NAME || 'ComercialLaEstrella',
  options: {
    encrypt: false,               // el contenedor usa un certificado autofirmado
    trustServerCertificate: true,
  },
  pool: { max: 10, min: 0, idleTimeoutMillis: 30000 },
  connectionTimeout: 15000,
};

let poolPromise = null;

function getPool() {
  if (!poolPromise) {
    poolPromise = new sql.ConnectionPool(config).connect().catch((err) => {
      poolPromise = null; // permite reintentar en la siguiente peticion
      throw err;
    });
  }
  return poolPromise;
}

module.exports = { sql, getPool, config };
