# inx_flutter_frontend
Inxource dashboard cross platform flutter version.

## Run the Flutter frontend locally (Web/Chrome)

### Prerequisites
- Flutter SDK (stable channel)
- Chrome (for Flutter web)
- Supabase project (URL + anon key)
- Backend running locally at `http://localhost:8001/api/v1` (recommended)

### 1) Clone and open the project
```bash
cd flutter-fastapi-app
```

### 2) Environment variables
- Copy `.env.example` to `.env` in `flutter-fastapi-app/`
- Set:
  - `SUPABASE_URL` = your Supabase project URL
  - `SUPABASE_ANON_KEY` = your Supabase anon key

### 3) Install dependencies
```bash
flutter pub get
```

If you plan to use Hive codegen later, you can run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4) Start the backend (recommended)
In another terminal:
```bash
cd backend
uvicorn app.main:app --reload --port 8001
```
Ensure it shows: `Uvicorn running on http://127.0.0.1:8001`

### 5) Run the Flutter app (web)
```bash
flutter run -d chrome --web-port=3000
```
Open `http://localhost:3000` if it doesn’t open automatically.

### 6) Sign in
- Use a Supabase Auth user email + password.
- If the account was created via magic link/social and has no password, use “Forgot password” to set one.

### Notes & Troubleshooting
- API base URL is set to `http://localhost:8001/api/v1` in `lib/core/services/api_service.dart`.
- If you get 401s, verify your Supabase session is valid. You can print `SupabaseService.client.auth.currentSession?.accessToken` for debugging.
- If you see timeouts on first load, keep the backend running and retry; local cold starts and large queries may take longer on the first request.
- For best UX, keep Chrome open and let Flutter’s hot reload refresh changes.



