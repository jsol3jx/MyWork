#Created by: John Stephen
#Created on: 11/8/2020
#Written for: Azure Windows Virtual Desktop Fall 2019(classic) & Spring 2020 (ARM Integrated)
#Purpose: When provided a user UPN(email address) it will take that and search the entire WVD environment to find what session host(s) they are assigned.

[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $upn
                
     )

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

#Function to find the session hosts the user is a part of in the WVD Fall 2019 environment.
function Get-FallSessionName {
    param (
        [Parameter(Mandatory=$true)]
        [string] $upn
    )
    
    $Tenants = (Get-RdsTenant).TenantName

    ForEach ($Tenant in $Tenants)
    {
        $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
        foreach ($Hostpool in $Hostpools) 
        {
            (Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool | where-object {$_.AssignedUser -eq $upn}).SessionHostName    
        }
    }
    return $FallAssignments
}

#Function to find the session hosts the user is a part of in the WVD Spring 2020 environment.
function Get-SpringSessionName {
    param (
        [Parameter(Mandatory=$true)]
        [string] $upn
    )
    #Manually had them entered due to the small amount of Subs for WVD compared to rest of Azure Environment. Cuts search time down.
    $Subscriptions = "SubID","SubID","SubID","SubID"
    
    foreach ($subs in $Subscriptions) 
    {
        Select-AzSubscription -SubscriptionId $subs | out-null
        $AllRGs = (Get-AzResourceGroup).ResourceGroupName    

        Foreach ($RGname in $AllRGs)
        {
            $AllHPs = (Get-AzWvdHostPool -ResourceGroupName $RGname).name
            
            foreach ($HPname in $AllHPs) 
            {
                (Get-AzWvdSessionHost -HostPoolName $HPname -ResourceGroupName $RGname |  where-object {$_.AssignedUser -eq $upn}).Name
            }
        }
    }
    return $Assignments
}

$2019SessionNames = Get-FallSessionName -upn $upn
$2019SessionNames = $2019SessionNames | Where-Object {$_ -ne $null}

if ($2019SessionNames -eq $null)
{
    Write-Host "$upn is not assigned to any Fall 2019 session hosts."
}
else 
{
    Write-Host "Here are the associated Fall 2019 session hosts for user $upn"
    $2019SessionNames
}

$2020SessionNames = Get-SpringSessionName -upn $upn
$2020SessionNames = $2020SessionNames | Where-Object {$_ -ne $null}

if ($2020SessionNames -eq $null)
{
    Write-Host "$upn is not assigned to any Spring 2020 session hosts."
}
else 
{
    Write-Host "Here are the associated Spring 2020 session hosts for user $upn"
    $2020SessionNames
}
