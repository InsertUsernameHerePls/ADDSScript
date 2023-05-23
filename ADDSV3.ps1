#Network Variables
$ethipaddress = '192.168.55.5' #STATIC IP ADDRESS VAN DE SERVER
$ethprefixlength = '24' # AANGEGEVEN CIDR NOTATIE SUBNETMASK '255.255.255.0' (16/255.255.0.0 classe B) (8/255.0.0.0 classe A)
$etherdefaultgw = '192.168.55.1' #DEFAULT GATEWAY ROUTER IP ADDRESS
$ethdns = '192.168.55.5'#OMDAT DIT ONZE DNS SERVER WORDT GEVEN WE DE STATIC IP ADDRESS VAN ONZE SERVER HIER IN
$subnetlocation = 'Belgium'
$sitename = 'ProjectWilliam.local'

#ACTIVE DIRECTORY DOMAIN
$domainname = 'ProjectWilliam.local'

#REMOTE DESKTOP ENABLE/DISABLE
$enablerdp = 'yes' # ENABLE IS YES / DISABLE IS NO

#IE ENCHANCED SECURITY 
$disableieseconfig = 'yes' # IE ENCHANCED SECURITY UITSCHAKELEN MET YES EN INSHAKELEN MET NO

# HOSTNAME/COMPUTERNAAM WIJZIGEN
$computername = 'ADDSSERVER1' #NAAM VAN COMPUTER/SERVER

#TIME ZONE WIJZIGEN VAN COMPUTER NAAR ROMANCE STANDARD TIME
Set-TimeZone -Id "Romance Standard Time"

# TIMESTAMP
    {
    $timestamp = Get-Date -Format "dd-MM-yyy_hh:mm:ss"
    }
#AANMAKEN VAN LOGFILE LOCATIE
$logfile = ".\desktop\ADDS_LOG.txt"

#AANMAKEN VAN LOGFILE ZELF DIE WE GAAN GEBRUIKEN ALS CHECKMARK OM COMPUTER IN 3 STAPPEN TE LATEN HERSTARTEN
Write-Host "-= ANALYZING TIME =-" -ForegroundColor DarkRed

Timestamp

IF (Test-Path $logfile)
    {
    Write-Host "-= LOGFILE ENDURES =-" -ForegroundColor Yellow
    }

ELSE {

Write-Host "-= FABRICATING LOGFILE =-" -ForegroundColor DarkCyan

try{
    New-Item -ItemType File -Path $logfile -ErrorAction Stop | Out-Null
    Write-Host "-= LOGFILE $($logfile) FABRICATED =-" -ForegroundColor Green
    }
Catch {
    Write-Warning -Message $("CONSTRUCTION LOGFILE FAILURE. Error: "+ $_.Exception.message)
    Break;
    }
}

#CHECKSUMS VAN SCRIPT VIA LOGFILE DIE NET IS AANGEMAAKT zie .\desktop\logfile.txt

$firstcheck = Select-String -Path $logfile -Pattern "BASIC CONFIGURATION EFFECTUATED"

IF (!$firstcheck) {
#TIJD INGEVEN IN LOGFILE
Write-Host "-= BASIC CONFIGURATION INSIGNIFICANT =-" -ForegroundColor DarkRed

Timestamp
Add-Content $logfile "$($timestamp) - COMMENCING ADDS SCRIPT"

## BASIC CONFIGURATION ADDS
#NETWORK AANMAKEN 

Timestamp
Try {
    New-NetIPAddress -IPAddress $ethipaddress -PrefixLength $ethprefixlength -DefaultGateway $etherdefaultgw -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ErrorAction Stop | Out-Null
    Set-DnsClientServerAddress -ServerAddresses $ethdns -InterfaceIndex (Get-NetAdapter).InterfaceIndex -ErrorAction stop
    Write-Host "-= IP ADDRESS APPOINTED $($ethipaddress), SUBNET APPOINTED $($ethprefixlength), GATEWAY APPOINTED $($etherdefaultgw) DNS SERVER APPOINTED $($ethdns) =-" -ForegroundColor Green
    Add-Content $logfile "$($timestamp) - IP ADDRESS APPOINTED $($ethipaddress), SUBNET APPOINTED $($ethprefixlength), DEFAULT GATEWAY APPOINTED $($etherdefaultgw) DNS SERVER APPOINTED $($ethdns)"
    }
Catch {
    Write-Warning -Message $("FAILURE ACTUALIZING NETWORK. Error: "+ $_Exception.Message)
    break;
    }
}

# HET MOGELIJK MAKEN RDP AAN TE ZETTEN OF UIT TE ZETTEN
Timestamp
try{
    IF ($enablerdp -eq "yes")
    {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "FdenyTSConnections" -value 0 -ErrorAction Stop
    Enable-NetfirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Sto
    Write-Host "-= RDP SET IN MOTION =-" -ForegroundColor Green
    Add-content $logfile "$($timestamp) - RDP SET IN MOTION"
    }
}
catch{
    Write-Warning -Message $("SYSTEMATIC FAILURE APPLICATION RDP. ERROR WHY ARE YOU SO STUPID: "+ $_.Exception.Message)
    Break;
    }
IF ($enablerdp -ne "yes")
    {
    Write-Host "-= RDP REMAINS DISFUNCTIONAL =-" -ForegroundColor Green
    add-content $logfile "$($timestamp) - RDP REMAINS DISFUNCTIONAL"
    }

#UITZETTEN IE ENHANCED SECURITY (NIET AAN TE RADEN , DEFAULT STAAT HET AAN) 
timestamp
try{
    IF ($disableieconfig -eq "yes")
    {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0 -ErrorAction Stop
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0 -ErrorAction Stop
    Write-Host "-= IE Enhanced Security TERMINATED =-" -ForegroundColor Green
    Add-Content $logfile "$($timestamp) - IE Enhanced TERMINATED"
    }
}
catch{
    Write-Warning -Message $("FAILURE TERMINATING IE ENHANCED SECURITY. Error: "+ $_.Exception.Message)
    Break;
    }

if ($disableieseconfig -ne "yes")
    {
    Write-Host "-= IE ENHANCED SECURITY UNBROKEN =-" -foregroundColor Green
    Add-Content $logfile "$($timestamp) - IE ENCHANCED SECURITY UNBROKEN"
    # HOSTNAME AANGEVEN AAN SERVER
timestamp
Try{
    Rename-Computer -ComputerName $env:COMPUTERNAME -Newname $computername -ErrorAction Stop | Out-Null
    Write-Host "-= ENTITY ASSIGNED  $($computername) =-" -ForegroundColor Green
    Add-Content $logfile "$($timestamp) - ENTITY ASSIGNED $($computername)"
    }
catch{
    Write-Warning -Message $("FAILURE ASSIGNMENT ENTITY. Error: "+ $_.Exception.Message)
    break;
    }

# EERSTE RESTART CHECKSUM DOORGEVEN VIA LOGFILE
timestamp
Add-Content $logfile "$($timestamp) - BASIC CONFIGURATION REQUIREMENTS MET, INITIALISING REBOOT, INITIALISING SCRIPT 2 =-"

# HOST REBOOTEN + APPLICATIE AANGEMAAKTE SETTINGS -> VOORAL ALLEEN VOOR HOSTNAME
timestamp
Write-Host "-= REBOOT INITIALISING WITHIN 20 SECONDS =-" -ForegroundColor White -BackgroundColor Black
Sleep 20

try{
    Restart-Computer -ComputerName $env:COMPUTERNAME -ErrorAction stop
    Write-Host "-= REBOOT COMMENCING =-" -foregroundColor Green
    Add-Content $logfile "-= $($timestamp) - REBOOT COMMENCING =-"
    Break;
    }
Catch{
    write-warning -Message $("REBOOT FAILURE $($env:computername) . Error"+ $_.Exception_Message)
    Break;
    }
}
# NA REBOOT NAKIJKEN VAN ONZE PROGRESS VIA AANGEMAAKTE LOGFILE
$secondcheck1 = Get-Content $logfile | Where-Object { $_.Contains("BASIC CONFIGURATIONS MET, INITIALISING REBOOT, INITIALISING SCRIPT 2 =-") }


IF ($secondcheck1)
    {
    $secondcheck2 = Get-Content $logfile | Where-Object { $_.Contains("STEP 2 CONFIG ACCEPTED") }

    If (!secondcheck2)
    {

    # DEEL 2 VAN ADDS SCRIPTS (INSTALLEREN VAN ADDS ZELF)    
    Timestamp
    Try{
        Write-Host "-= REACHING THE ETHER FOR ADDS INSTALLMENT =-" -ForegroundColor Yellow
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
        Write-Host "-= AD-DOMAIN SERVICES BREACHED SUCCES =-" -ForegroundColor Green
        Add_content $logfile "$($timestamp) - AD-DOMAIN SERVICES DOWNLOAD SUCCESFULL"
        }
catch{
    write-warning -Message $("AD-DOMAIN ERROR ACKNOWLEDGED $($env:computername) . Error: "+ $_.Exception_Message)
    Break;
    }
    
    #ACTIVE DIRECTORY CONFIGURATIE
Timestamp
Try {
    Write-Host "-= CONSTRUCTING AD-DOMAIN SERVICES =-" -ForegroundColor Yellow
    Install-ADDSForest -CreateDnsDelegation:$false -databasepath "Windows\NTDS" -domainMode "Winthreshold" -Domainname "projectWilliam.local" -DomainNetbiosName "ProjectWilliam" -Forestmode "Winthreshold" -InstallDns:$true -logpath "c:Windows\NTDS" -NorebootOncompletion:$true -sysvolPath "c:\Windows\sysvol" -Force:$true -SafemodeAdministratorPassword (ConvertTo-SecureString "9097133LoL" -AsPlainText -Force)
    Write-host "-= AD-DOMAIN SERVICES DOWNLOAD SUCCESFULL=- " -ForegroundColor Green
    Add_content $logfile "$($timestamp) - AD-DOMAIN SERVICES DOWNLOAD SUCCESFULL=- "
    }
Catch {
    Write-Warning -Message $("FAILURE CONSTRUCTION AD-DOMAIN SERVICES. Error: "+ $_.Exception_Message)
    Break;
    }
#TWEEDE LOGFILE SCRIPT COMPLETION 
Timestamp
Add_content $logfile "$($timestamp) - AD-DOMAIN SERVICES CONFIGURATION REQUIREMENTS MET, INITIALISING REBOOT, INITIALISING SCRIPT 3 =-"

#REBOOT COMPUTER VIA LOGFILE
timestamp
Write-Host "-= REBOOT INITIALISING WITHIN 20 SECONDS =-" -ForegroundColor White -BackgroundColor Black
Sleep 20

try{
    Restart-Computer -ComputerName $env:COMPUTERNAME -ErrorAction stop
    Write-Host "-= REBOOT COMMENCING =-" -foregroundColor Green
    Add-Content $logfile "-= $($timestamp) - REBOOT COMMENCING =-"
    Break;
    }
Catch{
    write-warning -Message $("REBOOT FAILURE $($env:computername) . Error"+ $_.Exception_Message)
    Break;
    }
}
}

