<script setup lang="ts" generic="T extends string | number">
/** Pill radio group with roving arrow-key focus. */
const props = withDefaults(defineProps<{
  options: ReadonlyArray<{ value: T; label: string; hint?: string }>
  label: string
  size?: 'sm' | 'md'
}>(), { size: 'md' })

const model = defineModel<T>({ required: true })
const group = shallowRef<HTMLElement | null>(null)

function move(event: KeyboardEvent) {
  const step = { ArrowRight: 1, ArrowDown: 1, ArrowLeft: -1, ArrowUp: -1 }[event.key]
  if (!step) return
  event.preventDefault()
  const i = props.options.findIndex((o) => o.value === model.value)
  const next = props.options[(i + step + props.options.length) % props.options.length]!
  model.value = next.value
  nextTick(() => group.value?.querySelector<HTMLElement>('[aria-checked="true"]')?.focus())
}
</script>

<template>
  <div ref="group" role="radiogroup" :aria-label="label" class="flex flex-wrap gap-2" @keydown="move">
    <button
      v-for="option in options"
      :key="option.value"
      type="button"
      role="radio"
      :aria-checked="model === option.value"
      :tabindex="model === option.value ? 0 : -1"
      :title="option.hint"
      class="rounded-full font-medium transition-[background-color,color,box-shadow] duration-200"
      :class="[
        size === 'sm' ? 'h-8 min-w-8 px-3 text-[13px]' : 'h-10 px-4 text-sm',
        model === option.value
          ? 'bg-white text-ink-950 shadow-[0_6px_24px_-6px_rgb(var(--rgb-primary)/0.7)]'
          : 'bg-white/[0.05] text-ink-200 ring-1 ring-white/10 ring-inset hover:bg-white/10 hover:text-white',
      ]"
      @click="model = option.value"
    >
      {{ option.label }}
    </button>
  </div>
</template>
