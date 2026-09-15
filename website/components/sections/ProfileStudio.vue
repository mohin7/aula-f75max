<script setup lang="ts">
import { profiles } from '~/data/content'
import type { LightingState } from '~/composables/useKeyboardRGB'

type ProfileId = (typeof profiles)[number]['id']
const selectedId = ref<ProfileId>('coding')
const profile = computed(() => profiles.find((p) => p.id === selectedId.value)!)
const lighting = computed<LightingState>(() => ({ effect: profile.value.effect, color: profile.value.accent, brightness: 4, speed: 3 }))
const options = profiles.map((p) => ({ value: p.id, label: p.name }))
</script>

<template>
  <section id="profiles" class="relative overflow-hidden px-5 py-14 sm:px-8 sm:py-24" :style="{ '--rgb-primary': profile.accent }" aria-labelledby="profiles-title">
    <UiGlow :color="profile.accent" :intensity="0.6" />
    <div class="mx-auto max-w-6xl">
      <div v-reveal>
        <UiSectionHeading id="profiles-title" soon eyebrow="Profiles" :title="'One keyboard.\nEvery workflow.'" description="Save lighting and settings together and switch in one click. Profiles are planned; switch between these examples to preview the idea." />
      </div>

      <div v-reveal class="mt-10 flex justify-center">
        <UiChoice v-model="selectedId" :options="options" label="Example profile" class="justify-center" />
      </div>

      <div v-reveal class="mt-10 grid items-center gap-10 lg:grid-cols-[1fr_300px]">
        <KeyboardVisual :lighting="lighting" screen="clock" :highlight-ids="profile.highlight" interactive :label="`Keyboard with the ${profile.name} example profile`" />

        <Transition name="profile" mode="out-in">
          <dl :key="profile.id" class="grid grid-cols-2 gap-3 lg:grid-cols-1">
            <div class="rounded-2xl bg-white/[0.04] p-4 ring-1 ring-white/[0.08]">
              <dt class="text-sm text-ink-400">Profile</dt>
              <dd class="mt-1 text-xl font-semibold tracking-tight text-white">{{ profile.name }}</dd>
            </div>
            <div class="rounded-2xl bg-white/[0.04] p-4 ring-1 ring-white/[0.08]">
              <dt class="text-sm text-ink-400">Lighting</dt>
              <dd class="mt-1 flex items-center gap-2 font-medium text-white capitalize">
                <span class="size-2.5 rounded-full" :style="{ backgroundColor: `rgb(${profile.accent})`, boxShadow: `0 0 10px rgb(${profile.accent})` }" aria-hidden="true" />
                {{ profile.effect === 'spectrum' ? 'Spectrum cycle' : profile.effect }}
              </dd>
            </div>
            <div class="rounded-2xl bg-white/[0.04] p-4 ring-1 ring-white/[0.08]">
              <dt class="text-sm text-ink-400">Highlighted keys</dt>
              <dd class="mt-1 font-medium text-white">{{ profile.highlight.length }} shortcuts</dd>
            </div>
            <div class="rounded-2xl bg-white/[0.04] p-4 ring-1 ring-white/[0.08]">
              <dt class="text-sm text-ink-400">Knob</dt>
              <dd class="mt-1 font-medium text-white">{{ profile.knob }}</dd>
            </div>
          </dl>
        </Transition>
      </div>
    </div>
  </section>
</template>

<style scoped>
.profile-enter-active, .profile-leave-active { transition: opacity 0.3s ease, transform 0.3s var(--ease-out-quint); }
.profile-enter-from { opacity: 0; transform: translateY(10px); }
.profile-leave-to { opacity: 0; transform: translateY(-6px); }
</style>
