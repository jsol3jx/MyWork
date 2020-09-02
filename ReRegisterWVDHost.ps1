#Created by: John Stephen
#Created on: 6/3/2020
#Written for: Azure Windows Virtual Desktop Fall 2019 (classic)
#Purpose: This script will re-register an Azure Windows Virtual Desktop VM with the Host Pool it resides in. This is required after removing a user assignment on the vm to make it available again.

#Pass the variables through before script runs.
[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $TenantName,
         [Parameter(Mandatory=$true)]
         [string] $HostPoolName,
         [Parameter(Mandatory=$true)]
		 [string] $HostFQDN,
		 [Parameter(Mandatory=$true)]
         [string] $UserUPN
     )

#Connect to Windows Virtual Desktop with your ansys admin account
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

try 
{
	Remove-RdsAppGroupUser $TenantName $HostPoolName "Desktop Application Group" -UserPrincipalName $UserUPN -ErrorAction Stop | Out-Null
	Write-Host "User Removed"	
}
catch 
{
	Write-host "User does not exist"	
}

$CurrentToken = $null
$NewToken = $null

# This section either exports the token that currently exists or it creates a new one. 
Try
{
	$CurrentToken = Export-RdsRegistrationInfo -TenantName $TenantName -HostPoolName $HostPoolName -ErrorAction Stop | Select-Object -ExpandProperty Token | Out-Null
	Write-host "Current Token Exported"
}
Catch
{
	$NewToken = New-RdsRegistrationInfo -TenantName $TenantName -HostPoolName $HostPoolName | Select-Object -ExpandProperty Token
	Write-host "New Token Generated"
}

#Removes the Host from the Hostpool.
Try
{
	Remove-RdsSessionHost -TenantName $TenantName -HostPoolName $HostPoolName -Name $HostFQDN -Force -ErrorAction Stop | Out-Null
	Write-Host "Host Removed"
}
Catch
{
	Write-Host "Host does not exist in pool."
}
#Once host is removed, this will re-register the host in the pool.
Invoke-command -Computername $HostFQDN -ScriptBlock {
    
    If ($Using:CurrentToken -eq $null)

	{
        write-host "Used New Token"
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name 'RegistrationToken' -Value $Using:NewToken -Force
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name 'IsRegistered' -Value 0 -Propertytype DWORD -Force
		Restart-Service -Name RDAgentBootLoader

	} 
	Else
	{
		Write-host "Used Current Token"
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name 'RegistrationToken' -Value $Using:CurrentToken -Force
		New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name 'IsRegistered' -Value 0 -Propertytype DWORD -Force
		Restart-Service -Name RDAgentBootLoader

	} 
} 