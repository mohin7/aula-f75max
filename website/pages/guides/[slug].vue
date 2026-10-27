<script setup lang="ts">
import { findGuide } from '~/data/guides'
import { site } from '~/data/site'

const route = useRoute()

const guide = findGuide(String(route.params.slug))
if (!guide) throw createError({ statusCode: 404, statusMessage: 'Guide not found', fatal: true })

const path = `/guides/${guide.slug}/`
const crumbs = [{ name: 'Guides', path: '/guides/' }, { name: guide.shortTitle, path }]

usePageSeo({
  title: guide.metaTitle,
  description: guide.description,
  path,
  ogType: 'article',
  crumbs,
  schema: [{
    '@context': 'https://schema.org',
    '@type': 'TechArticle',
    headline: guide.title,
    description: guide.description,
    url: absoluteUrl(path),
    dateModified: guide.updated,
    inLanguage: 'en',
    author: { '@type': 'Person', name: site.author.name, url: site.author.github },
    about: { '@id': `${absoluteUrl('/')}#app` },
  }],
})

const updatedLabel = new Date(`${guide.updated}T00:00:00Z`).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' })
</script>

<template>
  <div v-if="guide">
    <AppHeader />
    <main id="main">
      <PageIntro :crumbs="crumbs" eyebrow="Guide" :title="guide.title" :lead="guide.intro">
        <p class="meta mt-6">Updated <time :datetime="guide.updated">{{ updatedLabel }}</time> · AULA Studio for macOS</p>
      </PageIntro>

      <section class="section">
        <div class="frame">
          <article class="max-w-3xl">
            <section v-for="(part, i) in guide.sections" :key="part.heading" :class="i > 0 && 'mt-14'" :aria-labelledby="`part-${i}`">
              <h2 :id="`part-${i}`" class="text-balance text-2xl font-semibold tracking-[-0.025em] text-white sm:text-[1.75rem]">{{ part.heading }}</h2>

              <ol v-if="part.steps" class="mt-5 flex flex-col gap-3">
                <li v-for="(step, n) in part.steps" :key="n" class="flex gap-4 rounded-xl bg-white/[0.03] p-4 ring-1 ring-white/[0.07]">
                  <span class="font-mono text-sm text-accent" aria-hidden="true">{{ String(n + 1).padStart(2, '0') }}</span>
                  <span class="text-pretty leading-relaxed text-ink-200">{{ step }}</span>
                </li>
              </ol>

              <p v-for="(text, p) in part.paragraphs" :key="p" class="mt-5 text-pretty text-[17px] leading-relaxed text-ink-300">{{ text }}</p>

              <div v-if="part.table" class="mt-5 overflow-x-auto">
                <table class="w-full text-left text-sm" :class="part.table.head.length > 2 && 'min-w-[30rem]'">
                  <thead>
                    <tr class="border-b border-[var(--line-strong)]">
                      <th v-for="(head, h) in part.table.head" :key="h" scope="col" class="meta py-3 pr-4 !text-[13px] font-normal">{{ head }}</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-[var(--line)]">
                    <tr v-for="row in part.table.rows" :key="row[0]">
                      <th scope="row" class="py-3.5 pr-4 align-top font-normal text-ink-200">{{ row[0] }}</th>
                      <td v-for="(cell, c) in row.slice(1)" :key="c" class="py-3.5 pr-4 align-top text-pretty text-ink-400">{{ cell }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <ul v-if="part.list" class="mt-5 flex flex-col gap-2.5">
                <li v-for="(item, l) in part.list" :key="l" class="flex gap-3 text-pretty text-[17px] leading-relaxed text-ink-300">
                  <span class="mt-[0.7em] size-1.5 shrink-0 rounded-full bg-accent-solid" aria-hidden="true" />
                  <span>{{ item }}</span>
                </li>
              </ul>

              <NuxtLink v-if="part.link" :to="part.link.to" class="mt-5 inline-flex items-center gap-1.5 text-sm font-medium text-white underline underline-offset-4">
                {{ part.link.label }}
                <svg viewBox="0 0 16 16" class="size-3.5" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M6 3l5 5-5 5" /></svg>
              </NuxtLink>
            </section>
          </article>

          <div class="mt-16">
            <DownloadCard />
          </div>

          <div class="mt-16">
            <h2 class="font-mono text-xs font-medium tracking-tight text-accent">More guides</h2>
            <div class="mt-5">
              <GuideCards :slugs="guide.related" />
            </div>
          </div>
        </div>
      </section>
    </main>
    <AppFooter />
  </div>
</template>
