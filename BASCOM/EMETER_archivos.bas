'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*  SD_Archivos.bas                                                        *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
'*                                                                             *
'*  Variables, Subrutinas y Funciones                                          *
'* WATCHING SOLUCIONES TECNOLOGICAS                                            *
'* 25.06.2015                                                                  *
'* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

$nocompile
$projecttime = 318

'*******************************************************************************
'Declaracion de subrutinas
'*******************************************************************************
Declare Sub Inivar()
Declare Sub Procser()
Declare Sub Leeidserial()
Declare Sub Defaultvalues()
Declare Sub Txmdb()
Declare Sub Rxmdb()
Declare Sub Txauto1()
Declare Sub Txauto2()
Declare Sub Txrpi()
Declare Sub Procrpi()
Declare Sub Txauto5()
Declare Sub Txauto6()

'*******************************************************************************
'Declaracion de variables
'*******************************************************************************
Dim Tmpb As Byte , Tmpb2 As Byte , Tmpb3 As Byte
Dim Ntx As Byte , Ntx0 As Byte , J As Byte
Dim Tmpw As Word
Dim Tmpl As Long , Tmpl2 As Long
Dim Cmdtmp As String * 6
Dim Atsnd As String * 200
Dim Cmderr As Byte
Dim Tmpstr8 As String * 16
Dim Tmpstr52 As String * 52
Dim Enabug As Byte
Dim Enabugeep As Eram Byte
Dim Idslave As Byte
Dim Idslaveeep As Eram Byte
Dim Tmpcrc32 As Long
Dim Trytx As Byte
Dim Txok As Bit
Dim Spuertaant As Bit

Dim Tmps As Single
Dim Bs1 As Byte At Tmps Overlay
Dim Bs2 As Byte At Tmps + 1 Overlay
Dim Bs3 As Byte At Tmps + 2 Overlay
Dim Bs4 As Byte At Tmps + 3 Overlay

Dim Tmpdw As Dword
Dim Bdw1 As Byte At Tmpdw Overlay
Dim Bdw2 As Byte At Tmpdw + 1 Overlay
Dim Bdw3 As Byte At Tmpdw + 2 Overlay
Dim Bdw4 As Byte At Tmpdw + 3 Overlay



'Variables para transmisiones automáticas
Dim Autoval(numtxaut) As Long , Autovaleep(numtxaut) As Eram Long
Dim Offset(numtxaut) As Long , Offseteep(numtxaut) As Eram Long
Dim Idserial As String * 22
Dim Fechaed As String * 10
Dim Horaed As String * 10

'clk
Dim Horamin As Long
Dim Horamineep As Eram Long
Dim Dow As Byte
Dim Actclk As Bit


'MODBUS
Dim Addrmdb As Word
Dim Ptrmod As Byte
'Dim Tblmod(48) As Byte
Dim Rdnormal As Bit
Dim Newmod As Bit
Dim Lendatamdb As Byte
Dim Msbmdb As Byte
Dim Lsbmdb As Byte
Dim W As Word
Dim Regmdb As Word
Dim Cntrm As Word
Dim Ptrmdb As Byte

'Variables Modbus
Dim Va As Word
Dim Vb As Word
Dim Vc As Word
Dim Freq As Single
Dim I3s As Single
Dim Ia As Single
Dim Ib As Single
Dim Ic As Single

Dim Pwr3s As Single
Dim Pwra As Single
Dim Pwrb As Single
Dim Pwrc As Single

Dim Ea3s As Single
Dim Ea As Dword
Dim Eb As Dword
Dim Ec As Dword

Dim Er3s As Single

Dim Eag3s As Single
Dim Eag As Single
Dim Ebg As Single
Dim Ecg As Single


Dim Cntrini As Word
Dim Cntrinieep As Eram Word

'Variables TIMER0
Dim T0c As Byte
Dim Num_ventana As Byte
Dim Estado As Long
Dim Estado_led As Byte
Dim Iluminar As Bit
Dim T00 As Byte
Dim Cntrseg As Byte
Dim T0cntr As Word
Dim T0tout As Bit , T0ini As Bit
Dim T0rate As Word

'TIMER2
Dim Tc2 As Byte , Tc20 As Byte
Dim Lsyssec As Long
Dim Tmplisr As Long
Dim Iniauto As Byte
Dim Newseg As Byte

'Variables SERIAL0
Dim Ser_ini As Bit , Sernew As Bit
Dim Numpar As Byte
Dim Cmdsplit(34) As String * 20
Dim Serdata As String * 200 , Serrx As Byte , Serproc As String * 200

Dim Rpi_ini As Bit , Rpinew As Bit
Dim Rpirx As Byte
Dim Rpidata As String * 140 , Rpiproc As String * 140

'Variables SERIAL1
Dim Serrx2 As Byte
Dim Inicntrm As Bit
Dim Tblmod(numregtblmod) As Byte

'*******************************************************************************
'* END public part                                                             *
'*******************************************************************************


Goto Loaded_arch

'*******************************************************************************
' INTERRUPCIONES
'*******************************************************************************

'*******************************************************************************
' Subrutina interrupcion de puerto serial 1
'*******************************************************************************
At_ser1:
   Serrx = Udr

   Select Case Serrx
      Case "$":
         Ser_ini = 1
         Serdata = ""

      Case "%":
         Set Rpi_ini
         Rpidata = ""

      Case 13:
         If Ser_ini = 1 Then
            Ser_ini = 0
            Serdata = Serdata + Chr(0)
            Serproc = Serdata
            Sernew = 1
            'Enable Timer0
         End If
         If Rpi_ini = 1 Then
            Rpi_ini = 0
            Rpidata = Rpidata + Chr(0)
            Rpiproc = Rpidata
            Set Rpinew
         End If

      Case Is > 31
         If Ser_ini = 1 Then
            Serdata = Serdata + Chr(serrx)
         End If
         If Rpi_ini = 1 Then
            Rpidata = Rpidata + Chr(serrx)
           If Len(rpidata) > 140 Then
               Rpidata = ""
            End If
         End If

   End Select

Return



'*******************************************************************************
' Subrutina interrupcion de puerto serial 2
'*******************************************************************************
At_ser2:
   Serrx2 = Udr1
   If Inicntrm = 1 Then
      Incr Ptrmod
      Tblmod(ptrmod) = Serrx2
   End If
Return

'*******************************************************************************



'*******************************************************************************
' TIMER0
'*******************************************************************************
Int_timer0:
   Timer0 = &H64                                            '100.1603hZ
   Incr T0c
   T0c = T0c Mod 8
   If T0c = 0 Then
      Num_ventana = Num_ventana Mod 32
      Estado = Lookup(estado_led , Tabla_estado)
      Iluminar = Estado.num_ventana
      Toggle Iluminar
      Led1 = Iluminar
      Incr Num_ventana
   End If

   If Inicntrm = 1 Then
      Incr Cntrm
      Cntrm = Cntrm Mod 160
      If Cntrm = 0 Then
         Reset Inicntrm
         Set Newmod
      End If
   End If

   If T0ini = 1 Then
      Incr T0cntr
      If T0cntr = T0rate Then
         Set T0tout
      End If
   Else
      T0cntr = 0
   End If
Return




'TIMER2
'*******************************************************************************
Sectic:
   Lsyssec = Syssec()
   For Tc2 = 1 To Numtxaut
      Tc20 = Tc2 - 1
      Tmplisr = Lsyssec - Offset(tc2)
      Tmplisr = Tmplisr Mod Autoval(tc2)
      If Tmplisr = 0 Then Set Iniauto.tc20
   Next
   Set Newseg
Return


'*******************************************************************************
' SUBRUTINAS
'*******************************************************************************

'*******************************************************************************
' Inicialización de variables
'*******************************************************************************
Sub Inivar()
   Reset Led1
   Print #1 , "************ EMETER 2025 ************"
   Print #1 , Version(1)
   Print #1 , Version(2)
   Print #1 , Version(3)
   Estado_led = 1

   For Tmpb = 1 To Numtxaut
      Autoval(tmpb) = Autovaleep(tmpb)
      Offset(tmpb) = Offseteep(tmpb)
      Print #1 , "Aut" ; Tmpb ; "=" ; Autoval(tmpb) ; ", OFF" ; Tmpb ; "=" ; Offset(tmpb)
   Next

   Call Leeidserial()
   Print#1 , "IDser<" ; Idserial ; ">"
   Horamin = Horamineep
   Print #1 , "Ultima ACTCLK " ; Date(horamin) ; "," ; Time(horamin)
   Enabug = Enabugeep
   Print #1 , "ENABUG=" ; Enabug

   Idslave = Idslaveeep
   Print #1 , "IDSlave>" ; Idslave
   Cntrini = Cntrinieep
   Cntrini = Cntrini + 1
   Cntrinieep = Cntrini
   Print #1 , "CNTRini=" ; Cntrini

End Sub


'*******************************************************************************
' LEE ID SERIAL DEL CHIP
'*******************************************************************************

 Sub Leeidserial()
   Tmpb = 0
   Tmpb2 = 0
   Do
      Idserial = ""
      For Tmpb = 14 To 23
         Idserial = Idserial + Hex(readsig(tmpb))
      Next
      Atsnd = Idserial
      Idserial = ""
      For Tmpb = 14 To 23
         Idserial = Idserial + Hex(readsig(tmpb))
      Next
      If Idserial = Atsnd Then
         Tmpb = 1
      End If
      Incr Tmpb2
      If Tmpb = 0 Then
         Waitms 500
         Print #1 , "Try " ; Tmpb2
      End If
   Loop Until Tmpb = 1 Or Tmpb2 = 10

 End Sub

'*******************************************************************************
' VALORES POR DEFAULT
'*******************************************************************************

 Sub Defaultvalues()
   Tmpl = 0
   For Tmpb = 1 To Numtxaut
      Autovaleep(tmpb) = 300
      Offseteep(tmpb) = Tmpl
      Tmpl = Tmpl + 60
   Next

   Idslaveeep = 1
   Autovaleep(4) = 10

 End Sub

'*******************************************************************************
' VALORES POR DEFAULT
'*******************************************************************************
Sub Txmdb()
   Incr Ptrmdb
   Ptrmdb = Ptrmdb Mod Numlecmdb
   Addrmdb = Lookup(ptrmdb , Tbl_ptrmdb)
   Print #1 , "Ptr=" ; Ptrmdb ; ", Addr=" ; Hex(addrmdb)
   For J = 1 To Numregtblmod
      Tblmod(j) = 0
   Next
   Ptrmod = 0
   If Enabug.3 = 1 Then
      Print #1 , "TX " ; Hex(addrmdb)
      Print #1 , Makemodbus(idslave , 3 , Addrmdb , 36)
   End If
   Set Inicntrm
   Set Dir485
   Print #4 , Makemodbus(idslave , 3 , Addrmdb , 36);
   Waitus 1500
   Reset Dir485
'   Set Inicntrm
   Set Rdnormal


End Sub

Sub Rxmdb()
   If Enabug.3 = 1 Then
      Print #1 , "PTRMDB=" ; Ptrmod ; ", Addr=" ; Hex(addrmdb)
      For J = 1 To Ptrmod                                   'La respuesta es la direccion del esclavo,la funcion que se recibio, el numero de bytes
         Print #1 , Hex(tblmod(j)) ; ",";                   ' que se envian, los bytes que se reciben (12 en este caso) y 2 bytes de CHCKSUM
      Next                                                  ' ADDR(1) + FUNCION(1) + NUMbytes (12)+ DATOS(12) + CHCKSUM(2) = 1+1+1+12+2 = 17 bytes que se reciben
      Print #1,
   End If
   Lendatamdb = Ptrmod - 2
   Msbmdb = Lendatamdb + 1
   Lsbmdb = Msbmdb + 1
   'Print #1 , Lendatamdb ; "," ; Msbmdb ; "," ; Lsbmdb
   W = Crc16uni(tblmod(1) , Lendatamdb , &HFFFF , &H8005 , 1 , 1)
   Tmpw = Makeint(tblmod(msbmdb) , Tblmod(lsbmdb))
   If W = Tmpw Then
      If Rdnormal = 1 Then
         Select Case Ptrmdb:
            Case 0:                                         '1000H
               Bdw4 = Tblmod(4)
               Bdw3 = Tblmod(5)
               Bdw2 = Tblmod(6)
               Bdw1 = Tblmod(7)
               'Va = Tmpdw
               Print #1 , "V3fs=" ; Tmpdw

               Bdw4 = Tblmod(8)
               Bdw3 = Tblmod(9)
               Bdw2 = Tblmod(10)
               Bdw1 = Tblmod(11)
               Va = Tmpdw
               Print #1 , "Va=" ; Va

               Bdw4 = Tblmod(12)
               Bdw3 = Tblmod(13)
               Bdw2 = Tblmod(14)
               Bdw1 = Tblmod(15)
               Vb = Tmpdw
               Print #1 , "Vb=" ; Vb

               Bdw4 = Tblmod(16)
               Bdw3 = Tblmod(17)
               Bdw2 = Tblmod(18)
               Bdw1 = Tblmod(19)
               Vc = Tmpdw
               Print #1 , "Vc=" ; Vc

            Case 1:                                         '100EH
               Bdw4 = Tblmod(4)
               Bdw3 = Tblmod(5)
               Bdw2 = Tblmod(6)
               Bdw1 = Tblmod(7)
               I3s = Tmpdw / 1000
               Print #1 , "I3s=" ; I3s

               Bdw4 = Tblmod(8)
               Bdw3 = Tblmod(9)
               Bdw2 = Tblmod(10)
               Bdw1 = Tblmod(11)
               Ia = Tmpdw / 1000
               Print #1 , "Ia=" ; Ia

               Bdw4 = Tblmod(12)
               Bdw3 = Tblmod(13)
               Bdw2 = Tblmod(14)
               Bdw1 = Tblmod(15)
               Ib = Tmpdw / 1000
               Print #1 , "Ib=" ; Ib

               Bdw4 = Tblmod(16)
               Bdw3 = Tblmod(17)
               Bdw2 = Tblmod(18)
               Bdw1 = Tblmod(19)
               Ic = Tmpdw / 1000
               Print #1 , "Ic=" ; Ic

            Case 2:                                         '10AEH  Resolucion 100 (dividir para 100?)
               Bdw4 = Tblmod(4)
               Bdw3 = Tblmod(5)
               Bdw2 = Tblmod(6)
               Bdw1 = Tblmod(7)
               Eag3s = Tmpdw / 100
               Print #1 , "Eag3s=" ; Eag3s

               Bdw4 = Tblmod(8)
               Bdw3 = Tblmod(9)
               Bdw2 = Tblmod(10)
               Bdw1 = Tblmod(11)
               Eag = Tmpdw / 100
               Print #1 , "Eag=" ; Eag

               Bdw4 = Tblmod(12)
               Bdw3 = Tblmod(13)
               Bdw2 = Tblmod(14)
               Bdw1 = Tblmod(15)
               Ebg = Tmpdw / 100
               Print #1 , "Ebg=" ; Ebg

               Bdw4 = Tblmod(16)
               Bdw3 = Tblmod(17)
               Bdw2 = Tblmod(18)
               Bdw1 = Tblmod(19)
               Ecg = Tmpdw / 100
               Print #1 , "Ecg=" ; Ecg

            Case 3:                                         '1070

               Bs4 = Tblmod(4)
               Bs3 = Tblmod(5)
               Bs2 = Tblmod(6)
               Bs1 = Tblmod(7)
               Pwr3s = Tmps
               Print #1 , "Pwr3s=" ; Pwr3s                  'W

               Bdw4 = Tblmod(12)
               Bdw3 = Tblmod(13)
               Bdw2 = Tblmod(14)
               Bdw1 = Tblmod(15)
               Pwra = Tmpdw / 100
               Print #1 , "Pwra=" ; Pwra                    'Wh

               Bdw4 = Tblmod(16)
               Bdw3 = Tblmod(17)
               Bdw2 = Tblmod(18)
               Bdw1 = Tblmod(19)
               Pwrb = Tmpdw / 100
               Print #1 , "Pwrb=" ; Pwrb

               Bdw4 = Tblmod(20)
               Bdw3 = Tblmod(21)
               Bdw2 = Tblmod(22)
               Bdw1 = Tblmod(23)
               Pwrc = Tmpdw / 100
               Print #1 , "Pwrc=" ; Pwrc


            Case 4:                                         '103eH
               Bdw4 = Tblmod(4)
               Bdw3 = Tblmod(5)
               Bdw2 = Tblmod(6)
               Bdw1 = Tblmod(7)
               Ea3s = Tmpdw / 100
               Print #1 , "Ea3s=" ; Ea3s

               Bdw4 = Tblmod(8)
               Bdw3 = Tblmod(9)
               Bdw2 = Tblmod(10)
               Bdw1 = Tblmod(11)
               Er3s = Tmpdw / 100
               Print #1 , "Er3s=" ; Er3s
               Bdw4 = Tblmod(16)
               Bdw3 = Tblmod(17)
               Bdw2 = Tblmod(18)
               Bdw1 = Tblmod(19)
               Freq = Tmpdw / 1000
               Print #1 , "frec=" ; Freq

            Case Else:
               Print #1 , "Ptr no val"

         End Select
      Else
         If Ptrmod = 7 Then
            Regmdb = Makeint(tblmod(5) , Tblmod(4))
            Print #1 , "REG MDB DEC=" ; Regmdb ; ", HEX=" ; Hex(regmdb) ; ", DEC=" ; Regmdb
         End If
         If Ptrmod = 8 Then
            Regmdb = Makeint(tblmod(6) , Tblmod(5))
            Print #1 , "REG MDB DEC=" ; Regmdb ; ", HEX=" ; Hex(regmdb)
            'Set Iniauto.0
            'Set Initx
         End If
      End If
   Else
      If Enabug.3 = 1 Then
         Print #1 , "CRC fail en ADDR=" ; Hex(addrmdb)
      End If
   End If

End Sub


Sub Txrpi()
   Trytx = 0
   Reset Txok
   Do
      Incr Trytx
      Print #1 , "Espera RPI " ; Trytx
      T0rate = 100
      T0cntr = 0
      Set T0ini
      Reset T0tout
      Do
         If Rpinew = 1 Then
            Reset Rpinew
            Print#1 , "RPItx>" ; Rpiproc
            Call Procrpi()
         End If
         If Sernew = 1 Then
            Reset Sernew
            Print #1 , "SER1=" ; Serproc
            Call Procser()
         End If
      Loop Until Txok = 1 Or T0tout = 1
      Reset T0ini
      If Txok = 0 Then
         Print #1 , "$" ; Atsnd
         'Print #2 , "$" ; Atsnd
      End If
   Loop Until Txok = 1 Or Trytx = 3

   Reset T0ini
   Reset Txok

End Sub

Sub Txauto1()
   Print #1 , "TXAUT1 ;" ; Time$ ; "," ; Date$
   Fechaed = Date$
   Horaed = Time$
   Atsnd = "A" + "," + Fechaed + "," + Horaed + "," + Idserial + "-1"
   Atsnd = Atsnd + "," + Str(va) + "," + Str(vb) + "," + Str(vc) + "," + Str(freq) + "," + Str(ia) + "," + Str(ib) + "," + Str(ic) + ","
   Tmpw = Len(atsnd)
   Tmpcrc32 = Crc32(atsnd , Tmpw)
   Atsnd = Atsnd + "&" + Hex(tmpcrc32)                      '+ Chr(10)
   Print #1 , "$" ; Atsnd
   'Print #2 , "$" ; Atsnd
   Call Txrpi()
End Sub

Sub Txauto2()
   Print #1 , "TXAUT4 ;" ; Time$ ; "," ; Date$
   Fechaed = Date$
   Horaed = Time$
   Atsnd = "A" + "," + Fechaed + "," + Horaed + "," + Idserial + "-2"
   Atsnd = Atsnd + "," + Fusing(pwr3s , "#.##") + "," + Fusing(pwra , "#.##") + "," + Fusing(pwrb , "#.##") + "," + Fusing(pwrc , "#.##")
   Atsnd = Atsnd + "," + Fusing(ea3s , "#.##" ) + "," + Str(ea) + "," + Str(eb) + "," + Str(ec)
   Tmpw = Len(atsnd)
   Tmpcrc32 = Crc32(atsnd , Tmpw)
   Atsnd = Atsnd + "&" + Hex(tmpcrc32)                      '+ Chr(10)
   Print #1 , "$" ; Atsnd
   'Print #2 , "$" ; Atsnd
   Call Txrpi()
End Sub


Sub Txauto5()
   Print #1 , "TXAUT5 ;" ; Time$ ; "," ; Date$
   Fechaed = Date$
   Horaed = Time$
   Atsnd = "A" + "," + Fechaed + "," + Horaed + "," + Idserial + "-5"
   Atsnd = Atsnd + "," + Fusing(eag3s , "#.##") + "," + Fusing(eag , "#.##") + "," + Fusing(ebg , "#.##") + "," + Fusing(ecg , "#.##")
   Atsnd = Atsnd + "," + Fusing(er3s , "#.##") + "," + "," + ","
   Tmpw = Len(atsnd)
   Tmpcrc32 = Crc32(atsnd , Tmpw)
   Atsnd = Atsnd + "&" + Hex(tmpcrc32)                      '+ Chr(10)
   Print #1 , "$" ; Atsnd
   'Print #2 , "$" ; Atsnd
   Call Txrpi()

End Sub

Sub Txauto6()
   Print #1 , "TXAUT6 ;" ; Time$ ; "," ; Date$
   Fechaed = Date$
   Horaed = Time$
   Atsnd = "A" + "," + Fechaed + "," + Horaed + "," + Idserial + "-6"
   Atsnd = Atsnd + "," + Str(spuerta) + "," + Str(cntrini) + ",,,,,,"
   Tmpw = Len(atsnd)
   Tmpcrc32 = Crc32(atsnd , Tmpw)
   Atsnd = Atsnd + "&" + Hex(tmpcrc32)                      '+ Chr(10)
   Print #1 , "$" ; Atsnd
   'Print #2 , "$" ; Atsnd
   Call Txrpi()

End Sub


'*******************************************************************************
' Procesamiento de datos del RPi
'*******************************************************************************
Sub Procrpi()
   'Cntrackesp32 = 0
   Numpar = Split(rpiproc , Cmdsplit(1) , ";")
   If Numpar > 0 Then
      Cmdtmp = Cmdsplit(1)
   Else
      Cmdtmp = Rpiproc
   End If
   '   Cmdtmp = "nocmd"
   'Else
      'Cmdtmp = Cmdsplit(1)

  ' End If
   Select Case Cmdtmp
      Case "OK"
         Set Txok

      Case "ERR"
         Reset Txok

      Case "SETMBD"
         Set Sernew
         Serproc = Cmdsplit(2)
         Print #1 , "NEW MDC CMD"

      Case "SETDAA"
    '     Cntrackesp32 = 0
         Set Sernew
         'Set Resptb
         Serproc = Cmdsplit(2)
         Print #1 , "NEW MDC CMD"

      Case Else
         Print #1 , "No cmd val"

   End Select

End Sub

'*******************************************************************************
' Procesamiento de comandos
'*******************************************************************************
Sub Procser()
   'Print #1 , "$" ; Serproc
   Tmpstr52 = Mid(serproc , 1 , 6)
   Numpar = Split(serproc , Cmdsplit(1) , ",")
'   If Numpar > 0 Then
'      For Tmpb = 1 To Numpar
'         Print #1 , Tmpb ; ":" ; Cmdsplit(tmpb)
'      Next
'   End If

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


         Case "SETLED"
            If Numpar = 2 Then
               Tmpb = Val(cmdsplit(2))
               If Tmpb < 17 Then
                  Cmderr = 0
                  Atsnd = "Se configura setled a " + Str(tmpb)
                  Estado_led = Tmpb
               Else
                  Cmderr = 5
               End If
            Else
               Cmderr = 4
            End If

         Case "RSTVAR"
            Cmderr = 0
            Atsnd = "Valores por default"
            Call Defaultvalues()

         Case "SETCLK"
            If Numpar = 2 Then
               If Len(cmdsplit(2)) = 12 Then
                  Cmderr = 0
                  Tmpstr52 = Mid(cmdsplit(2) , 7 , 2) + ":" + Mid(cmdsplit(2) , 9 , 2) + ":" + Mid(cmdsplit(2) , 11 , 2)
                  Print #1 , Tmpstr52
                  Time$ = Tmpstr52
                  Print #1 , "T>" ; Time$
                  Tmpstr52 = Mid(cmdsplit(2) , 1 , 2) + "/" + Mid(cmdsplit(2) , 3 , 2) + "/" + Mid(cmdsplit(2) , 5 , 2)
                  Print #1 , Tmpstr52
                  Date$ = Tmpstr52
                  Print #1 , "D>" ; Date$
                  Atsnd = "WATCHING INFORMA. Se configuro reloj en " + Date$ + " a " + Time$
                  Dow = Dayofweek()
                  Horamin = Syssec()
                  Horamineep = Horamin
                  Set Actclk
                  Estado_led = 1
               Else
                  Cmderr = 6
               End If
            Else
               Cmderr = 4
            End If

         Case "SISCLK"
            Cmderr = 0
            Tmpstr52 = Time$
            Atsnd = "Hora actual=" + Tmpstr52 + ", Fecha actual="
            Tmpstr52 = Date$
            Atsnd = Atsnd + Tmpstr52

         Case "LEECLK"
            Cmderr = 0
            Tmpstr52 = Time(horamin)
            Atsnd = "Ultima ACT CLK a =" + Tmpstr52 + ", del "
            Tmpstr52 = Date(horamin)
            Atsnd = Atsnd + Tmpstr52

         Case "SETAUT"
            If Numpar = 3 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 'Snstr = Cmdsplit(3)
                 Tmpl2 = Val(cmdsplit(3))
                 Autoval(j) = Tmpl2
                 Autovaleep(j) = Tmpl2
                 Cmderr = 0
                 'Print #1 , "$" ; J ; "," ; Autoval(j)
                 'Print #1 , "$OK"
                 Atsnd = "Se configuro tx AUT " + Str(j) + ":" + Str(autoval(j))
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "SETOFF"
            If Numpar = 3 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 'Snstr = Cmdsplit(3)
                 Tmpl2 = Val(cmdsplit(3))
                 Offset(j) = Tmpl2
                 Offseteep(j) = Tmpl2
                 Cmderr = 0
                 'Print #1 , "$" ; J ; "," ; Offset(j)
                 'Print #1 , "$OK"
                 Atsnd = "Se configuro tx AUT " + Str(j) + ":" + Str(offset(j))
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEAUT"                                      'Habilitaciones de Usuario
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  'Snstr = Cmdsplit(3)
                  Atsnd = "Tx Aut " + Str(j) + ":" + Str(autoval(j))
                  Cmderr = 0
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEOFF"                                      'Habilitaciones de Usuario
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                 'Snstr = Cmdsplit(3)
                  Atsnd = "Offset Aut " + Str(j) + ":" + Str(offset(j))
                  Cmderr = 0
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If


         Case "SETNEW"
            If Numpar = 2 Then
               J = Val(cmdsplit(2))
               If J > 0 And J < Numtxaut_mas_uno Then
                  Cmderr = 0
                  Tmpb = J - 1
                  Set Iniauto.tmpb
                  Atsnd = "Se activo Tx. AUT " + Str(j) + "," + Bin(iniauto)
               Else
                  Cmderr = 3
               End If
            Else
               Cmderr = 4
            End If

         Case "SETBUG"
            If Numpar = 2 Then
               Cmderr = 0
               Enabug = Val(cmdsplit(2))
               Enabugeep = Enabug
               Atsnd = "Se configuro ENABUG=" + Str(enabug)
            Else
               Cmderr = 4
            End If

         Case "LEEBUG"
            Cmderr = 0
            Atsnd = "ENABUG=" + Str(enabug)

         Case "LEERID"
            Cmderr = 0
            Call Leeidserial()
            Atsnd = "ID ser <" + Idserial + ">"

         Case "SETDIR"
            If Numpar = 2 Then
               Cmderr = 0
               Tmpb = Val(cmdsplit(2))
               If Tmpb > 0 And Tmpb < 255 Then
                  Idslave = Tmpb
                  Idslaveeep = Idslave
                  Atsnd = "Se configuro IDslave a " + Str(idslave)
               Else
                  Cmderr = 5
               End If
            Else
               Cmderr = 4
            End If

         Case "LEEDIR"
            Cmderr = 0
            Atsnd = "IDslave =" + Str(idslave)

         Case "SETREL"
            If Numpar = 2 Then
               Cmderr = 0
               Tmpb = Val(cmdsplit(2))
               If Tmpb = 0  THEN
                  Atsnd = "RESET rele"
                  Reset Rele
               Else
                  Atsnd = "SET rele"
                  Set Rele
               End If
            Else
               Cmderr = 4
            End If


         Case Else
            Cmderr = 1

      End Select

   Else
        'Cmderr = 2
      Cmdtmp = Cmdsplit(1)
      Cmdtmp = Ucase(cmdtmp)
      Select Case Cmdtmp
         Case "OK"
            Set Txok
            Cmderr = 0

         Case "ERR"
            Reset Txok
            Cmderr = 0

         Case "SETMBD"
            Set Sernew
            Serproc = Cmdsplit(2)
            Print #1 , "NEW MDC CMD"
            Cmderr = 0

         Case "SETDAA"
            'Cntrackesp32 = 0
            Set Sernew
            'Set Resptb
            Serproc = Cmdsplit(2)
            Print #1 , "NEW MDC CMD"
            Cmderr = 0
         Case Else
            'Print #1 , "No cmd val"
            Cmderr = 2
      End Select
   End If

   If Cmderr > 0 Then
      Atsnd = Lookupstr(cmderr , Tbl_err)
   End If

   Print #1 , Atsnd

End Sub



'*******************************************************************************
'TABLA DE DATOS
'*******************************************************************************
Tbl_ptrmdb:
Data &H1000%                                                'Voltaje
Data &H100E%                                                'Corriente
Data &H10AE%                                                '3-PHASE SYS. GENERATED ACTIVE ENERGY
Data &H1070%                                                'PWR Reactiva
Data &H103E%                                                'Energia + Frecuencia


Tbl_err:
Data "OK"                                                   '0
Data "Comando no reconocido"                                '1
Data "Longitud comando no valida"                           '2
Data "Numero de parametro no valido"                        '3
Data "Numero de parametros invalido"                        '4
Data "Error longitud parametro 1"                           '5
Data "Error longitud parametro 2"                           '6
Data "Parametro no valido"                                  '7
Data "ERROR8"                                               '8
Data "ERROR SD. Intente de nuevo"                           '9

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
Data &B11111111111111000000000000001100&                    'Estado 11
Data &B11111111111111000000000011001100&                    'Estado 12
Data &B11111111111111000000110011001100&                    'Estado 13
Data &B11111111111111001100110011001100&                    'Estado 14
Data &B11111111111111000000000000001100&                    'Estado 15
Data &B11111111111111111111111111110000&                    'Estado 16



Loaded_arch: