#!/bin/bash

# ==========================================
# Script 1 : Nettoyage et Rotation Intelligente des Logs
# ==========================================

# Étape 1 : Définir les variables de configuration
LOG_DIR="/var/log"
RETENTION_DAYS=14
MAX_SIZE_MB=50
REPORT_LOG="/var/log/nettoyage_script.log"

# Fonction pour journaliser chaque action (Étape 4)
log_action() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message" | tee -a "$REPORT_LOG"
}

log_action "=== Début du script de nettoyage des logs ==="

# Étape 2 : Parcourir le répertoire des logs et supprimer les archives obsolètes (*.gz, *.old) de plus de 14 jours
log_action "Recherche et suppression des archives obsolètes (*.gz, *.old) de plus de $RETENTION_DAYS jours..."
find "$LOG_DIR" -type f \( -name "*.gz" -o -name "*.old" \) -mtime +$RETENTION_DAYS | while read -r old_file; do
    rm -f "$old_file"
    log_action "Suppression de l'archive obsolète : $old_file"
done

# Étape 3 : Parcourir les fichiers actifs (*.log), vérifier leur taille en Mo et effectuer une troncature sécurisée si > 50 Mo
log_action "Vérification des fichiers actifs (*.log) dépassant ${MAX_SIZE_MB} Mo..."
find "$LOG_DIR" -type f -name "*.log" | while read -r log_file; do
    if [ -f "$log_file" ]; then
        # Obtenir la taille du fichier en mégaoctets
        size_mb=$(du -m "$log_file" | cut -f1)
        
        if [ "$size_mb" -gt "$MAX_SIZE_MB" ]; then
            # Troncature sécurisée (vider à zéro sans supprimer le fichier)
            : > "$log_file"
            log_action "Troncature sécurisée effectuée sur : $log_file (taille dépassée : ${size_mb} Mo)"
        fi
    fi
done

log_action "=== Fin du processus de nettoyage des logs ==="
