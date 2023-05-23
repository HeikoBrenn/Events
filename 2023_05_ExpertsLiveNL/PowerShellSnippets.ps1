#region GET THE PARTY STARTED - P!NK
start-process "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\Brave.exe" https://www.youtube.com/watch?v=mW1dbiD_zDk
#Microsoft Teams
Import-Module MicrosoftTeams

#Exchange Online
Install-Module -Name ExchangeOnlineManagement

#Azure
Install-Module -Name Az
Install-Module -Name Az.Compute

#AzureAD
Install-Module AzureAD

#VMWare
Install-Module -Name "VMware.PowerCLI" -Scope AllUsers
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope AllUsers
#endregion

#region CONNECTED - STEREO MC'S
start-process "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\Brave.exe" https://www.youtube.com/watch?v=LOtTxfvvY00
#Microsoft Teams
Connect-MicrosoftTeams

#Exchange Online
Connect-ExchangeOnline

#Azure
Connect-AzAccount

#AzureAD
Connect-AzureAD

#VMware
$Server = '10.0.75.1' #Home
Connect-VIServer -server $server -Port 443

#endregion

#region YOU CAN GET IT IF YOU REALLY WANT - JIMMY CLIFF
start-process "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\Brave.exe" https://www.youtube.com/watch?v=0hKc-mxGp-g
##Microsoft Teams

# Top 10 Teams users (Owner/Member)
$Teams = Get-Team
$Top10Owners = foreach ($Team in $Teams) { Get-TeamUser -GroupId $Team.GroupId | where {$_.Role -eq "Member"} } 
($Top10Owners | Group-Object User -NoElement) | Format-Table -AutoSize | Select-Object -First 10


##Exchange Online

#Show all users with "Send As" permissions
Get-Mailbox | foreach {
(Get-RecipientPermission -Identity $_.userprincipalname | where{ -not (($_.Trustee -match "NT AUTHORITY") -or ($_.Trustee -match "S-1-5-21"))}) | select Identity,trustee}

#Show emails based on status (delivered, failed...)
Get-MessageTrace -StartDate ((Get-Date).AddDays(-10)) -EndDate (Get-Date) | Where-Object {$_.Status -eq "Delivered"} | Select-Object Received,SenderAddress,RecipientAddress,Subject,Status|Out-GridView

##Azure

#Find all running Azure VMs with name "test*" and stop them
Get-AzVM -Status |Where {$_.PowerState -eq "VM running" -and $_.Name -like 'test*'} |Stop-AzVM -force -AsJob -Whatif

#Show current Azure consumption
Get-AzConsumptionusagedetail | Sort-Object Pretaxcost -desc | Select-Object -first 10 |ft BillingPeriodname,ConsumedService,Instancename,@{label='PreTaxCost';expression={"{0:N2}" -f $_.PretaxCost}}, Currency


##AzureAD
#Show all Azure AD users with specific properties
Get-AzureADUser | Select Givenname, Surname, UserPrincipalName, Country, State, City, Department |ft

##Active Directory

#Find users that have not login in for a long time (and disable these users)
$When = ((Get-Date).AddDays(-30)).Date
Get-ADUser -Filter {LastLogonDate -lt $When} -SearchBase 'OU=UK,OU=EMEA,DC=company,DC=net' -Properties * | select-object samaccountname,givenname,surname,LastLogonDate,distinguishedname |Disable-ADAccount -WhatIf

#VMware

#Show all snapshots from all VMs
Get-VM |Get-Snapshot |ft -Property VM,Description, Name, Created 

#endregion

#region MESSAGE IN A BOTTLE - THE POLICE
start-process "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\Brave.exe" https://www.youtube.com/watch?v=MbXWrmQW-OE

# Push messages to Teams channels

$WebhookURL = 'https://scriptrunner1.webhook.office.com/webhookb2/c93cc6d0-88ba-44f5-b598-b5b5fb4c5b5d@30f65c4b-8dc9-4f07-912a-7fa0bf6715b9/IncomingWebhook/bd0b6d30754f4c9d816f1952d95ec79d/aedbe5f7-f6ad-48db-8b1f-cb3a79737494'
$Message = "Please be kind and stay healthy"
$Title = "Our daily message $(Get-date)"
$MessageColor = "green"
SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title -MessageColor $MessageColor
#endregion

#region DREADLOCK HOLIDAY - 10CC
start-process "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\Brave.exe" https://youtu.be/fI2FC36lXXQ?t=7

# Managing Out of Office notifications

#Show existing Autoreply notification settings
Get-Mailbox | Get-MailboxAutoReplyConfiguration -ResultSize unlimited |Out-GridView

#Set OOF in O365 with start and end date (mutiple users)
$Users = Get-Content C:\test\myusers.txt
$(foreach ($User in $Users) {

Set-MailboxAutoReplyConfiguration $User –AutoReplyState Scheduled –StartTime “7/22/2023” –EndTime “8/15/2023” –ExternalMessage "Our current tour is canceled. I'm working from home at the moment. Stay healthy." –InternalMessage "Our current tour is canceled. I'm working from home at the moment."
}

#endregion

#region LET ME IN - BEATSTEAKS
start-process "C:\Program Files (x86)\BraveSoftware\Brave-Browser\Application\Brave.exe" https://youtu.be/8MGZ_SsL0AE?t=70
#Reset AD user password
$NewPassword = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force
Set-ADAccountPassword -Identity Tom -NewPassword $NewPassword -Reset
Set-ADUser -Identity Tom -ChangePasswordAtLogon $true


#Reset a password for an Azure AD user
$user = Get-AzureADUser -Filter "userPrincipalName eq 'Test.user15@kraichgau-touristik.de'"
$Password = ConvertTo-SecureString "Admin123!" -AsPlainText -Force
Set-AzureADUserPassword -ObjectId $user.ObjectId -Password $password -ForceChangePasswordNextLogin $true
#endregion

