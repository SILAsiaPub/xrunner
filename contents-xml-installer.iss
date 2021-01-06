; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!
#define scripts "C:\programs\xrunner\scripts"
#define icon "xslt.ico"

[Setup]
OutputBaseFilename=Xrunner-installer
AppName=Xrunner
AppVersion=0.2
DefaultDirName=C:\programs\xrunner
DisableDirPage=true
DefaultGroupName=Publishing
UninstallDisplayIcon={app}\setup\{#icon}
Compression=lzma2
SolidCompression=yes

[Files]
Source: "*.hta"; DestDir: "{app}"
Source: "*.cmd"; DestDir: "{app}"
Source: "setup\*.ico"; DestDir: "{app}\setup"
Source: "setup\*.css"; DestDir: "{app}\setup"
Source: "setup\*.vbs"; DestDir: "{app}\setup"
Source: "setup\*.js"; DestDir: "{app}\setup"
Source: "*.xml"; DestDir: "{app}"
Source: "LICENSE"; DestDir: "{app}"
;Source: "*.md"; DestDir: "{app}"
;Source: "*.txt"; DestDir: "{app}" ; Flags: onlyifdoesntexist;
Source: "scripts\*.xslt"; DestDir: "{#scripts}"
Source: "scripts\*.cct"; DestDir: "{#scripts}"
Source: "setup\*.html"; DestDir: "{app}\setup"
;Source: "setup\*.ini"; DestDir: "{app}\setup"
;Source: "docs\*.md"; DestDir: "{app}\docs"
Source: "docs\*.html"; DestDir: "{app}\docs"
Source: "_Xrunner_Projects\Unit-tests\*.*"; DestDir: "{app}\_Xrunner_Projects\Unit-tests"  ;
Source: "_Xrunner_Projects\Complete_Concordance_Builder\My-Concordance\*.*"; DestDir: "{app}\_Xrunner_Projects\Complete_Concordance_Builder\My-Concordance" ; Flags: recursesubdirs
; Modify-LIFT
Source: "_Xrunner_Projects\Modify-LIFT\*.*"; DestDir: "{app}\_Xrunner_Projects\Modify-LIFT"  ;
Source: "_Xrunner_Projects\Modify-LIFT\scripts\*.*"; DestDir: "{app}\_Xrunner_Projects\Modify-LIFT\scripts"  ;
Source: "_Xrunner_Projects\Modify-LIFT\source\*.txt"; DestDir: "{app}\_Xrunner_Projects\Modify-LIFT\source"  ;
; HymnBook contents menu
Source: "_Xrunner_Projects\Hymn_Menu\*.*"; DestDir: "{app}\_Xrunner_Projects\Hymn_Menu"  ;
Source: "_Xrunner_Projects\Hymn_Menu\scripts\*.*"; DestDir: "{app}\_Xrunner_Projects\Hymn_Menu\scripts"  ;

; tools
;Source: "..\..\..\installer-tools\jre-8u141-windows-x64.exe"; DestDir: "{tmp}"; DestName: "JREInstall.exe"; Check: IsWin64 AND InstallJava(); Flags: deleteafterinstall
;Source: "..\..\..\installer-tools\jre-8u66-windows-i586.exe"; DestDir: "{tmp}"; DestName: "JREInstall.exe"; Check: (NOT IsWin64) AND InstallJava(); Flags: deleteafterinstall
Source: "..\..\..\installer-tools\UNZIP.EXE"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{tmp}\UNZIP.EXE');
Source: "..\..\..\installer-tools\SaxonHE9-8-0-3J.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{app}\tools\saxon\saxon9he.jar');
Source: "..\..\..\installer-tools\cc8_1_6.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{app}\tools\ccw32.exe');
Source: "tools\bin\*"; DestDir: "{app}\tools\bin"; 

;Source: "..\..\..\installer-tools\amazon-corretto-8.222.10.3-windows-x64-jre.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{app}\tools\java\java.exe');

[Icons]
Name: "{group}\Xrunner"; Filename: "{app}\xrunner.hta"; IconFilename: "{app}\setup\{#icon}"
;Name: "{group}\Xrun func documentation"; Filename: "{app}\docs\xrun-docs.md.html"; IconFilename: "{app}\setup\{#icon}"
Name: "{group}\Uninstallers\Xrunner Uninstall"; Filename: "{uninstallexe}" 

 [Run]
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\SaxonHE9-8-0-3J.zip -d {app}\saxon";  Check: FileDoesNotExist('C:\programs\xrunner\tools\saxon\saxon9he.jar');
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\cc8_1_6.zip -d '{app}\tools'";  Check: FileDoesNotExist('{app}\tools');
;Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\amazon-corretto-8.222.10.3-windows-x64-jre.zip -d '{app}\tools\java'";  Check: FileDoesNotExist('{app}\tools\java\java.exe');
;Filename: "{tmp}\JREInstall.exe"; Parameters: "/s"; Flags: nowait postinstall runhidden runascurrentuser; Check: InstallJava() ;

[Dirs]
Name: "{app}\_Xrunner_Projects\Demos"
Name: "{app}\_Xrunner_Projects\Modify-LIFT"
Name: "{app}\docs"

[INI]
;The following line is different to how it is tested on the computer
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "projecthome"; String: "C:\programs\xrunner\_xrunner_projects"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "taskgroup_list"; String: "a b c d e f g h i j k l m n o p q r s t u v w x y z"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "button-or-label_list"; String: "button label"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "nonunique_list"; String: "t xt ut button label com"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "unittestlabel_list"; String: "ut utt"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "tasklabel_list"; String: "t"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "batchsection_list"; String: "variables var project proj"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "xsltsection_list"; String: "variables xvar"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "includesection_list"; String: "include inc"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "guisection_list"; String: "gui"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "reservedsection_list"; String: "variables var project proj include inc gui"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "includelabel_list"; String: "i"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "true_list"; String: "true yes on 1"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "commentlabel"; String: "com"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "needsaxon"; String: "true"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "detectjava"; String: ""; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "setup-type"; String: "java"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "java"; String: "java"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "iconv"; String: "tools\bin\iconv.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "uniq"; String: "tools\bin\uniq.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "UnicodeCCount"; String: "tools\bin\UnicodeCCount.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "file"; String: "tools\bin\file.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "ccw32"; String: "C:\programs\xrunner\tools\Ccw32.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "saxon"; String: "C:\programs\xrunner\tools\saxon\saxon9he.jar"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "zip"; String: "C:\Program Files\7-Zip\7z.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "editor"; String: "notepad"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "foxe"; String: "C:\Program Files (x86)\firstobject\foxe.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "prince"; String: "C:\Program Files (x86)\Prince\engine\bin\prince.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "rdwrtp8"; String: "C:\Program Files (x86)\Paratext 8\rdwrtp8.exe"; Flags: createkeyifdoesntexist




[Code]
function FileDoesNotExist(file: string): Boolean;
begin
  if (FileExists(ExpandConstant(file))) then
    begin
      Result := False;
    end
  else
    begin
      Result := True;
    end;
end;


procedure DecodeVersion(verstr: String; var verint: array of Integer);
var
  i,p: Integer; s: string;
begin
  { initialize array }
  verint := [0,0,0,0];
  i := 0;
  while ((Length(verstr) > 0) and (i < 4)) do
  begin
    p := pos ('.', verstr);
    if p > 0 then
    begin
      if p = 1 then s:= '0' else s:= Copy (verstr, 1, p - 1);
      verint[i] := StrToInt(s);
      i := i + 1;
      verstr := Copy (verstr, p+1, Length(verstr));
    end
    else
    begin
      verint[i] := StrToInt (verstr);
      verstr := '';
    end;
  end;
end;


function CompareVersion (ver1, ver2: String) : Integer;
var
  verint1, verint2: array of Integer;
  i: integer;
begin
  SetArrayLength (verint1, 4);
  DecodeVersion (ver1, verint1);

  SetArrayLength (verint2, 4);
  DecodeVersion (ver2, verint2);

  Result := 0; i := 0;
  while ((Result = 0) and ( i < 4 )) do
  begin
    if verint1[i] > verint2[i] then
      Result := 1
    else
      if verint1[i] < verint2[i] then
        Result := -1
      else
        Result := 0;
    i := i + 1;
  end;
end;

function InstallJava() : Boolean;
var
  JVer: String;
  InstallJ: Boolean;
begin
  RegQueryStringValue(
    HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JVer);
  InstallJ := true;
  if Length( JVer ) > 0 then
  begin
    if CompareVersion(JVer, '1.8') >= 0 then
    begin
      InstallJ := false;
    end;
  end;
  Result := InstallJ;
end;