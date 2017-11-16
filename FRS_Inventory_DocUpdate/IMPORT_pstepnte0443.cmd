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
@set tmpDir=%datasInDir%\compil
@set tmpFile=FRS_Inventory_DocUpdate.tmp
if not exist %tmpDir% mkdir %tmpDir%
copy %datasInDir%\%datasInPattern% %tmpDir%\%tmpFile%

@echo Alimentation de la DB
%pyBin% %importScript% %tmpDir%\%tmpFile% %sqlDB%
goto EOF

pause
REM del %tmpDir%\%tmpFile%
