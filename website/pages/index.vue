<script setup lang="ts">
import { site } from '~/data/site'
import { faqs } from '~/data/content'

usePageSeo({
  title: site.title,
  description: site.description,
  path: '/',
  schema: [useAppSchema(), faqSchema(faqs)],
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
