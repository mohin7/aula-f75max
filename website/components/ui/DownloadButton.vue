<script setup lang="ts">
import { site } from '~/data/site'

/**
 * Downloads the DMG directly: no new tab, no GitHub page in between.
 * `details` adds the version, size and requirements underneath.
 */
withDefaults(defineProps<{ size?: 'md' | 'lg'; details?: boolean; label?: string }>(), {
  size: 'lg',
  details: false,
  label: 'Download for Mac',
})

const links = useSiteLinks()
const meta = computed(() => [links.version && `Version ${links.version}`, links.size, site.requirements].filter(Boolean).join(' · '))
</script>

<template>
  <div class="inline-flex flex-col items-center gap-3">
    <UiButton :href="links.download" :download="links.downloadName" :size="size" class="w-full" :aria-label="`${label}, AULA Studio ${links.version} disk image`">
      <svg viewBox="0 0 16 16" class="size-4 -translate-y-px" fill="currentColor" aria-hidden="true"><path d="M11.2 8.5c0-1.6 1.3-2.4 1.4-2.4-.8-1.1-2-1.3-2.4-1.3-1-.1-2 .6-2.5.6s-1.3-.6-2.2-.6C4.4 4.8 3.3 5.5 2.7 6.5c-1.3 2.2-.3 5.5.9 7.3.6.9 1.3 1.9 2.2 1.8.9 0 1.2-.6 2.3-.6s1.4.6 2.3.6c.9 0 1.5-.9 2.1-1.8.7-1 .9-1.9.9-2-.1 0-1.9-.7-2.2-3.3zM9.5 3.6c.5-.6.8-1.4.7-2.2-.7 0-1.5.5-2 1.1-.4.5-.8 1.3-.7 2.1.8.1 1.5-.4 2-1z" /></svg>
      {{ label }}
      <svg viewBox="0 0 16 16" class="size-3.5 opacity-60 transition-transform duration-200 group-hover:translate-y-0.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 3v9M4.5 8.5L8 12l3.5-3.5" /></svg>
    </UiButton>
    <p v-if="details" class="text-[13px] text-ink-400">{{ meta }}</p>
  </div>
</template>
