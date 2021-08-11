Find-Module -Name MicrosoftTeams | Install-Module -Scope AllUsers
Import-Module MicrosoftTeams

Get-Module -Name MicrosoftTeams* -ListAvailable | select Name,Version,Path
get-command -type Cmdlet -module MicrosoftTeams
get-command -module MicrosoftTeams
get-command -module MicrosoftTeams |Measure-Object

$cred = Get-Credential
Connect-MicrosoftTeams -Credential $cred
Connect-MicrosoftTeams
Disconnect-MicrosoftTeams

Get-Team

Get-Team -DisplayName wfh

 

Get-team | get-teamuser

Get-TeamUser -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74

Get-TeamUser -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74 -Role owner

#Find Guest user in Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Get-TeamUser -GroupId $Team.GroupId | where {$_.Role -eq "Guest"} | Select User, Role, @{n='TeamName';e={$Team.DisplayName} } }

#Show all channels in all Teams
$Teams = Get-Team
$List = foreach ($Team in $Teams) { Get-TeamChannel -GroupId $Team.GroupId | Select-Object @{n='TeamName';e={$Team.DisplayName} }, @{n='ChannelName';e={$_.DisplayName} }, Description  }
$ChannelCount = ($List.DisplayName).Count

Write-Host Total Teams :: $Teams.count -ForegroundColor Green
Write-Host Total Channels :: $ChannelCount -ForegroundColor Green

$List

#Show a specific channels in all Teams
$Teams = Get-Team
$List = foreach ($Team in $Teams) { Get-TeamChannel -GroupId $Team.GroupId | Where-Object {$_.Displayname -Like "Venues"} |  Select-Object @{n='TeamName';e={$Team.DisplayName} }, @{n='ChannelName';e={$_.DisplayName} }, Description  }
$ChannelCount = ($List.DisplayName).Count

Write-Host Total Teams :: $Teams.count -ForegroundColor Green
Write-Host Total Channels :: $ChannelCount -ForegroundColor Green

$List

# Show Guest users in all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Get-TeamUser -GroupId $Team.GroupId | where {$_.Role -eq "Guest"} | Select User, Role, @{n='TeamName';e={$Team.DisplayName} } }


# Remove a specific channel from all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Remove-TeamChannel  -GroupId $Team.GroupId -DisplayName "Catering"}

# Remove a specific user from all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Remove-TeamUser -GroupId $Team.GroupId -User angus.young@kraichgau-touristik.de -Role Member }

# Add a specific user to all Teams
$Teams = Get-Team
foreach ($Team in $Teams) { Add-TeamUser -GroupId $Team.GroupId -User angus.young@kraichgau-touristik.de -Role Member}

# Top 10 Teams Owner/Member
$Teams = Get-Team
$Top10Owners = foreach ($Team in $Teams) { Get-TeamUser -GroupId $Team.GroupId | where {$_.Role -eq "Member"} } 
($Top10Owners | Group-Object User -NoElement) | Format-Table -AutoSize | Select-Object -First 10

# Summary of my Teams
# Originally from https://sid-500.com/2020/12/14/microsoft-teams-list-all-teams-team-members-and-team-channels/
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

##########



New-Team -DisplayName "WorkFromHome2021" -Description "WfH collaboration" -Visibility Public -AllowGiphy $false


#Create multiple Teams 

$Teams = Get-Content C:\test\myteams.txt
$(foreach ($Team in $Teams) {

New-Team –Displayname $Team -Description "Collaboration for $Team" -Visibility Private

})

Add-TeamUser -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -User "angus.young@kraichgau-touristik.de"

New-TeamChannel -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -DisplayName "Events Asia 2022"

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


Set-Team -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74 -Description "New Description" 

Set-Team -GroupId 33a5febc-9087-4adf-b684-4d12477edf01 -AllowUserDeleteMessages - - $false 

Set-Team -GroupId 080e8d6f-e931-4bf6-95a7-afff755df127 -AllowGiphy $false

Set-TeamArchivedState -GroupId e9957be5-547c-4a5e-8ea1-fafd070509b7 -Archived:$true

Remove-Team -GroupId 59d04b2f-9f79-4ee3-984f-bde6025a9cbd

$WebhookURL = 'https://outlook.office.com/webhook/87973ca6-1d50-42dc-b8a4-f20cfd11a45c@30f65c4b-8dc9-4f07-912a-7fa0bf6715b9/IncomingWebhook/36566f3279344e5b95170a3debceb3af/aedbe5f7-f6ad-48db-8b1f-cb3a79737494'
$Message = "Please be kind and stay healthy"
$Title = "Corona crisis - daily message $(Get-date)"
$MessageColor = "red"
SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title -MessageColor $MessageColor

Get-CsPolicyPackage

Grant-CsUserPolicyPackage -Identity angus.young@kraichgau-touristik.de -PackageName Education_PrimaryStudent
