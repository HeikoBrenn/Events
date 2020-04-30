#START OFFICE 365 SESSION

$UserCredential = Get-Credential user@domain.com
Connect-MsolService -Credential $UserCredential


$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/?proxymethod=rps" -Credential $UserCredential -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession

Get-MsolUser

#------------------------------------------------------------------------------------
#ActiveSync

Get-CASMailbox
Get-ActiveSyncMailboxPolicy
Get-MobileDeviceMailboxPolicy

Set-CASMailbox -Identity kim.wilde -ActiveSyncEnabled $true -ActiveSyncDebugLogging $true -ActiveSyncMailboxPolicy Default

Get-CASMailbox -Resultsize Unlimited |Set-CASMailbox -ActiveSyncEnabled $true

Get-User -Filter "RecipientType -eq 'UserMailbox' -and Department -like 'IT*'" | Set-CasMailbox -ActiveSyncEnabled $false


#------------------------------------------------------------------------------------

#Get OOF in O365

Get-MailboxAutoReplyConfiguration -Identity bryan.adams@kraichgau-touristik.de

Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited
Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited |Out-GridView

#-------------------------------------------------------------------------------------

#Set OOF in O365

Set-MailboxAutoReplyConfiguration -Identity bryan.adams@kraichgau-touristik.de -AutoReplyState Enabled -ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." -InternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy."

#-------------------------------------------------------------------------------------

#Set OOF in O365 with start and end date

Set-MailboxAutoReplyConfiguration -Identity bryan.adams@kraichgau-touristik.de -AutoReplyState Schedule -StartTime "4/22/2020 08:00:00" -EndTime "6/15/2020 17:00:00" -ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." -InternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy."

#-------------------------------------------------------------------------------------

#Set OOF in O365 with start and end date (mutiple users)

$Users = Get-Content C:\test\myusers.txt
$(foreach ($User in $Users) {

Set-MailboxAutoReplyConfiguration $User –AutoReplyState Scheduled –StartTime “4/22/2020” –EndTime “6/15/2020” –ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." –InternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy."

})

#-------------------------------------------------------------------------------------

#Disable OOF in O365

Set-MailboxAutoReplyConfiguration -Identity bryan.adams@kraichgau-touristik.de -AutoReplyState Disabled

#-------------------------------------------------------------------------------------

#Disable OOF in O365 (mutiple users)

$Users = Get-Content C:\test\myusers.txt
$(foreach ($User in $Users) {

Set-MailboxAutoReplyConfiguration $User –AutoReplyState Disabled -Verbose

})

