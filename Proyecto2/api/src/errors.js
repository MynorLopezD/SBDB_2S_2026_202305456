// Manejo centralizado de errores: traduce los errores de SQL Server a HTTP.

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

// mssql puede traer varios errores juntos (por ejemplo, el del trigger y otro
// posterior): se revisan todos, no solo el ultimo.
function todosLosErrores(err) {
  const lista = [];
  if (err) lista.push(err);
  if (Array.isArray(err && err.precedingErrors)) lista.push(...err.precedingErrors);
  if (err && err.originalError) lista.push(err.originalError);
  return lista;
}

function numerosSql(err) {
  return todosLosErrores(err)
    .map((e) => e.number || (e.info && e.info.number))
    .filter((n) => n !== undefined);
}

function tiene(err, numero) {
  return numerosSql(err).includes(numero);
}

function traducir(err) {
  if (err instanceof HttpError) return { status: err.status, error: err.message };

  // JSON mal formado en el cuerpo de la peticion
  if (err && err.type === 'entity.parse.failed') {
    return { status: 400, error: 'El cuerpo de la peticion no es un JSON valido' };
  }

  // --- errores lanzados por los triggers (numeros propios, ver init.sql) ---
  if (tiene(err, 50001)) return { status: 400, error: 'Stock insuficiente' };
  if (tiene(err, 50002)) return { status: 400, error: 'Producto no disponible en la tienda de la venta' };

  // --- errores estandar de SQL Server ---
  if (tiene(err, 2627) || tiene(err, 2601)) {
    return { status: 409, error: 'Registro duplicado: ya existe un valor igual en un campo unico' };
  }
  if (tiene(err, 547)) {
    const msg = String(err.message || '');
    if (/DELETE statement/i.test(msg)) {
      return { status: 409, error: 'No se puede eliminar: el registro esta referenciado por otros registros' };
    }
    return { status: 400, error: 'Referencia invalida o valor fuera de las restricciones permitidas' };
  }
  if (tiene(err, 515)) return { status: 400, error: 'Falta un campo obligatorio' };
  if (tiene(err, 245) || tiene(err, 241) || tiene(err, 242) || tiene(err, 8114) || tiene(err, 8115) || tiene(err, 220)) {
    return { status: 400, error: 'Tipo de dato o valor invalido en algun campo' };
  }
  if (err && err.code === 'EPARAM') return { status: 400, error: 'Tipo de dato o valor invalido en algun campo' };
  if (err && ['ECONNREFUSED', 'ESOCKET', 'ELOGIN', 'ETIMEOUT', 'ECONNCLOSED', 'ENOTOPEN'].includes(err.code)) {
    return { status: 503, error: 'No hay conexion con la base de datos' };
  }

  return { status: 500, error: 'Error interno del servidor' };
}

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  const { status, error } = traducir(err);
  if (status >= 500) console.error(err);
  const cuerpo = { error };
  // El mensaje original de SQL Server ayuda a depurar (y a las capturas de la revision)
  if (err && err.message && !(err instanceof HttpError) && error !== err.message) cuerpo.detalle = err.message;
  res.status(status).json(cuerpo);
}

function notFound(req, res) {
  res.status(404).json({ error: `Ruta no encontrada: ${req.method} ${req.originalUrl}` });
}

module.exports = { HttpError, asyncHandler, errorHandler, notFound, traducir };
