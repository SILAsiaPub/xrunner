@echo off
set pauseatend=%4
if exist tasks.rexx del tasks.rexx
rexx xrun.rexx %*  2> xrunrx.log
if defined pauseatend pause
