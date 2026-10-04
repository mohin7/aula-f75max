<script setup lang="ts">
defineProps<{ label: string; detail?: string }>()
const model = defineModel<boolean>({ required: true })
const id = useId()
</script>

<template>
  <div class="flex items-center justify-between gap-4 px-4 py-3">
    <label :for="id" class="min-w-0 cursor-pointer">
      <span class="block text-[13px] text-white">{{ label }}</span>
      <span v-if="detail" class="mt-0.5 block text-xs text-ink-400">{{ detail }}</span>
    </label>
    <button
      :id="id"
      type="button"
      role="switch"
      :aria-checked="model"
      class="relative h-[22px] w-[38px] shrink-0 rounded-full transition-colors duration-200"
      :class="model ? 'bg-[rgb(var(--rgb-primary))]' : 'bg-white/15'"
      @click="model = !model"
    >
      <span class="absolute top-[2px] left-[2px] size-[18px] rounded-full bg-[#fff] shadow-[0_1px_3px_rgba(0,0,0,0.4)] transition-transform duration-200 ease-[var(--ease-spring)]" :class="model && 'translate-x-4'" />
    </button>
  </div>
</template>
