# Define the paths for the folders
$customDir = Join-Path $PWD "custom"
$personaDir = Join-Path $env:LocalAppData "Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\premium_cache\persona"

# Function to display the cape selection menu
function Show-CapeSelectionMenu {
    # Check if the "custom" folder exists
    if (-Not (Test-Path $customDir)) {
        Write-Host "[INFO] The 'custom' folder does not exist. Creating it..."
        New-Item -ItemType Directory -Path $customDir
        Write-Host ""
        Write-Host "*******************************"
        Write-Host "[INFO] The 'custom' folder has been created!"
        Write-Host "*******************************"
        Write-Host ""
        Write-Host "*************************************"
        Write-Host "Please place your capes in the 'custom' folder!"
        Write-Host "*************************************"
        Write-Host ""
        Pause
        exit
    }

    # Count the folders in "custom"
    $folders = Get-ChildItem -Path $customDir -Directory
    $folderCount = $folders.Count

    # If no folders, display a message
    if ($folderCount -eq 0) {
        Write-Host "[ERROR] No folders found in 'custom'. Add a cape to proceed."
        Pause
        exit
    }

    # If only one folder, continue directly
    if ($folderCount -eq 1) {
        Write-Host "[OK] Only one cape detected: $($folders.Name)"
        $selectedCape = $folders.Name
    } else {
        # If multiple folders, ask the user to choose by number
        Write-Host "***************************************"
        Write-Host "*  Multiple capes detected.           *"
        Write-Host "*  Please select using a number:      *"
        Write-Host "*  created by TaediumBreak            *"  # Added TaediumBreak
        Write-Host "***************************************"
        Write-Host ""

        # Display the list of capes without the "!" prefix
        $counter = 1
        foreach ($folder in $folders) {
            Write-Host "$counter. $($folder.Name.TrimStart('!'))"
            $counter++
        }

        Write-Host ""
        Write-Host "Enter the cape number or type 'reset' to reset."
        $choice = Read-Host "Enter your choice"

        # If the user chooses 'reset'
        if ($choice -eq 'reset') {
            Write-Host "[INFO] Resetting files..."
            # Delete all folders, including those that start with "!"
            $foldersInPersona = Get-ChildItem -Path $personaDir -Directory
            foreach ($folder in $foldersInPersona) {
                Remove-Item -Path $folder.FullName -Recurse -Force
            }

            Write-Host "[OK] Reset completed."
            # Wait for the user to press Enter before returning to the selection menu
            Read-Host "Press Enter to return to the cape selection menu"
            Clear-Host
            Show-CapeSelectionMenu
            return
        }

        # Check if the input is valid
        if ($choice -ge 1 -and $choice -le $folderCount) {
            $selectedCape = $folders[$choice - 1].Name
        } else {
            Write-Host "[ERROR] Please choose a valid number or 'reset'."
            Pause
            exit
        }
    }

    # Clear previous display
    Clear-Host

    Write-Host "[OK] You selected the cape: $selectedCape"

    # Ask for confirmation with "Y" for yes, "N" for no
    $confirmation = Read-Host "Do you really want this cape? (Y/N)"

    if ($confirmation -eq "Y") {
        Write-Host "[INFO] Processing the cape: $selectedCape"
    } elseif ($confirmation -eq "N") {
        # Clear the display and return to the selection menu
        Clear-Host
        Show-CapeSelectionMenu
        return
    } else {
        Write-Host "[ERROR] You must enter 'Y' for yes or 'N' for no."
        Pause
        exit
    }

    # ------------------------------------------
    # Step 1: Delete folders in "persona" that do not start with "!"
    # ------------------------------------------

    Write-Host "[INFO] Deleting folders in 'persona' that do not start with '!'..."

    $foldersInPersona = Get-ChildItem -Path $personaDir -Directory | Where-Object { $_.Name -notmatch "^!" }

    # Delete all folders
    foreach ($folder in $foldersInPersona) {
        Remove-Item -Path $folder.FullName -Recurse -Force
    }

    Write-Host "[OK] All unwanted folders have been deleted."

    # ------------------------------------------
    # Step 2: Check and delete existing cape
    # ------------------------------------------

    # Get the PNG image name in the selected cape folder
    $selectedCapePath = Join-Path $customDir $selectedCape
    $pngFile = Get-ChildItem -Path $selectedCapePath -Filter *.png | Select-Object -First 1

    if (-Not $pngFile) {
        Write-Host "[ERROR] No PNG image found in the selected cape folder."
        Pause
        exit
    }

    # Name of the PNG image
    $imageName = $pngFile.Name
    Write-Host "[INFO] Image name of the selected cape: $imageName"

    # Loop through folders that start with "!" in "persona"
    $foldersInPersona = Get-ChildItem -Path $personaDir -Directory | Where-Object { $_.Name -match "^!" }

    foreach ($folder in $foldersInPersona) {
        # Check if a file in this folder has the same name as the cape's image
        $matchingFiles = Get-ChildItem -Path $folder.FullName -Filter $imageName
        if ($matchingFiles) {
            Write-Host "[INFO] The file $imageName already exists in the folder '$($folder.Name)'. Deleting the folder..."
            Remove-Item -Path $folder.FullName -Recurse -Force
        }
    }

    # Copy the new cape to the "persona" folder
    $destFolder = Join-Path $personaDir "!$selectedCape"
    Write-Host "[INFO] Adding the cape to the 'persona' folder."
    Copy-Item -Path $selectedCapePath -Destination $destFolder -Recurse -Force

    # Simplified message for successful cape change
    Clear-Host
    Write-Host "[OK] Operation successful."

    # Return to the cape selection menu
    Read-Host "Press Enter to return to the cape selection menu"
    Clear-Host
    Show-CapeSelectionMenu
}

# Launch the selection menu
Show-CapeSelectionMenu
