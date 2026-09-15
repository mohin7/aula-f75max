<script setup lang="ts">
import { appSections, type SectionId } from '~/data/app-ui'

const props = defineProps<{ section: SectionId }>()
const item = computed(() => appSections.find((s) => s.id === props.section)!)

const copy: Partial<Record<SectionId, { body: string; href: string }>> = {
  keymap: { body: 'Remap keys to shortcuts, apps and media controls.', href: '#keymap' },
  macros: { body: 'Record sequences of keys, delays and text on a timeline.', href: '#macros' },
  profiles: { body: 'Save lighting and settings together and switch in one click.', href: '#profiles' },
}
</script>

<template>
  <div class="grid h-full min-h-[420px] place-items-center text-center">
    <div class="max-w-xs">
      <span class="mx-auto grid size-14 place-items-center rounded-2xl bg-white/[0.05] text-ink-200 ring-1 ring-inset ring-white/10" aria-hidden="true">
        <svg viewBox="0 0 24 24" class="size-6" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path :d="item.icon" /></svg>
      </span>
      <p class="mt-5 text-lg font-semibold text-white">{{ item.title }} is coming</p>
      <p class="mt-2 text-pretty text-[13px] leading-relaxed text-ink-400">{{ copy[section]?.body }} It isn't in the app yet.</p>
      <a v-if="copy[section]" :href="copy[section]!.href" class="mt-5 inline-flex h-8 items-center rounded-lg bg-white/[0.08] px-3.5 text-xs font-medium text-white ring-1 ring-inset ring-white/10 transition-colors hover:bg-white/[0.14]">See the preview below</a>
    </div>
  </div>
</template>
