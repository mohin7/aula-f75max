<script setup lang="ts">
import { appSections, type SectionId } from '~/data/app-ui'

/**
 * A working recreation of the AULA Studio window, built in HTML for this site.
 * It mirrors the app's layout and controls. It never talks to a keyboard.
 */
const props = withDefaults(defineProps<{
  /** Lets the sidebar change pages. Off for single-page illustrations. */
  navigable?: boolean
}>(), { navigable: true })

const section = defineModel<SectionId>('section', { default: 'dashboard' })

const demo = createStudioDemo(section.value)
provideStudioDemo(demo)
watch(section, (value) => (demo.state.section = value))
watch(() => demo.state.section, (value) => (section.value = value))

const { version: appVersion } = useSiteLinks()
const version = appVersion ? `v${appVersion}` : ''
const current = computed(() => appSections.find((s) => s.id === section.value)!)

function go(id: SectionId) {
  if (props.navigable) section.value = id
}
</script>

<template>
  <div
    class="font-app @container relative overflow-hidden rounded-[14px] bg-ink-850 text-left shadow-[0_0_0_1px_var(--line-strong),0_50px_120px_-30px_var(--shadow-soft)] sm:rounded-[18px]"
    :style="{ '--rgb-primary': demo.state.color }"
    role="group"
    aria-roledescription="app preview"
    aria-label="AULA Studio app, recreated for this page"
  >
    <!-- Title bar -->
    <div class="relative flex h-11 items-center border-b border-[var(--line)] bg-ink-800 px-4">
      <div class="flex gap-2" aria-hidden="true">
        <span class="size-3 rounded-full bg-[#ff5f57]" /><span class="size-3 rounded-full bg-[#febc2e]" /><span class="size-3 rounded-full bg-[#28c840]" />
      </div>
      <p class="absolute left-1/2 -translate-x-1/2 text-[13px] font-medium text-ink-200">AULA Studio</p>
      <span class="ml-auto hidden items-center gap-1.5 rounded-full bg-white/[0.06] px-2.5 py-1 text-[11px] text-ink-200 ring-1 ring-inset ring-white/[0.07] @md:inline-flex">
        <span class="size-1.5 rounded-full bg-emerald-400 shadow-[0_0_6px_#34d399]" aria-hidden="true" />
        F75 Max · USB-C
      </span>
    </div>

    <div class="flex">
      <!-- Sidebar -->
      <nav class="hidden w-52 shrink-0 flex-col border-r border-[var(--line)] bg-ink-800/90 p-3 @3xl:flex" aria-label="App sections">
        <ul class="flex flex-col gap-0.5">
          <li v-for="item in appSections" :key="item.id">
            <button
              type="button"
              class="flex w-full items-center gap-2.5 rounded-lg px-2.5 py-[7px] text-[13px] transition-colors duration-150"
              :class="[
                item.id === section ? 'bg-[rgb(var(--rgb-primary)/0.22)] text-white' : 'text-ink-300',
                navigable && item.id !== section && 'hover:bg-white/[0.05] hover:text-white',
                !navigable && 'cursor-default',
              ]"
              :aria-current="item.id === section ? 'page' : undefined"
              :tabindex="navigable ? 0 : -1"
              @click="go(item.id)"
            >
              <svg viewBox="0 0 24 24" class="size-4 shrink-0" :class="item.id === section ? 'text-accent' : 'text-ink-400'" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path :d="item.icon" /></svg>
              <span class="flex-1 text-left">{{ item.title }}</span>
              <span v-if="item.soon" class="rounded bg-amber-400/10 px-1.5 py-px text-[9px] font-semibold uppercase tracking-wider text-warn">Soon</span>
            </button>
          </li>
        </ul>
        <div class="mt-auto flex items-center gap-2.5 rounded-xl bg-white/[0.04] p-2.5 ring-1 ring-inset ring-white/[0.06]">
          <span class="grid size-8 place-items-center rounded-lg bg-gradient-to-b from-ink-600 to-ink-700 ring-1 ring-white/10" aria-hidden="true">
            <svg viewBox="0 0 24 24" class="size-4 text-ink-200" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 7h18v10H3zM7 10h.01M11 10h.01M15 10h.01M8 14h8" /></svg>
          </span>
          <span class="min-w-0">
            <span class="block truncate text-xs font-medium text-white">AULA F75 Max</span>
            <span class="block text-[11px] text-ok">Connected</span>
          </span>
        </div>
      </nav>

      <div class="min-w-0 flex-1">
        <!-- Compact navigation for narrow windows -->
        <nav v-if="navigable" class="flex gap-1 overflow-x-auto border-b border-[var(--line)] bg-ink-800 px-3 py-2 [scrollbar-width:none] @3xl:hidden" aria-label="App sections">
          <button
            v-for="item in appSections"
            :key="item.id"
            type="button"
            class="shrink-0 rounded-md px-2.5 py-1 text-xs transition-colors"
            :class="item.id === section ? 'bg-[rgb(var(--rgb-primary)/0.25)] text-white' : 'text-ink-300'"
            :aria-current="item.id === section ? 'page' : undefined"
            @click="go(item.id)"
          >
            {{ item.title }}
          </button>
        </nav>

        <main class="h-[560px] overflow-y-auto overscroll-contain p-4 [scrollbar-width:thin] @md:p-6 @3xl:h-[640px] @3xl:p-7" :aria-label="current.title">
          <Transition name="page" mode="out-in">
            <AppPageDashboard v-if="section === 'dashboard'" />
            <AppPageLighting v-else-if="section === 'lighting'" />
            <AppPageDisplay v-else-if="section === 'display'" />
            <AppPageSettings v-else-if="section === 'settings'" />
            <AppPageFirmware v-else-if="section === 'firmware'" />
            <AppPageSoon v-else :key="section" :section="section" />
          </Transition>
        </main>
      </div>
    </div>

    <!-- Status bar -->
    <div class="meta flex items-center justify-between gap-4 border-t border-[var(--line)] bg-ink-800 px-4 py-2 text-[11px]">
      <span class="flex items-center gap-1.5"><span class="size-1.5 rounded-full bg-emerald-400" aria-hidden="true" />Interactive recreation · not connected to a keyboard</span>
      <span class="hidden sm:block">{{ version }}</span>
    </div>
  </div>
</template>

<style scoped>
.page-enter-active, .page-leave-active { transition: opacity 0.22s ease, transform 0.22s var(--ease-out-quint); }
.page-enter-from { opacity: 0; transform: translateY(6px); }
.page-leave-to { opacity: 0; }
</style>
