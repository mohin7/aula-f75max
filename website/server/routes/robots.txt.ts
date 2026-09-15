import { joinURL } from 'ufo'

export default defineEventHandler((event) => {
  const { siteUrl } = useRuntimeConfig(event).public
  setHeader(event, 'content-type', 'text/plain; charset=utf-8')
  return `User-agent: *\nAllow: /\n\nSitemap: ${joinURL(siteUrl, '/sitemap.xml')}\n`
})
