<script setup lang="ts">
import { howItWorks } from '~/data/content'
</script>

<template>
  <section id="how-it-works" class="relative px-5 py-14 sm:px-8 sm:py-24" aria-labelledby="how-title">
    <div class="mx-auto max-w-6xl">
      <div v-reveal>
        <UiSectionHeading id="how-title" eyebrow="How it works" title="Up and running in a minute." />
      </div>

      <div class="relative mt-12">
        <div aria-hidden="true" class="absolute left-0 right-0 top-6 hidden h-px bg-gradient-to-r from-transparent via-white/15 to-transparent md:block" />
        <ol class="relative grid gap-10 md:grid-cols-3 md:gap-6">
          <li v-for="(item, i) in howItWorks" :key="item.step" v-reveal="i * 100" class="relative">
            <span class="relative grid size-12 place-items-center rounded-full bg-ink-900 font-mono text-sm text-white ring-1 ring-white/15 shadow-[0_0_30px_rgb(var(--rgb-primary)/0.25)]">{{ item.step }}</span>
            <h3 class="mt-6 text-xl font-semibold tracking-tight text-white">{{ item.title }}</h3>
            <p class="mt-2 max-w-sm text-pretty leading-relaxed text-ink-300">{{ item.body }}</p>
          </li>
        </ol>
      </div>
    </div>
  </section>
</template>
