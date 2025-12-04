# EMETER
Equipo para leer los valores de un Medidor de Energía con interfaz Modbus y enviar estos datos a una plataforma de monitoreo basado en Thingsboard.<br>
Este equipo mide las variables y parametros eléctricos que entrega un medidor de energía de ABB (ABB Power EM400 EM400-T (5A)). El EM400 trabaja como un esclavo modbus y permite acceder a sus registros configurando el puerto serial a una velocidad de 19200bps (8,N,1). Para leer los registros Modbus del EM400 se utiliza un microcontrolador AVR (ATMega1284P) el cual esta programado para trabajar como un master Modbus consultando periodicamente los registros Modbus que se consideran de interés. Adicionalmente este microcontrolador también monitorea el estado de una entrada digital que puede ser utilizada como sensor de puerta.

## COMPONENTES
* Conversor DC-DC de entrada (24V de entrada a 12V de entrada)
* Mini UPS
* Raspberry Pi 4
* Tarjeta de monitoreo Raspberry
* Tarjeta interfaz Raspberry Modbus
* Conversor DC-DC elevador (9V entrada a 24V de salida) para energizar el Emeter
* Router LTE
* Rele Wifi

 <img width="1000" alt="Componentes" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Componentes.jpg">
  
### CONVERSOR DC-DC DE ENTRADA
Este conversor permite disminuir el voltaje de entrada de 24VDC a 12VDC para utilizar este voltaje a la entrada del mini UPS que se carga con este voltaje.
El voltaje de entrada de 24V utiliza una bornera verde de 2 pines

 <img width="1000" alt="ConversorDCDC" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Conversorentrada.jpg">

 ### MINI UPS
 Este miniUPS de corriente continua incluye un cargador de batería interno y 2 pilas de Litio con una cpacidad de 2000mAh /14.8Wh. Se carga a 12VDC con un ca corriente máxima de 2A y tiene tres salidas de voltaje:<br>
 * 5V
 * 9V
 * 12V
<img width="1000" alt="Componentes" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/MiniUPS.jpg">

### RASPBERRY PI 4
Es el encargado de manejar las comunicaciones, permitiendo enviar los datos a un plataforma de monitoreo de IOT (Thingsboard). También se puede reprogramar el firmware de la tarjeta de interfaz Modbus.
<img width="600" alt="Raspberry" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Rpi4.jpg">

### TARJETA DE MONITOREO DEL RASPBERRY
Esta tarjeta se encarga de mantener operativo al Raspberry monitoreando el voltaje de alimentación del miniUPS. En caso de una falla de energía se activa un temporizador que mantiene encendido al Raspberry Pi 4 por un tiempo máximo de 1800 segndos (media hora) en caso de que no exista alimentación principal(no se detecta voltaje de carga en el miniUPS). Si se supera este tiempo se activa una señal para apagar de forma segura el Raspberry. El Raspberry se encuentra corriendo continuamente un script que decta el cambio de estado del GPIO3 de manera de realizar un apagado seguro (shutdown) si este pin se pone en bajo por más de seis segundos. En caso de que la limentación principal se reestablezca antes de la media hora el Raspberry continúa operando normalmente. <br>
Si el Raspberry se apaga, la tarjeta de monitoreo permanece en bajo consumo de potencia esperando que se reestablezca la alimentación principal. Cuando se detecta de nuevo la alimentación principal, la tarjeta espera 2 minutos antes de encender automáticamnete el Raspberry por medio de un pulso de 1 segundo en el GPIO3. De esta manera se garantiza que no se produzcan apagados por falta de energía que pueden corromper la memoria SD que guarda el sistema operativo del Raspberry.<br>
 <img width="600" alt="Monitoreo" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/TarjetaMonitoreo.jpg"> 
 
En caso de necesitar apagar inmediatamente el Raspberry, como por ejemplo transportar el equipo, se puede utilizar un botón manual (que se muestra en la figura siguiente) y que apaga al Raspberry sesi se mantiene presioando por más de seis segundos. Luego de comprobar que el Rpi se apaga es necesario desconectar el conector USB del miniUPS que proporciona los 5V para evitar que la tarjeta de monitoreo vuelva a encender automáticamente al Rpi.<br>
<img width="600" alt="Apagado manual" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Boton_offmanual.jpg">

La tarjeta de monitoreo incluye dos leds de señalizacion marcados como LED3 (color rojo) y LED4 (color verde) que permiten determinar el estado de la tarjeta de monitoreo y el Rpi. Estos estados y su señalización es la siguiente:<br>
* Con energía principal y Rpi encendido el LED4 (verde) parpadea una vez cada segundo.
* Sin energía principal y RPI encendido el LED4 (verde) parpadea dos veces cada segundo.
* Sin energía principal y Rpi apagado, el LED3 (rojo) parpadea dos veces cada segundo.
* Con energía principal y Rpi apagado, el LED# (rojo) parpadea una vez cada segundo.
<img width="600" alt="Señalizacion Monitoreo" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Leds_se%C3%B1alizacion_monitoreo_Rpi.jpg">

### TARJETA INTERFAZ RASPBERRY MODBUS
Esta tarjeta se encarga de leer los registros Modbus del Emeter ABB. La tarjeta actúa como maestro en el bus Modbus y consulta periodicamente al Emeter el cual esta configurado como esclavo.<br>
Esta tarjeta también monitorea una entrada digital en donde se va a conectar un sensor mágnetico de puerta.
<img width="600" alt="Interfaz Modbus" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Conexi%C3%B3n_Modbus.jpg">

La señal del bus Modbus (B,A y S ) se conectan en los terminales respectivos del Emeter como se muestra en la figura.
<img width="600" alt="Conexion Modbus" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Conexi%C3%B3n_Modbus_Emeter.jpg">

Esta tarjeta consulta los registros erqueridos al Emeter y envía la información obtenida al Raspberry por medio del puerto serial. Para este fin se utiliza un conector de 3 pines con los cables cruzados como se muestra en la figura.
<img width="600" alt="Conector interfaz" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/Cable_cruzado_Rpi_modbus.jpg">
<img width="600" alt="Conexión interfaz" src="https://github.com/Ferivas/EMETER/blob/main/DOCS/ConexionRpiInterfaz.jpg">


Se tiene tres leds de señalización en esta tarjeta. Dos de ellos (LED2 y LED3) muestran la transmisión y recepción de datos en el bus modbus. El LED3 parpadea cuando el maestro envia datos al escalvo y el LED2 parpadea cuando se recibe una respuesta del esclavo. El LED2 (led blanco) señaliza si existe comunicación entre la tarjeta y el Raspberry. Si no se ha establecido comunicaicón este led parpadea 2 veces cada segundo, mientras que si la comunicación es normal el led parpadea una vez por segundo.

### CONVERSOR DC-DC ELEVADOR
Para asegurar el respaldo de energía de la alimentación del emter se utiliza la salida de 9VDC del miniUPS para que el conversor elevador suba este voltaje hasta 24VDC.

### ROUTER LTE
Para poder utilizar internet para las comunicaciones se utiliza un router LTE marca Cudy. Este genera una red Wifi donde se conecta el Raspberry Pi para enviar los datos a la plataforma de monitoreo

### RELE WIFI
Para monitorear que nos inhiba el router LTE se utiliza un rele para reiniciar el modem en caso de que se pierdan las comunicaciones con el proveedor de datos celular. La condición es que se pierdan comunicaciones por más de 20 minutos, en cuyo caso se apaga el relé por cinco segundo y luego se lo vuelve a encender. El router se energiza a tráves de la salida de 12VDC del miniUPPS y por los contactos normalmente cerrados de un relé que se utiliza para apagar/encender el router para reiniciarlo.


## REGISTROS MODBUS
Los registros Modbus están descritos a partir de la página 5 en el siguiente documento:

https://github.com/Ferivas/EMETER/blob/main/DOCS/Emeter_Modbus-1.pdf

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









