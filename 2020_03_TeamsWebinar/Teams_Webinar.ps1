Find-Module -Name MicrosoftTeams | Install-Module -Scope AllUsers
Import-Module MicrosoftTeams

Get-Module -Name MicrosoftTeams* -ListAvailable | select Name,Version,Path
get-command -type Cmdlet -module MicrosoftTeams
get-command -type Cmdlet -module MicrosoftTeams |Measure-Object

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

New-Team –Displayname $Team -Description "Demo $Team" -Visibility Private

})

Add-TeamUser -GroupId 5639fdc5a-5570-4fa3-b2ad-a61f28c3e554 -User "annie.lennox@kraichgau-touristik.de"

New-TeamChannel -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74 -DisplayName "Events 2020"

$group = New-Team -MailNickname "Tour 2020 Test" -displayname "Tour 2020 Test" -Visibility "private"
Add-TeamUser -GroupId $group.GroupId -User "Angus.young@kraichgau-touristik.de"
Add-TeamUser -GroupId $group.GroupId -User "phil.collins@kraichgau-touristik.de"
Add-TeamUser -GroupId $group.GroupId -User "iggy.pop@kraichgau-touristik.de"
Add-TeamUser -GroupId $group.GroupId -User "kim.wilde@kraichgau-touristik.de"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Venues"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Catering"
New-TeamChannel -GroupId $group.GroupId -DisplayName "Rehearsal"


Set-Team -GroupId 521acc12-ecb9-4746-8e70-0475f9605e74 -Description "New Description"

Set-Team -GroupId cb38eadc-2a83-4854-b96f-76915b6ac002 -AllowUserDeleteMessages $false

Remove-Team -GroupId da8b1c0b-1a68-4175-a755-6ef8bf54eb16

$WebhookURL = 'https://outlook.office.com/webhook/87973ca6-1d50-42dc-b8a4-f20cfd11a45c@30f65c4b-8dc9-4f07-912a-7fa0bf6715b9/IncomingWebhook/36566f3279344e5b95170a3debceb3af/aedbe5f7-f6ad-48db-8b1f-cb3a79737494'
$Message = "Test Message Webinar Test 2"
$Title = "NEW MESSAGE"
$MessageColor = "red"
SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title -MessageColor $MessageColor
