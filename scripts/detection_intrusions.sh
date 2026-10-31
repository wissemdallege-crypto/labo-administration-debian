#!/bin/bash

# ==========================================
# Script 4 : Détection d'Intrusions et Réponse Automatique
# ==========================================

# Étape 1 : Localiser le fichier de log d'authentification ou utiliser journald
AUTH_LOG="/var/log/auth.log"
SECURITY_REPORT="/var/log/securite_alertes.log"
THRESHOLD=5

# Fonction pour journaliser les alertes
log_alert() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message" | tee -a "$SECURITY_REPORT"
}

log_alert "=== Début de l'analyse de détection d'intrusions SSH ==="

# Vérification de la source des logs
if [ -f "$AUTH_LOG" ]; then
    # Étape 2 & 3 : Extraire, dénombrer les IP en échec et comparer au seuil critique (ex: 5 tentatives)
    # On extrait les lignes "Failed password", récupère l'IP (généralement le champ 11), compte les occurrences
    failed_ips=$(grep "Failed password" "$AUTH_LOG" | awk '{for(i=1;i<=NF;i++) if ($i=="from") print $(i+1)}' | sort | uniq -c)
    
    while read -r count ip; do
        if [ -n "$count" ] && [ "$count" -ge "$THRESHOLD" ]; then
            log_alert "ALERTE : Adresse IP suspecte détectée : $ip avec $count échecs de connexion."
            
            # Étape 4 : Ajouter une règle de blocage défensive dans UFW si l'IP n'est pas déjà bannie
            if command -v ufw &> /dev/null; then
                if ! ufw status | grep -q "$ip"; then
                    ufw deny from "$ip" to any port 22 proto tcp
                    log_alert "Action UFW : IP $ip bloquée avec succès."
                else
                    log_alert "Information : L'IP $ip est déjà bannie dans UFW."
                fi
            else
                log_alert "Erreur : UFW n'est pas installé ou disponible."
            fi
        fi
    done <<< "$failed_ips"
else
    log_alert "Erreur : Le fichier de log $AUTH_LOG est introuvable."
fi

log_alert "=== Fin de l'analyse de détection d'intrusions ==="
