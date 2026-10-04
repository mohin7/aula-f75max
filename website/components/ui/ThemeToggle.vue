<script setup lang="ts">
/**
 * Light / dark switch. The page's theme lives on <html data-theme>, set before first paint by an
 * inline script, so this button never renders from state: CSS shows the right icon.
 */
function toggle() {
  const root = document.documentElement
  const next = root.dataset.theme === 'light' ? 'dark' : 'light'
  root.classList.add('theme-fade')
  root.dataset.theme = next
  try { localStorage.setItem('aula-theme', next) } catch { /* private mode: the choice just won't persist */ }
  setTimeout(() => root.classList.remove('theme-fade'), 400)
}
</script>

<template>
  <button
    type="button"
    class="theme-toggle grid size-9 place-items-center rounded-lg text-ink-300 transition-colors hover:bg-white/[0.06] hover:text-white"
    aria-label="Switch between light and dark theme"
    @click="toggle"
  >
    <svg class="theme-toggle__moon size-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" /></svg>
    <svg class="theme-toggle__sun size-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="4" /><path d="M12 2.5v2M12 19.5v2M4.6 4.6l1.4 1.4M18 18l1.4 1.4M2.5 12h2M19.5 12h2M4.6 19.4L6 18M18 6l1.4-1.4" /></svg>
  </button>
</template>

<style scoped>
.theme-toggle > svg { grid-area: 1 / 1; }
/* Dark theme (default) shows the sun, offering the switch to light; light shows the moon. */
:global([data-theme="light"]) .theme-toggle__sun,
.theme-toggle__moon { display: none; }
:global([data-theme="light"]) .theme-toggle__moon { display: block; }
</style>
