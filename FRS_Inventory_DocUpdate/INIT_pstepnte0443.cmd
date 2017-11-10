@cls
@setlocal enabledelayedexpansion
@rem 65001 UTF8, 1252 	West European Latin, 850 	Multilingual (Latin I), 437 	United States
@rem cscript.exe //U
@rem @CHCP 1252

@set homeDir=".\"
@set sqlBin="D:\myTools\sqlite\sqlite3.exe"
@set sqlHome="D:\RepoS\BOxi\FRS_Inventory_DocUpdate"
@set sqlDB="%sqlHome%\BO_inventories.sqlite"

@echo Initialisation de la DB
@set sqlFile=%homeDir%\DocUpdate_InitializeDB.sql
%sqlBin% %sqlDB% < %sqlFile%