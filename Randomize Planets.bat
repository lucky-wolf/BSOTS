@echo off

::Min and Max for RNG
set max=12
set min=1

:: Generate number between Min and Max
set /A rand=%random% %% (max - min + 1)+ min
echo Changing to %rand.script...

:: Copy new file
copy /Y "%~dp0Models\Planets\%rand%.script" "%~dp0Models\Planets\PlanetResources.script"

:: Output file used and pause
echo The current variation number: %rand%
pause
