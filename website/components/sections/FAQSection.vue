<script setup lang="ts">
import { faqs } from '~/data/content'

const half = Math.ceil(faqs.length / 2)
</script>

<template>
  <section id="faq" class="relative px-5 py-14 sm:px-8 sm:py-24" aria-labelledby="faq-title">
    <div class="mx-auto max-w-6xl">
      <h2 id="faq-title" v-reveal class="text-center text-3xl font-semibold tracking-[-0.03em] text-white sm:text-4xl">Questions, answered.</h2>
      <div v-reveal class="mt-10 grid gap-x-10 md:grid-cols-2">
        <UiAccordion :items="faqs.slice(0, half)" />
        <UiAccordion :items="faqs.slice(half)" class="-mt-px md:mt-0" />
      </div>
    </div>
  </section>
</template>
