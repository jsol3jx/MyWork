#Created By: John Stephen with some help from a friend. 
#Created On: 8/25/2020
#Written for: Azure Windows Virtual Desktop Fall 2019 (classic)
#Purpose: You enter the user's email address in as the UPN Variable upon running the script and the script
#will take that upn, search Azure VDI, get the virtual machine assigned to it, convert the upn to the user's SAM Account, and add them as a local administrator.

#Provide the user email address that is assigned to MVD.
[CmdletBinding()]
     Param
     (
         [Parameter(Mandatory=$true)]
         [string] $upn
                
     )

#Signs you in to the MVD Environment.     
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" | Out-Null

#Each of the Tenants you have are hard coded here and this function loops through them all to see what Session Hosts(VMs) are assigned to a user
function FindSessionName {
    param (
        [Parameter(Mandatory=$true)]
        [string] $upn
    )
    
    $Tenants = "TenantEastUS","TenantWestUS","TenantWestIndia","TenantWestEurope"

    ForEach ($Tenant in $Tenants)
    {
        $Hostpools = (Get-RdsHostPool -TenantName $Tenant).HostPoolName
        foreach ($Hostpool in $Hostpools) 
        {
            (Get-RdsSessionHost -TenantName $Tenant -HostPoolName $Hostpool | where-object {$_.AssignedUser -eq $upn}).SessionHostName    
        }
    }

}

#This section will remove objects in the array that are a Null entry to prevent issues with the Invoke-Command farther down.
$SessionNames = FindSessionName -upn $upn
$SessionNames = $SessionNames | Where-Object {$_ -ne $null}

#Converts the UPN variable to a SAM Account username.
$sam = (get-aduser -Filter * | where-object {$_.UserPrincipalName -eq $upn}).SamAccountName

#Self Explanatory, writes out the vms assigned to a user and their username.
Write-Host "Here are associated session hosts for user $upn"

$SessionNames

Write-Host "SAM Account for user $upn is $sam."

#You will need to provide your Admin Account creds to be able to run the Invoke-Command on the remote VMs.
$cred = get-credential -Message "Enter Your Domain Administrator username"

#Loops through all of the vms, or not if just one vm, assigned to the user and add them to the local administrators group.
foreach ($SystemName in $SessionNames)
{
    Invoke-command -Computername $SessionNames -Credential $cred -ScriptBlock {

        Add-LocalGroupMember -Group "Administrators" -member "Domain\$Using:sam"
    
    }
}
