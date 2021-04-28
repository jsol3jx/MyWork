
$upnlist = get-content -path C:\path\to\file\upnlist.txt
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
                    # Defines an object that will be displayed in an Out-Gridview.
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
