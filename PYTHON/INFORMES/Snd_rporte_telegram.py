# -*- coding: utf-8 -*-
"""
Created on Fri Jan 30 18:33:24 2026

@author: Fernando
"""

import requests
import glob
import os
import json
import time


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
    varconfig={"chatid":"CHATID","tokentgram":"TOKEN"}
    print("Guardando Var file")
    with open(FILECONFIG,'w') as f:
        json.dump(varconfig,f) 

# CONFIGURACIÓN
TOKEN = varconfig.get("tokentgram")
CHAT_ID = varconfig.get("chatid")



def enviar_ultimo_reporte():
    # Buscar los archivos más recientes creados por el procesador
    try:
        archivo_txt = max(glob.glob("Reporte_*.txt"), key=os.path.getctime)
        archivo_img = max(glob.glob("Grafico_*.png"), key=os.path.getctime)
    except ValueError:
        print("❌ No se encontraron archivos de reporte.")
        return

    # Enviar Texto
    with open(archivo_txt, 'r', encoding='utf-8') as f:
        mensaje = f.read()
    
    url_msg = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
    requests.post(url_msg, data={'chat_id': CHAT_ID, 'text': mensaje})

    # Enviar Imagen
    url_photo = f"https://api.telegram.org/bot{TOKEN}/sendPhoto"
    with open(archivo_img, 'rb') as foto:
        res_photo =requests.post(url_photo, data={'chat_id': CHAT_ID}, files={'photo': foto})
        print(f"Status Imagen: {res_photo.status_code}")
        print(f"Respuesta Imagen: {res_photo.text}")        
    
    print(f"🚀 Reporte {archivo_txt} enviado a Telegram.")
    

        

if __name__ == "__main__":
    flagconfig=True
    if TOKEN=="TOKEN":
        flagconfig=False
        
    while not flagconfig:
        print("Sin config inicial")
        time.sleep(10)    
    enviar_ultimo_reporte()