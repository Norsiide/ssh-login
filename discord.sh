#!/bin/bash

# ---------------------------
# CONFIGURATION
# ---------------------------
DISCORD_WEBHOOK="URL_DU_WEBHOOK_DISCORD" # Webhook Discord
SERVER="DEDICATED LOCAL"
STATE_FILE="/opt/ssh-login/ssh_last"
DATE=$(date +"%d-%m-%Y %H:%M:%S")

# ---------------------------
# INFOS SERVEUR & UTILISATEUR
# ---------------------------
USER=$(whoami)
SRV_HOSTNAME=$(hostname -f)
SRV_IP=$(hostname -I | awk '{print $1}')

# ---------------------------
# TYPE DE CONNEXION
# ---------------------------
if [ -n "$SSH_CLIENT" ]; then
    CONN_TYPE="SSH (client distant)"
    IP=$(echo "$SSH_CLIENT" | awk '{print $1}')
else
    CONN_TYPE="LOCAL (machine)"
    IP="127.0.0.1"
fi

# ---------------------------
# TYPE UTILISATEUR
# ---------------------------
if [ "$USER" = "root" ]; then
    USER_TYPE="⚠️ ROOT"
else
    USER_TYPE="👤 Utilisateur"
fi

# ---------------------------
# GEOLOCALISATION IP
# ---------------------------
if [ "$IP" != "127.0.0.1" ]; then
    IPINFO=$(curl -s --max-time 5 "https://ipapi.co/${IP}/json/")
    COUNTRY=$(echo "$IPINFO" | jq -r '.country_name // "Inconnu"')
    CITY=$(echo "$IPINFO" | jq -r '.city // "Inconnue"')
    ISP=$(echo "$IPINFO" | jq -r '.org // "Inconnu"')
else
    COUNTRY="Local"
    CITY="Machine"
    ISP="Localhost"
fi

# ---------------------------
# ANTI-SPAM
# ---------------------------
LAST_LINE=""
[ -f "$STATE_FILE" ] && LAST_LINE=$(cat "$STATE_FILE")

NEW_LINE="${USER}_${IP}_${DATE}"
if [ "$NEW_LINE" = "$LAST_LINE" ]; then
    exit 0
fi
echo "$NEW_LINE" > "$STATE_FILE"

# ---------------------------
# EMBED DISCORD
# ---------------------------
TITLE="🔔 Nouvelle connexion"
COLOR=3066993 # Vert

# 🚨 Alerte ROOT distant
if [ "$USER" = "root" ] && [ "$CONN_TYPE" = "SSH (client distant)" ]; then
    TITLE="🚨 ALERTE ROOT DISTANT 🚨"
    COLOR=15158332 # Rouge
fi

PAYLOAD=$(jq -n \
  --arg title "$TITLE" \
  --arg user "$USER" \
  --arg usertype "$USER_TYPE" \
  --arg conn "$CONN_TYPE" \
  --arg server "$SERVER" \
  --arg host "$SRV_HOSTNAME" \
  --arg srvip "$SRV_IP" \
  --arg date "$DATE" \
  --arg ip "$IP" \
  --arg city "$CITY" \
  --arg country "$COUNTRY" \
  --arg isp "$ISP" \
  --argjson color "$COLOR" \
'{
  embeds: [
    {
      title: $title,
      color: $color,
      fields: [
        { "name": "👤 Utilisateur", "value": ("`" + $user + "`"), "inline": true },
        { "name": "🆔 Type", "value": $usertype, "inline": true },
        { "name": "🔐 Connexion", "value": ("`" + $conn + "`"), "inline": true },

        { "name": "🖥️ Serveur", "value": ("`" + $server + "`"), "inline": true },
        { "name": "🏷️ Hostname", "value": ("`" + $host + "`"), "inline": true },
        { "name": "🌐 IP serveur", "value": ("`" + $srvip + "`"), "inline": true },

        { "name": "📡 IP source", "value": ("`" + $ip + "`"), "inline": true },
        { "name": "🌍 Localisation", "value": ($city + ", " + $country), "inline": true },
        { "name": "🏢 Fournisseur", "value": ("`" + $isp + "`"), "inline": true }
      ],
      footer: {
        text: ("⏰ " + $date)
      }
    }
  ]
}')

# ---------------------------
# ENVOI DISCORD
# ---------------------------
curl -s -H "Content-Type: application/json" \
     -X POST \
     -d "$PAYLOAD" \
     "$DISCORD_WEBHOOK" >/dev/null
