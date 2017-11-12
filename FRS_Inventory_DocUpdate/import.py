#!/python
# -*- coding: utf-8 -*-

### http://sametmax.com/lencoding-en-python-une-bonne-fois-pour-toute/
from __future__ import unicode_literals

"""
Importer les extractions du FRS BO dans la base de donnees
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
    #print("nbrL = ", nbrL)
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM CRS")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM BO_DOC_TYPES")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM BO_DOCS_LISTE")
    nbrL = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM BO_DOCS_MODIFS")
    nbrL = cursor.fetchone()
    # cursor.execute("SELECT COUNT(*) AS ""NbrL"" FROM nmeaValues")
    # nbrL = cursor.fetchone()
except Exception as e :
    print("Pb avec la DB [" + frsDbname + "]")
    db.close()
    quit()

## TS ISO8601 epoch
iso8601 = time.strftime("%Y%m%d%H%M%S")
epoch = int(time.time())
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


## INSERT des metadonnees
try :
    ## Heure de debut dans la table RUN
    sql = "INSERT INTO nmeaFiles(FileName, FileCheck, FileTsWrite, FileTsImport) VALUES ('" + basename + "', '" + fileCheck + "', " + mTimeIso + ", " + iso8601 + ");"
    cursor.execute(sql)
    sql = "SELECT LAST_INSERT_ROWID();" # print(cursor.lastrowid)
    cursor.execute(sql)
    fileId = cursor.fetchone()[0] # (3,)  donc [0] pour isoler le premier element
    #print(fileId)
    ## feed nmeaValues
    sql = "INSERT INTO nmeaValues(FileID, FileLineNum, NmeaID, NmeaVal) VALUES (?, ?, ?, ?);" # " + fileId + ", " + nLine + ", '" + id + "', '" + val + "'
    traceInfo = ""
    with open(frsFilename, 'r') as fFrs :
        nLine = 0
        for line in fFrs.readlines() :
            line = line.rstrip()
            if (line == "") :
                continue
            if (line[0:3] == "!AI") :
                continue
            nLine += 1
            if (line[0:1] != "$") : 
                traceInfo = traceInfo + line
                id = ""
                val = line
            else :
                commaPos = line.find(",")
                id = line[0:commaPos]
                val = line[commaPos + 1:]
            cursor.execute(sql, (fileId, nLine, id, val))    
    ## Heure de fin dans la table RUN
    sql = "INSERT INTO nmeaTraces(FileID, TraceName, LineStart, LineStop, TraceInfo) VALUES(?, ?, ?, ?, ?);"
    cursor.execute(sql, (fileId, basename, 1, nLine, traceInfo))
    db.commit()
    
    ## 
    
    print("Import de " + str(nLine) + " lignes (FileID:" + str(fileId) + ")")
except Exception as e :
    db.rollback()
    print("Pb avec import de [" + frsFilename + "]")
    print(e)
