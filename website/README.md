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

## Deploy

The site is live at **https://aula.uxatom.com**, served by the Cloudflare Worker `aula` (static assets only, configured in `wrangler.jsonc`):

```sh
pnpm generate
npx wrangler deploy
```

The `Website` GitHub Actions workflow can also publish to GitHub Pages under `/aula-f75max/`. To use it, enable Pages with **Source: GitHub Actions** in the repository settings.

## Releasing a new version

The download buttons serve the DMG from this site, at `/downloads/AULA-Studio.dmg`.

1. Run `make dmg` in the repository root. It writes `dist/AULA-Studio.dmg`.
2. Run `pnpm generate` (or `pnpm dev`). It copies the DMG into `public/downloads/` and writes its version and size to `data/release.json`.
3. Commit `public/downloads/AULA-Studio.dmg` and `data/release.json`, then push.

The version comes from `Support/Info.plist` and the size from the DMG, so there's nothing to update by hand. The build only reads files inside `website/`, so it also works on hosts that build this folder on its own, such as Cloudflare Pages (build command `pnpm generate`, output directory `dist`).

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
  ui/          Buttons, badges, headings, choice pills, accordion, download button
  keyboard/    Keyboard visual with CSS-only lighting, key inspector, knob
  app/         Interactive recreation of the AULA Studio window and its pages
  layout/      Header, footer, logo
  hero/        Hero with the live keyboard
  sections/    Features (app window), key mapping, macros, profiles, knob, built for Mac,
               how it works, download, contribute, documentation, FAQ
plugins/       v-reveal (one shared IntersectionObserver)
scripts/       sync-dmg.mjs copies ../dist/AULA-Studio.dmg into public/downloads
server/routes/ sitemap.xml and robots.txt (prerendered)
```

## Honesty rules

This site describes a real app, so keep it true:

- A feature is marked `available` in `data/features.ts` only if the shipping app has it.
- Key mapping, macros, profiles and custom knob actions are labeled **Coming soon · Preview**, and their demos say they don't change a real keyboard.
- The recreated app window (`components/app/`) must use the app's real labels and options, and stays labeled as a recreation that doesn't connect to a keyboard.
- Don't add performance numbers, download counts, GitHub stats, testimonials or compatibility claims that haven't been verified.
