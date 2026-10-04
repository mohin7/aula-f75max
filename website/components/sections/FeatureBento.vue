<script setup lang="ts">
/**
 * Six cards, each a small schematic of what the app does. Every claim here matches the shipping app
 * (see README and Docs/Roadmap.md). Register-style captions are real, verified values.
 */
const cards = [
  { id: 'lighting', accent: '139 92 246', caption: 'lighting_effects', reg: '20 modes', title: 'All 20 firmware effects', body: 'Pick an effect, a color, brightness, speed and direction. The on-screen keyboard previews it, then the keyboard confirms the change.', foot: 'USB-C · acknowledged writes' },
  { id: 'screen', accent: '34 211 238', caption: 'display', reg: '128 × 128', title: 'Pictures and GIFs on the screen', body: 'Upload an image or an animated GIF, up to 255 frames. Fit, Fill or Stretch, and watch the upload progress.', foot: 'USB-C · 0xFF68 · 4096-byte chunks' },
  { id: 'settings', accent: '52 211 153', caption: 'settings', reg: '0x17', title: 'Settings that stick', body: 'Key response time, sleep timer, Windows, Alt+F4 and Alt+Tab locks, and the Fn switch. The keyboard keeps them over Bluetooth.', foot: 'USB-C · settings block 0x17' },
  { id: 'transport', accent: '59 130 246', caption: 'transport', reg: 'USB-C · BLE · 2.4G', title: 'USB-C, Bluetooth or 2.4G', body: 'Configure over the USB-C cable. Live keys and battery also work wirelessly. 2.4G configuration is next on the roadmap.', foot: 'Bluetooth has no config channel (verified)' },
  { id: 'battery', accent: '52 211 153', caption: 'battery', reg: 'BLE GATT 0x180F', title: 'Live battery level', body: 'Read over Bluetooth through notifications, and remembered from the last reading for next time.', foot: 'Bluetooth LE · notifications' },
  { id: 'preview', accent: '236 72 153', caption: 'key_events', reg: 'HID', title: 'A live on-screen keyboard', body: 'Mirrors your key presses and knob turns as you type, with a Key Tester to check every switch.', foot: 'IOKit · Input Monitoring' },
] as const

// Eight columns by three rows of tiny keycaps for the lighting card; the wave is a CSS delay per column.
const miniKeys = Array.from({ length: 24 }, (_, i) => ({ col: i % 8, row: Math.floor(i / 8) }))
</script>

<template>
  <section id="capabilities" class="section" aria-labelledby="capabilities-title">
    <div class="frame">
      <div v-reveal>
        <UiSectionHeading
          id="capabilities-title"
          eyebrow="What it does"
          title="Everything the keyboard offers, without Windows"
          description="AULA makes no software for Mac. AULA Studio talks to the keyboard directly, with no drivers, no account and no network."
          meta="HID · IOKit · no drivers"
        />
      </div>

      <ul v-reveal class="mt-12 grid gap-px overflow-hidden rounded-2xl border border-[var(--line)] bg-[var(--line)] md:grid-cols-2 lg:grid-cols-3">
        <li
          v-for="card in cards"
          :key="card.id"
          class="group relative flex flex-col bg-ink-900"
          :style="{ '--rgb-primary': card.accent }"
        >
          <!-- Schematic -->
          <div class="dot-bg relative flex h-56 flex-col justify-between border-b border-[var(--line)] bg-ink-850/60 p-4 transition-colors duration-500 group-hover:bg-[rgb(var(--rgb-primary)/0.05)]" aria-hidden="true">
            <div class="meta flex items-center justify-between text-[11px]"><span>{{ card.caption }}</span><span>{{ card.reg }}</span></div>

            <!-- lighting: a wave rolling across tiny keycaps -->
            <div v-if="card.id === 'lighting'" class="mx-auto grid w-full max-w-[16rem] grid-cols-8 gap-1.5">
              <span v-for="(k, n) in miniKeys" :key="n" class="mini-key aspect-square rounded-[5px] bg-[rgb(var(--rgb-primary))]" :style="{ animationDelay: `${(k.col * 0.16 + k.row * 0.09).toFixed(2)}s` }" />
            </div>

            <!-- screen: the 128×128 frame with a strip of GIF frames -->
            <div v-else-if="card.id === 'screen'" class="flex items-end justify-center gap-3">
              <div class="relative size-24 overflow-hidden rounded-lg bg-[#0b0c0e] ring-1 ring-[var(--line-strong)]">
                <div class="absolute inset-0 bg-[radial-gradient(circle_at_30%_30%,rgb(var(--rgb-primary)/0.9),transparent_55%),radial-gradient(circle_at_75%_80%,rgb(139_92_246/0.8),transparent_50%)]" />
                <div class="absolute inset-x-0 bottom-0 h-px bg-white/30" />
                <span class="absolute left-1.5 top-1.5 font-mono text-[9px] text-white/80">128×128</span>
              </div>
              <div class="flex flex-col gap-1.5">
                <span v-for="n in 3" :key="n" class="block h-6 w-9 rounded-[5px] ring-1 ring-[var(--line-strong)]" :style="{ background: `linear-gradient(${60 + n * 55}deg, rgb(var(--rgb-primary) / ${0.9 - n * 0.2}), rgb(139 92 246 / ${0.7 - n * 0.15}))` }" />
              </div>
            </div>

            <!-- settings: response slider and lock toggles -->
            <div v-else-if="card.id === 'settings'" class="mx-auto flex w-full max-w-[15rem] flex-col gap-2">
              <div>
                <div class="meta mb-1.5 flex justify-between text-[10px]"><span>key response</span><span>2</span></div>
                <div class="relative h-1 rounded-full bg-[var(--line-strong)]">
                  <span class="absolute inset-y-0 left-0 w-1/2 rounded-full bg-[rgb(var(--rgb-primary))]" />
                  <span class="absolute left-1/2 top-1/2 size-3 -translate-x-1/2 -translate-y-1/2 rounded-full bg-[#fff] ring-2 ring-[rgb(var(--rgb-primary))]" />
                </div>
              </div>
              <div v-for="(row, n) in ['Windows key lock', 'Alt+F4 lock', 'Alt+Tab lock']" :key="row" class="flex items-center justify-between rounded-md border border-[var(--line)] bg-ink-900 px-2.5 py-1">
                <span class="font-mono text-[10px] text-ink-300">{{ row }}</span>
                <span class="relative h-3.5 w-6 rounded-full" :class="n === 0 ? 'bg-[rgb(var(--rgb-primary))]' : 'bg-[var(--line-strong)]'"><span class="absolute top-0.5 size-2.5 rounded-full bg-[#fff] shadow-sm" :class="n === 0 ? 'right-0.5' : 'left-0.5'" /></span>
              </div>
            </div>

            <!-- transport: Mac to keyboard over three links -->
            <svg v-else-if="card.id === 'transport'" viewBox="0 0 240 100" class="mx-auto w-full max-w-[16rem] text-ink-400" fill="none" stroke="currentColor" stroke-width="1.2">
              <rect x="4" y="30" width="44" height="40" rx="6" class="fill-[var(--color-ink-900)]" />
              <text x="26" y="54" text-anchor="middle" class="fill-current font-mono" stroke="none" font-size="9">Mac</text>
              <rect x="192" y="30" width="44" height="40" rx="6" class="fill-[var(--color-ink-900)]" />
              <text x="214" y="54" text-anchor="middle" class="fill-current font-mono" stroke="none" font-size="9">F75</text>
              <path d="M48 38h144" stroke="rgb(var(--rgb-primary))" stroke-width="2" />
              <path d="M48 50h144" stroke-dasharray="3 4" />
              <path d="M48 62h144" stroke-dasharray="1 4" stroke-linecap="round" stroke-width="2" />
              <text x="120" y="33" text-anchor="middle" class="font-mono" stroke="none" fill="rgb(var(--rgb-primary))" font-size="8">USB-C · config</text>
              <text x="120" y="46" text-anchor="middle" class="fill-current font-mono" stroke="none" font-size="8">2.4G · soon</text>
              <text x="120" y="75" text-anchor="middle" class="fill-current font-mono" stroke="none" font-size="8">Bluetooth · keys, battery</text>
            </svg>

            <!-- battery -->
            <div v-else-if="card.id === 'battery'" class="mx-auto flex w-full max-w-[14rem] items-center gap-3">
              <div class="relative h-12 flex-1 rounded-lg border border-[var(--line-strong)] bg-ink-900 p-1">
                <span class="block h-full w-[82%] rounded-[5px] bg-gradient-to-r from-[rgb(var(--rgb-primary)/0.55)] to-[rgb(var(--rgb-primary))]" />
                <span class="absolute -right-1.5 top-1/2 h-4 w-1 -translate-y-1/2 rounded-r bg-[var(--line-strong)]" />
              </div>
              <span class="font-mono text-xl font-medium text-white">82<span class="text-sm text-ink-400">%</span></span>
            </div>

            <!-- preview: keycaps and the knob -->
            <div v-else class="flex items-end justify-center gap-4" data-theme="dark">
              <div class="flex gap-1.5">
                <span v-for="(k, n) in ['⌘', 'K', 'A', 'U', 'L', 'A']" :key="n" class="cap-demo grid size-8 place-items-center rounded-md bg-gradient-to-b from-ink-600 to-ink-700 font-mono text-xs text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.1),0_3px_0_#0b0b0d]" :style="{ animationDelay: `${n * 0.35}s` }">{{ k }}</span>
              </div>
              <span class="relative grid size-11 place-items-center rounded-full bg-[radial-gradient(circle_at_30%_25%,#4a4b52,#1d1e22)] shadow-[0_6px_14px_-4px_rgba(0,0,0,0.6)]"><span class="absolute top-1.5 h-2.5 w-0.5 rounded-full bg-[rgb(var(--rgb-primary))]" style="transform-origin: 50% 16px; transform: rotate(35deg)" /></span>
            </div>

            <span class="h-2" aria-hidden="true" />
          </div>

          <!-- Copy -->
          <div class="flex flex-1 flex-col p-5 sm:p-6">
            <h3 class="text-[17px] font-semibold tracking-tight text-white">{{ card.title }}</h3>
            <p class="mt-2 flex-1 text-pretty text-[15px] leading-relaxed text-ink-300">{{ card.body }}</p>
            <p class="meta mt-5 text-[11px]">{{ card.foot }}</p>
          </div>
        </li>
      </ul>
    </div>
  </section>
</template>

<style scoped>
.mini-key {
  opacity: 0.18;
  animation: mini-wave 2.4s ease-in-out infinite;
}
@keyframes mini-wave {
  0%, 100% { opacity: 0.16; transform: scale(0.9); }
  45% { opacity: 1; transform: scale(1); }
}
.cap-demo {
  animation: cap-tap 2.8s ease-in-out infinite;
}
@keyframes cap-tap {
  0%, 82%, 100% { transform: translateY(0); }
  88% { transform: translateY(3px); box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.1), 0 0 0 #0b0b0d, 0 0 14px rgb(var(--rgb-primary) / 0.8); }
}
@media (prefers-reduced-motion: reduce) {
  .mini-key { opacity: 0.7; transform: none; }
}
</style>
