
iniline2var:
-- Description: Sets variables from one section
-- Usage: call :variableset line sectionget
  if (info4 == on) then say funcstarttext arg()
  parse arg line, setionget
  parse var line vname '=' value
  say line
  say setionget
  vname = "'"value"'"
  if sectionstart == 'on' then
    do
      if left(1,line) == "[" and line <> "[" sectionget "]" then
        do
          if info4 == "on" then say funcendtext %0
          exit
        end
    end; else if (line == sectionget) then 
    do 
    	sectionstart = 'on'
    	say 'section found ' setionget 
    	exit
    end
  -- if line == "[" sectionstart = &goto :eof
  -- if not defined sectionstart @if defined info4 echo %funcendtext% %0
  -- if not defined sectionstart goto :eof
  -- if defined sectionstart %line%
  -- utreturn=utreturn, line
  return vname
  if info4 = 'on' then say funcendtext %0

