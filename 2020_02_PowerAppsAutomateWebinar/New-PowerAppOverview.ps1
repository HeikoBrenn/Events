<#PSScriptInfo  
.VERSION 1.0
.GUID eb76a31b-e5f3-461d-8859-0e99593cb054
.AUTHOR 
 Maarten Peeters - Cloud Securitea - https://www.cloudsecuritea.com
.COMPANYNAME
 Cloud Securitea
.COPYRIGHT
.TAGS
 PowerApps, Administration
.LICENSEURI
.PROJECTURI 
.ICONURI
.EXTERNALMODULEDEPENDENCIES
 Microsoft.PowerApps.Administration.PowerShell
 Microsoft.PowerApps.PowerShell
.RELEASENOTES
 Version 1.0: Original published version.
#> 

<# 
.SYNOPSIS
 Quickly generate an overview of the current PowerApps in your environment

.DESCRIPTION
 This script will generate a HTML file to list all PowerApps per PowerApp environment

.PARAMETER LogPath 
 Enter the full path to store the HTML report of the PowerApp overview
 For example: C:\Install 
.PARAMETER Recipient 
 Please select a recipient for the report. 

.EXAMPLE
 New-PowerAppOverview.ps1 -LogPath "C:\Install"

 .NOTES
 Version:        1.0
 Author:         Maarten Peeters
 Creation Date:  24-09-2019
 Purpose/Change: Quickly generate an overview of the current PowerApps in your environment
#>

param(
    [Parameter(mandatory=$true)]
    [string] $LogPath,
    [Parameter(Mandatory = $true)]   
    [pscredential]$PACredential,
    [Parameter(mandatory=$false)]
    [string]$Recipient = 'Admin <administrator@company.net>'
    )
        Import-Module Microsoft.PowerApps.Administration.PowerShell
try{
        
#Verify if the Microsoft.PowerApps.Administration.PowerShell Module and Microsoft.PowerApps.PowerShell are installed
	if (Get-Module -ListAvailable -Name Microsoft.PowerApps.Administration.PowerShell) {
		if (Get-Module -ListAvailable -Name Microsoft.PowerApps.PowerShell) {
	
			#Test if logpath exists
			If(Test-Path $LogPath) { 
				#Start script
				Try{
					#Object collections
					$PowerAppCollection = @()
					$environmentCollection = @()

					#Connect to the PowerApp Environment
					ConnectPowerApps -PAFCredential $PACredential	
					
					#Retrieve all PowerApp environments
					$environments = Get-AdminPowerAppEnvironment | Sort-Object EnvironmentName
					
					#Retrieve all PowerApps
					$PowerApps = get-AdminPowerApp | Sort-Object EnvironmentName
				  
					#loop through all environments
					foreach($environment in $environments){
						#fill the collection with information
						$envProperties = $environment.internal.properties
						[datetime]$createdTime = $envProperties.createdTime
						$environmentCollection += new-object psobject -property @{displayName = $envProperties.displayName;InternalName = $environment.EnvironmentName;SKU = $envProperties.environmentSku;EnvType = $envProperties.environmentType;Region = $envProperties.azureRegionHint;Created = $createdTime.ToString("dd-MM-yyyy HH:mm:ss");CreatedBy = $envProperties.createdby.displayname}
					}

					#loop through all PowerApps
					foreach($PowerApp in $PowerApps){
						#fill the collection with information
						$PowerAppProperties = $PowerApp.internal.properties
						$ownerName = $PowerAppProperties.owner.userprincipalname
						$creatorName = $PowerAppProperties.createdBy.userprincipalname
						$lastModifiedName = $PowerAppProperties.lastModifiedBy.userprincipalname
																	
						[datetime]$modifiedTime = $PowerApp.LastModifiedTime
						[datetime]$createdTime = $PowerAppProperties.createdTime
						
						$listUrl = $PowerAppProperties.embeddedApp.listurl
						
						$PowerAppCollection += new-object psobject -property @{displayName = $PowerAppProperties.displayName;environment = $PowerAppProperties.Environment.name;ListURL = $listUrl;FeaturedApp = $PowerAppProperties.isFeaturedApp;HeroApp = $PowerAppProperties.isHeroApp;Created = $createdTime.ToString("dd-MM-yyyy HH:mm:ss");Modified = $modifiedTime.ToString("dd-MM-yyyy HH:mm:ss");CreatedBy = $creatorName;LastModifiedBy = $lastModifiedName;Owner = $ownerName}
					}	

					#We now have our collections so we are building the HTML page to get a direct view
					#List of all PowerApp environments
					$article = "<h2>List of all PowerApp environments</h2>"
					$article += "<table>
								<tr>
									<th>displayName</th>
									<th>InternalName</th>
									<th>SKU</th>
									<th>Type</th>
									<th>Region</th>
									<th>Created</th>
									<th>CreatedBy</th>
								</tr>"
					
					foreach($environmentColl in $environmentCollection){
					$article += "<tr>
									<td>$($environmentColl.displayName)</td>
									<td>$($environmentColl.InternalName)</td>
									<td>$($environmentColl.SKU)</td>
									<td>$($environmentColl.EnvType)</td>
									<td>$($environmentColl.Region)</td>
									<td>$($environmentColl.Created)</td>
									<td>$($environmentColl.CreatedBy)</td>
								</tr>"
					}
					
					$article += "</table>"

					#List of all PowerApps
					$article += "<h2>List of all PowerApps</h2>"
					$article += "<table>
								<tr>
									<th>displayName</th>
									<th>environment</th>
									<th>ListUrl</th>
									<th>FeaturedApp</th>
									<th>HeroApp</th>
									<th>Created</th>
									<th>Modified</th>
									<th>CreatedBy</th>
									<th>LastModifiedBy</th>
									<th>Owner</th>
								</tr>"
					
					foreach($PowerAppColl in $PowerAppCollection){
					$article += "<tr>
									<td>$($PowerAppColl.displayName)</td>
									<td>$($PowerAppColl.environment)</td>
									<td>$($PowerAppColl.ListUrl)</td>
									<td>$($PowerAppColl.FeaturedApp)</td>
									<td>$($PowerAppColl.HeroApp)</td>
									<td>$($PowerAppColl.Created)</td>
									<td>$($PowerAppColl.Modified)</td>
									<td>$($PowerAppColl.CreatedBy)</td>
									<td>$($PowerAppColl.LastModifiedBy)</td>
									<td>$($PowerAppColl.Owner)</td>
								</tr>"
					}
					
					$article += "</table>"

					$date = get-date
					$today = $date.ToString("ddMMyyyy_HHmm")
					$LogPath = Join-Path $LogPath "HTMLPowerAppReport_$($today).html"	
					
					#Head
					$head = "
					<html xmlns=`"http://www.w3.org/1999/xhtml`">
						<head>
							<style>
								@charset `"UTF-8`";

								@media print {
									body {-webkit-print-color-adjust: exact;}
								}
					
								div.container {
									width: 100%;
									border: 1px solid gray;
								}
								
								header {
									padding: 0.1em;
									color: white;
									background-color: #000033;
									color: white;
									clear: left;
									text-align: center;
									border-bottom: 2px solid #FF0066
								}	
								
								footer {
									padding: 0.1em;
									color: white;
									background-color: #000033;
									color: white;
									clear: left;
									text-align: center;
									border-top: 2px solid #FF0066
								}	

								article {
									margin-left: 20px;
									min-width:600px;
									min-height: 600px;
									padding: 1em;
								}
								
								th{
									border:1px Solid Black;
									border-Collapse:collapse; 
									background-color:#000033;
									color:white;
								}
								
								th{
									border:1px Solid Black;
									border-Collapse:collapse; 
								}
								
								tr:nth-child(even) {
								  background-color: #dddddd;
								}

							</style>
						</head>	
					"
					
					#Header
					$date = (get-date).tostring("dd-MM-yyyy")
					$header = "
						<h1>PowerApp Report</h1>
						<h5>$($date)</h5>
					"
					
					#Footer
					$Footer = "
						<A href=http://winsrv-poc1.company.net/scriptrunner/reports/HTMLPowerAppReport_$($today).html>Link to report page</a>
					"
					
					#Full HTML
					$HTML = "
						$($Head)		
						<body class=`"Inventory`">
							<div class=`"container`">
								<header>
									$($Header)
								</header>
								
								<article>
									$($article)
								</article>
										
								<footer>
									$($footer)
								</footer>
							</div>	
						</body>
						</html>
					" 
					add-content $HTML -path $LogPath

					Write-Host "PowerApp overview created at $($LogPath), it will also open automatically in 5 seconds" -foregroundcolor green

					start-sleep -s 5
					Invoke-Item $LogPath

                    Send-MailMessage -From 'Admin <administrator@company.net>' -To $Recipient -Subject "Daily PowerApps Report: $date" -SmtpServer 'Exchange.company.net' -Attachments $LogPath -BodyAsHtml $HTML
                    
                    $WebhookURL = 'https://outlook.office.com/webhook/87973ca6-1d50-42dc-b8a4-f20cfd11a45c@30f65c4b-8dc9-4f07-912a-7fa0bf6715b9/IncomingWebhook/36566f3279344e5b95170a3debceb3af/aedbe5f7-f6ad-48db-8b1f-cb3a79737494'
                    $Message = "<A href=http://winsrv-poc1.company.net/scriptrunner/reports/HTMLPowerAppReport_$($today).html>Link to report page</a>"
                    $Title = "Daily PowerApps Report: $date available" 
                    $MessageColor = 'Green'    
                    SendMessage2Channel -WebhookURL $WebhookURL -Message $Message -Title $Title `
                -MessageColor $MessageColor -ActivityTitle $ActivityTitle -ActivitySubtitle $ActivitySubtitle 

				}
				catch{
					write-host "Error occurred: $($_.Exception.Message), please post this error on https://www.cloudsecuritea.com" -foregroundcolor red
				}
			} Else { 
				Write-Host "The path $($LogPath) could not be found. Please enter a correct path to store the Office 365 subscription and license overview" -foregroundcolor yellow
			}
		}
		Else{Write-Host "The new Microsoft.PowerApps.PowerShell Module is not installed. Please install using the link in the blog" -foregroundcolor yellow}
	}
	Else{Write-Host "The new Microsoft.PowerApps.Administration.PowerShell Module is not installed. Please install using the link in the blog" -foregroundcolor yellow}
}
catch{
    write-host "Error occurred: $($_.Exception.Message)" -foregroundcolor red
}