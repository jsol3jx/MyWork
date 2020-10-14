#Created By:John Stephen
#Date: 10/12/2020
#Written for: Azure Windows Virtual Desktop Fall 2019 (classic)
#Purpose: This script will collect all session hosts in your Azure Environment

#Signs you in to the MVD environment
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

#Function will collect all Tenants in your MVD environment, it will pull all sessionhosts in each host pool in each tenant.
function UserSessionDump {
    
$AllTenants = (Get-RdsTenant).TenantName

    Foreach ($Tenant in $AllTenants)
    {
        $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
        foreach ($Hostpool in $Hostpools) 
        {
            Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool
        }
    }
    
}

#Quickest way to set the output of the function to a variable.
$AssignedUsers = UserSessionDump

#Exports that output to a csv file. 
$AssignedUsers | Export-Csv Path