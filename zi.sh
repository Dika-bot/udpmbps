#!/bin/bash
clear
echo "==========================================="
echo "         ZIVPN UDP Server Installer         "
echo "      Ubuntu 20 / 22 / 24 LTS Supported     "
echo "==========================================="
echo ""

# Default port & password
PORT=7300
read -p "Masukkan password UDP (default: zi): " PASS
PASS=${PASS:-zi}

echo ""
echo "[*] Mengunduh binary udp-custom..."

# Binary WORKING (mirror aman, bukan file 404)
wget -O /root/udp-custom https://raw.githubusercontent.com/Cloud-Master3/ZIVPN-BIN/main/udp-custom > /dev/null 2>&1

if [ ! -s /root/udp-custom ]; then
    echo "[!] Gagal mendownload binary! Link mungkin rusak."
    exit 1
fi

chmod +x /root/udp-custom

echo "[*] Membuat service systemd..."

cat > /etc/systemd/system/udp-custom.service << END
[Unit]
Description=ZIVPN UDP Forwarder
After=network.target

[Service]
ExecStart=/root/udp-custom -l $PORT -p $PASS
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable udp-custom > /dev/null 2>&1
systemctl restart udp-custom

echo "[*] Membuka port firewall..."
ufw allow $PORT/udp > /dev/null 2>&1

echo ""
echo "==========================================="
echo "   INSTALLASI BERHASIL!"
echo "==========================================="
echo "Host Server : $(curl -s ifconfig.me)"
echo "Port UDP    : $PORT"
echo "Password    : $PASS"
echo "Aplikasi    : ZIVPN UDP"
echo "==========================================="
echo ""
echo "Status service:"
systemctl status udp-custom --no-pager
