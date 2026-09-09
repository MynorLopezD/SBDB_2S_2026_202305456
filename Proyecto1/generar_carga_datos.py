# -*- coding: utf-8 -*-
"""
generar_carga_datos.py

Lee dataset_comercial_la_estrella.xlsx (debe estar en la MISMA carpeta que este
script) y genera carga_datos_prueba.sql en esa misma carpeta, listo para
ejecutar en SQL Developer contra el esquema "estrella" (o el que uses),
DESPUES de haber corrido 03_creacion_DB.sql.

Uso:
    python generar_carga_datos.py

Requisitos:
    pip install openpyxl

El script es re-ejecutable: cada vez que lo corras (por ejemplo, despues de
modificar o agregar filas en el Excel), el .sql generado primero BORRA el
contenido de las 19 tablas (en orden inverso de dependencias) y luego lo
vuelve a insertar completo desde el Excel actual. Asi puedes probar cambios
en el archivo de origen corriendo el mismo .sql las veces que necesites, sin
errores de llave primaria duplicada.
"""

import sys
import datetime
from pathlib import Path

try:
    import openpyxl
except ImportError:
    sys.exit(
        "Falta la libreria openpyxl. Instalala con:\n"
        "    pip install openpyxl\n"
        "y vuelve a correr este script."
    )

# ---------------------------------------------------------------------------
# Configuracion de rutas: todo relativo a la carpeta donde vive este script,
# sin importar desde donde se invoque.
# ---------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).resolve().parent
EXCEL_NAME = "dataset_comercial_la_estrella.xlsx"
EXCEL_PATH = SCRIPT_DIR / EXCEL_NAME
OUTPUT_PATH = SCRIPT_DIR / "carga_datos.sql"

if not EXCEL_PATH.exists():
    sys.exit(
        f"No encontre '{EXCEL_NAME}' en la carpeta:\n    {SCRIPT_DIR}\n"
        "Coloca el Excel en la misma carpeta que este script y vuelve a intentar."
    )

wb = openpyxl.load_workbook(EXCEL_PATH, data_only=True)

REQUIRED_SHEETS = [
    'PAIS', 'DEPARTAMENTO', 'MUNICIPIO', 'TIPO_TIENDA', 'TIPO_IDENTIFICACION',
    'CARGO', 'CATEGORIA', 'MARCA', 'ESTADO_VENTA', 'METODO_PAGO', 'TIENDA',
    'PERSONA', 'EMPLEADO', 'CLIENTE', 'PRODUCTO', 'CATALOGO_PRODUCTO',
    'VENTA', 'DESGLOSE_VENTA', 'PAGO',
]
missing = [s for s in REQUIRED_SHEETS if s not in wb.sheetnames]
if missing:
    sys.exit(
        "El Excel no tiene todas las hojas esperadas. Faltan: " + ", ".join(missing) +
        f"\nHojas encontradas: {wb.sheetnames}"
    )


def rows(sheet):
    return list(wb[sheet].iter_rows(min_row=2, values_only=True))


def esc(s):
    """Escapa comillas simples para SQL."""
    return s.replace("'", "''")


def sval(v):
    """Formatea un valor de texto (o NULL) como literal SQL."""
    if v is None:
        return "NULL"
    return "'" + esc(str(v)) + "'"


def nval(v):
    """Formatea un valor numerico (o NULL)."""
    if v is None:
        return "NULL"
    return str(v)


def dval(v):
    """Formatea una fecha como literal ANSI DATE 'YYYY-MM-DD' (o NULL)."""
    if v is None:
        return "NULL"
    if isinstance(v, datetime.datetime):
        v = v.date()
    return "DATE '" + v.isoformat() + "'"


def max_id(sheet, idx=0):
    vals = [r[idx] for r in rows(sheet) if r[idx] is not None]
    return max(vals) if vals else 0


out = []
out.append("--------------------------------------------------------------------------------")
out.append(f"-- Comercial La Estrella - Carga de datos (generado automaticamente desde {EXCEL_NAME})")
out.append("-- Re-ejecutable: primero limpia las 19 tablas y luego recarga todo desde el Excel")
out.append("-- actual. Ejecutar DESPUES de 03_creacion_DB.sql, con Ejecutar Script (F5).")
out.append("--------------------------------------------------------------------------------")
out.append("SET DEFINE OFF;")


def section(title):
    out.append("")
    out.append(f"-- ===== {title} =====")


# ---------------------------------------------------------------------------
# 0. Limpieza (orden inverso de dependencias) para que el script sea
#    re-ejecutable sin errores de llave duplicada tras modificar el Excel.
# ---------------------------------------------------------------------------
section("Limpieza previa (orden inverso de FK)")
delete_order = [
    "pago", "detalle_venta", "venta", "catalogo_tienda_producto", "producto",
    "cliente", "empleado", "persona", "tienda", "metodo_pago", "estado_venta",
    "marca", "categoria", "cargo", "tipo_identificacion", "tipo_tienda",
    "municipio", "departamento", "pais",
]
for tbl in delete_order:
    out.append(f"DELETE FROM {tbl};")

# ---------------------------------------------------------------------------
# 1-19. Carga (orden de dependencias)
# ---------------------------------------------------------------------------
section("pais")
for id_pa, nombre in rows('PAIS'):
    out.append(f"INSERT INTO pais (id_pais, nombre_pais) VALUES ({nval(id_pa)}, {sval(nombre)});")

section("departamento")
for id_dep, nombre, id_pa in rows('DEPARTAMENTO'):
    out.append(f"INSERT INTO departamento (id_departamento, nombre_departamento, id_pais) VALUES ({nval(id_dep)}, {sval(nombre)}, {nval(id_pa)});")

section("municipio")
for id_mun, nombre, id_dep in rows('MUNICIPIO'):
    out.append(f"INSERT INTO municipio (id_municipio, nombre_municipio, id_departamento) VALUES ({nval(id_mun)}, {sval(nombre)}, {nval(id_dep)});")

section("tipo_tienda")
for id_tt, nombre in rows('TIPO_TIENDA'):
    out.append(f"INSERT INTO tipo_tienda (id_tipo_tienda, nombre_tipo_tienda) VALUES ({nval(id_tt)}, {sval(nombre)});")

section("tipo_identificacion")
for id_ti, nombre in rows('TIPO_IDENTIFICACION'):
    out.append(f"INSERT INTO tipo_identificacion (id_tipo_identificacion, nombre_tipo_identificacion) VALUES ({nval(id_ti)}, {sval(nombre)});")

section("cargo")
for id_car, nombre in rows('CARGO'):
    out.append(f"INSERT INTO cargo (id_cargo, nombre_cargo) VALUES ({nval(id_car)}, {sval(nombre)});")

section("categoria")
for id_cat, nombre in rows('CATEGORIA'):
    out.append(f"INSERT INTO categoria (id_categoria, nombre_categoria) VALUES ({nval(id_cat)}, {sval(nombre)});")

section("marca")
for id_mar, nombre in rows('MARCA'):
    out.append(f"INSERT INTO marca (id_marca, nombre_marca) VALUES ({nval(id_mar)}, {sval(nombre)});")

section("estado_venta")
for id_ev, nombre in rows('ESTADO_VENTA'):
    out.append(f"INSERT INTO estado_venta (id_estado_venta, nombre_estado_venta) VALUES ({nval(id_ev)}, {sval(nombre)});")

section("metodo_pago")
for id_mp, nombre in rows('METODO_PAGO'):
    out.append(f"INSERT INTO metodo_pago (id_metodo_pago, nombre_metodo_pago) VALUES ({nval(id_mp)}, {sval(nombre)});")

section("tienda")
for id_ti, nombre, direccion, telefono, id_mun, id_tt in rows('TIENDA'):
    out.append(
        f"INSERT INTO tienda (id_tienda, nombre_tienda, direccion_tienda, telefono_tienda, id_municipio, id_tipo_tienda) "
        f"VALUES ({nval(id_ti)}, {sval(nombre)}, {sval(direccion)}, {sval(telefono)}, {nval(id_mun)}, {nval(id_tt)});"
    )

section("persona")
for id_per, nombres, apellidos, telefono, correo, direccion, id_mun in rows('PERSONA'):
    out.append(
        f"INSERT INTO persona (id_persona, nombres, apellidos, telefono, correo, direccion, id_municipio) "
        f"VALUES ({nval(id_per)}, {sval(nombres)}, {sval(apellidos)}, {sval(telefono)}, {sval(correo)}, {sval(direccion)}, {nval(id_mun)});"
    )

section("empleado")
for id_emp, fecha_cont, id_ti, id_car, id_per in rows('EMPLEADO'):
    out.append(
        f"INSERT INTO empleado (id_empleado, id_persona, fecha_contratacion, id_tienda, id_cargo) "
        f"VALUES ({nval(id_emp)}, {nval(id_per)}, {dval(fecha_cont)}, {nval(id_ti)}, {nval(id_car)});"
    )

section("cliente")
for id_cli, id_tip_ide, numero_ide, id_per in rows('CLIENTE'):
    out.append(
        f"INSERT INTO cliente (id_cliente, id_persona, id_tipo_identificacion, numero_identificacion) "
        f"VALUES ({nval(id_cli)}, {nval(id_per)}, {nval(id_tip_ide)}, {sval(numero_ide)});"
    )

section("producto")
for id_pro, nombre, descripcion, id_cat, id_mar in rows('PRODUCTO'):
    out.append(
        f"INSERT INTO producto (id_producto, nombre_producto, descripcion_producto, id_categoria, id_marca) "
        f"VALUES ({nval(id_pro)}, {sval(nombre)}, {sval(descripcion)}, {nval(id_cat)}, {nval(id_mar)});"
    )

section("catalogo_tienda_producto")
for precio, existencia, id_ti, id_pro in rows('CATALOGO_PRODUCTO'):
    out.append(
        f"INSERT INTO catalogo_tienda_producto (id_tienda, id_producto, precio_vigente, existencia_actual) "
        f"VALUES ({nval(id_ti)}, {nval(id_pro)}, {nval(precio)}, {nval(existencia)});"
    )

section("venta")
for id_ven, fecha_ven, id_ti, id_emp, id_cli, id_ev in rows('VENTA'):
    out.append(
        f"INSERT INTO venta (id_venta, fecha_venta, id_tienda, id_empleado, id_cliente, id_estado_venta) "
        f"VALUES ({nval(id_ven)}, {dval(fecha_ven)}, {nval(id_ti)}, {nval(id_emp)}, {nval(id_cli)}, {nval(id_ev)});"
    )

section("detalle_venta")
for cantidad, precio_uni, subtotal, id_ven, id_pro in rows('DESGLOSE_VENTA'):
    out.append(
        f"INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario, subtotal) "
        f"VALUES ({nval(id_ven)}, {nval(id_pro)}, {nval(cantidad)}, {nval(precio_uni)}, {nval(subtotal)});"
    )

section("pago")
for id_pag, monto, id_mp, id_ven in rows('PAGO'):
    out.append(
        f"INSERT INTO pago (id_pago, id_venta, id_metodo_pago, monto_pagado) "
        f"VALUES ({nval(id_pag)}, {nval(id_ven)}, {nval(id_mp)}, {nval(monto)});"
    )

out.append("")
out.append("COMMIT;")

# ---------------------------------------------------------------------------
# Resincroniza las IDENTITY para que la proxima insercion sin ID explicito
# continue despues del maximo ID que haya en el Excel en este momento.
# ---------------------------------------------------------------------------
out.append("")
out.append("--------------------------------------------------------------------------------")
out.append("-- Resincroniza las secuencias IDENTITY con el maximo ID actual de cada tabla")
out.append("--------------------------------------------------------------------------------")
resync_tables = [
    ("pais", "id_pais", "PAIS", 0),
    ("departamento", "id_departamento", "DEPARTAMENTO", 0),
    ("municipio", "id_municipio", "MUNICIPIO", 0),
    ("tipo_tienda", "id_tipo_tienda", "TIPO_TIENDA", 0),
    ("tipo_identificacion", "id_tipo_identificacion", "TIPO_IDENTIFICACION", 0),
    ("cargo", "id_cargo", "CARGO", 0),
    ("categoria", "id_categoria", "CATEGORIA", 0),
    ("marca", "id_marca", "MARCA", 0),
    ("estado_venta", "id_estado_venta", "ESTADO_VENTA", 0),
    ("metodo_pago", "id_metodo_pago", "METODO_PAGO", 0),
    ("tienda", "id_tienda", "TIENDA", 0),
    ("persona", "id_persona", "PERSONA", 0),
    ("empleado", "id_empleado", "EMPLEADO", 0),
    ("cliente", "id_cliente", "CLIENTE", 0),
    ("producto", "id_producto", "PRODUCTO", 0),
    ("venta", "id_venta", "VENTA", 0),
    ("pago", "id_pago", "PAGO", 0),
]
for tbl, col_, sheet, idx in resync_tables:
    maxv = max_id(sheet, idx)
    out.append(f"ALTER TABLE {tbl} MODIFY {col_} GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH {maxv + 1});")

OUTPUT_PATH.write_text("\n".join(out), encoding="utf-8")

# ---------------------------------------------------------------------------
# Resumen en pantalla, para confirmar de un vistazo que el Excel se leyo bien
# (por ejemplo, si agregaste un cliente, aqui deberias ver el conteo subir).
# ---------------------------------------------------------------------------
print(f"Listo. Generado: {OUTPUT_PATH}")
print()
print("Filas leidas por tabla:")
for sheet in REQUIRED_SHEETS:
    print(f"  {sheet:24s} {len(rows(sheet))}")
