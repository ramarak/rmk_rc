# srmk - Secure Remove for SSD
# Minimal overwriting to protect drive lifespan + immediate cell clearing via TRIM.
# Secure Remove adaptado a SSD (Minimal overwrite + TRIM)
# This function is fot super user.
rmk () {
        if [[ -z "$1" ]]
        then
                echo "Usage: rmk <file|folder>"
                return 1
        fi
        if [[ ! -e "$1" && ! -L "$1" ]]
        then
                echo "Error: '$1' does not exist."
                return 1
        fi

        if [[ -d "$1" && ! -L "$1" ]]
        then
                read -q "REPLY?¿Delete folder '$1' and ALL its contents? [y/N] " || { echo; return 1; }
                echo
                find "$1" -type f -exec shred -zu -n 1 -v {} + \
                        && find "$1" -type l -delete \
                        && find "$1" -depth -type d -empty -delete \
                        && sync
        else
                shred -zu -n 1 -v "$1" && sync
        fi
}
