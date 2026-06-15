#!/bin/bash

# ==============================================================================
# Netlayer RADIUS Management Utility
# ==============================================================================

RADIUS_SERVICE_NAME="netlayer-radius.service"
RADIUS_SERVICE_FILE="/etc/systemd/system/$RADIUS_SERVICE_NAME"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
NETLAYER_EXEC="$SCRIPT_DIR/netlayer"

# Colors & Icons
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Helper Functions ---

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✔]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✘]${NC} $1"; }

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root or with sudo."
        echo "   Try: sudo $0"
        exit 1
    fi
}

check_netlayer() {
    if [ ! -f "$NETLAYER_EXEC" ]; then
        log_error "Executable 'netlayer' not found at $NETLAYER_EXEC"
        log_warn "Please ensure the file is in the same directory as this script."
        exit 1
    fi
    [ ! -x "$NETLAYER_EXEC" ] && chmod +x "$NETLAYER_EXEC"
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

# --- Action Functions ---

start_radius() {
    log_info "Initializing RADIUS service..."
    check_netlayer
    
    # Ensure permissions
    for dir in data voucher backup; do
        [ -d "$SCRIPT_DIR/$dir" ] && chmod -R 777 "$SCRIPT_DIR/$dir"
    done
    
    if [ ! -f "$RADIUS_SERVICE_FILE" ]; then
        log_info "Installing service configuration..."
        create_radius_service
        systemctl daemon-reload
    fi
    
    systemctl enable "$RADIUS_SERVICE_NAME" >/dev/null 2>&1
    if systemctl start "$RADIUS_SERVICE_NAME" 2>/dev/null; then
        log_success "RADIUS service started successfully."
    else
        log_error "Failed to start RADIUS service."
        systemctl status "$RADIUS_SERVICE_NAME" --no-pager -l | head -n 5
    fi
}

stop_radius() {
    log_info "Stopping RADIUS service..."
    if systemctl stop "$RADIUS_SERVICE_NAME" 2>/dev/null; then
        systemctl disable "$RADIUS_SERVICE_NAME" >/dev/null 2>&1
        rm -f "$RADIUS_SERVICE_FILE"
        systemctl daemon-reload
        log_success "Service stopped and configuration removed."
    else
        log_warn "Service is not running or not installed."
    fi
}

restart_radius() {
    log_info "Restarting RADIUS service..."
    if systemctl restart "$RADIUS_SERVICE_NAME" 2>/dev/null; then
        log_success "RADIUS service restarted."
    else
        log_error "Failed to restart. Ensure the service is active first."
    fi
}

status_radius() {
    echo -e "\n${BOLD}>>> Current Status:${NC}"
    if systemctl is-active --quiet "$RADIUS_SERVICE_NAME"; then
        echo -e "${GREEN}● ACTIVE${NC}"
    else
        echo -e "${RED}○ INACTIVE${NC}"
    fi
    systemctl status "$RADIUS_SERVICE_NAME" --no-pager -l | grep -v "Active:"
}

show_menu() {
    clear
    echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}         ${BOLD}NETLAYER RADIUS MANAGEMENT${NC}            ${BLUE}║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}Auth Port:${NC} 1812  ${GREEN}Acct Port:${NC} 1813     ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   ${GREEN}HTTP Port:${NC} 8080                        ${BLUE}║${NC}"
    echo -e "${BLUE}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}   1) Start Service      2) Stop Service        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   3) Restart Service    4) Check Status        ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}                                               ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}   0) Exit                                     ${BLUE}║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
}

# --- Main Loop ---

check_root

while true; do
    show_menu
    read -p "Select an option [0-4]: " choice
    case $choice in
        1) start_radius; read -p "Press Enter to continue...";;
        2) stop_radius; read -p "Press Enter to continue...";;
        3) restart_radius; read -p "Press Enter to continue...";;
        4) status_radius; read -p "Press Enter to continue...";;
        0) echo -e "\nExiting... Goodbye!\n"; exit 0;;
        *) echo -e "${RED}Invalid selection. Try again.${NC}"; sleep 1;;
    esac
done