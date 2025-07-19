#!/bin/bash
set -e

echo "📦 Starte vollautomatische Mailcow-Installation..."

# System vorbereiten
echo "🔄 Aktualisiere System..."
sudo apt update && sudo apt upgrade -y

echo "🧰 Installiere benötigte Pakete..."
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release git sudo

# Docker & Compose installieren
echo "🐳 Installiere Docker..."
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER"

# Docker Compose v2 absichern
if ! command -v docker compose &>/dev/null; then
    echo "🔧 Installiere Docker Compose v2..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Mailcow klonen
echo "⬇️ Lade Mailcow herunter..."
git clone https://github.com/mailcow/mailcow-dockerized.git ~/mailcow
cd ~/mailcow

# Konfigurationsdatei erstellen
echo "⚙️ Konfiguriere Mailcow..."

# Hostname abfragen
read -p "🌐 Gib den FQDN (z. B. mail.deine-domain.tld) ein: " fqdn

cp mailcow.conf.example mailcow.conf
sed -i "s/^MAILCOW_HOSTNAME=.*/MAILCOW_HOSTNAME=$fqdn/" mailcow.conf

# Zufalls-Passwort für Mailcow generieren
./generate_config.sh

# Starten
echo "🚀 Starte Mailcow-Container..."
docker compose pull
docker compose up -d

echo ""
echo "✅ Mailcow ist jetzt gestartet!"
echo "👉 Du erreichst das Webinterface unter: https://$fqdn"
echo "   (Achte darauf, dass DNS & Ports korrekt sind)"
echo ""
