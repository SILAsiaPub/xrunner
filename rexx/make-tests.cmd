@echo off
Echo Creating testing files for functions
set thispath=%CD%
set pathdown=%thispath:\rexx\rexx=\rexx%
call :detectdateformat
call :time
call :date
rem if exist "%pathdown%\func.rexx" move /y "%pathdown%\func.rexx" "%cd%\old\%curyyyymmdd%%%curhhmmss%%func.rexx"
setlocal enabledelayedexpansion
call :loopfiles *.rexx :maketest test-header testing
@echo off
rem copy /y "testing\rexxini.rexx" "C:\programs\xrunner"
rem copy /y "testing\rexxini.rexx" "D:\All-SIL-Publishing\github-SILAsiaPub\xrunner\trunk"

pause
goto :eof

:maketest
  set file=%~1
  call :dependson "%file%"
  set headerpath=%~2
  set outpath=%~3
  if exist "%headerpath%\%file%" (
    copy /y %headerpath%\%file%+%file%%dependency% "%outpath%\ut-%file%"
  )
goto :eof

:dependson
  set dp=%~1
  set dependency=
  if '%dp%' == 'writexslt.rexx' set dependency=+listseparator.rexx+rxstringwithvar.rexx
  if '%dp%' == 'inisection.rexx' set dependency=+nameext.rexx+rexxvar.rexx+rexxvarwithvar.rexx+rexxtasks.rexx+writexslt.rexx+stringwithvar.rexx
  if '%dp%' == 'outputfile.rexx' set dependency=+linecopy.rexx
  if '%dp%' == 'outfile.rexx' set dependency=+checkdir.rexx
  if '%dp%' == 'infile.rexx' set dependency=+fatal.rexx
  if '%dp%' == 'checkdir.rexx' set dependency=+drivepath.rexx
  if '%dp%' == 'xslt.rexx' set dependency=+infile.rexx+outfile.rexx+fatal.rexx+inccount.rexx+funcend.rexx+checkdir.rexx
  if '%dp%' == 'xsltstringwithvar.rexx' set dependency=+teststring.rexx
  if '%dp%' == 'rxstringwithvar.rexx' set dependency=+teststring.rexx
  if '%dp%' == 'xrunini.rexx' set dependency=+xsltstringwithvar.rexx
  if '%dp%' == 'projtxt.rexx' set dependency=+rexxvar.rexx+rxstringwithvar.rexx
  rem if '%dp%' == 'rexxini.rexx' set dependency=+writecmdtasks.rexx+writecmdvar.rexx+inisection.rexx+nameext.rexx+rexxvar.rexx+rexxvarwithvar.rexx+rexxtasks.rexx+writexslt.rexx+stringwithvar.rexx
  set dependency=%dependency%+info.rexx
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles file_specs sub_name [param[3-9]]
:: Depends on: appendnumbparam, last, taskgroup. Can also use any other function.
  @if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3" "%~4" "%~5" "%~6" "%~7" "%~8" "%~9"
  if defined fatal goto :eof
  set filespec=%~1
  set grouporfunc=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  set numbparam=
  set appendparam=
  if not defined grouporfunc echo Error: Missing func parameter[2]
  if not defined grouporfunc if defined info4 echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined filespec echo Error: Missing filespec parameter[1]
  if not defined filespec if defined info4 echo %funcendtext% %0 
  if not defined filespec goto :eof
  if not exist "%filespec%" echo Error: Missing source files
  if not exist "%filespec%" if defined info4 echo %funcendtext% %0 
  if not exist "%filespec%" goto :eof
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info3 set numbparam
  if defined info4 if defined comment echo %last%
  if not defined unittest (
    if "%grouporfunc:~0,1%" == ":" (
        FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO  call %grouporfunc% "%%s" %numbparam%
      ) else (
        FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO  call :taskgroup %grouporfunc% "%%s" %numbparam%
  )  
    )  
  )  
  set utreturn= %filespec%, %sub%, %numbparam%, %last%
  if defined unittest FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO call :unittestaccumulate "%%s" %sub% %numbparam%
  @if defined info4 echo %funcendtext% %0
goto :eof

:appendfile
:: Description: Appends one file to the end of another file.
:: Usage: call : appendfile filetoadd filetoappendto
  if defined fatal goto :eof
  @if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  type "%~1" >> "%~2"
  set utreturn=%~1, %~2
  @if defined info4 echo %funcendtext% %0
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

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Required variables: detectdateformat
:: Created: 2016-05-04
rem got this from: http://www.robvanderwoude.com/datetiment.php#IDate
  @if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
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
  set yyyy-mm-dd=%fyyyy%-%fmm%-%fdd%
  set curyyyymmdd=%fyyyy%%fmm%%fdd%
  set curyymmdd=%fyyyy:~2%%fmm%%fdd%
  set curUSdate=%fmm%/%fdd%/%fyyyy%
  set curAUdate=%fdd%/%fmm%/%fyyyy%
  set curyyyy=%fyyyy%
  set curyy=%fyyyy:~2%
  set curmm=%fmm%
  set curdd=%fdd%
  @if defined info4 echo %funcendtext% %0
goto :eof

:detectdateformat
:: Description: Get the date format from the Registery: 0=US 1=AU 2=iso
:: Usage: call :detectdateformat
  @if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  set KEY_DATE="HKCU\Control Panel\International"
  rem get dateformat number
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v iDate`) DO set dateformat=%%A
  rem get the date separator: / or -
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sDate`) DO set dateseparator=%%A
  rem get the time separator: : or ?
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sTime`) DO set timeseparator=%%A
  rem set project log file name by date
  @if defined info4 echo %funcendtext% %0
goto :eof

:time
:: Description: Retrieve time in several shorter formats than %time% provides
:: Usage: call :time
:: Created: 2016-05-05
  @if defined info4 echo %funcstarttext% %0 "%~1" "%~2" "%~3"
  FOR /F "tokens=1-4 delims=:%timeseparator%." %%A IN ("%time%") DO (
    set curhhmm=%%A%%B
    set curhhmmss=%%A%%B%%C
    set curisohhmmss=%%A-%%B-%%C
    set curhh_mm=%%A:%%B
    set curhh_mm_ss=%%A:%%B:%%C
  )
  @if defined info4 echo %funcendtext% %0
goto :eof

