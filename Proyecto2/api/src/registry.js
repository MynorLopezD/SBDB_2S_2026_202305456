// Definicion de las tablas que usan el CRUD generico.
// Los nombres de tabla y de columna salen SOLO de aqui (nunca de la peticion),
// y todos los valores viajan como parametros: no hay inyeccion SQL posible.
const { sql } = require('./db');

const I = sql.Int;
const S = sql.NVarChar;
const D = sql.Decimal(10, 2);
const DT = sql.Date;

// path: segmento de la ruta | table: tabla | pk: llave (una o dos columnas)
// identity: la PK la genera el motor | columns: columnas escribibles y su tipo
const entidades = [
  { path: 'paises', table: 'pais', pk: ['id_pais'], identity: true, columns: { nombre_pais: S } },
  { path: 'departamentos', table: 'departamento', pk: ['id_departamento'], identity: true,
    columns: { nombre_departamento: S, id_pais: I } },
  { path: 'municipios', table: 'municipio', pk: ['id_municipio'], identity: true,
    columns: { nombre_municipio: S, id_departamento: I } },
  { path: 'tipos-tienda', table: 'tipo_tienda', pk: ['id_tipo_tienda'], identity: true,
    columns: { nombre_tipo_tienda: S } },
  { path: 'tipos-identificacion', table: 'tipo_identificacion', pk: ['id_tipo_identificacion'], identity: true,
    columns: { nombre_tipo_identificacion: S } },
  { path: 'cargos', table: 'cargo', pk: ['id_cargo'], identity: true, columns: { nombre_cargo: S } },
  { path: 'categorias', table: 'categoria', pk: ['id_categoria'], identity: true,
    columns: { nombre_categoria: S } },
  { path: 'marcas', table: 'marca', pk: ['id_marca'], identity: true, columns: { nombre_marca: S } },
  { path: 'estados-venta', table: 'estado_venta', pk: ['id_estado_venta'], identity: true,
    columns: { nombre_estado_venta: S } },
  { path: 'metodos-pago', table: 'metodo_pago', pk: ['id_metodo_pago'], identity: true,
    columns: { nombre_metodo_pago: S } },
  { path: 'tiendas', table: 'tienda', pk: ['id_tienda'], identity: true,
    columns: { nombre_tienda: S, direccion_tienda: S, telefono_tienda: S, id_municipio: I, id_tipo_tienda: I } },
  { path: 'personas', table: 'persona', pk: ['id_persona'], identity: true,
    columns: { nombres: S, apellidos: S, telefono: S, correo: S, direccion: S, id_municipio: I } },
  { path: 'productos', table: 'producto', pk: ['id_producto'], identity: true,
    columns: { nombre_producto: S, descripcion_producto: S, id_categoria: I, id_marca: I } },
  // llave compuesta: el precio y la existencia dependen de la pareja tienda-producto
  { path: 'catalogo', table: 'catalogo_tienda_producto', pk: ['id_tienda', 'id_producto'], identity: false,
    columns: { precio_vigente: D, existencia_actual: I } },
  { path: 'pagos', table: 'pago', pk: ['id_pago'], identity: true,
    columns: { id_venta: I, id_metodo_pago: I, monto_pagado: D } },
];

// detalle_venta tiene llave compuesta y su POST es personalizado (precio por defecto);
// el resto de sus operaciones usan el CRUD generico. subtotal es columna calculada.
const detalleVenta = {
  path: 'detalles-venta', table: 'detalle_venta', pk: ['id_venta', 'id_producto'], identity: false,
  columns: { cantidad: I, precio_unitario: D },
};

module.exports = { entidades, detalleVenta, tipos: { I, S, D, DT } };
