# AIMS PHP API (XAMPP)

This is an XAMPP-compatible backend that mirrors the login/dashboard endpoints used by the Flutter app.

## 1) Copy API into XAMPP

Copy this folder:

`php_backend/aims_api`

to:

`C:\xampp\htdocs\aims_api`

## 2) Start XAMPP services

From XAMPP Control Panel, start:

- `Apache`
- `MySQL`

## 3) Create database schema

Open phpMyAdmin:

`http://localhost/phpmyadmin`

Import:

`C:\xampp\htdocs\aims_api\setup\schema.sql`

This creates `afterspace_db` schema plus seeded login accounts only.

Seed login accounts:

- Admin: `ADMIN-001` / `admin123`
- Manager: `MGR-001` / `manager123`
- Staff: `STF-001` / `staff123`

If you already imported an older seeded schema, run:

`C:\xampp\htdocs\aims_api\setup\clear_all_data.sql`

in phpMyAdmin to wipe all existing rows. Then re-import `schema.sql` to restore only the login accounts above.

## 4) Verify endpoints

Health:

`http://127.0.0.1/aims_api/api/health`

Expected response:

```json
{"ok":true,"data":{"status":"healthy","time":"..."}}
```

## 5) Point Flutter app to XAMPP API

Run Flutter with:

```powershell
flutter run --dart-define=AIMS_API_BASE_URL=http://127.0.0.1/aims_api
```

For Android emulator:

```powershell
flutter run --dart-define=AIMS_API_BASE_URL=http://10.0.2.2/aims_api
```

## Implemented routes

- `GET /api/health`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/logout`
- `GET /api/dashboard/admin`
- `GET /api/dashboard/manager`
- `GET /api/dashboard/staff`
- `GET /api/bookings`
- `POST /api/bookings`
- `POST /api/bookings/check-in`
- `POST /api/bookings/cancel`
- `POST /api/sessions/check-in`
- `POST /api/sessions/check-out`
- `GET /api/users`
- `POST /api/users`
- `PATCH /api/users`
- `DELETE /api/users`
- `GET /api/staff-accounts`
- `POST /api/staff-accounts`
- `PATCH /api/staff-accounts`
- `DELETE /api/staff-accounts`
- `GET /api/reports/sales?range=daily|weekly|monthly|yearly`
- `GET /api/reports/customer?days=7|30|90...`
- `GET /api/schedules?from=YYYY-MM-DD&to=YYYY-MM-DD`
- `POST /api/schedules`
- `PATCH /api/schedules`
- `DELETE /api/schedules`
- `GET /api/pricing-promos`
- `POST /api/pricing-promos` (`kind=membership|promotion`)
- `PATCH /api/pricing-promos` (`kind=membership|pricing`)
- `DELETE /api/pricing-promos` (`kind=membership|promotion`)

## Supabase migration

Supabase/PostgreSQL migration files are in `setup/`:

- `supabase_schema.sql` creates the PostgreSQL schema and seed staff accounts.
- `supabase_migration.md` documents the migration/import steps.

To point the PHP API at a Supabase PostgreSQL database, copy `.env.example` to
`.env` in the deployed `aims_api` folder and configure:

```text
AIMS_DB_DRIVER=pgsql
AIMS_DB_HOST=aws-1-ap-northeast-1.pooler.supabase.com
AIMS_DB_PORT=5432
AIMS_DB_NAME=postgres
AIMS_DB_USER=postgres.yifpferiexemkghcipze
AIMS_DB_PASS=<database-password>
```

The PHP runtime must have `pdo_pgsql` enabled. The API now includes PostgreSQL
route support; set `AIMS_DB_DRIVER=pgsql` and restart Apache before switching
live traffic to Supabase.

## Note

For local development speed, seeded passwords are stored as plain values in `password_hash`. Login accepts both plain text and hashed (`password_verify`) values. For production, hash all passwords before deployment.
