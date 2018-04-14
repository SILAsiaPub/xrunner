:: Description: xrun
:: Usage: xrun C:\path\project.txt [group]
:: Note: Xrun requires a project file. The group parameter is normally a letter a-t but can be nothing. If noting all groups are run.
 @echo off
rem
echo %0 %1 %2
setlocal enabledelayedexpansion

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
set projectfile=%1
set projectpath=%~dp1
set projectpath=%projectpath:~0,-1%
set group=%2
call :setup
for %%g in (%taskgroup%) do (
  if defined group (
      if "%group%" == "%%g" call :taskgroup %%g
    ) else (
      call :taskgroup %%g 
    )
  )
if defined pauseatend pause
goto :eof

:taskgroup
:: Description: Loop that triggers each task in the group.
:: Usage: call :taskgroup group
set group=%~1
set taskend=!task%~1count!
FOR /L %%c IN (1,1,%taskend%) DO call :task %%c
goto :eof

:task
:: Description: This tests various variables and starts the task if appropriate.
:: Usage: call :task task
:: Note: The task variable is an interger number, in the range 1-20 but can be set higher.
  if defined skiptasks goto :eof
  set task=!task%group%%~1!
  set task=%task%
  set first=%task:~0,1%
  if defined task%group%%~1 (
    if "%first%" == ":" (
      call !task%group%%~1!
    ) else (
      !task%group%%~1!
    )
  )
goto :eof


:variableslist
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist list
  set list=%~1
  FOR /F "eol=[ delims=; tokens=1,2" %%s IN (%list%) DO set %%s
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
set /A count=0
call :variableslist "%cd%\setup\xrun.ini"
  call :variableslist "%projectfile%"
  if not exist "%ProgramFiles%\java" (
    echo is java installed? 
    pause 
    exit
    )
if not exist "%saxon%" (
  echo Panic! Saxon9he.jar not found. 
  echo This program will exit now! 
  Pause 
  exit
  )
  call :xslt variable2xslt.xslt blank.xml %scripts%\project.xslt "projectpath='%projectpath%'"
goto :eof


:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
  call :inccount %count%
  set script=%scripts%\%~1
  call :infile "%~2"
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  set params=%~4
  if defined params set params=%params:'="%
  if defined params set params=%params:::==%
    )
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"
  if exist "%outfile%" del "%outfile%"
  echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  @if not exist "%outfile%" echo Outfile not found: %outfile%
  @if not exist "%outfile%" set skiptasks=on
  @if not exist "%outfile%" pause
goto :eof

:cct                                               
  :: Description: Privides interface to CCW32.
  :: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
  call :inccount %count%
  set script=%scripts%\%~1
  if not defined script echo CCT missing! & goto :eof
  call :infile "%~2"
  if defined missinginput echo missing input file & goto :eof
  set cctparam=-u -b -q -n
  if not exist "%ccw32%" echo missing ccw32.exe file & goto :eof
  set scriptout=%script:.cct,=_%
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml"
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"
  if exist "%outfile%" del "%outfile%"
  set curcommand="%ccw32%" %cctparam% -t "%script%" -o "%outfile%" "%infile%"
  echo %curcommand%
  call %curcommand%
  @if not exist "%outfile%" echo Outfile not found: %outfile%
  @if not exist "%outfile%" set skiptasks=on
  @if not exist "%outfile%" pause
goto :eof

:infile
  :: Description: If infile is specifically set then uses that else uses previous outfile.
  :: Usage: call :infile "%file%"
  set infile=%~1
  if not defined infile (
    set infile=%outfile%
  )
  if exist "%infile%" (
    set missinginput=
  ) else (
    set missinginput=on
  )
goto :eof

:outfile
  :: Description: If out file is specifically set then uses that else uses supplied name.
  :: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml"
  set testoutfile=%~1
  set defaultoutfile=%~2
  set nocheck=%~3
  if "%testoutfile%" == "" (
  set outfile=%defaultoutfile%
  ) else (
  set outfile=%testoutfile%
  )
  if not defined nocheck call :checkdir "%outfile%"
goto :eof

:drivepath
  :: Description: returns the drive and path from a full drive:\path\filename
  :: Usage: call :drivepath C:\path\name.ext|path\name.ext
  set drivepath=%~dp1
goto :eof

:checkdir
  :: Description: checks if dir exists if not it is created
  :: Usage: call :checkdir C:\path\name.ext
  set dir=%~dp1
  if not defined dir echo missing required directory parameter & goto :eof
  set report=Checking dir %dir%
  if exist "%dir%" (
       rem echo ::. . . Found! %dir%
       echo.
  ) else (
      echo Creating . . . %dirout%
      mkdir "%dir%"
  )
goto :eof

:inccount
:: Description: iIncrements the count variable
  set /A count=%count%+1
  set writecount=%count%
  if %count% lss 10 set writecount=%space%%count%
goto :eof

:var
set %~1=%~2
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext
call :inccount
set infile=%outfile%
set outfile=%~1
call :checkdir "%outfile%"
copy /Y "%infile%" "%outfile%"
echo File created: %~nx1 in folder: %~dp1
goto :eof

:command
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run  command in"   "output file to test for"]
:: Note: Single quotes get converted to double quotes before the command is used.
call :inccount
set curcommand=%~1
set commandpath=%~2
set outfile=%~3
set outfile=%outfile%
set basepath=%cd%
if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"
if exist "%outfile%" del "%outfile%"
if not defined curcommand (
  echo missing curcommand 
  goto :eof
)
set curcommand=%curcommand:'="%
if defined commandpath (
  if not exist "%commandpath%" mkdir "%commandpath%"
)
if defined commandpath cd /D "%commandpath%"
if defined commandpath echo current path: %cd%
echo %curcommand%
call %curcommand%
if defined commandpath cd /D "%basepath%"
if defined outfile (
  if not exist "%outfile%" echo File not created: %outfile%
  @if not exist "%outfile%" set skiptasks=on
  if not exist "%outfile%" pause
  )
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Usage: call :command2file "command" "outfile" ["commandpath"]
:: Depends on: inccount, outfile
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
call :inccount
set command=%~1
set out=%~2
if not defined command echo missing command & goto :eof
call :outfile "%out%" "%projectpath%\xml\%group%-%count%-%~1-command2file.xml"
if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"
if exist "%outfile%" del "%outfile%"
set commandpath=%~3
set append=%~4
rem the following is used for the feed back but not for the actual command
set curcommand=%command:'="%
if defined commandpath (
  set basepath=%cd%
  cd /d "%commandpath%"
)
if not defined append (
  echo %curcommand% ^>  "%outfile%"
  call %curcommand% > "%outfile%"
) else (
  echo %curcommand% ^>^>  "%outfile%"
  call %curcommand% >> "%outfile%"
)
if defined commandpath (
  cd /D "%basepath%"
)
if defined outfile (
  if not exist "%outfile%" echo File not created: %outfile%
  @if not exist "%outfile%" set skiptasks=on
  if not exist "%outfile%" pause
  )
goto :eof


:command2var
:: Description: creates a variable from the command line
:: Usage: call :command2var varname "command" "comment"
set commandline=%~1
set varname=%~2
set invalid=%~3
set comment=%~4
if not defined varname echo missing varname parameter & goto :eof
if not defined commandline echo missing list parameter & goto :eof
set commandline=%commandline:'="%
if defined comment echo %comment%
FOR /F %%s IN ('%commandline%') DO set %varname%=%%s
set varname=
set commandline=
set comment=
if "%varname%" == "%invalid%" echo invalid & set skip=on
goto :eof

:inputfile
:: Description: Sets the starting file of a serial tasklist, by assigning it to the var outfile
:: usage: call :inputfile "drive:\path\file.ext"
set outfile=%~1
if not defined outfile echo missing outfile parameter & goto :eof
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles "action" "file specs" ["comment" ]
set action=%~1
set filespec=%~2
set comment=%~3
if not defined action echo Missing action parameter & goto :eof
if not defined filespec echo Missing filespec parameter & goto :eof
set action=%action:'="%
if defined comment echo %comment%
FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO call :%action% "%%s"
goto :eof

:start
:: Description: Start a program but don't wait for it.
  call :var p1 %~1
  call :var p2 %~2
  set p3=%~3
  set p4=%~4
  echo.
  echo start "%p1%" "%p2%" "%p3%" "%p4%"
  start "%p1%" "%p2%" "%p3%" "%p4%"
goto :eof

