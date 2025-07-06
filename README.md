# TODO

## Jeu de base

- musique de fond

## Idées

- power ups that change rules (reroll number, score calculations..)
- dice alterations (changing faces, adding jokers, more than 6 faces die..)
- animated background (like in Balatro)

## Bump de la version

dans un shell unix (wsl, git bash...) - pas powershell - lancer: `cog bump --auto`

## Déployer vers le store:

> **PREREQUIS**
>
> Avoir le fichier `miccode-release.keystore` à la racine du projet et une version de Java SDK 17 installée

- faire export android depuis godot (utiliser l'option `Export All...` sinon ça génère une version debug)
- signer l'aab: `jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore miccode-release.keystore exports\yamsatro.aab MicCode`
- vérifier la signature: `jarsigner -verify -verbose -certs exports\yamsatro.aab`
- uploader sur [la console Google Play](https://play.google.com/console/u/0/developers)
