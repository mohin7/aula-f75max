<script setup lang="ts">
import { appCard, appLabel } from '~/utils/app-styles'
import { lightingModes } from '~/data/app-ui'
import { swatches } from '~/data/lighting'

const { state, mode, lighting, lightsOff } = useStudioDemo()

const directions = [{ value: 'left', label: '← Left' }, { value: 'right', label: 'Right →' }] as const
const direction = ref<'left' | 'right'>('right')

// Status like the app's: "Sending…" while changes are coalesced, then the keyboard's confirmation.
const status = ref<'idle' | 'sending' | 'applied'>('idle')
let timer: ReturnType<typeof setTimeout> | undefined
watch(() => [state.mode, state.color, state.brightness, state.speed, state.multicolor, direction.value], () => {
  status.value = 'sending'
  clearTimeout(timer)
  timer = setTimeout(() => (status.value = 'applied'), 450)
})
onBeforeUnmount(() => clearTimeout(timer))
</script>

<template>
  <div class="flex flex-col gap-5">
    <AppPageHeader title="Lighting" subtitle="Changes are sent to the keyboard as you make them.">
      <span class="inline-flex h-7 items-center gap-1.5 rounded-full px-2.5 text-[11px] font-medium ring-1 ring-inset transition-colors" :class="status === 'sending' ? 'bg-white/[0.05] text-ink-200 ring-white/10' : 'bg-emerald-400/10 text-ok ring-emerald-500/25'" aria-live="polite">
        <svg v-if="status === 'sending'" viewBox="0 0 16 16" class="size-3 animate-spin" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M8 2a6 6 0 1 0 6 6" /></svg>
        <svg v-else viewBox="0 0 16 16" class="size-3" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M3 8.5l3 3 7-7" /></svg>
        {{ status === 'sending' ? 'Sending…' : status === 'applied' ? 'Keyboard confirmed' : 'In sync' }}
      </span>
    </AppPageHeader>

    <div class="flex flex-col gap-4">
      <div class="flex min-w-0 flex-col gap-4">
        <div :class="appCard" class="p-3 @md:p-4">
          <KeyboardVisual class="mx-auto max-w-[34rem]" :lighting="lighting" :dark="lightsOff" screen="clock" interactive label="Lighting preview" />
        </div>

        <div>
          <p :class="appLabel">Effect</p>
          <div class="mt-2 grid grid-cols-2 gap-1.5 @md:grid-cols-4 @3xl:grid-cols-5" role="radiogroup" aria-label="Lighting mode">
            <button
              v-for="item in lightingModes"
              :key="item.id"
              type="button"
              role="radio"
              :aria-checked="state.mode === item.id"
              class="truncate rounded-lg px-2.5 py-2 text-left text-xs transition-colors duration-150"
              :class="state.mode === item.id ? 'bg-[rgb(var(--rgb-primary)/0.2)] text-white ring-1 ring-inset ring-[rgb(var(--rgb-primary)/0.6)]' : 'bg-white/[0.03] text-ink-200 ring-1 ring-inset ring-white/[0.06] hover:bg-white/[0.07]'"
              @click="state.mode = item.id"
            >
              {{ item.name }}
            </button>
          </div>
        </div>
      </div>

      <div :class="appCard" class="grid gap-5 p-4 @xl:grid-cols-2 @xl:gap-x-8" :aria-disabled="lightsOff">
        <div :class="lightsOff && 'pointer-events-none opacity-40'">
          <p :class="appLabel">Color</p>
          <div class="mt-2.5 flex flex-wrap gap-2" role="radiogroup" aria-label="Color">
            <button
              v-for="swatch in swatches"
              :key="swatch.rgb"
              type="button"
              role="radio"
              :aria-checked="state.color === swatch.rgb"
              :aria-label="swatch.name"
              class="size-8 rounded-lg transition-transform duration-150 hover:scale-105"
              :style="{ backgroundColor: `rgb(${swatch.rgb})`, boxShadow: state.color === swatch.rgb ? `0 0 0 2px #131317, 0 0 0 3.5px rgb(${swatch.rgb})` : 'inset 0 0 0 1px rgb(255 255 255 / 0.15)' }"
              @click="state.color = swatch.rgb"
            />
          </div>
        </div>
        <div class="-my-2 [&>div]:px-0" :class="lightsOff && 'pointer-events-none opacity-40'">
          <AppSwitch v-model="state.multicolor" label="Multicolor" detail="Use the firmware's rainbow palette" />
        </div>
        <div :class="lightsOff && 'pointer-events-none opacity-40'">
          <AppSlider v-model="state.brightness" label="Brightness" />
        </div>
        <div :class="(lightsOff || state.mode === 'static') && 'pointer-events-none opacity-40'">
          <AppSlider v-model="state.speed" label="Speed" />
        </div>
        <div v-if="mode.direction">
          <p class="mb-2 text-[13px] text-white">Direction</p>
          <AppSegmented v-model="direction" :options="directions" label="Direction" class="w-full" />
        </div>
      </div>
    </div>
  </div>
</template>
