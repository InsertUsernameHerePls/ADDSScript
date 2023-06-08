### ADDS SCRIPT VOOR AD , DNS , DHCP ###
# NETWERK VARIABLES
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
$disableiesecconfig = 'no' # IE ENCHANCED SECURITY UITSCHAKELEN MET YES EN INSHAKELEN MET NO AANGERADEN! 

# HOSTNAME/COMPUTERNAAM WIJZIGEN
$computername = 'ADDSSERVERWILLIAM' #NAAM VAN COMPUTER/SERVER

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
Write-Host "-=<<< RETRIEVING TIMESTAMP >>>=-" -ForegroundColor Green

Timestamp

IF (Test-Path $logfile)
    {
    Write-Host "-=<<< LOGFILE ENDURES >>>=-" -ForegroundColor Yellow
    }

ELSE {

Write-Host "-=<<< COGITATING LOGFILE >>>=-" -ForegroundColor Green

Try{
   New-Item -Path 'C:\ADDS_LOG' -ItemType Directory
   New-Item -ItemType File -Path $logfile -ErrorAction Stop | Out-Null
   Write-Host "-=<<< LOG $($logfile) HAS BEEN COGITATED >>>=-" -ForegroundColor Green
   }
Catch{
     Write-Warning -Message $("FAILURE CREATION LOGFILE. Error: "+ $_.Exception.Message)
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
     Write-Warning -Message $("FAILURE APPLICATION NETWORK SETTINGS. Error: "+ $_.Exception.Message)
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
    Write-Host "-=< ENTITY SET TO $($computername) >=-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - ENTITY SET TO $($computername)"
    }
Catch{
     Write-Warning -Message $("FAILURE ASSIGNING ENTITY IDENTITY . Error: "+ $_.Exception.Message)
     Break;
     }

# DOORGEVEN AAN LOGFILE DAT DEEL 1 VAN SCRIPT GEDAAN IS
Timestamp
Add-Content $logfile "$($Timestamp) - CONFIGURATION STEP 1 COMPLETED , INITIALISING STEP 2 =-" 

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
$secondcheck1 = Get-Content $logfile | Where-Object { $_.Contains("CONFIGURATION STEP 1 COMPLETED") }

IF ($secondcheck1)
    {
    $secondcheck2 = Get-Content $logfile | Where-Object { $_.Contains("2-CONFIGURATION STEP 2 COMPLETED") }

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
            Write-Host "-=<<< COGITATING ACTIVE DIRECTORY DOMAIN SERVICES >>>=-" -ForegroundColor Yellow
            Install-ADDSForest -DomainName $domainname -InstallDNS -ErrorAction Stop -NoRebootOnCompletion -SafeModeAdministratorPassword $dsrmpassword -Confirm:$false | Out-Null
            Write-Host "-=<<< COGITATION ACTIVE DIRECTORY DOMAIN SERVICES ACCEPTED >>>=-" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - COGITATION ACTIVE DIRECTORY DOMAIN SERVICES ACCEPTED"
            }
        Catch{
            Write-Warning -Message $("FAILURE COGITATING ACTIVE DIRECTORY DOMAIN SERVICES. Error: "+ $_.Exception.Message)
            Break;
            }

        # TWEEDE COMPLETION DOORGEVEN AAN HET LOGFILE
        Timestamp
        Add-Content $logfile "$($Timestamp) - 2-CONFIGURATION STEP 2 COMPLETED, INITIALISING STEP 3 =-"

        # PC RESTART VOOR ADDS
        Write-Host "-=<<< INITIATING RESTART >>>=-" -ForegroundColor White -BackgroundColor Red
        Sleep 10

        Try{
            Restart-Computer -ComputerName $env:computername -ErrorAction Stop
            Write-Host "REBOOT INITIALIZED" -ForegroundColor Green
            Add-Content $logfile "$($Timestamp) - REBOOT INITIALIZED"
            Break;
            }
        Catch{
            Write-Warning -Message $("FAILURE REBOOT $($env:computername). Error: "+ $_.Exception.Message)
            Break;
            }
        } # Close 'IF ($secondcheck2)'
    }# Close 'IF ($secondcheck1)'




# TWEEDE KEER NAKIJKEN VAN LOGFILE OM PROGRESS NA TE ZIEN
$thirdcheck = Get-Content $logfile | Where-Object { $_.Contains("2-CONFIGURATION STEP 2 COMPLETED") }

## DNS SETTINGS AANPASSEN OP ADDS##

#------------
#- Settings -
#------------

# TOEVOEGEN VAN EEN DNS REVERSE LOOKUP
Timestamp
Try{
    Add-DnsServerPrimaryZone -NetworkId $globalsubnet -DynamicUpdate Secure -ReplicationScope Domain -ErrorAction Stop
    Write-Host "-=<<< SUCCEEDED $($globalsubnet) AS RERVERSE LOOKUP WITHIN DNS >>>=-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - SUCCEEDED $($globalsubnet) AS REVERSE LOOKUP WITHIN DNS"
    }
Catch{
     Write-Warning -Message $("FAILURE CREATING REVERSE LOOKUP $($globalsubnet). Error: "+ $_.Exception.Message)
     Break;
     }

# ADNS SCAVENGING MOGELIJKHEID TOEVOEGEN
Write-Host "-=<<< COGITATING DNS SCAVENING >>>=-" -ForegroundColor Yellow

Timestamp
Try{
    Set-DnsServerScavenging -ScavengingState $true -ScavengingInterval 8.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $domainname -Aging $true -RefreshInterval 8.00:00:00 -NoRefreshInterval 8.00:00:00 -Verbose -ErrorAction Stop
    Set-DnsServerZoneAging $reversezone -Aging $true -RefreshInterval 8.00:00:00 -NoRefreshInterval 8.00:00:00 -Verbose -ErrorAction Stop
    Add-Content $logfile "$($Timestamp) - DNS Scavenging Complete"
    }
Catch{
     Write-Warning -Message $("FAILURE COGIATING DNS SCAVENGING. Error: "+ $_.Exception.Message)
     Break;
     }

Get-DnsServerScavenging

Write-Host "-=<<< DNS SCAVENGING COTIGATED >>>=-" -ForegroundColor Green

# AD SITES EN SERVICES AANMAKEN
Timestamp
Try{
    New-ADReplicationSubnet -Name $globalsubnet -Site "Default-First-Site-Name" -Location $subnetlocation -ErrorAction Stop
    Write-Host "-=<<< SUCCEEDED ADDING $($globalsubnet) WITHIN LOCATION $($subnetlocation) IN AD SITES AND SERVICES >>>=-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - SUCCEEDED ADDING $($globalsubnet) WITHIN LOCATION $($subnetlocation) IN AD SITES AND SERVICES"
    }
Catch{
     Write-Warning -Message $("FAILURE CREATION SUBNET $($globalsubnet) IN AD SITES AND SERVICES. Error: "+ $_.Exception.Message)
     Break;
     }

# HERNOEMEN VAN DNS SITES
Timestamp
Try{
    Get-ADReplicationSite Default-First-Site-Name | Rename-ADObject -NewName $sitename -ErrorAction Stop
    Write-Host "-=<<< SUCCEEDED RENAME $sitename IN AD SITES AND SERVICES >>>=-" -ForegroundColor Green
    Add-Content $logfile "$($Timestamp) - SUCCEEDED RENAME $sitename IN AD SITES AND SERVICES"
    }
Catch{
     Write-Warning -Message $("FAILURE RENAME $sitename IN AD SITES AND SERVICES. Error: "+ $_.Exception.Message)
     Break;
     }
}

# DOORGEVEN AAN LOGFILE DAT HET SCRIPT COMPLEET IS

Timestamp
Write-Host "-= 3-Finalize-AD-Config Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - 3-Finalize-AD-Config Complete"
Write-Host "-= Active Directory Script Complete =-" -ForegroundColor Green
Add-Content $logfile "$($Timestamp) - Active Directory Script Complete"
