<script setup lang="ts">
import { site } from '~/data/site'

/** Download call to action for guide and help pages. */
withDefaults(defineProps<{ title?: string }>(), { title: 'Get AULA Studio for your Mac' })

const asset = useAsset()
</script>

<template>
  <div class="relative isolate overflow-hidden rounded-2xl border border-[var(--line)] bg-ink-900 p-6 sm:p-8">
    <UiGlow :intensity="0.6" />
    <div class="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
      <div class="flex items-center gap-4">
        <img :src="asset('/images/app-icon.webp')" alt="" width="64" height="64" loading="lazy" decoding="async" class="size-16 drop-shadow-[0_14px_28px_rgb(var(--rgb-primary)/0.4)]">
        <div>
          <p class="text-lg font-semibold tracking-tight text-white">{{ title }}</p>
          <p class="mt-1 text-sm text-ink-300">Free and open source, for the {{ site.keyboard }}. No driver needed.</p>
        </div>
      </div>
      <div class="flex flex-col items-start gap-3 md:items-end">
        <DownloadButton />
        <DownloadMeta />
      </div>
    </div>
  </div>
</template>
