# Mailcow – Vollständige Installationsanleitung (Docker, Stand November 2025)

Diese README ist **vollständig GitHub-Mobile-kompatibel**, alle Befehle sind in **```bash**-Codeblöcken**, damit der **Copy-Button** auf iPhone sauber funktioniert.

Mailcow wird als Docker‑Stack installiert und beinhaltet:
- Mailserver (Postfix, Dovecot)
- Webinterface
- ACME/Let’s Encrypt
- DNS-Einrichtung
- Fail2ban
- SOGo (optional)

---

# 1. Voraussetzungen

- Ubuntu 22.04 oder 24.04  
- Root-Rechte  
- Eine Domain (z. B. mail.deinedomain.ch)  
- DNS-Zugriff  
- Offene Ports: 25, 80, 110, 143, 443, 465, 587, 993, 995  

---

# 2. System aktualisieren

```bash
sudo apt update
```

```bash
sudo apt upgrade -y
```

---

# 3. Docker vorbereiten

## 3.1 Pakete installieren

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

## 3.2 Defekten Docker-Key löschen (Hetzner-Fix)

```bash
sudo rm -f /usr/share/keyrings/docker.gpg
```

## 3.3 Docker GPG-Key neu hinzufügen

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o docker.gpg
```

```bash
sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg docker.gpg
```

```bash
rm docker.gpg
```

## 3.4 Repository hinzufügen

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

## 3.5 Update

```bash
sudo apt update
```

## 3.6 Docker installieren

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## 3.7 Docker aktivieren

```bash
sudo systemctl enable docker
```

---

# 4. Mailcow herunterladen

## 4.1 Git installieren

```bash
sudo apt install -y git
```

## 4.2 Mailcow Repo klonen

```bash
git clone https://github.com/mailcow/mailcow-dockerized.git /opt/mailcow
```

```bash
cd /opt/mailcow
```

---

# 5. Setup starten

## 5.1 Konfiguration erzeugen

```bash
./generate_config.sh
```

Du wirst gefragt:

- Mailserver-Host: **mail.deinedomain.ch**
- Zeitzone: **Europe/Zurich**

---

# 6. Mailcow starten

```bash
docker compose pull
```

```bash
docker compose up -d
```

---

# 7. DNS-Einträge setzen

### Zwingend nötig:

**A‑Record**  
mail → IPv4 deines Servers

**AAAA‑Record (optional)**  
mail → IPv6 deines Servers

**MX-Record**  
@ → mail.deinedomain.ch (Priorität 10)

**SPF**  
`v=spf1 mx -all`

**DKIM**  
Nach Start im Mailcow UI unter „Configuration → DKIM“ abrufen.

**DMARC**  
`v=DMARC1; p=quarantine; rua=mailto:postmaster@deinedomain.ch`

**Autodiscover / Autoconfig**  
autodiscover → gleiche IP  
autoconfig → gleiche IP

---

# 8. Webinterface öffnen

```bash
https://mail.deinedomain.ch
```

Login:

- Benutzer: **admin**
- Passwort: das bei Installation gesetzte

---

# 9. SSL aktivieren (Let’s Encrypt)

Mailcow kümmert sich selbst darum.

Manuell anstoßen:

```bash
docker compose restart acme-mailcow
```

---

# 10. Fail2ban (Mailcow-intern)

Fail2ban ist in Mailcow bereits integriert und vorkonfiguriert.  
Zusätzliche Installation ist **nicht nötig**.

Status prüfen:

```bash
docker logs f2b-mailcow
```

---

# 11. Mail testen

## SMTP prüfen

```bash
telnet mail.deinedomain.ch 25
```

## IMAP prüfen

```bash
openssl s_client -connect mail.deinedomain.ch:993
```

---

# 12. Backup von Mailcow

Backup-Script ausführen:

```bash
cd /opt/mailcow
```

```bash
./helper-scripts/backup_and_restore.sh backup all
```

Standard-Speicherort:

```
/opt/mailcow/backups
```

---

# 13. Mailcow updaten (Stand 2025)

```bash
cd /opt/mailcow
```

```bash
git pull
```

```bash
docker compose pull
```

```bash
docker compose up -d
```

---

# 14. Dienste neu starten

```bash
docker compose restart
```

---

# Fertig

Mailcow ist vollständig installiert und produktionsbereit.

Stand: November 2025
