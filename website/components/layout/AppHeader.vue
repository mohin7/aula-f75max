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
  { label: 'Under the hood', href: '#protocol' },
  { label: 'Privacy', href: '#privacy' },
  { label: 'Coming soon', href: '#keymap' },
  { label: 'FAQ', href: '#faq' },
]
</script>

<template>
  <header class="sticky top-0 z-50">
    <nav
      aria-label="Main"
      class="glass border-b transition-[border-color,box-shadow] duration-300"
      :class="scrolled ? 'border-[var(--line-strong)] shadow-[0_8px_30px_-18px_var(--shadow-soft)]' : 'border-[var(--line)]'"
    >
      <div class="mx-auto flex h-14 max-w-[78rem] items-center justify-between gap-6 px-4 sm:px-6">
        <div class="flex items-center gap-8">
          <a href="#top" aria-label="AULA Studio home"><AppLogo /></a>
          <ul class="hidden items-center md:flex">
            <li v-for="item in nav" :key="item.href">
              <a :href="item.href" class="rounded-lg px-3 py-2 text-sm text-ink-300 transition-colors hover:text-white">{{ item.label }}</a>
            </li>
          </ul>
        </div>

        <div class="flex items-center gap-1.5">
          <a :href="links.repo('readme')" target="_blank" rel="noopener noreferrer" class="hidden rounded-lg px-3 py-2 text-sm text-ink-300 transition-colors hover:text-white lg:block">Docs</a>
          <ThemeToggle />
          <a :href="links.github" target="_blank" rel="noopener noreferrer" aria-label="AULA Studio on GitHub" class="grid size-9 place-items-center rounded-lg text-ink-300 transition-colors hover:bg-white/[0.06] hover:text-white">
            <svg viewBox="0 0 16 16" class="size-[18px]" fill="currentColor" aria-hidden="true"><path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8z" /></svg>
          </a>
          <span class="ml-1.5 hidden sm:block"><DownloadButton size="md" label="Download" /></span>
          <button
            type="button"
            class="grid size-10 place-items-center rounded-lg text-white md:hidden"
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
      </div>
    </nav>

    <Transition
      enter-active-class="transition duration-300 ease-out"
      enter-from-class="opacity-0"
      leave-active-class="transition duration-200 ease-in"
      leave-to-class="opacity-0"
    >
      <div v-if="open" id="mobile-menu" class="fixed inset-0 top-0 z-[-1] bg-ink-950/95 px-6 pt-24 backdrop-blur-xl md:hidden">
        <ul class="flex flex-col">
          <li v-for="item in nav" :key="item.href" class="border-b border-[var(--line)]">
            <a :href="item.href" class="flex items-center justify-between py-4 text-2xl font-semibold tracking-tight text-white" @click="open = false">
              {{ item.label }}
              <svg viewBox="0 0 16 16" class="size-4 text-ink-400" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M6 3l5 5-5 5" /></svg>
            </a>
          </li>
        </ul>
        <DownloadButton details class="mt-10 w-full" />
      </div>
    </Transition>
  </header>
</template>
