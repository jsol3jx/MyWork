#Created by: John Stephen
#Date: 10/15/2020
#Applies to: Azure Microsoft Virtual Desktop Spring 2020
#Exports a list of assigned users to the Spring 2020 verson of MVD to a spreadsheet.

#$AllHostPoolNames = (Get-AzWvdHostPool).name

function Get-MVDAssignments {
    $AllRGs = (Get-AzResourceGroup).ResourceGroupName

    Foreach ($RGname in $AllRGs)
    {
        $AllHPs = (Get-AzWvdHostPool -ResourceGroupName $RGname).name
        
        foreach ($HPname in $AllHPs) 
        {
            Get-AzWvdSessionHost -HostPoolName $HPname -ResourceGroupName $RGname | Select-Object -Property Name,AssignedUser             
        }
    }
    return $Assignments
}

Get-MVDAssignments | Out-GridView


