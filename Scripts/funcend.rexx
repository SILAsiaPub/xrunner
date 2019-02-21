funcend:
    parse ARG a b
    if info2 == "on"
        then
            if lines(outfile) > 0
                then say "Output:" outfile
                else say "Did not create:" outfile
        else nop
return

