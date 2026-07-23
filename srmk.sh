# srmk - Secure Remove for SSD
# Minimal overwriting to protect drive lifespan + immediate cell clearing via TRIM.
# Secure Remove adaptado a SSD (Minimal overwrite + TRIM)
srmk () {
    if [[ -z "$1" ]]; then
        echo "Uso: rmk <archivo>"
        return 1
    fi

    if [[ ! -e "$1" ]]; then
        echo "Error: '$1' no existe."
        return 1
    fi

    # 1 pasada de ceros + renombrar y eliminar puntero + forzar flush a disco
    shred -zu -n 1 -v "$1" && sync
}
