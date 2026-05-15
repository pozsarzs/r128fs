@echo off
if "%1"=="CYCLE" goto START
%0 CYCLE rcopy rdir rstat rtype
goto END

:START
shift
:LOOP
if "%1"=="" goto END

masm %1.asm %1.obj %1.lst;
if errorlevel 1 goto END
link %1.obj+r128lib.obj+rdsclib.obj+rimglib.obj+rmemlib.obj;
if errorlevel 1 goto END
exe2bin %1.exe %1.com
if errorlevel 1 goto END
del %1chk.exe

shift
goto LOOP

:END
