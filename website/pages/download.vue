<script setup lang="ts">
import { site } from '~/data/site'
import { downloadFaqs, installSteps } from '~/data/content'
import { features } from '~/data/features'

const crumbs = [{ name: 'Download', path: '/download/' }]

const connectionRows = [
  ['Live key preview', 'Yes', 'Yes', 'Yes'],
  ['Lighting, screen, clock and settings', 'Yes', 'Not yet', 'No, the keyboard doesn’t allow it'],
  ['Battery level', 'Charging', 'Not reported yet', 'Yes'],
]

const available = features.filter((f) => f.status === 'available')
const comingSoon = features.filter((f) => f.status === 'coming-soon')

usePageSeo({
  title: 'Download AULA F75 Max Software for macOS (No Driver Needed)',
  description: 'Download AULA Studio, free AULA F75 Max software for Mac. AULA’s own app is Windows-only; this one needs no driver. macOS 15+, Apple silicon and Intel.',
  path: '/download/',
  crumbs,
  schema: [useAppSchema(), faqSchema(downloadFaqs)],
})

const links = useSiteLinks()

const requirements = computed(() => [
  ['Keyboard', `${site.keyboard} (tested with its 2024 firmware)`],
  ['macOS', site.requirements],
  ['Mac', `${site.architectures} (universal app)`],
  ['Connection', 'USB-C cable to change settings, Bluetooth for battery level'],
  ['Download', [links.version && `Version ${links.version}`, links.size, '.dmg'].filter(Boolean).join(' · ')],
  ['Price', `Free, open source (${site.license} License)`],
])
</script>

<template>
  <div>
    <AppHeader />
    <main id="main">
      <PageIntro
        :crumbs="crumbs"
        eyebrow="Download"
        title="AULA F75 Max software for Mac"
        lead="AULA’s own software for the F75 Max runs on Windows only. AULA Studio is a free, open-source app made for macOS that changes the lighting, the screen, the clock and the keyboard settings. It talks to the keyboard directly, so there’s no driver to install."
      >
        <div class="mt-10 flex flex-col items-start gap-3">
          <DownloadButton />
          <DownloadMeta />
          <p class="mt-1 text-sm text-ink-400">
            Older versions and release notes are on <a :href="links.repo('releases')" target="_blank" rel="noopener noreferrer" class="text-ink-200 underline underline-offset-4 hover:text-white">GitHub Releases</a>.
          </p>
        </div>
      </PageIntro>

      <section class="section" aria-labelledby="install-title">
        <div class="frame">
          <UiSectionHeading id="install-title" eyebrow="Install" title="Install in three steps" description="The app isn’t notarized by Apple yet, so macOS asks you to confirm the first time." />
          <ol class="mt-10 grid gap-px overflow-hidden rounded-2xl border border-[var(--line)] bg-[var(--line)] md:grid-cols-3">
            <li v-for="(step, i) in installSteps" :key="step.title" class="flex gap-4 bg-ink-900 p-5 sm:p-6">
              <span class="font-mono text-sm text-accent" aria-hidden="true">0{{ i + 1 }}</span>
              <div>
                <h3 class="font-medium text-white"><span class="sr-only">Step {{ i + 1 }}: </span>{{ step.title }}</h3>
                <p class="mt-1.5 text-pretty text-sm leading-relaxed text-ink-300">{{ step.body }}</p>
              </div>
            </li>
          </ol>
          <p class="mt-6 text-sm text-ink-400">
            Next: <NuxtLink to="/guides/setup/" class="text-white underline underline-offset-4">connect your F75 Max and allow the permissions it asks for</NuxtLink>.
          </p>
        </div>
      </section>

      <section class="section" aria-labelledby="features-title">
        <div class="frame">
          <UiSectionHeading id="features-title" eyebrow="What it does" title="What AULA Studio does on your Mac" />
          <div class="mt-10 grid gap-10 lg:grid-cols-[1.6fr_1fr]">
            <ul class="grid gap-4 sm:grid-cols-2">
              <li v-for="feature in available" :key="feature.id" class="rounded-2xl bg-white/[0.03] p-5 ring-1 ring-white/[0.07]">
                <h3 class="font-medium tracking-tight text-white">{{ feature.name }}</h3>
                <p class="mt-2 text-pretty text-sm leading-relaxed text-ink-400">{{ feature.description }}</p>
              </li>
            </ul>
            <div>
              <div class="flex items-center gap-2.5">
                <h3 class="font-medium tracking-tight text-white">Not available yet</h3>
                <UiBadge tone="soon">Coming soon</UiBadge>
              </div>
              <ul class="mt-4 divide-y divide-[var(--line)] border-y border-[var(--line)]">
                <li v-for="feature in comingSoon" :key="feature.id" class="py-4">
                  <p class="text-sm font-medium text-ink-200">{{ feature.name }}</p>
                  <p class="mt-1 text-pretty text-sm leading-relaxed text-ink-400">{{ feature.description }}</p>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      <section class="section" aria-labelledby="requirements-title">
        <div class="frame">
          <UiSectionHeading id="requirements-title" eyebrow="Requirements" title="System requirements and connections" />
          <div class="mt-10 grid gap-10 lg:grid-cols-2">
            <dl class="divide-y divide-[var(--line)] border-y border-[var(--line)]">
              <div v-for="[label, value] in requirements" :key="label" class="grid grid-cols-[7.5rem_1fr] gap-4 py-3.5 text-sm">
                <dt class="meta !text-[13px]">{{ label }}</dt>
                <dd class="text-ink-200">{{ value }}</dd>
              </div>
            </dl>
            <div class="overflow-x-auto">
              <table class="w-full min-w-[28rem] text-left text-sm">
                <caption class="sr-only">What works over each connection</caption>
                <thead>
                  <tr class="border-b border-[var(--line)]">
                    <th scope="col" class="py-3 pr-4 font-normal"><span class="sr-only">Feature</span></th>
                    <th v-for="head in ['USB-C', '2.4G', 'Bluetooth']" :key="head" scope="col" class="meta py-3 pr-4 !text-[13px] font-normal">{{ head }}</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-[var(--line)]">
                  <tr v-for="[label, ...cells] in connectionRows" :key="label">
                    <th scope="row" class="py-3.5 pr-4 font-normal text-ink-200">{{ label }}</th>
                    <td v-for="(cell, i) in cells" :key="i" class="py-3.5 pr-4 text-ink-400">{{ cell }}</td>
                  </tr>
                </tbody>
              </table>
              <p class="mt-4 text-pretty text-sm leading-relaxed text-ink-400">Settings you change over USB-C stay on the keyboard when you switch back to wireless.</p>
            </div>
          </div>
        </div>
      </section>

      <section class="section" aria-labelledby="download-faq-title">
        <div class="frame">
          <UiSectionHeading id="download-faq-title" eyebrow="FAQ" title="Drivers, safety and support" />
          <div class="mt-10 grid gap-x-12 md:grid-cols-2">
            <UiAccordion :items="downloadFaqs.slice(0, 3)" />
            <UiAccordion :items="downloadFaqs.slice(3)" class="-mt-px md:mt-0" />
          </div>
        </div>
      </section>

      <section class="section" aria-labelledby="guides-title">
        <div class="frame">
          <UiSectionHeading id="guides-title" eyebrow="Guides" title="Learn what it can do" />
          <div class="mt-10">
            <GuideCards />
          </div>
        </div>
      </section>
    </main>
    <AppFooter />
  </div>
</template>
