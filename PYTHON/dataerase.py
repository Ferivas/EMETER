# -*- coding: utf-8 -*-
"""
Created on Mon Oct 27 21:29:30 2025

@author: Fernando
"""

import requests
from datetime import datetime
import json
import time


FILECONFIG="daterase.json"

try:
    print("Buscando conf inicial")
    with open(FILECONFIG,'r') as f:
        varconfig=json.load(f)
    print("Var file encontrado")
except:
    print("Inicializando conf inicial")
    varconfig={"url":"https://thingsboard.cloud","user":"username","password":"psw",
               "chatid":"CHATID","tokentgram":"TOKEN","iddev":"IDDEVICE"}
    print("Guardando Var file")
    with open(FILECONFIG,'w') as f:
        json.dump(varconfig,f) 


USERNAME=varconfig.get("user")
PASSWORD=varconfig.get("password")
DEVICEID=varconfig.get("iddev")
CHATID=varconfig.get("chatid")
BOTID=varconfig.get("tokentgram")
URL=varconfig.get("url")

def borrar_telemetria(url, username, password, device_id, keys, fecha_inicio, fecha_fin):
    """
    Función simple para borrar telemetría
    
    Ejemplo de uso:
    borrar_telemetria(
        url='https://thingsboard.cloud',
        username='tu-email@ejemplo.com',
        password='tu-contraseña',
        device_id='abc123',
        keys='temperature,humidity',
        fecha_inicio='2024-01-01',
        fecha_fin='2024-01-31'
    )
    """
    
    # 1. Autenticarse
    login_response = requests.post(
        f"{url}/api/auth/login",
        json={"username": username, "password": password}
    )
    token = login_response.json()['token']
    
    # 2. Convertir fechas a timestamps
    start_ts = int(datetime.fromisoformat(fecha_inicio).timestamp() * 1000)
    end_ts = int(datetime.fromisoformat(fecha_fin).timestamp() * 1000)
    
    # 3. Eliminar telemetría
    delete_response = requests.delete(
        f"{url}/api/plugins/telemetry/DEVICE/{device_id}/timeseries/delete",
        params={
            'keys': keys,
            'deleteAllDataForKeys': False,
            'startTs': start_ts,
            'endTs': end_ts
        },
        headers={'X-Authorization': f'Bearer {token}'}
    )
    
    if delete_response.status_code == 200:
        print("✓ Telemetría EMETER eliminada exitosamente")
        msg="✓ Telemetría EMETER eliminada exitosamente"
    else:
        print(f"✗ Error: {delete_response.status_code} - {delete_response.text}")
        msg=f"✗ Error: {delete_response.status_code} - {delete_response.text}"
    
    sndmsgtelegram(msg, CHATID, BOTID)
    return delete_response.status_code == 200

def sndmsgtelegram(msg,chatid,botid):
    urlbase="https://api.telegram.org"
    url=urlbase+'/bot'+botid+'/sendMessage?chat_id='+chatid+'&disable_web_page_preview=1&parse_mode=Markdown&text='+msg
    try:
        response = requests.get(url)
        if response.status_code == 200:
            results = response.json()
            print(results)
        else:
            print("Error code %s" % response.status_code)
    except:
        print("Error snd Telegram") 


flagconfig=True
if USERNAME=="username":
    flagconfig=False
    
while not flagconfig:
    print("Sin config inicial")
    time.sleep(10)

# Uso
borrar_telemetria(
    url='https://thingsboard.cloud',
    username=USERNAME,
    password=PASSWORD,
    device_id=DEVICEID, #DAMMER
    #device_id='9b48c2f0-af8a-11f0-b150-2710a8915e1d', #CONDADO
    #device_id='992a11e0-4c93-11f0-b94b-f3b14d0c4306', #DITECNET LABORATORIO
    keys= 'POWER_FULL_A,POWER_FULL_B,POWER_FULL_C,POWER_FULL_SUMMARY',
    fecha_inicio='2025-12-30 08:30:00',
    #fecha_inicio='2025-11-05',
    fecha_fin='2026-12-30 14:20:00'
    #fecha_fin='2025-11-06'
)