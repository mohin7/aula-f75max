<script setup lang="ts">
/** Planned features, shown compactly. None of these are in the app yet. */
const items = [
  { id: 'keymap', title: 'Key mapping', body: 'Turn any key into a shortcut, an app or a media control.', accent: '251 146 60' },
  { id: 'macros', title: 'Macros', body: 'Record keys, delays and text, then play them back.', accent: '236 72 153' },
  { id: 'profiles', title: 'Profiles', body: 'Save lighting and settings together and switch in a click.', accent: '168 85 247' },
  { id: 'knob', title: 'Knob actions', body: 'Use the knob for brightness, zoom or scrubbing a timeline.', accent: '34 211 238' },
] as const
</script>

<template>
  <section id="coming-soon" class="relative px-5 py-14 sm:px-8 sm:py-24" aria-labelledby="soon-title">
    <div class="mx-auto max-w-6xl">
      <div v-reveal class="flex flex-col items-center text-center">
        <UiBadge tone="soon">Coming soon</UiBadge>
        <h2 id="soon-title" class="mt-4 text-balance text-3xl font-semibold tracking-[-0.03em] text-white sm:text-4xl">What’s next for AULA Studio.</h2>
        <p class="mt-3 max-w-xl text-pretty text-ink-300">In development. These aren’t in the app yet.</p>
      </div>

      <ul class="mt-10 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <li v-for="(item, i) in items" :key="item.id" v-reveal="i * 60" class="group relative overflow-hidden rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/[0.07] sm:p-5" :style="{ '--rgb-primary': item.accent }">
          <!-- Small illustration of each idea -->
          <div class="flex h-12 items-center" aria-hidden="true">
            <div v-if="item.id === 'keymap'" class="flex items-center gap-1.5 text-sm sm:gap-2">
              <span class="grid h-9 min-w-9 place-items-center rounded-lg bg-gradient-to-b from-ink-600 to-ink-700 px-2 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.1),0_3px_0_#111]">⇪</span>
              <span class="text-ink-400">→</span>
              <span class="grid h-9 place-items-center rounded-lg bg-[rgb(var(--rgb-primary)/0.15)] px-2 text-xs font-medium whitespace-nowrap text-[rgb(var(--rgb-primary))] sm:px-2.5 sm:text-[13px] ring-1 ring-inset ring-[rgb(var(--rgb-primary)/0.4)]">⌘ Space</span>
            </div>
            <div v-else-if="item.id === 'macros'" class="flex items-center gap-1.5">
              <span v-for="(k, j) in ['⌘', '⇧', 'P', '↩']" :key="k" class="grid size-7 sm:size-8 place-items-center rounded-md text-xs text-white ring-1 ring-inset" :class="j < 3 ? 'bg-[rgb(var(--rgb-primary)/0.15)] ring-[rgb(var(--rgb-primary)/0.4)]' : 'bg-white/[0.04] ring-white/10'">{{ k }}</span>
            </div>
            <div v-else-if="item.id === 'profiles'" class="flex -space-x-2">
              <span v-for="c in ['59 130 246', '52 211 153', '239 68 68', '168 85 247', '251 146 60']" :key="c" class="size-7 rounded-full ring-2 ring-ink-900 sm:size-8" :style="{ backgroundColor: `rgb(${c})` }" />
            </div>
            <div v-else class="relative size-11 rounded-full bg-[conic-gradient(from_0deg,#9a9ca3,#5c5e66,#c4c6cc,#55575e,#9a9ca3)] shadow-[0_0_0_3px_rgb(var(--rgb-primary)/0.35)]">
              <span class="absolute inset-[18%] rounded-full bg-[radial-gradient(circle_at_30%_25%,#3a3b40,#1d1e22)]" />
              <span class="absolute left-1/2 top-[22%] h-[22%] w-[6%] -translate-x-1/2 rounded-full bg-white" />
            </div>
          </div>
          <h3 class="mt-3 font-semibold tracking-tight text-white sm:mt-4">{{ item.title }}</h3>
          <p class="mt-1 text-pretty text-[13px] leading-relaxed text-ink-400 sm:text-sm">{{ item.body }}</p>
        </li>
      </ul>
    </div>
  </section>
</template>
