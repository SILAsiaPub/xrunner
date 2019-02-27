/* rexx unit test framework

   concatenate these files:

   t1 test-script t2 rexx-file-to-test t3 > t.rexx

   then execute t.rexx

   this file is t1
*/

count = 0
passed = 0
failed = 0
contextdesc = ''
checkresult. = ''
divider = '----------------------------------------'
spacer = ' '
/* test script to demonstrate the rexx unit test framework */

context('Checking the iniline2var function')
check( 'passing ini start section',	expect( iniline2var( '[find]',  '[find]' ),  'to be',      '' ))
check( 'passing ini line',        	expect( iniline2var( 'val=something',  '[find]' ),  'to be',      'something' ))/* rexx unit test framework

   concatenate these files:

   t1 test-script t2 rexx-file-to-test t3 > t.rexx

   then execute t.rexx

   this file is t2
*/

/* display the test results */

say divider
say contextdesc
say spacer

do i = 1 to checkresult.0
    say checkresult.i
end    

say spacer

text = counts()
do i = 1 to text.0
    say text.i
end

say divider

exit

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

/* rexx unit test framework

   concatenate these files:

   t1 test-script t2 rexx-file-to-test t3 > t.rexx

   then execute t.rexx

   this file is t3
*/

/* functions for the test framework */

context:
parse arg desc
contextdesc = desc
return ''


check:
count = count + 1
checkresult.0 = count
parse arg description, assertion
checkresult.count = count || '. ' || assertion || ' ' || description
return ''

expect:
parse arg actual, op, expected
if op == 'to be' then return report(actual, op, expected, actual == expected)
if op == 'not to be' then return report(actual, op, expected, actual \== expected)

report:
parse arg actual, op, expected, res
lineout = ''
select
    when res == 0 then do
         failed = failed + 1
         lineout = '*** FAILED: Expected ' || expected || ' but got ' || actual
         end
    when res == 1 then do
         passed = passed + 1
         lineout = '    PASSED:'
         end   
end     
return lineout    

counts:
text.0 = 3
text.1 = count ' checks were executed'
text.2 = passed ' checks passed'
text.3 = failed ' checks failed'
return text

