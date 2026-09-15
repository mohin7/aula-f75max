<script setup lang="ts">
const links = useSiteLinks()

const ways = [
  { title: 'Report a bug', body: 'Something not working with your keyboard? Open an issue with your macOS version and connection type.', href: links.repo('issues'), cta: 'Open an issue' },
  { title: 'Test another keyboard', body: 'Own a different AULA model? Help map what it supports. Never try unverified commands on hardware you rely on.', href: links.repo('contributing'), cta: 'Read the guide' },
  { title: 'Send a pull request', body: 'SwiftUI, IOKit and CoreBluetooth. Small, focused changes with tests are easiest to review.', href: links.repo('contributing'), cta: 'How to contribute' },
]
</script>

<template>
  <section id="contribute" class="relative px-5 py-14 sm:px-8 sm:py-24" aria-labelledby="contribute-title">
    <div class="mx-auto max-w-6xl">
      <div v-reveal>
        <UiSectionHeading id="contribute-title" eyebrow="Open source" title="Built in the open." description="AULA Studio is MIT-licensed and made for the Mac community. Contributions of every size are welcome." />
      </div>

      <ul class="mt-12 grid gap-4 md:grid-cols-3">
        <li v-for="(way, i) in ways" :key="way.title" v-reveal="i * 80">
          <a :href="way.href" target="_blank" rel="noopener noreferrer" class="group flex h-full flex-col rounded-3xl bg-white/[0.03] p-6 ring-1 ring-white/[0.07] transition-colors duration-300 hover:bg-white/[0.06] sm:p-7">
            <h3 class="text-xl font-semibold tracking-tight text-white">{{ way.title }}</h3>
            <p class="mt-2 flex-1 text-pretty leading-relaxed text-ink-300">{{ way.body }}</p>
            <span class="mt-6 inline-flex items-center gap-1.5 text-sm font-medium text-white">
              {{ way.cta }}
              <svg viewBox="0 0 16 16" class="size-3.5 transition-transform duration-300 group-hover:translate-x-0.5" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M6 3l5 5-5 5" /></svg>
            </span>
          </a>
        </li>
      </ul>

      <div v-reveal class="mt-10 flex justify-center">
        <UiButton :href="links.github" external variant="secondary" size="lg">
          <svg viewBox="0 0 16 16" class="size-4" fill="currentColor" aria-hidden="true"><path d="M8 0a8 8 0 0 0-2.5 15.6c.4 0 .5-.2.5-.4v-1.5c-2.2.5-2.7-1-2.7-1-.4-.9-.9-1.2-.9-1.2-.7-.5.1-.5.1-.5.8.1 1.2.8 1.2.8.7 1.3 1.9.9 2.3.7.1-.5.3-.9.5-1.1-1.8-.2-3.6-.9-3.6-4 0-.9.3-1.6.8-2.1-.1-.2-.4-1 .1-2.1 0 0 .7-.2 2.2.8a7.6 7.6 0 0 1 4 0c1.5-1 2.2-.8 2.2-.8.4 1.1.2 1.9.1 2.1.5.6.8 1.3.8 2.1 0 3.1-1.9 3.8-3.6 4 .3.3.6.8.6 1.5v2.2c0 .2.1.5.6.4A8 8 0 0 0 8 0z" /></svg>
          View the repository
        </UiButton>
      </div>
    </div>
  </section>
</template>
