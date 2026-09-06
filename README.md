# Kapnanda School Management System — Supabase Edition

## Files
- `index.html` — complete school management system and login screen.
- `supabase_schema.sql` — database tables and Row Level Security policies.
- `supabase/functions/create-staff-user/index.ts` — administrator-only account generator.
- `supabase/functions/admin-reset-password/index.ts` — recovery-number password reset endpoint.

## Important
The browser uses only the Supabase publishable key. Never put a `sb_secret_...` key in `index.html` or GitHub. Supabase recommends secret keys only in backend/Edge Functions.

## Configure index.html
Replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_PUBLISHABLE_KEY` in the constants near the top of the JavaScript.

## Supabase setup
1. Run `supabase_schema.sql` in Supabase SQL Editor.
2. Create the first administrator in Supabase Authentication > Users.
3. Run the commented profile INSERT at the bottom of `supabase_schema.sql`, replacing the administrator email.
4. Set Edge Function secrets: `SUPABASE_SECRET_KEY` and `KAPNANDA_RECOVERY_NUMBER`. Set `KAPNANDA_RECOVERY_NUMBER` to the recovery number you specified.
5. Deploy both Edge Functions.
6. Open the GitHub Pages site and sign in.

The generated staff credentials are returned once to the administrator and are not stored in the frontend source code.
