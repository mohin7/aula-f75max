<script setup lang="ts">
/** A level slider (1–5 by default) drawn like the app's. */
const props = withDefaults(defineProps<{ label: string; min?: number; max?: number }>(), { min: 1, max: 5 })
const model = defineModel<number>({ required: true })
const fill = computed(() => ((model.value - props.min) / (props.max - props.min)) * 100)
const id = useId()
</script>

<template>
  <div>
    <div class="flex items-center justify-between">
      <label :for="id" class="text-[13px] text-white">{{ label }}</label>
      <span class="text-xs text-ink-400 tabular-nums">{{ model }} / {{ max }}</span>
    </div>
    <div class="relative mt-2.5 h-5">
      <div class="absolute inset-x-0 top-1/2 h-1 -translate-y-1/2 rounded-full bg-white/10" />
      <div class="absolute left-0 top-1/2 h-1 -translate-y-1/2 rounded-full bg-[rgb(var(--rgb-primary))] transition-[width] duration-150" :style="{ width: `${fill}%` }" />
      <div class="absolute inset-x-[7px] top-1/2 flex -translate-y-1/2 justify-between" aria-hidden="true">
        <span v-for="n in max - min + 1" :key="n" class="size-1 rounded-full" :class="n - 1 + min <= model ? 'bg-white/0' : 'bg-white/25'" />
      </div>
      <input
        :id="id"
        v-model.number="model"
        type="range"
        :min="min"
        :max="max"
        step="1"
        class="app-range absolute inset-0 w-full cursor-pointer appearance-none bg-transparent"
      >
    </div>
  </div>
</template>

<style scoped>
.app-range::-webkit-slider-thumb {
  width: 16px;
  height: 16px;
  border-radius: 999px;
  background: #fff;
  box-shadow: 0 1px 4px rgb(0 0 0 / 0.5), 0 0 0 0.5px rgb(0 0 0 / 0.2);
  appearance: none;
}
.app-range::-moz-range-thumb {
  width: 16px;
  height: 16px;
  border: 0;
  border-radius: 999px;
  background: #fff;
  box-shadow: 0 1px 4px rgb(0 0 0 / 0.5);
}
.app-range:focus-visible {
  outline: none;
}
.app-range:focus-visible::-webkit-slider-thumb {
  box-shadow: 0 0 0 3px rgb(var(--rgb-primary) / 0.6);
}
</style>
