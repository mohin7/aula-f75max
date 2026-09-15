import { existsSync, readFileSync } from 'node:fs'
import tailwindcss from '@tailwindcss/vite'

// GitHub Pages serves the site from /aula-f75max/. Set NUXT_APP_BASE_URL when building for it.
const baseURL = process.env.NUXT_APP_BASE_URL || '/'

// The DMG is served by the website itself (copied from ../dist by scripts/sync-dmg.mjs, which also
// writes data/release.json). Only files inside website/ are read, so the site builds on its own.
const releasePath = new URL('./data/release.json', import.meta.url)
const release: { version?: string; bytes?: number } = existsSync(releasePath) ? JSON.parse(readFileSync(releasePath, 'utf8')) : {}
const appVersion = release.version ?? ''
const downloadSize = release.bytes ? `${(release.bytes / 1e6).toFixed(1)} MB` : ''

// Everything that changes between releases or deployments lives in runtimeConfig.public,
// so it can be overridden with NUXT_PUBLIC_* environment variables at build time.
export default defineNuxtConfig({
  compatibilityDate: '2026-09-01',
  devtools: { enabled: false },
  telemetry: false,

  modules: ['@nuxt/image', '@vueuse/nuxt'],

  css: ['~/assets/css/main.css'],

  // Component names are their file names (UiButton, KeyboardVisual…), whatever folder they live in.
  components: [{ path: '~/components', pathPrefix: false }],

  vite: {
    plugins: [tailwindcss()],
  },

  app: {
    baseURL,
    head: {
      htmlAttrs: { lang: 'en', class: 'dark' },
      meta: [
        { name: 'viewport', content: 'width=device-width, initial-scale=1, viewport-fit=cover' },
        { name: 'theme-color', content: '#08080a' },
        { name: 'color-scheme', content: 'dark' },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: `${baseURL}favicon.svg` },
        { rel: 'icon', type: 'image/png', sizes: '48x48', href: `${baseURL}favicon-48.png` },
        { rel: 'apple-touch-icon', href: `${baseURL}apple-touch-icon.png` },
      ],
    },
  },

  runtimeConfig: {
    public: {
      /** Absolute site URL, used for canonical links, Open Graph and the sitemap. */
      siteUrl: 'https://mohin7.github.io/aula-f75max',
      /** The DMG every download button fetches. A path is served from this site; a full URL works too. */
      downloadUrl: '/downloads/AULA-Studio.dmg',
      githubUrl: 'https://github.com/mohin7/aula-f75max',
      /** Shown under the download buttons. From data/release.json (written by scripts/sync-dmg.mjs). */
      appVersion,
      downloadSize,
    },
  },

  image: {
    format: ['avif', 'webp'],
    quality: 82,
    screens: { xs: 390, sm: 640, md: 768, lg: 1024, xl: 1280, xxl: 1536, '2xl': 1920 },
  },

  nitro: {
    prerender: {
      routes: ['/', '/sitemap.xml', '/robots.txt'],
      crawlLinks: false,
    },
  },

  experimental: {
    payloadExtraction: false,
  },

  features: {
    inlineStyles: true,
  },

  typescript: {
    strict: true,
  },
})
