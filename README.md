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