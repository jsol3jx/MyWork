#Created by: John Stephen
#This will add custom RDP properties to a hostpool.

[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $TenantName,
         [Parameter(Mandatory=$true)]
         [string] $hostpoolname
     )

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

$properties="drivestoredirect:s:;audiocapturemode:i:1;camerastoredirect:s:*"
Set-RdsHostPool -TenantName $tenantname -Name $hostpoolname -CustomRdpProperty $properties