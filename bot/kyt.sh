#!/bin/bash

# === Variabel awal ===
NS=$(cat /etc/xray/dns 2>/dev/null)
PUB=$(cat /etc/slowdns/server.pub 2>/dev/null)
domain=$(cat /etc/xray/domain 2>/dev/null)

grenbo="\e[92;1m"
NC='\e[0m'

# Pastikan apt-get ada sebelum digunakan
if ! command -v apt-get &> /dev/null; then
    echo -e "\e[91m[ERROR] Sistem ini tidak menggunakan apt-get. Skrip dihentikan.\e[0m"
    exit 1
fi

# === Membersihkan cache dpkg yang bisa mengunci apt ===
echo -e "[INFO] Membersihkan lock file APT..."
rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/dpkg/statoverride
dpkg --configure -a

# === Hapus file/service lama ===
echo -e "[INFO] Menghapus service lama..."
systemctl stop kyt 2>/dev/null
rm -f /etc/systemd/system/kyt.service
rm -rf /usr/bin/kyt /usr/bin/bot /usr/bin/kyt.* /usr/bin/bot.* /root/kyt.zip /root/bot.zip /root/kyt.sh

# === Update dan Install dependencies ===
echo -e "[INFO] Update dan install package penting..."
# Update paket
sudo apt-get update > /dev/null 2>&1
# Install zip, unzip, python3, pip, dan git
sudo apt-get install -y zip unzip python3 python3-pip git

# === Download dan pasang bot (Script/Utility Pendukung) ===
echo -e "[INFO] Download & pasang bot (Utility)..."
wget -q https://raw.githubusercontent.com/jurnakhusnaa/os/master/bot/bot.zip
unzip -o bot.zip
mv bot/* /usr/bin
# Hanya berikan hak eksekusi pada file yang diekstrak dari bot.zip
chmod +x /usr/bin/bot-*
rm -rf bot bot.zip

# === Download dan pasang kyt (Bot Utama) ===
echo -e "[INFO] Download & pasang Bot (Python Modules)..."
wget -q https://raw.githubusercontent.com/jurnakhusnaa/os/master/bot/kyt.zip
# Ekstrak ke /usr/bin/, akan membuat folder /usr/bin/kyt/
unzip -o kyt.zip -d /usr/bin/

# Instal dependensi Python
echo -e "[INFO] Menginstal dependensi Python dari requirements.txt..."
cd /usr/bin/kyt
# Menggunakan pip3 secara eksplisit
/usr/bin/pip3 install -r requirements.txt
cd

# === Konfigurasi bot ===
clear
# Perlu lolcat dan figlet terinstal agar baris ini bekerja
if command -v figlet &> /dev/null && command -v lolcat &> /dev/null; then
    figlet "EDAN VPN" | lolcat
fi
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \e[1;97;101m          ADD BOT PANEL          \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "${grenbo}Tutorial Create Bot dan ID Telegram${NC}"
echo -e "${grenbo}[*] Buat Bot dan Token : @BotFather${NC}"
echo -e "${grenbo}[*] Cek ID Telegram : @MissRose_bot, perintah /info${NC}"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -e -p "[*] Masukkan Bot Token Anda : " bottoken
read -e -p "[*] Masukkan ID Telegram Anda : " admin

# === Simpan file variabel environment ===
mkdir -p /etc/bot
cat <<EOF > /usr/bin/kyt/var.txt
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$domain"
PUB="$PUB"
HOST="$NS"
EOF

echo "#bot# $bottoken $admin" > /etc/bot/.bot.db

# === Buat systemd service untuk bot (Perbaikan Fatal) ===
echo -e "[INFO] Membuat Systemd Service..."
cat >/etc/systemd/system/kyt.service <<EOF
[Unit]
Description=Kyt Bot V2
After=network.target

[Service]
# WorkingDirectory mengarah ke folder utama bot
WorkingDirectory=/usr/bin/kyt
# ExecStart menjalankan modul 'kyt' menggunakan python3
ExecStart=/usr/bin/python3 -m kyt
Restart=always

[Install]
WantedBy=multi-user.target
EOF


# === Aktifkan service ===
echo -e "[INFO] Mengaktifkan dan memulai service kyt..."
sudo systemctl daemon-reload
sudo systemctl enable kyt.service
sudo systemctl start kyt.service

# Cek status service
if sudo systemctl is-active --quiet kyt.service; then
    SERVICE_STATUS="\e[92mAKTIF (Berjalan)\e[0m"
else
    SERVICE_STATUS="\e[91mGAGAL\e[0m. Cek log: journalctl -xeu kyt.service"
fi

# === Output selesai ===
clear
echo -e "\e[92mInstalasi selesai!\e[0m"
echo "==============================="
echo "Token Bot     : $bottoken"
echo "Admin ID      : $admin"
echo "Domain        : $domain"
echo "Status Service: $SERVICE_STATUS"
echo "==============================="
echo "Ketik /menu di Bot Telegram Anda"
