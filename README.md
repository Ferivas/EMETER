# EMETER
Medidor de Energía con interfaz Modbus.<br>
Este equipo mide las variables y parametros eléctricos que entrega un medidor de energía de ABB (ABB Power EM400 EM400-T (5A)).
Este medidor trabaja como un esclavo modbus y permite acceder a sus registros configurando el puerto serial a una velocidad de 19200bps (8,N,1). Para leer los registros Modbus del EM400 se utiliza un microcontrolador AVR (ATMega1284P) el cual esta programado para trabajar como un master Modbus consultando periodicamente los registros Modbus que se consideran de interés. Adicionalmente este microcntrolador también monitorea el estado de una entrada digital que puede ser utilizada como sensor de puerta y también puede activar/desactivar un relé que se utiliza para energizar un módem LTE de Mikrotik el cual se encarga de proporcionar conectividad de Internet al equipo.

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









