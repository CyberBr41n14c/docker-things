#!/usr/bin/bash
echo //
echo //  Nexpose Universal Crack -ZEN
echo //
if [ "$EUID" -ne 0 ]
  then echo "Please run as root (so we can stop the service, replace files, etc)"
  exit
fi
echo =[ Stopping the Nexpose service.. ]============================================
systemctl stop nexposeconsole
echo =[ Checking service status.. ]=================================================
systemctl is-active --quiet nexposeconsole && (
echo .
echo Cannot install crack since "Nexpose Security Console" nexposeconsole service failed to stop.
echo You\'ll want to kill this manually somehow.
echo Running  systemctl status nexposeconsole
systemctl status nexposeconsole
exit
)

echo =[ Backing up existing jars to a 7z file.. ]===================================
chmod +x 7zz
./7zz a backup_$( date +%Y_%m_%d ).7z /opt/rapid7/nexpose/nse/lib/nse.jar /opt/rapid7/nexpose/shared/lib/nxshared.jar &>/dev/null
echo =[ Injecting cracked class files into the jars.. ]=============================
./7zz a -aoa /opt/rapid7/nexpose/shared/lib/nxshared.jar META-INF/CN_RAPID.RSA com/rapid7/nexpose/license/LicenseManager.class com/rapid7/nexpose/license/NexposeLicense.class &>/dev/null
./7zz a -aoa /opt/rapid7/nexpose/nse/lib/nse.jar META-INF/CN_RAPID.RSA &>/dev/null
echo =[ Restarting the Nexpose service.. ]==========================================
systemctl start nexposeconsole
echo =[ Done. ]=====================================================================
echo
echo Now open https://localhost:3780 to access the web interface
echo   go to admin section and add license from file and use enclosed lic file
echo
echo example:
echo xdg-open https://localhost:3780
echo
#sensible-browser https://localhost:3780
#x-www-browser https://localhost:3780
#gnome-open https://localhost:3780
