#Created by: John Stephen
#Created on: 5/26/2021
#Written for: Azure Windows Virtual Desktop Spring 2020 (ARM Integrated) and Fall 2019(classic)
#Purpose: When provided a text file of user UPNs(email addresses) the script will search the WVD environment to find what session host(s) they are assigned.

#Import text file with UPN list.
$upnlist = get-content -path C:\path\to\file\upnlist.txt
#Sets the tenant list in fall 2019(classic) environment.
$Tenants = "tenant1","tenant2","tenant3"
#Sets a specific set of subscriptions. I went this route due to huge amount of subs in my environment and the search takes a long time just with the few selected.
$Subscriptions = "Sub1","Sub2","Sub3"

#Function to find the session hosts the user is a part of in the WVD Fall 2019(classic) environment and will dump the output to a hash table.
function Get-FallSessionName {
    param(
        [string[]]$UserPrincipalName,
        [string[]]$Tenants
    )     
        
    ForEach ($upn in $upnlist) {
        
        ForEach ($Tenant in $Tenants) {
            
            $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
            
            foreach ($Hostpool in $Hostpools) {   
                    
                $shn = (Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool | where-object {$_.AssignedUser -eq $upn}).SessionHostName
                
                foreach($hostName in $shn)
                {
                # Defines an hast table that will be displayed in an Out-Gridview outside of the function.
                [pscustomobject]@{
                    UserPrincipalName=$upn
                    Tenant=$Tenant
                    HostPool=$Hostpool
                    SessionHostName=$shn
                    }
                }       
            }
    
        }
    }
}


#Function to find the session hosts the user is a part of in the WVD Spring 2020(arm integrated) environment.
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
$2019SessionNames = Get-FallSessionName -UserPrincipalName $upnlist -Tenants $Tenants
$2020SessionNames = Get-SpringSessionName -UserPrincipalName $upnlist -Subscriptions $Subscriptions

If ($null -eq $2019AssignedUsers)
{
    Write-Host "There are no Spring 2019 Assignments."
}
    if ($null -eq $2020AssignedUsers) 
    {
        Write-Host "There are no Spring 2020 Assignments."    
    }    
        else 
        {
            $2019SessionNames | Out-GridView
            $2020SessionNames | Out-GridView        
        }
