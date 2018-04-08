    If len(ReadIni(projectTxt,"tasks","labela")) > 0 Then
        document.getElementById("buttona").InnerText = ReadIni(projectTxt,"tasks","labela")
    End If
    If len(ReadIni(projectTxt,"tasks","labelb")) > 0 Then
        document.getElementById("buttonb").InnerText = ReadIni(projectTxt,"tasks","labelb")
    End If
    usea = ReadIni(projectTxt,"tasks","labela")
    useb = ReadIni(projectTxt,"tasks","labelb")
    'set usec = ReadIni(projectTxt,,"taskc1")
    'set used = ReadIni(projectTxt,"","taskd1")
    'set usee = ReadIni(projectTxt,"","taske1")
    'set usef = ReadIni(projectTxt,"","taskf1")
    
    document.getElementById("buttonb").InnerText = ReadIni(projectTxt,"tasks","labelb")
    
    
sub initialize
  CurrentFolder.value = CreateObject("Wscript.Shell").CurrentDirectory
  Cmd.focus
end sub

Function CmdPrompt(sCmd)
  Dim alines, sCmdLine, stemp, ofs, oWS, nRes
  'On Error Resume Next
  sCmdLine = """%comspec%"" /c " & sCmd & " 1>> "
  set ofs = CreateObject("Scripting.FileSystemObject")
  stemp = ofs.GetTempName
  set oWS = CreateObject("Wscript.Shell")
  stemp = oWS.Environment("PROCESS")("TEMP") & "\" & stemp
  nRes = oWS.Run(sCmdLine & Chr(34) & sTemp & Chr(34) _
       , Abs(cSng(bConsoleSw)), True)
  alines = "ERRORLEVEL: " & nRes & vbCRLF
  if ofs.FileExists(sTemp) Then
    with ofs.OpenTextFile(stemp)
      if Not .AtEndofStream Then
        alines = aLines & .ReadAll
      End if
    End With
    ofs.DeleteFile stemp
    alines = Split(aLines, vbNewline)
  Else
    aLines = Array(nRes, "")
  End if
  ReDim Preserve alines(Ubound(alines) - 1)
  if Err.Number <> 0 Then _
    aLines = Array("Error Number:" & CStr(Err.Number), Err.Description) 
    CmdPrompt = alines
End Function

sub checkEnter
  With window.event
    if .keycode = 13 then
      runMS_DOS
    Else
      .cancelbubble = false
      .returnvalue = true
    End if
  End With
End sub

Sub ChDir
  Set oSHL = CreateObject("Shell.Application")
    On Error Resume Next
    Set oFolder = oSHL.BrowseForFolder(&H0,"Select Working Folder",&H11,&H11)
    If Err.Number = 0 Then
      CurrentFolder.value = oFolder.Self.Path
      Cmd.focus
    End if
End Sub

sub Copy
  document.ParentWindow.ClipboardData.SetData "text", Results.innerText
end sub

  Sub runMS_DOS
    'On Error Resume Next
    CreateObject("Wscript.Shell").CurrentDirectory = CurrentFolder.value
    if Err.Number <> 0 Then
      aLines = Array("Error Number:" & Hex(Err.Number), Err.Description)
    Else
      Results.innerhtml = "</b> Working ...</b>"
      aLines = CmdPrompt(Cmd.Value)
    End if
    Results.innerhtml = "<xmp>" & Join(aLines, vbCRLF) & "</xmp>"
  End Sub
  
        <iframe src="" width="750" height="260" frameborder="2" id="projecttxt"></iframe>
      <div class="floatright"><button onclick="editFile(projectTxt)" name="LoadValues" class="inibutton">Edit variables and tasks</button></div>