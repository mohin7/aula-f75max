<script setup lang="ts">
import { features } from '~/data/features'
import type { SectionId } from '~/data/app-ui'

// The app window's sidebar picks the page; the copy above it follows along.
const section = ref<SectionId>('lighting')
const feature = computed(() => features.find((f) => f.section === section.value) ?? features[0]!)

// Links like #app-display open that page of the app window.
function openFromHash() {
  const id = location.hash.startsWith('#app-') ? location.hash.slice(5) : ''
  const match = features.find((f) => f.section === id || f.id === id)
  if (!match) return
  section.value = match.section
  document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' })
}
onMounted(openFromHash)
useEventListener('hashchange', openFromHash)
</script>

<template>
  <section id="features" class="relative px-5 py-14 sm:px-8 sm:py-24" :style="{ '--rgb-primary': feature.accent }" aria-labelledby="features-title">
    <div class="mx-auto max-w-6xl">
      <div v-reveal class="mx-auto flex max-w-3xl flex-col items-center text-center">
        <p class="text-[13px] font-medium tracking-wide text-[rgb(var(--rgb-primary))]">Everything in one place</p>
        <h2 id="features-title" class="mt-3 text-balance text-4xl leading-[1.02] font-semibold tracking-[-0.035em] text-white sm:text-5xl">One app for your whole keyboard.</h2>

        <!-- Follows the page picked in the app window -->
        <div class="mt-6 flex min-h-[5.5rem] flex-col items-center" aria-live="polite">
          <Transition name="copy" mode="out-in">
            <div :key="feature.id" class="flex flex-col items-center">
              <p class="flex flex-wrap items-center justify-center gap-2 text-lg font-medium text-white">
                {{ feature.headline }}
                <UiBadge :tone="feature.status === 'available' ? 'accent' : 'soon'">{{ feature.status === 'available' ? 'Available' : 'Coming soon' }}</UiBadge>
              </p>
              <p class="mt-2 max-w-2xl text-pretty text-ink-300">{{ feature.description }}</p>
            </div>
          </Transition>
        </div>
      </div>

      <div v-reveal class="relative mt-8">
        <UiGlow :intensity="0.6" />
        <AppWindow v-model:section="section" />
        <p class="mt-4 text-center text-xs text-ink-400">An interactive recreation of the AULA Studio interface. Click around; it doesn’t connect to a keyboard.</p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.copy-enter-active, .copy-leave-active { transition: opacity 0.25s ease, transform 0.25s var(--ease-out-quint); }
.copy-enter-from { opacity: 0; transform: translateY(6px); }
.copy-leave-to { opacity: 0; }
</style>
