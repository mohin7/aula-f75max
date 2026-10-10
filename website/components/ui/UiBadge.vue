<script setup lang="ts">
withDefaults(defineProps<{ tone?: 'neutral' | 'accent' | 'soon' }>(), { tone: 'neutral' })
</script>

<template>
  <span
    class="inline-flex items-center gap-1.5 rounded-md px-2 py-0.5 font-mono text-[11px] font-medium tracking-tight"
    :class="{
      'bg-white/[0.06] text-ink-300 ring-1 ring-white/10 ring-inset': tone === 'neutral',
      'bg-[rgb(var(--rgb-primary)/0.14)] text-accent ring-1 ring-[rgb(var(--rgb-primary)/0.3)] ring-inset': tone === 'accent',
      'bg-amber-400/10 text-warn ring-1 ring-amber-500/30 ring-inset': tone === 'soon',
    }"
  >
    <slot />
  </span>
</template>
