import { joinURL } from 'ufo'
import { repoPaths } from '~/data/site'

/** Prefixes public assets with the app base URL (needed when hosted under /aula-f75max/). */
export function useAsset() {
  const base = useRuntimeConfig().app.baseURL
  return (path: string) => joinURL(base, path)
}

/** Every outbound link in one place, driven by runtime config. */
export function useSiteLinks() {
  const config = useRuntimeConfig().public
  const asset = useAsset()
  const repo = (path: keyof typeof repoPaths) =>
    repoPaths[path].startsWith('#') ? `${config.githubUrl}${repoPaths[path]}` : joinURL(config.githubUrl, repoPaths[path])

  return {
    /** Same-site path (prefixed with the base URL) or a full URL. */
    download: config.downloadUrl.startsWith('/') ? asset(config.downloadUrl) : config.downloadUrl,
    /** File name the browser saves, e.g. AULA-Studio-0.4.0.dmg. */
    downloadName: config.appVersion ? `AULA-Studio-${config.appVersion}.dmg` : 'AULA-Studio.dmg',
    github: config.githubUrl,
    version: config.appVersion,
    size: config.downloadSize,
    repo,
  }
}
