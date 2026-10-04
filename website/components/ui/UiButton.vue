<script setup lang="ts">
const props = withDefaults(defineProps<{
  href?: string
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'md' | 'lg'
  external?: boolean
}>(), { variant: 'primary', size: 'md', external: false })

const classes = computed(() => [
  'group relative inline-flex select-none items-center justify-center gap-2 rounded-[10px] font-medium tracking-tight',
  'transition-[transform,background-color,box-shadow,color] duration-200 ease-out active:scale-[0.97]',
  props.size === 'lg' ? 'h-12 px-6 text-[15px]' : 'h-10 px-4 text-sm',
  props.variant === 'primary' && 'bg-white text-ink-950 shadow-[0_0_0_1px_rgba(255,255,255,0.1),0_8px_30px_-8px_rgb(var(--rgb-primary)/0.6)] hover:bg-ink-100 hover:shadow-[0_0_0_1px_rgba(255,255,255,0.2),0_10px_40px_-6px_rgb(var(--rgb-primary)/0.8)] in-data-[theme=light]:shadow-[0_1px_2px_rgba(15,23,42,0.25),0_8px_24px_-10px_rgb(var(--rgb-primary)/0.6)]',
  props.variant === 'secondary' && 'bg-white/[0.06] text-white ring-1 ring-white/10 ring-inset hover:bg-white/10 in-data-[theme=light]:bg-ink-900 in-data-[theme=light]:ring-[var(--line-strong)] in-data-[theme=light]:hover:bg-ink-850',
  props.variant === 'ghost' && 'text-ink-300 hover:text-white',
])
</script>

<template>
  <a
    v-if="href"
    :href="href"
    :class="classes"
    :target="external ? '_blank' : undefined"
    :rel="external ? 'noopener noreferrer' : undefined"
  >
    <slot />
  </a>
  <button v-else type="button" :class="classes">
    <slot />
  </button>
</template>
