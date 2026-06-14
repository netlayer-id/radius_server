#!/bin/bash

RADIUS_SERVICE_NAME="netlayer-radius.service"
RADIUS_SERVICE_FILE="/etc/systemd/system/$RADIUS_SERVICE_NAME"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
NETLAYER_EXEC="$SCRIPT_DIR/netlayer"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Skrip ini harus dijalankan sebagai root atau dengan sudo.${NC}"
        echo "Coba jalankan dengan: sudo $0"
        exit 1
    fi
}

check_netlayer() {
    if [ ! -f "$NETLAYER_EXEC" ]; then
        echo -e "${RED}Error: File netlayer tidak ditemukan di $NETLAYER_EXEC${NC}"
        echo -e "${YELLOW}Pastikan file netlayer berada di direktori yang sama dengan script ini.${NC}"
        exit 1
    fi
    
    if [ ! -x "$NETLAYER_EXEC" ]; then
        echo -e "${YELLOW}Memberikan permission execute pada netlayer...${NC}"
        chmod +x "$NETLAYER_EXEC"
    fi
}

create_radius_service() {
    cat <<EOF > "$RADIUS_SERVICE_FILE"
[Unit]
Description=NETLAYER RADIUS SERVER
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR
ExecStart=$NETLAYER_EXEC
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
}

start_radius() {
    chmod +x "$SCRIPT_DIR/netlayer"
    chmod -R 777 "$SCRIPT_DIR/data/"
    chmod -R 777 "$SCRIPT_DIR/voucher/"
    chmod -R 777 "$SCRIPT_DIR/backup/"
    
    echo -e "\n${YELLOW}Memulai RADIUS service...${NC}"
    
    if [ ! -f "$RADIUS_SERVICE_FILE" ]; then
        echo -e "${YELLOW}Service belum terinstall, melakukan instalasi...${NC}"
        check_netlayer
        create_radius_service
        systemctl daemon-reload
    fi
    
    # Start service
    systemctl enable "$RADIUS_SERVICE_NAME" 2>/dev/null
    if systemctl start "$RADIUS_SERVICE_NAME" 2>/dev/null; then
        echo -e "${GREEN}RADIUS service started.${NC}"
    else
        echo -e "${RED}Gagal memulai RADIUS service.${NC}"
        systemctl status "$RADIUS_SERVICE_NAME" --no-pager -l
    fi
}

stop_radius() {
    echo -e "\n${YELLOW}Menghentikan RADIUS service...${NC}"
    
    if systemctl stop "$RADIUS_SERVICE_NAME" 2>/dev/null; then
        systemctl disable "$RADIUS_SERVICE_NAME" 2>/dev/null
        echo -e "${GREEN}RADIUS service stopped.${NC}"
    else
        echo -e "${YELLOW}Service tidak sedang berjalan atau belum terinstall.${NC}"
    fi
    
    # Remove service file
    if [ -f "$RADIUS_SERVICE_FILE" ]; then
        rm -f "$RADIUS_SERVICE_FILE"
        systemctl daemon-reload
        echo -e "${GREEN}File service dihapus.${NC}"
    fi
}

restart_radius() {
    echo -e "\n${YELLOW}Me-restart RADIUS service...${NC}"
    
    if systemctl restart "$RADIUS_SERVICE_NAME" 2>/dev/null; then
        echo -e "${GREEN}RADIUS service restarted.${NC}"
    else
        echo -e "${RED}Gagal me-restart RADIUS service.${NC}"
        echo -e "${YELLOW}Pastikan service sudah di-start terlebih dahulu.${NC}"
    fi
}

status_radius() {
    echo -e "\n${YELLOW}Status RADIUS service:${NC}"
    
    if [ -f "$RADIUS_SERVICE_FILE" ]; then
        systemctl status "$RADIUS_SERVICE_NAME" --no-pager -l
    else
        echo -e "${RED}Service belum terinstall.${NC}"
        echo -e "${YELLOW}Gunakan opsi 1 (Start) untuk menginstall dan memulai service.${NC}"
    fi
}

show_menu() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "    ${YELLOW}Netlayer Radius Service${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN} AUTH PORT : 1812${NC}"
    echo -e "${GREEN} ACCT PORT : 1813${NC}"
    echo -e "${GREEN} HTTP PORT : 8080${NC}"
    echo ""
    echo " 1. Start Service"
    echo " 2. Stop Service"
    echo " 3. Restart"
    echo " 4. Status"
    echo ""
    echo " 0. Exit"
    echo -e "${BLUE}=========================================${NC}"
}

press_enter() {
    echo ""
    read -p "Tekan [Enter] untuk kembali ke menu..."
}

check_root

while true; do
    show_menu
    read -p "Pilih opsi [0-4]: " choice

    case $choice in
        1)
            start_radius
            press_enter
            ;;
        2)
            stop_radius
            press_enter
            ;;
        3)
            restart_radius
            press_enter
            ;;
        4)
            status_radius
            press_enter
            ;;
        0)
            echo -e "\n${BLUE}Terima kasih! Keluar dari program.${NC}\n"
            break
            ;;
        *)
            echo -e "\n${RED}Pilihan tidak valid. Harap coba lagi.${NC}"
            sleep 2
            ;;
    esac
done
