#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Starting BitNet setup in Termux..."

# Step 1: Ensure Termux has storage permissions
termux-setup-storage

# Step 2: Update and install necessary packages
pkg update -y
pkg install -y proot-distro curl git

# Step 3: Install Ubuntu using proot-distro
proot-distro install ubuntu

# Step 4: Define the setup script path
SETUP_SCRIPT="$HOME/.bitnet-ubuntu-setup.sh"

# Step 5: Create the setup script
cat << 'EOF' > "$SETUP_SCRIPT"
#!/bin/bash
set -e

echo "[*] Inside Ubuntu environment..."

# Update package lists
apt update -y

# Install essential packages
apt install -y build-essential git curl wget

# Manually add PPA key to avoid 504 errors
echo "[*] Adding Mozilla Team PPA key manually..."
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6DCF7707EBC211F

# Add the PPA repository
echo "deb http://ppa.launchpad.net/mozillateam/thunderbird-next/ubuntu noble main" > /etc/apt/sources.list.d/mozillateam-thunderbird-next.list

# Update package lists again
apt update -y

# Install Thunderbird
apt install -y thunderbird

# Clone BitNet repository
echo "[*] Cloning BitNet repository..."
git clone https://github.com/bitnet/bitnet.git /opt/bitnet

echo "[*] BitNet setup completed inside Ubuntu."
EOF

# Step 6: Make the setup script executable
chmod +x "$SETUP_SCRIPT"

# Step 7: Copy the setup script into the Ubuntu environment
echo "[*] Copying setup script into Ubuntu environment..."
proot-distro login ubuntu -- bash -c "cp /host-rootfs/data/data/com.termux/files/home/.bitnet-ubuntu-setup.sh /root/"

# Step 8: Run the setup script inside Ubuntu
echo "[*] Running setup script inside Ubuntu..."
proot-distro login ubuntu -- bash /root/.bitnet-ubuntu-setup.sh

echo "[*] BitNet setup completed successfully."
