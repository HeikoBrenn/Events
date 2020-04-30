Find-Module -Name MicrosoftTeams | Install-Module -Scope AllUsers
Import-Module MicrosoftTeams

Get-Module -Name MicrosoftTeams* -ListAvailable | select Name,Version,Path
get-command -type Cmdlet -module MicrosoftTeams
get-command -module MicrosoftTeams |Measure-Object

$cred = Get-Credential
Connect-MicrosoftTeams -Credential $cred
Connect-MicrosoftTeams
Disconnect-MicrosoftTeams

Get-Team

Get-Team | Where-Object {$_.MailNickName -like '*test*'}

Get-team | get-teamuser

Get-TeamUser -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74

Get-TeamUser -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74 -Role owner



New-Team -DisplayName "WorkFromHome" -Description "WfH collaboration" -Visibility Public 


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

Remove-Team -GroupId 59d04b2f-9f79-4ee3-984f-bde6025a9cbd

$WebhookURL = 'https://outlook.office.com/webhook/87973ca6-1d50-42dc-b8a4-f20cfd11a45c@30f65c4b-8dc9-4f07-912a-7fa0bf6715b9/IncomingWebhook/36566f3279344e5b95170a3debceb3af/aedbe5f7-f6ad-48db-8b1f-cb3a79737494'
$Message = "Please be kind and stay healthy"
$Title = "Corona crisis - daily message $(Get-date)"
$MessageColor = "red"
SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title -MessageColor $MessageColor


Get-CsPolicyPackage

Grant-CsUserPolicyPackage -Identity angus.young@kraichgau-touristik.de -PackageName Education_PrimaryStudent
