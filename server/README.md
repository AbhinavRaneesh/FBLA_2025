# FBLA 2025 Backend (Node + Express + MongoDB)

This lightweight API matches the Flutter app's RemoteApiClient contract so you can switch from local SQLite to MongoDB Atlas.

## Endpoints

- POST /auth/register { username, password } → { ok }
- POST /auth/login { username, password } → { ok }
- GET /users/:username/points → { points }
- PUT /users/:username/points { points } → { points }
- GET /users/:username/theme → { theme }
- PUT /users/:username/theme { theme } → { theme }
- GET /users/:username/themes → { themes }
- POST /users/:username/themes/purchase { theme } → { ok }
- GET /users/:username/powerups → { powerups: { id: count } }
- POST /users/:username/powerups/purchase { powerupId } → { ok }
- POST /users/:username/powerups/use { powerupId } → { ok }
- GET /users/:username/imported-sets → { sets: [{ name }] }
- POST /users/:username/imported-sets { setName } → { ok }
- DELETE /users/:username/imported-sets/:setName → { ok }

## Setup

1. Install Node 18+.
2. Create `.env` from `.env.example` and set `MONGODB_URI` (Atlas or local). Default port is 3000.
3. Install deps:
   - `npm install`
4. Run dev server:
   - `npm run dev`

On Android emulator, the Flutter app uses `http://10.0.2.2:3000` (already handled by AppConfig). On desktop/web, it uses `http://localhost:3000`.

## Notes

- Users are created on-the-fly when accessing non-auth endpoints if they don't exist yet.
- Theme 'space' is included by default and returned even if not stored.
- Purchasing a theme or power-up does not deduct points; your Flutter UI should update points separately (already wired).
