# Exercice 3 : Vérification d'une infrastructure réseau (temps estimé : 1h30 min)

## Découverte du réseau

Q.3.1 Quel est le matériel réseau A ?
Quel est son rôle sur ce schéma vis-à-vis des ordinateurs ?

Le matériel réseau A est un _Switch_, il sert d'intermédiaire entre les sous-réseaux contenant les différents VPCS, il va capter et transmettre les diférentes trames recues des VPCS et les rediriger ver B.

Q.3.2 Quel est le matériel réseau B ?
Quel est son rôle pour le réseau 10.10.0.0/16 ?

Le matériel B est un _Routeur_, il sert de passerelle entre le réseau `10.10.0.0/16` et le réseau `10.12.2.0/24`

Q.3.3 Que signifie f0/0 et g1/0 sur l’élément B ?

`f0/0` correspond au premier port de la carte réseau du _Routeur_ raccordé au réseau `10.10.0.0/16`

Q.3.4 Pour l'ordinateur PC2, que représente /16 dans son adresse IP ?

Pour le PC2, le `/16` correspond au CIDR du réseau, cela correspond à la forme abrégée du masque, ici le masque sera `255.255.0.0`
Converti en bits, nous avons alors les 16 premiers bits à `1`, le reste à `0`, donc `11111111 11111111 00000000 00000000`

Q.3.5 Pour ce même ordinateur, que représente l'adresse 10.10.255.254 ?

Pour le PC2, l'adresse `10.10.255.254` est l'interface local du routeur (du côté du réseau comprenant le PC2), cela sert à joindre le second réseau `10.12.0.0/24` via le Routeur

## Etude théorique

Q.3.6 Pour les ordinateur PC1, PC2, et PC5 donne :

L'adresse de réseau
La première adresse disponible
La dernière adresse disponible
L'adresse de diffusion

Pour le PC1 et PC2, le CIDR de `16`, nous aurons un masque de `255.255.0.0` ou `11111111 11111111 00000000 00000000` converti en bits
Pour le PC5, le CIDR est `15`, le masque est alors `255.255.254.0` ou `11111111 11111110 00000000 00000000` converti en bits

Il faut donc comparer l'adresse de la machine avec le masque pour connaitre le réseau auquel la machine appartient

Par exemple, pour le PC5, l'adresse est `10.10.4.7/15` ou `00001010 00001010 00000100 00000111` converti en bits

|PC5|Adresse en bits|
|:-:|:-:|
|Adresse|`00001010 00001010 00000100 00000111`|
|Masque|`11111111 11111110 00000000 00000000`|
|Réseau|`00001010 00001010 00000000 00000000`|

Donc l'adresse de réseau est en `10.10.0.0`

Calcul du nombre d'hotes pour le réseau `10.10.0.0/15`

On prend le CIDR de `15` qu'on ôte à 32, soit 32 - 15 = 17

On met alors 2^17 = 131072 auquel on retire l'adresse de réseau et l'adresse de broadcast, soit 131072 -2 = 131070 hôtes possibles

|Computer|Adresse de réseau|Première adresse|Dernière adresse|Adresse de broacast|
|:-:|:-:|:-:|:-:|:-:|
|PC1|10.10.0.0|10.10.0.1|10.10.25.254|10.10.255.255|
|PC2|10.11.0.0|10.11.0.1|10.11.255.254|10.11.255.255|
|PC5|10.10.0.0|10.10.0.1|10.11.255.254|10.11.255.255|

Q.3.7 En t'aidant des informations que tu as fourni à la question 3.6, et à l'aide de tes connaissances, indique parmi tous les ordinateurs du schéma, lesquels vont pouvoir communiquer entre-eux.

Grâce au plan d'adressage obtenu, nous pouvons constater que:
* PC1 et PC5 ont la même adresse de réseau, PC1 est inclus dans le réseau du PC5, ils vont par conséquent pouvoir communiquer entre eux.
* PC2 et PC5 vont pouvoir communiquer car le PC2 est inclus dans le réseau du PC5

En revanche, PC2 ne pourras pas communiquer avec PC1, car de leurs points de vue respectifs, ils ne sont pas sur le même réseau. `10.11.0.0/16` pour le PC2 et `10.10.0.0/16` pour le PC1.

Q.3.8 De même, indique ceux qui vont pouvoir atteindre le réseau 172.16.5.0/24.

En partant du réseau `172.16.5.0/24`, nous pouvons remarquer que :
* nous passons par le réseau `10.12.2.0/24` qui correspond au réseau entre les Routeurs R2 et le matériel B
* nous passons ensuite dans le réseau `10.10.0.0/16`.

Or le PC2 n'est pas sur le réseau `10.10.0.0/16`, il ne pourra pas atteindre le Routeur B.

Q.3.9 Quel incidence y-a-t'il pour les ordinateurs PC2 et PC3 si on interverti leur ports de connexion sur le matériel A ?

Il n'y a aucune incidence quand à un éventuel changement de port sur le Swicth B entre les PC1 et PC2, le switch n'étant là que pour faire la liaison vers le Routeur. Du point de vue du swicth, il ne fait pas la différence entre le PC1 et le PC2.

Q.3.10 On souhaite mettre la configuration IP des ordinateurs en dynamique. Quelles sont les modifications possible ?

Pour mettre la configuration des ordinateurs en dynamique, nous devrons ajouter un serveur DHCP.

## Analyse de trames

### Fichier 1

Q.3.11 Sur le paquet N°5, quelle est l'adresse mac du matériel qui initialise la communication ? Déduis-en le nom du matériel.

L'adresse MAC du matériel qui initialise la communication est `00:50:79:66:68:00` qui correspond au PC avec l'IP `10.10.4.1`.

Q.3.12 Est-ce que la communication enregistrée dans cette capture a réussi ? Si oui, indique entre quels matériel, si non indique pourquoi cela n'a pas fonctionné.

La communication a abouti avec succés, une réponse du PC `10.10.4.2` est envoyé et reçue par `10.10.4.1` dans le paquet n°6.

Q.3.13 Dans cette capture, à quel matériel correspond le request et le reply ? Donne le nom, l'adresse IP, et l'adresse mac de chaque materiel.

|Nom|Adresse IP|Adresse MAC|
|:-:|:-:|:-:|
|PC1|10.10.4.1|00:50:79:66:68:00|
|PC2|10.10.4.2|00:50:79:66:68:03|

Q.3.14 Dans le paquet N°2, quel est le protocole encapsulé ? Quel est son rôle ?

Le paquet n°2 correspond au protocole ARP qui consiste faire correspondre une adresse IP et une adresse MAC.

Q.3.15 Quels ont été les rôles des matériels A et B dans cette communication ?



### Fichier 2

Q.3.16 Dans cette trame, qui initialise la communication ? Donne l'adresse IP ainsi que le nom du matériel.

La communication est initialisée par le matériel avec l'adresse IP `10.10.80.3` et l'adresse MAC `00:50:79:66:68:02`

Q.3.17 Quel est le protocole encapsulé ? Quel est son rôle ?

Le protocole encapsulé est `ICMP` qui correspond à une requête de présence d'un autre matériel.

Q.3.18 Est-ce que cette communication a réussi ? Si oui, indique entre quels matériel, si non indique pourquoi cela n'a pas fonctionné.

La communication n'a pas abouti, nous pouvons constater que toutes les réponses sont en `Destination unreachable`, ceci est dû au fait que le destinataire n'est pas accessible.

Q.3.19 Explique la ligne du paquet N° 2

Le paquet n°2 nous indique que la requête de ping initialisée n'est pas accessible via l'IP `10.10.255.254`

Q.3.20 Quels ont été les rôles des matériels A et B ?



### Fichier 3

Q.3.21 Dans cette trame, donne les noms et les adresses IP des matériels sources et destination.

|Paquet|Nom Source|Adresse IP|Nom Destination|Adresse IP|
|:-:|:-:|:-:|:-:|:-:|
|1|PC1|10.10.4.2|PC2|172.16.5.253|
|2|PC2|172.16.5.253|PC1|10.10.4.2|
|3|PC1|10.10.4.2|PC2|172.16.5.253|
|4|PC2|172.16.5.253|PC1|10.10.4.2|
|5|PC1|10.10.4.2|PC2|172.16.5.253|
|6|PC2|172.16.5.253|PC1|10.10.4.2|

Q.3.22 Quelles sont les adresses mac source et destination ? Qu'en déduis-tu ?

Le PC1 a comme adresse MAC `CA:01:DA:D2:00:1C`, le PC2 a comme adresse MAC `CA:03:9E:EF:00:38`, la requête de ping a réussi, les deux matériels se voient.

Q.3.23 A quel emplacement du réseau a été enregistré cette communication ?

Cette communication a été enregistré au niveau d'un Routeur, car les deux matériels ne sont pas sur le même réseau.