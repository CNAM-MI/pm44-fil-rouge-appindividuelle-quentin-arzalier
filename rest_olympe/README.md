# RestOlympe - Édition Flutter

L'itération de l'application RestOlympe développée en Dart à l'aide du framework Flutter par Quentin ARZALIER dans le cadre du projet de développement mobile au CNAM IEM en 2024.

# Spécificités

## Spécificités mobile

- Géolocalisation lors de la création d'un salon
- Utilisation de la fonction Partage du téléphone pour partager le code du salon.
- Scan d'un QR code pour rejoindre le salon à partir d'un code généré sur l'application.
- Mise à disposition d'une carte pour repérer les différents restaraurants.
- Émission d'une notification lorsque le vote prend fin.

## Fonctionnement API

Les opérations réalisées par l'utilisateur à un instant T sont réalisées à l'aide de l'API. Cela contient les opérations de création, de modification, de suppression et de lecture des données.

## Fonctionnement WebSocket

Les changements apportées en temps réel à l'application sont signalés au travers d'un client WebSocket SignalR. Ces opérations sont les suivantes :

- Un utilisateur s'est connecté au salon => On recharge la liste des utilisateurs.
- Un utilisateur a créé, changé ou supprimé un vote => On recharge les votes de la liste des utilisateurs.
- Un administrateur a mis fin au vote => On affiche le bouton résultats au lieu du bouton vote est on est redirigé à la page salon si on était en train de voter. De plus, une notification est lancée si l'application est en arrière plan.