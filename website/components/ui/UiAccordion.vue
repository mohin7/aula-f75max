<script setup lang="ts">
/** Native <details>: accessible, keyboard-friendly and zero JavaScript. */
defineProps<{ items: ReadonlyArray<{ q: string; a: string }> }>()
</script>

<template>
  <div class="divide-y divide-[var(--line)] border-y border-[var(--line)]">
    <details v-for="item in items" :key="item.q" class="group">
      <summary class="flex cursor-pointer list-none items-center justify-between gap-6 py-5 text-left text-[17px] font-medium tracking-tight text-white transition-colors hover:text-ink-200 [&::-webkit-details-marker]:hidden">
        <h3 class="text-pretty">{{ item.q }}</h3>
        <span aria-hidden="true" class="grid size-7 shrink-0 place-items-center rounded-md bg-white/[0.06] ring-1 ring-white/10 transition-transform duration-300 group-open:rotate-45">
          <svg viewBox="0 0 12 12" class="size-3" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M6 1v10M1 6h10" /></svg>
        </span>
      </summary>
      <p class="max-w-3xl pb-5 text-pretty leading-relaxed text-ink-300">{{ item.a }}</p>
    </details>
  </div>
</template>
