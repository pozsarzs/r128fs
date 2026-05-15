@echo off
if "%1"=="CYCLE" goto START
%0 CYCLE rdsc rimg rmem
goto END

:START
shift
:LOOP
if "%1"=="" goto NEXT

del r128.lib

masm %1lib.asm %1lib.obj %1lib.lst;
if errorlevel 1 goto END
lib r128.lib +%1lib.obj r128.lst;
masm %1chk.asm %1chk.obj %1chk.lst;
if errorlevel 1 goto END
link %1chk.obj+%1lib.obj;
if errorlevel 1 goto END
exe2bin %1chk.exe %1chk.com
if errorlevel 1 goto END
del %1chk.exe

shift
goto LOOP

:NEXT
masm r128lib.asm r128lib.obj r128lib.lst;

:END
