<script setup lang="ts">
defineProps<{ title: string; subtitle?: string }>()
</script>

<template>
  <header class="flex flex-wrap items-start justify-between gap-4">
    <div class="min-w-0">
      <h3 class="text-xl font-semibold tracking-tight text-white @md:text-2xl">{{ title }}</h3>
      <p v-if="subtitle" class="mt-1 text-[13px] text-ink-400">{{ subtitle }}</p>
    </div>
    <slot />
  </header>
</template>
