#!/bin/bash
echo "[ Installer ZIVPN Manager - Dika-bot / udpmbps ]"

wget -O /usr/local/bin/udpmbps https://raw.githubusercontent.com/Dika-bot/udpmbps/main/manager.sh
chmod +x /usr/local/bin/udpmbps

echo "Instalasi selesai!"
echo "Jalankan dengan perintah:"
echo "  udpmbps"
