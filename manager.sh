#!/bin/bash
# ======================================================
#   ZIVPN UDP ACCOUNT MANAGER (CLASSIC VERSION)
#   Dika-bot / udpmbps
# ======================================================

DATA_DIR="/etc/zivpn"
ACCOUNTS_FILE="$DATA_DIR/accounts.db"
LOG_FILE="$DATA_DIR/logs.log"
BACKUP_DIR="$DATA_DIR/backup"
CONFIG_DIR="$DATA_DIR/config"

mkdir -p $DATA_DIR $BACKUP_DIR $CONFIG_DIR

# Create database file if not exist
[[ ! -f $ACCOUNTS_FILE ]] && touch $ACCOUNTS_FILE
[[ ! -f $LOG_FILE ]] && touch $LOG_FILE

banner() {
clear
echo "=========================================="
echo "         ZIVPN UDP ACCOUNT MANAGER        "
echo "=========================================="
echo "IP VPS     : $(curl -s ifconfig.me)"
echo "Port Aktif : 5667"
echo "=========================================="
}

list_accounts() {
    banner
    echo "[ DAFTAR AKUN UDP ]"
    echo "-------------------------------------------"
    if [[ ! -s $ACCOUNTS_FILE ]]; then
        echo "Tidak ada akun."
    else
        awk -F "|" '{ printf "User: %-10s | Exp: %-10s | IP Limit: %s | Quota: %s MB\n", $1, $2, $3, $4 }' $ACCOUNTS_FILE
    fi
    echo "-------------------------------------------"
    read -p "Enter untuk kembali..."
}

add_account() {
    banner
    read -p "Masukkan username: " user
    read -p "Masa aktif (hari): " days
    read -p "Limit IP: " ip_limit
    read -p "Limit Kuota (MB, 0=unlimited): " quota

    exp=$(date -d "$days days" +"%Y-%m-%d")
    echo "$user|$exp|$ip_limit|$quota" >> $ACCOUNTS_FILE

    echo "[+] Akun berhasil dibuat!"
    sleep 1
}

delete_account() {
    banner
    read -p "Masukkan username: " user
    sed -i "/^$user|/d" $ACCOUNTS_FILE
    echo "[+] Akun dihapus!"
    sleep 1
}

edit_account() {
    banner
    read -p "Username: " user
    line=$(grep "^$user|" $ACCOUNTS_FILE)

    if [[ -z "$line" ]]; then
        echo "[!] Akun tidak ditemukan!"
        sleep 1
        return
    fi

    IFS="|" read olduser oldexp oldip oldquota <<< "$line"

    read -p "IP Limit baru ($oldip): " newip
    read -p "Kuota baru ($oldquota MB): " newquota

    newip=${newip:-$oldip}
    newquota=${newquota:-$oldquota}

    sed -i "s/^$user|.*/$user|$oldexp|$newip|$newquota/" $ACCOUNTS_FILE
    echo "[+] Akun diperbarui!"
    sleep 1
}

backup_accounts() {
    cp $ACCOUNTS_FILE $BACKUP_DIR/accounts.backup
    echo "$(date) BACKUP DONE" >> $LOG_FILE
    echo "[+] Backup selesai."
    sleep 1
}

restore_accounts() {
    cp $BACKUP_DIR/accounts.backup $ACCOUNTS_FILE
    echo "$(date) RESTORE DONE" >> $LOG_FILE
    echo "[+] Restore berhasil."
    sleep 1
}

vps_status() {
    banner
    echo "[ STATUS VPS ]"
    echo "CPU Load : $(top -bn1 | grep load | awk '{printf \"%.2f%%\", $(NF-2)}')"
    echo "RAM      : $(free -m | awk '/Mem/ {printf \"%d / %d MB\", $3, $2}')"
    echo "Disk     : $(df -h / | awk 'NR==2 {print $3 \" / \" $2}')"
    echo "Uptime   : $(uptime -p)"
    echo "-------------------------------------------"
    read -p "Enter untuk kembali..."
}

menu() {
while true; do
    banner
    echo "1) Lihat akun UDP"
    echo "2) Tambah akun baru"
    echo "3) Hapus akun"
    echo "4) Edit akun"
    echo "5) Restart layanan ZIVPN"
    echo "6) Status VPS"
    echo "7) Backup akun"
    echo "8) Restore akun"
    echo "0) Keluar"
    echo "=========================================="
    read -p "Pilih menu: " opt

    case $opt in
        1) list_accounts ;;
        2) add_account ;;
        3) delete_account ;;
        4) edit_account ;;
        5) systemctl restart zivpn; sleep 1 ;;
        6) vps_status ;;
        7) backup_accounts ;;
        8) restore_accounts ;;
        0) exit ;;
        *) echo "Menu salah!"; sleep 1 ;;
    esac
done
}

menu
