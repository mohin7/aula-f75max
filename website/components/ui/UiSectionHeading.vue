<script setup lang="ts">
withDefaults(defineProps<{
  eyebrow?: string
  title: string
  description?: string
  align?: 'left' | 'center'
  soon?: boolean
  /** id for the h2, so the section can be aria-labelledby it. */
  id?: string
}>(), { align: 'center', soon: false })
</script>

<template>
  <div class="flex flex-col gap-4" :class="align === 'center' ? 'mx-auto max-w-3xl items-center text-center' : 'max-w-2xl'">
    <div v-if="eyebrow || soon" class="flex flex-wrap items-center gap-2" :class="align === 'center' && 'justify-center'">
      <p v-if="eyebrow" class="text-[13px] font-medium tracking-wide text-[rgb(var(--rgb-primary))]">{{ eyebrow }}</p>
      <UiBadge v-if="soon" tone="soon">Coming soon · Preview</UiBadge>
    </div>
    <h2 :id="id" class="text-balance text-4xl leading-[1.02] font-semibold tracking-[-0.035em] whitespace-pre-line text-white sm:text-5xl">
      {{ title }}
    </h2>
    <p v-if="description" class="text-pretty text-lg leading-relaxed text-ink-300">
      {{ description }}
    </p>
  </div>
</template>
