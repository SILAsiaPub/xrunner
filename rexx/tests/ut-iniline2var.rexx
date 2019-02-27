/* test script to demonstrate the rexx unit test framework */

context('Checking the iniline2var function')
check( 'passing ini start section',	expect( iniline2var( '[find]',  '[find]' ),  'to be',      '' ))
check( 'passing ini line',        	expect( iniline2var( 'val=something',  '[find]' ),  'to be',      'something' ))