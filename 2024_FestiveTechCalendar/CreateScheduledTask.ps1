function Create-ScheduledTask {
    param (
        [string]$ScriptPath,
        [string]$TaskName,
        [ValidateSet('PowerShell','VBS')]
        [string]$StartProgram
    )

    try {
        # Check if the task already exists
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Host "Task already exists. Deleting existing task to create a new one." -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }

        # Validate StartProgram value
        if ($StartProgram -notin @("PowerShell", "VBS")) {
            throw "Invalid StartProgram. Must be 'PowerShell' or 'VBS'."
        }

        # Define the action for the task
        if ($StartProgram -ieq "PowerShell") {
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -File `"$ScriptPath`""
        } elseif ($StartProgram -ieq "VBS") {
            $action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$ScriptPath`""
        }

        # Define the trigger (every 5 minutes)
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 365)

        # Register the scheduled task under the current user
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $TaskName -Description "Change desktop background every 5 minutes" -User $env:USERNAME

        Write-Host "Scheduled task '$TaskName' has been created successfully and will run every 5 minutes." -ForegroundColor Green
    } catch {
        Write-Host "Failed to create the scheduled task: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Call the function, providing the path to the script that changes the background
Create-ScheduledTask -TaskName ChangeBackgroundPS1 -StartProgram PowerShell -scriptPath "C:\test\RandomChristmasWindowsBackground.ps1"
Create-ScheduledTask -TaskName ChangeBackgroundVBS -StartProgram VBS -scriptPath "C:\test\RunPS.vbs"
