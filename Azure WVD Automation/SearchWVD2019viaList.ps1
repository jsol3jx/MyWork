#Created by: John Stephen
#Created on: 4/28/2021
#Written for: Azure Windows Virtual Desktop Fall 2019 (Classic)
#Purpose: When provided a text file of user UPNs(email addresses) the script will search the WVD environment to find what session host(s) they are assigned.

#Connects to the 2019 WVD environment.
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

#Import text file with UPN list.
$upnlist = get-content -path C:\path\to\file\upnlist.txt
#Sets the list of tenants to search. I wanted a targeted list of tenants in this example. 
$Tenants = "tenant1","tenant2","tenant3"


#Function to find the session hosts the user is a part of in the WVD Fall 2019 environment and will dump the output to a hash table.
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
$2019SessionNames = Get-FallSessionName -UserPrincipalName $upnlist -Tenants $Tenants
$2019SessionNames | Out-GridView