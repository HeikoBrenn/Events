#region Install PowerShell Modules

$Modules = @(
    "ExchangeOnlineManagement",
    "MicrosoftTeams",
    "Microsoft.Online.SharePoint.PowerShell",
    "PnP.PowerShell",
    "AzureAD",
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Groups",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Users.Actions",
    "Microsoft.Graph.Identity.DirectoryManagement",
    "Microsoft.Graph.Teams",
    "PSAI"
)
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module -Name $Modules -AcceptLicense -Repository PSGallery


#endregion


#region Connect to M365 Services

$cred = Get-Credential -Credential scriptrunner@demo01.onmicrosoft.com

Connect-ExchangeOnline -Credential $cred -ShowBanner:$false

Connect-IPPSSession -Credential $cred -ShowBanner:$false

Connect-MicrosoftTeams -Credential $cred

$tenant = 'xxxxxx'

Import-Module -Name PNP.PowerShell

$env:ENTRAID_APP_ID = 'xxxx' 
Connect-PnPOnline "https://$tenant-admin.sharepoint.com" -Interactive 

Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, Team.ReadBasic.All, TeamSettings.ReadWrite.All, Group.ReadWrite.All, openid, profile,email

#region AI Key
$env:OpenAIKey = 'xxxxxxx'
#endregion

#endregion


#region EXCHANGE ONLINE


#region Show | Change Mailbox Settings


#Show Retention Settings for specific group
Get-UnifiedGroupLinks -Identity "Finance" -LinkType Members | Get-Mailbox | Select-Object Displayname, PrimarySmtpAddress, RetainDeletedItemsFor

#Show Retention Settings for all users
Get-UnifiedGroupLinks -Identity * -LinkType Members | Get-Mailbox | Select-Object Displayname, PrimarySmtpAddress, RetainDeletedItemsFor

#Change Retention Setting for specific group
Get-UnifiedGroupLinks -Identity "Finance" -LinkType Members | ForEach-Object { Set-Mailbox -Identity $_.PrimarySmtpAddress -RetainDeletedItemsFor 10 -WhatIf }

#Show Autoprocessing settings
Get-Mailbox -ResultSize Unlimited | ForEach-Object { [PSCustomObject]@{ MailboxName = $_.Identity; AutomateProcessing = (Get-CalendarProcessing -Identity $_.Identity).AutomateProcessing } } | Format-Table -AutoSize

#Change Autoprocessing setings
Get-MailBox | Where {$_.ResourceType -eq "Room"} | Set-CalendarProcessing -AutomateProcessing:AutoAccept


#Create new room mailboxes
( 0 .. 5 ) | % { New-Mailbox -Name "NY_MeetingRoom00$_" -Room }

#Delete Mailboxes
Get-Mailbox -Filter {Name -Like "NY_MeetingRoom*"} | Where {$_.ResourceType -eq "Room"}| Remove-Mailbox -Confirm:$False -WhatIf


#Delete all messages with a specific subject
New-ComplianceSearch -Name "Find and delete suspicious emails (DANGER 02)" -ExchangeLocation All -ContentMatchQuery 'Subject:"DANGER"' ; Start-ComplianceSearch -Identity "Find and delete suspicious emails" ; while ((Get-ComplianceSearch -Identity "Find and delete suspicious emails").Status -ne 'Completed') { Start-Sleep -Seconds 10 } ; New-ComplianceSearchAction -SearchName "Find and delete suspicious emails" -Purge -PurgeType HardDelete -WhatIf

#Check results of ComplianceSearch
$searches = Get-ComplianceSearch; foreach ($search in $searches){Get-ComplianceSearch $search.name | FL Name,Items,Size,JobProgress,Status}


#endregion


#region Message Tracking

#Show delivered message of last 10 days
Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.Status -eq "Delivered"} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status | Format-Table -AutoSize

#Show pending message of last 10 days
Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.Status -eq "Pending"} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status|FT

#Show delivered messages of the last 10 days for a specific sender address
Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.Status -eq "Delivered" -and $_.SenderAddress -eq "sradmin@yourdomain.onmicrosoft.com"} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status | Format-Table -AutoSize |Out-File ".\messagetrace_"+$SenderAddress+".txt"

#Show delivered messages of the last 10 days for a specific sender address and save the result in a txt file
$senderAddress = "kimwilde@yourdomain.onmicrosoft.com"; Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.Status -eq "Delivered" -and $_.SenderAddress -eq $senderAddress} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status | Format-Table -AutoSize | Out-File -FilePath "$($senderAddress -replace '@', '_').txt"

#Show all messages of the last 10 days for a specific sender address
Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.SenderAddress -eq "sradmin@yourdomain.onmicrosoft.com"} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status | Format-Table -AutoSize


#Show the top 5 mailboxes
Get-EXOMailbox -ResultSize Unlimited | Get-EXOMailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize -First 5

#Show the top 5 mailboxes and shows the total mailbox sizes
$allMailboxes = Get-EXOMailbox -ResultSize Unlimited | Get-EXOMailboxStatistics; $topMailboxes = $allMailboxes | Sort-Object TotalItemSize -Descending | Select-Object DisplayName,TotalItemSize -First 30; $sumMailboxSize = ($allMailboxes | ForEach-Object { [math]::Round([double]$_.TotalItemSize.Value.ToMB(), 2) } | Measure-Object -Sum).Sum; $topMailboxes | Format-Table -AutoSize; 'Total Mailbox Size: {0:N2} MB' -f $sumMailboxSize


#endregion


#region Show | Change Distribution Groups


#Show all Distribution Groups
Get-DistributionGroup |Select-Object Displayname, GroupType, PrimarySmtpAddress, Name, WhenCreated|Sort-Object WhenCreated -Descending|ft

#Create a new distribution group
New-DistributionGroup -Name "IT Administrators" -Alias itadmin -MemberJoinRestriction open

#Add all users to a distribution group
Get-mailbox | Add-DistributionGroupMember -Identity "IT Administrators"

#Add all users to a distribution group and check if user is already member of the group
Get-Mailbox | ForEach-Object { $mailbox = $_.PrimarySmtpAddress; if (-not (Get-DistributionGroupMember -Identity "IT Administrators" | Where-Object { $_.PrimarySmtpAddress -eq $mailbox })) { Add-DistributionGroupMember -Identity "IT Administrators" -Member $mailbox; Write-Output "Added $mailbox to IT Administrators" } else { Write-Output "$mailbox is already a member of IT Administrators" } }


#Remove all users from a group
Get-DistributionGroupMember -Identity 'IT Administrators' | Where-Object { $_.PrimarySmtpAddress -ne $null -and $_.PrimarySmtpAddress -ne "" } | ForEach-Object { Remove-DistributionGroupMember -Identity 'IT Administrators' -Member $_.PrimarySmtpAddress -Confirm:$false }

#endregion


#region Configure Out-Of-Office Settings

#Show all OOF settings
Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited | Format-Table | Out-File OOF_Settings.txt

#Enable OOF for all mailboxes
Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Enabled -ExternalMessage "test"

#Schedule OOF for all mailboxes
Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Schedule -StartTime "10/22/2024 08:00:00" -EndTime "10/28/2024 17:00:00" -ExternalMessage "Our current tour is canceled. I'm working from home at the moment" -InternalMessage "Our current tour is canceled. I'm working from home at the moment."

#Enable OOF for a specific group
Get-DistributionGroupMember -Identity "IT Adminstrators" | ForEach-Object { Set-MailboxAutoReplyConfiguration -Identity $_.PrimarySmtpAddress -AutoReplyState Enabled -InternalMessage "I am currently out of the office and will respond to your email upon my return." -ExternalMessage "I am currently out of the office. I will respond to your message when I return." }

#Enable OOF for a specific group and push infos to a Teams channel
$webhookUrl = "https://yourdomain.webhook.office.com/webhookb2/5f1a1898-a613-46ad-b9aa-e8c03966023c@aad7eb5d-eae1-4de2-8f8f-0694e868ff75/IncomingWebhook/679b42a541cd4b718bc02b7e4a933c0e/d581a13d-546f-4b46-9b24-e76f9296ee18"; $userInfoList = @(); Get-DistributionGroupMember -Identity "IT Administrators" | ForEach-Object { Set-MailboxAutoReplyConfiguration -Identity $_.PrimarySmtpAddress -AutoReplyState Enabled -InternalMessage "I am currently out of the office and will respond to your email upon my return." -ExternalMessage "I am currently out of the office. I will respond to your message when I return."; $userInfoList += "Auto-reply enabled for: $($_.PrimarySmtpAddress)<br>" }; $messageBody = @{ text = $userInfoList -join "`n" } | ConvertTo-Json; Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType 'application/json' -Body $messageBody | Out-Null

#endregion

#endregion


#region MICROSOFT TEAMS

#region Show | Change Teams Settings

#Show all Channels in all Teams
Get-Team | Get-TeamChannel | Select-Object *

#Show archive state of specific Teams
Get-Team | Where-Object {$_.Displayname -Like "Test*"-AND $_.Archived -EQ $true}

#Set Archive state for specific Teams
Get-Team | Where-Object {$_.Displayname -Like "Test*"-AND $_.Archived -EQ $false} | Set-TeamArchivedState -Archived $true # NO -Whatif AVAILABLE

#Add a new Channel in all Teams
Get-Team | ForEach-Object { New-TeamChannel -GroupId $_.GroupId -DisplayName "TestChannel01" }

#Add a new Channel in all Teams with "Test" and check if it is already existing
Get-Team | Where-Object {$_.Displayname -Like "Test*"} | ForEach-Object { if (-not (Get-TeamChannel -GroupId $_.GroupId | Where-Object { $_.DisplayName -eq "NewChannel02" })) { New-TeamChannel -GroupId $_.GroupId -DisplayName "NewChannel02" -MembershipType Shared } }

#Check if a specific channel is existing 
$channelName = "NewChannel02"; Get-MgTeam -All | ForEach-Object { $teamId = $_.Id; $teamName = $_.DisplayName; if (Get-MgTeamChannel -TeamId $teamId | Where-Object { $_.DisplayName -eq $channelName }) { "$channelName exists in team $teamName" } else { "$channelName does not exist in team $teamName" } }


#Remove a channel form all Teams
Get-Team | ForEach-Object { $channel = Get-TeamChannel -GroupId $_.GroupId | Where-Object { $_.DisplayName -eq "TechChannel01" }; if ($channel) { Remove-TeamChannel -GroupId $_.GroupId -DisplayName "TechChannel01" } }


#Add a new member to all Teams
Get-Team | ForEach-Object { Add-TeamUser -GroupId $_.GroupId -User "scriptrunner@yourdomain.onmicrosoft.com" -Role Owner }


#Add a new member to all Teams and check if the user is already member of the team
Get-Team | ForEach-Object { $groupId = $_.GroupId; $teamName = $_.DisplayName; $user = "angusyoung@yourdomain.onmicrosoft.com"; if (Get-TeamUser -GroupId $groupId | Where-Object { $_.User -eq $user }) { Write-Host "$user is already a member of the team '$teamName'" } else { Add-TeamUser -GroupId $groupId -User $user -Role Owner; Write-Host "$user has been added as an owner to the team '$teamName'" } }


#Remove a user from all Teams
Get-Team | ForEach-Object { if (Get-TeamUser -GroupId $_.GroupId | Where-Object { $_.User -eq "angusyoung@yourdomain.onmicrosoft.com" }) { Remove-TeamUser -GroupId $_.GroupId -User "angusyoung@yourdomain.onmicrosoft.com" } }

#Rename channel in all Teams
Get-MgTeam -All | ForEach-Object { $teamId = $_.Id; Get-MgTeamChannel -TeamId $teamId | Where-Object { $_.DisplayName -eq 'TestChannel01' } | ForEach-Object { Update-MgTeamChannel -TeamId $teamId -ChannelId $_.Id -DisplayName 'TestChannel02' } }


#endregion

#region Analyzing Teams


#Show Top 10 Members in Teams
(Get-Team | ForEach-Object { Get-TeamUser -GroupId $_.GroupId | Where-Object { $_.Role -eq "Member" } } | Group-Object User -NoElement | Sort-Object Count -Descending | Select-Object -First 10) | Format-Table -AutoSize

#Show all Guests in Teams
Get-Team | ForEach-Object { Get-TeamUser -GroupId $_.GroupId | Where-Object { $_.Role -eq "Guest" } | Select-Object User, Role, @{n='TeamName';e={$_.DisplayName}} } | Export-Csv -Path .\GuestsInTeams.txt -NoTypeInformation

#Find Teams with only one owner
Get-Team | Where-Object { (Get-TeamUser -GroupId $_.GroupId | Where-Object { $_.Role -eq 'Owner' }).Count -eq 1 }

#Find Teams with only one owner and show more details
Get-Team | Where-Object { (Get-TeamUser -GroupId $_.GroupId | Where-Object { $_.Role -eq 'Owner' }).Count -eq 1 } | Select-Object DisplayName, @{Name='Owner'; Expression={(Get-TeamUser -GroupId $_.GroupId | Where-Object { $_.Role -eq 'Owner' }).User}}, Visibility, Description, Archived | Format-Table -AutoSize

#endregion

#region Push Message to Teams channel
Invoke-RestMethod -Uri "https://yourdomain.webhook.office.com/webhookb2/5f1a1898-a613-46ad-b9aa-e8c03966023c@aad7eb5d-eae1-4de2-8f8f-0694e868ff75/IncomingWebhook/679b42a541cd4b718bc02b7e4a933c0e/d581a13d-546f-4b46-9b24-e76f9296ee18" -Method Post -ContentType 'application/json' -Body (@{summary="PowerShell Test Message"; themeColor="00FF00"; text="**Test Message Header**<br>This is a test message sent from PowerShell."} | ConvertTo-Json)


#endregion

#endregion


#region SHAREPOINT ONLINE

#Create a new SharePoint Site
New-PnPSite -Type CommunicationSite -Title "New Site 002" -Url "https://yourdomain.sharepoint.com/sites/NewSite002" -Owner "sradmin@yourdomain.onmicrosoft.com"


#Create a new SharePoint Site and check if its already existing
if (-not (Get-PnPTenantSite -Url "https://yourdomain.sharepoint.com/sites/NewSite004" -ErrorAction SilentlyContinue)) { New-PnPSite -Type CommunicationSite -Title "New Site 004" -Url "https://yourdomain.sharepoint.com/sites/NewSite004" -Owner "scriptrunner@yourdomain.onmicrosoft.com"; Write-Host "Site created." } else { Write-Host "Site already exists." }


( 0 .. 5 ) | % { New-PnPSite -Type CommunicationSite -Title "New Site 30$_" -Url "https://yourdomain.sharepoint.com/sites/NewSite30$_" -Owner "scriptrunner@yourdomain.onmicrosoft.com" }



#Set Owner for SharePoint Site
Set-PnPTenantSite -Identity "https://yourdomain.sharepoint.com/sites/NewSite002" -Owners "kimwilde@yourdomain.onmicrosoft.com"


Get-PnPTenantSite | Where-Object { $_.Url -like "*Test*" } |Select-Object Title, Url, Owner, Template
Get-PnPTenantSite | Where-Object { $_.Template -eq "SITEPAGEPUBLISHING#0" -AND $_.Url -like "*NewSite30*" } | Select-Object Title, Url, Owner, Template



# Specify the new owner for one site
$newOwner = "kimwilde@yourdomain.onmicrosoft.com"


#Specify the new owner for multiple sites
$newOwner = "angusyoung@yourdomain.onmicrosoft.com"; Get-PnPTenantSite | Where-Object { $_.Template -like "SITEPAGEPUBLISHING#0" -AND $_.Url -like "*NewSite30*" } | ForEach-Object { Write-Host "Updating owner for site: $($_.Url)"; Set-PnPTenantSite -Identity $_.Url -PrimarySiteCollectionAdmin $newOwner }

#endregion


#region LICENSE MANAGEMENT


#Show license for a specific user
Get-MgUserLicenseDetail -UserId angusyoung@yourdomain.onmicrosoft.com

#Show License infos for all users
Get-MgUser -All | ForEach-Object { $userUPN = $_.UserPrincipalName; Get-MgUserLicenseDetail -UserId $_.Id | Select-Object @{Name='UserPrincipalName';Expression={$userUPN}}, SkuId, ServicePlans }

#Show License infos for all users with all service plan details
Get-MgUser -All | ForEach-Object { $userUPN = $_.UserPrincipalName; Get-MgUserLicenseDetail -UserId $_.Id | ForEach-Object { $_.ServicePlans | Select-Object @{Name='UserPrincipalName';Expression={$userUPN}}, SkuId, ServicePlanName, ProvisioningStatus } } | Format-Table -AutoSize | Out-File .\licenses.txt

#Show License where Provisioning Status is not "Success"
Get-MgUser -All | ForEach-Object { $userUPN = $_.UserPrincipalName; Get-MgUserLicenseDetail -UserId $_.Id | ForEach-Object { $_.ServicePlans | Where-Object { $_.ProvisioningStatus -ne 'Success' } | Select-Object @{Name='UserPrincipalName';Expression={$userUPN}}, SkuId, ServicePlanName, ProvisioningStatus } } | Format-Table -AutoSize

#Find unlicesend user
Get-MgUser -Filter 'assignedLicenses/$count eq 0' -ConsistencyLevel eventual -CountVariable unlicensedUserCount -All

#Assign license to single user
Set-MgUserLicense -UserId "kimwilde@yourdomain.onmicrosoft.com" -AddLicenses @{SkuId = (Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq 'DEVELOPERPACK_E5' }).SkuId} -RemoveLicenses @()

#Assign licenses to all members of a group
Get-MgGroup -Filter "DisplayName eq 'IT Administrators'" | ForEach-Object { Get-MgGroupMember -GroupId $_.Id -All } | ForEach-Object { Set-MgUserLicense -UserId $_.Id -AddLicenses @{SkuId = (Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq 'DEVELOPERPACK_E5' }).SkuId} -RemoveLicenses @() }

#Copy the license assignments from another user
Set-MgUserLicense -UserId "kimwilde@yourdomain.onmicrosoft.com" -AddLicenses (Get-MgUser -UserId "angusyoung@yourdomain.onmicrosoft.com" -Property AssignedLicenses).AssignedLicenses -RemoveLicenses @()

#Remove license to single user
Set-MgUserLicense -UserId "kimwilde@yourdomain.onmicrosoft.com" -RemoveLicenses @((Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq 'DEVELOPERPACK_E5' }).SkuId) -AddLicenses @{}


#endregion


#region FUN
$joke = "**Chuck Norris Joke of the Day:**<br>$((Invoke-RestMethod https://api.chucknorris.io/jokes/random).value)"; $null = Invoke-RestMethod -Uri "https://yourdomain.webhook.office.com/webhookb2/5f1a1898-a613-46ad-b9aa-e8c03966023c@aad7eb5d-eae1-4de2-8f8f-0694e868ff75/IncomingWebhook/679b42a541cd4b718bc02b7e4a933c0e/d581a13d-546f-4b46-9b24-e76f9296ee18" -Method Post -ContentType 'application/json' -Body (@{summary = "Chuck Norris Joke"; themeColor = "00FF00"; text = $joke} | ConvertTo-Json)


#Show all countries and capitols of Europe and push it to a Teams channel
$Europe = (Invoke-RestMethod -Uri "https://restcountries.com/v3.1/all") | Where-Object { $_.region -eq "Europe" } | Select-Object @{Name='Country';Expression={$_.name.common}}, @{Name='Capital';Expression={$_.capital[0]}} | Sort-Object -Property Country | ConvertTo-Json ; $null = Invoke-RestMethod -Uri "https://yourdomain.webhook.office.com/webhookb2/5f1a1898-a613-46ad-b9aa-e8c03966023c@aad7eb5d-eae1-4de2-8f8f-0694e868ff75/IncomingWebhook/679b42a541cd4b718bc02b7e4a933c0e/d581a13d-546f-4b46-9b24-e76f9296ee18" -Method Post -ContentType 'application/json' -Body (@{text = $Europe} |ConvertTo-Json)

#Show trivia of the current day and push it into Teams channel
$today=Get-Date -Format "MM/dd"; $url="http://numbersapi.com/$($today -replace '/','/')/date"; $trivia = "**Trivia for today's date ($today):**<br> $(Invoke-RestMethod -Uri $url)" ; $null = Invoke-RestMethod -Uri "https://yourdomain.webhook.office.com/webhookb2/5f1a1898-a613-46ad-b9aa-e8c03966023c@aad7eb5d-eae1-4de2-8f8f-0694e868ff75/IncomingWebhook/679b42a541cd4b718bc02b7e4a933c0e/d581a13d-546f-4b46-9b24-e76f9296ee18" -Method Post -ContentType 'application/json' -Body (@{text = $trivia} | ConvertTo-Json)

#Show random picture of a dog
$localFilePath=".\randomdog.jpg"; $dogImageUrl=(Invoke-RestMethod -Uri "https://dog.ceo/api/breeds/image/random").message; Invoke-WebRequest -Uri $dogImageUrl -OutFile $localFilePath; Copy-Item $localfilepath /mnt/c/test/ | Start-Process '/mnt/c/Program Files/IrfanView/i_view64.exe' C:\test\randomdog.jpg


#endregion
