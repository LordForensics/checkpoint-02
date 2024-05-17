# Etape 1 : Se connecter en Administrateur sur le Client
# Etape 2 : Copier les fichiers du Serveur vers le Client via la session interactive distante

#$Session = New-PSSession -ComputerName "WINSERV" -Credential "Administrator"
#Copy-Item  -Path "C:\Scripts" -Destination "C:\Scripts" -ToSession $Session

#New-PSSession : [WINSERV] La connexion au serveur distant WINSERV a échoué avec le message d’erreur suivant: Le client WinRM ne peut pas traiter la demande. Si le 
#modèle d’authentification n’est pas Kerberos, ou si l’ordinateur client n’est pas membre d’un domaine, le transport HTTPS doit être utilisé ou l’ordinateur de 
#destination doit être ajouté au paramètre de configuration TrustedHosts. Utilisez winrm.cmd pour configurer TrustedHosts. Notez que les ordinateurs dans la liste 
#TrustedHosts ne sont peut-être pas authentifiés. Pour plus d’informations, exécutez la commande suivante: winrm help config. Pour plus d'informations, voir la rubrique 
#d'aide about_Remote_Troubleshooting.
#Au caractère Ligne:5 : 12
#+ $Session = New-PSSession -ComputerName "WINSERV" -Credential "Adminis ...
#+            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    + CategoryInfo          : OpenError: (System.Manageme....RemoteRunspace:RemoteRunspace) [New-PSSession], PSRemotingTransportException
#    + FullyQualifiedErrorId : ServerNotTrusted,PSSessionOpenFailed
#Copy-Item : Impossible de valider l'argument sur le paramètre « ToSession ». L’argument est Null ou vide. Indiquez un argument qui n’est pas Null ou vide et réessayez.
#Au caractère Ligne:6 : 68
#+ ... tem  -Path "C:\Scripts" -Destination "C:\Scripts" -ToSession $Session
#+                                                                  ~~~~~~~~
#    + CategoryInfo          : InvalidData : (:) [Copy-Item], ParameterBindingValidationException
#    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.PowerShell.Commands.CopyItemCommand

# Pour ne pas prendre de retard, j'ai copié le contenu de chaque fichier à la main
# Ce n'est pas très legit, mais il vaut mieux cela que ne pas rendre l'exercice 2

# Fichier Main.ps1
# Changement de la destination de l'ArgumentList (remplace C:\Temp par C:\Scripts)

Start-Process -FilePath "powershell.exe" -ArgumentList "C:\Scripts\AddLocalUsers.ps1" -Verb RunAs -WindowStyle Maximized

# Fichier Functions.psm1 - La fonction Log n'existe pas dans le script AddLocalUsers.ps1

function Log
{
    param([string]$FilePath,[string]$Content)

    # Vérifie si le fichier existe, sinon le crée
    If (-not (Test-Path -Path $LogFile))
    # Modification $FilePath > $LogFile pour chercher si le fichier de Log n'existe pas
    {
        New-Item -ItemType File -Path $LogFile | Out-Null
        # Modification $FilePath > $LogFile pour créer le fichier de Log si il n'existe pas
    }

    # Construit la ligne de journal
    $Date = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
    $User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $logLine = "$Date;$User;$Content"

    # Ajoute la ligne de journal au fichier
    Add-Content -Path $LogFile -Value $logLine
    # Modification $FilePath > $LogFile pour ajouter du contenu au fichier de Log
}

# Fichier AddLocalUsers.ps1

Write-Host "--- Début du script ---"

Function RandomPassword ($length = 6)
# Modification du nom de la fonction, qui se rapproche trop d'une cmdlet > Random-Password devient RandomPassword
{
    $punc = ':,;?@'
    # Modification pour ajouter des caracères de ponctuation et caractères spéciaux
    $digits = 0..9
    # Modification pour prendre en compte les chiffre de 0 à 9
    $letters = [a..z] + [A..Z]
    # Modification pour prendre en compte les lettres de A à Z en minuscules et majuscules

    $password = get-random -count $length -input ($punc + $digits + $letters) |`
        ForEach-Object -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
        # Modification de la commande ForEach > ForEach-Object
    Return $password.ToString()
}

Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

$Users = Import-Csv -Path $CsvFile -Delimiter ";" -Header "prenom","nom","societe","fonction","service","description","mail","mobile","scriptPath","telephoneNumber" -Encoding UTF8  | Select-Object -Skip 2

foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.Nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = RandomPassword
        # Modification du nom de fonction, en lien avec la modification apportée en ligne 57
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($user.description) - $($User.fonction)"
        $UserInfo = @{
            Name                 = "$Name"
            # Modification du contenu qui correspond à la variable $Prenom.$Nom > $Name créé en ligne 92
            FullName             = "$Prenom.$Nom"
            Description          = "$Description"
            # Ajout de la Description dans la création de l'Utilisateur référencée en ligne 98
            Password             = $Password
            AccountNeverExpires  = $true
            PasswordNeverExpires = $false
        }

        New-LocalUser @UserInfo
        Log
        #Ajout de la fonction Log pour une journalisation
        Add-LocalGroupMember -Group "Utilisateur" -Member "$Prenom.$Nom"
        Write-Host "L'utilisateur $Prenom.$Nom a été crée"
    }
}

pause
Write-Host "--- Fin du script ---"
Start-Sleep -Seconds 10

