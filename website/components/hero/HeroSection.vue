<script setup lang="ts">
import { keys } from '~/data/keyboard-layout'
import { swatches } from '~/data/lighting'
import type { EffectId } from '~/data/lighting'
import type { LightingState } from '~/composables/useKeyboardRGB'

const stage = shallowRef<HTMLElement | null>(null)
useMouseParallax(stage, 1)
const { held, last, presses } = usePhysicalKeys(stage)
const reduced = useReducedMotion()

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

// The last keys pressed, on the real keyboard or on the page, shown as a strip of keycaps.
// Kept in memory only, and only the last few.
const history = ref<Array<{ n: number; label: string }>>([])
let n = 0
function remember(id: string | null) {
  const key = keys.find((k) => k.id === id)
  if (!key) return
  history.value = [...history.value, { n: n++, label: key.mac ?? (key.label || 'Space') }].slice(-8)
}
watch(presses, () => remember(last.value))

// Facts about the app, floating around the keyboard on wide screens.
const callouts = [
  { id: 'lighting', title: '20 lighting modes', body: 'Color, brightness, speed', icon: 'M12 3v2M12 19v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M3 12h2M19 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z', position: 'left-[-19%] top-[26%]', depth: 1.4 },
  { id: 'screen', title: '128 × 128 screen', body: 'Pictures, GIFs and the clock', icon: 'M4 5h16v12H4zM4 14l4-4 4 4 3-3 5 5', position: 'right-[-19%] top-[-3%]', depth: 1.8 },
  { id: 'settings', title: 'Every setting', body: 'Key response, sleep, Fn', icon: 'M4 7h10M18 7h2M4 17h4M12 17h8M14 5v4M8 15v4', position: 'right-[-21%] bottom-[16%]', depth: 1.2 },
  { id: 'mac', title: 'No drivers', body: 'Apple silicon and Intel', icon: 'M12 3l7 3v6c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V6zM9 12l2 2 4-4', position: 'left-[-15%] bottom-[2%]', depth: 1.6 },
] as const
</script>

<template>
  <section id="top" class="relative isolate overflow-hidden" :style="{ '--rgb-primary': lighting.color }" aria-labelledby="hero-title">
    <!-- Ambient light, tinted by the keyboard color -->
    <div aria-hidden="true" class="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[1200px] overflow-hidden">
      <div class="absolute left-1/2 top-[520px] h-[600px] w-[1200px] -translate-x-1/2 rounded-full blur-2xl transition-[background] duration-700" :style="{ background: `radial-gradient(closest-side, rgb(${lighting.color} / calc(0.32 * var(--glow))), transparent)` }" />
      <div class="absolute left-[66%] top-[660px] h-[420px] w-[700px] -translate-x-1/2 rounded-full bg-[radial-gradient(closest-side,rgb(34_211_238/calc(0.14*var(--glow))),transparent)] blur-2xl" />
      <div class="absolute inset-0 bg-[radial-gradient(ellipse_at_top,rgba(255,255,255,0.07),transparent_55%)]" />
      <div class="grid-bg absolute inset-0 [mask-image:radial-gradient(ellipse_at_top,black_25%,transparent_72%)]" />
    </div>

    <div class="frame !pt-10 !pb-8 sm:!pt-14 sm:!pb-12">
    <div class="mx-auto flex max-w-4xl flex-col items-center text-center">
      <!-- Hook -->
      <a href="#features" class="animate-fade-up group inline-flex items-center gap-2 rounded-full bg-white/[0.05] py-1 pr-3 pl-1 text-[13px] text-ink-200 ring-1 ring-white/10 transition-colors [animation-delay:40ms] hover:bg-white/[0.09]">
        <span class="rounded-full bg-[rgb(var(--rgb-primary))] px-2 py-0.5 text-[11px] font-semibold text-ink-950 transition-colors duration-700">Free</span>
        No official Mac app? Now there is.
        <svg viewBox="0 0 16 16" class="size-3 text-ink-400 transition-transform group-hover:translate-x-0.5" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><path d="M6 3l5 5-5 5" /></svg>
      </a>

      <h1 id="hero-title" class="animate-fade-up mt-5 text-balance text-[2.9rem] leading-[1] font-semibold tracking-[-0.045em] text-white [animation-delay:100ms] sm:text-6xl lg:text-[4.75rem]">
        Finally, a Mac app<br>
        for your <span class="hero-gradient bg-clip-text text-transparent" :style="{ '--hero-a': lighting.color }">F75 Max</span>
      </h1>

      <p class="animate-fade-up mt-5 max-w-3xl text-pretty text-lg leading-relaxed text-ink-300 [animation-delay:180ms]">
        AULA doesn’t make software for Mac, so AULA Studio does. Change the lighting, put GIFs on the screen, sync the clock and tune every setting, in one native app.
      </p>

      <div class="animate-fade-up mt-7 flex w-full flex-col items-center gap-3 [animation-delay:240ms] sm:w-auto sm:flex-row">
        <DownloadButton class="w-full sm:w-auto" />
        <UiButton href="#features" variant="secondary" size="lg" class="w-full sm:w-auto">
          See what it does
          <svg viewBox="0 0 16 16" class="size-3.5 opacity-60" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 3v9M4.5 8.5L8 12l3.5-3.5" /></svg>
        </UiButton>
      </div>
      <DownloadMeta class="animate-fade-up mt-4 text-center [animation-delay:270ms]" />

      <!-- Spec chips: which links do what -->
      <ul class="animate-fade-up meta mt-5 flex flex-wrap items-center justify-center gap-x-3 gap-y-1.5 [animation-delay:300ms]" aria-label="Connections">
        <li class="flex items-center gap-1.5 text-ink-200"><span class="size-1.5 rounded-full bg-emerald-400" aria-hidden="true" />USB-C <span class="text-ink-400">· configure</span></li>
        <li class="text-ink-500" aria-hidden="true">/</li>
        <li class="flex items-center gap-1.5 text-ink-200"><span class="size-1.5 rounded-full bg-sky-400" aria-hidden="true" />Bluetooth <span class="text-ink-400">· keys, battery</span></li>
        <li class="text-ink-500" aria-hidden="true">/</li>
        <li class="flex items-center gap-1.5 text-ink-200"><span class="size-1.5 rounded-full bg-amber-400" aria-hidden="true" />2.4G <span class="text-ink-400">· soon</span></li>
        <li class="hidden text-ink-500 sm:block" aria-hidden="true">/</li>
        <li class="hidden sm:block">MIT · Not affiliated with AULA</li>
      </ul>
    </div>

    <!-- Live keyboard -->
    <div ref="stage" class="relative mx-auto mt-6 max-w-[56rem]">
      <!-- Typing strip: the last keys pressed -->
      <div class="animate-fade-up mb-5 flex h-9 items-center justify-center [animation-delay:300ms]" aria-hidden="true">
        <TransitionGroup v-if="history.length" tag="div" name="cap" class="flex items-center gap-1.5">
          <span
            v-for="(item, i) in history"
            :key="item.n"
            data-theme="dark"
            class="grid h-8 min-w-8 place-items-center rounded-lg bg-gradient-to-b from-ink-600 to-ink-700 px-2 text-[13px] font-medium text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.1),0_3px_0_#0b0b0d]"
            :style="{ opacity: 0.35 + ((i + 1) / history.length) * 0.65, boxShadow: i === history.length - 1 ? `inset 0 1px 0 rgba(255,255,255,0.1), 0 3px 0 #0b0b0d, 0 0 18px rgb(${lighting.color} / 0.7)` : undefined }"
          >{{ item.label }}</span>
        </TransitionGroup>
        <p v-else class="flex items-center gap-2.5 text-sm text-ink-300">
          <span class="relative flex size-2"><span class="absolute inline-flex size-full animate-ping rounded-full bg-[rgb(var(--rgb-primary))] opacity-60" /><span class="relative inline-flex size-2 rounded-full bg-[rgb(var(--rgb-primary))]" /></span>
          <template v-if="finePointer">Go ahead, type something. <span class="hidden text-ink-400 sm:inline">Your keys light up here.</span></template>
          <template v-else>Tap the keys to light them up.</template>
        </p>
      </div>

      <div class="animate-fade-up relative [animation-delay:360ms]">
        <div class="hero-keyboard">
          <KeyboardVisual
            :lighting="lighting"
            screen="clock"
            interactive
            eager
            :active-ids="held"
            label="Interactive AULA F75 Max keyboard. Type on your keyboard or click keys to light them up."
            @select="remember($event.id)"
          />
        </div>

        <!-- Floating facts (wide screens) -->
        <div
          v-for="(callout, i) in callouts"
          :key="callout.id"
          class="callout glass pointer-events-none absolute hidden items-center gap-3 rounded-2xl py-2.5 pr-4 pl-2.5 shadow-[0_0_0_1px_var(--line-strong),0_20px_50px_-15px_var(--shadow-soft)] xl:flex"
          :class="[callout.position, !reduced && 'callout--float']"
          :style="{ '--depth': callout.depth, animationDelay: `${i * -1.7}s` }"
          aria-hidden="true"
        >
          <span class="grid size-9 place-items-center rounded-xl bg-[rgb(var(--rgb-primary)/0.16)] text-[rgb(var(--rgb-primary))] ring-1 ring-inset ring-[rgb(var(--rgb-primary)/0.35)] transition-colors duration-700">
            <svg viewBox="0 0 24 24" class="size-[18px]" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path :d="callout.icon" /></svg>
          </span>
          <span class="text-left">
            <span class="block text-[13px] font-semibold text-white">{{ callout.title }}</span>
            <span class="block text-xs text-ink-400">{{ callout.body }}</span>
          </span>
        </div>

        <div aria-hidden="true" class="absolute inset-x-[10%] -bottom-10 -z-10 h-32 rounded-full blur-[70px] transition-[background-color] duration-700" :style="{ backgroundColor: `rgb(${lighting.color} / 0.4)` }" />
      </div>

      <!-- Controls -->
      <div class="animate-fade-up mt-8 flex flex-col items-center gap-4 [animation-delay:440ms]">
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
              :style="{ backgroundColor: `rgb(${swatch.rgb})`, boxShadow: lighting.color === swatch.rgb ? `0 0 0 2px var(--color-ink-900), 0 0 0 3.5px rgb(${swatch.rgb}), 0 0 14px rgb(${swatch.rgb} / 0.8)` : 'inset 0 0 0 1px rgb(255 255 255 / 0.15)' }"
              @click="lighting.color = swatch.rgb"
            />
          </div>
        </div>
        <!-- The same facts, for narrow screens -->
        <ul class="flex flex-wrap justify-center gap-x-4 gap-y-2 text-[13px] text-ink-400 xl:hidden">
          <li v-for="callout in callouts" :key="callout.id" class="flex items-center gap-1.5">
            <svg viewBox="0 0 24 24" class="size-3.5 text-[rgb(var(--rgb-primary))]" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path :d="callout.icon" /></svg>
            {{ callout.title }}
          </li>
        </ul>
        <p class="sr-only">{{ callouts.map((c) => `${c.title}: ${c.body}.`).join(' ') }}</p>
      </div>
    </div>
    </div>
  </section>
</template>

<style scoped>
.hero-gradient {
  background-image: linear-gradient(100deg, rgb(var(--hero-a)) 0%, rgb(34 211 238) 45%, rgb(236 72 153) 80%, rgb(var(--hero-a)) 100%);
  background-size: 220% 100%;
  animation: hero-shine 9s linear infinite;
}
:global([data-theme="light"]) .hero-gradient {
  background-image: linear-gradient(100deg, rgb(var(--hero-a)) 0%, rgb(8 145 178) 45%, rgb(219 39 119) 80%, rgb(var(--hero-a)) 100%);
}
@keyframes hero-shine {
  to { background-position: -220% 0; }
}

.hero-keyboard {
  transform: perspective(2200px) rotateX(calc(8deg + var(--py, 0) * -4deg)) rotateY(calc(var(--px, 0) * 4deg));
  transition: transform 0.6s var(--ease-out-quint);
  will-change: transform;
}

/* Callouts drift with the pointer at different depths, and bob gently. */
.callout {
  translate: calc(var(--px, 0) * var(--depth) * -14px) calc(var(--py, 0) * var(--depth) * -10px);
  transition: translate 0.6s var(--ease-out-quint);
}
.callout--float {
  animation: callout-float 6s ease-in-out infinite;
}
@keyframes callout-float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}

.cap-enter-active { transition: transform 0.25s var(--ease-spring), opacity 0.25s ease; }
.cap-enter-from { transform: translateY(8px) scale(0.8); opacity: 0; }
.cap-leave-active { position: absolute; opacity: 0; transition: opacity 0.15s ease; }
.cap-move { transition: transform 0.25s var(--ease-out-quint); }

@media (prefers-reduced-motion: reduce), (hover: none) {
  .hero-keyboard { transform: perspective(2200px) rotateX(6deg); }
  .callout { translate: none; }
}
@media (prefers-reduced-motion: reduce) {
  .hero-gradient { animation: none; background-position: 0 0; }
}
</style>
