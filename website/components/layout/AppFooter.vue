<script setup lang="ts">
import { site } from '~/data/site'

const links = useSiteLinks()

const columns = [
  { title: 'Product', items: [
    { label: 'Features', href: '#features' },
    { label: 'Coming soon', href: '#keymap' },
    { label: 'FAQ', href: '#faq' },
    { label: 'Download', href: '#download' },
  ] },
  { title: 'Project', items: [
    { label: 'GitHub', href: links.github, external: true },
    { label: 'Documentation', href: links.repo('readme'), external: true },
    { label: 'Roadmap', href: links.repo('roadmap'), external: true },
    { label: 'Contribute', href: links.repo('contributing'), external: true },
    { label: 'Protocol notes', href: links.repo('protocol'), external: true },
  ] },
  { title: 'Support', items: [
    { label: 'Report an issue', href: links.repo('issues'), external: true },
    { label: 'Security', href: links.repo('security'), external: true },
    { label: 'License (MIT)', href: links.repo('license'), external: true },
  ] },
]
</script>

<template>
  <footer class="border-t border-white/[0.06] px-5 pt-12 pb-8 sm:px-8">
    <div class="mx-auto grid max-w-6xl grid-cols-3 gap-x-4 gap-y-10 md:grid-cols-[1.4fr_1fr_1fr_1fr] md:gap-12">
      <div class="col-span-3 flex flex-col gap-4 md:col-span-1">
        <AppLogo />
        <p class="text-ink-300">{{ site.tagline }}</p>
        <p class="text-sm text-ink-400">
          Made by <a :href="site.author.github" target="_blank" rel="noopener noreferrer" class="text-ink-200 underline-offset-4 hover:underline">{{ site.author.name }}</a>
          ·
          <a :href="site.author.linkedin" target="_blank" rel="noopener noreferrer" class="text-ink-200 underline-offset-4 hover:underline">LinkedIn</a>
        </p>
      </div>
      <nav v-for="column in columns" :key="column.title" :aria-label="column.title">
        <h2 class="text-sm font-medium text-white">{{ column.title }}</h2>
        <ul class="mt-4 flex flex-col gap-3">
          <li v-for="item in column.items" :key="item.label">
            <a
              :href="item.href"
              :target="'external' in item && item.external ? '_blank' : undefined"
              :rel="'external' in item && item.external ? 'noopener noreferrer' : undefined"
              class="text-sm text-ink-400 transition-colors hover:text-white"
            >{{ item.label }}</a>
          </li>
        </ul>
      </nav>
    </div>

    <div class="mx-auto mt-10 flex max-w-6xl flex-col gap-3 border-t border-white/[0.06] pt-8 text-xs text-ink-400 sm:flex-row sm:items-center sm:justify-between">
      <p>© 2026 AULA Studio · Made for macOS · Open source under the MIT License</p>
      <p class="max-w-xl text-pretty sm:text-right">Unofficial app. Not affiliated with or endorsed by AULA or Epomaker. Product names are trademarks of their respective owners.</p>
    </div>
  </footer>
</template>
