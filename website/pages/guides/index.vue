<script setup lang="ts">
import { guides } from '~/data/guides'

const crumbs = [{ name: 'Guides', path: '/guides/' }]

usePageSeo({
  title: 'AULA F75 Max Mac Guides: Setup, RGB, Screen | AULA Studio',
  description: 'Step-by-step guides for using the AULA F75 Max on a Mac: setup, RGB lighting effects, GIFs on the screen, sleep timer, key locks and clock sync.',
  path: '/guides/',
  crumbs,
  schema: [{
    '@context': 'https://schema.org',
    '@type': 'CollectionPage',
    name: 'AULA F75 Max guides for Mac',
    url: absoluteUrl('/guides/'),
    hasPart: guides.map((g) => ({ '@type': 'TechArticle', headline: g.title, url: absoluteUrl(`/guides/${g.slug}/`) })),
  }],
})

const links = useSiteLinks()
</script>

<template>
  <div>
    <AppHeader />
    <main id="main">
      <PageIntro
        :crumbs="crumbs"
        eyebrow="Guides"
        title="Use your AULA F75 Max on a Mac"
        lead="How to set up the keyboard with AULA Studio and change everything the app supports today. Each guide sticks to what the app really does."
      />

      <section class="section" aria-label="All guides">
        <div class="frame">
          <GuideCards heading-level="h2" />
          <p class="mt-10 max-w-2xl text-pretty text-sm leading-relaxed text-ink-400">
            Looking for the technical side? The
            <a :href="links.repo('protocol')" target="_blank" rel="noopener noreferrer" class="text-ink-200 underline underline-offset-4 hover:text-white">protocol notes</a>
            and
            <a :href="links.repo('roadmap')" target="_blank" rel="noopener noreferrer" class="text-ink-200 underline underline-offset-4 hover:text-white">roadmap</a>
            live on GitHub.
          </p>
          <div class="mt-12">
            <DownloadCard />
          </div>
        </div>
      </section>
    </main>
    <AppFooter />
  </div>
</template>
