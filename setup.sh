#!/bin/bash
set -e

echo "======================================"
echo " Telegram Bot — VPS Setup Script"
echo "======================================"

BOT_DIR="/root/bot"

# 1. Update system & install Python
echo "[1/6] Installing system dependencies..."
apt-get update -qq
apt-get install -y -qq python3 python3-venv python3-pip git curl \
    libfreetype6-dev libjpeg-dev zlib1g-dev

# 2. Create bot directory
echo "[2/6] Setting up bot directory..."
mkdir -p "$BOT_DIR"

# 3. Copy files (run this from the repo root)
echo "[3/6] Copying bot files..."
cp boy.py "$BOT_DIR/"
cp requirements.txt "$BOT_DIR/"

# 4. Create .env if it doesn't exist
if [ ! -f "$BOT_DIR/.env" ]; then
    cp .env.example "$BOT_DIR/.env"
    echo ""
    echo "  ⚠️  សូមបំពេញ .env ជាមុនសិន:"
    echo "      nano $BOT_DIR/.env"
    echo ""
fi

# 5. Create Python virtual environment & install packages
echo "[4/6] Installing Python packages..."
python3 -m venv "$BOT_DIR/venv"
"$BOT_DIR/venv/bin/pip" install --upgrade pip -q
"$BOT_DIR/venv/bin/pip" install -r "$BOT_DIR/requirements.txt" -q

# 6. Install & enable systemd service
echo "[5/6] Installing systemd service..."
cp bot.service /etc/systemd/system/telegram-bot.service
systemctl daemon-reload
systemctl enable telegram-bot.service

echo "[6/6] Done!"
echo ""
echo "======================================"
echo " Commands:"
echo "   Start :  systemctl start telegram-bot"
echo "   Stop  :  systemctl stop telegram-bot"
echo "   Logs  :  journalctl -u telegram-bot -f"
echo "   Status:  systemctl status telegram-bot"
echo "======================================"
echo ""
echo "  ⚠️  ត្រូវ fill in $BOT_DIR/.env ជាមុន រួចហើយ:"
echo "      systemctl start telegram-bot"
echo ""
