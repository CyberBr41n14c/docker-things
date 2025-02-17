@echo off & setlocal
echo ############################################################################
echo ## Nexpose Universal Crack windows  Zen  https://cyberarsenal.org/pwn3rzs ##
echo ############################################################################
set /a _Debug=0
cd /d %~dp0

::check required files are in the same dir
for %%i in ("7za.exe" "com\rapid7\nexpose\license\LicenseManager.class" "com\rapid7\nexpose\license\NexposeLicense.class" "META-INF\CN_RAPID.RSA") do if not exist "%%i" echo %%i missing & goto :ending

:: Prompt to Run as administrator
Set "Variable=0" & if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
fsutil dirty query %systemdrive%  >nul 2>&1 && goto :(PrivOK)
If "%1"=="%Variable%" (echo. &echo. Please right-click on the file and select &echo. "Run as administrator". &echo. Press any key to exit. &pause>nul 2>&1& exit)
cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "%Variable%", "", "runas", 1 > "%temp%\getadmin.vbs"&cscript //nologo "%temp%\getadmin.vbs" & exit
:(PrivOK)
echo.
echo /// Checking and Stopping the Nexpose services
sc query "nexposeconsole" 2>nul|find /i "1060" >nul 2>&1 &&(
   echo   x  Nexpose service is not installed!
   echo   x  you need to install Nexpose before using this crack
   echo   x  exiting..
goto ending
)||(
  echo   o  service installed, let's stop it..
)
set b=0
:nexposeservice
:: try to stop it 8 times - why not - saw this someone maybe it is needed maybe not
set /a b=%b%+1
if %b% equ 8 (
   goto end1
)
echo   o  Stopping Nxpose services so we can crack in peace..
net stop "nexposeconsole" >nul 2>&1
taskkill /im nexserv.exe /f >nul 2>&1
echo   o  Checking the Nexpose service status.
sc query nexposeconsole 2>nul|find /i "STOPPED" >nul 2>&1 &&(
   echo   o  service is not running. good! let's continue..
)||(
  echo   x  service still running, trying again to stop it..
  goto nexposeservice
)
goto crackit
:end1
echo   x  Cannot install crack since "Nexpose Security Console" (nexposeconsole) service failed to stop.
echo   x  Kill it manually (nexserv.exe) then run script again.
echo   x  We did try to kill the process.. apparently something is wrong..
echo   x  note: SOMETIMES just wait a few seconds and run this batch file again works..
goto ending

:crackit
echo.
echo /// Installing crack files..
echo   o Making a backup of existing jars
set tag=%DATE:~-4%-%DATE:~7,2%-%DATE:~4,2%
7za.exe a backup_original_jars_%tag%.7z "%PROGRAMFILES%\rapid7\nexpose\nse\lib\nse.jar" "%PROGRAMFILES%\rapid7\nexpose\shared\lib\nxshared.jar" >nul 2>&1 
echo   o Injecting cracked class files into jars
7za.exe a -aoa "%PROGRAMFILES%\rapid7\nexpose\shared\lib\nxshared.jar" META-INF/CN_RAPID.RSA com/rapid7/nexpose/license/LicenseManager.class com/rapid7/nexpose/license/NexposeLicense.class >nul 2>&1 
7za.exe a -aoa "%PROGRAMFILES%\rapid7\nexpose\nse\lib\nse.jar" META-INF/CN_RAPID.RSA >nul 2>&1
:Start

echo.
echo /// Starting Nexpose service again
echo.
net start nexposeconsole >nul 2>&1
echo /// Launching default web browser to Nexpose start page
echo.
START "" "https://localhost:3780"
echo   o done!
echo   o Now open https://localhost:3780 to access the web interface
echo   o go to admin section and add license from file and use enclosed lic file
:ending
echo.
pause
