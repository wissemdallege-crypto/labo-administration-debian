#!/bin/bash

# ==========================================
# Script 3 : Création Automatisée d'un Utilisateur de Service SSH
# ==========================================

# Étape 1 : Valider que le script est exécuté avec les privilèges root (via $EUID)
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : Ce script doit être exécuté avec les privilèges root." >&2
    exit 1
fi

# Étape 2 : Valider la présence des arguments requis (nom d'utilisateur et clé publique)
if [ "$#" -lt 2 ]; then
    echo "Usage : $0 <nom_utilisateur> <cle_publique_ssh>" >&2
    exit 1
fi

USERNAME="$1"
SSH_KEY="$2"

# Étape 3 : Créer l'utilisateur système avec un répertoire personnel et un shell standard s'il n'existe pas
if id "$USERNAME" &>/dev/null; then
    echo "L'utilisateur $USERNAME existe déjà."
else
    echo "Création de l'utilisateur système $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME"
    echo "Utilisateur $USERNAME créé avec succès."
fi

# Étape 4 : Configurer le répertoire .ssh et injecter la clé publique avec des permissions strictes
USER_HOME=$(eval echo "~$USERNAME")
SSH_DIR="$USER_HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo "Configuration des accès SSH pour $USERNAME..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Ajouter la clé publique si elle n'y est pas déjà
if ! grep -q "$SSH_KEY" "$AUTH_KEYS" 2>/dev/null; then
    echo "$SSH_KEY" >> "$AUTH_KEYS"
    echo "Clé publique SSH ajoutée avec succès."
else
    echo "La clé publique est déjà présente dans authorized_keys."
fi

chmod 600 "$AUTH_KEYS"
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

echo "=== Configuration SSH terminée pour l'utilisateur $USERNAME ==="
