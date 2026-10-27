<script setup lang="ts">
import type { Crumb } from '~/composables/usePageSeo'

defineProps<{
  /** Trail after Home. The last crumb is the current page. */
  crumbs: Crumb[]
  eyebrow?: string
  title: string
  lead?: string
}>()
</script>

<template>
  <section class="relative isolate overflow-hidden" aria-labelledby="page-title">
    <div class="grid-bg absolute inset-0 -z-10 [mask-image:linear-gradient(to_bottom,black,transparent)]" aria-hidden="true" />
    <UiGlow :intensity="0.5" />
    <div class="frame !pb-12 !pt-10 sm:!pb-16 sm:!pt-14">
      <nav aria-label="Breadcrumb">
        <ol class="meta flex flex-wrap items-center gap-2">
          <li><NuxtLink to="/" class="transition-colors hover:text-white">Home</NuxtLink></li>
          <li v-for="(crumb, i) in crumbs" :key="crumb.path" class="flex items-center gap-2">
            <span aria-hidden="true">/</span>
            <NuxtLink v-if="i < crumbs.length - 1" :to="crumb.path" class="transition-colors hover:text-white">{{ crumb.name }}</NuxtLink>
            <span v-else aria-current="page" class="text-ink-300">{{ crumb.name }}</span>
          </li>
        </ol>
      </nav>
      <p v-if="eyebrow" class="mt-8 font-mono text-xs font-medium tracking-tight text-accent">{{ eyebrow }}</p>
      <h1 id="page-title" class="mt-4 max-w-4xl text-balance text-[2.3rem] leading-[1.05] font-semibold tracking-[-0.035em] text-white sm:text-5xl lg:text-[3.4rem]">
        {{ title }}
      </h1>
      <p v-if="lead" class="mt-6 max-w-2xl text-pretty text-lg leading-relaxed text-ink-300">{{ lead }}</p>
      <slot />
    </div>
  </section>
</template>
