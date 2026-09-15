# AULA Studio website

The product site for AULA Studio. It's built with Nuxt 3, Vue 3, TypeScript, Tailwind CSS v4, VueUse and Nuxt Image, and generated as a static site.

## Develop

The project uses pnpm. The esbuild and sharp build scripts are approved in `pnpm-workspace.yaml`.

```sh
pnpm install
pnpm dev             # http://localhost:3000
pnpm typecheck
```

## Build

```sh
NUXT_APP_BASE_URL=/aula-f75max/ pnpm generate   # output: .output/public
```

`NUXT_APP_BASE_URL` sets the path the site is served from. Leave it unset when the site is served from a domain root.

The `Website` GitHub Actions workflow deploys to GitHub Pages on every push to `main` that changes `website/`. To use it, enable Pages with **Source: GitHub Actions** in the repository settings.

## Releasing a new version

The download buttons serve the DMG from this site, at `/downloads/AULA-Studio.dmg`.

1. Run `make dmg` in the repository root. It writes `dist/AULA-Studio.dmg`.
2. Run `pnpm generate` (or `pnpm dev`). It copies the DMG into `public/downloads/`.
3. Commit `website/public/downloads/AULA-Studio.dmg` and push. GitHub Pages then serves the new file.

The version and file size under the buttons are read from `Support/Info.plist` and the DMG, so there's nothing to update by hand.

## Configuration

Everything that changes between releases lives in `runtimeConfig.public` in `nuxt.config.ts`. You can override any of it at build time:

| Setting | Environment variable | Purpose |
| --- | --- | --- |
| `downloadUrl` | `NUXT_PUBLIC_DOWNLOAD_URL` | The DMG the download buttons fetch (defaults to the copy on this site) |
| `githubUrl` | `NUXT_PUBLIC_GITHUB_URL` | Repository links |
| `siteUrl` | `NUXT_PUBLIC_SITE_URL` | Canonical URL, Open Graph, sitemap and robots.txt |

## Structure

```
data/          Content and facts: features, FAQ, app labels, keyboard layout, lighting colors
composables/   Motion, keyboard lighting, live key mirroring, app window state, links
components/
  ui/          Buttons, badges, choice pills, accordion, download button
  keyboard/    Keyboard visual with CSS-only lighting
  app/         Interactive recreation of the AULA Studio window and its pages
  layout/      Header, footer, logo
  hero/        Hero with the live keyboard
  sections/    Features (app window), coming soon, built for Mac, download, FAQ
plugins/       v-reveal (one shared IntersectionObserver)
scripts/       sync-dmg.mjs copies ../dist/AULA-Studio.dmg into public/downloads
server/routes/ sitemap.xml and robots.txt (prerendered)
```

## Honesty rules

This site describes a real app, so keep it true:

- A feature is marked `available` in `data/features.ts` only if the shipping app has it.
- Key mapping, macros, profiles and custom knob actions are labeled **Coming soon**.
- The recreated app window (`components/app/`) must use the app's real labels and options, and stays labeled as a recreation that doesn't connect to a keyboard.
- Don't add performance numbers, download counts, GitHub stats, testimonials or compatibility claims that haven't been verified.
