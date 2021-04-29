#Created by: John Stephen
#Created on: 11/6/2020
#Written for: Azure Windows Virtual Desktop Spring 2020 (ARM Integrated)
#Purpose: When provided a user UPN(email address) it will take that and search the WVD environment to find what session host(s) they are assigned.


[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $upn
                
     )

#Function to find the session hosts the user is a part of.
function Get-WVDUserAssignments {
    param (
        [Parameter(Mandatory=$true)]
        [string] $upn
    )

    $AllRGs = (Get-AzResourceGroup).ResourceGroupName

    Foreach ($RGname in $AllRGs)
    {
        $AllHPs = (Get-AzWvdHostPool -ResourceGroupName $RGname).name
        
        foreach ($HPname in $AllHPs) 
        {
            (Get-AzWvdSessionHost -HostPoolName $HPname -ResourceGroupName $RGname |  where-object {$_.AssignedUser -eq $upn}).Name
        }
    }
    return $Assignments
}

$SessionNames = Get-WVDUserAssignments -upn $upn
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