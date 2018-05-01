:: Description: xrun
:: Usage: xrun C:\path\project.txt [group] [infolevel] [pauseatend]
:: Note: Xrun requires a project file. The group parameter is normally a letter a-t but can be nothing. If nothing all groups are run.
@echo off
set echoatstart=%~3
if "%echoatstart%" == "5" echo on
rem 
set projectfile=%1 
if not exist %1 (
  rem This is to ensure there is a parameter for the project.txt file.
  echo A valid project file must be provided. It is a required parameter.
  echo This script will exit.
  goto :eof
)
set projectpath=%~dp1
set projectpath=%projectpath:~0,-1%
set groupin=%2
set infolevel=%3
set Pauseatend=%4
set unittest=%5
setlocal enabledelayedexpansion
color 07
if not defined infolevel set infolevel=0
call :setinfolevel %infolevel%
if defined clfeedback echo Cmd: %0 "%1" %2 %3 %4 %5 
if not defined unittest goto :main %groupin%
if defined unittest call :test
goto :eof

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Depends on: setup, taskgroup
  if defined info4 echo {---- :main
  set group=%~1
  call :setup
  if defined groupin call :taskgroup task%groupin%
  if not defined groupin for %%g in (%taskgroup%) do call :taskgroup task%%g
  if defined unittest for %%g in (%taskgroup%) do call :testecho task%%g
  set utreturn= %groupid%, %taskgroup%
  if defined info4 echo %funcendtext% :main
  if defined pauseatend pause
goto :eof

:taskgroup
:: Description: Loop that triggers each task in the group.
:: Usage: call :taskgroup group
:: Requires: task
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set group=%~1
  set taskend=!%~1count!
  if not defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :task %group%%%c
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO echo %group%%%c
  set utreturn=%group%, %taskend%
  if defined info4 echo %funcendtext% %0 %~1
goto :eof

:task
:: Description: This tests various variables and starts the task if appropriate.
:: Usage: call :task task
:: Note: The task variable is an interger number, in the range 1-20 but can be set higher.
:: Depends on: 
  set task=%~1
  if not defined %task% goto :eof
  set call=
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  if defined skiptasks goto :eof
  set curcommand=!%~1!
  set firstlet=%curcommand:~0,1%
  if "%firstlet%" == ":" set call=call
  if not defined unittest %call% !%~1!
  set utreturn=%task%, %firstlet%, %curcommand:"='%, 
  if defined info4 echo %funcendtext% %0 %~1
goto :eof


:variableslist
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist list
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set list=%~1
  if defined info2 echo.
  if defined info2 echo Info: Setting variables from: %~nx1
  FOR /F "eol=[ delims=;" %%q IN (%list%) DO set %%q
  set utreturn=%list%
  if defined info4 echo %funcendtext% %0
goto :eof

:readline
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist list
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set list=%~1
  set func=%~2
  set par3=%~3
  set par4=%~4
  if defined info2 echo.
  if defined info2 echo Info: Reading lines from: %~nx1
  FOR /F "eol=[ delims=;" %%q IN (%list%) DO call %func% %%q %par3%
  set utreturn=%list%, %func%
  if defined info4 echo %funcendtext% %0
goto :eof

:inisection
:: Description: Read a section of an ini
set line=%~1
set section=%~2
if not defined line goto :eof
if %line:~0,1% == [ set skipkey=on
if %line% == [%section%] set skipkey=
if %line% == [%section%] set foundsect=%section%

goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Depends on: variableslist, xslt
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=0
  call :variableslist "%cd%\setup\xrun.ini"
  for %%k in (%taskgroup%) do set task%%kcount=%defaulttaskcount%
  set maxsubcount=%defaulttaskcount%
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
  call "%projectpath%\tmp\project.cmd"
  rem call :variableslist "%projectfile%"
  call :setinfolevel %infolevel%
  if defined info4 echo %funcendtext% %0
goto :eof


:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  call :inccount %count%
  set script=%scripts%\%~1
  call :infile "%~2"
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  if not exist "%script%" echo Error: missing script: %script%& color 06 & goto :eof
  set params=%~4
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev" >> log.txt
  if exist "%outfile%" del "%outfile%"
  if defined info3 echo.
  if defined info3 echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  call :funcend %0 info4
goto :eof

:cct                                               
  :: Description: Privides interface to CCW32.
  :: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
:: Depends on: inccount, infile, outfile
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  call :funcend %0 info4
goto :eof

:infile
  :: Description: If infile is specifically set then uses that else uses previous outfile.
  :: Usage: call :infile "%file%"
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set testoutfile=%~1
  set testoutdp=%~dp1
  set testoutnx=%~nx1
  rem call :v2 testoutfile "!testoutfile!"
  set defaultoutfile=%~2
  set defaultoutdp=%~dp2
  set defaultoutnx=%~nx2
  rem if defined info1 set defaultoutfile
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
  set utreturn=%outfile%, %outdp%, %outnx%
  if defined info4 echo.
  if defined info4 if defined testoutfile echo Outfile supplied  %~nx1
  if defined info4 if not defined testoutfile echo Outfile fallback used %~nx2
  if defined info4 echo %funcendtext% %0
goto :eof

:drivepath
  :: Description: returns the drive and path from a full drive:\path\filename
  :: Usage: call :drivepath C:\path\name.ext|path\name.ext
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set utdp=%~dp1
  set drivepath=%utdp:~0,-1%
  set utreturn=%drivepath%
  if defined info4 echo %funcendtext% %0
goto :eof

:checkdir
  :: Description: checks if dir exists if not it is created
  :: Usage: call :checkdir C:\path\name.ext
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set /A count=%count%+1
  set writecount=%count%
  if %count% lss 10 set writecount=%space%%count%
  if defined info4 echo %funcendtext% %0
goto :eof

:inc
set /A %~1+=1
goto :eof

:dec
set /A %~1-=1
goto :eof

:var
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set & goto :eof
  call :v2 retval "%value%"
  set %vname%=%retval%
  set utreturn=%retval%
  if defined info4 echo %funcendtext% %0
goto :eof

:v2
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set & goto :eof
  set %~1=%value%
  set utreturn=%value%
  if defined info4 echo %funcendtext% %0
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  @if defined outfile call :funcend %0 funcgrp2
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Usage: call :command2file "command" "outfile" ["commandpath"]
:: Depends on: inccount, outfile
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  call :funcend %0 funcgrp2
goto :eof


:command2var
:: Description: creates a variable from the command line
:: Usage: call :command2var varname "command" "comment"
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
set outfile=%~1
  if not defined outfile echo Missing param1  & set skip=on
  if defined info4 echo %funcendtext% %0
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles "action" "file specs" ["comment" ]
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
:: depreciated: this is not needed
:: Description: Start a program but don't wait for it.
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7"
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
  for /F "tokens=1-10 delims=," %%g in ("%val2%") do (
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
    )
  for /F "tokens=1-10 delims=," %%g in ("%utreturn%") do (
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
    )
  for /L %%n in (1,1,10) Do (
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
  echo %tword%  %t%  %val1% test %tcount% %last%
  @echo.
  if defined unittestpause pause
  if not defined unittest if defined funcgrp4 echo %funcendtext% %0
goto :eof

:testcore
  rem :main will call :setup
  call :test :main " a, a" "a" "Testing Main"
  call :test :main " , a b c d e f g h i j k l m n o p q r s t u v w x y z" "" "Testing Main without group"
  call :test :taskgroup "taska, 20" "taska" "Testing with a task"
  set taska1=:testecho "This is to test task in unittesting"
  call :test :task "taska1, :" "taska1" "Testing with a task"
goto :eof

:testecho
  echo :testecho %~1
goto :eof

:addnumbparam
:: Description: Append numbered parameters on the end of a predefined %preaddnumbparam% string
:: Usage: call :addnumbparam prepart-of-par-name seed-numb [value-to-add-or-subtract]
:: Note: Default value to add or subtract is -0
  set minusnumb=%~3
  if not defined minusnumb set minusnumb=+0
  set /A less=%~2%minusnumb%
  if defined val%~2 set preaddnumbparam=%preaddnumbparam% "!%~1%less%!"
goto :eof

:last
  if defined lastfound goto :eof
  set last=!%~1%~2!
  if defined last set lastfound=on
goto :eof


:sub
:: Description: Starts a sub loop
:: Usage: call :sub "subname" "['param1' ['param2' ['param3' ['param4']]]]"
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined funcgrp1 echo %funcendtext% %0
goto :eof

:setinfolevel
:: Description: Used for initial setup and after xrun.ini and project.txt
:: Usage: call :setinfolevel numb-level
:: Note: numb-level range 0-5
  if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  if defined funcgrp1 echo %funcendtext% %0
goto :eof

:funcend
:: Description: Used with func that out put files. Like XSLT, cct, command2file
:: Usage: call :funcend %%0
  set funcname=%~1
  set endfunc=%~2
  @if defined info1 if exist "%outfile%" echo.
  @if defined info1 if exist "%outfile%" echo Created: %outfile%
  @if defined outfile if not exist "%outfile%" color 06 & Echo Output file not created!
  @if defined info4 echo %funcendtext% %funcname%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & pause
goto :eof

:prince
:: Description: Make PDF using PrinceXML
:: Usage: call :prince [infile [outfile [css]]]
  call :infile %~1
  call :outfile %~2
  set css=%~3
  if defined css set css=-s "%css%"
  set curcommand=call "%prince%" %css% "%infile%" -o "%outfile%"
  if defined info3 echo %curcommand%
  %curcommand%
  call :funcend %0 funcgrp2
goto :eof