@echo off
chcp 65001 >nul
color A
call :banner

echo.
echo ================================================
echo                 Choose an option:
echo ================================================
echo [ 1 ]  IP Lookup
echo [ 2 ]  Ping
echo [ 3 ]  Traceroute
echo [ 4 ]  DNS Lookup
echo [ 5 ]  Reverse DNS Lookup
echo [ 6 ]  Set ethernet IP to automatic
echo [ 7 ]  Set ethernet IP to static
echo [ 8 ]  Set ethernet IP to (options)
echo ================================================
echo.

set /p choice=Enter your choice (1-8):
echo.

if "%choice%"=="1" goto IPLookup
if "%choice%"=="2" goto Ping
if "%choice%"=="3" goto Traceroute
if "%choice%"=="4" goto DNSLookup
if "%choice%"=="5" goto ReverseDNSLookup
if "%choice%"=="6" goto SetIPAutomatic
if "%choice%"=="7" goto SetIPStatic
if "%choice%"=="8" goto SetIPOptions

echo Invalid choice. Please try again.
goto End

:IPLookup
echo Your IP
ipconfig /all
goto End

:Ping
echo Ping
ping 8.8.8.8
goto End

:Traceroute
echo Traceroute
tracert google.com
goto End

:DNSLookup
echo DNS Lookup
nslookup
goto End

:ReverseDNSLookup
echo Reverse DNS Lookup
nslookup 8.8.8.8
goto End

:SetIPAutomatic
echo Set ethernet IP to automatic
netsh interface ip set address "Ethernet" dhcp
netsh interface ip set dns "Ethernet" dhcp
netsh interface ip set gateway "" "Ethernet"
goto End

:SetIPStatic
echo Set ethernet IP to static
set /p interface="Enter the network interface name (e.g., Ethernet or Wi-Fi): "
set /p subnet="Enter the Subnet Mask (e.g., 255.255.255.0): "
set /p ip="Enter the IP address (e.g., 192.168.1.100): "
set /p gateway="Enter the Default Gateway (e.g., 192.168.1.1): "
set /p dns="Enter the Preferred DNS Server (e.g., 8.8.8.8): "
set /p alt_dns="Enter the Alternate DNS Server (e.g., 8.8.4.4): "

netsh interface ip set dns "%interface%" static %dns%
netsh interface ip set address "%interface%" static %ip% %subnet% %gate
way%
netsh interface ip add dns "%interface%" %alt_dns% index=2

echo.
echo The settings for the "%interface%" interface have been updated:
echo IP Address: %ip%
echo Subnet Mask: %subnet%
echo Default Gateway: %gateway%
echo Preferred DNS: %dns%
echo Alternate DNS: %alt_dns%
echo.
goto End

:SetIPOptions
echo.
set "csvPath=%~dp0manual_saved\ip.csv"
setlocal enabledelayedexpansion
set "count=0"
if not exist "%csvPath%" (
    echo CSV file not found: %csvPath%
    pause
    endlocal
    goto End
)
for /f "usebackq tokens=1,* delims=," %%A in ("%csvPath%") do (
    set /a count+=1
)
echo.
echo ================================================
echo               Select an Option:
echo ================================================
echo [ 1 ] Add New Configuration
set /a option=2
for /f "usebackq tokens=1,* delims=, skip=1" %%A in ("%csvPath%") do (
      echo [ !option! ] %%A
      set /a option+=1
)

echo ================================================
echo.
set /p choice=Enter your choice (1-%count%): 

:: Handle the user's choice
if "%choice%"=="1" (
    echo You selected "Add New Configuration".
    set /p name="Enter the name for the new configuration: "
    set /p ip="Enter the IP address (e.g., 192.168.1.100): "
    set /p subnet="Enter the Subnet Mask (e.g., 255.255.255.0): "
    set /p gateway="Enter the Default Gateway (e.g., 192.168.1.1): "
    set /p dns="Enter the Preferred DNS Server (e.g., 8.8.8.8): "
    set /p alt_dns="Enter the Alternate DNS Server (e.g., 8.8.4.4): "
    echo %name%,%ip%,%subnet%,%gateway%,%dns%,%alt_dns% >> "%csvPath%"
    echo.
    echo The new configuration has been added.
) else (
    set i=1
    :: TODO: add skip to make chosen configuration set   
    for /f "usebackq tokens=1,2,3,4,5,6 delims=," %%A in ("%csvPath%") do (
      if "!i!"=="!choice!" (
        echo You selected: %%A
        echo IP Address: %%B
        echo Subnet Mask: %%C
        echo Default Gateway: %%D
        echo Preferred DNS: %%E
        echo Alternate DNS: %%F
        set "interface=Ethernet"  :: Set your interface here if necessary
        netsh interface ip set address "%interface%" static %%B %%C %%D
        netsh interface ip set dns "%interface%" static %%E
        netsh interface ip add dns "%interface%" %%F index=2
      ) 
      set /a i=i+1
    )
  )   
endlocal
goto End

:End
pause
exit /b

:banner
echo.
echo.
echo                                                __   ____ ____
echo        ____ ___   ____ _ ____   __  __ ____ _ / /  /  _// __ \
echo       / __ `__ \ / __ `// __ \ / / / // __ `// /   / / / /_/ /
echo      / / / / / // /_/ // / / // /_/ // /_/ // /  _/ / / ____/
echo     /_/ /_/ /_/ \__;_//_/ /_/ \__,_/ \__;_//_/  /___//_/
echo.
echo.

echo     =========================================
echo         IPtool.bat - A simple IP tool for Windows
echo     =========================================
echo.
pause
