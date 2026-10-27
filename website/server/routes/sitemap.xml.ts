import { joinURL, withTrailingSlash } from 'ufo'
import { sitePages } from '../../data/pages'

export default defineEventHandler((event) => {
  const { siteUrl } = useRuntimeConfig(event).public
  setHeader(event, 'content-type', 'application/xml; charset=utf-8')
  const urls = sitePages.map((page) => `  <url>
    <loc>${withTrailingSlash(joinURL(siteUrl, page.path))}</loc>
    <lastmod>${page.updated}</lastmod>
  </url>`)
  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.join('\n')}
</urlset>
`
})
