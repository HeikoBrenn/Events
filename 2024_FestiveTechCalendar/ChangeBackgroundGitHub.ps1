# Define a mapping of queries based on the current month
$month = (Get-Date).Month
$queryMap = @{
    1 = "New Year"
    2 = "Valentine's Day"
    3 = "Spring"
    4 = "Easter"
    5 = "Flowers"
    6 = "Summer"
    7 = "Beach"
    8 = "Sunset"
    9 = "Autumn"
    10 = "Halloween"
    11 = "Thanksgiving"
    12 = "Christmas"
}

# Automatically set the query based on the current month
$SearchQuery = $queryMap[$month]


# API endpoint and key (replace with your Pexels API key)
$apiKey = "your key here"
#$apiUrlBase = "https://api.pexels.com/v1/search?query=mountains and sea&per_page=1&orientation=landscape"
$apiUrlBase = "https://api.pexels.com/v1/search?query=$SearchQuery&per_page=1&orientation=landscape"

# Define the history folder where images will be saved
$historyFolderPath = "C:\Data\OneDrive\_ScriptRunner\Präsentationen\Bilder\WallpaperHistory"
$timestamp = (Get-Date -Format "yyyyMMdd-HHmmss")

# Create the history folder if it doesn't exist
if (-not (Test-Path -Path $historyFolderPath)) {
    New-Item -ItemType Directory -Path $historyFolderPath
    Write-Host "Created history folder at: $historyFolderPath" -ForegroundColor Green
}


# Function to download a random image from Pexels
function Get-RandomChristmasImage {
    try {
        # Generate a random page number to get a different image (Pexels has around 1000 pages for large queries)
        $randomPage = Get-Random -Minimum 1 -Maximum 1000

        # Full API URL with random page number
        $apiUrl = "$apiUrlBase&page=$randomPage"
        
        # Define headers for the Pexels API (Authorization)
        $headers = @{
            Authorization = $apiKey
        }

        # Send REST request to get a random Christmas image
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers 

        # Extract the image URL (original resolution)
        $imageUrl = $response.photos[0].src.original
        Write-Host "Downloading image from: $imageUrl" -ForegroundColor Green

        # Define local file path for the image
        $localPath = "$env:TEMP\christmas_wallpaper.jpg"

        # Download the image and save it to the local path
        Invoke-WebRequest -Uri $imageUrl -OutFile $localPath
        Write-Host "Image downloaded to: $localPath" -ForegroundColor Green

        # Save the image in the history folder with a timestamp
        $historyImagePath = "$historyFolderPath\${timestamp}_${SearchQuery}_wallpaper.jpg"
        Copy-Item -Path $localPath -Destination $historyImagePath -Force
        Write-Host "Image saved to history folder: $historyImagePath" -ForegroundColor Green

        return $localPath
    } catch {
        Write-Host "Failed to fetch image: $_" -ForegroundColor Red
        return $null
    }
}

# Function to set the desktop background using SystemParametersInfo
function Set-DesktopBackground {
    param(
        [string]$imagePath
    )

    try {
        # Define the SystemParametersInfo function from user32.dll
        Add-Type @"
            using System;
            using System.Runtime.InteropServices;
            public class Wallpaper {
                [DllImport("user32.dll", CharSet=CharSet.Auto)]
                public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            }
"@

        # Use the SPI_SETDESKWALLPAPER action (20) to change the wallpaper
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $imagePath, 0x0001)
        Write-Host "Desktop wallpaper updated to: $imagePath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to set desktop background: $_" -ForegroundColor Red
    }
}

# Main script
$imagePath = Get-RandomChristmasImage
if ($imagePath) {
    Set-DesktopBackground -imagePath $imagePath
} else {
    Write-Host "No image found, skipping wallpaper update." -ForegroundColor Yellow
}
