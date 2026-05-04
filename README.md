# afterspace_integrated_management_system

## Running the Flutter app with Supabase directly

The Flutter app now connects to Supabase with `supabase_flutter` instead of
calling the XAMPP/PHP API.

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

The Supabase schema file is still kept in:

```text
php_backend/aims_api/setup/supabase_schema.sql
```

That schema also creates the RPC functions used by the direct Flutter client for
staff login and staff password hashing.
