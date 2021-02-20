# =================================================================
# Install PowerShell modules
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber
Import-Module -Name Microsoft.PowerApps.Administration.PowerShell

Get-Module -Name Microsoft.PowerApps* -ListAvailable | select Name,Version,Path
get-command -module Microsoft.PowerApps*
get-command -module Microsoft.PowerApps.Administration.Powershell |Measure-Object
get-command -module Microsoft.PowerApps.Powershell |Measure-Object
get-command -module Microsoft.PowerApps.Checker.Powershell |Measure-Object
# =================================================================
# This call opens prompt to collect credentials 
Add-PowerAppsAccount

$pass = ConvertTo-SecureString "password" -AsPlainText -Force
Add-PowerAppsAccount -Username user@company.com -Password $pass

# ===========================================================================
# POWERAPPS
# ===========================================================================
# Show existing environments in O365 tenant
Get-AdminPowerAppEnvironment
Get-AdminPowerAppEnvironment | Format-Table -Property EnvironmentName, DisplayName, CreatedBy, Location

# Show available locations
Get-AdminPowerAppEnvironmentLocations

# Create a new environment
New-AdminPowerAppEnvironment -DisplayName 'ScriptRunnerDEV2' -LocationName unitedstates -EnvironmentSku Production

# Delete existing environment
Remove-AdminPowerAppEnvironment -EnvironmentName 'f4edceff-19b9-49fa-b14b-3c6def79ee27'

# =================================================================
# Show existing PowerApps

$MyEnvironmentID = 'Default-30f65c4b-8dc9-4f07-912a-7fa0bf6715b9'

Get-AdminPowerApp | Where-Object {$_.EnvironmentName -eq $MyEnvironmentId } | Format-Table -Property DisplayName, CreatedTime, EnvironmentName 

# Show Owner of existing PowerApps
Get-AdminPowerApp | Where-Object {$_.EnvironmentName -eq $MyEnvironmentId } | Select AppName, CreatedTime -ExpandProperty Owner | Format-Table -Property AppName, CreatedTime, Displayname

# =================================================================
# Show Connections
Get-AdminPowerAppConnection | Where-Object {$_.EnvironmentName -eq $MyEnvironmentId } | SELECT ConnectorName,Statuses,DisplayName,Publisher

$allApps=Get-AdminPowerApp | Where-Object{$_.EnvironmentName -eq $MyEnvironmentId} | SELECT AppName,CreatedTime,EnvironmentName
foreach($app in $allApps) {
 $app.AppName
 Write-Output "========== `r`n"
 Get-AdminPowerAppConnectionReferences -EnvironmentName $MyEnvironmentId -AppName $app.AppName | SELECT ConnectorName,ConnectorId,DisplayName,Publisher
}

# ================================================================================
# Show PowerApp Ids that use a specific connector
$MyEnvironmentId ="Default-30f65c4b-8dc9-4f07-912a-7fa0bf6715b9";
$connectorname = "shared_office365";

$allApps = Get-AdminPowerApp | Where-Object {$_.EnvironmentName -eq $MyEnvironmentId} | SELECT AppName, CreatedTime, EnvironmentName

foreach ($app in $allApps) {
 
$Connectors = Get-AdminPowerAppConnectionReferences -EnvironmentName $MyEnvironmentId -AppName $app.AppName | Where-Object {$_.ConnectorName -eq $connectorname} | SELECT ConnectorName, ConnectorId, DisplayName, Publisher
$ConnectorCount = ($Connectors).Count

 if ($ConnectorCount -ne 0) {
 Write-Output $app.AppName
 }
}
# ===========================================================================
# Show custom connectors
Get-AdminPowerAppConnector | SELECT DisplayName, CreatedTime, CreatedBy 

# ===========================================================================
# Show all Administrator and Maker
Get-AdminPowerAppEnvironmentRoleAssignment | Where-Object {$_.EnvironmentName -eq $MyEnvironmentID} | SELECT RoleId, RoleName, RoleType,  PrincipalDisplayName, PrincipalType, PrincipalObjectId 

# ===========================================================================
# Show how many PowerApps are owened by which users
Get-AdminPowerApp | Select –ExpandProperty Owner | Select –ExpandProperty displayname | Group 


# Show permissions per user
$principals = Get-AdminPowerAppEnvironmentRoleAssignment | Where-Object {$_.EnvironmentName -eq $MyEnvironmentID} | SELECT RoleName, RoleType, PrincipalDisplayName, PrincipalType, PrincipalObjectId

Foreach ($principal in $principals)
{
 $principal.PrincipalDisplayName
 Write-Output "-------------------------"
 Get-AdminPowerAppRoleAssignment -UserId $principal.PrincipalObjectId | Where-Object {$_.EnvironmentName -eq $MyEnvironmentID } | Select PrincipalType, RoleType, AppName
}

# ===========================================================================
# POWER AUTOMATE
# ===========================================================================
# Show existing Automate objects
Get-AdminFlow 
Get-AdminFlow | Where-Object {$_.EnvironmentName -eq $MyEnvironmentId } | Format-Table -Property DisplayName, CreatedTime, Enabled, EnvironmentName 

#Enabled Flows
Get-AdminFlow | Where-Object {$_.EnvironmentName -eq $MyEnvironmentId -and $_.Enabled -eq $true } | Format-Table -Property DisplayName, CreatedTime, Enabled, EnvironmentName 

Get-AdminFlow | Select –ExpandProperty CreatedBy | Select –ExpandProperty UserId | Group 


# ===========================================================================
# Disable/Enable Flows

Disable-AdminFlow -EnvironmentName $MyEnvironmentId -FlowName '124b72ab-3c07-48eb-aae4-6ee45b214719' 
Enable-AdminFlow -EnvironmentName $MyEnvironmentId -FlowName '124b72ab-3c07-48eb-aae4-6ee45b214719'

# ===========================================================================
# Delete Flows
Remove-AdminFlow -EnvironmentName $MyEnvironmentId -FlowName $YourFlowId 

# ===========================================================================
# Show and Change Roles in Flows

Get-AdminFlowOwnerRole –EnvironmentName $MyEnvironmentId –FlowName '4dcce14e-80c9-45d1-b727-b82b6332b039' |Out-GridView

Set-AdminFlowOwnerRole -PrincipalType User -PrincipalObjectId '5dc2643c-f5b4-4fe9-ab36-afea676839ad' -RoleName CanEdit -FlowName '124b72ab-3c07-48eb-aae4-6ee45b214719' -EnvironmentName $MyEnvironmentId 

