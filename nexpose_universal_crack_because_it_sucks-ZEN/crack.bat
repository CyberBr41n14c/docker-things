@echo off
:: misc comments
cd /d %~dp0

:: Prompt to Run as administrator
Set "Variable=0" & if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
fsutil dirty query %systemdrive%  >nul 2>&1 && goto :(Privileges_got)
If "%1"=="%Variable%" (echo. &echo. Please right-click on the file and select &echo. "Run as administrator". &echo. Press any key to exit. &pause>nul 2>&1& exit)
cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "%~0", "%Variable%", "", "runas", 1 > "%temp%\getadmin.vbs"&cscript //nologo "%temp%\getadmin.vbs" & exit
:(Privileges_got)
echo "[We have admin privs now]"
:: Checking and Stopping the Nexpose services
set b=0
:nexposeconsole
set /a b=%b%+1
if %b% equ 3 (
   goto end1
) 
net stop nexposeconsole
echo Checking the nexposeconsole service status.
sc query nexposeconsole | findstr /I /C:"STOPPED" 
if not %errorlevel%==0 ( 
    goto nexposeconsole 
) 
goto crackit
:end1
echo.
echo Cannot install crack since "Nexpose Security Console" (nexposeconsole) service failed to stop.
echo Kill it manually (nexserv.exe) then continue (otherwise hit ctrl-c because this will all fail)
echo.
pause

:crackit
echo =[ entering crackit routine ]===================================================
if not exist "c:\Program Files\7-Zip\7z.exe" ( 
    echo "\Program Files\7-Zip\7z.exe" missing, this script is not for public release, my local machine has it...
    pause
	goto ending
)
:: backup existing files
echo =[ backing up existing jars to a zip file ]=====================================
set tag=%DATE:~-4%-%DATE:~7,2%-%DATE:~4,2%
"\Program Files\7-Zip\7z.exe" a backup_original_jars_%tag%.7z "c:\program files\rapid7\nexpose\nsc\lib\nsc.jar" "c:\program files\rapid7\nexpose\nse\lib\nse.jar" "c:\program files\rapid7\nexpose\shared\lib\nxshared.jar" "c:\program files\rapid7\nexpose\shared\lib\r7shared.jar" "c:\program files\rapid7\nexpose\shared\lib\r7static.jar"
:: inject my replacement class files into the jars
echo =[ injecting cracked class files into the jars ]================================
rem "\Program Files\7-Zip\7z.exe" a -aoa "c:\program files\rapid7\nexpose\nsc\lib\nsc.jar" META-INF/CN_RAPID.RSA com/rapid7/nexpose/nsc/exposure/analytics/ExposureAnalyticsService.class
"\Program Files\7-Zip\7z.exe" a -aoa "c:\program files\rapid7\nexpose\shared\lib\nxshared.jar" META-INF/CN_RAPID.RSA com/rapid7/nexpose/license/LicenseManager.class com/rapid7/nexpose/license/NexposeLicense.class
"\Program Files\7-Zip\7z.exe" a -aoa "c:\program files\rapid7\nexpose\nse\lib\nse.jar" META-INF/CN_RAPID.RSA 
rem "\Program Files\7-Zip\7z.exe" a -aoa "c:\program files\rapid7\nexpose\shared\lib\r7shared.jar" META-INF/CN_RAPID.RSA 
rem "\Program Files\7-Zip\7z.exe" a -aoa "c:\program files\rapid7\nexpose\shared\lib\r7static.jar" META-INF/CN_RAPID.RSA 
echo =[ done ]=======================================================================
:Start
echo If you don't break here, this script will run the nexpose service again...
pause
net start nexposeconsole

:ending
