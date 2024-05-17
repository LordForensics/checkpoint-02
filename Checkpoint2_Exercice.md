# Exercice 2 : Débogage de script PowerShell (temps estimé : 1h30)

## Pratique

Q.2.1 Tous les fichiers nécessaires sont dans un dossier c:\Scripts sur le serveur.
Mets ces fichiers dans un dossier c:\Scripts sur le client.
Tu dois donc avoir sur le client, un dossier C:\Scripts avec les fichiers :

AddLocalUsers.ps1
Functions.psm1
Main.ps1
Users.csv
Explique la marche à suivre pour transférer les fichiers du serveur vers le client et montre-le par des copies d'écran.

Comme mis en commentaire dans le script rendu, j'ai tout copié manuellement après m'être pris la tête pendant 15 minutes, j'ai préféré la facilité pour pouvoir travailler sur le script.

Q.2.2 Sur le client, ouvre une console PowerShell ISE et exécute le script Main.ps1.
Que se passe t'il à l'exécution ?
Corrige ce script pour qu'il lance correctement le script AddLocalUsers.ps1.
Explique ta modification.

Lors du lancement du script sans modification, Powershell s'ouvre et se ferme, rien de plus

Il faut donc modifier le fichier Main.ps1 et remplacer le dossier `Temp` par `Scripts`.

Q.2.3 A quoi sert l'option -Verb RunAs ?

L'option `-Verb RunAs` sert (comme dit dans l'énoncé) à lancer le script avec des privilèges élevés.

Q.2.4 De même, à quoi sert l'option -WindowsStyle Maximized ?

L'option `-WindowsStyle Maximized` sert à lancer la fenêtre Powershell en format maximal.

Q.2.5 Le premier utilisateur du fichier Users.csv n'est jamais pris en compte.
Explique pourquoi et modifie le script pour que cela soit le cas.

Anna Dumas n'est pas pris en compte car dans le script on demande de passer la seconde ligne `-Skip 2`, il suffit d'effacer cela ou de mettre un # avant.

Q.2.6 Le champs Description est importé du fichier CSV mais n'est pas utilisé.
Explique pourquoi et modifie le code pour que ce champs soit utilisé dans la création des utilisateurs.

La variable $Description (contenant la description et la fonction) existe bien mais n'est pas exploité dans le script, il faut ajouter cette variable dans $UserInfo

```
        $Pass = Random-Password
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.description) - $($User.fonction)"
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
	        Description		     = "$Description"
            Password             = $Password
            AccountNeverExpires  = $true
            PasswordNeverExpires = $false
        }
```

Q.2.7 Dans l'importation des utilisateurs du fichier CSV, tous les champs sont pris. Or il n'y en a qu'une partie qui est utilisé par la suite.
Corrige le script pour qu'il n'y ait que les champs utilisés pour la création des utilisateurs qui soient importés du fichier CSV.

Il faut retirer dans le Header les champs non-utilisés soit les champs "Société" "Service" "Mail" "Mobile" "ScriptPath et "TelephoneNumber".

```
$Users = Import-Csv -Path $CsvFile -Delimiter ";" -Header "prenom","nom","fonction","description" -Encoding UTF8  | Select-Object -Skip 2
```

Q.2.8 Le mot de passe crée n'est pas affiché, donc on ne le connait pas.
Modifie le script pour qu'il affiche avec une couleur verte "Le compte <Utilisateur> a été crée avec le mot de passe <MotDePasse>".

Il faut modifier le teste qui sera affiché en ajoutant la variable du mot de passe.

```
Write-Host "L'utilisateur $Prenom.$Nom a été crée avec le mot de passe $Pass" -ForegroundColor Green
```

Q.2.9 Une fonction de création de log, nommée Log existe dans le fichier Functions.psm1.
Donne 2 façons d'utiliser cette fonction dans le script AddLocalUsers.ps1.
Modifie le script avec une des méthodes pour journaliser l'activité et les actions importantes avec cette fonction.

Afin de pouvoir utiliser la fonction `Log`, nous devons :
* soit appeler le script directement dans le script LocalAddUsers.ps1
* soit copier son contenu dans LocalAddUsers.ps1 au début puis appeler la fonction Log

Il faut également changer le nom de la variable `$FilePath` et la remplacer par `$LogFile` qui correspond à la variable créé dans le Script `LocalAddUsers.ps1`

En utilisant la seconde méthode, on auras alors :

```
Log | Write-Host "La journalisation de l'ajout des utilisateurs a été enregistré dans le fichier $LogFile" -ForegroundColor Yellow
```

Q.2.10 Si l'utilisateur à créer existe déjà, il n'est pas crée, ce qui est normal (c'est comme ça que doit fonctionner le script). Or cette information n'est pas affichée, donc on ne le sait pas.
Modifie le script pour qu'un message affiche en rouge "Le compte <Utilisateur> existe déjà".

Il faut ajouter la condition  dans la fonction qui correspond au cas où l'utilisateur existe

```
    else 
    {
        Write-Host "L'utilisateur $Name existe déjà" -ForegroundColor Red
    }
```

Q.2.11 L'ajout des utilisateurs dans le groupe des utilisateurs locaux ne fonctionne pas. Corrige le script pour que cela fonctionne.



Q.2.12 Plusieurs fois dans le code du script, la chaine "$Prenom.$Nom" est utilisée.
Pour simplifier la lecture du script, remplace la par une variable $Name.

```
            Name                 = "$Name"
            FullName             = "$Name"
```

Q.2.13 Les comptes utilisateurs créer ont un mot de passe qui expire.
Corrige le script pour que le mot de passe n'expire pas.

Il faut remplacer la valeur false par true : `PasswordNeverExpires = $true`

Q.2.14 Modifie le code pour que le mot de passe soit constitué de 12 caractères au lieu de 6.

Il faut passer la longueur du mot de passe de 6 à 12 en modifiant la variable $lenght `($length = 12)`

Q.2.15 Le script a un temps d'attente de 10 secondes à la fin de l'exécution. Remplace ce temps par une pause gérable par un appuie sur la touche Entrée du clavier.

Il suffit de remplacer `Start-Sleep -Seconds 10` par `pause. 

Q.2.16 À quoi sert la fonction ManageAccentsAndCapitalLetters ?
Donne un exemple à partir de la liste des utilisateurs.

Cette fonction sert à remplacer les lettres avec accents par des lettres équivalentes sans accent et en minuscule.

Ainsi `Styrbjörn` devient `styrbjorn` et `Anaïs` devient `anais`.

_Si j'avais pris le temps de lire les questions (je suis parti trop vite sur le debug du script), j'aurais pu constater et corriger mieux les erreurs... En fait, je me suis pris la tête pour rien_

Par exemple, j'avais renommé la fonction `Random-Password` en `RandomPassword` qui me paraissait être plus cohérent pour le nom d'une fonction.