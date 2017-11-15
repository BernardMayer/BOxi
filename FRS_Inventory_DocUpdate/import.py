#!/python
# -*- coding: utf-8 -*-

### http://sametmax.com/lencoding-en-python-une-bonne-fois-pour-toute/
from __future__ import unicode_literals

"""
Importer les extractions du FRS BO dans la base de donnees

(separateur est \t et non plus | )
##  CE	AWZEddzi5GZMnYKK70cB5J8	5151	FullClient	Liste des automates sans activite depuis 24H	Root Folder/Documents CACP/Direction Bancaire et Technologies	22/09/2016 13:40:40	22/09/2016 13:40:40
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
#   - Ordre des colonnes (colsName)
fileInSep = '\t' # "|"
#columnsOrder = (1, 3, 2, 5, 4, 6, 7, 8)
colsName = ("CR_ID", "SI_CUID", "SI_ID", "SI_KIND", "SI_NAME", "DOC_FOLDER", "DT_CREATE", "DT_MODIF")
nbrCols = len(colsName)
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

try :
    ##  Le dernier RUN est-il bien terminé ? ou bien est-il en cours ?
    sql = "SELECT RUN_ID, RUN_START_EPOCH, run_start_TS, run_start_DT, run_start_D, RUN_STOP_EPOCH, RUN_STOP_TS, RUN_STOP_DT, RUN_STOP_D FROM RUN WHERE RUN_ID = (SELECT MAX(RUN_ID) FROM RUN)"
    cursor.execute(sql)
    (run_id, run_start_epoch, run_start_TS, run_start_DT, run_start_D, run_stop_epoch, run_stop_ts, run_stop_dt, run_stop_d) = cursor.fetchone()
    if (run_stop_epoch is None or run_stop_ts is None or run_stop_dt is None or run_stop_d is None) :
        print("Pb : Dernier RUN non termine / en cours")
        exit()
    else :
        nextRun          = str(run_id + 1)
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

## Debut du traitement
if (True) :
# try :
    with open(frsFilename, 'r') as fFrs :
        ## Purge de la table d'accueil
        sql = "DELETE FROM BO_DOCS_LISTE"
        cursor.execute(sql)
        ## Heure de debut dans la table RUN
        sql = "INSERT INTO RUN(RUN_ID, RUN_START_EPOCH, run_start_TS, run_start_DT, run_start_D) VALUES (" + nextRun + ", " + str(run_start_epoch) + ", '" + run_start_TS + "', '" + run_start_DT + "', " + run_start_D + ");"
        cursor.execute(sql)
        print("SQL START = [" + sql + "]")
        # sql = "SELECT LAST_INSERT_ROWID();" # print(cursor.lastrowid)
        # cursor.execute(sql)
        # runID = str(cursor.fetchone()[0]) # (3,)  donc [0] pour isoler le premier element
        
        ## Preparation du SQL d'insertion
        ## la variable liste des colonnes colsName = list("CR_ID", "SI_CUID", "SI_ID", "SI_KIND", "SI_NAME", "DOC_FOLDER", "DT_CREATE", "DT_MODIF")
        sql = "INSERT INTO " + tblDocs + " (RUN_ID"
        for col in colsName : 
            sql = sql + ", " + col
        sql = sql + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        print("SQL INSERT = [" + sql + "]")
        nLine = 0
        for line in fFrs.readlines() :
            line = line.rstrip()
            if (line == "") :
                continue
            # if (line[0:1] == "-" or line[0:1] == "'" or line[0:1] == "#") :
                # continue
            # On attend un code alphanumerique comme premier caractere
            # La compilation des fichiers en 1 seul ajoute 1 derniere ligne constituee du caractere \x1a ou \x1e ou \xe9
            if (not line[0:1].isalnum()) : 
                continue 
            cols = (nextRun + fileInSep + line).split(fileInSep)
            cursor.execute(sql, cols)
            nLine += 1
            
        print(cols)
        print("SQL INSERT = [" + sql + "]")
        
        ## Comptage import
        sql = "SELECT COUNT(*) AS ""NbrL"" FROM BO_DOCS_LISTE"
        cursor.execute(sql)
        print("Comptage import : " + str(cursor.fetchone()[0]))
        
        ## Historisation 
        sql = "INSERT INTO BO_DOCS_MODIFS (RUN_ID, CR_ID, SI_ID, DT_MODIF, D_MODIF) SELECT RUN_ID, CR_ID, SI_ID, DT_MODIF, SUBSTR(DT_MODIF, 7, 4) || SUBSTR(DT_MODIF, 4, 2) || SUBSTR(DT_MODIF, 1, 2)  FROM BO_DOCS_LISTE"
        cursor.execute(sql)
        sql = "SELECT COUNT(*) FROM BO_DOCS_MODIFS"
        cursor.execute(sql)
        print("Comptage historisation : " + str(cursor.fetchone()[0]))
        
        ## Heure de fin dans la table RUN
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
    ## FIN
    print("Import de " + str(nLine) + " lignes")
# except Exception as e :
    # db.rollback()
    # print("Pb avec import de [" + frsFilename + "]")
    # print(e)
# finally :
    db.close()