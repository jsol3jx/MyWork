#Created by: John Stephen
#Date: 10/12/2020
#Written for: Azure Windows Virtual Desktop Fall 2019 (classic)
#Purpose: This will add custom RDP properties to a hostpool.

#Pass the variables through before script runs.
[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $TenantName,
         [Parameter(Mandatory=$true)]
         [string] $hostpoolname
     )

#Connect to Windows Virtual Desktop with your ansys admin account
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

#sets the actual custom RDP properties
$properties="drivestoredirect:s:;audiocapturemode:i:1;camerastoredirect:s:*"
Set-RdsHostPool -TenantName $tenantname -Name $hostpoolname -CustomRdpProperty $properties