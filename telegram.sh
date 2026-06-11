#!/bin/bash

# ---------------------------
# CONFIGURATION
# ---------------------------
TELEGRAM_BOT_TOKEN="8127642052:AAHNu7qVqhKAAGLgy3zbNHWoQBXE_ZYcedA" # Remplacer par le token du bot
TELEGRAM_CHAT_ID="-1003397949834"     # Remplacer par l'ID du chat/canal
SERVER="PROXMOX"
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
# MESSAGE TELEGRAM
# ---------------------------
TITLE="🔔 Nouvelle connexion"

# 🚨 Alerte ROOT distant
if [ "$USER" = "root" ] && [ "$CONN_TYPE" = "SSH (client distant)" ]; then
    TITLE="🚨 ALERTE ROOT DISTANT 🚨"
fi

TEXT=$(cat <<EOF
<b>$TITLE</b>

<b>👤 Utilisateur:</b> <code>$USER</code>
<b>🆔 Type:</b> $USER_TYPE
<b>🔐 Connexion:</b> <code>$CONN_TYPE</code>

<b>🖥️ Serveur:</b> <code>$SERVER</code>
<b>🏷️ Hostname:</b> <code>$SRV_HOSTNAME</code>
<b>🌐 IP serveur:</b> <code>$SRV_IP</code>

<b>📡 IP source:</b> <code>$IP</code>
<b>🌍 Localisation:</b> $CITY, $COUNTRY
<b>🏢 Fournisseur:</b> <code>$ISP</code>

⏰ $DATE
EOF
)

PAYLOAD=$(jq -n \
  --arg chat_id "$TELEGRAM_CHAT_ID" \
  --arg text "$TEXT" \
  --arg parse_mode "HTML" \
'{
  chat_id: $chat_id,
  text: $text,
  parse_mode: $parse_mode
}')

# ---------------------------
# ENVOI TELEGRAM
# ---------------------------
curl -s -H "Content-Type: application/json" \
     -X POST \
     -d "$PAYLOAD" \
     "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" >/dev/null
