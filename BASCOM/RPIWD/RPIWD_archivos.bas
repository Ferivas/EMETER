'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*  SD_Archivos.bas                                                        *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*                                                                             *
'*  Variables, Subrutinas y Funciones                                          *
'* WATCHING SOLUCIONES TECNOLOGICAS                                            *
'* 25.06.2015                                                                  *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

$nocompile
$projecttime = 24

'*******************************************************************************
'Declaracion de subrutinas
'*******************************************************************************
#if Micro = 1
Declare Sub Inivar()
Declare Sub Procser()
#endif


'*******************************************************************************
'Declaracion de variables
'*******************************************************************************
Dim Tmpb As Byte

#if Micro = 1
Dim Cmdtmp As String * 6
Dim Atsnd As String * 200
Dim Cmderr As Byte
Dim Tmpstr8 As String * 16
Dim Tmpstr52 As String * 52
#endif

'Variables TIMER0
Dim T0c As Byte , T00 As Byte
Dim Num_ventana As Byte
Dim Estado As Long
Dim Estado_led(numled) As Byte
Dim Kt As Byte
Dim Kt0 As Byte
Dim Iluminar As Bit

Dim Inicntron As Bit
Dim Inicntroff As Bit

Dim Cntroff As Word
Dim Cntroffant As Word
Dim Inipulsooff As Bit
Dim Cntron As Word
Dim Cntronant As Word
Dim Inipulsoon As Bit
Dim Starpiant As Bit
Dim Vinmonant As Bit
Dim Inivariables As Bit


Dim Twaiton As Word
Dim Twaitoff As Word
Dim Twaitoneep As Eram Word
Dim Twaitoffeep As Eram Word


#if Micro = 1
'Variables SERIAL0
Dim Ser_ini As Bit , Sernew As Bit
Dim Numpar As Byte
Dim Cmdsplit(34) As String * 20
Dim Serdata As String * 200 , Serrx As Byte , Serproc As String * 200
#endif



'*******************************************************************************
'* END public part                                                             *
'*******************************************************************************


Goto Loaded_arch

'*******************************************************************************
' INTERRUPCIONES
'*******************************************************************************

#if Micro = 1
'*******************************************************************************
' Subrutina interrupcion de puerto serial 1
'*******************************************************************************
At_ser1:
   Serrx = Udr

   Select Case Serrx
      Case "$":
         Ser_ini = 1
         Serdata = ""

      Case 13:
         If Ser_ini = 1 Then
            Ser_ini = 0
            Serdata = Serdata + Chr(0)
            Serproc = Serdata
            Sernew = 1
            'Enable Timer0
         End If

      Case Is > 31
         If Ser_ini = 1 Then
            Serdata = Serdata + Chr(serrx)
         End If

   End Select

Return
#endif



'*******************************************************************************



'*******************************************************************************
' TIMER0
'*******************************************************************************
Int_timer0:
   Timer0 = &HB2                                            '100Hz
   Incr T0c
   T0c = T0c Mod 8
   If T0c = 0 Then
      Num_ventana = Num_ventana Mod 32
      For Kt = 1 To Numled
         Kt0 = Kt - 1
         Estado = Lookup(estado_led(kt) , Tabla_estado)
         If Kt = 1 Then
            Led1 = Estado.num_ventana
         End If
         If Kt = 2 Then
            Led2 = Estado.num_ventana
         End If
      Next
      Incr Num_ventana
   End If


   Incr T00
   T00 = T00 Mod 100
   If T00 = 0 Then
      If Inicntron = 1 Then
         Incr Cntron
         Cntron = Cntron Mod Twaiton
         If Cntron = 0 Then
            Set Inipulsoon
         End If
      Else
         Cntron = 0
      End If
      If Inicntroff = 1 Then
         Incr Cntroff
         Cntroff = Cntroff Mod Twaitoff
         If Cntroff = 0 Then
            Set Inipulsooff
         End If
      Else
         Cntroff = 0
      End If
   End If

Return





'*******************************************************************************
' SUBRUTINAS
'*******************************************************************************

'*******************************************************************************
' Inicialización de variables
'*******************************************************************************
#if Micro = 1
Sub Inivar()
   Reset Led1
   Reset Led2
   Print #1 , Version(1)
   Print #1 , Version(2)
   Print #1 , Version(3)
   Estado_led(1) = 1
   Twaiton = Twaitoneep
   Twaitoff = Twaitoffeep
   Print #1 , "TwaitON=" ; Twaiton
   Print #1 , "TwaitOFF=" ; Twaitoff
End Sub


'*******************************************************************************
' Procesamiento de comandos
'*******************************************************************************
Sub Procser()
   Print #1 , "$" ; Serproc
   Tmpstr52 = Mid(serproc , 1 , 6)
   Numpar = Split(serproc , Cmdsplit(1) , ",")
   If Numpar > 0 Then
      For Tmpb = 1 To Numpar
         Print #1 , Tmpb ; ":" ; Cmdsplit(tmpb)
      Next
   End If

   If Len(cmdsplit(1)) = 6 Then
      Cmdtmp = Cmdsplit(1)
      Cmdtmp = Ucase(cmdtmp)
      Cmderr = 255
      Select Case Cmdtmp
         Case "LEEVFW"
            Cmderr = 0
            Atsnd = "Version FW: Fecha <"
            Tmpstr52 = Version(1)
            Atsnd = Atsnd + Tmpstr52 + ">, Archivo <"
            Tmpstr52 = Version(3)
            Atsnd = Atsnd + Tmpstr52 + ">"

         Case "RSTVAR"
            Cmderr = 0
            Twaitoneep = 30
            Twaiton = Twaitoneep
            Twaitoffeep = 300
            Twaitoff = Twaitoffeep
            Atsnd = "Valores por defecto"
            Set Inivariables



         Case "SETLED"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb < 17 Then
                  Cmderr = 0
                  Atsnd = "Se configura setled a " + Str(tmpb)
                  Estado_led(1) = Tmpb
               Else
                  Cmderr = 5
               End If

            Else
               Cmderr = 4
            End If

         Case "LEEDIN"
            Cmderr = 0
            Atsnd = "RPIsta=" + Str(starpi) + ", VinMon=" + Str(vinmon)

         Case "SETTON"
            If Numpar = 2 Then
               Cmderr = 0
               Twaiton = Val(cmdsplit(2))
               Twaitoneep = Twaiton
               Atsnd = "Se configuro TwaitON=" + Str(twaiton)
            Else
               Cmderr = 4
            End If

         Case "SETOFF"
            If Numpar = 2 Then
               Cmderr = 0
               Twaitoff = Val(cmdsplit(2))
               Twaitoffeep = Twaitoff
               Atsnd = "Se configuro TwaitON=" + Str(twaitoff)
            Else
               Cmderr = 4
            End If

         Case "LEETON"
            Cmderr = 0
            Atsnd = "TwaitON=" + Str(twaiton)

         Case "LEEOFF"
            Cmderr = 0
            Atsnd = "TwaitOFF=" + Str(twaitoff)


         Case Else
            Cmderr = 1

      End Select

   Else
        Cmderr = 2
   End If

   If Cmderr > 0 Then
      Atsnd = Lookupstr(cmderr , Tbl_err)
   End If

   Print #1 , Atsnd

End Sub

#endif

'*******************************************************************************
'TABLA DE DATOS
'*******************************************************************************
 #if Micro = 1
Tbl_err:
Data "OK"                                                   '0
Data "Comando no reconocido"                                '1
Data "Longitud comando no valida"                           '2
Data "Numero de usuario no valido"                          '3
Data "Numero de parametros invalido"                        '4
Data "Error longitud parametro 1"                           '5
Data "Error longitud parametro 2"                           '6
Data "Parametro no valido"                                  '7
Data "ERROR8"                                               '8
Data "ERROR SD. Intente de nuevo"                           '9
#endif

Tabla_estado:
Data &B00000000000000000000000000000000&                    'Estado 0
Data &B00000000000000000000000000000011&                    'Estado 1
Data &B00000000000000000000000000110011&                    'Estado 2
Data &B00000000000000000000001100110011&                    'Estado 3
Data &B00000000000000000011001100110011&                    'Estado 4
Data &B00000000000000110011001100110011&                    'Estado 5
Data &B00000000000011001100000000110011&                    'Estado 6
Data &B00001111111111110000111111111111&                    'Estado 7
Data &B01010101010101010101010101010101&                    'Estado 8
Data &B00110011001100110011001100110011&                    'Estado 9
Data &B01110111011101110111011101110111&                    'Estado 10
Data &B00000000000000000000000000111111&                    'Estado 11
Data &B00000000000000111111000000111111&                    'Estado 12
Data &B11110000111100001111000011110000&                    'Estado 13
Data &B11111111000000001111111100000000&                    'Estado 14
Data &B11111111111111110000000000000000&                    'Estado 15
Data &B11111111111111111111111111111111&                    'Estado 16



Loaded_arch: