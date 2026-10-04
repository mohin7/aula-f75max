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
  <section id="features" class="section" :style="{ '--rgb-primary': feature.accent }" aria-labelledby="features-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading id="features-title" eyebrow="The app" title="One app for your whole keyboard" meta="SwiftUI · IOKit · CoreBluetooth" />
      </div>

      <!-- Follows the page picked in the app window -->
      <div class="mt-8 flex min-h-[5.5rem] flex-col" aria-live="polite">
        <Transition name="copy" mode="out-in">
          <div :key="feature.id">
            <p class="flex flex-wrap items-center gap-2.5 text-lg font-medium text-white">
              {{ feature.headline }}
              <UiBadge :tone="feature.status === 'available' ? 'accent' : 'soon'">{{ feature.status === 'available' ? 'Available' : 'Coming soon' }}</UiBadge>
            </p>
            <p class="mt-2 max-w-2xl text-pretty text-ink-300">{{ feature.description }}</p>
          </div>
        </Transition>
      </div>

      <div v-reveal class="relative mt-6">
        <UiGlow :intensity="0.6" />
        <AppWindow v-model:section="section" />
      </div>
    </div>
  </section>
</template>

<style scoped>
.copy-enter-active, .copy-leave-active { transition: opacity 0.25s ease, transform 0.25s var(--ease-out-quint); }
.copy-enter-from { opacity: 0; transform: translateY(6px); }
.copy-leave-to { opacity: 0; }
</style>
