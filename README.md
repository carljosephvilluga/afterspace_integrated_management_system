# afterspace_integrated_management_system

## Running the Flutter App with Supabase

The Flutter app connects directly to Supabase with `supabase_flutter`.
XAMPP, Apache, the old PHP API, and local SQL setup files are no longer needed
to run the system.

Get the anon public key from:

```text
Supabase Dashboard -> Project Settings -> API -> Project API keys -> anon public
```

Then run:

```powershell
cd aims
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://yifpferiexemkghcipze.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon-public-key>
```

Do not put the database password or service-role key in Flutter. The app should
only use the anon public key.
