# -*- coding: utf-8 -*-
"""
Created on Fri Jan 30 19:25:27 2026

@author: Fernando
"""

import pandas as pd
import matplotlib.pyplot as plt
import locale
import json

FILECONFIG="reportemeter.json"

try:
    print("Buscando conf inicial")
    with open(FILECONFIG,'r') as f:
        varconfig=json.load(f)
    print("Var file encontrado")
except:
    print("Inicializando conf inicial")
    varconfig={"filedevices":"2601_443230323937FF171E0D-5.csv"}
    print("Guardando Var file")
    with open(FILECONFIG,'w') as f:
        json.dump(varconfig,f) 

ARCHIVO=varconfig.get("filedevices")

# Intentar configurar el idioma a español
try:
    locale.setlocale(locale.LC_TIME, 'es_ES.UTF-8')
except:
    pass

def formatear_tiempo(minutos_totales):
    dias = minutos_totales // (24 * 60)
    horas = (minutos_totales % (24 * 60)) // 60
    minutos = minutos_totales % 60
    resultado = ""
    if dias > 0: resultado += f"{int(dias)}d "
    if horas > 0: resultado += f"{int(horas)}h "
    resultado += f"{int(minutos)}min"
    return resultado

def obtener_info_mes(df):
    fechas = pd.to_datetime(df['Fecha'], dayfirst=True)
    mes_num = fechas.dt.month.iloc[-1]
    mes_nombre = fechas.dt.month_name(locale='es_ES').iloc[-1].upper()
    return f"{mes_num:02d}", mes_nombre

def generar_reporte_local(input_file):
    df = pd.read_csv(input_file, header=None, usecols=[1, 2, 4], names=['Fecha', 'Hora', 'Energia'])
    df['Energia'] = pd.to_numeric(df['Energia'], errors='coerce')
    df['Diferencia'] = df['Energia'].diff().fillna(0)
    
    num_mes, nom_mes = obtener_info_mes(df)
    etiqueta_mes = f"{num_mes}_{nom_mes}"
    
    # Cálculos de Energía
    energia_por_dia = df.groupby('Fecha')['Energia'].agg(lambda x: (x.max() - x.min()) / 1_000_000)
    total_energia_mwh = energia_por_dia.sum()
    promedio_diario_mwh = energia_por_dia.mean() # <--- NUEVO CÁLCULO
    
    # Análisis de Disponibilidad
    esta_parado = df['Diferencia'] == 0
    disponibilidad = ((len(df) - esta_parado.sum()) / len(df)) * 100
    
    # Parada más larga
    df['Grupo'] = (esta_parado != esta_parado.shift()).cumsum()
    max_minutos_parado = df[esta_parado].groupby('Grupo').size().max() * 5
    tiempo_formateado = formatear_tiempo(max_minutos_parado)
    
    file_txt = f'Reporte_{etiqueta_mes}.txt'
    file_img = f'Grafico_{etiqueta_mes}.png'
    
    # 5. Guardar Reporte con PROMEDIO
    with open(file_txt, 'w', encoding='utf-8') as f:
        f.write(f"📊 REPORTE DE GENERACIÓN - MES {num_mes} ({nom_mes})\n")
        f.write("-" * 45 + "\n")
        f.write(f"⚡ Energía Total: {total_energia_mwh:.2f} MWh\n")
        f.write(f"📈 Promedio Diario: {promedio_diario_mwh:.2f} MWh/día\n") # <--- LÍNEA NUEVA
        f.write(f"✅ Disponibilidad: {disponibilidad:.2f}%\n")
        f.write(f"⏳ Parada más larga: {tiempo_formateado}\n")
        f.write(f"📅 Rango: {df['Fecha'].iloc[0]} al {df['Fecha'].iloc[-1]}\n")

    # 6. Guardar Gráfico con línea de promedio
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Gráfica de barras + Línea de promedio
    energia_por_dia.plot(kind='bar', ax=ax1, color='seagreen', alpha=0.7)
    ax1.axhline(promedio_diario_mwh, color='red', linestyle='--', label=f'Promedio: {promedio_diario_mwh:.2f}')
    ax1.set_title(f'Energía Diaria MWh - Mes {num_mes}')
    ax1.legend()
    
    # Pastel
    ax2.pie([100-disponibilidad, disponibilidad], labels=['Detenido', 'Generando'], 
            autopct='%1.1f%%', colors=['#e74c3c', '#2ecc71'], startangle=140)
    ax2.set_title(f'Disponibilidad Mes {num_mes}')
    
    plt.tight_layout()
    plt.savefig(file_img)
    plt.close()
    
    print(f"✅ Reporte y Gráfico con promedios generados: {etiqueta_mes}")

if __name__ == "__main__":
    generar_reporte_local(ARCHIVO)