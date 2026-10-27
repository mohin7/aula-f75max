<script setup lang="ts">
import { guides } from '~/data/guides'

const props = defineProps<{
  /** Guide slugs to show, in order. Defaults to every guide. */
  slugs?: string[]
  headingLevel?: 'h2' | 'h3'
}>()

const items = computed(() => props.slugs ? guides.filter((g) => props.slugs!.includes(g.slug)).sort((a, b) => props.slugs!.indexOf(a.slug) - props.slugs!.indexOf(b.slug)) : guides)
</script>

<template>
  <ul class="grid gap-4 sm:grid-cols-2" :class="items.length > 3 ? 'lg:grid-cols-4' : 'lg:grid-cols-3'">
    <li v-for="guide in items" :key="guide.slug">
      <NuxtLink :to="`/guides/${guide.slug}/`" class="group flex h-full flex-col rounded-2xl bg-white/[0.03] p-5 ring-1 ring-white/[0.07] transition-colors duration-300 hover:bg-white/[0.06]">
        <div class="flex items-start justify-between gap-3">
          <component :is="headingLevel ?? 'h3'" class="text-pretty font-medium tracking-tight text-white">{{ guide.title }}</component>
          <svg viewBox="0 0 16 16" class="mt-1 size-3.5 shrink-0 text-ink-400 transition-transform duration-300 group-hover:translate-x-0.5 group-hover:text-white" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M6 3l5 5-5 5" /></svg>
        </div>
        <p class="mt-2 text-pretty text-sm leading-relaxed text-ink-400">{{ guide.summary }}</p>
      </NuxtLink>
    </li>
  </ul>
</template>
