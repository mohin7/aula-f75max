<script setup lang="ts">
const links = useSiteLinks()

const steps = [
  { title: 'Download', body: 'Click the button. AULA Studio downloads as a small disk image.' },
  { title: 'Drag to Applications', body: 'Open the downloaded file and drag AULA Studio into the Applications folder.' },
  { title: 'Allow it once', body: 'The first time, open System Settings → Privacy & Security and click Open Anyway.' },
]

const cloneCommand = `git clone ${links.github} && cd aula-f75max && make open`
</script>

<template>
  <section id="download" class="section overflow-hidden" aria-labelledby="download-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading
          id="download-title"
          eyebrow="Get started"
          title="Up and running in a minute"
          description="Free for your Mac. Download the app, or build it yourself from source."
          meta=".dmg · Apple silicon and Intel · macOS 15+"
        />
      </div>

      <div v-reveal class="relative mt-12">
        <UiGlow :intensity="0.7" />
        <div class="grid gap-px overflow-hidden rounded-2xl border border-[var(--line)] bg-[var(--line)] lg:grid-cols-[1.1fr_1fr]">
          <!-- Download -->
          <div class="flex flex-col items-start gap-6 bg-ink-900 p-6 sm:p-8">
            <div class="flex items-center gap-4">
              <NuxtImg src="/images/app-icon-512.png" alt="" width="112" height="112" sizes="64px" densities="x1 x2" loading="lazy" class="size-16 drop-shadow-[0_14px_28px_rgb(var(--rgb-primary)/0.4)]" />
              <div>
                <p class="text-lg font-semibold tracking-tight text-white">AULA Studio for Mac</p>
                <p class="meta mt-0.5">Free · open source · MIT</p>
              </div>
            </div>
            <div class="flex w-full flex-col items-start gap-3">
              <DownloadButton class="w-full sm:w-auto" />
              <DownloadMeta />
            </div>
            <p class="max-w-md text-pretty text-sm leading-relaxed text-ink-300">
              AULA Studio isn’t notarized by Apple yet, so macOS asks you to confirm the first time (step 3). It never changes your keyboard’s firmware.
            </p>
          </div>

          <!-- From source -->
          <div class="flex flex-col gap-6 bg-ink-900 p-6 sm:p-8">
            <div>
              <p class="flex items-center gap-2 text-lg font-semibold tracking-tight text-white">
                <svg viewBox="0 0 24 24" class="size-5 text-ink-400" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 8l-4 4 4 4M16 8l4 4-4 4M13.5 5l-3 14" /></svg>
                Build from source
              </p>
              <p class="mt-2 text-sm leading-relaxed text-ink-300">Needs macOS 15 and Swift 6, from Xcode or the Command Line Tools.</p>
            </div>
            <UiCommand :command="cloneCommand" label="Clone and build AULA Studio" />
            <div>
              <p class="mb-2 text-sm text-ink-300">No keyboard? Try demo mode:</p>
              <UiCommand command="AULA_DEMO=1 make run" label="Run AULA Studio in demo mode" />
            </div>
          </div>
        </div>

        <ol class="mt-4 grid gap-px overflow-hidden rounded-2xl border border-[var(--line)] bg-[var(--line)] md:grid-cols-3">
          <li v-for="(step, i) in steps" :key="step.title" v-reveal="i * 70" class="flex gap-4 bg-ink-900 p-5 sm:p-6">
            <span class="font-mono text-sm text-[rgb(var(--rgb-primary))]" aria-hidden="true">0{{ i + 1 }}</span>
            <div>
              <h3 class="font-medium text-white"><span class="sr-only">Step {{ i + 1 }}: </span>{{ step.title }}</h3>
              <p class="mt-1.5 text-pretty text-sm leading-relaxed text-ink-300">{{ step.body }}</p>
            </div>
          </li>
        </ol>
      </div>
    </div>
  </section>
</template>
