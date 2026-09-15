<script setup lang="ts">
import { performance } from '~/data/content'

const icons: Record<string, string> = {
  'Native SwiftUI': 'M4 7l8-4 8 4-8 4zM4 12l8 4 8-4M4 17l8 4 8-4',
  'No drivers': 'M12 3l7 3v6c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V6z',
  'Live sync over USB-C': 'M8 4v5a4 4 0 0 0 8 0V4M12 13v7M9 4h6',
  Universal: 'M5 5h14v14H5zM9 9h6v6H9zM9 2v3M15 2v3M9 19v3M15 19v3M2 9h3M2 15h3M19 9h3M19 15h3',
  'Private by design': 'M6 10V8a6 6 0 0 1 12 0v2M5 10h14v10H5zM12 14v2',
}
</script>

<template>
  <section id="built-for-mac" class="relative px-5 py-12 sm:px-8 sm:py-20" aria-labelledby="mac-title">
    <div class="mx-auto max-w-6xl">
      <h2 id="mac-title" v-reveal class="text-center text-3xl font-semibold tracking-[-0.03em] text-white sm:text-4xl">Light, native and private.</h2>
      <ul class="mt-10 grid grid-cols-2 gap-3 lg:grid-cols-5">
        <li v-for="(item, i) in performance" :key="item.title" v-reveal="i * 50" class="rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/[0.07] sm:p-5" :class="i === 4 && 'col-span-2 lg:col-span-1'">
          <span class="grid size-9 place-items-center rounded-lg bg-white/[0.06] text-white ring-1 ring-white/10" aria-hidden="true">
            <svg viewBox="0 0 24 24" class="size-[18px]" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round"><path :d="icons[item.title]" /></svg>
          </span>
          <h3 class="mt-3 font-semibold tracking-tight text-white sm:mt-4">{{ item.title }}</h3>
          <p class="mt-1 text-pretty text-[13px] leading-relaxed text-ink-400 sm:text-sm">{{ item.body }}</p>
        </li>
      </ul>
    </div>
  </section>
</template>
