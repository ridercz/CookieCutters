@ECHO OFF

ECHO # This file was autogenerated with genvars.cmd > cc.scad.vars
ECHO # Do not edit this file directly, as it will be overwritten >> cc.scad.vars

FOR %%I IN (SVG\*.svg) DO ECHO %%~nI: image_file = "SVG/%%~nI.svg"; >> cc.scad.vars
