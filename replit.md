# Telegram Bot — Bakong KHQR Payments

## Overview
A Python Telegram bot that accepts orders, generates Bakong KHQR payment QR codes, and tracks state in a Neon Postgres database via its HTTP `/sql` API. Single-file implementation in `boy.py`.

## Stack
- **Python 3.11+**
- **python-telegram-bot v22+** (Bot API HTTP polling)
- `bakong-khqr`, `requests`, `pillow`, `qrcode`, `python-dotenv`
- Neon Postgres (HTTP API, no driver required)

## Architecture
| Feature | Implementation |
|---|---|
| Transport | python-telegram-bot Bot API polling |
| Concurrency | Full `asyncio` — no threads |
| Per-user safety | `asyncio.Lock` per user ID |
| Global data lock | `asyncio.Lock` |
| Blocking DB/HTTP calls | `run_in_executor` (`run_sync`) |
| Background tasks | `asyncio.create_task` |
| Handler priority | PTB `group=` parameter + `ApplicationHandlerStop` |
| In-memory cache | `MemCache` (TTL-based, in-process) |
| Dispatch | Single `on_private_message` dispatcher with inline state checks |

### Handlers
| Handler | Purpose |
|---|---|
| `on_channel_post` (group -10) | Channel posts → forward to admin |
| `CommandHandler("start")` (group 0) | Show account selection |
| `CommandHandler("cancel")` (group 0) | Cancel active purchase |
| `on_private_message` (group 0) | All private non-command messages dispatcher |
| `on_callback_query` | Inline keyboard callbacks |

## Required Secrets / Environment Variables
| Variable | Description |
|---|---|
| `TELEGRAM_BOT_TOKEN` | Bot token from @BotFather (required) |
| `NEON_DATABASE_URL` | Neon Postgres connection string (required) |
| `BAKONG_TOKEN` | Bakong KHQR API token |
| `DROPMAIL_API_TOKEN` | Dropmail GraphQL API token |

## Admin-Managed Settings (persisted in `bot_settings` DB table)
| Key | Description |
|---|---|
| `PAYMENT_NAME` | Merchant name shown on KHQR |
| `MAINTENANCE_MODE` | `true`/`false` — blocks non-admin users |
| `BAKONG_RELAY_TOKEN` | Relay token (takes priority) |
| `BAKONG_API_TOKEN` | Direct Bakong JWT token |
| `TELEGRAM_CHANNEL_ID` | Notification channel |
| `EXTRA_ADMIN_IDS` | JSON array of additional admin user IDs |
| `ADMIN_BOT_TOKEN` | Token for the admin-only clone bot |
| `DROPMAIL_API_TOKEN` | Dropmail GraphQL API token |

## Primary Admin
Hardcoded: `ADMIN_ID = 5002402843`. Additional admins managed via the ⚙️ settings menu.

---

## Run on Replit
The `Telegram Bot` workflow runs `python3 boy.py` automatically.

---

## Deploy on VPS (Ubuntu/Debian) — 24h

### Step 1 — Upload files to VPS
```bash
scp boy.py requirements.txt setup.sh bot.service .env.example root@YOUR_VPS_IP:/root/bot_setup/
```

### Step 2 — Run setup script (SSH into VPS first)
```bash
ssh root@YOUR_VPS_IP
cd /root/bot_setup
bash setup.sh
```

### Step 3 — Fill in your secrets
```bash
nano /root/bot/.env
```
បំពេញ values ទាំងអស់ (copy from `.env.example`):
```
TELEGRAM_BOT_TOKEN=...
NEON_DATABASE_URL=...
BAKONG_TOKEN=...
DROPMAIL_API_TOKEN=...
```

### Step 4 — Start the bot
```bash
systemctl start telegram-bot
systemctl status telegram-bot
```

### Useful commands
```bash
# មើល logs live
journalctl -u telegram-bot -f

# Restart
systemctl restart telegram-bot

# Stop
systemctl stop telegram-bot

# Auto-start on reboot (already enabled by setup.sh)
systemctl enable telegram-bot
```

## User Preferences
- Keep same code structure/format when migrating
- Use python-telegram-bot (Bot API) not Pyrogram (MTProto)
- All data stored in Neon DB only (no local files)
