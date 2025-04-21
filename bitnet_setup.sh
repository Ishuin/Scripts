#!/bin/bash
set -e

echo "[*] Updating packages..."
apt update -y && apt install -y unzip build-essential cmake wget curl file

cd /root || exit 1

ZIP_URL="https://github.com/kldurga999/BitNet.cpp/archive/refs/heads/main.zip"
ZIP_FILE="bitnet.zip"
EXTRACTED_DIR="BitNet.cpp-main"

echo "[*] Downloading BitNet.cpp zip file from GitHub..."
curl -L -o "$ZIP_FILE" "$ZIP_URL"

# Validate ZIP
FILE_TYPE=$(file --mime-type -b "$ZIP_FILE")
if [[ "$FILE_TYPE" != "application/zip" ]]; then
    echo "[!] Downloaded file is not a valid ZIP. Detected type: $FILE_TYPE"
    echo "---- File Content Preview ----"
    head -n 20 "$ZIP_FILE"
    exit 1
fi

# Clean existing folder if exists
rm -rf "$EXTRACTED_DIR" BitNet.cpp

echo "[*] Unzipping $ZIP_FILE..."
unzip -q "$ZIP_FILE" || { echo '[!] Failed to unzip BitNet.cpp'; exit 1; }

mv "$EXTRACTED_DIR" BitNet.cpp

echo "[*] Building BitNet.cpp..."
cd BitNet.cpp
mkdir -p build && cd build
cmake .. || { echo '[!] cmake failed'; exit 1; }
make -j$(nproc) || { echo '[!] make failed'; exit 1; }

echo
echo "[*] DONE! You can now run BitNet with:"
echo "/root/BitNet.cpp/build/bitnet -p \"Hello world\""
