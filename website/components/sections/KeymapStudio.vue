<script setup lang="ts">
import { keys } from '~/data/keyboard-layout'
import { keymapPresets } from '~/data/content'

const options = ['Shortcut', 'Media', 'App', 'Text', 'Disabled'] as const
const remappable = Object.keys(keymapPresets)
const selectedId = ref('capslock')
const selected = computed(() => keys.find((k) => k.id === selectedId.value)!)

// The demo "types" Caps Lock → ⌘ Space once, when the section comes into view.
const root = shallowRef<HTMLElement | null>(null)
const seen = useInViewOnce(root)
const reduced = useReducedMotion()
const stage = ref(0) // 0 idle · 1 key picked · 2 action applied
watch(seen, (visible) => {
  if (!visible) return
  if (reduced.value) { stage.value = 2; return }
  setTimeout(() => (stage.value = 1), 300)
  setTimeout(() => (stage.value = 2), 1300)
})

const lighting = { effect: 'static', color: '251 146 60', brightness: 1, speed: 3 } as const

function onSelect(key: { id: string }) {
  selectedId.value = key.id
  stage.value = 2
}
</script>

<template>
  <section id="keymap" ref="root" class="section" style="--rgb-primary: 251 146 60" aria-labelledby="keymap-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading id="keymap-title" meta="design preview · not in the app yet" soon eyebrow="Key Mapping" title="Every key can do more" description="Turn Caps Lock into Spotlight, F1 into Play/Pause, F2 into your favorite app. Key mapping is in development; this is an interactive preview of the design." />
      </div>

      <div v-reveal class="mt-12 grid items-start gap-8 lg:grid-cols-[1fr_340px]">
        <div>
          <!-- Remap flow -->
          <div class="mb-8 flex items-center justify-center gap-4 sm:gap-6" aria-live="polite">
            <span data-theme="dark" class="grid h-14 min-w-20 place-items-center rounded-2xl bg-gradient-to-b from-ink-600 to-ink-700 px-4 text-lg font-medium text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.1),0_4px_0_#111] transition-shadow duration-500" :class="stage >= 1 && 'shadow-[0_0_0_2px_rgb(251_146_60),0_4px_0_#111,0_0_30px_rgb(251_146_60/0.5)]'">
              {{ selected.mac ?? (selected.label || 'Space') }}
            </span>
            <svg viewBox="0 0 48 12" class="w-12 text-ink-400 sm:w-16" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
              <path d="M0 6h46M40 1l6 5-6 5" class="transition-[stroke-dashoffset] duration-700" stroke-dasharray="60" :stroke-dashoffset="stage >= 2 ? 0 : 60" />
            </svg>
            <span class="grid h-14 min-w-28 place-items-center rounded-2xl px-4 text-lg font-medium transition-all duration-500" :class="stage >= 2 ? 'bg-white text-ink-950 shadow-[0_10px_40px_-10px_rgb(251_146_60/0.8)]' : 'bg-white/[0.04] text-ink-400 ring-1 ring-white/10'">
              {{ stage >= 2 ? (keymapPresets[selectedId]?.action ?? 'Choose…') : '?' }}
            </span>
          </div>

          <KeyboardVisual
            :lighting="lighting"
            screen="off"
            interactive
            :selected-id="selectedId"
            :highlight-ids="remappable"
            label="Key mapping preview keyboard. Select a key to see its planned mapping."
            @select="onSelect"
          />
          <p class="mt-5 text-center text-sm text-ink-400">Highlighted keys have example mappings. Select any key.</p>
        </div>

        <KeyboardInspector :key-def="selected" :action="stage >= 2 ? keymapPresets[selectedId] : undefined" :options="options" @close="selectedId = 'capslock'" />
      </div>
    </div>
  </section>
</template>
