# EMETER
Medidor de Energía con interfaz Modbus
## CONFIGURACION MODULO DE COMUNICACIONES BASADO EN DITEC-RPI
### control.json
{"runpi": true, "procconsumos": false, "prococupa": false, "iotwtch": true}
### serialserver.json
{"ledsta": 18, "starpi": 4, "polaridad": 1, "runpi": true, "tactclk": 86400, "puerto": "/dev/serial0", "pathd": "/home/pi/DITEC-RPI/PYTHON/DATOS/", "pathn": "/home/pi/DITEC-RPI/PYTHON/NOTX/", "pathtb": "/home/pi/DITEC-RPI/PYTHON/NOTB/"}
### txtb.json
{"runpi": true, "archivo": "EMETER_var.csv"}
### urlbase.json
{"url": "http://iot.watching.com.ec:3000"}

