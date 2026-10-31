#!/bin/bash

# ==========================================
# Script 2 : Sauvegarde et Rotation Avancée (MariaDB Docker)
# ==========================================

# Étape 1 : Créer l'arborescence de sauvegarde dédiée
BACKUP_DIR="/var/backups/infrastructure"
DB_BACKUP_DIR="$BACKUP_DIR/db"
VOL_BACKUP_DIR="$BACKUP_DIR/volumes"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$DB_BACKUP_DIR"
mkdir -p "$VOL_BACKUP_DIR"

echo "Début de la sauvegarde de l'infrastructure..."

# Étape 2 : Dump logique complet et compressé d'un conteneur MariaDB en production (transaction cohérente)
# Remplacez 'mariadb_prod' par le nom réel de votre conteneur MariaDB si nécessaire
CONTAINER_NAME="mariadb_prod"
DB_NAME="all_databases"

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Réalisation du dump MariaDB du conteneur $CONTAINER_NAME..."
    docker exec -i "$CONTAINER_NAME" mariadb-dump --all-databases --single-transaction --routines --triggers -uroot -p"${DB_ROOT_PASSWORD}" 2>/dev/null | gzip > "$DB_BACKUP_DIR/mariadb_dump_$DATE.sql.gz"
    echo "Dump MariaDB sauvegardé avec succès."
else
    echo "Attention : Le conteneur MariaDB '$CONTAINER_NAME' est introuvable ou arrêté."
fi

# Étape 3 : Archiver l'intégralité du répertoire des volumes Docker
echo "Archivage du répertoire des volumes Docker (/var/lib/docker/volumes/)..."
tar -czf "$VOL_BACKUP_DIR/docker_volumes_$DATE.tar.gz" -C /var/lib/docker volumes/
echo "Volumes Docker archivés avec succès."

# Étape 4 : Rétention automatique (supprimer les archives de plus de 7 jours)
echo "Application de la règle de rétention (suppression > $RETENTION_DAYS jours)..."
find "$BACKUP_DIR" -type f -name "*.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "=== Processus de sauvegarde et de rotation terminé avec succès ==="
