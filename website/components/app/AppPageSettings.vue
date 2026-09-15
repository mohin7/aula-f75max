<script setup lang="ts">
import { appCard, appLabel } from '~/utils/app-styles'
import { responseLevels, sleepOptions } from '~/data/app-ui'

const { state } = useStudioDemo()
const now = useLiveClock()
const clock = computed(() => now.value?.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', second: '2-digit', hour12: state.twelveHour }) ?? '–')

const levels = [1, 2, 3, 4, 5].map((n) => ({ value: n, label: String(n) }))
const sleeps = sleepOptions.map((s) => ({ value: s as string, label: s }))
const formats = [{ value: '12', label: '12-hour' }, { value: '24', label: '24-hour' }] as const
const format = computed({ get: () => (state.twelveHour ? '12' : '24'), set: (v: string) => (state.twelveHour = v === '12') })

const synced = ref(false)
function sync() {
  synced.value = true
}
watch(() => state.twelveHour, () => (synced.value = false))
</script>

<template>
  <div class="flex flex-col gap-5">
    <AppPageHeader title="Settings" />

    <section>
      <h4 :class="appLabel" class="mb-2 px-1">Keyboard</h4>
      <div :class="appCard" class="divide-y divide-white/[0.06]">
        <div class="flex flex-col gap-2.5 px-4 py-3 @xl:flex-row @xl:items-center @xl:justify-between">
          <div class="min-w-0">
            <p class="text-[13px] text-white">Key response time</p>
            <p class="mt-0.5 text-[11px] text-ink-400">{{ responseLevels[state.responseLevel] }}</p>
          </div>
          <AppSegmented v-model="state.responseLevel" :options="levels" label="Key response level" />
        </div>
        <div class="flex flex-col gap-2.5 px-4 py-3 @xl:flex-row @xl:items-center @xl:justify-between">
          <div class="min-w-0">
            <p class="text-[13px] text-white">Sleep after</p>
            <p class="mt-0.5 text-[11px] text-ink-400">How long the keyboard waits before sleeping on battery.</p>
          </div>
          <AppSegmented v-model="state.sleep" :options="sleeps" label="Sleep timer" />
        </div>
        <AppSwitch v-model="state.disableWindowsKey" label="Disable Windows / ⌘ key" detail="Stops accidental presses while gaming" />
        <AppSwitch v-model="state.disableAltF4" label="Disable Alt + F4" />
        <AppSwitch v-model="state.disableAltTab" label="Disable Alt + Tab" />
        <AppSwitch v-model="state.fnSwitch" label="Fn switch" detail="Swaps the top row between F1–F12 and media keys" />
      </div>
    </section>

    <section>
      <h4 :class="appLabel" class="mb-2 px-1">Time</h4>
      <div :class="appCard" class="divide-y divide-white/[0.06]">
        <div class="flex items-center justify-between gap-4 px-4 py-3">
          <div class="min-w-0">
            <p class="text-[13px] text-white">Keyboard clock</p>
            <p class="mt-0.5 text-[15px] font-semibold text-white tabular-nums">{{ clock }}</p>
          </div>
          <button type="button" class="h-7 shrink-0 rounded-md bg-white/[0.08] px-3 text-xs font-medium text-white ring-1 ring-inset ring-white/10 transition-colors hover:bg-white/[0.14]" @click="sync">
            {{ synced ? 'Synced ✓' : 'Sync now' }}
          </button>
        </div>
        <div class="flex flex-wrap items-center justify-between gap-3 px-4 py-3">
          <p class="text-[13px] text-white">Keyboard clock format</p>
          <AppSegmented v-model="format" :options="formats" label="Keyboard clock format" />
        </div>
        <AppSwitch v-model="state.autoSync" label="Sync automatically" detail="When you plug in the cable, after your Mac wakes, when the time zone changes, and every hour" />
      </div>
    </section>
  </div>
</template>
