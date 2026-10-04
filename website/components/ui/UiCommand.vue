<script setup lang="ts">
import { useClipboard } from '@vueuse/core'

/** A terminal command in a pill, with a copy button. */
const props = defineProps<{ command: string; label?: string }>()
const { copy, copied, isSupported } = useClipboard({ copiedDuring: 1600 })
</script>

<template>
  <div class="flex min-w-0 items-center gap-2 rounded-[10px] border border-[var(--line-strong)] bg-ink-850 py-1.5 pr-1.5 pl-3.5 font-mono text-[13px] text-ink-100">
    <span class="select-none text-[rgb(var(--rgb-primary))]" aria-hidden="true">$</span>
    <code class="min-w-0 flex-1 overflow-x-auto whitespace-nowrap [scrollbar-width:none]" :aria-label="label">{{ command }}</code>
    <button
      v-if="isSupported"
      type="button"
      class="grid size-8 shrink-0 place-items-center rounded-md text-ink-400 transition-colors hover:bg-white/[0.07] hover:text-white"
      :aria-label="copied ? 'Copied' : 'Copy command'"
      @click="copy(props.command)"
    >
      <svg v-if="!copied" viewBox="0 0 16 16" class="size-4" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round" aria-hidden="true"><rect x="5.5" y="5.5" width="8" height="8" rx="1.5" /><path d="M10.5 3.5v-.2A1.3 1.3 0 0 0 9.2 2H3.8A1.3 1.3 0 0 0 2.5 3.3v5.4A1.3 1.3 0 0 0 3.8 10h.2" /></svg>
      <svg v-else viewBox="0 0 16 16" class="size-4 text-emerald-500" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 8.5l3 3 6-7" /></svg>
    </button>
  </div>
</template>
