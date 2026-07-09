# rmk - Secure Remove for HDD
# Overwrites files multiple times using scrub and shred to defeat magnetic remanence.
rmk () {
    scrub -p dod "$1"
    shred -zun 10 -v "$1"
}
