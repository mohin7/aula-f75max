<script setup lang="ts">
import { docs } from '~/data/content'

const links = useSiteLinks()
</script>

<template>
  <section id="docs" class="section" aria-labelledby="docs-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading id="docs-title" meta="README · Docs/ · protocol notes" eyebrow="Documentation" title="Everything you need to know." description="Guides and notes live alongside the code on GitHub." />
      </div>

      <ul class="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
        <li v-for="(doc, i) in docs" :key="doc.title" v-reveal="i * 60">
          <a :href="links.repo(doc.path)" target="_blank" rel="noopener noreferrer" class="group flex h-full flex-col rounded-2xl bg-white/[0.03] p-5 ring-1 ring-white/[0.07] transition-colors duration-300 hover:bg-white/[0.06]">
            <div class="flex items-center justify-between">
              <h3 class="font-medium tracking-tight text-white">{{ doc.title }}</h3>
              <svg viewBox="0 0 16 16" class="size-3.5 text-ink-400 transition-transform duration-300 group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-white" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M5 11l6-6M6 5h5v5" /></svg>
            </div>
            <p class="mt-2 text-pretty text-sm leading-relaxed text-ink-400">{{ doc.body }}</p>
          </a>
        </li>
      </ul>
    </div>
  </section>
</template>
