#!/usr/bin/env bash
# Creates a folder `events-site/` with the full project files and produces events-site.zip
# Usage:
# 1. Save this script as create_events_zip.sh
# 2. chmod +x create_events_zip.sh
# 3. ./create_events_zip.sh
# The resulting archive: ./events-site.zip

set -euo pipefail

BASE="events-site"

rm -rf "$BASE" events-site.zip
mkdir -p "$BASE"
echo "Creating project files under ./$BASE ..."

# README.md
mkdir -p "$BASE"
cat > "$BASE/README.md" <<'EOF'
# Events — GitHub-native

Events is a static, GitHub-native event scheduling site:
- Hosted on GitHub Pages (built by GitHub Actions).
- Event content stored as JSON files in the repository (content/events/*.json).
- Admin publishing flow: open an Issue using the event template and label it `publish-event` — a GitHub Action will convert it into a JSON event file in the repo.
- No backend, no Firebase — everything runs in the browser or inside GitHub Actions.

Quickstart (local)
1. Clone the repo
2. npm ci
3. npm run dev
4. Open http://localhost:5173

Publish flow (GitHub-native)
- Create an Issue using .github/ISSUE_TEMPLATE/event.md and fill the required fields.
- Label the issue `publish-event`.
- The workflow `.github/workflows/issue-to-event.yml` will run, parse the issue content, and commit a new JSON file into `content/events/`. It will also comment on the issue with the commit link.
- The build workflow `.github/workflows/deploy.yml` triggers on push to `main` and deploys the site to `gh-pages`.

Editing events
- Edit existing `content/events/*.json` files directly and submit a PR, or use the GitHub UI to edit and merge.
- Alternatively, open an Issue and use the same flow to propose changes.

Notes
- Because the site is static, event visibility is controlled by what is in the repo (public). For private events you would keep them out of the repo or create a private repository.
- The Issue -> file workflow performs simple parsing (see .github/workflows/issue-to-event.yml). Review generated JSON and security practices before enabling for public repos.
EOF

# .gitignore
cat > "$BASE/.gitignore" <<'EOF'
node_modules
dist
.env.local
.DS_Store
.vscode
EOF

# package.json
cat > "$BASE/package.json" <<'EOF'
{
  "name": "events",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext .ts,.tsx,.js,.jsx || true"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "react-router-dom": "6.14.1"
  },
  "devDependencies": {
    "@types/react": "^18.2.26",
    "@types/react-dom": "^18.2.9",
    "autoprefixer": "^10.4.14",
    "eslint": "^8.47.0",
    "eslint-config-prettier": "^8.10.0",
    "postcss": "^8.4.24",
    "tailwindcss": "^4.6.0",
    "typescript": "^5.5.0",
    "vite": "^5.2.0",
    "@vitejs/plugin-react": "^5.0.0"
  }
}
EOF

# vite.config.ts
cat > "$BASE/vite.config.ts" <<'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  base: "./"
});
EOF

# tailwind.config.cjs
cat > "$BASE/tailwind.config.cjs" <<'EOF'
module.exports = {
  content: ["./index.html", "./src/**/*.{ts,tsx,js,jsx}"],
  theme: {
    extend: {
      colors: {
        indigoPrimary: "#3F51B5"
      },
      fontFamily: {
        pt: ["'PT Sans'", "ui-sans-serif", "system-ui"]
      }
    }
  },
  plugins: []
};
EOF

# postcss.config.cjs
cat > "$BASE/postcss.config.cjs" <<'EOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
};
EOF

# index.html
cat > "$BASE/index.html" <<'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Events</title>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=PT+Sans:wght@400;700&display=swap" rel="stylesheet">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# src files
mkdir -p "$BASE/src/components" "$BASE/src/pages" "$BASE/src/lib"

# src/index.css
cat > "$BASE/src/index.css" <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root{
  --primary: #3F51B5;
  --bg: #f5f7fb;
  --card: #ffffff;
}

html,body,#root { height:100%; }
body {
  font-family: "PT Sans", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  background: var(--bg);
  color: #111827;
}
.container {
  max-width: 960px;
  margin-left: auto;
  margin-right: auto;
}
a { color: var(--primary); }
EOF

# src/main.tsx
cat > "$BASE/src/main.tsx" <<'EOF'
import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);
EOF

# src/App.tsx
cat > "$BASE/src/App.tsx" <<'EOF'
import React from "react";
import { Routes, Route } from "react-router-dom";
import Schedule from "./pages/Schedule";
import EventDetails from "./pages/EventDetails";
import AdminGuide from "./pages/AdminGuide";
import Header from "./components/Header";

export default function App() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="container px-4 py-6 flex-1">
        <Routes>
          <Route path="/" element={<Schedule />} />
          <Route path="/events/:id" element={<EventDetails />} />
          <Route path="/admin" element={<AdminGuide />} />
          <Route path="*" element={<div>Not found — <a href="/">Go home</a></div>} />
        </Routes>
      </main>
    </div>
  );
}
EOF

# src/components/Header.tsx
cat > "$BASE/src/components/Header.tsx" <<'EOF'
import React from "react";
import { Link } from "react-router-dom";

export default function Header() {
  return (
    <header className="w-full bg-white border-b py-3 px-6 flex items-center justify-between shadow-sm">
      <div>
        <Link to="/" className="text-xl font-bold text-indigoPrimary">Events</Link>
      </div>
      <nav>
        <Link to="/" className="mr-4 text-sm text-slate-600">Schedule</Link>
        <Link to="/admin" className="text-sm text-slate-600">Admin</Link>
      </nav>
    </header>
  );
}
EOF

# src/components/EventCard.tsx
cat > "$BASE/src/components/EventCard.tsx" <<'EOF'
import React from "react";
import { Link } from "react-router-dom";

export default function EventCard({ event }: { event: any }) {
  const start = new Date(event.start);
  const end = event.end ? new Date(event.end) : undefined;

  const typeColor = {
    social: "border-pink-400",
    performance: "border-yellow-400",
    meeting: "border-green-400",
    other: "border-slate-300"
  }[event.type || "other"];

  const icon = {
    social: "🎉",
    performance: "🎤",
    meeting: "📋",
    other: "📅"
  }[event.type || "other"];

  const now = new Date();
  let status = "upcoming";
  if (end && now > end) status = "finished";
  else if (now >= start && (!end || now <= end)) status = "live";

  return (
    <Link to={`/events/${event.id}`} className="block">
      <div className={`bg-white border rounded-lg shadow-sm overflow-hidden hover:shadow-md transition p-4 mb-3 flex gap-4`}>
        <div className={`w-2 ${typeColor}`} />
        <div className="flex-1">
          <div className="flex items-center justify-between">
            <h3 className="font-semibold text-lg">{icon} {event.title}</h3>
            <span className={`inline-flex items-center px-2 py-0.5 text-xs font-medium rounded-full ${status === "live" ? "bg-red-100 text-red-800 animate-pulse" : status === "upcoming" ? "bg-indigo-100 text-indigo-800" : "bg-gray-100 text-gray-700"}`}>
              {status === "live" ? "Live Now" : status === "upcoming" ? "Upcoming" : "Finished"}
            </span>
          </div>
          <div className="text-sm text-slate-600 mt-1">
            {event.publicDescription ?? event.description ?? ""}
          </div>
          <div className="text-xs text-slate-400 mt-2">
            {start.toLocaleString()} {end ? ` — ${end.toLocaleTimeString()}` : ""}
          </div>
        </div>
      </div>
    </Link>
  );
}
EOF

# src/lib/events.ts
cat > "$BASE/src/lib/events.ts" <<'EOF'
export type Event = {
  id: string;
  title: string;
  description?: string;
  publicDescription?: string;
  start: string; // ISO string
  end?: string; // ISO string
  type?: string;
  metadata?: Record<string, any>;
};

export function loadEvents(): Event[] {
  const modules = import.meta.glob('../../content/events/*.json', { eager: true }) as Record<string, any>;
  const events: Event[] = Object.values(modules).map((m: any) => m.default || m);
  events.sort((a, b) => new Date(a.start).getTime() - new Date(b.start).getTime());
  return events;
}
EOF

# src/pages/Schedule.tsx
cat > "$BASE/src/pages/Schedule.tsx" <<'EOF'
import React from "react";
import EventCard from "../components/EventCard";
import { loadEvents, Event } from "../lib/events";

function groupByDate(events: Event[]) {
  const map: Record<string, Event[]> = {};
  events.forEach((ev) => {
    const d = new Date(ev.start);
    const key = d.toDateString();
    map[key] = map[key] || [];
    map[key].push(ev);
  });
  return Object.entries(map).sort((a, b) => new Date(a[0]).getTime() - new Date(b[0]).getTime());
}

export default function Schedule() {
  const [events] = React.useState<Event[]>(() => loadEvents());

  const grouped = groupByDate(events);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Schedule</h1>
      {grouped.length === 0 && <div>No events found</div>}
      {grouped.map(([date, evs]) => (
        <section key={date} className="mb-6">
          <h2 className="font-semibold text-lg mb-2">{new Date(date).toLocaleDateString(undefined, { weekday: "long", month: "long", day: "numeric" })}</h2>
          {evs.map((e) => <EventCard key={e.id} event={e} />)}
        </section>
      ))}
    </div>
  );
}
EOF

# src/pages/EventDetails.tsx
cat > "$BASE/src/pages/EventDetails.tsx" <<'EOF'
import React from "react";
import { useParams, Link } from "react-router-dom";
import { loadEvents } from "../lib/events";

export default function EventDetails() {
  const params = useParams();
  const id = params.id ?? "";
  const events = loadEvents();
  const event = events.find((e) => e.id === id);

  if (!event) return <div>Event not found — <Link to="/">Back</Link></div>;

  return (
    <div>
      <h1 className="text-2xl font-bold">{event.title}</h1>
      <p className="text-sm text-slate-600 mt-2">{event.publicDescription ?? event.description}</p>

      <section className="mt-6">
        <h3 className="font-semibold">Details</h3>
        <div className="mt-2">
          <div><strong>Start:</strong> {new Date(event.start).toLocaleString()}</div>
          {event.end && <div><strong>End:</strong> {new Date(event.end).toLocaleString()}</div>}
        </div>
      </section>

      <section className="mt-6">
        <details>
          <summary className="cursor-pointer">Full (raw) event data</summary>
          <pre className="mt-2 bg-slate-50 p-3 rounded text-xs overflow-auto">{JSON.stringify(event, null, 2)}</pre>
        </details>
      </section>
    </div>
  );
}
EOF

# src/pages/AdminGuide.tsx
cat > "$BASE/src/pages/AdminGuide.tsx" <<'EOF'
import React from "react";

export default function AdminGuide() {
  return (
    <div>
      <h1 className="text-2xl font-bold mb-4">Admin — How to publish events</h1>

      <ol className="list-decimal ml-6">
        <li>Open a new Issue using the "Event" issue template (<code>.github/ISSUE_TEMPLATE/event.md</code>).</li>
        <li>Fill the event fields (Title, Start, End, Type, Public Description, Internal Notes).</li>
        <li>Label the issue <strong>publish-event</strong>. The repository's GitHub Action will parse the issue and create a new file under <code>content/events/</code>.</li>
        <li>Review the commit created by the workflow. Edit event files directly or via PR for corrections.</li>
      </ol>

      <p className="mt-4">You can also add or edit event JSON files manually in <code>content/events/*.json</code> and open a PR.</p>
    </div>
  );
}
EOF

# content/events sample
mkdir -p "$BASE/content/events"
cat > "$BASE/content/events/2025-10-29-sample-event.json" <<'EOF'
{
  "id": "2025-10-29-sample-event",
  "title": "Sample Orientation Session",
  "publicDescription": "Welcome to our sample orientation. Open to everyone.",
  "description": "Full internal description with extra notes.",
  "start": "2025-10-29T18:00:00Z",
  "end": "2025-10-29T19:30:00Z",
  "type": "meeting",
  "metadata": {
    "room": "Main Hall"
  }
}
EOF

# .github files
mkdir -p "$BASE/.github/ISSUE_TEMPLATE" "$BASE/.github/workflows"

cat > "$BASE/.github/ISSUE_TEMPLATE/event.md" <<'EOF'
---
name: "Event"
about: "Create a new event to publish to the site"
title: "Event: [Event Title]"
labels: ["event-proposal"]
assignees: []
---

Provide event information below using the headings. When ready, add the label `publish-event` to publish it automatically.

### Title
Event title here

### Start
YYYY-MM-DD HH:MM (UTC)  — e.g. 2025-10-29 18:00

### End
YYYY-MM-DD HH:MM (UTC)  — optional

### Type
social | performance | meeting | other

### Public Description
Short public description for the schedule

### Internal Notes
(Internal details; will be stored in the event JSON but visible in repo only.)

Example:

Title: Sample Orientation
Start: 2025-10-29 18:00
End: 2025-10-29 19:30
Type: meeting
Public Description: Welcome to our sample orientation. Open to everyone.
Internal Notes: Setup at 17:00. AV check at 17:30.
EOF

cat > "$BASE/.github/workflows/issue-to-event.yml" <<'EOF'
name: Issue -> Event file

on:
  issues:
    types: [labeled]

jobs:
  issue-to-event:
    if: contains(github.event.issue.labels.*.name, 'publish-event')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Parse issue and create event file
        env:
          ISSUE_TITLE: ${{ github.event.issue.title }}
          ISSUE_BODY: ${{ github.event.issue.body }}
          ISSUE_NUMBER: ${{ github.event.issue.number }}
          REPO: ${{ github.repository }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          set -e
          BODY="$ISSUE_BODY"

          TITLE="$(echo "$ISSUE_TITLE" | sed 's/^Event: //;s/^event: //I')"
          START="$(echo "$BODY" | sed -n 's/^Start[[:space:]]*[:\-]*[[:space:]]*//Ip' | sed -n '1p')"
          END="$(echo "$BODY" | sed -n 's/^End[[:space:]]*[:\-]*[[:space:]]*//Ip' | sed -n '1p')"
          TYPE="$(echo "$BODY" | sed -n 's/^Type[[:space:]]*[:\-]*[[:space:]]*//Ip' | sed -n '1p')"
          PUBLIC="$(echo "$BODY" | sed -n 's/^Public Description[[:space:]]*[:\-]*[[:space:]]*//Ip' | sed -n '1p')"
          INTERNAL="$(echo "$BODY" | sed -n 's/^Internal Notes[[:space:]]*[:\-]*[[:space:]]*//Ip' | sed -n '1p')"

          if [ -z "$START" ]; then
            START="$(echo "$BODY" | grep -i '^Start:' | head -n1 | sed 's/^Start:[[:space:]]*//I')"
          fi

          if [ -z "$TYPE" ]; then TYPE="other"; fi
          if [ -z "$PUBLIC" ]; then PUBLIC=""; fi

          to_iso() {
            DATEIN="$1"
            if [ -z "$DATEIN" ]; then
              echo ""
              return
            fi
            if echo "$DATEIN" | grep -q 'T'; then
              echo "$DATEIN"
              return
            fi
            echo "$(echo "$DATEIN" | sed 's/ /T/'):00Z"
          }

          START_ISO="$(to_iso "$START")"
          END_ISO="$(to_iso "$END")"

          SLUG="$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g' | sed 's/^-//;s/-$//')"
          TIMESTAMP=$(date -u +"%Y%m%d%H%M%S")
          FILENAME="content/events/${TIMESTAMP}-${SLUG}.json"

          mkdir -p content/events

          jq -n \
            --arg id "${TIMESTAMP}-${SLUG}" \
            --arg title "$TITLE" \
            --arg publicDescription "$PUBLIC" \
            --arg description "$INTERNAL" \
            --arg start "$START_ISO" \
            --arg end "$END_ISO" \
            --arg type "$TYPE" \
            '{
              id: $id,
              title: $title,
              publicDescription: $publicDescription,
              description: $description,
              start: $start,
              end: ($end | select(. != "")),
              type: $type,
              metadata: {}
            }' > "$FILENAME"

          git add "$FILENAME"
          git commit -m "Add event: $TITLE (from issue #$ISSUE_NUMBER)"
          git push

      - name: Comment on issue with link
        uses: actions/github-script@v7
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const issue_number = context.payload.issue.number;
            const repo = context.repo;
            const comment = `Event file has been created/committed to the repository. If you need edits, please open a PR or update the file directly.`;
            await github.issues.createComment({
              owner: repo.owner,
              repo: repo.repo,
              issue_number,
              body: comment
            });
EOF

cat > "$BASE/.github/workflows/deploy.yml" <<'EOF'
name: Build and Deploy to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Deploy to gh-pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dist
EOF

# Create ZIP
echo "Creating ZIP archive events-site.zip ..."
(cd "$BASE" && zip -r ../events-site.zip .) >/dev/null

echo "Done. Archive created: ./events-site.zip"
echo "You can now upload events-site.zip to GitHub (Repository → Add file → Upload files) or unzip locally and push with git."