#!/usr/bin/env python
'''
vinmonitor.py
Monitorea si hay alimentación principal leyendo un pin de entrada del RPI.
El GPIO utilizado para monitorear el voltaje de alimentación se determina en
con un archivo de texto en formato json que se puede editar si se utilizan pines diferentes. 
Si no se encuentra el archivo de configuración (vinmonitor.json) el programa
configura las variables de la siguiente manera

{"pinmonitor": 18}

'''
import RPi.GPIO as GPIO
import time
import json
import requests

# led_sta=18
# pinoff=3

FILECONFIG="vinmonitor.json"
print("Comprueba configuracion hw inicial")

confighw=False
try:
    with open(FILECONFIG, 'r') as fp:
        dataconfig = json.load(fp)
    confighw=True
except:
    print("Configuracion default")
    configdefault={'pinmonitor':18,"chatid":"CHATID","tokentgram":"TOKEN"}
    with open(FILECONFIG, 'w') as fp:
        json.dump(configdefault, fp)


if not confighw:
    with open(FILECONFIG, 'r') as fp:
        dataconfig = json.load(fp)
    confighw=True
    
print(dataconfig)    


PIN_MONITOREADO=dataconfig.get('pinmonitor')
CHATID=dataconfig.get("chatid")
BOTID=dataconfig.get("tokentgram")


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

print("pinmon>",PIN_MONITOREADO)

newestado=False

def callback(pin):
    global newestado
    print("Cambio detectado:", GPIO.input(pin))
    newestado=True

GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_MONITOREADO, GPIO.IN)

GPIO.add_event_detect(PIN_MONITOREADO, GPIO.BOTH, callback=callback, bouncetime=50)

print("Monitoreando pin con interrupciones. CTRL+C para salir.")

txvinok=False
txvinfalla=False
try:
    while True:
        time.sleep(1)
        if newestado:
            newestado=False
            estado=GPIO.input(PIN_MONITOREADO)
            if estado:
                if not txvinok:
                    print("Tx Vin OK")
                    msg="Se reestablecio voltaje de alimentacion principal en EMETER"
                    sndmsgtelegram(msg,CHATID,BOTID)                    
                    txvinok=True
                    txvinfalla=False
            else:
                if not txvinfalla:
                    print("Tx Vin Falla")
                    msg="FALLA en voltaje de alimentacion principal en EMETER"
                    sndmsgtelegram(msg,CHATID,BOTID)                    
                    txvinfalla=True
                    txvinok=False
            

except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()



