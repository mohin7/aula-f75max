// Copies the latest app build (../dist/AULA-Studio.dmg, made by `make dmg`) into the site,
// so the download buttons serve it directly from the website.
import { copyFileSync, existsSync, mkdirSync, statSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const website = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const source = resolve(website, '../dist/AULA-Studio.dmg')
const target = resolve(website, 'public/downloads/AULA-Studio.dmg')

if (!existsSync(source)) {
  if (existsSync(target)) {
    console.log('sync-dmg: no new build in ../dist, keeping public/downloads/AULA-Studio.dmg')
    process.exit(0)
  }
  console.error('sync-dmg: ../dist/AULA-Studio.dmg not found. Run `make dmg` in the repository root first.')
  process.exit(1)
}

const same = existsSync(target) && statSync(target).size === statSync(source).size && statSync(target).mtimeMs >= statSync(source).mtimeMs
if (same) {
  console.log('sync-dmg: public/downloads/AULA-Studio.dmg is up to date')
} else {
  mkdirSync(dirname(target), { recursive: true })
  copyFileSync(source, target)
  console.log(`sync-dmg: copied ${(statSync(target).size / 1e6).toFixed(1)} MB to public/downloads/AULA-Studio.dmg`)
}
