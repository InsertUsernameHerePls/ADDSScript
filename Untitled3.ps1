Install-WindowsFeature -Name DHCP -IncludeManagementTools

$Serverfqdn = "WilliamProject.local" 
$dnsServer ="192.168.55.5"
$scopeName = "MyScope"
$scopeStartRange = "192.168.55.50"
$ScopeEndRange = "192.168.55.254"
$subnetmask = "255.255.255.0"
$gateway = "192.168.55.1"
$leaseduration = "8.00:00:00"

Set-DhcpServerv4OptionValue -ComputerName $Serverfqdn -OptionID 3 -value $gateway
Set-DhcpServerv4OptionValue -ComputerName $Serverfqdn -OptionId 51 -Value $leaseduration
Set-DhcpServerv4OptionValue -ComputerName $Serverfqdn -OptionId 6 -Value $dnsServers

Add-DhcpServerv4Scope -ComputerName $Serverfqdn -Name $scopeName -StartRange $scopeStartRange -EndRange $ScopeEndRange -Subnetmask $subnetmask

Add-DhcpServerInDC -DnsName $Serverfqdn