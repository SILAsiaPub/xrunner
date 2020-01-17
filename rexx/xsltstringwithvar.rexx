xsltstringwithvar:
-- Description: Modify batch variable for XSLT
-- Usage:  xsltstringwithvar(value-string)
-- Type: function
-- Date: 2020-01-15
  comma = ','
  len = length(arg(1))
  if pos('%',arg(1)) > 0 then
  	do
  		varst = "concat("
  		do j = 1 to len by 1
  			char = substr(arg(1),j,1)
  			postchar = substr(arg(1),j + 1,1)
  			upto = substr(arg(1),1,j)
        prechar = left(right(upto,2),1)
  			countp = countstr('%',upto) // 2
        /* say upto  countp prechar */
  			select
  				when char == '%' & j == 1 then varst = varst'$'   /* start with variable */
  				when char == '%' & j == len then nop /* end with variable */
  				when char == '%' & countp == 0 then varst = varst||comma  /* end of variable */
  				when char == '%' & countp == 1 then varst = varst"',$" /* start of variabl */
  				when j > 1 & j < len & char == '%' then nop /* end with variable */
  				when char \== '%' & j == 1 then varst = "'"char   /* open quote at start for text */
  				when char \== '%' & prechar == '%' & right(varst,1) \== '$' then varst = varst"'"char   /* text follows quote */
  				when j == len & char \== '%' then varst = varst||char||sq /* add quote to end if text */
  				otherwise varst = varst||char
  			end
  		end
  		varst = varst')'
  	end
  else 
  	do
  		varst = arg(1)
  	end
  call info 5 'i5' 'Out string:' varst
return varst

