#!/bin/sh
BOTNAME="Julius"
THUMBNAIL_URL="https://cdn-icons-png.flaticon.com/512/5064/5064910.png"
AVATAR_URL="https://w7.pngwing.com/pngs/668/952/png-transparent-debian-arch-linux-computer-icons-desktop-linux-spiral-logo-magenta.png"
WEBHOOK="DISCORD WEEBHOOK" # lien du webhook
DATE=$(date +"%d-%m-%Y-%H:%M:%S")
server="DEDICATED"
USERID="<@!242990516843708416>"
TMPFILE=$(mktemp)

# Récupération IP
IP=$(echo $SSH_CLIENT | awk '{ print $1 }')
curl -s "https://ipapi.co/${IP}/json/" > $TMPFILE

# Timestamp ISO
getCurrentTimestamp() { date -u --iso-8601=seconds; }
 
SRV_HOSTNAME=$(hostname -f)
SRV_IP=$(hostname -I | awk '{print $1}')

# Construire description avec variables correctement
DESCRIPTION="**Détails du serveur**\n🟢 Utilisateur: \`$(whoami)\`\n👤 Type de serveur: \`$server\`\n🖥️ HostName: \`$SRV_HOSTNAME\`\n🕐 Time: \`$DATE\`\n\n**Connexion IP**\n📡 IP: \`$IP\`\n📡 Whois: https://db-ip.com/$IP"

# Envoi du webhook
curl -s -H "Content-Type: application/json" -X POST --data "{
    \"username\": \"$BOTNAME\",
    \"avatar_url\": \"$AVATAR_URL\",
    \"content\": \"🔔 Hey $USERID Nouvelle connexion **SSH**\",
    \"embeds\": [{
        \"color\": 12976176,
        \"title\": \"SSH Login Détections\",
        \"thumbnail\": { \"url\": \"$THUMBNAIL_URL\" },
        \"author\": { \"name\": \"$BOTNAME\", \"icon_url\": \"$AVATAR_URL\" },
        \"footer\": { \"icon_url\": \"$AVATAR_URL\", \"text\": \"$BOTNAME\" },
        \"description\": \"$DESCRIPTION\",
        \"timestamp\": \"$(getCurrentTimestamp)\"
    }]
}" $WEBHOOK > /dev/null

# Suppression du fichier temporaire
[ -e $TMPFILE ] && rm -f $TMPFILE


