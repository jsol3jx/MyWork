#Created by: John Stephen
#Date: 10/15/2020
#Applies to: Azure Microsoft Virtual Desktop Spring 2020
#Exports a list of assigned users to the Spring 2020 verson of MVD to a spreadsheet.

function Get-WVDAssignments {
    #I set the subscriptions manually due to the huge amount of Subs we have compared to the little amount of Spring 2020 Hostpools deployed.
    $Subscriptions = "SubID","SubID","SubID","SubID"

    foreach ($subs in $Subscriptions) 
    {
        Select-AzSubscription -SubscriptionId $subs | out-null
        $AllRGs = (Get-AzResourceGroup).ResourceGroupName    

        Foreach ($RGname in $AllRGs)
        {
            $AllHPs = Get-AzWvdHostPool -ResourceGroupName $RGname
            
            foreach ($HPname in $AllHPs) 
            {
                Get-AzWvdSessionHost -HostPoolName $HPname -ResourceGroupName $RGname |  Select-Object Name,AssignedUser
            }
        }
    }
    return $Assignments
}

$2020AssignedUsers = Get-WVDAssignments 
 
$2020AssignedUsers | Export-Csv C:\WVD\Reports\Spring2020users.csv