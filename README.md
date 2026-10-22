# Meeting Action Tracker

A single-page app for teams that keep forgetting agreed actions. Add an action with an owner and due date, see actions grouped by owner, tick them off, and spot overdue ones in red.

- Open, done and overdue counts with a progress bar
- Filter by All, Open or Overdue
- Delete with undo
- Sign in and sign out with a username and password
- Users panel to see the team and add users with a password you choose
- Live shared data in Supabase: everyone sees the same actions, refreshed every 30 seconds and when the tab regains focus

No build step and no dependencies. The whole app is `index.html`, which talks to Supabase over its REST API.

## Database and sign-in

The app uses Supabase for data and sign-in:

- `public.actions`: the actions. Only signed-in users can read or change them.
- `public.profiles`: one row per user, with username and display name. A trigger fills it when a user is created.
- `create-user` edge function (`supabase/functions/create-user/index.ts`): adds a user with a chosen password. It checks the caller is signed in and holds the admin key, which never reaches the browser.

`supabase/schema.sql` has the tables, policies and trigger.

Users sign in with a username. Behind the scenes it maps to `username@tracker.internal` in Supabase Auth, so no real email addresses or confirmation emails are needed.

The Supabase URL and publishable key are set at the top of the script in `index.html`. A publishable key is meant to be public.

**All signed-in users are equal.** Any signed-in user can add users. Passwords need at least 8 characters, so change the starting password for each person.

## Run locally

Open `index.html` in a browser, or serve the folder:

```bash
npx serve .
```

## Deploy to Vercel

1. In Vercel, choose **Add New > Project** and import this repository.
2. Set **Framework Preset** to **Other**. Leave the build command and output directory empty.
3. Click **Deploy**.

`vercel.json` adds clean URLs and two basic security headers.
