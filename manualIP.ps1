function Show-Banner {
  $Host.UI.RawUI.ForegroundColor = "Green"
  Write-Host ""
  Write-Host ""
  Write-Host "                                                __   ____ ____"
  Write-Host "        ____ ___   ____ _ ____   __  __ ____ _ / /  /  _// __ \"
  Write-Host "       / __ \`__ \ / __ \`// __ \ / / / // __ \`// /   / / / /_/ /"
  Write-Host "      / / / / / // /_/ // / / // /_/ // /_/ // /  _/ / / ____/"
  Write-Host "     /_/ /_/ /_/ \__;_//_/ /_/ \__,_/ \__;_//_/  /___//_/"
  Write-Host ""
  Write-Host ""
  Write-Host "     ========================================="
  Write-Host "         IPtool.ps1 - A simple IP tool for Windows"
  Write-Host "     ========================================="
  Write-Host ""
  Read-Host "Press Enter to continue..."
}

function Get-IPLookup {
  Write-Host "Your IP"
  ipconfig /all
}

function Get-Ping {
  Write-Host "Ping"
  ping 8.8.8.8
}

function Get-Traceroute {
  Write-Host "Traceroute"
  tracert google.com
}

function Get-DNSLookup {
  Write-Host "DNS Lookup"
  nslookup
}

function Get-ReverseDNSLookup {
  Write-Host "Reverse DNS Lookup"
  nslookup 8.8.8.8
}

function Set-IPAutomatic {
  Write-Host "Set ethernet IP to automatic"
  netsh interface ip set address "Ethernet" dhcp
  netsh interface ip set dns "Ethernet" dhcp
  netsh interface ip set gateway "" "Ethernet"
}

function Set-IPStatic {
  Write-Host "Set ethernet IP to static"
  $interface = Read-Host "Enter the network interface name (e.g., Ethernet or Wi-Fi): "
  $subnet = Read-Host "Enter the Subnet Mask (e.g., 255.255.255.0): "
  $ip = Read-Host "Enter the IP address (e.g., 192.168.1.100): "
  $gateway = Read-Host "Enter the Default Gateway (e.g., 192.168.1.1): "
  $dns = Read-Host "Enter the Preferred DNS Server (e.g., 8.8.8.8): "
  $alt_dns = Read-Host "Enter the Alternate DNS Server (e.g., 8.8.4.4): "

  netsh interface ip set dns $interface static $dns
  netsh interface ip set address $interface static $ip $subnet $gateway
  netsh interface ip add dns $interface $alt_dns index=2

  Write-Host ""
  Write-Host "The settings for the '$interface' interface have been updated:"
  Write-Host "IP Address: $ip"
  Write-Host "Subnet Mask: $subnet"
  Write-Host "Default Gateway: $gateway"
  Write-Host "Preferred DNS: $dns"
  Write-Host "Alternate DNS: $alt_dns"
  Write-Host ""
}

function Set-IPOptions {
  $csvPath = "$PSScriptRoot\manual_saved\ip.csv"
  $count = 0

  if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file not found: $csvPath"
    Read-Host "Press Enter to continue..."
    return
  }

  $count = (Import-Csv $csvPath).Count

  Write-Host ""
  Write-Host "==============================================="
  Write-Host "               Select an Option:"
  Write-Host "==============================================="

  Write-Host "[ 1 ] Add New Configuration"

  $option = 2
  $configurations = Import-Csv $csvPath | Select-Object -Skip 1

  foreach ($config in $configurations) {
    Write-Host "[ $option ] $($config.Name)"
    $option++
  }

  Write-Host "==============================================="
  Write-Host ""

  $choice = Read-Host "Enter your choice (1-$count): "

  if ($choice -eq "1") {
    Write-Host "You selected 'Add New Configuration'."
    $name = Read-Host "Enter the name for the new configuration: "
    $ip = Read-Host "Enter the IP address (e.g., 192.168.1.100): "
    $subnet = Read-Host "Enter the Subnet Mask (e.g., 255.255.255.0): "
    $gateway = Read-Host "Enter the Default Gateway (e.g., 192.168.1.1): "
    $dns = Read-Host "Enter the Preferred DNS Server (e.g., 8.8.8.8): "
    $alt_dns = Read-Host "Enter the Alternate DNS Server (e.g., 8.8.4.4): "

    $newConfig = [PSCustomObject]@{
      Name = $name
      IP = $ip
      Subnet = $subnet
      Gateway = $gateway
      DNS = $dns
      AltDNS = $alt_dns
    }

    $newConfig | Export-Csv -Path $csvPath -Append -NoTypeInformation

    Write-Host ""
    Write-Host "The new configuration has been added."
  }
  else {
    $i = 1

    foreach ($config in $configurations) {
      if ($i -eq $choice) {
        Write-Host "You selected: $($config.Name)"
        Write-Host "IP Address: $($config.IP)"
        Write-Host "Subnet Mask: $($config.Subnet)"
        Write-Host "Default Gateway: $($config.Gateway)"
        Write-Host "Preferred DNS: $($config.DNS)"
        Write-Host "Alternate DNS: $($config.AltDNS)"

        $interface = "Ethernet"  # Set your interface here if necessary
        netsh interface ip set address $interface static $config.IP $config.Subnet $config.Gateway
        netsh interface ip set dns $interface static $config.DNS
        netsh interface ip add dns $interface $config.AltDNS index=2

        break
      }

      $i++
    }
  }
}

Show-Banner

Write-Host ""
Write-Host "==============================================="
Write-Host "             Choose an option:"
Write-Host "==============================================="
Write-Host "[ 1 ]  IP Lookup"
Write-Host "[ 2 ]  Ping"
Write-Host "[ 3 ]  Traceroute"
Write-Host "[ 4 ]  DNS Lookup"
Write-Host "[ 5 ]  Reverse DNS Lookup"
Write-Host "[ 6 ]  Set ethernet IP to automatic"
Write-Host "[ 7 ]  Set ethernet IP to static"
Write-Host "[ 8 ]  Set ethernet IP to (options)"
Write-Host "==============================================="
Write-Host ""

$choice = Read-Host "Enter your choice (1-8): "

Write-Host ""

switch ($choice) {
  "1" { Get-IPLookup }
  "2" { Get-Ping }
  "3" { Get-Traceroute }
  "4" { Get-DNSLookup }
  "5" { Get-ReverseDNSLookup }
  "6" { Set-IPAutomatic }
  "7" { Set-IPStatic }
  "8" { Set-IPOptions }
  default { Write-Host "Invalid choice. Please try again." }
}

Read-Host "Press Enter to exit..."