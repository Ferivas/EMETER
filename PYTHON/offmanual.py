#!/usr/bin/env python
'''
listen_offrpi.py
Permite apagar de manera segura el Raspberry presionando un pulsante conectado
entre un GPIO y el GND del Rpi(pinoff)
Es necesario mantener presionado el pulsante durante aproximadamente 3 segundos
para que se apague el Rpi. Mientras se tiene presionado el pulsante, el ledsta
titila
El GPIO utilizado para conectar el pulsante se determina con un archivo de texto 
en formato json que se puede editar si se utilizan pines diferentes. 
La polaridad se refiere a la forma en que se conecta el led a la salida del GPIO.

Si no se encuentra el archivo de configuración (offmanual.json) el programa
configura las variables de la siguiente manera

{"ledsta": 18, "pinoff": 3, "polaridad": 1}

'''
import RPi.GPIO as GPIO
import subprocess
import time
import json

# led_sta=18
# pinoff=3

FILECONFIG="offmanual.json"
print("Comprueba configuracion hw inicial")

confighw=False
try:
    with open(FILECONFIG, 'r') as fp:
        dataconfig = json.load(fp)
    confighw=True
except:
    print("Configuracion default")
    configdefault={
                   'pinoff':23
}
    with open(FILECONFIG, 'w') as fp:
        json.dump(configdefault, fp)


if not confighw:
    with open(FILECONFIG, 'r') as fp:
        dataconfig = json.load(fp)
    confighw=True
    
print(dataconfig)    


pinoff=dataconfig.get('pinoff')
#starpi=27
GPIO.setmode(GPIO.BCM)
print("Listen for shutdown Rpi")
GPIO.setup(pinoff, GPIO.IN, pull_up_down=GPIO.PUD_UP)
while True:
    GPIO.wait_for_edge(pinoff, GPIO.FALLING)
    print("Ver retardo")
    counter=0
    while GPIO.input(pinoff) == False:     
        counter += 1
        time.sleep(0.5)
            
    if counter>6:
        subprocess.call(['shutdown', '-h', 'now'], shell=False)
    else:
        print("Retardo insuficiente")
