<script setup lang="ts">
const steps = [
  {
    title: 'Download',
    body: 'Click the button. AULA Studio downloads as a small disk image.',
    icon: 'M12 4v11M7.5 10.5L12 15l4.5-4.5M5 19h14',
  },
  {
    title: 'Drag to Applications',
    body: 'Open the downloaded file and drag AULA Studio into the Applications folder.',
    icon: 'M4 6h6l2 2h8v10H4zM12 11v5M9.5 13.5L12 16l2.5-2.5',
  },
  {
    title: 'Allow it once',
    body: 'The first time, open System Settings → Privacy & Security and click Open Anyway.',
    icon: 'M12 3l7 3v6c0 4.5-3 7.8-7 9-4-1.2-7-4.5-7-9V6zM9 12l2 2 4-4',
  },
]
</script>

<template>
  <section id="download" class="relative overflow-hidden px-5 py-12 sm:px-8 sm:py-20" aria-labelledby="download-title">
    <div class="relative mx-auto max-w-5xl overflow-hidden rounded-[32px] bg-ink-850 px-6 py-12 text-center ring-1 ring-white/[0.08] sm:px-12 sm:py-14">
      <UiGlow :intensity="0.9" />
      <div aria-hidden="true" class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-[rgb(var(--rgb-primary)/0.8)] to-transparent" />

      <div v-reveal class="flex flex-col items-center">
        <NuxtImg src="/images/app-icon-512.png" alt="" width="112" height="112" sizes="112px" densities="x1 x2" loading="lazy" class="size-20 drop-shadow-[0_20px_40px_rgb(var(--rgb-primary)/0.45)]" />
        <h2 id="download-title" class="mt-6 text-balance text-4xl leading-[1.02] font-semibold tracking-[-0.035em] text-white sm:text-5xl">Get AULA Studio.</h2>
        <p class="mt-5 max-w-md text-pretty text-lg leading-relaxed text-ink-300">Free for your Mac. Works on Apple silicon and Intel.</p>

        <DownloadButton details class="mt-8 w-full sm:w-auto" />
      </div>

      <ol class="mx-auto mt-10 grid max-w-4xl gap-3 text-left md:grid-cols-3">
        <li v-for="(step, i) in steps" :key="step.title" v-reveal="i * 80" class="rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/[0.07] sm:p-5">
          <div class="flex items-center gap-3">
            <span class="grid size-9 place-items-center rounded-xl bg-white/[0.06] text-white ring-1 ring-white/10" aria-hidden="true">
              <svg viewBox="0 0 24 24" class="size-[18px]" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path :d="step.icon" /></svg>
            </span>
            <h3 class="font-medium text-white"><span class="sr-only">Step {{ i + 1 }}: </span>{{ step.title }}</h3>
          </div>
          <p class="mt-2.5 text-pretty text-sm leading-relaxed text-ink-300">{{ step.body }}</p>
        </li>
      </ol>

      <p class="mx-auto mt-8 max-w-xl text-pretty text-xs leading-relaxed text-ink-400">
        Why step 3? AULA Studio isn’t notarized by Apple yet, so macOS asks you to confirm the first time. It’s open source, and it never changes your keyboard’s firmware.
      </p>
    </div>
  </section>
</template>
