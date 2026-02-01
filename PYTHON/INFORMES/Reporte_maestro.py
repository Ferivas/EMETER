# -*- coding: utf-8 -*-
"""
Created on Sun Feb  1 11:53:29 2026

@author: Fernando

"""


import pandas as pd
import matplotlib.pyplot as plt
from fpdf import FPDF
import requests
import locale
import json


MSGTEST=True

if MSGTEST:
    FILECONFIG="test_telegram.json"
else:
    FILECONFIG="telegram.json"

try:
    print("Buscando conf inicial")
    with open(FILECONFIG,'r') as f:
        varconfig=json.load(f)
    print("Var file encontrado")
except:
    print("Inicializando conf inicial")
    varconfig={"chatid":"CHATID","tokentgram":"TOKEN","filedevices":"2601_443230323937FF171E0D-5.csv"}
    print("Guardando Var file")
    with open(FILECONFIG,'w') as f:
        json.dump(varconfig,f) 

# CONFIGURACIÓN
TOKEN = varconfig.get("tokentgram")
CHAT_ID = varconfig.get("chatid")
ARCHIVO_CSV=varconfig.get("filedevices")



try:
    locale.setlocale(locale.LC_TIME, 'es_ES.UTF-8')
except:
    pass

def formatear_tiempo(minutos_totales):
    dias = minutos_totales // (24 * 60)
    horas = (minutos_totales % (24 * 60)) // 60
    minutos = minutos_totales % 60
    res = ""
    if dias > 0: res += f"{int(dias)}d "
    if horas > 0: res += f"{int(horas)}h "
    res += f"{int(minutos)}min"
    return res

def ejecutar_sistema_completo():
    print("🚀 Iniciando procesamiento...")
    
    # 1. PROCESAR DATOS
    df = pd.read_csv(ARCHIVO_CSV, header=None, usecols=[1, 2, 4], names=['Fecha', 'Hora', 'Energia'])
    df['Energia'] = pd.to_numeric(df['Energia'], errors='coerce')
    df['Diferencia'] = df['Energia'].diff().fillna(0)
    
    fechas_dt = pd.to_datetime(df['Fecha'], dayfirst=True)
    num_mes = fechas_dt.dt.month.iloc[-1]
    nom_mes = fechas_dt.dt.month_name(locale='es_ES').iloc[-1].upper()
    etiqueta = f"{num_mes:02d}_{nom_mes}"

    energia_diaria = df.groupby('Fecha')['Energia'].agg(lambda x: (x.max() - x.min()) / 1_000_000)
    total_mwh = energia_diaria.sum()
    promedio_mwh = energia_diaria.mean()
    max_gen = energia_diaria.max()
    dia_max = energia_diaria.idxmax()
    
    esta_parado = df['Diferencia'] == 0
    disponibilidad = ((len(df) - esta_parado.sum()) / len(df)) * 100
    df['Grupo'] = (esta_parado != esta_parado.shift()).cumsum()
    max_parada_min = df[esta_parado].groupby('Grupo').size().max() * 5
    
    # 2. GENERAR GRÁFICOS (BARRAS + PASTEL)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6)) # <--- Cambiado a 1 fila, 2 columnas
    
    # Gráfico de Barras
    colores = ['seagreen' if x < max_gen else 'orange' for x in energia_diaria]
    energia_diaria.plot(kind='bar', ax=ax1, color=colores, alpha=0.8)
    ax1.axhline(promedio_mwh, color='red', linestyle='--', label=f'Promedio: {promedio_mwh:.2f}')
    ax1.set_title(f'Generación Diaria (MWh) - {nom_mes}')
    ax1.legend()
    
    # Gráfico de Pastel (Disponibilidad)
    ax2.pie([100-disponibilidad, disponibilidad], labels=['Detenido', 'Generando'], 
            autopct='%1.1f%%', colors=['#e74c3c', '#2ecc71'], startangle=140, explode=(0.1, 0))
    ax2.set_title(f'Estado Operativo - Mes {num_mes}')
    
    plt.tight_layout()
    img_name = f"Grafico_Completo_{etiqueta}.png"
    plt.savefig(img_name)
    plt.close()

    # 3. GENERAR PDF
    pdf_name = f"Reporte_Generacion_{etiqueta}.pdf"
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", 'B', 16)
    pdf.cell(0, 10, f"REPORTE DE GENERACIÓN ELÉCTRICA - {nom_mes}", ln=True, align='C')
    pdf.ln(10)
    
    pdf.set_font("Arial", size=12)
    datos_reporte = [
        f"Mes de analisis: {nom_mes} (Mes {num_mes})",
        f"Energia Total Generada: {total_mwh:.2f} MWh",
        f"Promedio Diario: {promedio_mwh:.2f} MWh/dia",
        f"Record de Generacion: {max_gen:.2f} MWh (Dia: {dia_max})",
        f"Disponibilidad del Sistema: {disponibilidad:.2f}%",
        f"Parada mas larga: {formatear_tiempo(max_parada_min)}",
        f"Rango de datos: {df['Fecha'].iloc[0]} al {df['Fecha'].iloc[-1]}"
    ]
    
    for linea in datos_reporte:
        pdf.cell(0, 8, linea, ln=True)
    
    pdf.ln(10)
    # Insertar la imagen combinada que ahora incluye ambos gráficos
    pdf.image(img_name, x=10, w=190)
    pdf.output(pdf_name)


    # 4. ENVIAR A TELEGRAM
   # print(f"Enviando imagen y PDF a Telegram...")
    
    # URL para enviar fotos y para enviar documentos
    url_photo = f"https://api.telegram.org/bot{TOKEN}/sendPhoto"
    url_doc = f"https://api.telegram.org/bot{TOKEN}/sendDocument"
    
    # Texto resumen para la leyenda de la foto
    resumen_msg = (
        f"📊 *REPORTE MENSUAL: {nom_mes}*\n\n"
        f"⚡ *Total:* {total_mwh:.2f} MWh\n"
        f"📈 *Promedio:* {promedio_mwh:.2f} MWh/día\n"
        f"🏆 *Récord:* {max_gen:.2f} MWh\n"
        f"✅ *Disponibilidad:* {disponibilidad:.2f}%"
    )

    try:
        # A. Enviar la IMAGEN primero con el resumen
        with open(img_name, 'rb') as foto:
            res_photo=requests.post(url_photo, data={
                'chat_id': CHAT_ID, 
                'caption': resumen_msg, 
                'parse_mode': 'Markdown'
            }, files={'photo': foto})
            print(f"Status Imagen: {res_photo.status_code}")
            print(f"Respuesta Imagen: {res_photo.text}")              
        
        # B. Enviar el PDF como archivo adjunto técnico
        with open(pdf_name, 'rb') as doc:
            res_pdf=requests.post(url_doc, data={
                'chat_id': CHAT_ID
            }, files={'document': doc})
            print(f"Status Imagen: {res_pdf.status_code}")
            print(f"Respuesta Imagen: {res_pdf.text}")              
            
            
        print("✅ ¡Todo listo! Imagen y PDF enviados exitosamente.")
        
    except Exception as e:
        print(f"❌ Error en el envío: {e}")

if __name__ == "__main__":
    ejecutar_sistema_completo()

