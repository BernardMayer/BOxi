#!/python
# -*- coding: utf-8 -*-

### http://sametmax.com/lencoding-en-python-une-bonne-fois-pour-toute/
from __future__ import unicode_literals

"""
Importer les extractions du FRS BO dans la base de donnees
(separateur est \t et non | )
AL|AXoBxxVBY0dArrkgpP6xlIc|17432|FullClient|CANAL_BAM_ANALYSE|Root Folder/Administration Tools|19/02/2015 14:36:14|12/03/2015 09:26:23

CREATE TABLE BO_DOCS_LISTE (
	CR_ID INTEGER NOT NULL,
	SI_ID INTEGER NOT NULL,
	SI_CUID TEXT NOT NULL,
	SI_NAME TEXT NOT NULL,
	SI_KIND TEXT,
	DOC_FOLDER TEXT,
	DT_CREATE TEXT,
	DT_MODIF TEXT NOT NULL
);

##  Quel est l'ordre des colonnes du fichier, par rapport aux colonnes de la table ?
##  Definir les colonnes de la table, dans l'ordre dans lequel elles se presentent dans le fichier.
##  CE	AWZEddzi5GZMnYKK70cB5J8	5151	FullClient	Liste des automates sans activite depuis 24H	Root Folder/Documents CACP/Direction Bancaire et Technologies	22/09/2016 13:40:40	22/09/2016 13:40:40
##  chercher --> colsName = ("CR_ID", "SI_CUID", "SI_ID", "SI_KIND", "SI_NAME", "DOC_FOLDER", "DT_CREATE", "DT_MODIF")

"""

import cgitb
cgitb.enable(format='text')
import pyodbc
import sqlite3
import hashlib
import sys
import os
#import string
import pathlib
import argparse
import configparser
import re
#from collections import OrderedDict
import collections
import time
import datetime
import decimal

decimal.getcontext().prec = 2
TAB = '\t'
FileOutSep = TAB
FileOutHeader = False
Verbose = True
#dIni['verbose'] = Verbose
dtNow  = datetime.datetime.today()
tsNow = dtNow.timestamp()


#bShowIdentifier = os.getenv("dsXidentifier", False)

##  Les infos necessaires :
#   - Fichier en entree (parametre 1)
#   - Separateur de ce fichier en entree
#   - Fichier sqlite en sortie (parametre 2)
#   - Ordre des colonnes (columnsOrder) --> (colsOrder)
fileInSep = '\t' # "|"
#columnsOrder = (1, 3, 2, 5, 4, 6, 7, 8)
colsName = ("CR_ID", "SI_CUID", "SI_ID", "SI_KIND", "SI_NAME", "DOC_FOLDER", "DT_CREATE", "DT_MODIF")
tblDocs = "BO_DOCS_LISTE"

## fichier a traiter
me = sys.argv[0]
#args = sys.argv[1:]
if (len(sys.argv) != 3) :
    print(me + " : Pas le bon nombre de parametres.")
    print("Usage : " + me + " <Chemin et nom du fichier extraction FRS> <Chemin et nom de la base Sqlite>")
    quit()
else :
    frsFilename = sys.argv[1]
    frsDbname = sys.argv[2]
    print("Import du fichier FRS [" + frsFilename + "] dans la base Sqlite [" + frsDbname + "]")

## Tests prealables
if (not os.path.exists(frsFilename)) :
    print("Fichier", frsFilename, "introuvable")
    quit()
if (not os.path.exists(frsDbname)) :
    print("Base", frsDbname, "introuvable")
    quit()
try :
    db = sqlite3.connect(frsDbname)
    cursor = db.cursor()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM RUN")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM CRS")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM BO_DOC_TYPES")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM BO_DOCS_LISTE")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM BO_DOCS_MODIFS")
    nbrL = cursor.fetchone()
    # db.close()
except Exception as e :
    quit()

## TS ISO8601 epoch
iso8601 = time.strftime("%Y%m%d%H%M%S")
epoch = int(time.time())
DT = time.strftime("%Y-%m-%d %H:%M:%S")

# print(datetime.datetime.now().isoformat()) # 2017-10-31T10:52:02.101865
# print(time.strftime("%Y-%m-%d %H:%M:%S")) # 2017-10-31 10:52:02
# print(int(time.time())) # 1509443642

    

mTimeEpoch = int(os.path.getmtime(frsFilename)) # format epoch
# print("mTimeEpoch : " + str(mTimeEpoch))
# print(datetime.datetime.utcfromtimestamp(mTimeEpoch)) # 2017-10-19 13:40:11
mTimeStruct = time.localtime(mTimeEpoch)
# print("mTimeStruct : " + str(mTimeStruct)) # mTimeLocal : time.struct_time(tm_year=2017, tm_mon=10, tm_mday=19, tm_hour=15, tm_min=40, tm_sec=11, tm_wday=3, tm_yday=292, tm_isdst=1)
mTimeIso = time.strftime("%Y%m%d%H%M%S", mTimeStruct)
# print("mTimeIso : " + mTimeIso)

basename = os.path.basename(frsFilename)

##
##  Le dernier RUN est-il termine ?
# insert into run (run_id) values (9);
# delete from run where run_id = 
##  
bo_import_inventory_run_id = int(os.getenv('BO_IMPORT_INVENTORY_RUN_ID', 0)) # False


try :
    ##  Le dernier RUN est-il bien terminé ? ou bien est-il en cours ?
    sql = "SELECT RUN_ID, RUN_START_EPOCH, run_start_TS, run_start_DT, run_start_D, RUN_STOP_EPOCH, RUN_STOP_TS, RUN_STOP_DT, RUN_STOP_D FROM RUN WHERE RUN_ID = (SELECT MAX(RUN_ID) FROM RUN)"
    cursor.execute(sql)
    (run_id, run_start_epoch, run_start_TS, run_start_DT, run_start_D, run_stop_epoch, run_stop_ts, run_stop_dt, run_stop_d) = cursor.fetchone()
    #print(run_stop_ts)
    if (run_stop_epoch is None or run_stop_ts is None or run_stop_dt is None or run_stop_d is None) :
        print("Pb : Dernier RUN non termine / en cours")
        exit()
    else :
        ##  Monter le RUN_ID en variable d'environnement
        ##  afin que les autres execution l'utilisent
        
        #nextRun          = str(run_id + 1)
        if (bo_import_inventory_run_id != 0 and bo_import_inventory_run_id < run_id) :
            print("Pb : Ambiguite entre la variable d'environnement BO_IMPORT_INVENTORY_RUN_ID (" + str(bo_import_inventory_run_id) + ") et la plus grande valeur de RUN_ID de la table RUN (" + str(run_id) + ")") 
            db.close()
            exit()
        else :
            #nextRun = str(max(run_id, bo_import_inventory_run_id))
            if (bo_import_inventory_run_id == 0) :
                nextRun = str(run_id)
                os.putenv('BO_IMPORT_INVENTORY_RUN_ID', nextRun)
            
        run_start_epoch  = epoch
        run_start_TS     = iso8601
        run_start_DT     = DT
        run_start_D      = iso8601[0:8]
        print("Le prochain RUN sera le " + nextRun + ", en date epoch[" + str(run_start_epoch) + "], TS[" + run_start_TS + "], DT[" + run_start_DT + "], D[" + run_start_D + "]")
except Exception as e :
    print("Pb avec recherche dernier RUN")
    print(e)
    exit()
finally :
    pass
#print("OK", nextRun)

   




# print("SQL = " + sql)
# exit()
        


## Debut du traitement
# try :
if (True) :
    with open(frsFilename, 'r') as fFrs :
        ## Heure de debut dans la table RUN
        sql = "INSERT INTO RUN(RUN_ID, RUN_START_EPOCH, run_start_TS, run_start_DT, run_start_D) VALUES (" + nextRun + ", " + str(run_start_epoch) + ", '" + run_start_TS + "', '" + run_start_DT + "', " + run_start_D + ");"
        cursor.execute(sql)
        print("SQL START = [" + sql + "]")
        # sql = "SELECT LAST_INSERT_ROWID();" # print(cursor.lastrowid)
        # cursor.execute(sql)
        # runID = str(cursor.fetchone()[0]) # (3,)  donc [0] pour isoler le premier element
        #print(runID)
        
        ## Preparation du SQL d'insertion
        ## la variable liste des colonnes colsName = list("CR_ID", "SI_CUID", "SI_ID", "SI_KIND", "SI_NAME", "DOC_FOLDER", "DT_CREATE", "DT_MODIF")
        sql = "INSERT INTO " + tblDocs + " (RUN_ID"
        for col in colsName : 
            sql = sql + ", " + col
        sql = sql + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        #print("SQL INSERT = [" + sql + "]")
        #exit()
        
        
        sql2 = "INSERT INTO " + tblDocs + " (RUN_ID = " + nextRun
        for col in colsName : 
            sql2 = sql2 + ", " + col

        # sql = "INSERT INTO nmeaValues(FileID, FileLineNum, NmeaID, NmeaVal) VALUES (?, ?, ?, ?);" # " + fileId + ", " + nLine + ", '" + id + "', '" + val + "'
        # traceInfo = ""
        nLine = 0
        for line in fFrs.readlines() :
            line = line.rstrip()
            if (line == "") :
                continue
            if (line[0:1] == "-" or line[0:1] == "'" or line[0:1] == "#") :
                continue
            nLine += 1
            
            cols = (nextRun + fileInSep + line).split(fileInSep)
            # line = nextRun + fileInSep + line
            # cols = line.split(fileInSep)
            cursor.execute(sql, cols)
            # BMr 2017114 Ne fonctionne pas ???
            
            #cols = line.split(fileInSep)
            
            
            # if (line[0:1] != "$") : 
                # traceInfo = traceInfo + line
                # id = ""
                # val = line
            # else :
                # commaPos = line.find(",")
                # id = line[0:commaPos]
                # val = line[commaPos + 1:]
            # cursor.execute(sql, (fileId, nLine, id, val)) 
        print(cols)
        print("SQL INSERT = [" + sql + "]")
        
        ## Heure de fin dans la table RUN
        # sql = "INSERT INTO nmeaTraces(FileID, TraceName, LineStart, LineStop, TraceInfo) VALUES(?, ?, ?, ?, ?);"
        run_stop_epoch = str(int(time.time()))
        run_stop_TS = time.strftime("%Y%m%d%H%M%S")
        run_stop_DT = time.strftime("%Y-%m-%d %H:%M:%S")
        run_stop_D  = run_stop_TS[0:8]
        sql =       " UPDATE RUN SET "
        sql = sql + " RUN_STOP_EPOCH = " + run_stop_epoch + ", RUN_STOP_TS = '" + run_stop_TS + "', RUN_STOP_DT = '" + run_stop_DT + "', RUN_STOP_D = " + run_stop_D
        sql = sql + " WHERE RUN_ID = " + nextRun
        print("SQL STOP = [" + sql + "]")
        cursor.execute(sql)
        db.commit()

    # cursor.execute(sql, (fileId, basename, 1, nLine, traceInfo))
    # db.commit()
    
    ## 
    
    print("Import de " + str(nLine) + " lignes")
# except Exception as e :
    # db.rollback()
    # print("Pb avec import de [" + frsFilename + "]")
    # print(e)
    # db.close()

db.close()