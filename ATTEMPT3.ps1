
# Network Variables
$ethipaddress = '192.168.55.3' #STATIC IP ADDRESS VAN DE SERVER
$ethprefixlength = '24' # AANGEGEVEN CIDR NOTATIE SUBNETMASK '255.255.255.0' (16/255.255.0.0 classe B) (8/255.0.0.0 classe A)
$ethdefaultgw = '192.168.55.1' #DEFAULT GATEWAY ROUTER IP ADDRESS
$ethdns = '192.168.55.5' #OMDAT DIT ONZE DNS SERVER WORDT GEVEN WE DE STATIC IP ADDRESS VAN ONZE SERVER HIER IN
$globalsubnet = '192.168.55.5/24' # GLOBAL SUBNET WORDT GEBRUIKT VOOR DNS REVERSE RECORD EN AD SITES EN SERVICE SUBNETS
$subnetlocation = 'Belgium'
$sitename = 'ProjectWilliam.local'

#ACTIVE DIRECTORY DOMAIN
$domainname = 'ProjectWilliam.local' 

#REMOTE DESKTOP ENABLE/DISABLE
$enablerdp = 'yes' # ENABLE IS YES / DISABLE IS NO

#IE ENCHANCED SECURITY 
$disableiesecconfig = 'yes' # IE ENCHANCED SECURITY UITSCHAKELEN MET YES EN INSHAKELEN MET NO AANGERADEN! 

# HOSTNAME/COMPUTERNAAM WIJZIGEN
$computername = 'SERVERATT7' #NAAM VAN COMPUTER/SERVER

# NTP Variables
$ntpserver1 = '0.be.pool.ntp.org'
$ntpserver2 = '1.be.pool.ntp.org'

# DNS Variables
$reversezone = 'ProjectWilliam.local'

# HET MOGELIJK TE MAKEN VAN TIMESTAMP FUNCTIE OM TIJD BIJ TE HOUDEN VIA LOGFILE
Function Timestamp
    {
    $Global:timestamp = Get-Date -Format "dd-MM-yyy_hh:mm:ss"
    }

#AANMAKEN VAN LOGFILE LOCATIE
$logfile = "C:\ADDS_LOG\ADDS_LOG.txt"

#AANMAKEN VAN LOGFILE ZELF DIE WE GAAN GEBRUIKEN ALS CHECKMARK OM COMPUTER IN 3 STAPPEN TE LATEN HERSTARTEN
Write-Host "-= Get timestamp =-" -ForegroundColor Green

Timestamp

IF (Test-Path $logfile)
    {
    Write-Host "-= Logfile Exists =-" -ForegroundColor Yellow
    }

ELSE {

Write-Host "-= Creating Logfile =-" -ForegroundColor Green

Try{
   New-Item -Path 'C:\ADDS_LOG' -ItemType Directory
   New-Item -ItemType File -Path $logfile -ErrorAction Stop | Out-Null
   Write-Host "-= The file $($logfile) has been created =-" -ForegroundColor Green
   }
Catch{
     Write-Warning -Message $("Could not create logfile. Error: "+ $_.Exception.Message)
     Break;
     }
}
#CHECKSUMS VAN SCRIPT VIA LOGFILE DIE NET IS AANGEMAAKT zie C:\ADDS_LOG\ADDS_LOG.txt

$firstcheck = Select-String -Path $logfile -Pattern "1-Basic-Server-Config-Complete"

IF (!$firstcheck) {

# TIJD INGEVEN IN LOGFILE
Write-Host "-= 1-Basic-Server-Config-Complete, does not exist =-" -ForegroundColor Yellow

Timestamp
Add-Content $logfile "$($Timestamp) - Starting Active Directory Script"

## BASIC NETWORK CONFIGURATIE
# NETWORK AANMAKEN
Timestamp
Try{
    New-NetIPAddress -IPAddress $ethipaddress -PrefixLength $ethprefixlength -DefaultGateway $ethdefaultgw -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ErrorAction Stop | Out-Null
    Set-DNSClientServerAddress -ServerAddresses $ethdns -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ErrorAction Stop
    Write-Host "-= IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns) =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - IP Address successfully set to $($ethipaddress), subnet $($ethprefixlength), default gateway $($ethdefaultgw) and DNS Server $($ethdns)"
   }
Catch{
     Write-Warning -Message $("Failed to apply network settings. Error: "+ $_.Exception.Message)
     Break;
     }

# REMOTE DESKTOP UITSCHAKLEN OF INSCHAKELEN 
Timestamp
Try{
    IF ($enablerdp -eq "yes")
        {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0 -ErrorAction Stop
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
        Write-Host "-= RDP Successfully enabled =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - RDP Successfully enabled"
        }
    }
Catch{
     Write-Warning -Message $("Failed to enable RDP. Error: "+ $_.Exception.Message)
     Break;
     }

IF ($enablerdp -ne "yes")
    {
    Write-Host "-= RDP remains disabled =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - RDP remains disabled"
    }

# INSCHAKELEN OF UITSCHAKELEN IE ENHANCEDSECURTIY
Timestamp 
Try{
    IF ($disableiesecconfig -eq "yes")
        {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0 -ErrorAction Stop
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0 -ErrorAction Stop
        Write-Host "-= IE Enhanced Security Configuration successfully disabled for Admin and User =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - IE Enhanced Security Configuration successfully disabled for Admin and User"
        }
    }
Catch{
     Write-Warning -Message $("Failed to disable Ie Security Configuration. Error: "+ $_.Exception.Message)
     Break;
     }

If ($disableiesecconfig -ne "yes")
    {
    Write-Host "-= IE Enhanced Security Configuration remains enabled =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - IE Enhanced Security Configuration remains enabled"
    }

# HOSTNAME DOORGEVEN AAN SERVER
Timestamp
Try{
    Rename-Computer -ComputerName $env:computername -NewName $computername -ErrorAction Stop | Out-Null
    Write-Host "-= Computer name set to $($computername) =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Computer name set to $($computername)"
    }
Catch{
     Write-Warning -Message $("Failed to set new computer name. Error: "+ $_.Exception.Message)
     Break;
     }

# DOORGEVEN AAN LOGFILE DAT DEEL 1 VAN SCRIPT GEDAAN IS
Timestamp
Add-Content $logfile "$($Timestamp) - 1-Basic-Server-Config-Complete, starting script 2 =-"

# REBOOTEN VAN PC OM AANGEMAAKTE SETTINGS 
Timestamp
Write-Host "-= Save all your work, computer rebooting in 30 seconds =-"  -ForegroundColor White -BackgroundColor Red
Sleep 30

Try{
    Restart-Computer -ComputerName $env:computername -ErrorAction Stop
    Write-Host "-= Rebooting Now!! =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Rebooting Now!!"
	Break;
    }
Catch{
     Write-Warning -Message $("Failed to restart computer $($env:computername). Error: "+ $_.Exception.Message)
     Break;
     }

} # Close 'IF (!$firstcheck)'

# NA HET RESTARTEN ZAL SCRIPT NAKIJKEN IN LOGFILE WAAR WE STAAN EN DAN BEGINNEN AAN DEEL 2
$secondcheck1 = Get-Content $logfile | Where-Object { $_.Contains("1-Basic-Server-Config-Complete") }

IF ($secondcheck1)
    {
    $secondcheck2 = Get-Content $logfile | Where-Object { $_.Contains("2-Build-Active-Directory-Complete") }

    IF (!$secondcheck2)
        {

        ## DOWNLOADEN EN AANMAKEN VAN AD ##

        Timestamp
        
        #-------------
        #- Variables -                                         -
        #-------------

        # AANGEVEN VAN PASSWOORD DIE U WILT ALS ADMIN VAN DEZE ADDS ( POP UP KOMT BIJ HET BEGINNEN VAN DEEL 2 DIE PASSWOORD ZAL AANVRAGEN )
        $dsrmpassword = Read-Host "Enter Directory Services Restore Password" -AsSecureString

        #------------
        #- Settings -
        #------------

        # HET INSTALLEREN VAN DE AD ZELF
        Timestamp
        Try{
            Write-Host "-= Active Directory Domain Services installing =-" -ForegroundColor Yellow
            Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
            Write-Host "-= Active Directory Domain Services installed successfully =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Active Directory Domain Services installed successfully"
            }
        Catch{
            Write-Warning -Message $("Failed to install Active Directory Domain Services. Error: "+ $_.Exception.Message)
            Break;
            }

        # CONFIGURATIE VAN DE ADDS
        Timestamp
        Try{
            Write-Host "-= Configuring Active Directory Domain Services =-" -ForegroundColor Yellow
            Install-ADDSForest -DomainName $domainname -InstallDNS -ErrorAction Stop -NoRebootOnCompletion -SafeModeAdministratorPassword $dsrmpassword -Confirm:$false | Out-Null
            Write-Host "-= Active Directory Domain Services configured successfully =-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Active Directory Domain Services configured successfully"
            }
        Catch{
            Write-Warning -Message $("Failed to configure Active Directory Domain Services. Error: "+ $_.Exception.Message)
            Break;
            }

        # TWEEDE COMPLETION DOORGEVEN AAN HET LOGFILE
        Timestamp
        Add-Content $logfile "$($Timestamp) - 2-Build-Active-Directory-Complete, starting script 3 =-"

        # PC RESTART VOOR ADDS
        Write-Host "-= Save all your work, computer rebooting in 30 seconds =-" -ForegroundColor White -BackgroundColor Red
        Sleep 30

        Try{
            Restart-Computer -ComputerName $env:computername -ErrorAction Stop
            Write-Host "Rebooting Now!!" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - Rebooting Now!!"
            Break;
            }
        Catch{
            Write-Warning -Message $("Failed to restart computer $($env:computername). Error: "+ $_.Exception.Message)
            Break;
            }
        } # Close 'IF ($secondcheck2)'
    }# Close 'IF ($secondcheck1)'




# TWEEDE KEER NAKIJKEN VAN LOGFILE OM PROGRESS NA TE ZIEN
$thirdcheck = Get-Content $logfile | Where-Object { $_.Contains("2-Build-Active-Directory-Complete") }

## DNS SETTINGS AANPASSEN OP ADDS##

#------------
#- Settings -
#------------

# TOEVOEGEN VAN EEN DNS REVERSE LOOKUP
Timestamp
Try{
    Add-DnsServerPrimaryZone -NetworkId $globalsubnet -DynamicUpdate Secure -ReplicationScope Domain -ErrorAction Stop
    Write-Host "-= Successfully added in $($globalsubnet) as a reverse lookup within DNS =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully added $($globalsubnet) as a reverse lookup within DNS"
    }
Catch{
     Write-Warning -Message $("Failed to create reverse DNS lookups zone for network $($globalsubnet). Error: "+ $_.Exception.Message)
     Break;
     }

# ADNS SCAVENGING MOGELIJKHEID TOEVOEGEN
Write-Host "-= Set DNS Scavenging =-" -ForegroundColor Yellow

Timestamp
Try{
    Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $domainname -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $reversezone -Aging $true -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00 -Verbose -ErrorAction Stop
    Add-Content $logfile "$($Timestamp) - DNS Scavenging Complete"
    }
Catch{
     Write-Warning -Message $("Failed to DNS Scavenging. Error: "+ $_.Exception.Message)
     Break;
     }

Get-DnsServerScavenging

Write-Host "-= DNS Scavenging Complete =-" -ForegroundColor Green

# AD SITES EN SERVICES AANMAKEN
Timestamp
Try{
    New-ADReplicationSubnet -Name $globalsubnet -Site "Default-First-Site-Name" -Location $subnetlocation -ErrorAction Stop
    Write-Host "-= Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully added Subnet $($globalsubnet) with location $($subnetlocation) in AD Sites and Services"
    }
Catch{
     Write-Warning -Message $("Failed to create Subnet $($globalsubnet) in AD Sites and Services. Error: "+ $_.Exception.Message)
     Break;
     }

# HERNOEMEN VAN DNS SITES
Timestamp
Try{
    Get-ADReplicationSite Default-First-Site-Name | Rename-ADObject -NewName $sitename -ErrorAction Stop
    Write-Host "-= Successfully renamed Default-First-Site-Nameto $sitename in AD Sites and Services =-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - Successfully renamed Default-First-Site-Nameto $sitename in AD Sites and Services"
    }
Catch{
     Write-Warning -Message $("Failed to rename site in AD Sites and Services. Error: "+ $_.Exception.Message)
     Break;
     }

# NTP SETTINGS TOEVOEGEN 

Timestamp

$serverpdc = Get-AdDomainController -Filter * | Where {$_.OperationMasterRoles -contains "PDCEmulator"}

IF ($serverpdc)
    {
    Try{
        Start-Process -FilePath "C:\Windows\System32\w32tm.exe" -ArgumentList "/config /manualpeerlist:$($ntpserver1),$($ntpserver2) /syncfromflags:MANUAL /reliable:yes /update" -ErrorAction Stop
        Stop-Service w32time -ErrorAction Stop
        sleep 2
        Start-Service w32time -ErrorAction Stop
        Write-Host "-= Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2) =-" -ForegroundColor Green
        Add-Content $logfile "$($Timestamp) - Successfully set NTP Servers: $($ntpserver1) and $($ntpserver2)"
        }
    Catch{
          Write-Warning -Message $("Failed to set NTP Servers. Error: "+ $_.Exception.Message)
     Break;
     }
    }

# DOORGEVEN AAN LOGFILE DAT HET SCRIPT COMPLEET IS

Timestamp
Write-Host "-= 3-Finalize-AD-Config Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - 3-Finalize-AD-Config Complete"
Write-Host "-= Active Directory Script Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - Active Directory Script Complete"
