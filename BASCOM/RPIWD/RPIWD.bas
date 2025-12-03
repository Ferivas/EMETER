'RPIWD.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para apagar RPI por falta de energía. Se asume que elRPI queda energizado
' por un UPS que tiene al menos dos minutos de backup. En el RPi esta corriendo servicio
' para pagar el RPi por detección depulso en bajo de GIPO3.
' Cuando se reestablece la energía el micro espera Twaitonseg para generar un pulso en GPIO3
'
'


$regfile = "m328pdef.dat"
$baud = 9600
$version 0 , 1 , 87
$crystal = 8000000
$projecttime = 39

Const Micro = 1                                             '0 ATTiny 1 = ATMega
Const Numled = 2


#if Micro = 0
$regfile = "attiny85.dat"
#endif



$hwstack = 80
$swstack = 80
$framesize = 80


'Constantes
'Const Twaitoffseg = 1800
'Const Twaitoff = Twaitoffseg * 100

'Const Twaitonseg = 30
'Const Twaiton = Twaitonseg * 100



'Configuracion de entradas/salidas
#if Micro = 0
Led1 Alias Portb.1                                          'LED VERDE
Config Led1 = Output

Led2 Alias Portb.4                                          'LED ROJO
Config Led2 = Output

Vinmon Alias Pinb.0
Config Vinmon = Input
'Set Portb.0

Starpi Alias Pinb.2
Config Starpi = Input
'Set Portb.5

'Rpipinoff Alias Portc.4
'Set Rpipinoff
'Config Rpipinoff = Output


Pinoff Alias Portb.3
Reset Pinoff
Config Pinoff = Output
#endif


#if Micro = 1
Led1 Alias Portb.0                                          'LED VERDE
Config Led1 = Output

Led2 Alias Portb.1                                          'LED ROJO
Config Led2 = Output


Vinmon Alias Pind.2
Config Vinmon = Input
Set Portd.2

Starpi Alias Pinc.0
Config Starpi = Input
'Set Portc.0

'Rpipinoff Alias Portc.4
'Set Rpipinoff
'Config Rpipinoff = Output
Stavin Alias Portb.3
Config Stavin = Output


Pinoff Alias Portc.1
Reset Pinoff
Config Pinoff = Output
#endif

'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 1024                     'Ints a 100Hz si Timer0=184
On Timer0 Int_timer0
Enable Timer0
Start Timer0

#if Micro = 1
' Puerto serial 1
Open "com1:" For Binary As #1
On Urxc At_ser1
Enable Urxc
#endif

Enable Interrupts


'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "RPIWD_archivos.bas"



'Programa principal


#if Micro = 1
Call Inivar()
Atsnd = "RPIsta=" + Str(starpi) + ", VinMon=" + Str(vinmon)
Print #1 , Atsnd
#endif

Do
#if Micro = 1
   If Sernew = 1 Then                                       'DATOS SERIAL 1
      Reset Sernew
      Print #1 , "SER1=" ; Serproc
      Call Procser()
   End If
#endif

   If Starpi = 1 Then
      If Starpi <> Starpiant Then
         Starpiant = Starpi
         #if Micro = 1
         Print #1 , "RPI ON"
         #endif
      End If
      If Vinmon = 0 Then
         If Vinmon <> Vinmonant Then
            Vinmonant = Vinmon
            #if Micro = 1
            Print #1 , "FALLA AC, RPI ON"
            #endif
         End If
         Estado_led(1) = 2
         Estado_led(2) = 0
         Set Inicntroff
         Reset Stavin
      Else
         If Vinmon <> Vinmonant Then
            Vinmonant = Vinmon
            #if Micro = 1
            Print #1 , "AC OK, RPI ON "
            #endif
         End If
         Estado_led(1) = 1
         Estado_led(2) = 0
         Reset Inicntroff
         Reset Inicntron
         Set Stavin
      End If
   Else
      If Starpi <> Starpiant Then
         Starpiant = Starpi
         #if Micro = 1
         Print #1 , "RPI OFF"
         #endif
      End If

      If Vinmon = 1 Then
         If Vinmon <> Vinmonant Then
            Vinmonant = Vinmon
            #if Micro = 1
            Print #1 , "AC OK, RPI OFF"
            #endif
         End If
         Set Inicntron
         Estado_led(1) = 0
         Estado_led(2) = 1
         Set Stavin
      Else
         If Vinmon <> Vinmonant Then
            Vinmonant = Vinmon
            #if Micro = 1
            Print #1 , "FALLA AC, RPI OFF"
            #endif
         End If
         Estado_led(1) = 0
         Estado_led(2) = 2
         Reset Inicntron
         Reset Inicntroff
         Reset Stavin
      End If

   End If

   If Inipulsooff = 1 Then
      Reset Inipulsooff
      #if Micro = 1
      Print #1 , "APAGAR RPI"
      #endif
      Estado_led(2) = 16
      'Reset Pinoff
      'Reset Rpipinoff
      Set Pinoff
      Wait 6
      'Set Pinoff
      'Set Rpipinoff
      Reset Pinoff
   End If

   If Inipulsoon = 1 Then
      Reset Inipulsoon
      Estado_led(1) = 16
      'Reset Pinoff
      #if Micro = 1
      Print #1 , "ENCENDER RPI"
      #endif
      Set Pinoff
      'Reset Rpipinoff
      Wait 2
      'Set Pinoff
      Reset Pinoff
      'Set Rpipinoff
   End If

   If Inicntron = 1 Then
      If Cntron <> Cntronant Then
         Print #1 , "CntrON=" ; Cntron
         Cntronant = Cntron
      End If
   End If

   If Inicntroff = 1 Then
      If Cntroff <> Cntroffant Then
         Print #1 , "CntrOFF=" ; Cntroff
         Cntroffant = Cntroff
      End If
   End If

   If Inivariables = 1 Then
      Reset Inivariables
      Call Inivar()
   End If

Loop