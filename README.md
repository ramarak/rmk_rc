# Secure-RM (rmk & srmk)

A pair of custom shell functions designed for secure, irreversible file deletion tailored to your specific storage hardware type (HDD vs. SSD). 

Standard `rm` operations only delete pointers to files, leaving the actual data salvageable. These utilities ensure data destruction while matching your drive's physical architecture.

## Why two different scripts?

Traditional multi-pass shredding tools are vital for HDDs but detrimental to SSDs. This repository solves that conflict:
* **Magnetic Hard Drives (HDDs)** store data magnetically; defeating forensic recovery requires writing multiple patterns over the same physical sector.
* **Solid-State Drives (SSDs)** use flash memory and *Wear Leveling* algorithms. Heavy multi-pass overwriting doesn't guarantee the data is hit, and it severely degrades the drive's lifespan. SSDs require a clean logical pass followed by a hardware-level **TRIM** instruction.

---

## Features & Internal Logic

### 1. `rmk` (For Mechanical Hard Drives / HDDs)
Combines two robust utilities to perform a paranoid **14-pass shredding sequence**:
* **`scrub -p dod`**: Overwrites the target following the U.S. DoD 5220.22-M standard (Random, `0x00`, `0xff` patterns + verification pass). It automatically pads small files to scrub the entire filesystem block.
* **`shred -zun 10 -v`**: Executes 10 additional passes with varying binary patterns, truncates/renames the filename progressively to scramble metadata, and applies a final zeroing pass.

### 2. `srmk` (For Solid-State Drives / SSDs & NVMEs)
Designed to securely pulverize files while **preserving SSD health**:
* **`shred -zu -n 1 -v`**: Performs exactly **one** fast destructive pass to wipe logical access, masks the metadata by wiping the filename, and zeros the block.
* **`fstrim -v /`**: Triggers a hardware-level **TRIM** command. This forces the SSD controller to physically wipe the underlying flash blocks immediately, preventing any hardware-level data carving.

---

## Installation

1. Clone this repository or copy the desired function code.
2. Paste the function into your shell configuration file (e.g., `~/.bashrc` or `~/.zshrc`).
3. Reload your terminal or run:
   ```bash
   source ~/.bashrc  # Or source ~/.zshrc

## Usage
```Bash
# For mechanical drives
rmk sensitive_data.txt

# For solid-state drives
srmk sensitive_data.txt

