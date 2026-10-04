<script setup lang="ts">
import { knobModes } from '~/data/content'

type ModeId = (typeof knobModes)[number]['id']
const modeId = ref<ModeId>('volume')
const mode = computed(() => knobModes.find((m) => m.id === modeId.value)!)
const values = reactive(Object.fromEntries(knobModes.map((m) => [m.id, m.start])) as Record<ModeId, number>)
const value = computed({ get: () => values[modeId.value], set: (v: number) => (values[modeId.value] = v) })
const options = knobModes.map((m) => ({ value: m.id, label: m.name }))
</script>

<template>
  <section id="knob" class="section" style="--rgb-primary: 139 92 246" aria-labelledby="knob-title">
    <div class="frame grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
      <div v-reveal>
        <UiSectionHeading id="knob-title" align="left" eyebrow="The knob" title="Turn to take control." description="The F75 Max’s knob controls volume out of the box, and AULA Studio shows every turn live. Custom knob actions, like brightness, zoom or scrubbing a timeline, are ideas for later." />
        <div class="mt-8">
          <UiChoice v-model="modeId" :options="options" label="Knob action" />
        </div>
        <p class="mt-5 flex items-center gap-2 text-sm" aria-live="polite">
          <UiBadge :tone="mode.available ? 'accent' : 'soon'">{{ mode.available ? 'Works today' : 'Preview' }}</UiBadge>
          <span class="text-ink-400">{{ mode.available ? 'Handled by the keyboard itself.' : 'Not available yet.' }}</span>
        </p>
      </div>

      <div v-reveal class="relative">
        <UiGlow :intensity="0.5" />
        <KeyboardKnob v-model="value" :min="mode.min" :max="mode.max" :step="1" :unit="mode.unit" :label="mode.name" />
        <p class="mt-5 text-center text-sm text-ink-400">Drag up or down, scroll, or use the arrow keys.</p>
      </div>
    </div>
  </section>
</template>
