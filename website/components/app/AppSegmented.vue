<script setup lang="ts" generic="T extends string | number">
/** macOS-style segmented control. */
const props = defineProps<{ options: ReadonlyArray<{ value: T; label: string }>; label: string }>()
const model = defineModel<T>({ required: true })
const root = shallowRef<HTMLElement | null>(null)

function move(event: KeyboardEvent) {
  const step = { ArrowRight: 1, ArrowLeft: -1 }[event.key]
  if (!step) return
  event.preventDefault()
  const i = props.options.findIndex((o) => o.value === model.value)
  model.value = props.options[(i + step + props.options.length) % props.options.length]!.value
  nextTick(() => root.value?.querySelector<HTMLElement>('[aria-checked="true"]')?.focus())
}
</script>

<template>
  <div ref="root" role="radiogroup" :aria-label="label" class="inline-flex shrink-0 rounded-lg bg-black/30 p-0.5 ring-1 ring-inset ring-white/[0.07]" @keydown="move">
    <button
      v-for="option in options"
      :key="option.value"
      type="button"
      role="radio"
      :aria-checked="model === option.value"
      :tabindex="model === option.value ? 0 : -1"
      class="flex-1 whitespace-nowrap rounded-md px-2.5 py-1 text-xs font-medium transition-colors duration-150"
      :class="model === option.value ? 'bg-white/[0.14] text-white shadow-[0_1px_2px_rgba(0,0,0,0.4),inset_0_1px_0_rgba(255,255,255,0.08)]' : 'text-ink-300 hover:text-white'"
      @click="model = option.value"
    >
      {{ option.label }}
    </button>
  </div>
</template>
