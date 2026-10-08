const { HttpError } = require('./errors');

// Las columnas DATE llegan como objetos Date (UTC medianoche): se devuelven como "YYYY-MM-DD".
function normalizarFilas(filas) {
  return filas.map((fila) => {
    const copia = {};
    for (const [k, v] of Object.entries(fila)) {
      copia[k] = v instanceof Date ? v.toISOString().slice(0, 10) : v;
    }
    return copia;
  });
}

function entero(valor, nombre) {
  const n = Number(valor);
  if (valor === undefined || valor === null || valor === '' || !Number.isInteger(n)) {
    throw new HttpError(400, `El parametro ${nombre} debe ser un numero entero`);
  }
  return n;
}

module.exports = { normalizarFilas, entero };
