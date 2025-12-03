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

# led_sta=18
# pinoff=3

FILECONFIG="listen_offrpi.json"
print("Comprueba configuracion hw inicial")

confighw=False
try:
    with open(FILECONFIG, 'r') as fp:
        dataconfig = json.load(fp)
    confighw=True
except:
    print("Configuracion default")
    configdefault={'pinmonitor':18}
    with open(FILECONFIG, 'w') as fp:
        json.dump(configdefault, fp)


if not confighw:
    with open(FILECONFIG, 'r') as fp:
        dataconfig = json.load(fp)
    confighw=True
    
print(dataconfig)    


PIN_MONITOREADO=dataconfig.get('pinmonitor')


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
                    txvinok=True
                    txvinfalla=False
            else:
                if not txvinfalla:
                    print("Tx Vin Falla")
                    txvinfalla=True
                    txvinok=True
            

except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()



