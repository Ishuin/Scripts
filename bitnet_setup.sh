#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "[*] Updating Termux..."
pkg update -y && pkg upgrade -y
pkg install -y git curl wget proot-distro build-essential cmake

echo "[*] Installing Ubuntu via proot-distro..."
proot-distro install ubuntu

echo "[*] Setting up post-install script for BitNet inside Ubuntu..."

cat > ~/.bitnet-ubuntu-setup.sh << 'EOF'
#!/bin/bash
set -e

apt update && apt install -y unzip build-essential cmake wget curl

cd /root || cd ~

echo "[*] Downloading BitNet.cpp using curl..."
curl -L -o bitnet.zip https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/main.zip
unzip bitnet.zip
mv BitNet.cpp-main BitNet.cpp
cd BitNet.cpp
mkdir -p build && cd build
cmake ..
make -j$(nproc)

echo
echo "[*] DONE! To run BitNet, use:"
echo "proot-distro login ubuntu"
echo "cd BitNet.cpp/build && ./bitnet -p \"Hello world\""
EOF

chmod +x ~/.bitnet-ubuntu-setup.sh

echo "[*] Logging into Ubuntu to execute BitNet install..."
proot-distro login ubuntu --shared-tmp -- bash /root/.bitnet-ubuntu-setup.sh

echo "[*] Script complete!"
