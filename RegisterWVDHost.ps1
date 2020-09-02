#Created by: John Stephen
#Created on: 7/10/2020
#Written for: Azure Windows Virtual Desktop Fall 2019 (classic)
#Purpose: This script will copy the WVD agent and bootloader installers to the vm, install them, 
# and then register the Azure Windows Virtual Desktop VM with the Host Pool it resides in after a failed deployment.

#Note, you will need to set azcopy in your windows environment variables.


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
         [string] $AppID,
         [Parameter(Mandatory=$true)]
         [string] $TenantID,
         [Parameter(Mandatory=$true)]
         [string] $SPKey
         
     )

#Authenticate AzCopy using the variables listed for a ServicePrincipal and then copy the WVD Agent and Bootloader installers from blob storage to the vm for install.
$env:AZCOPY_SPA_CLIENT_SECRET = $SPkey
azcopy login --service-principal  --application-id $AppID --tenant-id=$TenantID
azcopy copy 'https://storageaccount.blob.core.windows.net/wvdfiles/*' ('\\'+$HostFQDN+'\c$\WVD') --recursive

#Connect to Windows Virtual Desktop with your ansys admin account
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

# This section either exports the token that currently exists or it creates a new one. 
Try
{
	$CurrentToken = Export-RdsRegistrationInfo -TenantName $TenantName -HostPoolName $HostPoolName | Select-Object -ExpandProperty Token -ErrorAction Stop
    $Token = $CurrentToken
    Write-host "Current Token Exported"
}
Catch
{
    $NewToken = New-RdsRegistrationInfo -TenantName $TenantName -HostPoolName $HostPoolName | Select-Object -ExpandProperty Token
    $Token = $NewToken
	Write-host "New Token Generated"
}

#This section will install the two files downloaded from Azure Blob Storage, wait for each to finish installing, and then set the Registration Token in the registry.
Invoke-command -Computername $HostFQDN -ScriptBlock {
    
        Start-Process msiexec.exe -ArgumentList '/I C:\WVD\WVDAgent.msi /quiet'
        Start-Sleep 20
        Start-Process msiexec.exe -ArgumentList '/I C:\WVD\WVDBootLoader.msi /quiet'
        Start-Sleep 20
        
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name 'RegistrationToken' -Value $Using:Token -Force
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name 'IsRegistered' -Value 0 -Propertytype DWORD -Force
        Restart-Service -Name RDAgentBootLoader
 
	    
        

	} 
	