<script setup lang="ts">
import type { KeyDef } from '~/data/keyboard-layout'

const props = defineProps<{
  keyDef: KeyDef
  /** Current action shown for the key (preview data). */
  action?: { action: string; kind: string }
  options?: readonly string[]
}>()

defineEmits<{ close: [] }>()

const current = computed(() => props.action ?? { action: props.keyDef.mac ?? (props.keyDef.label || 'Space'), kind: 'Default' })
const selectedOption = ref(props.options?.[0] ?? '')
watch(() => props.keyDef.id, () => (selectedOption.value = props.options?.[0] ?? ''))
</script>

<template>
  <aside class="glass w-full rounded-3xl p-5 shadow-[0_0_0_1px_var(--line-strong),0_30px_80px_-20px_var(--shadow-soft)] sm:p-6" aria-live="polite">
    <div class="flex items-start justify-between gap-4">
      <div class="flex items-center gap-4">
        <span data-theme="dark" class="grid size-14 place-items-center rounded-2xl bg-gradient-to-b from-ink-600 to-ink-700 text-xl font-medium text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.1),0_4px_0_#111,0_0_24px_rgb(var(--rgb-primary)/0.35)]">
          {{ keyDef.mac ?? (keyDef.label || '␣') }}
        </span>
        <div>
          <p class="text-lg font-semibold tracking-tight text-white">{{ keyDef.usage }}</p>
          <p class="font-mono text-xs text-ink-400">key id · {{ keyDef.id }}</p>
        </div>
      </div>
      <button type="button" class="grid size-8 place-items-center rounded-full text-ink-400 transition hover:bg-white/10 hover:text-white" aria-label="Close inspector" @click="$emit('close')">
        <svg viewBox="0 0 12 12" class="size-3" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M2 2l8 8M10 2l-8 8" /></svg>
      </button>
    </div>

    <dl class="mt-5 grid grid-cols-2 gap-3 text-sm">
      <div class="rounded-2xl bg-white/[0.04] p-3 ring-1 ring-white/[0.06]">
        <dt class="text-ink-400">Assigned action</dt>
        <dd class="mt-1 font-medium text-white">{{ current.action }}</dd>
      </div>
      <div class="rounded-2xl bg-white/[0.04] p-3 ring-1 ring-white/[0.06]">
        <dt class="text-ink-400">Type</dt>
        <dd class="mt-1 font-medium text-white">{{ current.kind }}</dd>
      </div>
    </dl>

    <div v-if="options?.length" class="mt-5">
      <div class="flex items-center justify-between">
        <p class="text-sm font-medium text-ink-200">Change to</p>
        <UiBadge tone="soon">Preview</UiBadge>
      </div>
      <div class="mt-3 flex flex-wrap gap-2" role="radiogroup" aria-label="Action type">
        <button
          v-for="option in options"
          :key="option"
          type="button"
          role="radio"
          :aria-checked="selectedOption === option"
          class="rounded-full px-3.5 py-1.5 text-sm transition"
          :class="selectedOption === option ? 'bg-white text-ink-950' : 'bg-white/[0.06] text-ink-200 ring-1 ring-white/10 hover:bg-white/10'"
          @click="selectedOption = option"
        >
          {{ option }}
        </button>
      </div>
      <p class="mt-4 text-xs leading-relaxed text-ink-400">Key remapping is in development. This panel previews the planned design and doesn’t change a real keyboard.</p>
    </div>
  </aside>
</template>
