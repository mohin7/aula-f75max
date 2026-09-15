<script setup lang="ts">
/** A large rotary knob. Drag vertically, scroll, or use the arrow keys. */
const props = withDefaults(defineProps<{ min?: number; max?: number; step?: number; label: string; unit?: string }>(), {
  min: 0,
  max: 100,
  step: 1,
  unit: '',
})

const model = defineModel<number>({ required: true })
const displayed = ref(model.value)
const reduced = useReducedMotion()

// Smoothly interpolate the displayed value toward the model value.
let frame = 0
watch(model, (target) => {
  if (reduced.value) { displayed.value = target; return }
  cancelAnimationFrame(frame)
  const tick = () => {
    const delta = target - displayed.value
    if (Math.abs(delta) < 0.05) { displayed.value = target; return }
    displayed.value += delta * 0.18
    frame = requestAnimationFrame(tick)
  }
  frame = requestAnimationFrame(tick)
})
onBeforeUnmount(() => cancelAnimationFrame(frame))

const fraction = computed(() => (displayed.value - props.min) / (props.max - props.min))
const angle = computed(() => -135 + fraction.value * 270)
const clamp = (value: number) => Math.min(props.max, Math.max(props.min, Math.round(value / props.step) * props.step))

let startY = 0
let startValue = 0
function onPointerDown(event: PointerEvent) {
  ;(event.currentTarget as HTMLElement).setPointerCapture(event.pointerId)
  startY = event.clientY
  startValue = model.value
}
function onPointerMove(event: PointerEvent) {
  if (!(event.currentTarget as HTMLElement).hasPointerCapture(event.pointerId)) return
  const range = props.max - props.min
  model.value = clamp(startValue + ((startY - event.clientY) / 220) * range)
}
function onWheel(event: WheelEvent) {
  event.preventDefault()
  model.value = clamp(model.value - Math.sign(event.deltaY) * props.step * Math.max(1, (props.max - props.min) / 50))
}
function onKey(event: KeyboardEvent) {
  const big = (props.max - props.min) / 10
  const map: Record<string, number> = { ArrowUp: props.step, ArrowRight: props.step, ArrowDown: -props.step, ArrowLeft: -props.step, PageUp: big, PageDown: -big }
  if (event.key in map) { event.preventDefault(); model.value = clamp(model.value + map[event.key]!) }
  if (event.key === 'Home') { event.preventDefault(); model.value = props.min }
  if (event.key === 'End') { event.preventDefault(); model.value = props.max }
}

const ticks = Array.from({ length: 48 }, (_, i) => i)
</script>

<template>
  <div class="flex flex-col items-center gap-6">
    <div
      class="relative size-56 cursor-grab touch-none select-none rounded-full active:cursor-grabbing focus-visible:outline-none sm:size-64"
      role="slider"
      tabindex="0"
      :aria-label="label"
      :aria-valuemin="min"
      :aria-valuemax="max"
      :aria-valuenow="model"
      :aria-valuetext="`${model}${unit}`"
      @pointerdown="onPointerDown"
      @pointermove="onPointerMove"
      @wheel="onWheel"
      @keydown="onKey"
    >
      <!-- progress arc -->
      <svg viewBox="0 0 100 100" class="absolute inset-0 -rotate-[225deg]" aria-hidden="true">
        <circle cx="50" cy="50" r="47" fill="none" stroke="rgb(255 255 255 / 0.06)" stroke-width="2" stroke-dasharray="221.5 295.3" stroke-linecap="round" />
        <circle
          cx="50" cy="50" r="47" fill="none" stroke="rgb(var(--rgb-primary))" stroke-width="2.2" stroke-linecap="round"
          :stroke-dasharray="`${221.5 * fraction} 295.3`"
          style="filter: drop-shadow(0 0 4px rgb(var(--rgb-primary) / 0.8))"
        />
      </svg>
      <!-- body -->
      <div class="absolute inset-[9%] rounded-full bg-[conic-gradient(from_0deg,#9a9ca3,#5c5e66,#c4c6cc,#55575e,#9a9ca3)] shadow-[0_30px_60px_-10px_rgba(0,0,0,0.9)]" :style="{ transform: `rotate(${angle}deg)` }">
        <span
          v-for="tick in ticks"
          :key="tick"
          class="absolute left-1/2 top-0 h-[7%] w-px -translate-x-1/2 origin-[50%_714%] bg-black/30"
          :style="{ transform: `translateX(-50%) rotate(${tick * 7.5}deg)` }"
        />
        <div class="absolute inset-[12%] rounded-full bg-[radial-gradient(circle_at_30%_25%,#3a3b40,#1d1e22)] shadow-[inset_0_2px_0_rgba(255,255,255,0.08)]">
          <span class="absolute left-1/2 top-[10%] h-[18%] w-[5%] -translate-x-1/2 rounded-full bg-white shadow-[0_0_12px_rgb(var(--rgb-primary))]" />
        </div>
      </div>
    </div>
    <p class="text-center">
      <span class="block text-5xl font-semibold tracking-[-0.04em] text-white tabular-nums">{{ Math.round(displayed) }}<span class="text-2xl text-ink-400">{{ unit }}</span></span>
      <span class="mt-1 block text-sm text-ink-400">{{ label }}</span>
    </p>
  </div>
</template>
