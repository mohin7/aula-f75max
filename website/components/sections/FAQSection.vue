<script setup lang="ts">
import { faqs } from '~/data/content'

const links = useSiteLinks()
const half = Math.ceil(faqs.length / 2)
</script>

<template>
  <section id="faq" class="section" aria-labelledby="faq-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading id="faq-title" eyebrow="FAQ" title="Things you might ask." meta="6 questions" />
      </div>
      <div v-reveal class="mt-12 grid gap-x-12 md:grid-cols-2">
        <UiAccordion :items="faqs.slice(0, half)" />
        <UiAccordion :items="faqs.slice(half)" class="-mt-px md:mt-0" />
      </div>
      <p class="mt-8 text-sm text-ink-400">
        Something else? <a :href="links.repo('issues')" target="_blank" rel="noopener noreferrer" class="text-white underline underline-offset-4">Open a GitHub issue</a>.
      </p>
    </div>
  </section>
</template>
