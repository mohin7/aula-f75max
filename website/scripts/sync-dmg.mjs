// Copies the latest app build (../dist/AULA-Studio.dmg, made by `make dmg`) into the site,
// so the download buttons serve it directly, and records its version and size in data/release.json.
//
// The site must also build where only the website/ folder exists (Cloudflare, CI),
// so everything here is optional: without ../dist the committed copy and release.json are used.
import { copyFileSync, existsSync, mkdirSync, readFileSync, statSync, writeFileSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const website = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const source = resolve(website, '../dist/AULA-Studio.dmg')
const plist = resolve(website, '../Support/Info.plist')
const target = resolve(website, 'public/downloads/AULA-Studio.dmg')
const releaseFile = resolve(website, 'data/release.json')

if (existsSync(source)) {
  const upToDate = existsSync(target) && statSync(target).size === statSync(source).size && statSync(target).mtimeMs >= statSync(source).mtimeMs
  if (upToDate) {
    console.log('sync-dmg: public/downloads/AULA-Studio.dmg is up to date')
  } else {
    mkdirSync(dirname(target), { recursive: true })
    copyFileSync(source, target)
    console.log(`sync-dmg: copied ${(statSync(target).size / 1e6).toFixed(1)} MB to public/downloads/AULA-Studio.dmg`)
  }
} else {
  console.log('sync-dmg: no build in ../dist, using the committed public/downloads/AULA-Studio.dmg')
}

if (existsSync(target)) {
  const previous = existsSync(releaseFile) ? JSON.parse(readFileSync(releaseFile, 'utf8')) : {}
  const version = existsSync(plist)
    ? readFileSync(plist, 'utf8').match(/<key>CFBundleShortVersionString<\/key>\s*<string>([^<]+)<\/string>/)?.[1] ?? previous.version ?? ''
    : previous.version ?? ''
  const release = { version, bytes: statSync(target).size }
  if (JSON.stringify(release) !== JSON.stringify({ version: previous.version, bytes: previous.bytes })) {
    writeFileSync(releaseFile, `${JSON.stringify(release, null, 2)}\n`)
    console.log(`sync-dmg: data/release.json → ${release.version}, ${release.bytes} bytes`)
  }
}
