<script setup lang="ts">
const links = useSiteLinks()
const { y } = useWindowScroll()
const scrolled = computed(() => y.value > 24)

const open = ref(false)
const isLocked = useScrollLock(import.meta.client ? document.body : null)
watch(open, (value) => (isLocked.value = value))
onKeyStroke('Escape', () => (open.value = false))

const nav = [
  { label: 'Features', href: '#features' },
  { label: 'Coming soon', href: '#keymap' },
  { label: 'FAQ', href: '#faq' },
  { label: 'Download', href: '#download' },
]
</script>

<template>
  <header class="sticky top-0 z-50 px-3 pt-3 sm:px-5">
    <nav
      aria-label="Main"
      class="mx-auto flex h-14 max-w-6xl items-center justify-between rounded-2xl border px-3 pl-4 transition-[background-color,border-color,box-shadow] duration-300"
      :class="scrolled ? 'glass border-white/[0.09] shadow-[0_10px_40px_-15px_rgba(0,0,0,0.8)]' : 'border-transparent bg-transparent'"
    >
      <a href="#top" aria-label="AULA Studio home"><AppLogo /></a>

      <ul class="hidden items-center gap-1 md:flex">
        <li v-for="item in nav" :key="item.href">
          <a :href="item.href" class="rounded-full px-3.5 py-2 text-sm text-ink-300 transition-colors hover:text-white">{{ item.label }}</a>
        </li>
        <li>
          <a :href="links.github" target="_blank" rel="noopener noreferrer" class="rounded-full px-3.5 py-2 text-sm text-ink-300 transition-colors hover:text-white">GitHub</a>
        </li>
      </ul>

      <div class="flex items-center gap-2">
        <span class="hidden sm:block"><DownloadButton size="md" label="Download" /></span>
        <button
          type="button"
          class="grid size-10 place-items-center rounded-full text-white md:hidden"
          :aria-expanded="open"
          aria-controls="mobile-menu"
          :aria-label="open ? 'Close menu' : 'Open menu'"
          @click="open = !open"
        >
          <svg viewBox="0 0 20 20" class="size-5" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true">
            <path v-if="!open" d="M3 7h14M3 13h14" />
            <path v-else d="M5 5l10 10M15 5L5 15" />
          </svg>
        </button>
      </div>
    </nav>

    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="opacity-0"
      leave-active-class="transition duration-200 ease-in"
      leave-to-class="opacity-0"
    >
      <div v-if="open" id="mobile-menu" class="fixed inset-0 top-0 z-[-1] bg-ink-950/95 px-6 pt-24 backdrop-blur-xl md:hidden">
        <ul class="flex flex-col gap-2">
          <li v-for="item in nav" :key="item.href">
            <a :href="item.href" class="block py-3 text-3xl font-semibold tracking-tight text-white" @click="open = false">{{ item.label }}</a>
          </li>
          <li>
            <a :href="links.github" target="_blank" rel="noopener noreferrer" class="block py-3 text-3xl font-semibold tracking-tight text-white">GitHub</a>
          </li>
        </ul>
        <DownloadButton details class="mt-10 w-full" />
      </div>
    </Transition>
  </header>
</template>
