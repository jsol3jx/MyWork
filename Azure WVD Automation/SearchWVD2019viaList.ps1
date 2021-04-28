Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

$upnlist = get-content -path C:\path\to\file\upnlist.txt
$Tenants = "tenant1","tenant2","tenant3"


#Function to find the session hosts the user is a part of in the WVD Fall 2019 environment.
function Get-FallSessionName {
    param(
        [string[]]$UserPrincipalName,
        [string[]]$Tenants
    )     
      
    #$null = $obj
    ForEach ($upn in $upnlist) {
        
        ForEach ($Tenant in $Tenants) {
            
            $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
            
            foreach ($Hostpool in $Hostpools) {   
                    
                $shn = (Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool | where-object {$_.AssignedUser -eq $upn}).SessionHostName
                
                foreach($hostName in $shn)
                {
                # Defines an object that will be displayed in an Out-Gridview.
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