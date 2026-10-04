<script setup lang="ts">
/** Soft ambient light behind content. Purely decorative. */
withDefaults(defineProps<{ color?: string; secondary?: string; intensity?: number }>(), {
  color: 'var(--rgb-primary)',
  secondary: 'var(--rgb-secondary)',
  intensity: 1,
})
</script>

<template>
  <div aria-hidden="true" class="pointer-events-none absolute inset-0 -z-10">
    <div
      class="absolute left-1/2 top-1/2 h-[60%] w-[70%] -translate-x-[60%] -translate-y-1/2 rounded-full blur-[120px] transition-[background-color] duration-700"
      :style="{ backgroundColor: `rgb(${color} / calc(${0.28 * intensity} * var(--glow)))` }"
    />
    <div
      class="absolute left-1/2 top-1/2 h-[45%] w-[50%] -translate-x-[10%] -translate-y-[30%] rounded-full blur-[120px] transition-[background-color] duration-700"
      :style="{ backgroundColor: `rgb(${secondary} / calc(${0.18 * intensity} * var(--glow)))` }"
    />
  </div>
</template>
