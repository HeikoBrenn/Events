
# Cloud Shell examples


uname -a

Get-Clouddrive
Get-AZVM
Get-AZVM -status
Get-AzVM -ResourceGroupName "IgniteTheTour" -status

get-azvm -Status |Where PowerState -eq "VM running"
get-azvm -Status |Where PowerState -eq "VM deallocated" |start-azvm 

get-azvm -status | select Name, Location, LicenseType, Plan, Type, OSProfile, powerstate

New-azvm -ResourceGroupName ScriptRunnerDemo -name test-HeikoVM01 -Location 'West Europe' -Image UbuntuLTS -size 'Standard_D1_v2'

Enable-AzVMPSRemoting -Name 'test-vm001' -ResourceGroupName 'ScriptRunnerDEMO' -Protocol ssh -OsType Linux
enter-azvm -name test-heikovm01  -ResourceGroupName ScriptRunnerDemo -Credential $cred


Get-AzConsumptionusagedetail | sort-Object Pretaxcost -desc | Select-Object -first 10 |ft BillingPeriodname,ConsumedService,Instancename,Pretaxcost,Currency
Get-AzSqlServer

Get-module
Connect-Exopssession
get-mailbox
get-mailboxplan

cd azure:
dir





# AZ MODULE ++++++++++++++++++++++++++++++++++++++

Start-Transcript

Install-Module -Name Az

#AZ CmdLets
get-command -type Cmdlet -module Az.*
get-command -type Cmdlet -module Az.Compute |Measure-Object

# Start Azure PowerShell session
Connect-AzAccount -credential $cred

#Disconnect from Azure
Disconnect-AzAccount


get-azvm -status | select Name, Location, LicenseType, Plan, Type, OSProfile, powerstate |Out-GridView
Start-AzVM -name ScriptRunner1 -ResourceGroupName IgniteTheTour
Stop-azvm -ResourceGroupName IgniteTheTour -name ScriptRunner1 -force

New-azvm -ResourceGroupName IgniteTheTour -name test-HeikoVM01 -Location 'West Europe' -Image UbuntuLTS -size 'Standard_D1_v2' -

$cred
New-azvm -ResourceGroupName IgniteTheTour -name test-HeikoVM03 -Location 'West Europe' -Image UbuntuLTS -size 'Standard_D1_v2'

get-azlocation
get-azlocation | Measure-Object
Get-AzLocation | Where-Object {$_.Providers -contains "Microsoft.AppConfiguration"}
Get-AzLocation | Where-Object {$_.Providers -contains "Microsoft.AppConfiguration"} | Measure-Object

Get-AZVMSize -Location "eastus"
Get-AZVMSize -Location "eastus" | Out-GridView
Get-AZVMSize -Location "eastus" | Where-Object NumberOfCores -EQ 4
Get-AZVMSize -Location "eastus" | Where-Object {($_.NumberOfCores -EQ 4) -and ($_.MemoryInMB -eQ 16384)} |Measure-Object








New-AzVm `
    -ResourceGroupName "IgniteTheTour" `
    -Name "Test-VM-002" `
    -Location "westeurope" `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "test1" `
    #-PublicIpAddressName "myPublicIpAddress" `
    -OpenPorts 80,3389
    -Size "Standard_DS1_v2"
 



Enable-AzVMPSRemoting -Name Scriptrunner1 -ResourceGroupName ignitethetour -protocol https -ostype windows
Invoke-AzVMCommand -Name scriptrunner1 -ResourceGroupName IgniteTheTour -ScriptBlock {get-service win*} -Credential $cred
get-command |measure

Get-AzNetworkSecurityGroup | select name,subnets,type,location,NetworkInterfaces,securityrules
Get-AzConsumptionusagedetail | sort-Object Pretaxcost -desc | Select-Object -first 10 |ft BillingPeriodname,ConsumedService,Instancename,Pretaxcost,Currency
$a | ForEach-Object { New-Object -TypeName PSObject -Property @{ Name = $_.InstanceName; PreTaxCost = ("{0:n2}" -f  $_.PretaxCost) } } 

Connect-Exopssession
get-mailbox
set-mailboxautoreplyconfiguration -identity heiko.brenn -autoreplystate scheduled -Starttime "7/7/2020" -Endtime "8/8/2020" -ExternalMessage "I'm out of the office"


# -----STOP VM------
 $ResourceGroupName = "IgniteTheTour"
 $VMs = Get-AzVM -ResourceGroupName "$ResourceGroupName"
		
   Foreach ($VM in $VMs) {
		Stop-AzVM -ResourceGroupName "$ResourceGroupName" -Name $VM.Name -Force -NoWait
		}
  
# -----START VM------
 $ResourceGroupName = "IgniteTheTour"
 $VMs = Get-AzVM -ResourceGroupName "$ResourceGroupName"
		
   Foreach ($VM in $VMs) {
		Start-AzVM -ResourceGroupName "$ResourceGroupName" -Name $VM.Name -NoWait
		}


Remove-AzVM -Name test-heikovm01 -ResourceGroupName IGNITETHETOUR -force


Get-AzResource
cd $HOME\clouddrive
cd Azure:

$cred = Get-Credential
Connect-AzAccount -credential $cred
Disconnect-AzAccount

#Bicep ++++++++
New-AzResourceGroupDeployment -ResourceGroupName IGNITETHETOUR -TemplateFile <path-to-bicep>


#Azure SQLServer
New-AzSqlServer -ServerName heikosqltest001 -Location westeurope -ResourceGroupName ScriptRunnerDemo -SqlAdministratorCredentials (Get-Credential)
Get-AzSqlServer
New-AzSqlDatabase -DatabaseName test001 -ServerName heikosqltest001 -ResourceGroupName ScriptRunnerDemo
Get-Azsqldatabase -DatabaseName test001 -ServerName heikosqltest001 -ResourceGroupName ScriptRunnerDemo |Out-GridView

#Azure AD
Connect-AzureAD
Get-AzureADUser

#Creat an new AzureAD user
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "Admin123!"
New-AzureADUser -DisplayName "New User 001" -PasswordProfile $PasswordProfile -UserPrincipalName "testuser001@haraldpfirmanntonline.onmicrosoft.com" -AccountEnabled $true -MailNickName "Newuser001"


