#Created by: John Stephen
#Created on: 4/28/2021
#Written for: Azure Windows Virtual Desktop Fall 2020 (ARM Integrated)
#Purpose: When provided a text file of user UPNs(email addresses) the script will search the WVD environment to find what session host(s) they are assigned.

#Import text file with UPN list.
$upnlist = get-content -path C:\path\to\file\upnlist.txt

#Sets a specific set of subscriptions. I went this route due to huge amount of subs in my environment and the search takes a long time just with the few selected.
$Subscriptions = "Sub1","Sub2","Sub3"

#Function to find the session hosts the user is a part of in the WVD Spring 2020 environment.
function Get-SpringSessionName {
    param (
        [string[]]$UserPrincipalName,
        [string[]]$Subscriptions
    )

    foreach ($upn in $upnlist) {

        foreach ($subs in $Subscriptions) 
        {
            Select-AzSubscription -SubscriptionId $subs | out-null
            $AllRGs = (Get-AzResourceGroup).ResourceGroupName    

            Foreach ($RGname in $AllRGs)
            {
                $AllHPs = (Get-AzWvdHostPool -ResourceGroupName $RGname).name
                
                foreach ($HPname in $AllHPs) 
                {
                    $shn = (Get-AzWvdSessionHost -HostPoolName $HPname -ResourceGroupName $RGname |  where-object {$_.AssignedUser -eq $upn}).Name
                    
                    foreach($hostName in $shn)
                    {
                    # Defines a hash table that will be displayed in an Out-Gridview outside of the function.
                        [pscustomobject]@{
                            UserPrincipalName=$upn
                            HostPoolName=$HPname
                            SessionHostName=$shn
                        }
                    }       
                }
            }
        }
    }
}
$2020SessionNames = Get-SpringSessionName -UserPrincipalName $upnlist -Subscriptions $Subscriptions
$2020SessionNames | Out-GridView
