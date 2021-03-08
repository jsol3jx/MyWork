#Created by: John Stephen
#Created on: 9/32/2020
#Written for: Azure Windows Virtual Desktop Fall 2019 (classic)
#Purpose: When provided a user UPN(email address) it will take that and search the MVD environment to find what session host(s) they are assigned.


#Pass the variables through before script runs.
[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $upn
                
     )

#Connect to Windows Virtual Desktop with your ansys admin account
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

#Function that does the actual work to find all assigned sessionhosts.
function FindSessionName {
    param (
        [Parameter(Mandatory=$true)]
        [string] $upn
    )
    
    $Tenants = "Tenant1","Tenant2","Tenant3"

    ForEach ($Tenant in $Tenants)
    {
        $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
        foreach ($Hostpool in $Hostpools) 
        {
            (Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool | where-object {$_.AssignedUser -eq $upn}).SessionHostName    
        }
    }

}

#Sets the function output to a variable and outputs the session hosts assigned to the console.
$SessionNames = FindSessionName -upn $upn
$SessionNames = $SessionNames | Where-Object {$_ -ne $null}

if ($SessionNames -eq $null)
{
    Write-Host "$upn is not assigned to any session hosts."
}
else 
{
    Write-Host "Here are associated session hosts for user $upn"
    $SessionNames
}