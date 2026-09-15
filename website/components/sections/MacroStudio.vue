<script setup lang="ts">
import { macroSteps } from '~/data/content'

const root = shallowRef<HTMLElement | null>(null)
const seen = useInViewOnce(root)
const reduced = useReducedMotion()
const active = ref(-1)
let timer: ReturnType<typeof setInterval> | undefined

function play() {
  clearInterval(timer)
  if (reduced.value) { active.value = macroSteps.length - 1; return }
  active.value = -1
  timer = setInterval(() => {
    active.value++
    if (active.value >= macroSteps.length - 1) clearInterval(timer)
  }, 480)
}

watch(seen, (visible) => visible && play())
onBeforeUnmount(() => clearInterval(timer))
</script>

<template>
  <section id="macros" ref="root" class="relative px-5 py-14 sm:px-8 sm:py-24" style="--rgb-primary: 236 72 153" aria-labelledby="macros-title">
    <div class="mx-auto max-w-6xl">
      <div v-reveal>
        <UiSectionHeading id="macros-title" soon eyebrow="Macro Studio" title="Automate the repetitive." description="Build sequences of keys, delays and text on a timeline. Macros are planned for a future release; the timeline below previews the design." />
      </div>

      <div v-reveal class="relative mx-auto mt-12 max-w-5xl">
        <UiGlow :intensity="0.45" />
        <div class="glass rounded-3xl p-5 ring-1 ring-white/[0.08] sm:p-8">
          <div class="flex flex-wrap items-center justify-between gap-4">
            <div>
              <p class="text-sm text-ink-400">Example macro</p>
              <h3 class="text-xl font-semibold tracking-tight text-white">Format document</h3>
            </div>
            <UiButton variant="secondary" @click="play">
              <svg viewBox="0 0 12 12" class="size-3" fill="currentColor" aria-hidden="true"><path d="M3 1.5v9l7-4.5z" /></svg>
              Replay
            </UiButton>
          </div>

          <div class="mt-8 overflow-x-auto pb-2 [scrollbar-width:thin]">
            <ol class="relative mx-auto flex w-max items-stretch gap-3" aria-label="Macro steps">
              <li
                v-for="(step, i) in macroSteps"
                :key="step.label"
                class="relative flex w-32 flex-col gap-3 rounded-2xl p-4 ring-1 ring-inset transition-all duration-500"
                :class="i <= active ? 'bg-white/[0.07] ring-[rgb(236_72_153/0.45)]' : 'bg-white/[0.02] ring-white/[0.06] opacity-50'"
                :aria-current="i === active ? 'step' : undefined"
              >
                <span
                  class="grid h-11 place-items-center rounded-xl text-lg font-medium transition-all duration-500"
                  :class="[
                    step.type === 'delay' ? 'bg-transparent text-sm text-ink-300 ring-1 ring-white/15' : 'bg-gradient-to-b from-ink-600 to-ink-700 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.1),0_3px_0_#111]',
                    i === active && step.type !== 'delay' && 'shadow-[0_0_0_2px_rgb(236_72_153),0_0_24px_rgb(236_72_153/0.6)]',
                  ]"
                >{{ step.key }}</span>
                <span class="text-[13px] leading-snug text-ink-300">{{ step.label }}</span>
                <span class="font-mono text-[10px] uppercase tracking-wider text-ink-400">{{ step.type }}</span>
              </li>
            </ol>
            <div class="mt-5 h-1 rounded-full bg-white/[0.06]" aria-hidden="true">
              <div class="h-full rounded-full bg-[rgb(236_72_153)] shadow-[0_0_12px_rgb(236_72_153)] transition-[width] duration-500 ease-out" :style="{ width: `${((active + 1) / macroSteps.length) * 100}%` }" />
            </div>
          </div>

          <div class="mt-6">
            <UiDemoNote>Preview of a planned feature. Nothing here is recorded or sent to a keyboard.</UiDemoNote>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
