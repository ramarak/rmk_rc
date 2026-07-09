# srmk - Secure Remove for SSD
# Minimal overwriting to protect drive lifespan + immediate cell clearing via TRIM.
srmk () {
    shred -zu -n 1 -v "$1"
    
    if command -v fstrim > /dev/null; then
        echo "Executing fstrim to clear SSD cells..."
        sudo fstrim -v /
    elif command -v sync > /dev/null; then
        sync
    fi
}
