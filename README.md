# Trognon

Un lanceur de commandes personnalisées pour votre projet de développement.

Exemple : 

```bash
# Affiche l'aide
./agnes help

# Installe votre projet (vous devez définir ce que `install` fait)
./agnes install

# créé un dump de la base de données
./agnes dump
```

# Dépendances

Ce projet nécessite des bibliothèques supplémentaires pour fonctionner.
Avec la commande `git` procédez ainsi&nbsp;: 

```bash
git submodule update --quiet --init --recursive 
```

# Fonctionnalités

* possibilité d'ajouter ses propres commandes
* système de configuration pour le chargement des variables, ainsi que leur sauvegarde

# Comment ajouter une commande ?

Exemple avec une sous-commande "install".

1. Utilisez comme template le fichier command.example
1. crééez un fichier, par exemple install.sh avec
1. complétez le fichier install.sh avec les commandes à lancer pour l'installation de votre projet
1. ajoutez "install" à la liste des commandes autorisées dans la variable ALLOWED\_COMMANDS du fichier **agnes**

Vous pouvez désormais lancer votre commande de cette façon : `./agnes install`

# Rendre la commande disponible dans tout le système

1. vérifiez d'avoir complété le programme avec la commande `git submodule update --quiet --init --recursive `
1. placez ce dépôt à un endroit phare de votre système, par exemple dans **${HOME}/trognon**
1. ajoutez la ligne suivante dans ~/.bashrc ou bien ~/.zshrc : 

```
alias trognon="ALIAS=trognon ${HOME}/trognon/agnes"
```

Désormais la commande se lance **depuis n'importe où dans le système** avec l'alias `trognon`. Et les commandes d'aide en conséquence.

# Licence

Ce logiciel est sous licence EUPL v1.2 (Cf. le fichier LICENSE).

This software is available under the terms of EUPL licence (Cf. LICENCE file).
