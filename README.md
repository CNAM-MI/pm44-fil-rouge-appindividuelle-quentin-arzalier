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

# Retex Flutter

La création d'une application en Flutter a été très simple d'un point de vue de prise en main.
- Le langage est intuitif, et les outils de développement sont complets, permettant une facilité de développement accrue.
- Les widgets proposés par défaut sont nombreux et permettent de répondre à de nombreuses problématiques.
- La création de widget personnalisés est également intuitive et on peut donc facilement réutiliser du code.


De ce fait, Flutter semble très bien adapté pour la création d'application mobiles multiplateformes, mais est victime de plusieurs problèmes.
- Le code n'a besoin d'être écrit qu'une seule fois, mais parfois il doit être beaucoup plus long pour être multiplateforme (eg: Configuration des notifications)
- Puisque dart est compilé avec gradle et kotlin, on se retrouve parfois face à des erreurs de configuration qui sont extrêmement compliquées à réparer
- L'écosystème de plugin pub.dev est très complet, et on trouve souvent une solution à un problème, mais les dépendances et les configurations à rajouter pour les différents paquets peuvent être complexes à mettre en place.

Je pense tout de même que Flutter est l'une des meilleures solutions en place pour développer le projet Restolympe, en comparaison avec Kotlin, Kotlin Multiplateforme et React Native.