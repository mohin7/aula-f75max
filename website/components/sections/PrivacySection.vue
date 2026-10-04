<script setup lang="ts">
const links = useSiteLinks()

// Matches SECURITY.md and the app's entitlements. Keep these true.
const rows = [
  { label: 'Network access', value: 'None', tone: 'none' },
  { label: 'Analytics and telemetry', value: 'None', tone: 'none' },
  { label: 'Accounts and sign-in', value: 'None', tone: 'none' },
  { label: 'Key presses', value: 'Animate the preview only. Never stored', tone: 'note' },
  { label: 'Keyboard firmware', value: 'Read only. Never flashed', tone: 'note' },
  { label: 'Your settings', value: 'Written to the keyboard over USB-C', tone: 'note' },
] as const
</script>

<template>
  <section id="privacy" class="section" aria-labelledby="privacy-title">
    <div class="frame">
      <div class="grid items-center gap-10 lg:grid-cols-[1fr_1.1fr] lg:gap-16">
        <div v-reveal>
          <UiSectionHeading
            id="privacy-title"
            eyebrow="Private by design"
            title="Nothing between your keyboard and your Mac"
            description="No account, no telemetry, no cloud. The app has no network access at all, and what you type is never recorded. It's open source, so you can check."
          />
          <div class="mt-8 flex flex-wrap gap-2">
            <UiBadge>No network</UiBadge>
            <UiBadge>No telemetry</UiBadge>
            <UiBadge>MIT license</UiBadge>
          </div>
          <a :href="links.repo('security')" target="_blank" rel="noopener noreferrer" class="mt-6 inline-flex items-center gap-1.5 text-sm font-medium text-white underline-offset-4 hover:underline">
            Read the security notes
            <svg viewBox="0 0 16 16" class="size-3.5" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M5 11l6-6M6 5h5v5" /></svg>
          </a>
        </div>

        <div v-reveal="80" class="overflow-hidden rounded-2xl border border-[var(--line)] bg-ink-850">
          <div class="dot-bg border-b border-[var(--line)] px-5 py-3.5">
            <p class="meta text-[11px] tracking-[0.12em] uppercase">What leaves your Mac</p>
          </div>
          <dl>
            <div v-for="row in rows" :key="row.label" class="flex items-center justify-between gap-6 border-b border-[var(--line)] px-5 py-4 last:border-b-0">
              <dt class="text-[15px] text-white">{{ row.label }}</dt>
              <dd class="text-right">
                <span v-if="row.tone === 'none'" class="inline-flex items-center gap-1.5 rounded-md bg-emerald-500/10 px-2 py-0.5 font-mono text-xs font-medium text-emerald-500 ring-1 ring-inset ring-emerald-500/25 in-data-[theme=dark]:text-emerald-400">
                  <svg viewBox="0 0 12 12" class="size-3" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.5 6.5l2.5 2.5 4.5-5.5" /></svg>
                  {{ row.value }}
                </span>
                <span v-else class="meta text-[12px]">{{ row.value }}</span>
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
  </section>
</template>
