# Laboratoire d'Administration Système - Debian

##  Description du Projet
Ce dépôt contient un ensemble de scripts shell développés dans le cadre du laboratoire d'administration système. L'objectif est d'automatiser des tâches courantes d'administration, de maintenance et de sécurité sur un environnement Debian.

##  Scripts Inclus
* **`creer_utilisateur_ssh.sh`** : Automatise la création d'un nouvel utilisateur système et configure ses accès SSH de manière sécurisée.
* **`detection_intrusions.sh`** : Analyse les journaux système à la recherche d'activités suspectes ou de tentatives de connexion infructueuses.
* **`nettoyage_logs.sh`** : Effectue le nettoyage et la rotation des fichiers de journaux pour libérer de l'espace disque.
* **`sauvegarde_infra.sh`** : Réalise des sauvegardes automatisées des répertoires et configurations critiques de l'infrastructure.

##  Utilisation
Pour exécuter l'un des scripts sur votre machine Debian, assurez-vous de disposer des privilèges `root` et d'ajuster les permissions d'exécution si nécessaire :

```bash
chmod +x scripts/<nom_du_script>.sh
sudo ./scripts/<nom_du_script>.sh
