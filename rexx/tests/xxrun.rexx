#!/usr/local/bin/rexx
iniline2var:
-- Description: Sets variables from one section
-- Usage: call :variableset line sectionget
  if (info4 == on) then say funcstarttext arg()
  parse arg line, setionget
  if line == "[" sectionget "]" then sectionstart = 'on'; exit
  if sectionstart == 'on' then
    do
      if left(1,line) == "[" and line <> "[" sectionget "]" then
        do
          if info4 == "on" then say funcendtext %0
          exit
        end
    end; else if
  if line == "[" sectionstart = &goto :eof
  if not defined sectionstart @if defined info4 echo %funcendtext% %0
  if not defined sectionstart goto :eof
  if defined sectionstart %line%
  utreturn=utreturn, line
  if info4 = 'on' then say funcendtext %0

