# -*- coding: utf-8 -*-
"""
Created on Mon Apr 12 15:27:17 2021
Estados
0 NOrmal
1 Mínimo
2 Máximo
@author: Fernando
"""

import requests
import pickle
import os
import time
import datetime
import codecs
#from twilio.rest import Client
import json


flagsndmsg=True
#ARCHIVO_DITEC="lista_ditecs.csv"
ARCHIVO_PARAM="set_alarmas.csv"
ARCHIVO_MSG="lista_msg.csv"
FILELASTOPER="lastoper.p"
FILESTAFIELDS="stafields.p"
TFUTURO=300
CABECERAMSG="MICROCENTRAL TILIVI. "


formato1="%Y-%m-%dT%H:%M:%SZ"
huso=datetime.timedelta(hours=5,minutes=0)


FILECONFIG="varemeter.json"

try:
    print("Buscando conf inicial")
    with open(FILECONFIG,'r') as f:
        varconfig=json.load(f)
    print("Var file encontrado")
except:
    print("Inicializando conf inicial")
    varconfig={"timeout":360,"url":"https://thingsboard.cloud","user":"username","password":"psw",
               "chatid":"CHATID","tokentgram":"TOKEN","filedevices":"Devices.CSV","piflag":"true"}
    print("Guardando Var file")
    with open(FILECONFIG,'w') as f:
        json.dump(varconfig,f) 

# CHATID y TOKEN en archivo de variables se  utilizan pára notificar nueva generación de TOKEN

TB_URL=varconfig.get("url")
USERNAME=varconfig.get("user")
PASSWORD=varconfig.get("password")
TIMEOUT=varconfig.get("timeout")
CHATID=varconfig.get("chatid")
BOTID=varconfig.get("tokentgram")
ARCHIVO_DITEC=varconfig.get("filedevices")
FILETXDATA="txnodat.dat"
formato2 = "%d %b %Y %H:%M:%S"

runpi=varconfig.get("piflag")
print("Runpi:",runpi)
if runpi=="true":
    pathd="/home/pi/EMETER/TBALARM/DATOS/"

if runpi=="false":
    pathd="DATOS/"
print(pathd)


# Proporciona los campos de la ultima entrada de un canal
# El canal se ingresa como numero entero
# Los datos del canal se presentan como una lista ordenanda de la sig. manera
# [fecha, field1, field2,....,field8,num_entrada]

def authenticate():
    url = f"{TB_URL}/api/auth/login"
    payload = {"username": USERNAME, "password": PASSWORD}
    response = requests.post(url, json=payload)
    response.raise_for_status()
    return response.json()["token"]

def get_latest_telemetry(jwt_token, device_id):
    url = f"{TB_URL}/api/plugins/telemetry/DEVICE/{device_id}/values/timeseries"
    headers = {"X-Authorization": f"Bearer {jwt_token}"}
    response = requests.get(url, headers=headers)
    coderesponse=response.status_code
    #print(response.json())
    try:
        if response.status_code == 200:
            message=response.json()
            datos=message.get("Eg3s")
            entrada=datos[0].get("ts")
            fecha1=datetime.datetime.fromtimestamp(entrada/1000)
            fecha=fecha1.strftime(formato1)
            try:
                lista=message.get('pt1')
                f1=lista[0].get("value")
              
            except:
                f1=""
            try:
                lista=message.get('POWER_FULL_SUMMARY')
                f2=lista[0].get("value")
            except:
                f2=""
            try:
                lista=message.get('VOLTAGE_A')
                f3=lista[0].get("value")
            except:
                f3=""
            try:
                lista=message.get('VOLTAGE_B')
                f4=lista[0].get("value")
            except:
                f4=""
            try:
                lista=message.get('VOLTAGE_C')
                f5=lista[0].get("value")
            except:
                f5="" 
            try:
                lista=message.get('CURRENT_A')
                f6=lista[0].get("value")
            except:
                f6=""
            try:
                lista=message.get('CURRENT_B')
                f7=lista[0].get("value")
            except:
                f7=""
            try:
                lista=message.get('CURRENT_C')
                f8=lista[0].get("value")
            except:
                f8=""
            data=[fecha,f1,f2,f3,f4,f5,f6,f7,f8,entrada]
            return data, coderesponse               
        else:
            print(f"Error obteniendo datos de {device_id}: {response.status_code}")
            data=[-1,0,0,0,0,0,0,0,0,0]
            return data,coderesponse
    except:
        data=[-1,0,0,0,0,0,0,0,0,0]
        return data,coderesponse


def checkdir(namedir):
    if os.path.isdir(namedir):
        print(namedir,"existe")
        dirok=True
    else:
        print(namedir,"no encontrado")
        try:
            os.mkdir(namedir)
            dirok=True
            print(namedir,"creado")
        except:
            dirok=False
    return dirok
    
       

def savealarmas(nombreditec,nameserv,ev,canaltst,datafecha,urliot,namefile):
    formato1="%Y-%m-%dT%H:%M:%SZ"
    #huso=datetime.timedelta(hours=5,minutes=0)
    horastr=datafecha
    hora=datetime.datetime.strptime(horastr,formato1)
    #horaloc=hora-huso
    horaloc=hora
    formato2="%Y-%m-%d %H:%M:%S"
    horalocstr=datetime.datetime.strftime(horaloc,formato2)
    archivo=open(namefile,"a")
    #urlver=urliot+'/channels/'+canaltst
    print("Evento",ev)
    msg=CABECERAMSG+nombreditec+". "+nameserv+". Detectado el "+horalocstr+"\r"
    #msg=msg+", revisar "+urlver+"\r"
    print(msg)
    archivo.write(msg)
    archivo.close()
    
def sndmsgtelegram(msg,chatid,botid):
    urlbase="https://api.telegram.org"
    url=urlbase+'/bot'+botid+'/sendMessage?chat_id='+chatid+'&disable_web_page_preview=1&parse_mode=Markdown&text='+msg
    try:
        response = requests.get(url)
        if response.status_code == 200:
            results = response.json()
            print(results)
        else:
            print("Error code %s" % response.status_code)
    except:
        print("Error snd Telegram")    

def saveobjeto(objeto,archivo):
  try:
    #print("Guardando",objeto,"en",archivo)
    pickle.dump(objeto, open( archivo, "wb" ))
  except:
    print("Problema guardando",objeto,"en",archivo)

def checkobjeto(objeto,archivo):
  if not os.path.isfile(archivo):
    print("No se encontro ",archivo,",se inicia con ",objeto)
    saveobjeto(objeto,archivo)
  else:
    print(archivo,"encontrado")

def getobjeto(archivo):
  objeto=pickle.load(open( archivo, "rb" ))
  return objeto
    

print("ALARMAS IOT")
print("Lee lista de DITECs")
with codecs.open(ARCHIVO_DITEC, "r",encoding='utf-8', errors='ignore') as listadatos:
    listaditec=listadatos.readlines()
    listaditec=listaditec[1:]
    # for i in listaditec:
    #     print(i)    
print("Lee lista de parametros de entradas")
with codecs.open(ARCHIVO_PARAM, "r",encoding='utf-8', errors='ignore') as listadatos:
    listaparamfields=listadatos.readlines()
    listaparamfields=listaparamfields[1:]
    # for i in listaparamfields:
    #     print(i)  
print("Lee lista de mensajes")
with codecs.open(ARCHIVO_MSG, "r",encoding='utf-8', errors='ignore') as listadatos:
    listamsg=listadatos.readlines()
    listamsg=listamsg[1:]
    # for i in listamsg:
    #     print(i)  

msgdict={}
for valor in listamsg:
    keyValue=valor.split(",")
    msgdict[keyValue[0]]=keyValue[1]        
print(msgdict)        
        
# Lista de fields que se van a procesar
param=[1,2,3,4,5,6,7,8]
    
#listadataparam=[["Voltaje mayor que el máximo", "Alcanza voltaje minimo","VBAT"],
           # ["Se reestablecio voltaje de alimentacion", "Falla alimentacion principal","AC"],
           # ["Se cerro puerta de caseta", "Se abrio puerta de caseta","PT1"],
           # ["Max en field6", "Min en fiel 6","F6"]]
          
print("Verifica archivo que almacena las ultimas entradas del canal de operación")
checkobjeto([],FILELASTOPER)
lastentry_oper=getobjeto(FILELASTOPER)
if lastentry_oper==[]:
    for i in range(len(listaditec)):
        #lastentry_oper.append(0)
        lastentry_oper=[0 for fila in range (len(listaditec))]
        #lastentry_operant=[1 for fila in range (len(listaditec))]
print("Ultima entradas canal operacion",lastentry_oper)

for i in range(len(listaditec)):
    lastentry_operant=[1 for fila in range (len(listaditec))]


      
print("Verifica archivo de estado de campos") 
checkobjeto([],FILESTAFIELDS)
listastafields=getobjeto(FILESTAFIELDS)
if listastafields==[]:
    listastafields = [[0 for columna in range(len(param))] for fila in range (len(listaditec))]
print("Estados de campos",listastafields)

   

newentry=False
newalarma=False
checkdir("DATOS")

flagconfig=True
if USERNAME=="username":
    flagconfig=False
    
while not flagconfig:
    print("Sin config inicial")
    time.sleep(10)

cntrnumr=0
print("Empieza operacion") 
#lastentry_operant=lastentry_oper 
token = authenticate()
headers = {"X-Authorization": f"Bearer {token}"}
cntrerr_rd=0

while True:
    x=datetime.datetime.now()
    #print('Lee IOT>',x)
    ptrditec=0
    for ditec in listaditec:
        paramditec=ditec.split(",")
        paramfieldsditec=listaparamfields[ptrditec]
        paramfields=paramfieldsditec.split(",")
        nombre=paramditec[1]
        canalop=paramditec[2]
        hab=paramditec[4]
        chatid=paramditec[5]
        botid=paramditec[6]
        if hab=="1":
            x=datetime.datetime.now()
            newalarma=False
            namefile=pathd+"ALARM_"+nombre+"_"+str(x.year)+"_"+str(x.month)+"_"+str(x.day)+"_"+str(x.hour)+"_"+str(x.minute)+"_"+str(x.second)+".txt"
            urliot=paramditec[3]
            #datacanal=getlastcts(canalop,urliot)
            #print("Canal>",nombre)
            try:
                datacanal,coderesponse=get_latest_telemetry(token, canalop)
            except:
                print("Err get data")
                cntrerr_rd=cntrerr_rd+1
                cntrerr_rd=cntrerr_rd%10
                if cntrerr_rd==0:
                    print("Se renueva Token")
                    token = authenticate() 
                    headers = {"X-Authorization": f"Bearer {token}"}
                    msg="Se renueva Token Thingsboard DITECNET por errores en lectura"
                    sndmsgtelegram(msg,CHATID,BOTID)                
                
            if coderesponse==401:
                print("Token no valido")
                token = authenticate() 
                headers = {"X-Authorization": f"Bearer {token}"}
                msg="Se genera nuevo Token Thingsboard DITECNET"
                sndmsgtelegram(msg,CHATID,BOTID)
            # ,print(datacanal)
            fechastr=datacanal[0]
            #print("Comp>",lastentry_oper[ptrditec],datacanal[9])
            if lastentry_oper[ptrditec]!=datacanal[9] and datacanal[9]>0:
                tmpl=datacanal[9]-lastentry_oper[ptrditec]
                tmpl=tmpl/1000
                if tmpl>0:
                    if tmpl > TFUTURO:
                        print("Tadelante",tmpl)
                        msg="Dato futuro en "+nombre+" por " +str(tmpl)+" seg"
                        sndmsgtelegram(msg,CHATID,BOTID)
                #print("Revisar nuevo datos")
                print(nombre,",",datacanal,",",tmpl)
                ptr=0
                for i in param:
                    numfield="field"+str(i)
                    #print(numfield)
                    #print("Proc ",numfield,"ptr=",ptr,", DITEC=",nombre,", ptrditec=",ptrditec)
                    #dataparam=listadataparam[ptr]
                    procesar=False
                    #print(datacanal[i],type(datacanal[i]))
                    if datacanal[i]!=None:
                        try:
                            valdata=float(datacanal[i])
                            procesar=True
                        except:
                            #print("Dato no valido")
                            procesar=False
                        if procesar:    
                            ptri=i*2
                            valminstr=paramfields[ptri]
                            ptri=ptri+1
                            valmaxstr=paramfields[ptri]
                            if valminstr!="" and valmaxstr!="":
                                valmin=float(valminstr)
                                valmax=float(valmaxstr)
                                #print(valdata,valmax,valmin)
                                #print(listastafields)
                                sta_fields=listastafields[ptrditec]
                                #print(sta_fields,"sta_fields ")
                                horastr=datacanal[0]
                                if sta_fields[ptr]==1: #Estado en normal
                                    if valdata>valmax:
                                       print("A Max de normal en",numfield)
                                       #print(sta_fields,",",ptr)
                                       ptri=2*i+17
                                       msgalarm=paramfields[ptri]
                                       print("Rep+>",msgalarm)
                                       if sta_fields[ptr]!=2:
                                           sta_fields[ptr]=2
                                           #print(sta_fields,"sta_fields")
                                           listastafields[ptrditec]=sta_fields
                                           #print(listastafields,"listastafields")
                                           saveobjeto(listastafields, FILESTAFIELDS)
                                           if msgalarm!="":
                                               try:
                                                   msgtxt=msgdict.get(msgalarm)
                                                   print(msgtxt)
                                                   #msgtxt=msgtxt[:-2]
                                                   savealarmas(nombre,msgtxt,"M2N",canalop,horastr,urliot,namefile)
                                                   newalarma=True
                                               except:
                                                   print("Error leyendo mensaje>",msgalarm)
                                                   print(msgdict.get(msgalarm))
                                       
                                    elif valdata<valmin:
                                        print("Min de normal en",numfield)
                                        #print(sta_fields,",",ptr)
                                        if sta_fields[ptr]!=0:
                                           sta_fields[ptr]=0
                                           #print(sta_fields,"1")
                                           listastafields[ptrditec]=sta_fields
                                           #print(listastafields,"2")
                                           saveobjeto(listastafields, FILESTAFIELDS)
                                           ptri=2*i+16
                                           msgalarm=paramfields[ptri]
                                           if msgalarm!="":
                                               print("Rep->",msgalarm)
                                               msgtxt=msgdict.get(msgalarm)
                                               print(msgtxt)
                                               try:
                                                   #msgtxt=msgtxt[:-2]
                                                   savealarmas(nombre,msgtxt,"m2N",canalop,horastr,urliot,namefile)
                                                   newalarma=True
                                               except:
                                                   print("Error leyendo mensaje>",msgalarm)
                                                   print(msgdict.get(msgalarm))
                                                   
                                elif sta_fields[ptr]==0: #Estado en minimo
                                    if valdata>valmax:
                                       print("Max de min en",numfield)
                                       #print(sta_fields,",",ptr)
                                       if sta_fields[ptr]!=2:
                                           sta_fields[ptr]=2
                                           #print(sta_fields,"1")
                                           listastafields[ptrditec]=sta_fields
                                           #print(listastafields,"2")
                                           saveobjeto(listastafields, FILESTAFIELDS)
                                           ptri=2*i+17
                                           msgalarm=paramfields[ptri]                                           
                                           if msgalarm!="":
                                               print("Rep+ de min>",msgalarm)
                                               msgtxt=msgdict.get(msgalarm)
                                               print(msgtxt)
                                               try:
                                                   #msgtxt=msgtxt[:-2]
                                                   savealarmas(nombre,msgtxt,"M2m",canalop,horastr,urliot,namefile)
                                                   newalarma=True
                                               except:
                                                   print("Error leyendo mensaje>",msgalarm)
                                                   print(msgdict.get(msgalarm))
                                                   
                                       
                                    elif valdata>valmin and valdata<valmax:
                                        print("A Normal de min en",numfield)
                                        #print(sta_fields,",",ptr)
                                        sta_fields[ptr]=1
                                        #print(sta_fields,"1")
                                        listastafields[ptrditec]=sta_fields
                                        #print(listastafields,"2")
                                        saveobjeto(listastafields, FILESTAFIELDS)
    
                                        
                                elif sta_fields[ptr]==2: #Estado en Maximo
                                    if valdata<valmax and valdata>valmin:
                                        print("A Normal de max en",numfield)
                                        #print(sta_fields,",",ptr)
                                        sta_fields[ptr]=1
                                        #print(sta_fields,"1")
                                        listastafields[ptrditec]=sta_fields
                                        #print(listastafields,"2")
                                        saveobjeto(listastafields, FILESTAFIELDS)
    
                                    elif valdata<valmin:
                                        print("A Min de max en",numfield)
                                        #print(sta_fields,",",ptr)
                                        if sta_fields[ptr]!=0:
                                           sta_fields[ptr]=0 
                                           #print(sta_fields,"1")
                                           listastafields[ptrditec]=sta_fields
                                           #print(listastafields,"2")
                                           saveobjeto(listastafields, FILESTAFIELDS)
                                           ptri=2*i+16
                                           msgalarm=paramfields[ptri]                                           
                                           if msgalarm!="":
                                               print("Rep->",msgalarm)
                                               msgtxt=msgdict.get(msgalarm)
                                               print(msgtxt)
                                               try:
                                                   #msgtxt=msgtxt[:-2]
                                                   savealarmas(nombre,msgtxt,"m2Ma",canalop,horastr,urliot,namefile)
                                                   newalarma=True
                                               except:
                                                   print("Error leyendo mensaje>",msgalarm)
                                                   print(msgdict.get(msgalarm))
                                                           
                        ptr=ptr+1
                    else:
                        ptr=ptr+1
                            
            if datacanal[9]>0:
                lastentry_oper[ptrditec]=datacanal[9]
            else:
                print("No se leyo data")
            
            if lastentry_operant[ptrditec]!=lastentry_oper[ptrditec]:
                saveobjeto(lastentry_oper,FILELASTOPER)
                lastentry_operant[ptrditec]=lastentry_oper[ptrditec]   
                #print("Guarda lastentry_oper")
                #print(lastentry_oper)
            if newalarma:
                print('TX ALARMAS...')
                archivo=open(namefile,"r")
                alarmas=archivo.readlines()
                cntr=0
                for trama in alarmas:
                    cntr=cntr+1
                    msg=trama
                    print(cntr,">",msg)
                    msg1=msg[:-1]
                    if flagsndmsg:
                        if chatid!="" and botid!="":
                            sndmsgtelegram(msg,chatid,botid)
                        else:
                            print("Telegram no configurado")
                            
                        
                        # twiliosid=paramditec[7]
                        # twiliotoken=paramditec[8]
                        # fononum=paramditec[9]
                        # print(twiliosid,",",twiliotoken,",",fononum)
                        # if twiliosid!="":
                        #     if twiliotoken!="":
                        #         if fononum!="":
                        #             msg1=msg[:-1]
                        #             print("SMS Twilio")
                                    #client = Client(twiliosid, twiliotoken)                                        
                                    #message = client.messages.create(body=msg1,from_='+16692006522',to=fononum)
                    else:
                        print("MSG no hab")
                    
                newalarma=False
                archivo.close()                            
                
#        else:
#            print(nombre," no hab")
            
        ptrditec=ptrditec+1             
        
    time.sleep(10)
