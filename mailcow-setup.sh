#!/bin/bash
set -e

echo "📦 Starte vollautomatische Mailcow-Installation..."

# ----------------------------------------
# 1) System vorbereiten
# ----------------------------------------
echo "🔄 Aktualisiere System..."
sudo apt update && sudo apt upgrade -y

echo "🧰 Installiere benötigte Pakete..."
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release git sudo

# ----------------------------------------
# 2) Docker & Docker Compose installieren
# ----------------------------------------
echo "🐳 Installiere Docker..."
curl -fsSL https://get.docker.com | sudo sh

# Aktuellen Benutzer in die Docker-Gruppe aufnehmen
sudo usermod -aG docker "$USER" || true

# Docker Compose v2 sicherstellen (falls noch nicht vorhanden)
if ! command -v docker &>/dev/null || ! docker compose version &>/dev/null; then
    echo "🔧 Installiere Docker Compose v2 Plugin..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# ----------------------------------------
# 3) Mailcow herunterladen
# ----------------------------------------
echo "⬇️ Lade Mailcow herunter..."
if [ -d "$HOME/mailcow" ]; then
    echo "ℹ️ Verzeichnis ~/mailcow existiert bereits, benutze vorhandenes Repo..."
    cd "$HOME/mailcow"
    git pull
else
    git clone https://github.com/mailcow/mailcow-dockerized.git "$HOME/mailcow"
    cd "$HOME/mailcow"
fi

# ----------------------------------------
# 4) Mailcow konfigurieren
# ----------------------------------------
echo "⚙️ Konfiguriere Mailcow..."
echo "   Das offizielle Mailcow-Script 'generate_config.sh' wird gestartet."
echo "   Du wirst nach dem Hostnamen (FQDN) gefragt, z. B.: mail.deine-domain.tld"
echo ""

./generate_config.sh

# FQDN aus der erzeugten Konfigurationsdatei auslesen
fqdn=$(grep '^MAILCOW_HOSTNAME=' mailcow.conf | cut -d= -f2 || echo "deine-mail-domain.tld")

# ----------------------------------------
# 5) Mailcow starten
# ----------------------------------------
echo "🚀 Starte Mailcow-Container..."
docker compose pull
docker compose up -d

echo ""
echo "✅ Mailcow ist jetzt gestartet!"
echo "👉 Du erreichst das Webinterface unter: https://$fqdn"
echo "   (Stelle sicher, dass DNS-Eintrag & Ports 25, 80, 443, 587, 993 usw. korrekt weitergeleitet sind.)"
echo ""
echo "ℹ️ Hinweis: Wenn du den Server nicht als root benutzt,"
echo "   melde dich einmal ab und wieder an, damit die Docker-Gruppe aktiv wird."
echo ""
