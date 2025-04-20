#!/data/data/com.termux/files/usr/bin/bash

set -e

log() {
    echo -e "\033[1;36m[*] $1\033[0m"
}

fail() {
    echo -e "\033[1;31m[!] $1\033[0m"
    exit 1
}

log "Updating Termux & installing packages..."
pkg update -y && pkg upgrade -y
pkg install -y git curl wget unzip proot-distro build-essential cmake || fail "Package install failed."

log "Installing Ubuntu via proot-distro (if not already installed)..."
proot-distro install ubuntu || log "Ubuntu already installed."

log "Creating BitNet install script..."
cat > ~/bitnet-ubuntu-setup.sh << 'EOF'
#!/bin/bash
set -e

echo "[*] Updating Ubuntu packages..."
apt update && apt install -y unzip build-essential cmake wget curl

cd /root || cd ~

echo "[*] Downloading BitNet.cpp..."
curl -L -o bitnet.zip https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/main.zip || { echo '[!] Failed to download BitNet.cpp'; exit 1; }
unzip -o bitnet.zip || { echo '[!] Failed to unzip BitNet.cpp'; exit 1; }
mv -f BitNet.cpp-main BitNet.cpp
cd BitNet.cpp
mkdir -p build && cd build
cmake .. || { echo '[!] cmake failed'; exit 1; }
make -j$(nproc) || { echo '[!] make failed'; exit 1; }

echo
echo "[*] DONE! To run BitNet later, type:"
echo "proot-distro login ubuntu"
echo "cd BitNet.cpp/build"
echo "./bitnet -p \"Hello world\""
EOF

chmod +x ~/bitnet-ubuntu-setup.sh

UBUNTU_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
DEST_SCRIPT="$UBUNTU_ROOTFS/root/bitnet-ubuntu-setup.sh"

log "Copying script into Ubuntu rootfs..."
cp -f ~/bitnet-ubuntu-setup.sh "$DEST_SCRIPT" || fail "Failed to copy script into Ubuntu."

log "Logging into Ubuntu to execute the setup script..."
proot-distro login ubuntu --shared-tmp -- bash /root/bitnet-ubuntu-setup.sh || fail "Failed to run BitNet setup inside Ubuntu."

log "Setup complete! You can now use BitNet."
