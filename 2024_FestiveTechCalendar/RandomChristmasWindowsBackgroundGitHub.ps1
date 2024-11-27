#region API endpoint and key (replace with your Pexels API key)
# This section defines the API key and base URL for the Pexels API.
# The API key is a unique identifier to authenticate and authorize requests.
# The API URL includes parameters to search for Christmas images, limit results to 1 per page, 
# and set the orientation of images to landscape.
$apiKey = "your key here"
$apiUrlBase = "https://api.pexels.com/v1/search?query=christmas&per_page=1&orientation=landscape"
#endregion

# Function to download a random image from Pexels
function Get-RandomChristmasImage {
    try {
        # Generate a random page number to retrieve a random image.
        # Pexels API supports pagination, allowing access to multiple pages of images.
        # This ensures the script fetches a different image each time it's run.
        $randomPage = Get-Random -Minimum 1 -Maximum 1000

        # Construct the full API URL by appending the randomly generated page number.
        $apiUrl = "$apiUrlBase&page=$randomPage"
        
        # Define the headers for the API request.
        # The Authorization header is required to authenticate the request using the API key.
        $headers = @{
            Authorization = $apiKey
        }

        # Send a GET request to the Pexels API using Invoke-RestMethod.
        # This command retrieves the API response, which is parsed into a PowerShell object.
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers

        # Extract the URL of the first image in the response.
        # The Pexels API returns multiple resolutions for images; here we select the original resolution.
        $imageUrl = $response.photos[0].src.original
        
        # Define the local file path where the image will be saved.
        # The TEMP environment variable is used to save the file in a temporary directory.
        $localPath = "$env:TEMP\christmas_wallpaper.jpg"

        # Download the image from the extracted URL and save it to the specified local path.
        # Invoke-WebRequest is used to perform the download.
        Invoke-WebRequest -Uri $imageUrl -OutFile $localPath
        Write-Host "Image downloaded to: $localPath" -ForegroundColor Green

        # Return the local path of the downloaded image.
        return $localPath
    } catch {
        # If an error occurs during the process (e.g., API failure, download error), 
        # log the error message and return null to indicate failure.
        Write-Host "Failed to fetch image: $_" -ForegroundColor Red
        return $null
    }
}

# Function to set the desktop background using SystemParametersInfo
function Set-DesktopBackground {
    param(
        # Accepts the local path of the image to be set as the desktop wallpaper.
        [string]$imagePath
    )

    try {
        # Add a C# class definition to the PowerShell session using Add-Type.
        # This class interacts with the Windows user32.dll library, allowing us to call the SystemParametersInfo function.
        Add-Type @"
            using System;
            using System.Runtime.InteropServices;
            public class Wallpaper {
                [DllImport("user32.dll", CharSet=CharSet.Auto)]
                public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            }
"@

        # Call the SystemParametersInfo function to update the desktop wallpaper.
        # Parameters:
        # 0x0014 - SPI_SETDESKWALLPAPER action code to change the wallpaper.
        # 0x0001 - Updates the user profile immediately.
        # $imagePath - The path of the new wallpaper image.
        [Wallpaper]::SystemParametersInfo(0x0014, 0, $imagePath, 0x0001)
        Write-Host "Desktop wallpaper updated to: $imagePath" -ForegroundColor Green
    } catch {
        # If an error occurs (e.g., permission issues, invalid file path), log the error message.
        Write-Host "Failed to set desktop background: $_" -ForegroundColor Red
    }
}

#region Main script
# Call the function to download a random Christmas image.
$imagePath = Get-RandomChristmasImage

# Check if an image was successfully downloaded.
if ($imagePath) {
    # If the image path is valid, set it as the desktop wallpaper.
    Set-DesktopBackground -imagePath $imagePath
} else {
    # If no image was downloaded, log a warning message.
    Write-Host "No image found, skipping wallpaper update." -ForegroundColor Yellow
}
#endregion


