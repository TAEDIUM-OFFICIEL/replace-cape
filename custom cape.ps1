# Definir les chemins des dossiers
$customDir = Join-Path $PWD "custom"
$personaDir = Join-Path $env:LocalAppData "Packages\Microsoft.MinecraftUWP_8wekyb3d8bbwe\LocalState\premium_cache\persona"

# Fonction pour afficher le menu de selection des capes
function Show-CapeSelectionMenu {
    # Verifier si le dossier "custom" existe
    if (-Not (Test-Path $customDir)) {
        Write-Host "[INFO] Le dossier 'custom' n'existe pas. Creation en cours..."
        New-Item -ItemType Directory -Path $customDir
        Write-Host ""
        Write-Host "*******************************"
        Write-Host "[INFO] Le dossier 'custom' a ete cree !"
        Write-Host "*******************************"
        Write-Host ""
        Write-Host "*************************************"
        Write-Host "Merci de placer vos capes dans le dossier 'custom' !"
        Write-Host "*************************************"
        Write-Host ""
        Pause
        exit
    }

    # Compter les dossiers dans "custom"
    $folders = Get-ChildItem -Path $customDir -Directory
    $folderCount = $folders.Count

    # Si aucun dossier, afficher un message
    if ($folderCount -eq 0) {
        Write-Host "[ERREUR] Aucun dossier trouve dans 'custom'. Ajoutez une cape pour continuer."
        Pause
        exit
    }

    # Si un seul dossier, continuer directement
    if ($folderCount -eq 1) {
        Write-Host "[OK] Une seule cape detectee : $($folders.Name)"
        $selectedCape = $folders.Name
    } else {
        # Si plusieurs dossiers, demander a l'utilisateur de choisir par numero
        Write-Host "***************************************"
        Write-Host "*  Plusieurs capes detectees.         *"
        Write-Host "*  Veuillez choisir avec un numero :  *"
        Write-Host "*  cree par TaediumBreak              *"  # Ajout de TaediumBreak
        Write-Host "***************************************"
        Write-Host ""

        # Afficher la liste des capes sans les "!"
        $counter = 1
        foreach ($folder in $folders) {
            Write-Host "$counter. $($folder.Name.TrimStart('!'))"
            $counter++
        }

        Write-Host ""
        Write-Host "Entrez le numero de la cape ou tapez 'reset' pour reinitialiser."
        $choice = Read-Host "Entrez votre choix"

        # Si l'utilisateur choisit 'reset'
        if ($choice -eq 'reset') {
            Write-Host "[INFO] Restauration des fichiers..."
            # Supprimer tous les dossiers, y compris ceux qui commencent par "!"
            $foldersInPersona = Get-ChildItem -Path $personaDir -Directory
            foreach ($folder in $foldersInPersona) {
                Remove-Item -Path $folder.FullName -Recurse -Force
            }

            Write-Host "[OK] Restauration terminee"
            # Attendre que l'utilisateur appuie sur Entrée avant de revenir au menu de selection
            Read-Host "Appuyez sur Entree pour revenir au menu de selection des capes"
            Clear-Host
            Show-CapeSelectionMenu
            return
        }

        # Verifier si l'entree est valide
        if ($choice -ge 1 -and $choice -le $folderCount) {
            $selectedCape = $folders[$choice - 1].Name
        } else {
            Write-Host "[ERREUR] Merci de choisir un numero valide ou 'reset'."
            Pause
            exit
        }
    }

    # Suppression de l'affichage precedent
    Clear-Host

    Write-Host "[OK] Vous avez selectionne la cape : $selectedCape"

    # Demander confirmation avec "Y" pour oui, "N" pour non
    $confirmation = Read-Host "Voulez-vous vraiment cette cape ? (Y/N)"

    if ($confirmation -eq "Y") {
        Write-Host "[INFO] Traitement de la cape : $selectedCape"
    } elseif ($confirmation -eq "N") {
        # Effacer l'affichage et revenir au menu de selection
        Clear-Host
        Show-CapeSelectionMenu
        return
    } else {
        Write-Host "[ERREUR] Vous devez entrer 'Y' pour oui ou 'N' pour non."
        Pause
        exit
    }

    # ------------------------------------------
    # Etape 1 : Supprimer les dossiers dans "persona" qui ne commencent pas par "!"
    # ------------------------------------------

    Write-Host "[INFO] Suppression des dossiers dans 'persona' qui ne commencent pas par '!'..."

    $foldersInPersona = Get-ChildItem -Path $personaDir -Directory | Where-Object { $_.Name -notmatch "^!" }

    # Supprimer tous les dossiers
    foreach ($folder in $foldersInPersona) {
        Remove-Item -Path $folder.FullName -Recurse -Force
    }

    Write-Host "[OK] Tous les dossiers non souhaites ont ete supprimes."

    # ------------------------------------------
    # Etape 2 : Verification et suppression de la cape existante
    # ------------------------------------------

    # Recuperer le nom de l'image PNG dans la cape selectionnee
    $selectedCapePath = Join-Path $customDir $selectedCape
    $pngFile = Get-ChildItem -Path $selectedCapePath -Filter *.png | Select-Object -First 1

    if (-Not $pngFile) {
        Write-Host "[ERREUR] Aucune image PNG trouvee dans le dossier de la cape selectionnee."
        Pause
        exit
    }

    # Nom de l'image PNG
    $imageName = $pngFile.Name
    Write-Host "[INFO] Nom de l'image de la cape selectionnee : $imageName"

    # Parcourir les dossiers qui commencent par "!" dans "persona"
    $foldersInPersona = Get-ChildItem -Path $personaDir -Directory | Where-Object { $_.Name -match "^!" }

    foreach ($folder in $foldersInPersona) {
        # Verifier si un fichier dans ce dossier a le meme nom que l'image de la cape
        $matchingFiles = Get-ChildItem -Path $folder.FullName -Filter $imageName
        if ($matchingFiles) {
            Write-Host "[INFO] Le fichier $imageName existe deja dans le dossier '$($folder.Name)'. Suppression du dossier..."
            Remove-Item -Path $folder.FullName -Recurse -Force
        }
    }

    # Copier la nouvelle cape dans le dossier "persona"
    $destFolder = Join-Path $personaDir "!$selectedCape"
    Write-Host "[INFO] Ajout de la cape dans le dossier 'persona'."
    Copy-Item -Path $selectedCapePath -Destination $destFolder -Recurse -Force

    # Affichage simplifie du changement de cape
    Clear-Host
    Write-Host "[OK] Operation reussie"
    Write-Host "[INFO] Merci d'avoir utilise mon programme !"

    # Retourner au menu de selection des capes
    Read-Host "Appuyez sur Entree pour revenir au menu de selection des capes"
    Clear-Host
    Show-CapeSelectionMenu
}

# Lancer le menu de selection
Show-CapeSelectionMenu