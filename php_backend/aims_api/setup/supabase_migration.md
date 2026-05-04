# Supabase Migration Guide

This project keeps the Flutter app -> PHP API flow, but moves the database
behind the PHP API from MySQL to Supabase PostgreSQL. The Flutter API calls do
not need to change.

## 1. Create the schema in Supabase

1. Open Supabase project `yifpferiexemkghcipze`.
2. Go to SQL Editor.
3. Run `setup/supabase_schema.sql`.

This creates the PostgreSQL version of the AIMS tables and seed login accounts:

- `ADMIN-001` / `admin123`
- `MGR-001` / `manager123`
- `STF-001` / `staff123`

## 2. Export existing MySQL data

From phpMyAdmin, export these tables as CSV or SQL data only:

1. `staff_accounts`
2. `users`
3. `user_profiles`
4. `memberships`
5. `promotions`
6. `membership_types`
7. `bookings`
8. `booking_meta`
9. `sessions`
10. `session_meta`
11. `transactions`
12. `space_pricing`
13. `meeting_schedules`

Import in the same order in Supabase Table Editor so foreign keys resolve.
Skip `api_sessions`; users should log in again after migration.

Before importing, remove duplicate staff emails/employee IDs and duplicate user
emails. Supabase enforces case-insensitive uniqueness for those fields.

## 3. Point the PHP API to Supabase

Supabase database connection values are in:

`Project Settings -> Database -> Connection string`

Copy `.env.example` to `.env` inside the deployed `aims_api` folder, then set
your Supabase database password:

```text
AIMS_DB_DRIVER=pgsql
AIMS_DB_HOST=aws-1-ap-northeast-1.pooler.supabase.com
AIMS_DB_PORT=5432
AIMS_DB_NAME=postgres
AIMS_DB_USER=postgres.yifpferiexemkghcipze
AIMS_DB_PASS=<database-password>
```

This uses Supabase's IPv4 pooler in session mode. The direct database host for
this project is IPv6-only, so the pooler is the better default for XAMPP/local
networks that do not have working IPv6.

After changing `.env`, restart Apache so the PHP API loads the new connection
settings.

## 4. PHP extension requirement

The PHP API needs the PostgreSQL PDO extension enabled:

```ini
extension=pdo_pgsql
extension=pgsql
```

On XAMPP, edit `php.ini`, enable those extensions, then restart Apache.

## 5. Deploy the updated PHP API

Copy the updated `php_backend/aims_api` folder to:

```text
C:\xampp\htdocs\aims_api
```

Then restart Apache and test:

```text
http://127.0.0.1/aims_api/api/health
```

The route code now switches SQL syntax automatically when `AIMS_DB_DRIVER=pgsql`
is set.
