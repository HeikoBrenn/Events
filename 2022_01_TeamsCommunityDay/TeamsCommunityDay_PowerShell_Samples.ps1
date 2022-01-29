
#region COMPUTERLIEBE (DIE MODULE SPIEL'N VERRÜCKT)
#COMPUTERLOVE (THE MODULES ARE GOING CRAZY)
# PowerShell logistics
 
Find-Module -Name MicrosoftTeams | Install-Module -Scope AllUsers
Import-Module MicrosoftTeams

Get-Module -Name MicrosoftTeams* -ListAvailable | select Name,Version,Path

get-command -type Cmdlet -module MicrosoftTeams
get-command -module MicrosoftTeams
get-command -module MicrosoftTeams |Measure-Object

# Connect to Teams
$cred = Get-Credential
Connect-MicrosoftTeams -Credential $cred
Connect-MicrosoftTeams
# Disconnect to Teams
Disconnect-MicrosoftTeams
#endregion

#region I WANT IT ALL - QUEEN
# Let's take a look at the current state
# Show Teams
 
Get-Team

#Show all archived Teams
Get-Team | Where-Object Archived -EQ $true 

#Show all archived Teams and un-archive them
Get-Team | Where-Object Archived -EQ $true |Set-TeamArchivedState -Archived $false

#Show all Teams with specific Names
Get-Team -DisplayName wfh

#Show all Teams where a specific user is member or owner
Get-Team -user iggy.pop@kraichgau-touristik.de | Tee-Object -Variable myuser
$myuser.count
(Get-Team -user iggy.pop@kraichgau-touristik.de).count

#Show all Teams and all Teams users 
Get-team | get-teamuser

Get-TeamUser -GroupId 350c0cd9-1515-4ab9-b601-50d98ead08df

Get-TeamUser -GroupId 350c0cd9-1515-4ab9-b601-50d98ead08df -Role owner

# Top 10 Teams users (Owner/Member)
$Teams = Get-Team
$Top10Owners = foreach ($Team in $Teams) { Get-TeamUser -GroupId $Team.GroupId | where {$_.Role -eq "Member"} } 
($Top10Owners | Group-Object User -NoElement) | Format-Table -AutoSize | Select-Object -First 10

# Summary of my Teams
$myteams = Get-Team
$myteamssummary = @()
 
foreach ($team in $myteams) {
 
    $members  = Get-TeamUser -GroupId $team.GroupId
    $owner    = Get-TeamUser -GroupId $team.GroupId -Role Owner
    $channels = Get-TeamChannel -GroupId $team.GroupId 
    $myteamssummary += New-Object -TypeName PSObject -Property ([ordered]@{
 
        'Team'     = $team.DisplayName
        'GroupId'  = $team.GroupId
        'Owner'    = $owner.User
        'Members'  = $members.user -join "`r`n"
        'Channels' = $channels.displayname -join "`r`n"
     
        })
}

Write-Output $myteamssummary |Out-GridView


#endregion

#region CALLING ALL STATIONS - GENESIS
#
# Show all channels in all Teams
$Teams = Get-Team
$List = foreach ($Team in $Teams) { Get-TeamChannel -GroupId $Team.GroupId | Select-Object @{n='TeamName';e={$Team.DisplayName} }, @{n='ChannelName';e={$_.DisplayName} }, Description  }
$ChannelCount = ($List.DisplayName).Count

Write-Host Total Teams :: $Teams.count -ForegroundColor Green
Write-Host Total Channels :: $ChannelCount -ForegroundColor Green

$List
#########

#Show a specific channels in all Teams
$Teams = Get-Team
$List = foreach ($Team in $Teams) { Get-TeamChannel -GroupId $Team.GroupId | Where-Object {$_.Displayname -Like "Venues"} | Select-Object @{n='TeamName';e={$Team.DisplayName} }, @{n='ChannelName';e={$_.DisplayName} }, Description  }
$ChannelCount = ($List.DisplayName).Count

Write-Host Total Teams :: $Teams.count -ForegroundColor Green
Write-Host Total Channels :: $ChannelCount -ForegroundColor Green

$List
#endregion

#region THE UNINVITED GUEST - MARILLION
# Show Guest users in all Teams
$Teams = Get-Team
$result = foreach ($Team in $Teams) { Get-TeamUser -GroupId $Team.GroupId | where {$_.Role -eq "Guest"} | Select User, Role, @{n='TeamName';e={$Team.DisplayName} }}
$result | Export-Csv .\GuestsInTeams.txt
Get-Content .\GuestsInTeams.txt
#endregion

#region GET THE PARTY STARTED - P!NK

# Add a specific user to all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Add-TeamUser -GroupId $Team.GroupId -User angus.young@kraichgau-touristik.de -Role Member}


# Add a specific Channel  to all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { New-TeamChannel -GroupId $Team.GroupId -DisplayName "NewChannel_TCD_001"}

# Create a specific Team
New-Team -DisplayName "TCD2022_001" -Description "Awesome Community Event" -Visibility Public -AllowGiphy $false -AllowAddRemoveApps $false -AllowCreatePrivateChannels $false


#Create multiple Teams 

$Teams = Get-Content C:\test\myteams.txt
$(foreach ($Team in $Teams) {

New-Team –Displayname $Team -Description "Collaboration for $Team" -Visibility Private -AllowGiphy $false -AllowDeleteChannels $false 

})

Add-TeamUser -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -User "angus.young@kraichgau-touristik.de"

New-TeamChannel -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -DisplayName "Events Asia 2023"

$group = New-Team -displayname "Tour 2023 Asia" -Visibility private
Add-TeamUser -GroupId $group.GroupId -User "Angus.young@kraichgau-touristik.de" -role 
Add-TeamUser -GroupId $group.GroupId -User "phil.collins@kraichgau-touristik.de"
Add-TeamUser -GroupId $group.GroupId -User "iggy.pop@kraichgau-touristik.de"
Add-TeamUser -GroupId $group.GroupId -User "kim.wilde@kraichgau-touristik.de"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Venues"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Catering"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Rehearsal"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Public Relations"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Ticket Sales"


#endregion

#region SEEK AND DESTROY - METALLICA
# Remove a specific channel from all Teams (soft deleted)
$Teams = Get-Team
foreach ($Team in $Teams) { Remove-TeamChannel  -GroupId $Team.GroupId -DisplayName "testtest"}


# Remove a specific user from all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Remove-TeamUser -GroupId $Team.GroupId -User peter.gabriel@kraichgau-touristik.de -Role Member }


# Remove specific Teams
$Teams = Get-Team -DisplayName testest
foreach ($Team in $Teams) { Remove-Team -GroupId $Team.GroupId}

Remove-Team -GroupId 59d04b2f-9f79-4ee3-984f-bde6025a9cbd
#endregion

#region MESSAGE IN A BOTTLE - THE POLICE
# Push messages to Teams channels
$WebhookURL = 'https://scriptrunner1.webhook.office.com/webhookb2/87973ca6-1d50-42dc-b8a4-f20cfd11a45c@30f65c4b-8dc9-4f07-912a-7fa0bf6715b9/IncomingWebhook/fdc24883b93149f5bb967326ca440ab9/aedbe5f7-f6ad-48db-8b1f-cb3a79737494'
$Message = "Please be kind and stay healthy"
$Title = "Our daily message $(Get-date)"
$MessageColor = "green"
SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title -MessageColor $MessageColor
#endregion

#region SO LONELY - THE POLICE
# Find Teams with too few owners

Param(
    [ValidateRange(1,10)]
    [int]$ThresholdValue = 2,
    [bool]$Archived
)


try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Archived' = $Archived
                            }                              
    
    $teams = Get-Team @getArgs 
    $result = @()
    foreach($item in $teams){
        try{
            $users = Get-TeamUser -GroupId  $item.GroupId -ErrorAction Stop | `
                        Where-Object {$_.Role -like "owner"}
            if(($null -eq $users) -or ($users.Count -lt $ThresholdValue)){
                $result += "WARNING: Team $($item.DisplayName) has $($users.Count) owners"
            }
        }
        catch{
            $result += "Error read team users from team $($item.DisplayName)"
        }
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}

#endregion

#region (NOT) BREAKING THE LAW - JUDAS PRIEST
# Configure settings in Teams

Get-Team | Set-Team -AllowGiphy $true -AllowStickersAndMemes $false -AllowAddRemoveApps $false -AllowGuestDeleteChannels $false -AllowDeleteChannels $false
Get-Team | Set-Team -AllowGiphy $false



Set-Team -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74 -Description "New Description" 

Set-Team -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -AllowUserDeleteMessages $false 
#endregion

#region THE POLICY OF TRUTH - DEPECHE MODE
# Manage Policies
Get-CsPolicyPackage

Grant-CsUserPolicyPackage -Identity angus.young@kraichgau-touristik.de -PackageName Frontline_manager
#endregion

#region SHOW ME THE WAY - PETER FRAMPTON
# Get help and additional ressources

#Microsoft Teams PowerShell Overview
Start-Process "https://docs.microsoft.com/en-us/microsoftteams/teams-powershell-overview"

#Microsoft Teams PowerShell Module Reference
Start-Process "https://docs.microsoft.com/en-us/powershell/module/teams/?view=teams-ps"

#Microsoft Teams PowerShell Module on the PowerShell Gallery
Start-Process "https://www.powershellgallery.com/packages/MicrosoftTeams"

#Manage Teams with PowerShell
Start-Process "https://docs.microsoft.com/en-us/microsoftteams/teams-powershell-managing-teams"

#Use Teams Webhooks with PowerShell
Start-Process "https://www.scriptrunner.com/en/blog/teams-webhooks-via-powershell-part-1"

#8-page Cheat Sheet for Microsoft Teams PowerShell Module
Start-Process "https://lp.scriptrunner.com/en/teams-cheat-sheet"

#Ready-to-use PowerShell scripts for Microsoft Teams use cases
Start-Process "https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams"
#endregion

#Archive Teams
Set-TeamArchivedState -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -Archived:$true

Get-Team | Where-Object Archived -EQ $true

$user = get-MgUser -Filter "DisplayName eq '<User Name>'"
 get-MgUserJoinedTeam -UserId $user.Id
