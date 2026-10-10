<script setup lang="ts">
withDefaults(defineProps<{
  eyebrow?: string
  title: string
  description?: string
  /** Mono caption on the right, like a spec sheet: "20 effects · 128×128". Hidden on narrow screens. */
  meta?: string
  align?: 'left' | 'center'
  soon?: boolean
  /** id for the h2, so the section can be aria-labelledby it. */
  id?: string
}>(), { align: 'left', soon: false })
</script>

<template>
  <div class="flex flex-col gap-6" :class="align === 'center' ? 'items-center text-center' : 'lg:flex-row lg:items-end lg:justify-between lg:gap-12'">
    <div class="flex flex-col gap-4" :class="align === 'center' ? 'mx-auto max-w-3xl items-center' : 'max-w-2xl'">
      <div v-if="eyebrow || soon" class="flex flex-wrap items-center gap-2.5" :class="align === 'center' && 'justify-center'">
        <p v-if="eyebrow" class="font-mono text-xs font-medium tracking-tight text-accent">{{ eyebrow }}</p>
        <UiBadge v-if="soon" tone="soon">Coming soon · Preview</UiBadge>
      </div>
      <h2 :id="id" class="text-balance text-[2rem] leading-[1.08] font-semibold tracking-[-0.03em] whitespace-pre-line text-white sm:text-[2.6rem]">
        {{ title }}
      </h2>
      <p v-if="description" class="text-pretty text-lg leading-relaxed text-ink-300">
        {{ description }}
      </p>
    </div>
    <p v-if="meta" class="meta shrink-0 lg:pb-2 lg:text-right">{{ meta }}</p>
  </div>
</template>
