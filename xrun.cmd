:: Description: xrun
:: Usage: xrun C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
:: Note: Xrun requires a project file. The group parameter is normally a letter a-t but can be nothing. If nothing all groups are run.
@echo off
set echoatstart=%~3
if "%echoatstart%" == "5" echo on
rem 
set projectfile=%1 
if not exist %1 (
  rem This is to ensure there is a parameter for the project.txt file.
  echo A valid project file must be provided. It is a required parameter.
  echo Usage: xrun C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
  echo This script will exit.
  pause
  goto :eof
)
set projectpath=%~dp1
set projectpath=%projectpath:~0,-1%
set groupin=%2
set infolevel=%3
set Pauseatend=%4
set unittest=%5
if defined info3 echo {---- Cmd: %0 "%1" %2 %3 %4 %5 
if not defined infolevel set infolevel=0
setlocal enabledelayedexpansion
color 07
call :setinfolevel %infolevel%
if not defined unittest call :main %groupin%
if defined unittest call :unittest %groupin%
if defined unittest pause
if defined unittest exit
if defined info3 echo %funcendtext% xrun
goto :eof

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Depends on: setup, taskgroup
  if defined info3 echo {---- :main %~1
  set group=%~1
  call :setup
  if defined group set taskgroup=%group%
  if not defined unittest for %%g in (%taskgroup%) do call :taskgroup t%%g
  set utreturn= %group%, %taskgroup%
  if defined unittest for %%g in (%taskgroup%) do call :unittestaccumulate t%%g
  if defined info3 echo %funcendtext% :main
  if defined pauseatend pause
goto :eof

:taskgroup
:: Description: Loop that triggers each task in the group.
:: Usage: call :taskgroup group
:: Requires: task
  set group=%~1
  if defined info3 echo %funcstarttext% %0 %group%
  set taskend=!%~1count!
  if not defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :task %group%%%c
  set utreturn= %group%, %taskend%
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :unittestaccumulate %group%%%c
  if defined info3 echo %funcendtext% %0 %~1
goto :eof

:task
:: Description: This tests various variables and starts the task if appropriate.
:: Usage: call :task task
:: Note: The task variable is an interger number, in the range 1-20 but can be set higher.
:: Depends on: 
  if defined missinginput goto :eof
  set task=%~1
  if not defined %task% goto :eof
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set call=
  if defined skiptasks goto :eof
  set curcommand=!%~1!
  set firstlet=%curcommand:~0,1%
  if "%firstlet%" == ":" set call=call
  if not defined unittest %call% !%~1!
  set utreturn= %task%, %firstlet%, %curcommand:"='%, %call%
  if defined info3 echo %funcendtext% %0 %~1
goto :eof


:variableslist
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist list
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set list=%~1
  if defined info2 echo.
  if defined info2 echo Info: Setting variables from: %~nx1
  FOR /F "eol=[ delims=`" %%q IN (%list%) DO set %%q
    set utreturn=%list%
  if defined info3 echo %funcendtext% %0
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Depends on: variableslist, xslt
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=0
  call :variableslist "%cd%\setup\xrun.ini"
  for %%k in (%taskgroup%) do set t%%kcount=%defaulttaskcount%
  set maxsubcount=%defaulttaskcount%
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
  set scripts=%projectpath%\scripts
  call "%projectpath%\tmp\project.cmd"
    if exist "scripts\project.xslt" move /Y "scripts\project.xslt" "%scripts%"
  rem call :variableslist "%projectfile%"
  call :setinfolevel %infolevel%
  if defined info3 echo %funcendtext% %0
goto :eof


:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount %count%
  set script=%scripts%\%~1
  call :infile "%~2"
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  set params=%~4
  if not exist "%script%" echo Error: missing script: %script% & set missinginput=on
  if defined missinginput color 06 & goto :eof
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev" >> log.txt
  if exist "%outfile%" del "%outfile%"
  if defined info3 echo.
  if defined info3 echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  call :funcend %0
goto :eof

:cct                                               
  :: Description: Privides interface to CCW32.
  :: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
:: Depends on: inccount, infile, outfile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info2 echo %curcommand%
  call %curcommand%
  call :funcend %0
goto :eof

:infile
  :: Description: If infile is specifically set then uses that else uses previous outfile.
  :: Usage: call :infile "%file%"
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set infile=%~1
  if not defined infile set infile=%outfile%
  if exist "%infile%" set missinginput=
  if not exist "%infile%" set missinginput=on
  if not exist "%infile%" echo Error: missing input file to :infile
  if defined info3 echo Info: infile = %infile%
  if defined info3 echo %funcendtext% %0
goto :eof

:outfile
  :: Description: If out file is specifically set then uses that else uses supplied name.
  :: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml"
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set testoutfile=%~1
  set testoutdp=%~dp1
  set testoutnx=%~nx1
  rem call :v2 testoutfile "!testoutfile!"
  set defaultoutfile=%~2
  set defaultoutdp=%~dp2
  set defaultoutnx=%~nx2
  rem if defined info1 set defaultoutfile
  set nocheck=%~3
  if defined testoutfile set outfile=%testoutfile%
  if not defined testoutfile set outfile=%defaultoutfile%
  if not defined nocheck call :checkdir "%outfile%"
  set utreturn=%outfile%, %testoutfile%, %defaultoutfile%
  if defined info3 echo.
  if defined info3 echo Info: outfile = %outfile%
  if defined info3 echo %funcendtext% %0
goto :eof

:drivepath
  :: Description: returns the drive and path from a full drive:\path\filename
  :: Usage: call :drivepath C:\path\name.ext|path\name.ext
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set utdp=%~dp1
  set drivepath=%utdp:~0,-1%
  set utreturn=%drivepath%
  if defined info3 echo %funcendtext% %0
goto :eof

:checkdir
  :: Description: checks if dir exists if not it is created
  :: Usage: call :checkdir C:\path\name.ext
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set checkpath=%~1
  set drivepath=%~dp1
  if not defined checkpath echo missing required directory parameter for :checkdir & goto :eof
  set ext=%~x1
  if defined ext set checkpath=%~dp1
  if defined ext set checkpath=%checkpath:~0,-1%
  if exist "%checkpath%" if defined info4 echo Info: found path %checkpath%
  if not exist "%checkpath%" if defined info4 echo Info: creating path %checkpath%
  if not exist "%checkpath%" mkdir "%checkpath%"
  set utreturn=%checkpath%
  if defined info3 echo %funcendtext% %0
goto :eof

:inccount
:: Description: iIncrements the count variable
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=%count%+1
  set writecount=%count%
  if %count% lss 10 set writecount=%space%%count%
  if defined info3 echo %funcendtext% %0
goto :eof

:inc
set /A %~1+=1
goto :eof

:dec
set /A %~1-=1
goto :eof

:var
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set & goto :eof
  call :v2 retval "%value%"
  set %vname%=%retval%
  set utreturn=%retval%
  if defined info3 echo %funcendtext% %0
goto :eof

:v2
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set & goto :eof
  set %~1=%value%
  set utreturn=%value%
  if defined info3 echo %funcendtext% %0
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set infile=%outfile%
  call :var infile "%infile%"
set outfile=%~1
call :checkdir "%outfile%"
  move /Y "%infile%" "%outfile%" >> log.txt
  @if defined info1 if exist "%outfile%" echo Created: %~nx1 in folder: %~dp1
  if defined info3 echo %funcendtext% %0
goto :eof

:command
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run  command in"   "output file to test for"]
:: Note: Single quotes get converted to double quotes before the command is used.
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info2 echo %curcommand%
call %curcommand%
if defined commandpath cd /D "%basepath%"
  @if defined outfile call :funcend %0
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Usage: call :command2file "command" "outfile" ["commandpath"]
:: Depends on: inccount, outfile
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
    if defined info2 echo %curcommand% ^>  "%outfile%"
  call %curcommand% > "%outfile%"
) else (
    if defined info2 echo %curcommand% ^>^>  "%outfile%"
  call %curcommand% >> "%outfile%"
)
if defined commandpath (
  cd /D "%basepath%"
)
  call :funcend %0 
goto :eof


:command2var
:: Description: creates a variable from the command line
:: Usage: call :command2var varname "command" "comment"
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info3 echo %funcendtext% %0
goto :eof

:inputfile
:: Description: Sets the starting file of a serial tasklist, by assigning it to the var outfile
:: usage: call :inputfile "drive:\path\file.ext"
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set outfile=%~1
  if not defined outfile echo Missing param1  & set skip=on
  if defined info3 echo %funcendtext% %0
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles file_specs sub_name [param[3-9]]
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7" "%~8" "%~9"
  set filespec=%~1
  set func=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  set appendparam=
  if not defined action echo Error: Missing action parameter & goto :eof
  if not defined filespec echo Error: Missing filespec parameter & goto :eof
  if not exist "%filespec%" echo Error: Missing source files & goto :eof
  for /L %%v in (4,1,9) Do call :appendnumbparam numbparam par %%v -1 
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info4 set numbparam
  if defined info3 if defined comment echo %last%
  if not defined unittest FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO  call %func% "%%s" %numbparam%
  set utreturn= %filespec%, %sub%, %numbparam%, %last%
  if defined unittest FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO call :unittestaccumulate "%%s" %sub% %numbparam%
  if defined info3 echo %funcendtext% %0
goto :eof

:loopstring
:: Description: Loops through a list supplied in a space separated string.
:: Usage: call :loopstring action "string" ["comment"]
:: Note: action may have multiple parts
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set string=%~1
  set func=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  if not defined func echo Missing action parameter & goto :eof
  if not defined string echo Missing string parameter & goto :eof

  for /L %%v in (4,1,9) Do call :appendnumbparam numbparam par %%v -1 
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info4 set numbparam
  if defined info3 if defined comment echo %last%
  echo off
  FOR %%s IN (%string%) DO call %func% "%%s" %numbparam%
  if defined info3 echo %funcendtext% %0
goto :eof

:start
:: depreciated: this is not needed
:: Description: Start a program but don't wait for it.
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :var p1 %~1
  call :var p2 %~2
  set p3=%~3
  set p4=%~4
  echo.
  echo start "%p1%" "%p2%" "%p3%" "%p4%"
  start "%p1%" "%p2%" "%p3%" "%p4%"
  if defined info3 echo %funcendtext% %0
goto :eof

:unittest
  set group=%~1
  call :setup
  if defined group set taskgroup=%group%
  FOR %%g in (%taskgroup%) do call :unittestgroup ut%%g
goto :eof

:unittestgroup
  set groupname=%~1
  FOR /L %%c IN (1,1,%taskend%) DO if defined %groupname%%%c call :test !%groupname%%%c!
goto :eof

:test
:: Description: Used for unit testing
:: Usage: call :test val1 val2 report
  if defined info3 echo %0 "%~1" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7"
  set val1=%~1
  set val2=%~2
  set val3=%~3
  set val4=%~4
  set val5=%~5
  set val6=%~6
  set val7=%~7
  set t=
  rem set the correct parameters for the command and the echo by the number of variables declared on each task line
  set preaddnumbparam=%val1%
  for /L %%v in (4,1,7) Do call :addnumbparam val %%v -1
  echo Unit test %preaddnumbparam%
  call %preaddnumbparam%
  rem Increment the test count
  set /A tcount+=1
  rem now echo the input values
  echo test input1: %val3%
  if defined val5 echo test input2: %val4%
  if defined val6 echo test input3: %val5%
  if defined val7 echo test input4: %val6%
  rem now output each  output followed by the expected output
  for /F "tokens=1-12 delims=," %%g in ("%val2%") do (
    set expect1=%%g
    set expect2=%%h
    set expect3=%%i
    set expect4=%%j
    set expect5=%%k
    set expect6=%%l
    set expect7=%%m
    set expect8=%%n
    set expect9=%%o
    set expect10=%%p
    set expect11=%%q
    set expect12=%%r
    )
  for /F "tokens=1-12 delims=," %%g in ("%utreturn%") do (
    set utreturn1=%%g
    set utreturn2=%%h
    set utreturn3=%%i
    set utreturn4=%%j
    set utreturn5=%%k
    set utreturn6=%%l
    set utreturn7=%%m
    set utreturn8=%%n
    set utreturn9=%%o
    set utreturn10=%%p
    set utreturn11=%%q
    set utreturn12=%%r
    )
  for /L %%n in (1,1,12) Do (
    if defined expect%%n (
      echo test output%%n: !utreturn%%n!
      echo    expected%%n: !expect%%n!
      echo on
      if "!utreturn%%n!" == "!expect%%n!" set t=!t!0
      if "!utreturn%%n!" neq "!expect%%n!"  set t=!t!1
      echo off
    ) 
  ) 
  set tword=passed
  if %t% gtr 0 set tword=failed & color 06
  for /L %%v in (7,-1,4) Do call :last val %%v
  echo Test: %tword%  %t%  %val1% test %tcount% %last%
  @echo.
  if "%tword%" == "failed" pause
  if not defined unittest if defined funcgrp4 echo %funcendtext% %0
goto :eof

:testcore
:: superceeded
  rem :main will call :setup
  call :test :main " a, a" "a" "Testing Main"
  call :test :main " , a b c d e f g h i j k l m n o p q r s t u v w x y z" "" "Testing Main without group"
  call :test :taskgroup "taska, 20" "taska" "Testing with a task"
  set taska1=:testecho "This is to test task in unittesting"
  call :test :task "taska1, :" "taska1" "Testing with a task"
goto :eof

:testecho
:: superceedd
  echo :testecho %~1
goto :eof

:unittestaccumulate
:: Description: Acumulate %utreturn% variables into a coma space separated list.
  set utreturn=%utreturn%, %~1
goto :eof

:addnumbparam
:: Description: Append numbered parameters on the end of a predefined %preaddnumbparam% string
:: Usage: call :addnumbparam prepart-of-par-name seed-numb [value-to-add-or-subtract]
:: Note: Default value to add or subtract is -0
  set calcnumb=%~3
  if not defined calcnumb set calcnumb=+0
  set /A newnumb=%~2%calcnumb%
  if defined val%~2 set preaddnumbparam=%preaddnumbparam% "!%~1%newnumb%!"
goto :eof

:appendnumbparam
:: Description: Append numbered parameters on the end of a given variable name. Used from a loop like :loopfiles.
:: Usage: call :addnumbparam prepart-of-par-name seed-numb out_var_name
  set outvar=%~1
  set parpre=%~2
  set numb=%~3
  set calcnumb=%~4
  if not defined calcnumb set calcnumb=+0
  set /A newnumb=%numb%%calcnumb%
  if not defined outvar echo Error: no var name defined at par3. & goto :eof
  if defined %parpre%%numb% set appendparam=%appendparam% "!%parpre%%newnumb%!"
  set %outvar%=%appendparam%
goto :eof

:last
:: Description: Find the last parameter in a set of numbered params. Usually called by a loop.
:: Usage: call :last par_name number
  if defined lastfound goto :eof
  set last=!%~1%~2!
  if defined last set lastfound=on
goto :eof


:sub
:: Description: Starts a sub loop
:: Usage: call :sub "subname" "['param1' ['param2' ['param3' ['param4']]]]"
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7" "%~8" "%~9"
  set sub1=%~1
  set sub2=%~2
  Set sub3=%~3
  Set sub4=%~4
  Set sub5=%~5
  Set sub6=%~6
  Set sub7=%~7
  Set sub8=%~8
  Set sub9=%~9
  set appendparam=
  If not defined sub1 echo Error: Missing variable in par1. Exit function! & goto :eof
  If not defined sub2 echo Error: Missing subname in par2. Exit function! & goto :eof
  rem now run all possible
  call scripts\%sub2%.cmd
  FOR /F "eol=[ delims=;" %%q IN (scripts\sub.txt) DO %%q
  rem the following 3 lines are for Unit testing.
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  set utreturn= %varin%, %subname%, %numbparam%, %taskend%, 
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO if defined %sub2%%%c call :unittestaccumulate %sub2%%%c
  if defined info3 echo %funcendtext% %0
goto :eof

:setinfolevel
:: Description: Used for initial setup and after xrun.ini and project.txt
:: Usage: call :setinfolevel numb-level
:: Note: numb-level range 0-5
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  rem reset info vars
  for /L %%v in (1,1,5) Do set info%%v=
  rem set info levels from input
  for /L %%v in (1,1,5) Do if "%~1" geq "%%v" set info%%v=on
  if defined info4 echo.
  if defined info4 FOR /F %%i IN ('set info') DO echo Info: %%i
  if "%~1" geq "3" set clfeedback=on
  set funcstarttext={---
  set funcendtext=       ----}
  rem if not unit testing the turn on echo for debugging
  if not defined unittest if "%~1" == "5" echo on
  rem turn off echo for the remaining levels
  for /L %%v in (4,-1,0) Do if "%~1" == "%%v" echo off
  set utreturn= %info1%, %info2%, %info3%, %info4%, %info5%, %funcstarttext%, %funcendtext%
  if defined info3 echo %funcendtext% %0
goto :eof

:funcend
:: Description: Used with func that out put files. Like XSLT, cct, command2file
:: Usage: call :funcend %%0
  set funcname=%~1
  @if defined info1 if exist "%outfile%" echo.
  @if defined info1 if exist "%outfile%" echo Created: %outfile%
  @if defined info1 if exist "%outfile%" set utret3=Created: %outfile%
  @if defined outfile if not exist "%outfile%" color 06 & Echo Output file not created!
  @if defined outfile if not exist "%outfile%" set utret4=color 06
  @if defined info3 echo %funcendtext% %funcname%
  @if defined info4 set utret5=%funcendtext% %funcname%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & pause
  set utreturn= %funcname%, %utret3%, %utret4%, %utret5%
  if defined info3 echo %funcendtext% %0
goto :eof

:prince
:: Description: Make PDF using PrinceXML
:: Usage: call :prince [infile [outfile [css]]]
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :infile %~1
  call :outfile %~2
  set css=%~3
  if defined css set css=-s "%css%"
  set curcommand=call "%prince%" %css% "%infile%" -o "%outfile%"
  if defined info2 echo %curcommand%
  %curcommand%
  call :funcend %0
goto :eof

:ifexist
:: Description:
:: Usage:
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set testfile=%~1
  set action=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  if not defined testfile echoError:  missing testfile parameter & goto :eof
  if not defined action echo Error: missing action parameter & goto :eof
  set action=%action:'="%
  if exist "%testfile%" "%action%"
  if defined info3 echo %funcendtext% %0
goto :eof

:iconv
:: Description: Converts files from CP1252 to UTF-8
:: Usage: call :iconv infile outfile OR call :iconv file_nx inpath outpath
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set par1=%~1
  set par2=%~2
  set par3=%~3
  if not defined par3 call :infile "%par1%"
  if not defined par3 call :outfile "%par2%" "%projectpath%\tmp\iconv-%~nx1"
  if defined par3 set infile=%par2%\%par1%
  if defined par3 call :outfile "%par3%\%par1%" "%projectpath%\tmp\iconv-%~nx1"
  if not exist "%infile%" echo Error: missing infile = %infile%  & goto :eof
  call iconv -f CP1252 -t UTF-8 "%infile%" > "%outfile%"
  call :funcend %0
goto :eof

:mergevar
set pname=%~1
set vname=%~2
set v1=%~3
set v2=%~4
set %vname%=!%pname%%v1%!!%pname%%v2%!
goto :eof

:name
set name=%~n1
set name
goto :eof