<script setup lang="ts">
import plexRegular from '@fontsource/ibm-plex-sans/files/ibm-plex-sans-latin-400-normal.woff2?url'
import plexSemibold from '@fontsource/ibm-plex-sans/files/ibm-plex-sans-latin-600-normal.woff2?url'

// The hero text uses these two weights, so load them before the CSS asks for them.
useHead({
  link: [plexRegular, plexSemibold].map((href) => ({ rel: 'preload', as: 'font', type: 'font/woff2', href, crossorigin: 'anonymous' })),
})
</script>

<template>
  <div>
    <a href="#main" class="sr-only z-[200] rounded-full bg-white px-4 py-2 text-sm font-medium text-ink-950 focus:not-sr-only focus:fixed focus:left-4 focus:top-4">Skip to content</a>
    <NuxtPage />
  </div>
</template>
