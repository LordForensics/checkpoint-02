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

# Pour ne pas prendre de retard, j'ai copié le contenu de chaque fichier à la main et j'ai inséré le tout dans des documents créés sur le Client
# Ce n'est pas très legit, mais il vaut mieux cela que ne pas rendre l'exercice 2



# Fichier Main.ps1

Start-Process -FilePath "powershell.exe" -ArgumentList "C:\Scripts\AddLocalUsers.ps1" -Verb RunAs -WindowStyle Maximized # Q.2.1


# Fichier AddLocalUsers.ps1

Write-Host "--- Début du script ---"

Function RandomPassword ($length = 12) # Q.2.14 # Modification du nom de Fonction trop proche des Cmdlets
{
    $punc = 46..46
    $digits = 48..57
    $letters = 65..90 + 97..122

    $password = get-random -count $length -input ($punc + $digits + $letters) |`
        ForEach -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $password.ToString()
}

Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

function Log # Q.2.9
{
    param([string]$LogFile,[string]$Content)

    # Vérifie si le fichier existe, sinon le crée
    If (-not (Test-Path -Path $LogFile))
    {
        New-Item -ItemType File -Path $LogFile | Out-Null
    }

    # Construit la ligne de journal
    $Date = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
    $User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $logLine = "$Date;$User;$Content"

    # Ajoute la ligne de journal au fichier
    Add-Content -Path $LogFile -Value $logLine
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

$Users = Import-Csv -Path $CsvFile -Delimiter ";" -Header "prenom","nom","fonction","description" -Encoding UTF8  | Select-Object # Q.2.5 + Q.2.7

foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = RandomPassword # Modification du nom de Fonction trop proche des Cmdlets
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.description) - $($User.fonction)"
        $UserInfo = @{
            Name                 = "$Name" # Q.2.12
            FullName             = "$Name" # Q.2.12
            Description		     = "$Description" # Q.2.6
            Password             = $Password
            AccountNeverExpires  = $true
            PasswordNeverExpires = $true # Q.2.13
        }

        New-LocalUser @UserInfo
        Add-LocalGroupMember -Group "Utilisateur" -Member "$Prenom.$Nom"
        Write-Host "L'utilisateur $Name a été crée avec le mot de passe $Pass" -ForegroundColor Green # Q.2.8 + Q.2.12
        Log | Write-Host "La journalisation de l'ajout des utilisateurs a été enregistré dans le fichier $LogFile" -ForegroundColor Yellow # Q.2.9
    }
    else 
    {
        Write-Host "L'utilisateur $Name existe déjà" -ForegroundColor Red # Q.2.10
    }
}

pause
Write-Host "--- Fin du script ---"
pause # Q.2.15