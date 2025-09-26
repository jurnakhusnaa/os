#!/bin/bash

# === Variabel awal ===
NS=$(cat /etc/xray/dns 2>/dev/null)
PUB=$(cat /etc/slowdns/server.pub 2>/dev/null)
domain=$(cat /etc/xray/domain 2>/dev/null)

grenbo="\e[92;1m"
NC='\e[0m'

# === Membersihkan cache dpkg yang bisa mengunci apt ===
echo -e "[INFO] Membersihkan lock file APT..."
rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/dpkg/statoverride
dpkg --configure -a

# === Hapus file/service lama ===
echo -e "[INFO] Menghapus service lama..."
systemctl stop kyt 2>/dev/null
rm -f /etc/systemd/system/kyt.service
rm -rf /usr/bin/kyt /usr/bin/bot /usr/bin/kyt.* /usr/bin/bot.* /root/kyt.zip /root/bot.zip

# === Update dan Install dependencies ===
echo -e "[INFO] Update dan install package penting..."
sudo apt-get update > /dev/null 2>&1
apt install zip unzip -y
sudo apt-get install -y python3 python3-pip git

# === Download dan pasang bot ===
echo -e "[INFO] Download & pasang bot..."
wget -q https://raw.githubusercontent.com/jurnakhusnaa/os/master/bot/bot.zip
unzip -o bot.zip
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot bot.zip

# === Download dan pasang kyt ===
echo -e "[INFO] Download & pasang Bot..."
wget -q https://raw.githubusercontent.com/jurnakhusnaa/os/master/bot/kyt.zip
unzip -o kyt.zip -d /usr/bin/
cd /usr/bin/kyt
pip install -r requirements.txt
cd

# === Konfigurasi bot ===
clear
figlet "EDAN VPN" | lolcat
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

# === Buat systemd service untuk bot ===
cat >/etc/systemd/system/kyt.service <<EOF
Unit]
Description=Kyt Bot V2
After=network.target

[Service]
WorkingDirectory=/usr/bin/kyt
ExecStart=/usr/bin/python3 -m kyt
Restart=always

[Install]
WantedBy=multi-user.target
EOF


# === Aktifkan service ===
systemctl daemon-reload
systemctl enable --now kyt

# === Output selesai ===
clear
echo -e "\e[92mInstalasi selesai!\e[0m"
echo "==============================="
echo "Token Bot     : $bottoken"
echo "Admin ID      : $admin"
echo "Domain        : $domain"
echo "==============================="
echo "Ketik /menu di Bot Telegram Anda"
