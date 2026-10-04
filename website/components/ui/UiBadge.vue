<script setup lang="ts">
withDefaults(defineProps<{ tone?: 'neutral' | 'accent' | 'soon' }>(), { tone: 'neutral' })
</script>

<template>
  <span
    class="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 font-mono text-[11px] font-medium tracking-tight"
    :class="{
      'bg-white/[0.06] text-ink-300 ring-1 ring-white/10 ring-inset': tone === 'neutral',
      'bg-[rgb(var(--rgb-primary)/0.14)] text-[rgb(var(--rgb-primary))] ring-1 ring-[rgb(var(--rgb-primary)/0.3)] ring-inset': tone === 'accent',
      'bg-amber-400/10 text-amber-300 ring-1 ring-amber-300/25 ring-inset in-data-[theme=light]:bg-amber-500/10 in-data-[theme=light]:text-amber-700 in-data-[theme=light]:ring-amber-600/25': tone === 'soon',
    }"
  >
    <slot />
  </span>
</template>
