# RushMore Phase 03 — Faker → Azure PostgreSQL

## Prerequisites
- Phase 02 schema deployed to `rushmore_db` (six tables).
- Python 3.10+ installed on Windows.
- Azure firewall allows your current public IP (not unrestricted Internet).

## Setup (PowerShell)
```powershell
cd path\to\rushmore_phase03
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
Copy-Item .env.example .env
```
Edit `.env` with your actual Azure password. Never commit `.env` or share the password.

## Run
```powershell
python populate.py --dry-run
python populate.py --load
```
Wait for `COMMITTED successfully`. Loading is atomic: on an exception, the transaction rolls back.
Then open `verification.sql` in pgAdmin and execute each of its three verification sections. Capture screenshots of the row counts and zero-failure results.

## Important
- Loader refuses to run when any of the six tables contain rows, preventing accidental duplicates.
- Only on disposable training data, `python populate.py --load --reset-synthetic` deletes **all** rows from the six tables before loading. Requires a typed confirmation.
- Prices are generated deterministically per menu item, stored in `order_items.unit_price`, and reconciled to `orders.total_amount`.
- Fake customer emails use `example.com`; phone numbers are synthetic identifiers, not validated dialable telephone numbers.
- Faker customer name fields are generated separately for schema compatibility.
- `ingredients` is a standalone inventory catalog as defined by the brief; no recipe mapping is claimed.
- The `menu_items` schema does not contain a price field; historical line-item prices are the authoritative sales prices for this prototype.
- Data is synthetic and should not be represented as real business records.
- After testing, stop the Azure server to limit compute costs; storage and some other charges may continue.
