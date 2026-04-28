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

## 3) Create database and seed data

Open phpMyAdmin:

`http://localhost/phpmyadmin`

Import:

`C:\xampp\htdocs\aims_api\setup\schema.sql`

This creates `afterspace_db` and seed records.

Seed login accounts:

- Admin: `ADMIN-001` / `admin123`
- Manager: `MGR-001` / `manager123`
- Staff: `STF-001` / `staff123`

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
- `GET /api/reports/sales?range=daily|weekly|monthly|yearly`
- `GET /api/reports/customer?days=7|30|90...`
- `GET /api/schedules?from=YYYY-MM-DD&to=YYYY-MM-DD`
- `POST /api/schedules`
- `PATCH /api/schedules`
- `DELETE /api/schedules`

## Note

For local development speed, seeded passwords are stored as plain values in `password_hash`. Login accepts both plain text and hashed (`password_verify`) values. For production, hash all passwords before deployment.
