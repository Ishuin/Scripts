# Scripts

A small collection of utility scripts.

## Scripts Index

### Environment Setup

- **`bitnet_setup.sh`** — Provisions a BitNet development environment inside a Termux proot Ubuntu distro. Installs `proot-distro`, Ubuntu, essential build tools, clones the BitNet repository to `/opt/bitnet`, and runs the inner setup automatically.

### Usage

```bash
# From Termux
chmod +x bitnet_setup.sh
./bitnet_setup.sh
```

The script runs unattended. On completion the BitNet repository is available inside the Ubuntu proot environment at `/opt/bitnet`.

## Notes

- Run these scripts at your own risk. Review each script before executing.
- `bitnet_setup.sh` requires an Android device with Termux installed.
