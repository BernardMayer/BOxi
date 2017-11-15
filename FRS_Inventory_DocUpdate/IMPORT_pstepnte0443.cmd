@cls
@setlocal enabledelayedexpansion
@rem 65001 UTF8, 1252 	West European Latin, 850 	Multilingual (Latin I), 437 	United States
@rem cscript.exe //U
@rem @CHCP 1252

@set homeDir=".\"
@set sqlBin="D:\myTools\sqlite\sqlite3.exe"
@set sqlHome="D:\RepoS\BOxi\FRS_Inventory_DocUpdate"
@set sqlDB="%sqlHome%\BO_inventories.sqlite"
@set pyBin="D:\myTools\Python\Python36\python.exe"
@rem @set dataInHome="D:\BOXI\Liste_Docs_TtesCrs\data"
@set dataInHome="D:\BOXI\Liste_Docs_TtesCrs\Data-FullClientOnly-ToutesCaisses"
@set dataInPattern="Liste_Docs_*.csv"
@set importScript=import.py

@REM Compilation des fichiers inventaires des FRS en 1 seul
@set datasInDir="C:\temp\Data-FullClientOnly-ToutesCaisses"
@set datasInPattern="Liste_Docs_*.csv"
@set tmpDir=%datasInDir%\"compil"
@set tmpFile="FRS_Inventory_DocUpdate.tmp"
if not exist %tmpDir% mkdir %tmpDir%
copy %datasInDir%\%datasInPattern% %tmpDir%\%tmpFile%

@echo Alimentation de la DB
set BO_IMPORT_INVENTORY_RUN_ID=7
%pyBin% %importScript% "D:\BOXI\Liste_Docs_TtesCrs\Data-FullClientOnly-ToutesCaisses\Liste_Docs_CL_Documents communautaires.csv" %sqlDB%
goto EOF

pause
del %tmpDir%\%tmpFile%


@REM -- Liste des fichiers
@rem echo. > %dataInHome%\test.txt
@REM REM REM FOR /f "delims=" %%c IN ('type "BO_ListeDesPlateformes.txt"') DO C:\Windows\SysWOW64\cscript.exe //Nologo //T:3600 .\%Nom_script%.vbs %username% %pwd% %%c %FRS_sommet% >> %FICH_LOG% 2>&1
@rem FOR /f "delims=" %%c IN ('dir /b "%dataInHome%\%dataInPattern%"') DO @echo %%c >> "%dataInHome%\test.txt"
@rem FOR /f "delims=" %%c IN ('dir /b %dataInHome%\%dataInPattern%') DO @echo %%c
@rem FOR /f "delims=" %%f IN ('dir /b %dataInHome%\%dataInPattern%') DO %pyBin% %importScript% %%f %sqlDB% >> "%dataInHome%\test.txt"

@rem @set sqlFile=%homeDir%\DocUpdate_InitializeDB.sql
@rem %sqlBin% %sqlDB% < %sqlFile%

