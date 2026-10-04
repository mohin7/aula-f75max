<script setup lang="ts">
import { site } from '~/data/site'

/** "Version 0.4.0 · 2.9 MB · macOS 15 or later". Placed by the caller, so it can align with whatever it sits under. */
const links = useSiteLinks()
const text = computed(() => [links.version && `Version ${links.version}`, links.size, site.requirements].filter(Boolean).join(' · '))
</script>

<template>
  <p class="meta text-[12px]">{{ text }}</p>
</template>
