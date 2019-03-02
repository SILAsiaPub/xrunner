set pauseatend=%4
if exist tasks.rexx del tasks.rexx
rexx xrun.rexx %*
if defined pauseatend pause
