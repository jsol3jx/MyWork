#Created By: John Stephen



[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $upn
                
     )

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null


function FindSessionName {
    param (
        [Parameter(Mandatory=$true)]
        [string] $upn
    )
    
    $Tenants = "ANSYS_VDI_AZUE","ANSYS_VDI_AZUW","ANSYS_VDI_AZIW","ANSYS_VDI_AZEW"

    ForEach ($Tenant in $Tenants)
    {
        $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
        foreach ($Hostpool in $Hostpools) 
        {
            (Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool | where-object {$_.AssignedUser -eq $upn}).SessionHostName    
        }
    }

}

$SessionNames = FindSessionName -upn $upn
$SessionNames = $SessionNames | Where-Object {$_ -ne $null}

Write-Host "Here are associated session hosts for user $upn"

$SessionNames