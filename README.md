# afterspace_integrated_management_system

## Running the Flutter App with Supabase

The Flutter app connects directly to Supabase with `supabase_flutter`.
XAMPP, Apache, the old PHP API, and local SQL setup files are no longer needed
to run the system.

Run:

```powershell
cd aims
flutter pub get
flutter run
```

The Supabase URL and anon public key are already configured in the Flutter
client. Do not put the database password or service-role key in Flutter.

If the Supabase project changes later, you can still override the defaults:

```powershell
flutter run --dart-define=SUPABASE_URL=<project-url> --dart-define=SUPABASE_ANON_KEY=<anon-public-key>
```
