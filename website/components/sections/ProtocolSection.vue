<script setup lang="ts">
import { swatches } from '~/data/lighting'
import type { EffectId } from '~/data/lighting'
import type { LightingState } from '~/composables/useKeyboardRGB'

/**
 * The same changes the app makes, written as the developer CLI that ships with it. The command updates
 * as you change the controls. Mode numbers and output wording come from aulactl itself.
 */
const effects: ReadonlyArray<{ value: EffectId; label: string; mode: number; title: string }> = [
  { value: 'wave', label: 'Wave', mode: 10, title: 'Wave' },
  { value: 'spectrum', label: 'Spectrum', mode: 8, title: 'Spectrum Cycle' },
  { value: 'breathing', label: 'Breathing', mode: 7, title: 'Breathing' },
  { value: 'reactive', label: 'Reactive', mode: 2, title: 'Reactive' },
  { value: 'static', label: 'Static', mode: 1, title: 'Static' },
]

const lighting = reactive<LightingState>({ effect: 'wave', color: swatches[1].rgb, brightness: 4, speed: 3 })
const effectModel = computed({ get: () => lighting.effect, set: (v: EffectId) => (lighting.effect = v) })
const current = computed(() => effects.find((e) => e.value === lighting.effect)!)
const hex = computed(() => '#' + lighting.color.split(' ').map((n) => Number(n).toString(16).padStart(2, '0')).join('').toUpperCase())
const command = computed(() => `aulactl rgb ${current.value.mode} '${hex.value}' ${lighting.brightness} ${lighting.speed}`)
</script>

<template>
  <section id="protocol" class="section" :style="{ '--rgb-primary': lighting.color }" aria-labelledby="protocol-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading
          id="protocol-title"
          eyebrow="Under the hood"
          title="Every change goes straight to the keyboard"
          description="No cloud, no middleman. AULA Studio writes over USB-C and waits for the keyboard to acknowledge. The same commands ship as a command-line tool."
          meta="USB-C · 0C45:800A · acknowledged writes"
        />
      </div>

      <div v-reveal class="mt-12 grid gap-4 lg:grid-cols-[1.05fr_1fr]">
        <!-- Controls -->
        <div class="relative flex flex-col gap-6 overflow-hidden rounded-2xl border border-[var(--line)] bg-ink-850 p-5 sm:p-6">
          <UiGlow :intensity="0.5" />
          <div class="rounded-xl bg-ink-900/40 p-1">
            <KeyboardVisual :lighting="lighting" screen="clock" label="Keyboard preview for the lighting controls" />
          </div>

          <div class="flex flex-col gap-5">
            <UiChoice v-model="effectModel" size="sm" :options="effects" label="Lighting effect" />

            <div class="flex items-center gap-3" role="radiogroup" aria-label="Color">
              <span class="meta w-20 shrink-0">color</span>
              <div class="flex gap-2.5">
                <button
                  v-for="swatch in swatches"
                  :key="swatch.rgb"
                  type="button"
                  role="radio"
                  :aria-checked="lighting.color === swatch.rgb"
                  :aria-label="swatch.name"
                  class="size-6 rounded-full transition-transform duration-200 hover:scale-110"
                  :style="{ backgroundColor: `rgb(${swatch.rgb})`, boxShadow: lighting.color === swatch.rgb ? `0 0 0 2px var(--color-ink-850), 0 0 0 3.5px rgb(${swatch.rgb})` : 'inset 0 0 0 1px rgb(128 128 128 / 0.3)' }"
                  @click="lighting.color = swatch.rgb"
                />
              </div>
            </div>

            <label class="flex items-center gap-3">
              <span class="meta w-20 shrink-0">brightness</span>
              <input v-model.number="lighting.brightness" type="range" min="1" max="5" step="1" class="range" aria-label="Brightness, 1 to 5">
              <span class="meta w-8 text-right text-white">{{ lighting.brightness }}/5</span>
            </label>
            <label class="flex items-center gap-3">
              <span class="meta w-20 shrink-0">speed</span>
              <input v-model.number="lighting.speed" type="range" min="1" max="5" step="1" class="range" aria-label="Speed, 1 to 5">
              <span class="meta w-8 text-right text-white">{{ lighting.speed }}/5</span>
            </label>
          </div>
        </div>

        <!-- Terminal: always dark, like a code panel -->
        <div data-theme="dark" class="flex flex-col overflow-hidden rounded-2xl border border-white/10 bg-[#0b0c10] text-white shadow-[0_30px_80px_-40px_var(--shadow-soft)]">
          <div class="flex items-center justify-between border-b border-white/10 px-4 py-3">
            <span class="meta text-[11px]">~/aula-studio · aulactl</span>
            <span class="flex items-center gap-1.5 font-mono text-[10px] tracking-[0.14em] text-[rgb(var(--rgb-primary))]"><span class="size-1.5 animate-pulse rounded-full bg-[rgb(var(--rgb-primary))]" aria-hidden="true" />LIVE</span>
          </div>
          <div class="flex-1 space-y-5 p-5 font-mono text-[13px] leading-6 sm:p-6" aria-live="polite">
            <div>
              <p class="break-all"><span class="text-[rgb(var(--rgb-primary))]">$</span> {{ command }}</p>
              <p class="text-emerald-400">✓ Lighting: {{ current.title }} {{ hex }} brightness {{ lighting.brightness }} speed {{ lighting.speed }}</p>
            </div>
            <div>
              <p><span class="text-[rgb(var(--rgb-primary))]">$</span> aulactl upload pixel-wave.gif fill</p>
              <p class="text-ink-400">251 frame(s), 2009 chunk(s)</p>
              <p class="text-ink-400">&nbsp;&nbsp;keyboard acknowledged 2009/2009 chunks</p>
              <p class="text-emerald-400">✓ Uploaded pixel-wave.gif</p>
            </div>
            <div>
              <p><span class="text-[rgb(var(--rgb-primary))]">$</span> aulactl settings --response 2 --sleep 2</p>
              <p class="text-emerald-400">✓ Settings: response 2, sleep 5 min</p>
            </div>
          </div>
          <div class="meta flex items-center justify-between border-t border-white/10 px-4 py-2.5 text-[11px]">
            <span>aulactl --trace shows every packet</span>
            <span>MIT</span>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.range {
  height: 4px;
  min-width: 0;
  flex: 1;
  cursor: pointer;
  appearance: none;
  border-radius: 999px;
  background: var(--line-strong);
  accent-color: rgb(var(--rgb-primary));
}
.range::-webkit-slider-thumb {
  appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 0 0 2px rgb(var(--rgb-primary)), 0 2px 6px rgb(0 0 0 / 0.3);
}
.range::-moz-range-thumb {
  width: 16px;
  height: 16px;
  border: 0;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 0 0 2px rgb(var(--rgb-primary)), 0 2px 6px rgb(0 0 0 / 0.3);
}
</style>
