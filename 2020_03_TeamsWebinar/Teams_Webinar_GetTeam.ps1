$availableTeams = Get-Team
$teams = @()
foreach($team in $availableTeams)
{
 
    Write-host "Handling team: " -NoNewline -ForegroundColor Yellow
    Write-host $team.DisplayName -ForegroundColor Yellow
    $users = Get-TeamUser -GroupId $team.GroupId
    $owners = @($users | Where-Object {$_.Role -eq "owner"})
    $members = @($users | Where-Object {$_.Role -eq "member"}).Length
    $guests = @($users | Where-Object {$_.Role -eq "guest"}).Length

    $teamObject = New-Object -TypeName PSObject
    $teamObject | Add-Member -MemberType NoteProperty -Name DisplayName -Value $team.DisplayName
    $teamObject | Add-Member -MemberType NoteProperty -Name GroupID -Value $team.GroupId
    $teamObject | Add-Member -MemberType NoteProperty -Name Alias -Value $team.MailNickName
    $teamObject | Add-Member -MemberType NoteProperty -Name "Number of Owners" -Value  $owners.Length
    $teamObject | Add-Member -MemberType NoteProperty -Name "Number of Members" -Value  $members
    $teamObject | Add-Member -MemberType NoteProperty -Name "Number of Guests" -Value  $guests
    if($owners.Count -eq 1)
    {
        $teamObject | Add-Member -MemberType NoteProperty -Name "Owner" -Value $owners[0].User
    }

    write-host " ...Done" -ForegroundColor Green
    $teams += $teamObject
}

$teams | Out-GridView 