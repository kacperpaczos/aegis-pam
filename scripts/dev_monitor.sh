#!/bin/bash

# Sprawdź czy tmux jest zainstalowany
if ! command -v tmux &> /dev/null; then
    echo "tmux nie jest zainstalowany. Instalowanie..."
    if [ "$EUID" -ne 0 ]; then
        sudo apt-get update && sudo apt-get install -y tmux || \
        sudo dnf install -y tmux || \
        sudo yum install -y tmux || \
        sudo pacman -Sy tmux --noconfirm
    else
        apt-get update && apt-get install -y tmux || \
        dnf install -y tmux || \
        yum install -y tmux || \
        pacman -Sy tmux --noconfirm
    fi
fi

# Przygotuj plik logów
touch /tmp/aegis_pam_dev.log
chmod 666 /tmp/aegis_pam_dev.log

# Zabij istniejącą sesję jeśli istnieje
tmux kill-session -t aegis_monitor 2>/dev/null || true

# Utwórz nową sesję tmux
tmux new-session -d -s aegis_monitor

# Podziel okno na panele
tmux split-window -v
tmux split-window -h

# Panel 1: Logi PAM
tmux select-pane -t 0
tmux send-keys "echo 'PAM Module logs:' && tail -f /tmp/aegis_pam_dev.log | grep --color=always --line-buffered 'PAM:.*'" C-m

# Panel 2: Logi agenta
tmux select-pane -t 1
tmux send-keys "echo 'Agent logs:' && tail -f /tmp/aegis_pam_dev.log | grep --color=always --line-buffered 'Agent:.*'" C-m

# Panel 3: Status usługi
tmux select-pane -t 2
tmux send-keys "watch -n 1 'systemctl status aegis_pam_agent'" C-m

# Ustaw tytuł okna
tmux set -g set-titles on
tmux set -g set-titles-string "AEGIS PAM MONITOR"

# Sprawdź komponenty
echo "Sprawdzanie komponentów..."
if [ -f "/lib/security/pam_aegis.so" ]; then
    echo "✓ Moduł PAM zainstalowany"
else
    echo "✗ Moduł PAM nie znaleziony"
fi

if [ -f "/usr/local/bin/aegis_pam_agent" ]; then
    echo "✓ Agent zainstalowany"
else
    echo "✗ Agent nie znaleziony"
fi

if systemctl is-active --quiet aegis_pam_agent; then
    echo "✓ Usługa agenta uruchomiona"
else
    echo "✗ Usługa agenta nie działa"
fi

# Dołącz do sesji
if [ -n "$DISPLAY" ]; then
    # Jeśli mamy środowisko graficzne, użyj gnome-terminal
    gnome-terminal -- tmux attach-session -t aegis_monitor
else
    # W przeciwnym razie dołącz bezpośrednio
    tmux attach-session -t aegis_monitor
fi 