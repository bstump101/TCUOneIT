Function Get-TcuDirectReport {

<#
.SYNOPSIS
    This script will get a user's direct reports recursively from ActiveDirectory and will exclude vendors.
    It is assumed that the Active Directory Module has already been imported.
  
.NOTES
    Name:           Get-DirectReport
    Author:         Bruce Stump
    Version:        1.0
    DateCreated:    2021-March-17
    
.PARAMETER SamAccountName
    Specify the samaccountname (username) to see direct reports.
  
.PARAMETER NoRecurse
    Don't recurse more than one level.
  
.EXAMPLE
    Get-DirectReport username
  
.EXAMPLE
    "username" | Get-DirectReport
#>
 
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
 
        [string]  $SamAccountName,
 
        [switch]  $NoRecurse
    )
 
    BEGIN {}
 
    PROCESS {
        $UserAccount = Get-ADUser $SamAccountName -Properties DirectReports, DisplayName
        $UserAccount | select -ExpandProperty DirectReports | ForEach-Object {
            $User = Get-ADUser $_ -Properties DirectReports, DisplayName, Title, EmployeeID
            if ($null -ne $User.EmployeeID) {
                if (-not $NoRecurse) {
                    Get-TCUDirectReport $User.SamAccountName
                }
                [PSCustomObject]@{
                    SamAccountName      = $User.SamAccountName
                    UserPrincipalName   = $User.UserPrincipalName
                    DisplayName         = $User.DisplayName
                    Manager             = $UserAccount.DisplayName
		            Title	            = $User.Title
                }
            }
        }
    }
 
    END {}
 
}
