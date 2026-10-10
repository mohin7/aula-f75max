<script setup lang="ts">
import { appCard } from '~/utils/app-styles'

const rows = [
  { label: 'Version', value: 'Read from the keyboard' },
  { label: 'Updates', value: 'Not part of AULA Studio' },
]
</script>

<template>
  <div class="flex flex-col gap-5">
    <AppPageHeader title="Firmware" subtitle="Information about the keyboard's firmware." />

    <div :class="appCard" class="flex items-start gap-4 p-5">
      <span class="grid size-11 shrink-0 place-items-center rounded-xl bg-emerald-400/10 text-ok ring-1 ring-inset ring-emerald-400/25" aria-hidden="true">
        <svg viewBox="0 0 24 24" class="size-5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"><path d="M12 3l7 3v6c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V6z" /><path d="M9 12l2 2 4-4" /></svg>
      </span>
      <div>
        <p class="text-[15px] font-semibold text-white">Your keyboard stays safe</p>
        <p class="mt-1 text-pretty text-[13px] leading-relaxed text-ink-300">AULA Studio reads the firmware version but never writes firmware. Every command it sends only changes settings you can change back.</p>
      </div>
    </div>

    <dl :class="appCard" class="divide-y divide-white/[0.06]">
      <div v-for="row in rows" :key="row.label" class="flex items-center justify-between gap-4 px-4 py-3 text-[13px]">
        <dt class="text-ink-300">{{ row.label }}</dt>
        <dd class="text-right text-white">{{ row.value }}</dd>
      </div>
    </dl>
  </div>
</template>
