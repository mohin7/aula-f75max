<script setup lang="ts">
import { appCard, appLabel } from '~/utils/app-styles'
import { displaySamples, uploadChunks } from '~/data/app-ui'

const asset = useAsset()

type Fit = 'fit' | 'fill' | 'stretch'
const sampleId = ref<(typeof displaySamples)[number]['id']>('wave')
const sample = computed(() => displaySamples.find((s) => s.id === sampleId.value)!)
const fit = ref<Fit>('fill')
const fits = [{ value: 'fit', label: 'Fit' }, { value: 'fill', label: 'Fill' }, { value: 'stretch', label: 'Stretch' }] as const
const objectFit = computed(() => ({ fit: 'contain', fill: 'cover', stretch: 'fill' } as const)[fit.value])

const chunks = computed(() => uploadChunks(sample.value.frames))
const sent = ref(0)
const uploading = ref(false)
const done = ref(false)
let timer: ReturnType<typeof setInterval> | undefined

function upload() {
  clearInterval(timer)
  sent.value = 0
  done.value = false
  uploading.value = true
  // Paced faster than a real upload, so the demo doesn't keep you waiting.
  timer = setInterval(() => {
    sent.value++
    if (sent.value >= chunks.value) {
      clearInterval(timer)
      uploading.value = false
      done.value = true
    }
  }, 2400 / chunks.value)
}

watch([sampleId, fit], () => {
  clearInterval(timer)
  uploading.value = false
  done.value = false
  sent.value = 0
})
onBeforeUnmount(() => clearInterval(timer))
</script>

<template>
  <div class="flex flex-col gap-5">
    <AppPageHeader title="Display" subtitle="Pictures and animated GIFs for the keyboard's 128 × 128 screen." />

    <div class="grid gap-4 @2xl:grid-cols-[minmax(0,260px)_1fr]">
      <div class="flex flex-col items-center gap-3">
        <div class="w-full max-w-[260px] rounded-[20px] bg-gradient-to-b from-[#2a2b30] to-[#151619] p-3 shadow-[inset_0_1px_0_rgba(255,255,255,0.12),0_20px_40px_-12px_rgba(0,0,0,0.8)]">
          <div class="relative aspect-square overflow-hidden rounded-xl bg-black ring-1 ring-white/10">
            <img
              :key="sample.id"
              :src="asset(sample.src)"
              :alt="`Preview of ${sample.name} on the keyboard screen`"
              width="128"
              height="128"
              loading="lazy"
              decoding="async"
              class="size-full"
              :class="sample.pixelated && '[image-rendering:pixelated]'"
              :style="{ objectFit }"
            >
          </div>
        </div>
        <p class="font-mono text-[11px] text-ink-400">128 × 128 · {{ sample.frames }} {{ sample.frames === 1 ? 'frame' : 'frames' }}</p>
      </div>

      <div class="flex min-w-0 flex-col gap-4">
        <div class="grid place-items-center rounded-2xl border border-dashed border-white/15 px-4 py-5 text-center">
          <svg viewBox="0 0 24 24" class="size-6 text-ink-400" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M12 16V4M7 9l5-5 5 5M4 16v3h16v-3" /></svg>
          <p class="mt-2 text-[13px] text-white">Drop an image or GIF here</p>
          <p class="mt-0.5 text-[11px] text-ink-400">PNG, JPEG, GIF, HEIC, WebP, BMP or TIFF</p>
        </div>

        <div>
          <p :class="appLabel">Samples</p>
          <div class="mt-2 grid grid-cols-2 gap-2" role="radiogroup" aria-label="Sample image">
            <button
              v-for="item in displaySamples"
              :key="item.id"
              type="button"
              role="radio"
              :aria-checked="sampleId === item.id"
              class="flex items-center gap-2.5 rounded-xl p-2 text-left transition-colors"
              :class="sampleId === item.id ? 'bg-[rgb(var(--rgb-primary)/0.18)] ring-1 ring-inset ring-[rgb(var(--rgb-primary)/0.55)]' : 'bg-white/[0.03] ring-1 ring-inset ring-white/[0.06] hover:bg-white/[0.06]'"
              @click="sampleId = item.id"
            >
              <img :src="asset(item.src)" alt="" width="36" height="36" loading="lazy" class="size-9 shrink-0 rounded-md object-cover" :class="item.pixelated && '[image-rendering:pixelated]'">
              <span class="min-w-0">
                <span class="block truncate text-xs text-white">{{ item.name }}</span>
                <span class="block text-[11px] text-ink-400">{{ item.frames === 1 ? 'Image' : `GIF · ${item.frames} frames` }}</span>
              </span>
            </button>
          </div>
        </div>

        <div class="flex flex-wrap items-center justify-between gap-3">
          <AppSegmented v-model="fit" :options="fits" label="Fit mode" />
          <button
            type="button"
            class="inline-flex h-8 items-center gap-2 rounded-lg bg-[rgb(var(--rgb-primary))] px-3.5 text-xs font-semibold text-white shadow-[0_6px_20px_-6px_rgb(var(--rgb-primary)/0.8)] transition-opacity disabled:opacity-60"
            :disabled="uploading"
            @click="upload"
          >
            {{ uploading ? 'Uploading…' : done ? 'Upload again' : 'Upload to keyboard' }}
          </button>
        </div>

        <div :class="appCard" class="p-3.5" aria-live="polite">
          <div class="flex items-center justify-between text-xs">
            <span class="text-white">{{ done ? 'Uploaded. The keyboard confirmed every chunk.' : uploading ? 'Sending to the keyboard' : 'Ready to upload over USB-C' }}</span>
            <span class="text-ink-400 tabular-nums">{{ sent }} / {{ chunks }}</span>
          </div>
          <div class="mt-2.5 h-1.5 overflow-hidden rounded-full bg-white/10">
            <div class="h-full rounded-full transition-[width] duration-100" :class="done ? 'bg-emerald-400' : 'bg-[rgb(var(--rgb-primary))]'" :style="{ width: `${(sent / chunks) * 100}%` }" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
