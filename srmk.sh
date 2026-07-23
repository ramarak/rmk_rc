# srmk - Secure Remove for SSD
# Minimal overwriting to protect drive lifespan + immediate cell clearing via TRIM.
# Secure Remove adaptado a SSD (Minimal overwrite + TRIM)
srmk () {
    # 1. Validar que se haya proporcionado un argumento
    if [[ -z "$1" ]]; then
        echo "Uso: rmk <archivo_o_directorio>"
        return 1
    fi

    # 2. Validar que el archivo o directorio exista
    if [[ ! -e "$1" ]]; then
        echo "Error: '$1' no existe."
        return 1
    fi

    # 3. Borrar de forma segura (1 pasada de ceros + renombrar/eliminar)
    shred -zu -n 1 -v "$1"

    # 4. Ejecutar TRIM o sync
    if command -v fstrim > /dev/null 2>&1; then
        echo "Ejecutando fstrim para liberar celdas SSD..."
        sudo fstrim -v /
    elif command -v sync > /dev/null 2>&1; then
        sync
    fi
}
