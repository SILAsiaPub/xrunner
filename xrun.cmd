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
if not defined infolevel set infolevel=0
setlocal enabledelayedexpansion
call :setinfolevel %infolevel%
if defined info2 echo %0 "%1" %2 %3 %4 %5 
color 07
if not defined unittest call :main %groupin%
if defined unittest call :unittest %groupin%
if defined unittest pause
if defined info3 echo %funcendtext% xrun
goto :eof

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Depends on: setup, taskgroup
  if defined info3 echo {---- :main %~1
  set group=%~1
  call :setup
  if defined group set taskgroup=%group%
  set utreturn=-,%group%,
  if not defined unittest for %%g in (%taskgroup%) do call :taskgroup t%%g
  if defined unittest for %%g in (%taskgroup%) do call :unittestaccumulate t%%g
  if exist scripts\*.xrun del scripts\*.xrun
  if defined info3 echo %funcendtext% :main
  if defined pauseatend pause
goto :eof

:taskgroup
:: Description: Loop that triggers each task in the group.
:: Usage: call :taskgroup group
  set group=%~1
  if defined info3 echo %funcstarttext% %0 %group%
  set taskend=!%~1count!
  rem if not defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :task %group%%%c
  if not defined unittest FOR /F "eol=] delims=[" %%q IN (scripts\%group%.xrun) DO %%q
  set utreturn= %group%
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :unittestaccumulate %group%%%c
  if defined info3 echo %funcendtext% %0 %~1
goto :eof

:task
:: Description: Depreciated; This tests various variables and starts the task if appropriate.
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
    set utreturn=%list%
  FOR /F "eol=[ delims=`" %%q IN (%list%) DO set %%q  & set utreturn=%utreturn%, %%q
  if defined info3 echo %funcendtext% %0
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Depends on: variableslist, xslt
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=0
  set scripts=
  call :variableslist "%cd%\setup\xrun.ini"
  set utreturn=
  call :detectdateformat
  rem for %%k in (%taskgroup%) do set t%%kcount=%defaulttaskcount% & set utreturn=%utreturn% %%k
  rem set maxsubcount=%defaulttaskcount%
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
  call :xslt variable2xslt-2.xslt blank.xml scripts\project.xslt "projectpath='%projectpath%'"
  rem the following sets the default script path but it can be overridden by a scripts= in the project.txt
  set scripts=%projectpath%\scripts
  call "%projectpath%\tmp\project.cmd"
  if exist "scripts\project.xslt" move /Y "scripts\project.xslt" "%scripts%" >> log.txt
  call :setinfolevel %infolevel%
  set utreturn=%scripts%
  if defined info3 echo %funcendtext% %0
goto :eof


:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2"
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  set params=%~4
  if not exist "%script%" echo Error: missing script: %script% & set missinginput=on
  if defined missinginput color 06& echo %funcendtext% %0  & goto :eof
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined info2 echo.
  if defined info2 echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  set utreturn=%saxon%, %script%, %infile%, %outfile%, %group%-%count%-%~n1.xml
  call :funcend %0
goto :eof

:cct                                               
  :: Description: Privides interface to CCW32.
  :: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
:: Depends on: inccount, infile, outfile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount %count%
  set script=%~1
  set append=%~4
  if not defined script echo CCT missing!& echo %funcendtext% %0 error1 & set utreturn=missing script & goto :eof
  call :infile "%~2"
  rem if not exist "%script%" echo Error: missing script file& echo %funcendtext% %0  & goto :eof
  set cctparam=-u -b -q -n
  if defined append set cctparam=-u -b -q -n -a
  if not exist "%ccw32%" echo missing ccw32.exe file& echo %funcendtext% %0  & goto :eof
  set scriptout=%script:.cct,=_%
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%scriptout%.xml"
  set curcommand="%ccw32%" %cctparam% -t "%script%" -o "%outfile%" "%infile%"
  if defined info2 echo. & echo %curcommand%
  set basepath=%cd%
  cd /D "%scripts%"
  call %curcommand%
  cd /D "%basepath%"
  set utreturn=%ccw32%, %cctparam%, %script%, %infile%, %outfile%
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
  set utreturn=%infile%
  if defined info3 echo %funcendtext% %0
goto :eof

:outfile
:: Description: If out file is specifically set then uses that else uses supplied name.
:: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml" nocheck
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
  rem create prev copy if already exists
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"  >> log.txt
  if exist "%outfile%" del "%outfile%"
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
  if not defined checkpath echo missing required directory parameter for :checkdir& echo %funcendtext% %0  & goto :eof
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
  set utreturn=%count%, %writecoun%
  if defined info3 echo %funcendtext% %0
goto :eof

:inc
  if defined info3 echo %funcstarttext% %0 "%~1"
set /A %~1+=1
  set utreturn=!%~1!
  if defined info3 echo %funcendtext% %0
goto :eof

:dec
  if defined info3 echo %funcstarttext% %0 "%~1"
set /A %~1-=1
  set utreturn=!%~1!
  if defined info3 echo %funcendtext% %0
goto :eof

:var
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set& echo %funcendtext% %0 & set utreturn=missing vname & goto :eof
  rem no longer needed call :v2 retval "%value%"
  set %vname%=%value%
  set utreturn=%vname%, !%vname%!
  if defined info3 echo %funcendtext% %0
goto :eof

:v2
:: Depreciated: no longer needed or used.
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set& echo %funcendtext% %0  & goto :eof
  set %~1=%value%
  set utreturn=%value%
  if defined info3 echo %funcendtext% %0
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set infile=%outfile%
set outfile=%~1
  set start=%~2
call :checkdir "%outfile%"
  move /Y "%infile%" "%outfile%" >> log.txt
  @if defined info1 if exist "%outfile%" echo. & echo Info: Moved to: %~1
  if defined start start "" "%outfile%"
  set utreturn=%infile%, %outfile%, %start%
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
  if defined outfile call :checkdir "%outfile%"
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
  set utreturn=%curcommand%, %commandpath%, %outfile%
  @if defined outfile call :funcend %0
goto :eof

:appendfile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  type "%~1" >> "%~2"
  set utreturn=%~1, %~2
  if defined info3 echo %funcendtext% %0
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
  if not defined command echo Info: missing command& echo %funcendtext% %0  & goto :eof
call :outfile "%out%" "%projectpath%\xml\%group%-%count%-%~1-command2file.xml"
set commandpath=%~3
set append=%~4
  if not defined append if "%commandpath%" == "append" set append=on
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
  set utreturn=%command%, %outfile%, %projectpath%\xml\%group%-%count%-%~1-command2file.xml
  call :funcend %0 
goto :eof


:command2var
:: Description: creates a variable from the command line
:: Usage: call :command2var varname "command" "comment"
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set commandline=%~1
set varname=%~2
  if not defined varname echo missing varname parameter& echo %funcendtext% %0  & goto :eof
  if not defined commandline echo missing list parameter& echo %funcendtext% %0  & goto :eof
set commandline=%commandline:'="%
if defined comment echo %comment%
  set utreturn=%commandline%, %varname%
  FOR /F "delims=#" %%s IN ('%commandline%') DO set %varname%=%%s & set utreturn=%utreturn%, %%s
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
  set numbparam=
  set appendparam=
  if not defined func echo Error: Missing func parameter[2]& echo %funcendtext% %0  & goto :eof
  if not defined filespec echo Error: Missing filespec parameter[1]& echo %funcendtext% %0  & goto :eof
  if not exist "%filespec%" echo Error: Missing source files& echo %funcendtext% %0  & goto :eof
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
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
  if not defined func echo Missing action parameter& echo %funcendtext% %0  & goto :eof
  if not defined string echo Missing string parameter& echo %funcendtext% %0  & goto :eof
  set numbparam=
  set appendparam=
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v 
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info4 set numbparam
  if defined info3 if defined comment echo %last%
  echo off
  FOR %%s IN (%string%) DO call %func% "%%s" %numbparam%
  if defined info3 echo %funcendtext% %0
goto :eof

:start
:: Description: Start a program but don't wait for it.
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set p1=%~1
  set p2=%~2
  set p3=%~3
  set p4=%~4
  set p5=%~5
  set p6=%~6
  set p7=%~8
  set p8=%~8
  echo.
  rem check availability
  if defined p1 call :command2var "where '%p1%'" whereout
  if "%whereout:~0,4%" neq "INFO" (
    set p1val=1
  ) else if exist "%p1%" (
    set p1val=1
  )
  if exist "%p2%" set p2val=1
  set /A valid=%p1val%+%p2val%
  if "%valid%" LSS "1" Echo Error: valid file not found to start! & goto :eof
  set curcommand="%p1%" "%p2%" "%p3%" %p4% %p5% %p6% %p7% %p8%
  rem run the command
  if "%p1%" == "%p1: =%" echo start %curcommand% & start %curcommand%
  if "%p1%" neq "%p1: =%" echo start "" %curcommand% & start "" %curcommand%
  if defined info3 echo %funcendtext% %0
goto :eof

:start2
:: Description: Start a program but don't wait for it.
  if defined info3 echo %funcstarttext% %0 %~1 %~2 %~3 %~4 %~5
  set p1=%~1
  set p2=%~2
  set p3=%~3
  set p4=%~4
  set p5=%~5
  set p6=%~6
  set p7=%~8
  set p8=%~8
  echo.
  rem check availability
  set curcommand=%p1% %p2% %p3%s %p4% %p5% %p6% %p7% %p8%
  rem run the command
  echo start /b %curcommand%
  start /b %curcommand%
  if defined info3 echo %funcendtext% %0
goto :eof

:unittest
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set group=%~1
  call :setup
  if defined group set taskgroup=%group%
  FOR /F "eol=[ delims=`" %%q IN (scripts\ut%group%.xrun) DO %%q
  if defined info2 echo Info: unit test for scripts\ut%group%.xrun
  rem FOR %%g in (%taskgroup%) do call :unittestgroup ut%%g
  if exist scripts\*.xrun del scripts\*.xrun
  if defined info3 echo %funcendtext% %0
goto :eof

rem :unittestgroup
rem   set groupname=%~1
rem   FOR /L %%c IN (1,1,%taskend%) DO if defined %groupname%%%c call :test !%groupname%%%c!
rem goto :eof

:pause
  pause
goto :eof

:test
:: Description: Used for unit testing
:: Usage: call :test val1 val2 valn report
  if defined info3 echo %0 "%~1" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7"
  set val1=%~1
  set val2=%~2
  set val3=%~3
  set val4=%~4
  set val5=%~5
  set val6=%~6
  set val7=%~7
  set val8=%~8
  set val9=%~9
  set t=
  set last=
  if defined info4 for /L %%v in (4,1,9) Do set val%%v
  rem if defined val4 if "%val4%" neq "%val4: =%" set val4="%val4%"
  rem if defined val5 if "%val5%" neq "%val5: =%" set val5="%val5%"
  rem set the correct parameters for the command and the echo by the number of variables declared on each task line
  set preaddnumbparam=%val1%
  for /L %%v in (4,1,9) Do call :calcnumbparam val %%v -1
  for /L %%v in (9,-1,4) Do call :last val %%v
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
    call :var utreturn1 %utreturn1%
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
  set tword=passed & color 07
  if %t% gtr 0 set tword=failed & color 06
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

:calcnumbparam
:: Description: Append numbered parameters on the end of a predefined %preaddnumbparam% string
:: Usage: call :calcnumbparam prepart-of-par-name seed-numb [value-to-add-or-subtract]
:: Note: Default value to add or subtract is -0
  set calcnumb=%~3
  if not defined calcnumb set calcnumb=+0
  set /A newnumb=%~2%calcnumb%
  if defined val%~2 set preaddnumbparam=%preaddnumbparam% "!%~1%newnumb%!"
goto :eof

:appendnumbparam
:: Description: Append numbered parameters on the end of a given variable name. Used from a loop like :loopfiles.
:: Usage: call :appendnumbparam prepart-of-par-name seed-numb out_var_name
  set outvar=%~1
  set parpre=%~2
  set numb=%~3
  set calcnumb=%~4
  if not defined calcnumb set calcnumb=+0
  set /A newnumb=%numb%%calcnumb%
  if not defined outvar echo Error: no var name defined at par3.& echo %funcendtext% %0  & goto :eof
  if defined %parpre%%numb% set appendparam=%appendparam% "!%parpre%%newnumb%!"
  set %outvar%=%appendparam%
goto :eof

:last
:: Description: Find the last parameter in a set of numbered params. Usually called by a loop.
:: Usage: call :last par_name number
  if defined lastfound goto :eof
  set last=!%~1%~2!
  if defined last set lastfound=on
  set utreturn=%last%, %~1, %~2
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
  If not defined sub1 echo Error: Missing variable in par1. Exit function!& echo %funcendtext% %0  & goto :eof
  If not defined sub2 echo Error: Missing subname in par2. Exit function!& echo %funcendtext% %0  & goto :eof
  rem now run all possible
  rem call scripts\%sub2%.cmd
  FOR /F "eol=[ delims=;" %%q IN (scripts\t%sub2%.xrun) DO %%q
  rem the following 3 lines are for Unit testing.
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam sub %%v
  set utreturn= %varin%, %subname%, %numbparam%, %taskend%, 
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO if defined %sub2%%%c call :unittestaccumulate %sub2%%%c
  if defined info3 echo %funcendtext% %0 %sub2%
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
  rem turn on echo for debugging
  if "%~1" == "5" echo on
  rem turn off echo for the remaining levels
  rem if  "%~1" LSS "5" echo off
  set utreturn=%~1, %info1%, %info2%, %info3%, %info4%, %info5%, %funcstarttext%, %funcendtext%
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
  @if defined outfile if exist "%outfile%" set utret4=
  @if defined info3 echo %funcendtext% %funcname%
  @if not defined info3 set utret5=
  @if defined info3 set utret5=%funcendtext% %funcname%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & if not defined unittest pause
  set utreturn= %funcname%, %info1%, %info3%, %utret3%, %utret4%, %utret5%
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
  set utreturn=%infile%, %outfile%, %css%, %prince%, %curcommand%
  call :funcend %0
goto :eof

:ifexist
:: Description:
:: Usage: call :ifexist testfile action 
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3" %~4 %~5 %~6
  set testfile=%~1
  set param2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  if not defined testfile echoError:  missing testfile parameter& echo %funcendtext% %0 error1 & goto :eof
  if not defined param2 echo Error: missing action param2& echo %funcendtext% %0 error2 & goto :eof
  for /L %%v in (2,1,6) Do if defined param%%v if "!param%%v!" neq "!param%%v: =!" set param%%v="!param%%v!"
  if not exist "%testfile%" if defined info1 echo Info: testfile %~nx1 does not exist. No action %param2% taken
  if exist "%testfile%" if defined info1 echo %param2% %param3% %param4% %param5%
  if exist "%testfile%" %param2% %param3% %param4% %param5% 
  set utreturn=%testfile%, %param2%, %param3%, %param4%, %param5%, %param6%
  if defined info3 echo %funcendtext% %0
goto :eof

:ifnotexist
:: Description: If a file or folder do not exist, then performs an action.
:: Usage: call :ifnotexist testfile action 
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set testfile=%~1
  set action=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  if not defined testfile echo missing testfile parameter & echo %funcendtext% %0  & goto :eof
  if not defined action echo missing action parameter & echo %funcendtext% %0  & goto :eof
  set action=%action:'="%
  if not exist "%testfile%" "%action%" %param3% %param4% %param5% %param6%
  set utreturn=%testfile%, %action%, %param3%, %param4%, %param5%, %param6%
  if defined info3 echo %funcendtext% %0
 if defined masterdebug call :funcdebug %0 end
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
  if not exist "%infile%" echo Error: missing infile = %infile% & echo %funcendtext% %0  & goto :eof
  if defined info2 echo.
  if defined info2 echo call iconv -f CP1252 -t UTF-8 "%infile%"
  call iconv -f CP1252 -t UTF-8 "%infile%" > "%outfile%"
  set utreturn=%par1%, %par2%, %par3%, %projectpath%\tmp\iconv-%~nx1, 
  call :funcend %0
goto :eof

:mergevar
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3" "%~4"
set pname=%~1
set vname=%~2
set v1=%~3
set v2=%~4
set %vname%=!%pname%%v1%!!%pname%%v2%!
  set utreturn=!%vname%!
  if defined info3 echo %funcendtext% %0
goto :eof

:name
  if defined info3 echo %funcstarttext% %0, %~1
set name=%~n1
set name
  if defined info3 echo %funcendtext% %0
goto :eof

:encoding
:: Description: to check the encoding of a file
:: Usage: call :encoding file validate-or-check [validate-against]
:: Depends on: :infile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
if not defined encodingchecker echo Encoding not checked. & echo %funcendtext% %0 error1 &goto :eof
if not exist "%encodingchecker%" echo file.exe not found! %fileext% &echo Encoding not checked. & echo %funcendtext% %0 error2 & goto :eof
set testfile=%~1
set validateagainst=%~2
call :infile "%testfile%"
set nameext=%~nx1
FOR /F "usebackq tokens=1-2" %%A IN (`%encodingchecker% --mime-encoding "%infile%"`) DO set fencoding=%%B
if defined validateagainst (
    if "%fencoding%" == "%validateagainst%"  (
        echo Encoding is: %fencoding% for file %nameext%.
      ) else if "%fencoding%" == "us-ascii" (
        echo Encoding is: %fencoding% not %validateagainst% but is usable.
      ) else (
        echo File %nameext% encoding is invalid! 
        echo Encoding is: %fencoding%  But it was expected to be: %validateagainst%.
        set errorsuspendprocessing=on
      )
) else  (              
    echo Encoding is: %fencoding% for file %nameext%.
) 
  set utreturn=%testfile%, %validateagainst%, %fencoding%, %nameext%
  if defined info3 echo %funcendtext% %0
goto :eof

:copy
:: Description: Provides copying with exit on failure
:: Usage: call :copy infile outfile [append]
:: Depends on: :infile, :outfile, :inccount :funcend
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :infile "%~1"
  call :outfile "%~2" "%~dpn1-copy%~x1"
  set appendfile=%~3
  if defined missinginput echo missing input file & goto :eof
  call :inccount
  if defined appendfile set curcommand=copy /y "%outfile%"+"%infile%" "%outfile%" 
  if not defined appendfile  set curcommand=copy /y "%infile%" "%outfile%" 
  %curcommand%
  call :funcend %0
goto :eof

:regex
:: Description: Run a regex on a file
:: usage: call :regex find replace infile outfile
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount
  if defined missinginput color 06& echo %funcendtext% %0  & goto :eof
  set find="%~1"
  set replace=%~2
  set replacepart=--replace "%~2"
  if not defined replace set replacepart=--replace ""
  call :infile "%~3"
  call :outfile "%~4" "%projectpath%\tmp\%group%-%count%-regex.txt"
  set options=%~5
  set curcommand=rxrepl.exe %options% --search %find% %replacepart% -f "%infile%" -o "%outfile%"
  echo call %curcommand%
  call %curcommand%
  call :funcend %0
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Revised: 2016-05-04
:: Classs: command - internal - date -time
:: Required preset variables:
:: dateformat
:: dateseparator
rem got this from: http://www.robvanderwoude.com/datetiment.php#IDate
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  FOR /F "tokens=1-4 delims=%dateseparator% " %%A IN ("%date%") DO (
      IF "%dateformat%"=="0" (
          SET fdd=%%C
          SET fmm=%%B
          SET fyyyy=%%D
      )
      IF "%dateformat%"=="1" (
          SET fdd=%%B
          SET fmm=%%C
          SET fyyyy=%%D
      )
      IF "%dateformat%"=="2" (
          SET fdd=%%D
          SET fmm=%%C
          SET fyyyy=%%B
      )
  )
  set curdate=%fyyyy%-%fmm%-%fdd%
  set curisodate=%fyyyy%-%fmm%-%fdd%
  set curyyyymmdd=%fyyyy%%fmm%%fdd%
  set curyymmdd=%fyyyy:~2%%fmm%%fdd%
  set curUSdate=%fmm%/%fdd%/%fyyyy%
  set curAUdate=%fdd%/%fmm%/%fyyyy%
  set curyyyy=%fyyyy%
  set curyy=%fyyyy:~2%
  set curmm=%fmm%
  set curdd=%fdd%
  if defined info3 echo %funcendtext% %0
goto :eof

:detectdateformat
:: Description: Get the date format from the Registery: 0=US 1=AU 2=iso
:: Usage: call :detectdateformat
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set KEY_DATE="HKCU\Control Panel\International"
  rem get dateformat number
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v iDate`) DO set dateformat=%%A
  rem get the date separator: / or -
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sDate`) DO set dateseparator=%%A
  rem get the time separator: : or ?
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sTime`) DO set timeseparator=%%A
  rem set project log file name by date
  if defined info3 echo %funcendtext% %0
goto :eof

:time
:: Description: Retrieve time in several shorter formats than %time% provides
:: Created: 2016-05-05
  if defined info3 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  FOR /F "tokens=1-4 delims=:%timeseparator%." %%A IN ("%time%") DO (
    set curhhmm=%%A%%B
    set curhhmmss=%%A%%B%%C
    set curhh_mm=%%A:%%B
    set curhh_mm_ss=%%A:%%B:%%C
  )
  if defined info3 echo %funcendtext% %0
goto :eof

:echo
:: Description: Echo a message
  echo %~1
goto :eof

:spawnbat
  set p1=%~1
  set p2=%~2
  set p3=%~3
  set p4=%~4
  set p5=%~5
  set p6=%~6
  set p7=%~8
  set p8=%~8

start "" %p1% "%p2%" "%p3%" "%p4%"
goto :eof

:copy2usb
:: Description: Set up to cop files to USB drive and optionally format.
:: Usage: call ::copy2usb source_path target_drive target_folder [format_first]
  if defined info3 echo %funcstarttext% %0 "%~1" %~2 "%~3" %~4
  set sourcepath=%~1
  set targetdrive=%~2
  set targetpath=%~3
  set format=%~4
  set volumename=%~5
  set protecteddrives=a b c d e l p s t
  if not exist %targetdrive%:\ echo Drive %targetdrive%: not available! & goto :eof
  if "%protecteddrives%" neq "!protecteddrives:%targetdrive%=!" echo System drive! Abort! & goto :eof
  if defined format FORMAT %targetdrive%: /V:%volumename% /Q /X /Y
  echo Copying %targetdrive%:\%targetpath%
  XCOPY /V /I /Q /G /Y /J "%sourcepath%" "%targetdrive%:\%targetpath%"
  EjectMedia %targetdrive%:
  if "%errorlevel%" neq "0" pause
  if defined info3 echo %funcendtext% %0
goto :eof
