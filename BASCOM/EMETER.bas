'Main.bas
'
'                 WATCHING Soluciones Tecnológicas
'                    Fernando Vásquez - 25.06.15
'
' Programa para almacenar los datos que se reciben por el puerto serial a una
' memoria SD
'


$regfile = "m1284pdef.dat"                                  ' used micro
$crystal = 16000000                                         ' used xtal
$baud = 9600                                                ' baud rate we want
$hwstack = 128
$swstack = 128
$framesize = 128

$projecttime = 45
$version 0 , 0 , 46


$lib "modbus.lbx"

'Declaracion de constantes
Const Numtxaut = 4
Const Numtxaut_mas_uno = Numtxaut + 1
Const Addr0 = &H3100
Const Addr1 = &H310C



'Configuracion de entradas/salidas
Led1 Alias Portb.0                                          'LED ROJO
Config Led1 = Output


'Configuración de Interrupciones
'TIMER0
Config Timer0 = Timer , Prescale = 1024                     'Ints a 100Hz si Timer0=184
On Timer0 Int_timer0
Enable Timer0
Start Timer0


'TIMER2 Utilizado aqui con cristal de 32.765kHZ generando ints cada 1s
Config Date = Dmy , Separator = /
Config Clock = Soft , Gosub = Sectic
Date$ = "07/01/25"
Time$ = "11:28:00"

' Puerto serial 1
Open "com1:" For Binary As #1
On Urxc At_ser1
Enable Urxc

Config Com2 = 115200 , Synchrone = 0 , Parity = None , Stopbits = 1 , Databits = 8 , Clockpol = 1
Open "COM2:" For Binary As #4
Dir485 Alias Portb.2
'Config Print3 = Dir485 , Mode = Set
Config Dir485 = Output
On Urxc1 At_ser2
Enable Urxc1


Enable Interrupts


'*******************************************************************************
'* Archivos incluidos
'*******************************************************************************
$include "EMETER_archivos.bas"



'Programa principal

Call Inivar()

' Lee hora del servidor
Do
   If Sernew = 1 Then                                       'DATOS SERIAL 1
      Reset Sernew
      Print #1 , "SER1=" ; Serproc
      Call Procser()
   End If
Loop Until Actclk = 1


Do

   If Sernew = 1 Then                                       'DATOS SERIAL 1
      Reset Sernew
      Print #1 , "SER1=" ; Serproc
      Call Procser()
   End If

   For Ntx = 1 To Numtxaut
      Ntx0 = Ntx - 1
      If Iniauto.ntx0 = 1 Then
         Reset Iniauto.ntx0
         Print #1 , "TXAUT " ; Ntx
         Select Case Ntx :
            Case 1:                                         'Txaut1
               Print #1 , "AUT1"

            Case 2:                                         'Txaut1
               Print #1 , "AUT2"

            Case 3:
               Print #1 , "AUT3"

            Case 4:
               Print #1 , "Read MDB"
               Call Txmdb()
         End Select
      End If
   Next

   If Newmod = 1 Then
      Reset Newmod
      Call Rxmdb()
   End If

Loop