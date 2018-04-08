; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!
#define scripts "C:\programs\xrunner\scripts"
#define icon "xslt.ico"

[Setup]
OutputBaseFilename=Xrunner-installer
AppName=Xrunner
AppVersion=0.1
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
Source: "setup\*.ini"; DestDir: "{app}\setup"
Source: "D:\All-SIL-Publishing\installer-tools\jre-8u141-windows-x64.exe"; DestDir: "{tmp}"; DestName: "JREInstall.exe"; Check: IsWin64 AND InstallJava(); Flags: deleteafterinstall
;Source: "D:\All-SIL-Publishing\installer-tools\jre-8u66-windows-i586.exe"; DestDir: "{tmp}"; DestName: "JREInstall.exe"; Check: (NOT IsWin64) AND InstallJava(); Flags: deleteafterinstall
Source: "D:\All-SIL-Publishing\installer-tools\UNZIP.EXE"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{tmp}\UNZIP.EXE');
Source: "D:\All-SIL-Publishing\installer-tools\SaxonHE9-8-0-3J.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('C:\programs\saxon\saxon9he.jar');
Source: "D:\All-SIL-Publishing\installer-tools\cc8_1_6.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('C:\Program Files (x86)\SIL\cc\ccw32.exe');

[Icons]
Name: "{group}\Xrunner"; Filename: "{app}\xrunner.hta"; IconFilename: "{app}\setup\{#icon}"
Name: "{group}\Uninstallers\Xrunner Uninstall"; Filename: "{uninstallexe}" 

 [Run]
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\SaxonHE9-8-0-3J.zip -d {app}\saxon";  Check: FileDoesNotExist('C:\programs\saxon\saxon9he.jar');
Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\cc8_1_6.zip -d 'C:\Program Files (x86)\SIL\cc'";  Check: FileDoesNotExist('C:\Program Files (x86)\SIL\cc');
Filename: "{tmp}\JREInstall.exe"; Parameters: "/s"; Flags: nowait postinstall runhidden runascurrentuser; Check: InstallJava() ;

[Dirs]
Name: "{app}\_Xrunner_Projects\Demos"

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