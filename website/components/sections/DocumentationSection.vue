<script setup lang="ts">
const links = useSiteLinks()
</script>

<template>
  <section id="docs" class="section" aria-labelledby="docs-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading id="docs-title" meta="Guides · protocol notes · roadmap" eyebrow="Documentation" title="Everything you need to know" description="Step-by-step guides for the F75 Max on your Mac. The technical notes live alongside the code on GitHub." />
      </div>

      <div v-reveal class="mt-12">
        <GuideCards />
      </div>

      <ul class="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-sm text-ink-400">
        <li><NuxtLink to="/guides/" class="text-ink-200 underline underline-offset-4 hover:text-white">All guides</NuxtLink></li>
        <li><a :href="links.repo('protocol')" target="_blank" rel="noopener noreferrer" class="underline underline-offset-4 hover:text-white">Protocol notes</a></li>
        <li><a :href="links.repo('roadmap')" target="_blank" rel="noopener noreferrer" class="underline underline-offset-4 hover:text-white">Roadmap</a></li>
        <li><a :href="links.repo('security')" target="_blank" rel="noopener noreferrer" class="underline underline-offset-4 hover:text-white">Security &amp; privacy</a></li>
      </ul>
    </div>
  </section>
</template>
