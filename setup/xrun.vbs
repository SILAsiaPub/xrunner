' VB Script Document
Option Explicit

'         <!--define variables-->
Dim strPath, dquote, WScript, shell, objShell, cmdline, projIni, labelIni, strUserProfile, projPath, projectTxt 
Dim xrunini, xrundata, zero, tskgrp, texteditor, bConsoleSw 
tskgrp =  Array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t" )
zero = 0
zero = CInt(zero)
xrundata = "setup\"
xrunini = "setup\xrun.ini"
projPath =  ReadIni(xrunini,"setup","projecthome")
texteditor =  ReadIni(xrunini,"setup","editor")
'         <!--set some values-->
projIni = "blank.txt"

Set objShell = CreateObject("Wscript.Shell")
dquote = chr(34)
strUserProfile = objShell.ExpandEnvironmentStrings( "%userprofile%" )

Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    ' Returns:
    ' the [string] value for the specified key in the specified section
    ' CAVEAT:     Will return a space if key exists but value is blank
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude
    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8
    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection
    Set objFSO = CreateObject( "Scripting.FileSystemObject" )
    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )
    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )
            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )
                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If
                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do
                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        Msgbox strFilePath & " doesn't exists. Exiting..."
    End If
End Function

Function SelectFolder( myStartFolder )
' This function opens a "Select Folder" dialog and will
' return the fully qualified path of the selected folder
' Argument:
'     myStartFolder    [string]    the root folder where you can start browsing;
'                                  if an empty string is used, browsing starts
'                                  on the local computer
' Returns:
' A string containing the fully qualified path of the selected folder
' Written by Rob van der Woude
' http://www.robvanderwoude.com
    ' Standard housekeeping
    Dim objFolder, objItem, objShell, usea, useb
    
    ' Custom error handling
    On Error Resume Next
    SelectFolder = vbNull
    ' Create a dialog object
    Set objShell  = CreateObject( "Shell.Application" )
    Set objFolder = objShell.BrowseForFolder( 0, "Select Folder", 0, myStartFolder )
    ' Return the path of the selected folder
    If IsObject( objfolder ) Then SelectFolder = objFolder.Self.Path
    ShowSelectedFolder.Value = SelectFolder
    projectTxt = SelectFolder & "\project.txt"
    projectInfo = SelectFolder & "\project-info.txt"
    buttonSet(tskgrp(0))
    buttonSet(tskgrp(1))
    buttonSet(tskgrp(2))
    buttonSet(tskgrp(3))
    buttonSet(tskgrp(4))
    buttonSet(tskgrp(5))
    buttonSet(tskgrp(6))
    buttonSet(tskgrp(7))
    buttonSet(tskgrp(8))
    buttonSet(tskgrp(9))
    buttonSet(tskgrp(10))
    buttonSet(tskgrp(11))
    buttonSet(tskgrp(12))
    buttonSet(tskgrp(13))
    buttonSet(tskgrp(14))
    buttonSet(tskgrp(15))
    buttonSet(tskgrp(16))
    buttonSet(tskgrp(17))
    buttonSet(tskgrp(18))
    buttonSet(tskgrp(19))
    Document.getElementById("title").InnerText = ReadIni(projectTxt,"variables","title")
    editProject()
    document.getElementById("projecttxt").src = projectTxt
    ' Standard housekeeping
    Set objFolder = Nothing
    Set objshell  = Nothing
    On Error Goto 0
End Function

Function RunCmd( bat, param )
    'writeProjIni projIni,"variables",styleout
    cmdline = """%comspec%"" /c " & "cmd.exe /c " & bat & " " & param
    objShell.run(cmdline)
End Function

Sub RunScript(groupa)
    'writeProjIni projIni,"variables",styleout
    cmdline = "xrun.cmd " & projectTxt & " " & groupa
    objShell.run(cmdline)
    'CmdPrompt(cmdline)
End Sub

Sub editfile(file)
    cmdline = texteditor & " " & file
    objShell.run(cmdline)
End Sub

Sub buttonSet(group)
    If len(ReadIni(projectTxt,"tasks","task" & group & "1")) > zero Then
        document.getElementById("button" & group).style.display = "block"
        If len(ReadIni(projectTxt,"tasks","label" & group)) > zero Then
            document.getElementById("button" & group).InnerText = ReadIni(projectTxt,"tasks","label" & group)
        End If
    End If
End Sub

Function OpenTab(tabid)
    Dim tab, x, Elem, Elemon, Elemtab , Elemtc, ifrm, tabname, tabactive
    tab = Array("project","projectinfo","Xrunnerinfo","expert")
    tabactive = tabid & "tab"
    For x = 0 To Ubound(tab)
      tabname = tab(x) & "tab"
      document.getElementById(tab(x)).style.display = "none"
      document.getElementById(tabname).style.background = "#f1f1f1"
    Next
    document.getElementById(tabid).style.display = "block"
    document.getElementById(tabactive).style.background = "#ccc"
End Function

'Const csFSpec = "E:\trials\SoTrials\answers\8841045\hta\29505115.txt"
Dim goFS : Set goFS = CreateObject("Scripting.FileSystemObject")

Sub editProject()
  If goFS.FileExists(projectTxt) Then
     document.all.DataArea.value = goFS.OpenTextFile(projectTxt).ReadAll()
  Else
     document.all.DataArea.value = projectTxt & " created"
  End If
End Sub

Sub SaveProject()
  goFS.CreateTextFile(projectTxt).Write document.all.DataArea.value
End Sub