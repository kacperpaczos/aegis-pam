#!/bin/bash

# Sprawdzenie uprawnień roota
if [ "$EUID" -ne 0 ]; then
    echo "Ten skrypt musi być uruchomiony jako root"
    exit 1
fi

# Instalacja pamtester
echo "Instalacja pamtester..."
if ! command -v pamtester &> /dev/null; then
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y pamtester
    elif command -v dnf &> /dev/null; then
        dnf install -y pamtester
    elif command -v yum &> /dev/null; then
        yum install -y pamtester
    elif command -v pacman &> /dev/null; then
        pacman -Sy pamtester --noconfirm
    else
        echo "Nie można zainstalować pamtester. Nieobsługiwany menedżer pakietów."
        exit 1
    fi
fi

if ! command -v pamtester &> /dev/null; then
    echo "Nie udało się zainstalować pamtester!"
    exit 1
fi

echo "pamtester zainstalowany pomyślnie"

# Tryb instalacji
INSTALL_MODE=${1:-dev}  # dev, sudo, global

# Funkcja tworzenia kopii zapasowych
backup_pam_config() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="/etc/aegis/backup_${timestamp}"
    
    mkdir -p "$backup_dir"
    
    # Kopia konfiguracji PAM
    if [ -f /etc/pam.d/common-auth ]; then
        cp /etc/pam.d/common-auth "$backup_dir/"
    fi
    if [ -f /etc/pam.d/sudo ]; then
        cp /etc/pam.d/sudo "$backup_dir/"
    fi
    
    echo "$backup_dir" > /etc/aegis/last_backup
    echo "Utworzono kopię zapasową w: $backup_dir"
}

case $INSTALL_MODE in
    "dev")
        echo "Instalacja w trybie deweloperskim..."
        
        # Terminal awaryjny
        gnome-terminal --window --title="EMERGENCY ROOT TERMINAL - DO NOT CLOSE" -- bash -c '
            echo -e "\e[41m\e[97m"
            echo "╔════════════════════════════════════════════════════════════════╗"
            echo "║                  EMERGENCY ROOT TERMINAL                       ║"
            echo "║           DO NOT CLOSE THIS TERMINAL during testing!           ║"
            echo "╚════════════════════════════════════════════════════════════════╝"
            echo -e "\e[0m"
            sudo -i
        ' &
        
        # Budowanie i instalacja lokalna
        meson setup builddir --buildtype=debug
        cd builddir
        meson compile
        ninja install
        cd ..
        
        # Konfiguracja dla trybu dev
        mkdir -p /etc/pam.d
        cp config/aegis-auth /etc/pam.d/aegis
        
        # Przygotuj plik logów z odpowiednimi uprawnieniami
        touch /tmp/aegis_pam_dev.log
        chmod 666 /tmp/aegis_pam_dev.log
        chown root:root /tmp/aegis_pam_dev.log
        
        # Uruchomienie agenta w trybie dev
        systemctl stop aegis_pam_agent 2>/dev/null || true
        cp config/aegis_pam_agent.service /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable aegis_pam_agent
        systemctl start aegis_pam_agent
        
        echo "Moduł PAM zbudowany w trybie dev. Użyj pamtester do testów:"
        echo "pamtester aegis \$USER authenticate"
        ;;
        
    "sudo")
        echo "Instalacja w trybie sudo..."
        backup_pam_config
        
        # Standardowa instalacja
        meson setup builddir --buildtype=release
        cd builddir
        meson compile
        meson install
        cd ..
        
        # Konfiguracja tylko dla sudo
        cp config/aegis-auth /etc/pam.d/aegis
        echo "@include aegis" >> /etc/pam.d/sudo
        ;;
        
    "global")
        echo "Instalacja globalna..."
        backup_pam_config
        
        # Standardowa instalacja
        meson setup builddir --buildtype=release
        cd builddir
        meson compile
        meson install
        cd ..
        
        # Konfiguracja globalna
        cp config/aegis-auth /etc/pam.d/aegis
        echo "@include aegis" >> /etc/pam.d/common-auth
        ;;
        
    *)
        echo "Nieznany tryb instalacji: $INSTALL_MODE"
        echo "Dostępne tryby: dev, sudo, global"
        exit 1
        ;;
esac

# Wspólne kroki dla wszystkich trybów
mkdir -p /etc/aegis
mkdir -p /var/run/aegis

# Konfiguracja i uruchomienie agenta (poza trybem dev)
if [ "$INSTALL_MODE" != "dev" ]; then
    cp config/aegis_pam_agent.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable aegis_pam_agent
    systemctl start aegis_pam_agent
fi

echo "Instalacja zakończona w trybie: $INSTALL_MODE" 