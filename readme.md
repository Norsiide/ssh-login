<p align="center"><img src="https://norsiide.be/media-proxy/3/01KQG1PSN5X63RC6ZCKM2TDGFE.png" width="100" alt="norsiide"></p>

# SSH login notifications

[![WebSite](https://img.shields.io/website?down_message=Offline&label=WebSite&up_message=Online&url=https%3A%2F%2Fnorsiide.be)](https://norsiide.be)
[![Discord](https://img.shields.io/discord/1126981605785866341?color=5865f2&label=Discord&logo=discord&logoColor=fff&style=flat-square)](https://discord.gg/EV3fAhFZJT)

**SSH login Notifications** est un petit script qui vous permet d'etre avertie lors d'une connexion SSH

![Screenshot](https://norsiide.be/images/github/ssh-login/screen-telegram.png)

## Notifications supportées 
* Telegram

# Installations du system

(1) Installer les dependance

```
apt install curl && git && jq
```
(2) Puis on va dans le dossier ( opt )
 
```
cd /opt/
```
(4) Maintenant on peut ajouter le repos
 
```
git clone https://github.com/Norsiide/ssh-login.git
```

(5) On activer les scripts
 
```
sh /opt/ssh-login/deploy.sh
```
(6) Config
* Telegram
Vous devez configurer le token de votre bot et votre chat ID dans le script telegram.sh
    - TELEGRAM_BOT_TOKEN="TON_BOT_TOKEN"
    - TELEGRAM_CHAT_ID="TON_CHAT_ID"

(7) Maintenant nous pouvons tester le scripts
 
```
sh /etc/profile.d/ssh-alert.sh
```
