<script setup lang="ts">
import { joinURL, withTrailingSlash } from 'ufo'
import { site } from '~/data/site'
import { faqs } from '~/data/content'

const config = useRuntimeConfig().public
const pageUrl = withTrailingSlash(config.siteUrl)
const ogImage = joinURL(config.siteUrl, '/og-image.jpg')

useSeoMeta({
  title: site.title,
  description: site.description,
  ogType: 'website',
  ogSiteName: site.name,
  ogLocale: 'en_US',
  ogTitle: site.title,
  ogDescription: site.description,
  ogUrl: pageUrl,
  ogImage,
  ogImageWidth: 1200,
  ogImageHeight: 630,
  ogImageAlt: 'AULA Studio app window with the AULA F75 Max keyboard',
  twitterCard: 'summary_large_image',
  twitterTitle: site.title,
  twitterDescription: site.description,
  twitterImage: ogImage,
  robots: 'index, follow',
})

// Structured data: only facts. No ratings, no download counts.
const schema = [
  {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: site.name,
    description: site.description,
    url: pageUrl,
    image: ogImage,
    screenshot: ogImage,
    featureList: ['All 20 firmware lighting effects', 'Pictures and GIFs on the 128×128 screen', 'Keyboard clock sync', 'Key response, sleep timer and key lock settings', 'Live battery level over Bluetooth'],
    applicationCategory: 'UtilitiesApplication',
    operatingSystem: site.requirements,
    license: 'https://opensource.org/licenses/MIT',
    isAccessibleForFree: true,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    downloadUrl: config.downloadUrl.startsWith('/') ? joinURL(config.siteUrl, config.downloadUrl) : config.downloadUrl,
    codeRepository: config.githubUrl,
    ...(config.appVersion ? { softwareVersion: config.appVersion } : {}),
    author: { '@type': 'Person', name: site.author.name, url: site.author.github, sameAs: [site.author.github, site.author.linkedin] },
  },
  {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((f) => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })),
  },
]

useHead({
  link: [{ rel: 'canonical', href: pageUrl }],
  script: [{ type: 'application/ld+json', innerHTML: JSON.stringify(schema) }],
})
</script>

<template>
  <div>
    <AppHeader />
    <main id="main">
      <HeroSection />
      <FeatureShowcase />
      <FeatureBento />
      <ProtocolSection />
      <PrivacySection />
      <KeymapStudio />
      <MacroStudio />
      <ProfileStudio />
      <KnobSection />
      <DownloadSection />
      <ContributionSection />
      <DocumentationSection />
      <FAQSection />
    </main>
    <AppFooter />
  </div>
</template>
