@echo off


:start
color f0
echo                                          -ERROR-
echo.
echo the app [name] try's to acces hardware/software that is currently in use
echo by [name].
echo.
echo.
echo THIS CAN BE CRITICAL!
echo.
echo you can still try to use your system.
echo NOTE: if you proceed it can be possible that your software gives an error!

echo do you want to try (y/n)
echo no= shutdown system


echo.
set /p opti=C:\
if "%opti%" == "y" goto yes
if "%opti%" == "n" goto ex
if "%opti%" == "Y" goto yes
if "%opti%" == "N" goto ex
goto error



:yes
color 08
cls
echo error command line can't be loaded!
pause
exit

:ex
exit

:error
color f0
echo you must type y or n
echo.
set /p opti=C:\
if "%opti%" == "y" goto yes
if "%opti%" == "n" goto ex
if "%opti%" == "Y" goto yes
if "%opti%" == "N" goto ex
goto error
