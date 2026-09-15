<script setup lang="ts">
withDefaults(defineProps<{ tone?: 'neutral' | 'accent' | 'soon' }>(), { tone: 'neutral' })
</script>

<template>
  <span
    class="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-medium uppercase tracking-[0.08em]"
    :class="{
      'bg-white/[0.06] text-ink-300 ring-1 ring-white/10 ring-inset': tone === 'neutral',
      'bg-[rgb(var(--rgb-primary)/0.14)] text-[rgb(var(--rgb-primary))] ring-1 ring-[rgb(var(--rgb-primary)/0.3)] ring-inset': tone === 'accent',
      'bg-amber-400/10 text-amber-300 ring-1 ring-amber-300/25 ring-inset': tone === 'soon',
    }"
  >
    <slot />
  </span>
</template>
