import { joinURL, withTrailingSlash } from 'ufo'
import { site } from '~/data/site'

export interface Crumb {
  name: string
  /** Site path with a trailing slash, e.g. /guides/. */
  path: string
}

interface PageSeo {
  title: string
  description: string
  /** Site path with a trailing slash, e.g. /download/. */
  path: string
  ogType?: 'website' | 'article'
  /** Breadcrumb trail after Home. Published as BreadcrumbList structured data. */
  crumbs?: Crumb[]
  schema?: Record<string, unknown>[]
}

/** Title, description, canonical, Open Graph and structured data for one page. */
export function usePageSeo(page: PageSeo) {
  const config = useRuntimeConfig().public
  const url = absoluteUrl(page.path)
  const ogImage = joinURL(config.siteUrl, '/og-image.jpg')

  useSeoMeta({
    title: page.title,
    description: page.description,
    ogType: page.ogType ?? 'website',
    ogSiteName: site.name,
    ogLocale: 'en_US',
    ogTitle: page.title,
    ogDescription: page.description,
    ogUrl: url,
    ogImage,
    ogImageWidth: 1200,
    ogImageHeight: 630,
    ogImageAlt: 'AULA Studio app window with the AULA F75 Max keyboard',
    twitterCard: 'summary_large_image',
    twitterTitle: page.title,
    twitterDescription: page.description,
    twitterImage: ogImage,
    robots: 'index, follow',
  })

  const schema = [...(page.schema ?? [])]
  if (page.crumbs?.length) schema.push(breadcrumbSchema(page.crumbs))

  useHead({
    link: [{ rel: 'canonical', href: url }],
    script: schema.length ? [{ type: 'application/ld+json', innerHTML: JSON.stringify(schema) }] : [],
  })

  return { url, ogImage }
}

/** Canonical URL for a site path. Always ends with a slash, like the URLs the host serves. */
export function absoluteUrl(path: string) {
  return withTrailingSlash(joinURL(useRuntimeConfig().public.siteUrl, path))
}

function breadcrumbSchema(crumbs: Crumb[]) {
  const trail = [{ name: 'Home', path: '/' }, ...crumbs]
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: trail.map((crumb, i) => ({ '@type': 'ListItem', position: i + 1, name: crumb.name, item: absoluteUrl(crumb.path) })),
  }
}

/** SoftwareApplication facts. Only what's true: no ratings, no download counts. */
export function useAppSchema() {
  const config = useRuntimeConfig().public
  const ogImage = joinURL(config.siteUrl, '/og-image.jpg')

  return {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    '@id': `${absoluteUrl('/')}#app`,
    name: site.name,
    description: site.description,
    url: absoluteUrl('/'),
    image: ogImage,
    screenshot: ogImage,
    featureList: ['All 20 firmware lighting effects', 'Pictures and GIFs on the 128×128 screen', 'Keyboard clock sync', 'Key response, sleep timer and key lock settings', 'Live battery level over Bluetooth'],
    applicationCategory: 'UtilitiesApplication',
    operatingSystem: site.requirements,
    license: 'https://opensource.org/licenses/MIT',
    isAccessibleForFree: true,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    downloadUrl: config.downloadUrl.startsWith('/') ? joinURL(config.siteUrl, config.downloadUrl) : config.downloadUrl,
    installUrl: absoluteUrl('/download/'),
    codeRepository: config.githubUrl,
    ...(config.appVersion ? { softwareVersion: config.appVersion, fileSize: config.downloadSize || undefined } : {}),
    author: { '@type': 'Person', name: site.author.name, url: site.author.github, sameAs: [site.author.github, site.author.linkedin] },
  }
}

export function faqSchema(items: ReadonlyArray<{ q: string; a: string }>) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: items.map((f) => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })),
  }
}
