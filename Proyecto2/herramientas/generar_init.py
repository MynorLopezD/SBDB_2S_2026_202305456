# -*- coding: utf-8 -*-
"""
generar_init.py

Lee dataset_comercial_la_estrella.xlsx (en la MISMA carpeta que este script) y
genera ../init.sql, el script que ejecuta el contenedor al iniciar:

    sql/01_esquema.sql        -> base de datos, tablas y restricciones
    (datos del Excel)         -> INSERTs en T-SQL, generados aqui
    sql/03_vistas_triggers.sql-> vistas analiticas y triggers

Uso:
    python generar_init.py

Requisito:
    pip install openpyxl

Si el Excel cambia (filas nuevas o modificadas), vuelve a correr este script y
reinicia el contenedor desde cero (docker compose down -v ; docker compose up -d).
"""

import datetime
import sys
from pathlib import Path

try:
    import openpyxl
except ImportError:
    sys.exit("Falta openpyxl. Instalalo con: pip install openpyxl")

AQUI = Path(__file__).resolve().parent
EXCEL = AQUI / "dataset_comercial_la_estrella.xlsx"
SALIDA = AQUI.parent / "init.sql"
BATCH = 500  # filas por INSERT (el maximo de T-SQL es 1000)

if not EXCEL.exists():
    sys.exit(f"No encuentro {EXCEL.name} junto a este script ({AQUI}).")

wb = openpyxl.load_workbook(EXCEL, data_only=True)


def filas(hoja):
    return [f for f in wb[hoja].iter_rows(min_row=2, values_only=True) if f[0] is not None or any(v is not None for v in f)]


# ---------------------------------------------------------------------------
# Literales T-SQL
# ---------------------------------------------------------------------------
def lit_str(valor):
    """N'...' en ASCII puro: cualquier caracter fuera de 32..126 se escribe con NCHAR()."""
    if valor is None:
        return "NULL"
    s = str(valor)
    partes, buf = [], ""
    # se recorre en unidades UTF-16 para cubrir tambien caracteres fuera del BMP
    unidades = s.encode("utf-16-le")
    for i in range(0, len(unidades), 2):
        u = int.from_bytes(unidades[i:i + 2], "little")
        if 32 <= u <= 126:
            buf += "''" if chr(u) == "'" else chr(u)
        else:
            if buf:
                partes.append(f"N'{buf}'")
                buf = ""
            partes.append(f"NCHAR({u})")
    if buf:
        partes.append(f"N'{buf}'")
    return " + ".join(partes) if partes else "N''"


def lit_num(valor):
    return "NULL" if valor is None else str(int(valor)) if float(valor).is_integer() else str(valor)


def lit_dec(valor):
    return "NULL" if valor is None else f"{float(valor):.2f}"


def lit_fecha(valor):
    if valor is None:
        return "NULL"
    if isinstance(valor, datetime.datetime):
        valor = valor.date()
    return f"'{valor.isoformat()}'"


# ---------------------------------------------------------------------------
# Definicion de la carga: (tabla, hoja, columnas destino, conversores, identity)
# Los conversores trabajan sobre la fila de la hoja segun su orden de columnas.
# ---------------------------------------------------------------------------
S, N, D, F = lit_str, lit_num, lit_dec, lit_fecha

CARGAS = [
    # tabla, hoja, [(columna, indice_en_hoja, conversor)], identity
    ("pais", "PAIS", [("id_pais", 0, N), ("nombre_pais", 1, S)], True),
    ("departamento", "DEPARTAMENTO", [("id_departamento", 0, N), ("nombre_departamento", 1, S), ("id_pais", 2, N)], True),
    ("municipio", "MUNICIPIO", [("id_municipio", 0, N), ("nombre_municipio", 1, S), ("id_departamento", 2, N)], True),
    ("tipo_tienda", "TIPO_TIENDA", [("id_tipo_tienda", 0, N), ("nombre_tipo_tienda", 1, S)], True),
    ("tipo_identificacion", "TIPO_IDENTIFICACION", [("id_tipo_identificacion", 0, N), ("nombre_tipo_identificacion", 1, S)], True),
    ("cargo", "CARGO", [("id_cargo", 0, N), ("nombre_cargo", 1, S)], True),
    ("categoria", "CATEGORIA", [("id_categoria", 0, N), ("nombre_categoria", 1, S)], True),
    ("marca", "MARCA", [("id_marca", 0, N), ("nombre_marca", 1, S)], True),
    ("estado_venta", "ESTADO_VENTA", [("id_estado_venta", 0, N), ("nombre_estado_venta", 1, S)], True),
    ("metodo_pago", "METODO_PAGO", [("id_metodo_pago", 0, N), ("nombre_metodo_pago", 1, S)], True),
    ("tienda", "TIENDA", [("id_tienda", 0, N), ("nombre_tienda", 1, S), ("direccion_tienda", 2, S),
                          ("telefono_tienda", 3, S), ("id_municipio", 4, N), ("id_tipo_tienda", 5, N)], True),
    ("persona", "PERSONA", [("id_persona", 0, N), ("nombres", 1, S), ("apellidos", 2, S), ("telefono", 3, S),
                            ("correo", 4, S), ("direccion", 5, S), ("id_municipio", 6, N)], True),
    ("empleado", "EMPLEADO", [("id_empleado", 0, N), ("fecha_contratacion", 1, F), ("id_tienda", 2, N),
                              ("id_cargo", 3, N), ("id_persona", 4, N)], True),
    ("cliente", "CLIENTE", [("id_cliente", 0, N), ("id_tipo_identificacion", 1, N),
                            ("numero_identificacion", 2, S), ("id_persona", 3, N)], True),
    ("producto", "PRODUCTO", [("id_producto", 0, N), ("nombre_producto", 1, S), ("descripcion_producto", 2, S),
                              ("id_categoria", 3, N), ("id_marca", 4, N)], True),
    ("catalogo_tienda_producto", "CATALOGO_PRODUCTO", [("precio_vigente", 0, D), ("existencia_actual", 1, N),
                                                       ("id_tienda", 2, N), ("id_producto", 3, N)], False),
    ("venta", "VENTA", [("id_venta", 0, N), ("fecha_venta", 1, F), ("id_tienda", 2, N), ("id_empleado", 3, N),
                        ("id_cliente", 4, N), ("id_estado_venta", 5, N)], True),
    # subtotal (indice 2) NO se inserta: es columna calculada; abajo se verifica que coincida
    ("detalle_venta", "DESGLOSE_VENTA", [("cantidad", 0, N), ("precio_unitario", 1, D),
                                         ("id_venta", 3, N), ("id_producto", 4, N)], False),
    ("pago", "PAGO", [("id_pago", 0, N), ("monto_pagado", 1, D), ("id_metodo_pago", 2, N), ("id_venta", 3, N)], True),
]

# Verificacion previa: el subtotal del Excel debe ser cantidad * precio_unitario
for cantidad, precio, subtotal, _v, _p in [f[:5] for f in filas("DESGLOSE_VENTA")]:
    if round(cantidad * precio, 2) != round(subtotal, 2):
        sys.exit(f"Subtotal inconsistente en DESGLOSE_VENTA: {cantidad} x {precio} != {subtotal}")

bloques = ["--------------------------------------------------------------------------------",
           "-- 2. DATOS INICIALES (generados desde dataset_comercial_la_estrella.xlsx)",
           "-- Se cargan ANTES de crear los triggers para no alterar el inventario.",
           "--------------------------------------------------------------------------------"]
resumen = []

for tabla, hoja, cols, identity in CARGAS:
    datos = filas(hoja)
    resumen.append((tabla, len(datos)))
    nombres = ", ".join(c[0] for c in cols)
    bloques.append(f"\n-- {tabla} ({len(datos)} filas)")
    if identity:
        bloques.append(f"SET IDENTITY_INSERT dbo.{tabla} ON;")
    for i in range(0, len(datos), BATCH):
        lote = datos[i:i + BATCH]
        valores = ",\n".join("    (" + ", ".join(conv(f[idx]) for _n, idx, conv in cols) + ")" for f in lote)
        bloques.append(f"INSERT INTO dbo.{tabla} ({nombres}) VALUES\n{valores};")
    if identity:
        bloques.append(f"SET IDENTITY_INSERT dbo.{tabla} OFF;")
    bloques.append("GO")

esquema = (AQUI / "sql" / "01_esquema.sql").read_text(encoding="utf-8")
objetos = (AQUI / "sql" / "03_vistas_triggers.sql").read_text(encoding="utf-8")
contenido = esquema.rstrip() + "\n\n" + "\n".join(bloques) + "\n\n" + objetos.rstrip() + "\n"

# init.sql debe ser ASCII puro (no depende de la codificacion del cliente sqlcmd)
try:
    contenido.encode("ascii")
except UnicodeEncodeError as e:
    sys.exit(f"init.sql contiene un caracter no ASCII en la posicion {e.start}: {contenido[e.start-20:e.start+20]!r}")

SALIDA.write_text(contenido, encoding="ascii", newline="\n")
print(f"Generado: {SALIDA}")
print("Filas por tabla:")
for tabla, n in resumen:
    print(f"  {tabla:26s} {n}")
