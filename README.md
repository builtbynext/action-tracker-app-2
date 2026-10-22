# Meeting Action Tracker

A single-page app for teams that keep forgetting agreed actions. Add an action with an owner and due date, see actions grouped by owner, tick them off, and spot overdue ones in red.

- Open, done and overdue counts with a progress bar
- Filter by All, Open or Overdue
- Delete with undo
- Live shared data in Supabase: everyone sees the same actions, refreshed every 30 seconds and when the tab regains focus

No build step and no dependencies. The whole app is `index.html`, which talks to Supabase over its REST API.

## Database

The app reads and writes a single `public.actions` table. `supabase/schema.sql` holds the table, row-level security policies and example rows.

The Supabase URL and publishable key are set at the top of the script in `index.html`. A publishable key is meant to be public.

**Access is open:** the policies let anyone with the site link view, add, tick and delete actions. That suits a small team sharing a link, but it is not private. To restrict it, add Supabase Auth and change the policies to check `auth.uid()`.

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
