# Meeting Action Tracker

A single-page app for teams that keep forgetting agreed actions. Add an action with an owner and due date, see actions grouped by owner, tick them off, and spot overdue ones in red.

- Open, done and overdue counts with a progress bar
- Filter by All, Open or Overdue
- Delete with undo
- Data is saved in the browser's local storage (per browser, not shared between people)

No build step and no dependencies. The whole app is `index.html`.

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
