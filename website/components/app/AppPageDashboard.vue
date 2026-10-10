<script setup lang="ts">
import { appCard, appLabel } from '~/utils/app-styles'
import type { KeyDef } from '~/data/keyboard-layout'
import { responseLevels } from '~/data/app-ui'

const { state, mode, lighting, lightsOff } = useStudioDemo()
const now = useLiveClock()
const clock = computed(() => now.value?.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', hour12: state.twelveHour }) ?? '–')

const lastKey = ref<KeyDef | null>(null)

// Example battery reading for the illustration.
const battery = 82
const circumference = 2 * Math.PI * 16

const stats = computed(() => [
  { label: 'Connection', value: 'USB-C', detail: 'Configuration available' },
  { label: 'Keyboard clock', value: clock.value, detail: state.autoSync ? 'Syncs automatically' : 'Manual sync' },
  { label: 'Lighting', value: mode.value.name, detail: lightsOff.value ? 'Lights off' : `Brightness ${state.brightness} of 5` },
  { label: 'Sleep timer', value: state.sleep, detail: 'On battery' },
  { label: 'Key response', value: `Level ${state.responseLevel}`, detail: responseLevels[state.responseLevel]!.split(' · ')[0]! },
  { label: 'Last key', value: lastKey.value?.usage ?? 'Press a key', detail: 'Live from the keyboard' },
])
</script>

<template>
  <div class="flex flex-col gap-5">
    <AppPageHeader title="AULA F75 Max">
      <template #default>
        <div :class="appCard" class="flex items-center gap-3 py-2 pr-4 pl-2">
          <svg viewBox="0 0 40 40" class="size-11 -rotate-90" aria-hidden="true">
            <circle cx="20" cy="20" r="16" fill="none" stroke="rgb(255 255 255 / 0.1)" stroke-width="3.5" />
            <circle cx="20" cy="20" r="16" fill="none" stroke="#34d399" stroke-width="3.5" stroke-linecap="round" :stroke-dasharray="`${(battery / 100) * circumference} ${circumference}`" />
          </svg>
          <div>
            <p class="text-[11px] text-ink-400">Battery</p>
            <p class="text-sm font-semibold text-white tabular-nums">{{ battery }}%</p>
            <p class="text-[11px] text-ok">Charging over USB-C</p>
          </div>
        </div>
      </template>
    </AppPageHeader>

    <div class="-mt-3 flex flex-wrap gap-2 text-[11px]">
      <span class="inline-flex items-center gap-1.5 rounded-full bg-emerald-400/10 px-2 py-0.5 text-ok"><span class="size-1.5 rounded-full bg-emerald-400" aria-hidden="true" />Connected · USB-C</span>
    </div>

    <div :class="appCard" class="p-3 @md:p-5">
      <KeyboardVisual :lighting="lighting" :dark="lightsOff" screen="clock" interactive label="Live keyboard preview" @select="lastKey = $event" />
    </div>

    <div class="grid grid-cols-2 gap-2.5 @2xl:grid-cols-3">
      <div v-for="stat in stats" :key="stat.label" :class="appCard" class="p-3.5">
        <p :class="appLabel">{{ stat.label }}</p>
        <p class="mt-1.5 truncate text-[15px] font-semibold text-white tabular-nums">{{ stat.value }}</p>
        <p class="mt-0.5 truncate text-[11px] text-ink-400">{{ stat.detail }}</p>
      </div>
    </div>
  </div>
</template>
