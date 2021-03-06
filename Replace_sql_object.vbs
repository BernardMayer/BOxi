Public Dict_Fonctions_KO, Dict_Datatypes_KO, Dict_MOTS_CLE, Dict_univers
Public Rep_univers_SQL, Rep_univers_TDA
Public Nb_Feuillets_a_traiter
Public Dict_Feuillets
Public User, Pwd, Domaine, Groupe_BO, FSO, Mode_debug, Bypass_controle_cr, Traitements
Public Fichier_log, Fichier_log_obj
Public Rep_ini, Rep_vbs, Rep_Reports
Public No_ligne
Public liste_fonctions
Public g_strScriptNameNoExt, g_strScriptDrive
Public Nom_fichier_INI
Public Nb_univers_a_traiter, Nb_mots_cle_a_traiter
Public Feuillet
Public Nb_datatypes_SQL_KO, Nb_Fonctions_SQL_KO
Public Nb_fn
'
' Emplacement des colonnes du feuillet Objects
'
Col_Universe_Name  = 2
Col_Class_path     = 9
Col_ClassId        = 7
Col_ObjectId       = 8
Col_Class_Name     = 10
Col_Object_Name    = 11
COL_STATUT         = 12
COL_Show           = 13
COL_SQL_MICROSOFT  = 14
COL_SQL_TERADATA   = 15
Col_SQL_LOV        = 16
Col_SQL_WHERE      = 17
'
' Emplacement des colonnes du feuillet Classes
'
Col_Universe_Name  = 1
Col_Class_path     = 2
Col_ClassId        = 3
Col_Class_Name     = 4
Col_Class_Description = 5
COL_STATUT            = 6
COL_Show              = 7

' Const ForReading = 1, ForWriting = 2, ForAppending = 3
Const FOR_READING = 1
Const ForReading  = 1
Const READ_ONLY   = 1
Const ForWriting  = 2
Const FOR_WRITING = 8
Const OverWriteFiles = True
Const Normal      = 0
Const ReadOnly    = 1

Const boBusObjDirectory        = 0    ' BusinessObjects directory
Const boDocumentDirectory    = 1    ' UserDocs directory
Const boTemplateDirectory      = 2    ' Template directory
Const boUniverseDirectory       = 3    ' Universe directory
Const boScriptsDirectory          = 4    ' Scripts directory
Const boLocDataDirectory        = 5     ' Local Data directory
Const boSharedDataDirectory  = 6     ' Shared Data directory
Const Dssecured = 2

'
' Objet Crystal report
'
Dim oSessionMgr, ceSession, iStore, oIObjects
Dim Ogroupes, Groupe_id
Dim Dossier_univers
Dim ObjSecurityInfo, ObjSecurityPrincipals
Dim principal
Dim ceRoleAdvanced, ceRoleNoAccess, ceRoleView, ceRoleSchedule, ceRoleViewOnDemand, ceRoleFullControl
Dim Ligne_Dict, Array_Ligne, Array_temp
Dim Sous_rep_defaut

ceRoleAdvanced = 0
ceRoleNoAccess = 1
ceRoleView = 2
ceRoleSchedule = 3
ceRoleViewOnDemand = 4
ceRoleFullControl = 5

'
' Ouverture du fichier ini
'

Mode_debug = "OUI"

' ****************************************************************
'
' Initialisation des Objets FSO, Designer et Crystal report  et network
'
' ****************************************************************

set FSO = CreateObject("Scripting.FileSystemObject")

Set DesignerSDK = Wscript.CreateObject("Designer.Application")

Set objShell = WScript.CreateObject("WScript.Shell")
'
'  Création des variables globales et des variables par défaut
'
' set wsArgs = wscript.arguments 'Wscript Arguments collection
' if wsArgs.count <> 1 then
'    wscript.echo "Preciser le nom du feuillet a traiter"
'    wscript.quit 'Arret immediat du script"
' end if

' Feuillet = wsArgs(0)

Create_variables_globales()
'
'  Création du fichier de Log
'
Create_log_file()

Lecture_fichier_global(Nom_fichier_INI)


call  WriteLogFile(0," ")
call  WriteLogFile(0,"Debut du script  "&g_strScriptNameNoExt)
Call  WriteLogFile(0,"  ")
Call  WriteLogFile(0,"Feuillet traite : " & Feuillet)

Rep_XLS = "D:\Developpement\DWH_V2\Projets\Deco_V2\XSL_Teradata"

On error Resume next

DesignerSDK.Visible = False
If  CLng(Err.Number) <> 0 Then
        call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
        call  WriteLogFile(1,"Ligne  # DesignerSDK.Visible = False")
        call  WriteLogFile(1,"Arret immediat du script")
       wscript.quit(1)
End if
On error Goto 0

If Ucase(Pwd) = "NULL" Then
        On error Resume next

        DesignerSDK.Interactive = True
        If  CLng(Err.Number) <> 0 Then
                call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
                call  WriteLogFile(1,"Ligne  # DesignerSDK.Interactive = True")
                call  WriteLogFile(1,"Arret immediat du script")
               wscript.quit(1)
        End if
        '
        ' Login à BO Designer
        '

       Call DesignerSDK.Logon(User, Pwd, cmsName, "secEnterprise")

       If  CLng(Err.Number) <> 0 Then
                call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
                call  WriteLogFile(1,"Ligne  #  DesignerSDK.LoginAs , ,False, "&Domaine_securite_BO)
                call  WriteLogFile(1,"Arret immediat du script")
               wscript.quit(1)
       End if
       On error Goto 0

Else
        On error Resume next

        Call DesignerSDK.Logon(User, Pwd, cmsName, "secEnterprise")
        If  CLng(Err.Number) <> 0 Then
                call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
                call  WriteLogFile(1,"Ligne  #  DesignerSDK.LoginAs , ,False, "&Domaine_securite_BO)
                call  WriteLogFile(1,"Arret immediat du script")
               wscript.quit(1)
       End if
       On error Goto 0

End if
'
' Récupération des répertoires par défaut
'
Rep_documents_defaut = DesignerSDK.GetInstallDirectory(boDocumentDirectory)

Rep_univers_SDK   = DesignerSDK.GetInstallDirectory(boUniverseDirectory)

Rep_univers_defaut  = Rep_univers_SDK  & "\" & Sous_rep_defaut

call WriteLogFile(3," ")
call WriteLogFile(0,"Répertoire par défaut pour les Univers      : " & rep_univers_defaut)
call WriteLogFile(0,"Répertoire ZX00 des univers                      : " & rep_univers_ZX00)
call WriteLogFile(3," ")

On error Resume next
'
' Gestion de l interactivite de BO
'
If Ucase(Interactive_global) = "NON" Then
       DesignerSDK.Visible = false
       If  CLng(Err.Number) <> 0 Then
              call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
              call  WriteLogFile(1,"Ligne  # DesignerSDK.Visible = False")
              call  WriteLogFile(1,"Arret immediat du script")
              wscript.quit(1)
       End if

       DesignerSDK.Interactive = False
       If  CLng(Err.Number) <> 0 Then
              call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
              call  WriteLogFile(1,"Ligne  # DesignerSDK.Interactive = False")
              call  WriteLogFile(1,"Arret immediat du script")
              wscript.quit(1)
       End if
else

       DesignerSDK.Visible = True
       If  CLng(Err.Number) <> 0 Then
              call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
              call  WriteLogFile(1,"Ligne  # DesignerSDK.Visible = False")
              call  WriteLogFile(1,"Arret immediat du script")
              wscript.quit(1)
       End if

       DesignerSDK.Interactive = True
       If  CLng(Err.Number) <> 0 Then
              call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
              call  WriteLogFile(1,"Ligne  # DesignerSDK.Interactive = False")
              call  WriteLogFile(1,"Arret immediat du script")
              wscript.quit(1)
       End if
End if

On error Goto 0
Call WriteLogFile(0," ")
call  WriteLogFile(0,"Connexion à BO Designer effectuee")
Call WriteLogFile(0," ")

For No_univers_a_traiter = 1 to NB_univers_a_traiter

    Nom_Univers = Dict_univers(No_univers_a_traiter)

wscript.echo "Nom_univers = " & Nom_univers

    Rep_univers_SQL  = "D:\Developpement\DWH_V2\Projets\Deco_V2\Univers\Univers_SQL"
    Nom_Univers_SQL   = Rep_univers_sql & "\" & Nom_Univers & ".unv"

    Rep_univers_TDA  = "D:\Developpement\DWH_V2\Projets\Deco_V2\Univers\Univers_TDA"
    Nom_Univers_TDA   = Rep_univers_TDA & "\" & Nom_Univers & ".unv"

wscript.echo "Nom_Univers_SQL = " & Nom_Univers_SQL

     Set Obj_Univers = DesignerSDK.Universes.Open(Nom_Univers_SQL)
     If  CLng(Err.Number) <> 0 Then
            call  WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
            Call WriteLogFile(1,"Ligne   # Set Obj_Univers = DesignerSDK.Universes.Open("& Nom_Univers_SQL &")")
            call  WriteLogFile(1,"Arret immediat du script")
            DesignerSDK.quit
            wscript.quit(1)
     End if

    Set objExcel = CreateObject("Excel.Application")
    objExcel.Visible = True

    Nom_univers = trim(Dict_univers.item(No_univers_a_traiter))
    Full_XLS = rep_XLS & "\" & Nom_univers & " - Teradata.xlsx"

    Call  WriteLogFile(0,"Nom_univers  = " & Nom_univers)
    Call  WriteLogFile(0,"Full_XLS     = " & Full_XLS )

    Set objWorkbook = objExcel.Workbooks.Open(Full_XLS)

'    Nom_univers_full = Nom_univers & ".unv"

    for No_feuillet = 1 to Nb_feuillets_a_traiter
        Nom_feuillet = trim(Dict_Feuillets.Item(No_feuillet))
        UFeuillet = Ucase(Nom_feuillet)
        Select UFeuillet
            Case "OBJECTS"

               '
               ' Ouverture du fichier Univers
               '
               Set oFeuille_Objets = objWorkbook.Worksheets(Nom_Feuillet)
               oFeuille_Objets.Activate

               Nb_rows = oFeuille_Objets.UsedRange.Rows.Count
               Nb_cols = oFeuille_Objets.UsedRange.Columns.Count

               Call  WriteLogFile(0,"  ")
               Call  WriteLogFile(0,"nb_rows =  " & nb_rows)
               Call  WriteLogFile(0,"nb_cols =  " & nb_cols)

                Nb_objet_modifie = 0
                Nb_objet_cache   = 0

                for No_ligne = 2 to Nb_rows

    ' if no_ligne > 47 then
    '    wscript.quit
    ' End if

                '
                ' Feuille des Objets
                '

                '
                ' positionnement sur le champs Recherche
                '
                    objet_trouve = False
                    strClass_path = oFeuille_Objets.Cells(No_ligne,Col_Class_path)
                    strClass_Name = oFeuille_Objets.Cells(No_ligne,Col_Class_Name)
                    strObject_Name = oFeuille_Objets.Cells(No_ligne,Col_Object_Name)
                    SQL_Microsoft = trim(oFeuille_Objets.Cells(No_ligne,COL_SQL_MICROSOFT))
                    SQL_TERADATA = trim(oFeuille_Objets.Cells(No_ligne,COL_SQL_TERADATA))
                    SQL_TERADATA = replace(SQL_TERADATA,CHR(10), " ")
                    strShow = Ucase(trim(oFeuille_Objets.Cells(No_ligne,Col_Show)))

                '   strObject_Has_LoV = trim(oFeuille_Objets.Cells(No_ligne,Col_Object_Has_LoV))
                    strLOV_original = oFeuille_Objets.Cells(No_ligne,Col_SQL_LOV)
                    strLOV = trim(strLOV_original)
                    strStatut = Ucase(trim(oFeuille_Objets.Cells(No_ligne,COL_STATUT)))
                    strClassId = oFeuille_Objets.Cells(No_ligne,Col_ClassId)
                    strObjectId = oFeuille_Objets.Cells(No_ligne,Col_ObjectId)
                    strOWhere = oFeuille_Objets.Cells(No_ligne,Col_SQL_WHERE)
                    strOwhere_original = strOWhere
                    strOwhere = trim(strOwhere_original)

                    select case strSTATUT
                    Case "U" Then

            '           wscript.echo "strObjectId = " & strObjectId
            '           wscript.echo "SQL_Microsoft   = " & SQL_Microsoft
            '           wscript.echo "SQL_TERADATA   = " & SQL_TERADATA
            '           wscript.echo "strStatut   = " & strStatut
            '           wscript.echo "strObjectId   = " & strObjectId
            '           wscript.echo "strClassId   = " & strClassId

                        set Oclasses =  Obj_univers.Classes.findclass(strClass_Name)
            ' LngID = CLng(strClassId)

            ' wscript.echo "LngID = " & LngID
            ' set Oclasses =  Obj_univers.Classes.item(LngID)
            ' wscript.echo "apres setoclasses"

            ' wscript.quit

            '            wscript.echo "Oclasses.Objects.Count = " & Oclasses.Objects.Count

                        for Each Object in Oclasses.Objects

            '                wscript.echo "Nom de l'objet = " & Object.name
            '                wscript.echo "Id de l'objet  = " & Object.Id

                            Nb_objects = Oclasses.Objects.Count
                            for No_object = 1 to Nb_objects

                                if Object.Id = strObjectId and objet_trouve = False then

                                    If strShow = "FALSE" then
                                        Object.show = False
                                        Call  WriteLogFile(0,"Objet " & Object.name & " est passe en 'Hidden'")
                                        Call  WriteLogFile(0," " )

                                        Nb_objet_cache = Nb_objet_cache + 1

                                    Else
                                        Object.select = SQL_TERADATA
                                        Call  WriteLogFile(0,"Objet " & Object.name & " modifie")
                                        Call  WriteLogFile(0,"Avant - " & SQL_Microsoft)
                                        Call  WriteLogFile(0,"Apres - " & SQL_TERADATA)
                                        Call  WriteLogFile(0," " )

                                        Nb_objet_modifie = Nb_objet_modifie + 1
                                    End if
                                    No_objects = Nb_objects + 1
                                    objet_trouve = True
                                End if
                            next

                            if objet_trouve then exit for
                        Next

                    End select

                Next
        Case "CLASSES"
           '
           ' Ouverture du fichier Univers
           '
           Set oFeuille_Objets = objWorkbook.Worksheets(Feuillet)
           oFeuille_Objets.Activate

           Nb_rows = oFeuille_Objets.UsedRange.Rows.Count
           Nb_cols = oFeuille_Objets.UsedRange.Columns.Count

           Call  WriteLogFile(0,"  ")
           Call  WriteLogFile(0,"nb_rows =  " & nb_rows)
           Call  WriteLogFile(0,"nb_cols =  " & nb_cols)

            Nom_univers_full = Nom_univers & ".unv"
            Nb_classes_modifie = 0
            Nb_classes_cache   = 0

            for No_ligne = 2 to Nb_rows

    ' if no_ligne > 47 then
    '    wscript.quit
    ' End if

            '
            ' Feuille des Objets
            '

            '
            ' positionnement sur le champs Recherche
            '

                class_trouve = False
                strClass_path = oFeuille_Objets.Cells(No_ligne,Col_Class_path)
                strClass_Name = oFeuille_Objets.Cells(No_ligne,Col_Class_Name)
                strShow = Ucase(trim(oFeuille_Objets.Cells(No_ligne,Col_Show)))
                strClassId = oFeuille_Objets.Cells(No_ligne,Col_ClassId)
                strStatut = Ucase(trim(oFeuille_Objets.Cells(No_ligne,COL_STATUT)))

                select case strSTATUT
                Case "U" Then

        '           wscript.echo "strClassId   = " & strClassId

                    set Oclasses =  Obj_univers.Classes.findclass(strClass_Name)

        '            wscript.echo "Oclasses.Objects.Count = " & Oclasses.Objects.Count

                    for Each class in Oclasses.Class

        '                wscript.echo "Nom de la classe = " & Class.name
        '                wscript.echo "Id de la classe  = " & Class.Id


                            if Class.Id = strClassId and Class_trouve = False then

                                If strShow = "FALSE" then
                                    Class.show = False
                                    Call  WriteLogFile(0,"Objet " & Object.name & " est passe en 'Hidden'")
                                    Call  WriteLogFile(0," " )

                                    Nb_class_cache = Nb_class_cache + 1

                                End if
                                exit for
                                Class_trouve = True
                            End if
                        next

                    Next

                End select

            Next
        End if

    Call  WriteLogFile(0,"Nombre d'objets modifies       : " & Nb_objet_modifie)
    Call  WriteLogFile(0,"Nombre d'objets caches (Hidden) : " & Nb_objet_cache)
    Call  WriteLogFile(0,"Nombre de classes caches (Hidden) : " & Nb_class_cache)
    objExcel.WorkBooks.close

    Obj_univers.SaveAs(Nom_Univers_TDA)
    If  CLng(Err.Number) <> 0 Then
         call   WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
         Call  WriteLogFile(1,"Ligne   # Obj_univers.save(" & Nom_Univers_TDA & ")")
         call   WriteLogFile(1,"Arret immédiat du script ")
         DesignerSDK.quit
         wscript.quit(1)
    End If

    Obj_univers.close
    If  CLng(Err.Number) <> 0 Then
             call   WriteLogFile(1,"Erreur # " & CStr(Err.Number) & ", "&Err.description&","&Err.source)
             Call  WriteLogFile(1,"Ligne   # Obj_univers.close")
             call   WriteLogFile(1,"Arret immédiat du script ")
             DesignerSDK.quit
             wscript.quit(1)
    End If
Next

objExcel.quit
Obj_univers
wscript.quit

' //////////////////////////////////////////////////////////////////////////////////////////////////////////////
' | Lecture_fichier_global
' |
' | Lecture du fichier ini
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////
Sub Lecture_fichier_global(Nom_fichier)
Dim Filesys
Dim Fichier_ini, Fichier_ReadAll
Dim Ligne
Dim Univers_trouve
Dim Dict_trouve

Const FOR_READING = 1

Set Dict_Dict_Feuillets    = CreateObject("Scripting.Dictionary")
Set Dict_univers           = CreateObject("Scripting.Dictionary")
Set Dict_Fonctions_KO      = CreateObject("Scripting.Dictionary")
Set Dict_Datatypes_KO      = CreateObject("Scripting.Dictionary")

Set Filesys = CreateObject("Scripting.FileSystemObject")
'
' Verification de l'existence du fichier ini
'
If  Not filesys.FileExists(Nom_fichier) Then
      call WriteLogFile(1,"  ")
      call WriteLogFile(1,"Le fichier de parametrage '" & Nom_fichier & "' n'est pas trouve")
      call WriteLogFile(1,"  ")
      call WriteLogFile(1,"Arret immediat du script ")
      call WriteLogFile(1,"  ")
      wscript.quit(1)
End If

Set Fichier_ini = filesys.OpenTextFile(Nom_fichier, FOR_READING)
call  WriteLogFile(0," ")
call  WriteLogFile(0,"Debut variables globales")
call  WriteLogFile(0," ")
call  WriteLogFile(0,"Lecture du fichier ini global : " & Nom_fichier)
call  WriteLogFile(0," ")
call  WriteLogFile(0,"Dictionnaire 'Dict_MOTS_CLE'   cree" )
call  WriteLogFile(0,"Dictionnaire 'Dict_univers'    cree" )
call  WriteLogFile(0," ")

Dict_trouve            = False
Univers_trouve         = False
Feuillet_trouve        = False
Fonction_SQL_KO_trouve = False
DATATYPE_SQL_KO_trouve = False

No_univers      = 0
Nb_univers      = 0

Nb_Feuillet     = 0
No_Feuillet     = 0

No_Fonction_SQL_KO = 0
Nb_Fonction_SQL_KO = 0

No_DATATYPE_SQL_KO = 0
Nb_DATATYPE_SQL_KO = 0

Do While Not Fichier_ini.AtEndOfStream
    Ligne = Fichier_ini.ReadLine()
' call  WriteLogFile(0,"Ligne = " & Ligne)

    If Left(Ligne,1) <> "'" Then
        If left(Ligne,1) = "[" Then
            Ligne = Replace(Ligne,"[","")
            Ligne = Replace(Ligne,"]","")

            If Ucase(Left(Trim(Ligne),3)) = "FIN"  Then
                If Univers_trouve Then
                        Univers_trouve = False
                Else
                    If  Feuillet_trouve Then
                          Feuillet_trouve = False
                    Else
                        If  Fonction_SQL_KO_trouve Then
                              Fonction_SQL_KO_trouve = False
                        Else

                            If  DATATYPE_SQL_KO_trouve Then
                                  DATATYPE_SQL_KO_trouve = False
                            Else
                                if Dict_trouve Then
                                    Dict_trouve = False
                                End If
                            End if
                        End if
                    End if
                End if
            Else
                If UCase(Left(trim(Ligne),Len("FEUILLETS"))) = "FEUILLETS" Then
                        Feuillet_trouve   = True
                        Dict_trouve = False
                Else
                    If  UCase(Left(trim(Ligne),Len("UNIVERS"))) = "UNIVERS" Then
                            Univers_trouve = True
                            Dict_trouve     = False
                    Else
                        If  UCase(Left(trim(Ligne),Len("FONCTION_SQL_KO"))) = "FONCTION_SQL_KO" Then
                                Fonction_SQL_KO_trouve = True
                                Dict_trouve     = False
                        Else
                            If  UCase(Left(trim(Ligne),Len("DATATYPE_SQL_KO"))) = "DATATYPE_SQL_KO" Then
                                    DATATYPE_SQL_KO_trouve = True
                                    Dict_trouve     = False
                            Else
                                call  WriteLogFile(0,"Dictionnaire '" & Ligne & "' inconnu" )
                                call  WriteLogFile(0," ")
                                Dict_trouve = True
                            End if
                        End if
                    End if
                End if
            End If
        Else
            If  Len(Trim(Ligne)) > 0 Then
                If  Feuillet_trouve Then
                        No_Feuillet = No_Feuillet + 1
                        Dict_Feuillets.add No_Feuillet,Ligne
                        Dict_Feuillets.add Ligne,Ligne
                        if Mode_debug = "OUI" then
                               call WriteLogFile(3,"Dict_Feuillets.add " & No_Feuillet & "," & Ligne)
                               call WriteLogFile(3,"Dict_Feuillets.add " & Ligne & "," & Ligne)
                        End If
                Else
                    If  Univers_trouve Then
                        No_univers = No_univers + 1
                        Dict_Univers.add No_univers,Ligne
                        if Mode_debug = "OUI" then
                               call WriteLogFile(3,"Dict_univers.add " & No_univers & "," & Ligne)
                        End If

                    Else
                        if Fonction_SQL_KO_trouve then

                            No_Fonction_SQL_KO = No_Fonction_SQL_KO + 1
                            Dict_Fonctions_KO.add No_Fonction_SQL_KO,Ligne

                            if Mode_debug = "OUI" then
                                   call WriteLogFile(3,"Dict_Fonctions_KO.add " & No_Fonction_SQL_KO & "," & Ligne)
                            End If
                        Else

                            if DATATYPE_SQL_KO_trouve then

                                No_DATATYPE_SQL_KO = No_DATATYPE_SQL_KO + 1
                                Dict_Datatypes_KO.add No_DATATYPE_SQL_KO,Ligne

                                if Mode_debug = "OUI" then
                                       call WriteLogFile(3,"Dict_Datatype_KO.add " & No_DATATYPE_SQL_KO & "," & Ligne)
                                End If
                            Else

                                If Not Dict_trouve Then
                                       ExecuteGlobal Ligne
                                       call  WriteLogFile(0,Ligne )
                                end If
                            End if
                        End if
                    End if
                End if
            End if
        End if

    End If

Loop

call  WriteLogFile(0," ")
call  WriteLogFile(0,"Fin variables globales")
call  WriteLogFile(0," ")

Nb_univers_a_traiter  = No_univers
Nb_Feuillets_a_traiter = No_Feuillet
Nb_datatypes_SQL_KO = No_DATATYPE_SQL_KO
Nb_Fonctions_SQL_KO = No_Fonction_SQL_KO

Dict_Fonctions_KO.add 0,No_Fonction_SQL_KO
Dict_Datatypes_KO.add 0,No_DATATYPE_SQL_KO

' wscript.echo "Nb_datatypes_SQL_KO = " & Nb_datatypes_SQL_KO
' wscript.echo "Nb_Fonctions_SQL_KO = " & Nb_Fonctions_SQL_KO

Fichier_ini.Close
Set Fichier_ini = Nothing

End Sub


' **********************************************************************************
' **********************************************************************************
'
' Gestion des variables globales
'
' **********************************************************************************
' **********************************************************************************
'
Function Create_variables_globales()
' -----------------------------------------------------------------------------
'   Création des variables globales & des objets globaux
' -----------------------------------------------------------------------------
Dim g_strScriptPath, g_strScriptName, g_strScriptFolder, i
Dim Jour, Mois, tempdate
Dim Rep_Ini_CR

g_strScriptPath = WScript.ScriptFullName
g_strScriptName = WScript.ScriptName
g_strScriptFolder = g_strScriptPath
g_strScriptDrive = Left(g_strScriptPath,instr(g_strScriptFolder,"\")-1)
g_strScriptFolder = Left(g_strScriptPath,instrrev(g_strScriptFolder,"\")-1)

Rep_vbs = g_strScriptFolder
Rep_ini = g_strScriptFolder & "/Ini"
Rep_reports = g_strScriptFolder & "/Log"

i = InStr(g_strScriptName, ".")
If i <> 0 Then
    g_strScriptNameNoExt = Left(g_strScriptName, i - 1)
Else
    g_strScriptNameNoExt = g_strScriptName
End If

tempdate = now()
Mois = month(Tempdate)
If Mois < 10 Then Mois = "0" & Mois

Jour = day(Tempdate)
If Jour < 10 Then Jour = "0" & Jour

Date_creation = Jour & "/" & Mois & "/" & DatePart("yyyy",tempdate) & " - "

Nom_fichier_INI  = Rep_ini&"\"&g_strScriptNameNoExt&".ini"

wscript.echo "Nom_fichier_INI  = " & Nom_fichier_INI

End Function

' **********************************************************************************
'
' Creation du fichier Log
'
' **********************************************************************************

Function Create_log_file()
'********************************************************************
' Creation du fichier log
'
' Ce Fichier est créé dans le Répertoire pointé par la variable Rep_reports
' Le nom du fichier est :<Nom du script>_Log_mmmdd.yyyy_hh.mm.log
'
'********************************************************************
Dim tempdate, Mois, Jour
Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

' wscript.echo "Debut de Create_log_file"
tempdate = now()
Dim  Nom_table, Nom_table_periode, Nom_index, Nom_index_periode
Dim temp, rc_test, Fichier_report, Type_CCM
'
' Nom abrégé du mois
'
Mois = month(Tempdate)
If Mois < 10 Then Mois = "0" & Mois

Jour = day(Tempdate)
If Jour < 10 Then Jour = "0" & Jour

filenamedate = DatePart ("yyyy",tempdate) & Mois  & Jour & "_"

temp = DatePart ("h",tempdate)
If temp < 10 Then temp = "0" & temp
filenamedate = filenamedate & temp & "."  'hour as hh

temp =  DatePart ("n",tempdate)
If temp < 10 Then temp = "0" & temp
filenamedate = filenamedate & temp        'minutes as mm

Fichier_log = Rep_reports & "\"&g_strScriptNameNoExt  & "_" & filenamedate & ".log"

wscript.echo Fichier_log

Set Fichier_log_obj = FSO.createtextfile(Fichier_log,True)
Fichier_log_obj.Close
Set Fichier_log_obj = FSO.OpenTextFile(Fichier_log,ForAppending,True)

' wscript.echo "Fin  de Create_log_file"
End Function
'
' //////////////////////////////////////////////////////////////////////////////
' |
' | Nom : WriteLogFile
' | Ecriture dans le fichier Log
' |
' //////////////////////////////////////////////////////////////////////////////
'
Function WriteLogFile(iResult, sLogInfo )

    Const ForReading    = 1
    Const ForWriting     = 2
    Const ForAppending = 8
    Dim sLog, fFile

 '   wscript.echo "dans call WriteLogFile"
 '   Wscript.echo Fichier_log
 '   wscript.echo iResult
 '   wscript.echo sLogInfo

    If iResult = 0 Then
        sLog = Date & " - " & Time & " == INFO    = " & sLogInfo
'        wscript.echo sLog
    Elseif iResult = 1 Then
        sLog = Date & " - " & Time & " == ERREUR  = " & sLogInfo
        wscript.echo sLog
    Elseif iResult = 2 Then
        sLog = Date & " - " & Time & " == WARNING = " & sLogInfo
        wscript.echo sLog
    Elseif iResult = 3 Then
        sLog = Date & " - " & Time & " == DEBUG   = " & sLogInfo
    End If
    Fichier_log_obj.writeline sLog
End Function

' **********************************************************************************
'
' RegExReplace
'
' **********************************************************************************

Function RegExReplace(strString,strPattern,strReplace)
On Error Resume Next
    Dim RegEx
    Set RegEx = New RegExp              ' Create regular expression.
    RegEx.IgnoreCase = True             ' Make case insensitive.
    RegEx.Global=True                   'Search the entire String
    RegEx.Pattern=strPattern

    If RegEx.Test(strString) Then       'Test if match is made
        RegExReplace = regEx.Replace(strString, strReplace) ' Make replacement.
     Else
         'return original string
         RegExReplace=strString
    End If
End Function
' **********************************************************************************
'
' RegExReplaceFirst
'
' **********************************************************************************

Function RegExReplaceFirst(strString,strPattern,strReplace)
On Error Resume Next
    Dim RegEx
    Set RegEx = New RegExp              ' Create regular expression.
    RegEx.IgnoreCase = True             ' Make case insensitive.
    RegEx.Global=True                   'Search the entire String
    RegEx.Pattern=strPattern

    If RegEx.Test(strString) Then       'Test if match is made
        RegExReplace = regEx.Replace(strString, strReplace,1) ' Make replacement.
     Else
         'return original string
         RegExReplace=strString
    End If
End Function
' **********************************************************************************
'
' RegExMatch
'
' **********************************************************************************

Function RegExMatch(strString,strPattern)
    Dim RegEx
    RegExMatch=False

    Set RegEx = New RegExp
    RegEx.IgnoreCase = True
    RegEx.Global=True
    RegEx.Pattern=strPattern

    If RegEx.Test(strString) Then RegExMatch=True

End Function

' **********************************************************************************
'
' GetMatch
'
' **********************************************************************************

Function GetMatch(strString,strPattern)
    Dim RegEx,arrMatches
    Set RegEx = New RegExp
    RegEx.IgnoreCase = True
    RegEx.Global=True
    RegEx.Pattern=strPattern
    Set colMatches=RegEx.Execute(strString)
    Set GetMatch=colMatches
End Function

