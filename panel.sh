#!/bin/bash

# =============================================
# Script Migrasi Pterodactyl Panel
# Backup dari VPS Lama ke VPS Baru
# Dengan Sistem Installasi Sama Seperti Bot
# =============================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Konfigurasi
BACKUP_DIR="/root/pterodactyl-backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/root/migrasi_pterodactyl_${TIMESTAMP}.log"

# Konfigurasi default (sama seperti di bot)
PANEL_USER="admin"
PANEL_PASS="admin001"
PANEL_EMAIL="admin@gmail.com"

# Fungsi untuk logging
log() {
    echo -e "${2}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# Fungsi untuk menampilkan progress bar
show_progress() {
    echo -ne "${CYAN}⏳ $1${NC}\r"
    sleep 0.5
}

# Fungsi untuk cek koneksi SSH
check_ssh_connection() {
    local ip=$1
    local password=$2
    
    log "Mengecek koneksi ke $ip..." "$YELLOW"
    
    if ! command -v sshpass &> /dev/null; then
        log "Menginstall sshpass..." "$YELLOW"
        apt-get update -y > /dev/null 2>&1
        apt-get install -y sshpass > /dev/null 2>&1
    fi
    
    if sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$ip "exit" 2>/dev/null; then
        log "✅ Koneksi ke $ip berhasil!" "$GREEN"
        return 0
    else
        log "❌ Gagal koneksi ke $ip!" "$RED"
        return 1
    fi
}

# ======================= FUNGSI BACKUP =======================

# Fungsi backup database
backup_database() {
    local ip=$1
    local password=$2
    
    log "📁 Memulai backup database..." "$YELLOW"
    
    local db_info=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no root@$ip "
        cd /var/www/pterodactyl 2>/dev/null
        if [ -f .env ]; then
            DB_DATABASE=\$(grep DB_DATABASE .env | cut -d '=' -f2)
            DB_USERNAME=\$(grep DB_USERNAME .env | cut -d '=' -f2)
            DB_PASSWORD=\$(grep DB_PASSWORD .env | cut -d '=' -f2)
            echo \"\${DB_DATABASE}|\${DB_USERNAME}|\${DB_PASSWORD}\"
        fi
    ")
    
    if [ -z "$db_info" ]; then
        log "⚠️ Tidak dapat membaca konfigurasi database, akan backup semua database" "$YELLOW"
        sshpass -p "$password" ssh -o StrictHostKeyChecking=no root@$ip "
            mysqldump --all-databases > /tmp/all_databases.sql
        " 2>/dev/null
        sshpass -p "$password" scp -o StrictHostKeyChecking=no root@$ip:/tmp/all_databases.sql "$BACKUP_DIR/all_databases_${TIMESTAMP}.sql"
    else
        IFS='|' read -r DB_NAME DB_USER DB_PASS <<< "$db_info"
        sshpass -p "$password" ssh -o StrictHostKeyChecking=no root@$ip "
            mysqldump -u${DB_USER} -p${DB_PASS} ${DB_NAME} > /tmp/panel_database.sql
        " 2>/dev/null
        sshpass -p "$password" scp -o StrictHostKeyChecking=no root@$ip:/tmp/panel_database.sql "$BACKUP_DIR/database_${TIMESTAMP}.sql"
    fi
    
    log "✅ Backup database selesai!" "$GREEN"
}

# Fungsi backup file panel
backup_panel_files() {
    local ip=$1
    local password=$2
    
    log "📁 Memulai backup file panel..." "$YELLOW"
    
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no root@$ip "
        tar -czf /tmp/pterodactyl_files.tar.gz /var/www/pterodactyl 2>/dev/null
    " 2>/dev/null
    
    sshpass -p "$password" scp -o StrictHostKeyChecking=no root@$ip:/tmp/pterodactyl_files.tar.gz "$BACKUP_DIR/pterodactyl_files_${TIMESTAMP}.tar.gz"
    
    log "✅ Backup file panel selesai!" "$GREEN"
}

# Fungsi backup konfigurasi wings
backup_wings_config() {
    local ip=$1
    local password=$2
    
    log "📁 Memulai backup konfigurasi Wings..." "$YELLOW"
    
    sshpass -p "$password" scp -o StrictHostKeyChecking=no root@$ip:/etc/pterodactyl/config.yml "$BACKUP_DIR/config_${TIMESTAMP}.yml" 2>/dev/null
    
    if [ -f "$BACKUP_DIR/config_${TIMESTAMP}.yml" ]; then
        log "✅ Backup konfigurasi Wings selesai!" "$GREEN"
    else
        log "⚠️ Tidak找到 konfigurasi Wings" "$YELLOW"
    fi
}

# ======================= FUNGSI INSTALL PANEL (SAMA PERSIS DENGAN BOT) =======================

install_panel() {
    local domainpanel=$1
    
    log "🚀 INSTALL PANEL - Menjalankan installer panel..." "$CYAN"
    
    # Install Pterodactyl Panel dengan cara yang sama seperti bot
    bash <(curl -s https://pterodactyl-installer.se) << EOF
0
y
${PANEL_USER}
${PANEL_USER}
${PANEL_PASS}
Asia/Jakarta
${PANEL_EMAIL}
${PANEL_EMAIL}
${PANEL_USER}
admin
admin
${domainpanel}
y
y
1
y
y
yes
y
y
y
A
EOF
    
    log "✅ Panel selesai diinstall!" "$GREEN"
}

# ======================= FUNGSI INSTALL WINGS (SAMA PERSIS DENGAN BOT) =======================

install_wings() {
    local domainpanel=$1
    local domainnode=$2
    local ramserver=$3
    
    log "🚀 INSTALL WINGS - Menjalankan installer wings..." "$CYAN"
    
    # Install Wings dengan cara yang sama seperti bot (menggunakan pipe input)
    bash <(curl -s https://pterodactyl-installer.se) << EOF
1
y
${domainpanel}
${PANEL_USER}
${PANEL_PASS}
${domainnode}
${PANEL_EMAIL}
EOF
    
    log "✅ Wings selesai diinstall, lanjut create node..." "$GREEN"
    
    # Create Node dengan script createnode.sh (sama seperti bot)
    create_node "$domainnode" "$ramserver"
}

# ======================= FUNGSI CREATE NODE (SAMA PERSIS DENGAN BOT) =======================

create_node() {
    local domainnode=$1
    local ramserver=$2
    
    log "🔧 CREATENODE - Membuat node baru..." "$CYAN"
    
    # Download script createnode
    curl -s https://raw.githubusercontent.com/Bangsano/Autoinstaller-Theme-Pterodactyl/main/createnode.sh -o /tmp/createnode.sh
    chmod +x /tmp/createnode.sh
    
    # Jalankan createnode dengan input otomatis (sama seperti bot)
    cd /var/www/pterodactyl
    
    # Persiapan untuk create node melalui artisan
    php artisan p:location:make << EOF
SGP
SGP
EOF
    
    php artisan p:node:make << EOF
1
NODES OMHC
${domainnode}
${domainnode}
${ramserver}
${ramserver}
${ramserver}
8080
2022
/var/lib/pterodactyl/volumes
EOF
    
    log "✅ Node berhasil dibuat!" "$GREEN"
    
    # Generate config.yml & restart wings (sama seperti bot)
    log "⚙️ Generate config.yml & restart wings..." "$YELLOW"
    
    cd /var/www/pterodactyl
    php artisan p:node:configuration 1 > /etc/pterodactyl/config.yml
    chmod 600 /etc/pterodactyl/config.yml
    systemctl restart wings
    
    log "✅ Config.yml generated & wings restarted!" "$GREEN"
}

# ======================= ALTERNATIF INSTALL WINGS (MENGGUNAKAN EXEC INTERACTIVE) =======================

# Fungsi ini adalah replikasi persis dari execInteractive di bot
install_wings_interactive() {
    local domainpanel=$1
    local domainnode=$2
    local ramserver=$3
    
    log "🚀 INSTALL WINGS (Interactive) - Menjalankan installer wings..." "$CYAN"
    
    # Buat temporary script untuk simulasi input interaktif
    cat > /tmp/wings_install.sh << 'WINGSSCRIPT'
#!/bin/bash
# Simulasi input interaktif untuk wings installer
{
    sleep 2
    echo "1"  # Pilih Wings
    sleep 2
    echo "y"  # Confirm
    sleep 2
    echo "$1"  # Panel domain
    sleep 2
    echo "$2"  # Database username (admin)
    sleep 2
    echo "$3"  # Database password (admin001)
    sleep 2
    echo "$4"  # Node domain
    sleep 2
    echo "$5"  # Email
} | bash <(curl -s https://pterodactyl-installer.se)
WINGSSCRIPT

    chmod +x /tmp/wings_install.sh
    /tmp/wings_install.sh "$domainpanel" "$PANEL_USER" "$PANEL_PASS" "$domainnode" "$PANEL_EMAIL"
    
    log "✅ Wings selesai diinstall!" "$GREEN"
    
    # Create node
    create_node_interactive "$domainnode" "$ramserver"
}

create_node_interactive() {
    local domainnode=$1
    local ramserver=$2
    
    log "🔧 CREATENODE - Membuat node (interactive)..." "$CYAN"
    
    cd /var/www/pterodactyl
    
    # Create location
    echo -e "SGP\nSGP\n" | php artisan p:location:make
    
    # Create node dengan input otomatis
    cat > /tmp/node_input.txt << EOF
1
NODES OMHC
${domainnode}
${domainnode}
${ramserver}
${ramserver}
${ramserver}
8080
2022
/var/lib/pterodactyl/volumes
EOF
    
    cat /tmp/node_input.txt | php artisan p:node:make
    
    # Generate config
    php artisan p:node:configuration 1 > /etc/pterodactyl/config.yml
    chmod 600 /etc/pterodactyl/config.yml
    systemctl restart wings
    
    log "✅ Node selesai dibuat dengan Wings aktif!" "$GREEN"
}

# ======================= FUNGSI INSTALL PANEL BARU (LENGKAP) =======================

install_new_panel_complete() {
    local domainpanel=$1
    local domainnode=$2
    local ramserver=$3
    
    log "🏗️ MEMULAI INSTALASI PTERODACTYL LENGKAP..." "$BLUE"
    
    # Update system
    apt-get update -y && apt-get upgrade -y
    
    # Install必要 dependencies
    apt-get install -y curl wget git zip unzip tar gzip \
        software-properties-common apt-transport-https \
        ca-certificates gnupg lsb-release
    
    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Install MariaDB
    apt-get install -y mariadb-server mariadb-client
    
    # Install Redis
    apt-get install -y redis-server
    
    # Install PHP 8.2
    add-apt-repository -y ppa:ondrej/php
    apt-get update -y
    apt-get install -y php8.2 php8.2-cli php8.2-common php8.2-mysql \
        php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-xml \
        php8.2-fpm php8.2-bcmath php8.2-redis
    
    # Install composer
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    
    # Install Nginx
    apt-get install -y nginx
    
    # Download Pterodactyl
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    
    # Setup .env
    cp .env.example .env
    php artisan key:generate --force
    
    # Setup database
    mysql -e "CREATE DATABASE IF NOT EXISTS panel;"
    mysql -e "CREATE USER IF NOT EXISTS '${PANEL_USER}'@'127.0.0.1' IDENTIFIED BY '${PANEL_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON panel.* TO '${PANEL_USER}'@'127.0.0.1' WITH GRANT OPTION;"
    mysql -e "FLUSH PRIVILEGES;"
    
    # Update .env
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=panel/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=${PANEL_USER}/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${PANEL_PASS}/" .env
    
    # Install panel
    composer install --no-dev --optimize-autoloader
    php artisan migrate --seed --force
    
    # Setup admin account
    php artisan p:user:make --email="${PANEL_EMAIL}" --name="${PANEL_USER}" --password="${PANEL_PASS}" --admin=true --no-interaction
    
    # Setup nginx
    cat > /etc/nginx/sites-available/pterodactyl << EOF
server {
    listen 80;
    server_name ${domainpanel};
    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOF

    ln -sf /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    systemctl restart nginx
    systemctl restart php8.2-fpm
    
    log "✅ Panel berhasil diinstall!" "$GREEN"
    
    # Install wings seperti di bot
    install_wings "$domainpanel" "$domainnode" "$ramserver"
}

# ======================= FUNGSI RESTORE =======================

restore_backup() {
    local domainpanel=$1
    
    log "📂 Merestore data dari backup..." "$YELLOW"
    
    # Restore database jika ada
    if [ -f "$BACKUP_DIR/database_${TIMESTAMP}.sql" ]; then
        log "Merestore database..." "$YELLOW"
        mysql panel < "$BACKUP_DIR/database_${TIMESTAMP}.sql"
        log "✅ Database berhasil direstore!" "$GREEN"
    elif [ -f "$BACKUP_DIR/all_databases_${TIMESTAMP}.sql" ]; then
        log "Merestore all databases..." "$YELLOW"
        mysql < "$BACKUP_DIR/all_databases_${TIMESTAMP}.sql"
        log "✅ All databases berhasil direstore!" "$GREEN"
    fi
    
    # Restore file panel
    if [ -f "$BACKUP_DIR/pterodactyl_files_${TIMESTAMP}.tar.gz" ]; then
        log "Merestore file panel..." "$YELLOW"
        cd /var/www
        tar -xzf "$BACKUP_DIR/pterodactyl_files_${TIMESTAMP}.tar.gz" --strip-components=2 2>/dev/null || tar -xzf "$BACKUP_DIR/pterodactyl_files_${TIMESTAMP}.tar.gz"
        cd /var/www/pterodactyl
        chmod -R 755 storage/* bootstrap/cache/
        php artisan migrate --force
        log "✅ File panel berhasil direstore!" "$GREEN"
    fi
    
    # Restore wings config
    if [ -f "$BACKUP_DIR/config_${TIMESTAMP}.yml" ]; then
        log "Merestore konfigurasi Wings..." "$YELLOW"
        cp "$BACKUP_DIR/config_${TIMESTAMP}.yml" /etc/pterodactyl/config.yml
        chmod 600 /etc/pterodactyl/config.yml
        systemctl restart wings
        log "✅ Konfigurasi Wings berhasil direstore!" "$GREEN"
    fi
}

# ======================= SETUP QUEUE DAN CRON =======================

setup_queue_and_cron() {
    log "⚙️ Setup queue worker dan cron job..." "$YELLOW"
    
    # Setup queue worker
    cat > /etc/systemd/system/pteroq.service << EOF
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=root
Group=root
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --sleep=3 --tries=3
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now pteroq
    
    # Setup cron
    echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1" | crontab -
    
    log "✅ Queue worker dan cron job siap!" "$GREEN"
}

# ======================= SETUP SSL =======================

setup_ssl() {
    local domain=$1
    
    log "🔒 Setup SSL untuk $domain..." "$YELLOW"
    
    apt-get install -y certbot python3-certbot-nginx
    certbot --nginx -d "$domain" --non-interactive --agree-tos --email "${PANEL_EMAIL}" 2>/dev/null || {
        log "⚠️ Gagal setup SSL otomatis, silahkan setup manual" "$YELLOW"
    }
    
    log "✅ SSL setup selesai!" "$GREEN"
}

# ======================= BUAT SUMMARY =======================

create_summary() {
    local old_ip=$1
    local new_domain=$2
    local node_domain=$3
    local ram=$4
    
    cat > "$BACKUP_DIR/migration_summary_${TIMESTAMP}.txt" << EOF
============================================
MIGRASI PTERODACTYL PANEL
Tanggal: $(date)
============================================

INFORMASI VPS LAMA:
- IP VPS Lama: $old_ip

INFORMASI PANEL BARU:
- Domain Panel: https://$new_domain
- Domain Node: $node_domain
- RAM Node: $ram MB

LOGIN CREDENTIAL:
- Username Panel: $PANEL_USER
- Password Panel: $PANEL_PASS
- Email Admin: $PANEL_EMAIL

LOKASI BACKUP:
- Directory: $BACKUP_DIR
- Database: database_${TIMESTAMP}.sql
- File Panel: pterodactyl_files_${TIMESTAMP}.tar.gz
- Config Wings: config_${TIMESTAMP}.yml

LOG FILE:
- $LOG_FILE

============================================
STATUS: ✅ MIGRASI SELESAI
============================================
EOF

    log "✅ Summary migrasi dibuat: migration_summary_${TIMESTAMP}.txt" "$GREEN"
}

# ======================= MAIN PROGRAM =======================

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     ██▓███   ▄▄▄█████▓ ██▓▓█████  ██▀███   ▄▄▄█▀▀░      ║
║    ▓██░  ██▒ ▓  ██▒ ▓▒▓██▒▓█   ▀ ▓██ ▒ ██▒░▀░██ ░        ║
║    ▓██░ ██▓▒ ▒ ▓██░ ▒░▒██▒▒███   ▓██ ░▄█ ▒░░ ██░         ║
║    ▒██▄█▓▒ ▒ ░ ▓██▓ ░ ░██░▒▓█  ▄ ▒██▀▀█▄   ██░          ║
║    ▒██▒ ░  ░   ▒██▒ ░ ░██░░▒████▒░██▓ ▒██▒ ██░           ║
║    ▒▓▒░ ░  ░   ▒ ░░   ░▓  ░░ ▒░ ░░ ▒▓ ░▒▓░ ░██░           ║
║    ░▒ ░        ░      ▒ ░ ░ ░  ░  ░▒ ░ ▒░ ░█░             ║
║    ░░        ░        ▒ ░   ░     ░░   ░  ░█░             ║
║                        ░     ░  ░   ░       ░             ║
║     MIGRATION SCRIPT v2.0                                ║
║     Backup & Migrate to New VPS                          ║
║     Dengan Sistem Installasi Sama Seperti Bot            ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Input dari user
echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║     MASUKKAN INFORMASI VPS LAMA        ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
read -p "IP VPS Lama: " OLD_VPS_IP
read -sp "Password VPS Lama: " OLD_VPS_PASS
echo ""
echo ""
echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║     MASUKKAN INFORMASI PANEL BARU      ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
read -p "Domain Panel Baru (contoh: panel.domain.com): " NEW_DOMAIN_PANEL
read -p "Domain Node Baru (contoh: node.domain.com): " NEW_DOMAIN_NODE
read -p "RAM untuk Node (dalam MB, contoh: 8192): " RAM_SERVER

NEW_VPS_IP=$(curl -s ifconfig.me)

# Buat directory backup
mkdir -p "$BACKUP_DIR"
log "=========================================" "$BLUE"
log "Memulai proses migrasi Pterodactyl" "$GREEN"
log "Backup akan disimpan di: $BACKUP_DIR" "$CYAN"
log "=========================================" "$BLUE"

# ======================= STEP 1: CEK KONEKSI =======================
echo ""
if ! check_ssh_connection "$OLD_VPS_IP" "$OLD_VPS_PASS"; then
    log "❌ Tidak dapat terhubung ke VPS lama! Proses dihentikan." "$RED"
    exit 1
fi

# ======================= STEP 2: BACKUP DATA =======================
echo ""
log "========== 📦 MEMULAI PROSES BACKUP ==========" "$BLUE"
backup_database "$OLD_VPS_IP" "$OLD_VPS_PASS"
backup_panel_files "$OLD_VPS_IP" "$OLD_VPS_PASS"
backup_wings_config "$OLD_VPS_IP" "$OLD_VPS_PASS"
log "========== ✅ BACKUP SELESAI ==========" "$GREEN"

# ======================= STEP 3: INSTALL PANEL BARU =======================
echo ""
log "========== 🚀 INSTALASI PANEL BARU ==========" "$BLUE"
install_new_panel_complete "$NEW_DOMAIN_PANEL" "$NEW_DOMAIN_NODE" "$RAM_SERVER"

# ======================= STEP 4: RESTORE DATA =======================
echo ""
log "========== 📂 RESTORE DATA ==========" "$BLUE"
restore_backup "$NEW_DOMAIN_PANEL"

# ======================= STEP 5: SETUP QUEUE & CRON =======================
echo ""
setup_queue_and_cron

# ======================= STEP 6: SETUP SSL =======================
echo ""
log "========== 🔒 SETUP SSL ==========" "$BLUE"
setup_ssl "$NEW_DOMAIN_PANEL"

# ======================= STEP 7: CREATE SUMMARY =======================
create_summary "$OLD_VPS_IP" "$NEW_DOMAIN_PANEL" "$NEW_DOMAIN_NODE" "$RAM_SERVER"

# ======================= FINAL OUTPUT =======================
echo ""
log "=========================================" "$GREEN"
log "✅ MIGRASI SELESAI DENGAN SUKSES!" "$GREEN"
log "=========================================" "$GREEN"
echo ""
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                    MIGRATION COMPLETED                    ║
║                                                           ║
║  📍 PANEL INFORMATION:                                    ║
║     URL Panel: https://$NEW_DOMAIN_PANEL                  ║
║     Username: admin                                       ║
║     Password: admin001                                    ║
║                                                           ║
║  🖥️ NODE INFORMATION:                                     ║
║     Domain Node: $NEW_DOMAIN_NODE                         ║
║     RAM: $RAM_SERVER MB                                   ║
║                                                           ║
║  💾 BACKUP LOCATION:                                      ║
║     $BACKUP_DIR                                           ║
║                                                           ║
║  📝 LOG FILE:                                             ║
║     $LOG_FILE                                             ║
║                                                           ║
║  ⚠️  JANGAN LUPA:                                         ║
║     - Ganti password default                              ║
║     - Setup SSL jika belum                                ║
║     - Test node connection                                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Menampilkan informasi login
echo -e "\n${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}       INFORMASI LOGIN PANEL BARU        ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${CYAN}URL Panel   :${NC} https://$NEW_DOMAIN_PANEL"
echo -e "${CYAN}Username    :${NC} $PANEL_USER"
echo -e "${CYAN}Password    :${NC} $PANEL_PASS"
echo -e "${CYAN}Email       :${NC} $PANEL_EMAIL"
echo -e "\n${CYAN}Domain Node :${NC} $NEW_DOMAIN_NODE"
echo -e "${CYAN}RAM Node     :${NC} $RAM_SERVER MB"
echo -e "${GREEN}════════════════════════════════════════${NC}"

# Optional: cek status wings
echo -e "\n${YELLOW}Apakah ingin mengecek status Wings? (y/n)${NC}"
read -r check_wings
if [[ "$check_wings" == "y" ]]; then
    systemctl status wings --no-pager
fi

# Optional: test panel
echo -e "\n${YELLOW}Apakah ingin melakukan test akses ke panel? (y/n)${NC}"
read -r test_choice
if [[ "$test_choice" == "y" ]]; then
    curl -k -s "https://$NEW_DOMAIN_PANEL/api" > /dev/null && \
        echo -e "${GREEN}✅ Panel berhasil diakses!${NC}" || \
        echo -e "${RED}❌ Gagal mengakses panel! Cek konfigurasi nginx dan SSL${NC}"
fi

log "Script migrasi selesai dijalankan pada $(date)" "$GREEN"
