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
pkg install -y proot-distro curl unzip cmake build-essential || fail "Package install failed."

log "Installing Ubuntu (if not already)..."
proot-distro install ubuntu || log "Ubuntu already installed."

log "Creating BitNet setup script inside Ubuntu..."
cat > ~/bitnet-ubuntu-setup.sh << 'EOF'
#!/bin/bash
set -e

echo "[*] Updating Ubuntu packages..."
apt update && apt install -y unzip build-essential cmake wget curl

cd /root || cd ~

echo "[*] Downloading BitNet.cpp ZIP file..."

curl -L --retry 3 -o bitnet.zip https://codeload.github.com/kldurga999/BitNet.cpp/zip/refs/heads/main
FILE_TYPE=$(file --mime-type -b bitnet.zip)

if [ "$FILE_TYPE" != "application/zip" ]; then
    echo "[!] Downloaded file is not a valid ZIP. Detected type: $FILE_TYPE"
    cat bitnet.zip | head -n 10
    exit 1
fi

unzip -o bitnet.zip || { echo '[!] Failed to unzip BitNet.cpp'; exit 1; }
mv -f BitNet.cpp-main BitNet.cpp
cd BitNet.cpp
mkdir -p build && cd build
cmake .. || { echo '[!] cmake failed'; exit 1; }
make -j$(nproc) || { echo '[!] make failed'; exit 1; }

echo
echo "[*] DONE! To run BitNet later:"
echo "proot-distro login ubuntu"
echo "cd BitNet.cpp/build"
echo "./bitnet -p \"Hello world\""
EOF

chmod +x ~/bitnet-ubuntu-setup.sh

UBUNTU_ROOTFS="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
DEST_SCRIPT="$UBUNTU_ROOTFS/root/bitnet-ubuntu-setup.sh"

log "Copying install script into Ubuntu root..."
cp -f ~/bitnet-ubuntu-setup.sh "$DEST_SCRIPT" || fail "Failed to copy script."

log "Logging into Ubuntu to execute setup..."
proot-distro login ubuntu --shared-tmp -- bash /root/bitnet-ubuntu-setup.sh || fail "Failed to run setup in Ubuntu."

log "BitNet install complete. Launch with:"
echo "proot-distro login ubuntu"
echo "cd BitNet.cpp/build && ./bitnet -p \"Hello world\""
