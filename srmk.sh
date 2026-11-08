#!/bin/sh
# rmk - Secure Remove for SSD (POSIX sh / Linux / Git Bash)
#
# Important warning:
# 'shred' is designed for magnetic disks. On an SSD, it does not guarantee the
# physical erasure of the original cells (due to wear leveling, over-provisioning,
# and the FTL). For a truly secure erasure on an SSD, use full-disk encryption
# (BitLocker/LUKS) or the manufacturer's ATA/NVMe Secure Erase feature.
#
# Usage:
# source rmk.sh # loads the function into your current shell
# ./rmk.sh <file> # executes directly (if it has execution permissions)
#
# Dependencies: shred (GNU coreutils), find, sync
rmk() {
    _rmk_target="$1"
    if [ -z "$_rmk_target" ]; then
        echo "Uso: rmk <archivo|carpeta>"
        return 1 2>/dev/null || exit 1
    fi
    if [ ! -e "$_rmk_target" ] && [ ! -L "$_rmk_target" ]; then
        echo "Error: '$_rmk_target' no existe."
        return 1 2>/dev/null || exit 1
    fi
    if [ -d "$_rmk_target" ] && [ ! -L "$_rmk_target" ]; then
        printf "¿Eliminar carpeta '%s' y TODO su contenido? [s/N] " "$_rmk_target"
        read -r _rmk_reply
        case "$_rmk_reply" in
            s|S|y|Y) ;;
            *) echo "Cancelado."; return 1 2>/dev/null || exit 1 ;;
        esac
        find "$_rmk_target" -type f -exec shred -zu -n 1 -v {} +
        find "$_rmk_target" -type l -delete
        find "$_rmk_target" -depth -type d -empty -delete
        sync
    else
        shred -zu -n 1 -v "$_rmk_target" && sync
    fi
    unset _rmk_target _rmk_reply
}
# If executed as a direct script (not sourced), call the function
case "$0" in
    */rmk.sh|rmk.sh) rmk "$@" ;;
esac
