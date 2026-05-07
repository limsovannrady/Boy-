# Telegram Bot — Bakong KHQR Payments

## Overview
A Python Telegram bot that accepts orders, generates Bakong KHQR payment QR codes, and tracks state in a Neon Postgres database via its HTTP `/sql` API. Single-file implementation in `telegram_bot_simple.py`.

## Stack
- **Python 3.11**
- **python-telegram-bot v20+** (Bot API HTTP polling — no MTProto, no session file)
- `bakong-khqr`, `requests`, `pillow`, `qrcode`, `urllib3`, `aiohttp`
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

### Dispatcher Flow (`on_private_message`)
1. Maintenance block (non-admin)
2. Admin branch: settings btn → admin_input states → delete/broadcast/email states → button labels → account-management states
3. Non-admin branch: payment_pending guard → show account selection

## Required Secrets
Stored in Replit Secrets (Tools → Secrets):
- `TELEGRAM_BOT_TOKEN` — from BotFather (required)
- `BAKONG_TOKEN` — Bakong KHQR API token (required)
- `NEON_DATABASE_URL` — Neon Postgres connection string (required)
- `DROPMAIL_API_TOKEN` — Dropmail API token (required)

> **Note:** `TELEGRAM_API_ID` and `TELEGRAM_API_HASH` are no longer needed — the bot uses Bot API (HTTP polling), not Pyrogram MTProto.

## Run
The `Telegram Bot` workflow runs `python3 telegram_bot_simple.py`.
python-telegram-bot handles polling automatically — no webhook or session file needed.

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

## User Preferences
- Keep same code structure/format when migrating
- Use python-telegram-bot (Bot API) not Pyrogram (MTProto)
