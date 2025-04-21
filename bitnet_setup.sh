#!/data/data/com.termux/files/usr/bin/bash

set -e

# Define variables
DISTRO_NAME="ubuntu"
SETUP_SCRIPT_NAME=".bitnet-ubuntu-setup.sh"
SETUP_SCRIPT_PATH="$HOME/$SETUP_SCRIPT_NAME"
PRIMARY_URL="https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/main.zip"
FALLBACK_URL="https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/master.zip"
OUT_ZIP="bitnet.zip"

# Function to download and verify ZIP file
download_and_check() {
    local url="$1"
    local label="$2"

    echo "[*] Trying $label..."

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$HTTP_STATUS" != "200" ]; then
        echo "[!] $label failed with HTTP status $HTTP_STATUS."
        return 1
    fi

    curl -L -o "$OUT_ZIP" "$url"
    FILE_TYPE=$(file --mime-type -b "$OUT_ZIP")
    if [ "$FILE_TYPE" != "application/zip" ]; then
        echo "[!] $label downloaded file is not a valid ZIP. Type: $FILE_TYPE"
        head "$OUT_ZIP"
        return 1
    fi

    return 0
}

# Create the setup script to run inside Ubuntu
cat > "$SETUP_SCRIPT_PATH" << 'EOF'
#!/bin/bash

set -e

echo "[*] Updating package lists..."
apt update

echo "[*] Installing required packages..."
apt install -y unzip build-essential cmake wget curl

echo "[*] Creating workspace..."
mkdir -p ~/BitNet.cpp && cd ~/BitNet.cpp

echo "[*] Downloading BitNet.cpp zip file from GitHub..."

PRIMARY_URL="https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/main.zip"
FALLBACK_URL="https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/master.zip"
OUT_ZIP="bitnet.zip"

download_and_check() {
    local url="$1"
    local label="$2"

    echo "[*] Trying $label..."

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$HTTP_STATUS" != "200" ]; then
        echo "[!] $label failed with HTTP status $HTTP_STATUS."
        return 1
    fi

    curl -L -o "$OUT_ZIP" "$url"
    FILE_TYPE=$(file --mime-type -b "$OUT_ZIP")
    if [ "$FILE_TYPE" != "application/zip" ]; then
        echo "[!] $label downloaded file is not a valid ZIP. Type: $FILE_TYPE"
        head "$OUT_ZIP"
        return 1
    fi

    return 0
}

# Try primary, then fallback
if ! download_and_check "$PRIMARY_URL" "Primary (main branch)"; then
    if ! download_and_check "$FALLBACK_URL" "Fallback (master branch)"; then
        echo "[!] All download attempts failed. Please check the repository or branch."
        exit 1
    fi
fi

echo "[*] Unzipping BitNet.cpp..."
unzip -o "$OUT_ZIP"
cd BitNet.cpp-*

echo "[*] Building BitNet.cpp..."
mkdir -p build && cd build
cmake ..
make -j$(nproc)

echo "[+] Build completed successfully."
EOF

# Make the setup script executable
chmod +x "$SETUP_SCRIPT_PATH"

# Install Ubuntu via proot-distro if not already installed
if ! proot-distro list | grep -q "$DISTRO_NAME"; then
    echo "[*] Installing Ubuntu via proot-distro..."
    proot-distro install "$DISTRO_NAME"
fi

# Run the setup script inside Ubuntu
echo "[*] Running setup script inside Ubuntu..."
proot-distro login "$DISTRO_NAME" -- bash -c "cp /host-rootfs/data/data/com.termux/files/home/$SETUP_SCRIPT_NAME /root/ && bash /root/$SETUP_SCRIPT_NAME"

echo "[+] BitNet setup completed successfully inside Ubuntu."
