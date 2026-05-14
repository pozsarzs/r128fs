@echo off
if "%1"=="CYCLE" goto START
%0 CYCLE rdsc rimg rmem
goto END

:START
shift
:LOOP
if "%1"=="" goto END

masm %1lib.asm %1lib.obj %1lib.lst;
if errorlevel 1 goto END
masm %1chk.asm %1chk.obj %1chk.lst;
if errorlevel 1 goto END
link %1chk.obj+%1lib.obj;
if errorlevel 1 goto END
exe2bin %1chk.exe %1chk.com
if errorlevel 1 goto END
del %1chk.exe

shift
goto LOOP

:END
