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
## ARCHIVO DE CONFIGURACION THINGSBOARD
El archivo es csv con el siguiente formato:

N,Idserial,Token,Nodo,field1,field2,field3,field4,field5,field6,field7,field8,D<br>
1,IDserial-1,tokenID_Device,EMETER,VOLTAGE_A,VOLTAGE_B,VOLTAGE_C,FREQUENCY,CURRENT_A,CURRENT_B,CURRENT_C,,D<br>
2,IDserial-2,tokenID_Device,EMETER,POWER_FULL_SUMMARY,POWER_FULL_A,POWER_FULL_B,POWER_FULL_C,,,,,D<br>
## CONFIGURACION DE LISTADOIBT y LISTADOMANGO
Es necesario correr primero el script control.py y configurar el canal de listado de ibt porqué es utilizado por serialserver.py para validar los ID de las tramas.
El canal de IBT debe tener una entrada con el IDserial del ATMega1284P que lee por Modbus los registros del EMETER.<br>
Monitoreo de tempeartura del Rpi en http://iot.watching.com.ec:3000/channels/357









