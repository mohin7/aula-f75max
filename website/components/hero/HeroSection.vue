<script setup lang="ts">
import { keys } from '~/data/keyboard-layout'
import { swatches } from '~/data/lighting'
import type { EffectId } from '~/data/lighting'
import type { LightingState } from '~/composables/useKeyboardRGB'

const stage = shallowRef<HTMLElement | null>(null)
useMouseParallax(stage, 1)
const { held, last } = usePhysicalKeys(stage)
// Read after mount, so the server HTML and the first client render match.
const mounted = useMounted()
const pointerQuery = useMediaQuery('(hover: hover) and (pointer: fine)')
const finePointer = computed(() => !mounted.value || pointerQuery.value)

const lighting = reactive<LightingState>({ effect: 'wave', color: swatches[0].rgb, brightness: 4, speed: 3 })
const heroEffects: ReadonlyArray<{ value: EffectId; label: string }> = [
  { value: 'wave', label: 'Wave' },
  { value: 'spectrum', label: 'Spectrum' },
  { value: 'breathing', label: 'Breathing' },
  { value: 'reactive', label: 'Reactive' },
  { value: 'static', label: 'Static' },
]
const effectModel = computed({ get: () => lighting.effect, set: (v: EffectId) => (lighting.effect = v) })

// The last key pressed, on the real keyboard or on the page.
const clicked = ref<string | null>(null)
const lastKey = computed(() => keys.find((k) => k.id === (clicked.value ?? last.value)) ?? null)
watch(last, () => (clicked.value = null))
</script>

<template>
  <section id="top" class="relative isolate overflow-hidden px-5 pt-10 pb-4 sm:px-8 sm:pt-14" :style="{ '--rgb-primary': lighting.color }" aria-labelledby="hero-title">
    <!-- ambient light, tinted by the keyboard color -->
    <div aria-hidden="true" class="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[1200px] overflow-hidden">
      <div class="absolute left-1/2 top-[560px] h-[560px] w-[1200px] -translate-x-1/2 rounded-full blur-2xl transition-[background] duration-700" :style="{ background: `radial-gradient(closest-side, rgb(${lighting.color} / 0.3), transparent)` }" />
      <div class="absolute left-[64%] top-[700px] h-[420px] w-[700px] -translate-x-1/2 rounded-full bg-[radial-gradient(closest-side,rgb(34_211_238/0.16),transparent)] blur-2xl" />
      <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top,rgba(255,255,255,0.06),transparent_55%)]" />
    </div>

    <div class="mx-auto flex max-w-4xl flex-col items-center text-center">
      <p class="animate-fade-up text-[13px] font-medium tracking-wide text-ink-300 [animation-delay:60ms]">
        <span class="mr-2 inline-block size-1.5 -translate-y-px rounded-full bg-emerald-400 shadow-[0_0_10px_#34d399]" aria-hidden="true" />
        A native macOS companion for the AULA F75 Max
      </p>
      <h1 id="hero-title" class="animate-fade-up mt-6 text-balance text-[3.4rem] leading-[0.95] font-semibold tracking-[-0.055em] text-white [animation-delay:120ms] sm:text-7xl lg:text-[5.75rem]">
        Your keyboard.<br>
        <span class="bg-gradient-to-r from-white via-white to-white/55 bg-clip-text text-transparent">Your way.</span>
      </h1>
      <p class="animate-fade-up mt-6 max-w-2xl text-pretty text-lg leading-relaxed text-ink-300 [animation-delay:200ms] sm:text-xl">
        Lighting, the screen, the clock and keyboard settings, all from one native Mac app. Free and open source.
      </p>
      <div class="animate-fade-up mt-8 w-full [animation-delay:260ms] sm:w-auto">
        <DownloadButton details class="w-full sm:w-auto" />
      </div>
    </div>

    <!-- Live keyboard -->
    <div ref="stage" class="relative mx-auto mt-10 max-w-[58rem]">
      <p class="animate-fade-up mb-6 flex h-6 items-center justify-center gap-2 text-sm text-ink-300 [animation-delay:320ms]" aria-hidden="true">
        <template v-if="lastKey">
          <span class="grid h-6 min-w-6 place-items-center rounded-md bg-white/10 px-1.5 text-xs font-medium text-white ring-1 ring-white/15">{{ lastKey.mac ?? (lastKey.label || '␣') }}</span>
          <span>{{ lastKey.usage }}</span>
        </template>
        <template v-else>
          <span class="relative flex size-2"><span class="absolute inline-flex size-full animate-ping rounded-full bg-[rgb(var(--rgb-primary))] opacity-60" /><span class="relative inline-flex size-2 rounded-full bg-[rgb(var(--rgb-primary))]" /></span>
          {{ finePointer ? 'Start typing. The keys light up as you press them.' : 'Tap the keys to light them up.' }}
        </template>
      </p>
      <div class="animate-fade-up [animation-delay:380ms]">
        <div class="hero-keyboard">
          <KeyboardVisual
            :lighting="lighting"
            screen="clock"
            interactive
            eager
            :active-ids="held"
            label="Interactive AULA F75 Max keyboard. Type on your keyboard or click keys to light them up."
            @select="clicked = $event.id"
          />
        </div>
        <div aria-hidden="true" class="absolute inset-x-[10%] -bottom-10 -z-10 h-32 rounded-full blur-[70px] transition-[background-color] duration-700" :style="{ backgroundColor: `rgb(${lighting.color} / 0.4)` }" />
      </div>

      <!-- Controls -->
      <div class="animate-fade-up mt-8 flex flex-col items-center [animation-delay:460ms]">
        <div class="glass flex max-w-full flex-col items-center gap-4 rounded-3xl p-3 ring-1 ring-white/[0.08] sm:flex-row sm:gap-3 sm:rounded-full sm:py-2 sm:pl-2 sm:pr-4">
          <UiChoice v-model="effectModel" size="sm" :options="heroEffects" label="Lighting effect" class="justify-center" />
          <span class="hidden h-6 w-px bg-white/10 sm:block" aria-hidden="true" />
          <div class="flex gap-2.5" role="radiogroup" aria-label="Color">
            <button
              v-for="swatch in swatches"
              :key="swatch.rgb"
              type="button"
              role="radio"
              :aria-checked="lighting.color === swatch.rgb"
              :aria-label="swatch.name"
              class="size-6 rounded-full transition-transform duration-200 hover:scale-110"
              :style="{ backgroundColor: `rgb(${swatch.rgb})`, boxShadow: lighting.color === swatch.rgb ? `0 0 0 2px #0f0f12, 0 0 0 3.5px rgb(${swatch.rgb}), 0 0 14px rgb(${swatch.rgb} / 0.8)` : 'inset 0 0 0 1px rgb(255 255 255 / 0.15)' }"
              @click="lighting.color = swatch.rgb"
            />
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hero-keyboard {
  transform: perspective(2200px) rotateX(calc(8deg + var(--py, 0) * -4deg)) rotateY(calc(var(--px, 0) * 4deg));
  transition: transform 0.6s var(--ease-out-quint);
  will-change: transform;
}
@media (prefers-reduced-motion: reduce), (hover: none) {
  .hero-keyboard { transform: perspective(2200px) rotateX(6deg); }
}
</style>
