:: Description: xrun
:: Usage: xrun C:\path\project.txt [group] [infolevel] [pauseatend]
:: Note: Xrun requires a project file. The group parameter is normally a letter a-t but can be nothing. If nothing all groups are run.
 @echo off
rem
set projectfile=%1 
if not exist "%projectfile%" (
  rem This is to ensure there is a parameter for the project.txt file.
  echo A valid project file must be provided. It is a required parameter.
  echo This script will exit.
  goto :eof
)
set projectpath=%~dp1
set projectpath=%projectpath:~0,-1%
set group=%2
set infolevel=%3
set Pauseatend=%4
if not defined infolevel set infolevel=0
call :setinfolevel %infolevel%
if defined %funcstart%%utgroup% echo Cmd: %0 "%1" %2 %3 %4 %5 
setlocal enabledelayedexpansion
goto :main


:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Depends on: setup, taskgroup
  if defined funccore echo %funcstarttext% %0
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
:: Requires: task
  if defined funccore echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set group=%~1
set taskend=!task%~1count!
FOR /L %%c IN (1,1,%taskend%) DO call :task %%c
  if defined info4 echo %funcendtext% %0
goto :eof

:task
:: Description: This tests various variables and starts the task if appropriate.
:: Usage: call :task task
:: Note: The task variable is an interger number, in the range 1-20 but can be set higher.
:: Depends on: 
  if not defined task%group%%~1 goto :eof
  if defined funccore echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcendtext% %0
goto :eof


:variableslist
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist list
  if defined funccore echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set list=%~1
  FOR /F "eol=[ delims=; tokens=1,2" %%s IN (%list%) DO (
    set data=%%s
    if defined data set %%s
    )
  if defined info4 echo %funcendtext% %0
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Depends on: variableslist, xslt
  if defined funccore echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=0
  call :variableslist "%cd%\setup\xrun.ini"
  for %%l in (%taskgroup%) do set task%%lcount=%defaulttaskcount%
  set maxsubcount=%defaulttaskcount%
  call :variableslist "%projectfile%"
  call :setinfolevel %infolevel%
  if not defined noxslt (
    rem this is run unless xslt (including Java and Saxon) is not needed
    if not exist "%ProgramFiles%\java" (
        echo Error: is java installed? 
      pause 
      exit
      )
    if not exist "%saxon%" (
    echo Panic! Saxon9he.jar not found. 
    echo This program will exit now! 
        pause 
    exit
    )
    call :xslt variable2xslt.xslt blank.xml scripts\project.xslt "projectpath='%projectpath%'"
    if exist "scripts\project.xslt" move /Y "scripts\project.xslt" "%scripts%"
  )
  if defined info4 echo %funcendtext% %0
goto :eof


:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount %count%
  set script=%scripts%\%~1
  call :infile "%~2"
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  if not exist "%script%" echo Error: missing script file & goto :eof
  set params=%~4
  if defined params set params=%params:'="%
  if defined params set params=%params:::==%
    )
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev" >> log.txt
  if exist "%outfile%" del "%outfile%"
  if defined info3 echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  call :funcend %0
goto :eof

:cct                                               
  :: Description: Privides interface to CCW32.
  :: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
:: Depends on: inccount, infile, outfile
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount %count%
  set script=%scripts%\%~1
  if not defined script echo CCT missing! & goto :eof
  call :infile "%~2"
  if not exist "%script%" echo Error: missing script file & goto :eof
  set cctparam=-u -b -q -n
  if not exist "%ccw32%" echo missing ccw32.exe file & goto :eof
  set scriptout=%script:.cct,=_%
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml"
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"  >> log.txt
  if exist "%outfile%" del "%outfile%"
  set curcommand="%ccw32%" %cctparam% -t "%script%" -o "%outfile%" "%infile%"
  if defined info3 echo %curcommand%
  call %curcommand%
  call :funcend %0
goto :eof

:infile
  :: Description: If infile is specifically set then uses that else uses previous outfile.
  :: Usage: call :infile "%file%"
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set infile=%~1
  if not defined infile set infile=%outfile%
  if exist "%infile%" (
    set missinginput=
  ) else (
    set missinginput=on
    echo Error: missing input file to :infile
  )
  if defined info4 echo %funcendtext% %0
goto :eof

:outfile
  :: Description: If out file is specifically set then uses that else uses supplied name.
  :: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml"
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set testoutfile=%~1
  set testoutdp=%~dp1
  set testoutnx=%~nx1
  if defined info1 set testoutfile
  rem call :v2 testoutfile "!testoutfile!"
  set defaultoutfile=%~2
  set defaultoutdp=%~dp2
  set defaultoutnx=%~nx2
  if defined info1 set defaultoutfile
  set nocheck=%~3
  if not defined testoutfile (
    rem this is to resolve var form project file
    call :v2 outfile %defaultoutfile%
    set outdp=%defaultoutpath%
    set outnx=%defaultoutdp%
  ) else (
    rem this is to resolve var form project file
    call :v2 outfile "%testoutfile%"
    set outdp=%testoutdp
    set outnx=%testoutnx%
  )
  if not defined nocheck call :checkdir "%outfile%"
  set utreturn=%outfile%
  set utreturn2=%outdp%
  set utreturn3=%outnx%
  if defined info4 echo %funcendtext% %0
goto :eof

:drivepath
  :: Description: returns the drive and path from a full drive:\path\filename
  :: Usage: call :drivepath C:\path\name.ext|path\name.ext
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set utdp=%~dp1
  set drivepath=%utdp:~0,-1%
  set utreturn=%drivepath%
  if defined info4 echo %funcendtext% %0
goto :eof

:checkdir
  :: Description: checks if dir exists if not it is created
  :: Usage: call :checkdir C:\path\name.ext
  if defined %funcstarttest0% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  rem Note to resolve var from project.txt use !var! form for !projectpath!
  call :v2 checkpath "%~1"
  set ext=%~x1
  if defined ext set checkpath=%~dp1
  if defined ext (
    set testpath=%checkpath:~0,-1%
   ) else if "%checkpath:~0,-1%" == "\" (
    set testpath=%checkpath:~0,-1%
  ) else (
    set testpath=%checkpath%
  )  
  if defined info2 set checkpath
  if defined info1 set testpath
  if not defined testpath echo missing required directory parameter & goto :eof
  if exist "%testpath%" (
       rem echo ::. . . Found! %testpath%
       echo.
  ) else (
      if defined info1 echo Creating . . . %testpath%
      mkdir "%testpath%"
  )
  set utreturn=%testpath%
  if defined info4 echo %funcendtext% %0
goto :eof

:inccount
:: Description: iIncrements the count variable
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=%count%+1
  set writecount=%count%
  if %count% lss 10 set writecount=%space%%count%
  if defined info4 echo %funcendtext% %0
goto :eof

:var
  if defined %funcstarttest0% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set value=%~2
  call :v2 retval "%value%"
  set %~1=%retval%
  set utreturn=%retval%
  if defined info4 echo %funcendtext% %0
goto :eof

:v2
  if defined %funcstarttest0% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set value=%~2
  set %~1=%value%
  set utreturn=%value%
  if defined info4 echo %funcendtext% %0
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext
  if defined %funcstarttest0% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
call :inccount
set infile=%outfile%
  call :var infile "%infile%"
set outfile=%~1
call :checkdir "%outfile%"
  move /Y "%infile%" "%outfile%" >> log.txt
  @ if exist "%outfile%" echo File created: %~nx1 in folder: %~dp1
  if defined info4 echo %funcendtext% %0
goto :eof

:command
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run  command in"   "output file to test for"]
:: Note: Single quotes get converted to double quotes before the command is used.
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info3 echo %curcommand%
call %curcommand%
if defined commandpath cd /D "%basepath%"
  @if defined info4 call :funcend %0
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Usage: call :command2file "command" "outfile" ["commandpath"]
:: Depends on: inccount, outfile
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
    if defined info3 echo %curcommand% ^>  "%outfile%"
  call %curcommand% > "%outfile%"
) else (
    if defined info3 echo %curcommand% ^>^>  "%outfile%"
  call %curcommand% >> "%outfile%"
)
if defined commandpath (
  cd /D "%basepath%"
)
  @if defined info4 call :funcend %0
goto :eof


:command2var
:: Description: creates a variable from the command line
:: Usage: call :command2var varname "command" "comment"
  if defined %funcstarttest0% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set commandline=%~1
set varname=%~2
set invalid=%~3
set comment=%~4
if not defined varname echo missing varname parameter & goto :eof
if not defined commandline echo missing list parameter & goto :eof
set commandline=%commandline:'="%
if defined comment echo %comment%
  FOR /F "delims=#" %%s IN ('%commandline%') DO set %varname%=%%s & set utreturn=%%s
set commandline=
set comment=
  if defined info4 echo %funcendtext% %0
goto :eof

:inputfile
:: Description: Sets the starting file of a serial tasklist, by assigning it to the var outfile
:: usage: call :inputfile "drive:\path\file.ext"
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set outfile=%~1
  if not defined outfile echo Missing param1  & set skip=on
  if defined info4 echo %funcendtext% %0
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles "action" "file specs" ["comment" ]
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set action=%~1
set filespec=%~2
set comment=%~3
if not defined action echo Missing action parameter & goto :eof
if not defined filespec echo Missing filespec parameter & goto :eof
set action=%action:'="%
  if defined info3 if defined comment echo %comment%
  set firstlet=%action:~0,1%
  FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO (
    call :%action% "%%s"
    If "%firstlet%" == ":" (
      call %action% %%s
    ) else (
      %action% %%s
    )

  )
  if defined info4 echo %funcendtext% %0
goto :eof

:loopstring
:: Description: Loops through a list supplied in a string.
:: Usage: call :loopstring action "string" ["comment"]
:: Note: action may have multiple parts
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set action=%~1
  set string=%~2
  set comment=%~3
  if not defined action echo Missing action parameter & goto :eof
  if not defined string echo Missing string parameter & goto :eof
  set action=%action:'="%
  if defined info3 if defined comment echo %comment%
  set firstlet=%action:~0,1%
  FOR %%s IN (%string%) DO (
    echo   :loopstring param %%s
    call :%action% %%s
    If "%firstlet%" == ":" (
        call %action% %%s
      ) else (
        %action% %%s
      )
    )
  if defined info4 echo %funcendtext% %0
goto :eof

:start
:: Description: Start a program but don't wait for it.
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :var p1 %~1
  call :var p2 %~2
  set p3=%~3
  set p4=%~4
  echo.
  echo start "%p1%" "%p2%" "%p3%" "%p4%"
  start "%p1%" "%p2%" "%p3%" "%p4%"
  if defined info4 echo %funcendtext% %0
goto :eof

:test
:: Description: Used for unit testing
:: Usage: call :test val1 val2 report
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set val1=%~1
  set val2=%~2
  set val3=%~3
  set val4=%~4
  set val5=%~5
  set val6=%~6
  set val7=%~7
  if defined val7 (
  call %val1% "%val3%" "%val4%" "%val5%"  "%val6%"
  ) else (
    if defined val6 (
    call %val1% "%val3%" "%val4%" "%val5%" 
    ) else (
      if defined val5 (
      call %val1% "%val3%" "%val4%"
      ) else (
      call %val1% "%val3%"
      )
    )
  )
  set /A tcount+=1
  echo test input1: %val3%
  if defined val5 echo test input2: %val4%
  if defined val6 echo test input3: %val5%
  if defined val7 echo test input4: %val6%
  echo test output: %utreturn%
  echo    expected: %val2%
  @if "%val2%" == "%utreturn%" set t=passed
  @if "%val2%" neq "%utreturn%" set t=failed
  if "%t%" == "failed" color 06
  set reporta=%t%    %val1% test %tcount% 
  if defined val7 (
    echo %reporta% %val7%
    ) else (
    if defined val6 (
      echo %reporta% %val6%
    ) else (
      if defined val5 (
      echo %reporta% %val5%
      ) else (
      echo %reporta% %va4%
      )
    )
  )
  @echo.
  set val3=
  set val4=
  set val5=
  if defined info4 echo %funcendtext% %0
goto :eof

:sub
:: Description: Starts a sub loop
:: Usage: call :sub "subname" "['param1' ['param2' ['param3' ['param4']]]]"
  if defined %funcstart%%utgroup% echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set subname=%~1
  Set PAR2=%~2
  If not defined par1 echo Missing param1. Exit function! & goto :eof
  Set PARAM=%par2:'="%
  set FIRSTLET=%par1:~0,1%
  If defined info2 echo %param%
  For %%n in (1,1,%maxsubcount%) do (
  If "%firstlet%" == ":" (
    call %subname%%%n %param%
    ) else (
    %subname%%%n %param%
    )
  )
  if defined info4 echo %funcendtext% %0
goto :eof

:setinfolevel
:: Description: Used for initial setup and after xrun.ini and project.txt
:: Usage: call :setinfolevel numb-level
:: Note: numb-level range 0-6
  rem reset info vars
  set info1=
  set info2=
  set info3=
  set info4=
  set info5=
  if "%~1" geq "1" set info1=on
  if "%~1" geq "2" set info2=on
  if "%~1" geq "3" set info3=on
  if "%~1" geq "4" set info4=on
  if "%~1" geq "5" set info5=on
  if defined info4 set funcendtext=       ----}
  if defined info4 set funcstarttext={---
  if defined info5 @echo on
goto :eof

:funcend
:: Description: Used with func that out put files. Like XSLT, cct, command2file
:: Usage: call :funcend %%0
  set funcname=%~1
  @if defined info1 if exist "%outfile%" echo Created: %outfile%
  @if defined outfile if not exist "%outfile%" color 60 & Echo Output file not created!
  @if defined info4 echo %funcendtext% %funcname%
  @if not exist "%outfile%" set skiptasks=on  & pause
goto :eof

