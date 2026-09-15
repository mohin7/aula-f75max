<script setup lang="ts">
import { keys, layout, type KeyDef } from '~/data/keyboard-layout'
import { keyLightStyle, type LightingState } from '~/composables/useKeyboardRGB'

export type ScreenMode = 'off' | 'clock' | 'gif' | 'image' | 'battery' | 'cpu'

const props = withDefaults(defineProps<{
  lighting: LightingState
  /** Lights off (used by the scroll story's opening). */
  dark?: boolean
  screen?: ScreenMode
  selectedId?: string | null
  highlightIds?: readonly string[]
  interactive?: boolean
  /** Rotation of the knob in degrees. */
  knobAngle?: number
  label?: string
  /** Spread of the wave/spectrum across the board. */
  spread?: number
  /** Keys currently held on the visitor's real keyboard. */
  activeIds?: ReadonlySet<string>
  /** Render keys in the server HTML instead of waiting for the keyboard to near the viewport. */
  eager?: boolean
}>(), {
  dark: false,
  screen: 'clock',
  selectedId: null,
  highlightIds: () => [],
  interactive: false,
  knobAngle: 0,
  label: 'AULA F75 Max keyboard',
  spread: 1,
  activeIds: () => new Set<string>(),
  eager: false,
})

const emit = defineEmits<{ select: [key: KeyDef] }>()

const hoveredId = ref<string | null>(null)
const litIds = ref(new Set<string>())
const focusId = ref<string>('q')
const timers = new Map<string, ReturnType<typeof setTimeout>>()

const lightStyles = computed(() =>
  Object.fromEntries(keys.map((key) => [key.id, keyLightStyle(key.x + key.w / 2, props.lighting, props.spread)])),
)
const highlight = computed(() => new Set(props.highlightIds))
const hoveredKey = computed(() => keys.find((k) => k.id === hoveredId.value) ?? null)

const pct = (value: number, total: number) => `${(value / total) * 100}%`

function keyBox(key: { x: number; y: number; w: number }) {
  return { left: pct(key.x, layout.width), top: pct(key.y, layout.height), width: pct(key.w, layout.width), height: pct(1, layout.height) }
}

function press(key: KeyDef) {
  // Reactive effect: light the key, then let it fade.
  litIds.value = new Set(litIds.value).add(key.id)
  clearTimeout(timers.get(key.id))
  timers.set(key.id, setTimeout(() => {
    const next = new Set(litIds.value)
    next.delete(key.id)
    litIds.value = next
  }, 120))
  focusId.value = key.id
  emit('select', key)
}

/** Arrow keys move to the nearest key in that direction. */
function onKeydown(event: KeyboardEvent) {
  const moves: Record<string, [number, number]> = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] }
  const move = moves[event.key]
  if (!move) return
  event.preventDefault()
  const current = keys.find((k) => k.id === focusId.value) ?? keys[0]!
  const [dx, dy] = move
  let best: KeyDef | null = null
  let bestScore = Infinity
  for (const candidate of keys) {
    if (candidate.id === current.id) continue
    const ox = candidate.x + candidate.w / 2 - (current.x + current.w / 2)
    const oy = candidate.y - current.y
    const along = ox * dx + oy * dy
    if (along <= 0.1) continue
    const score = along + (Math.abs(ox * dy) + Math.abs(oy * dx)) * 2
    if (score < bestScore) { bestScore = score; best = candidate }
  }
  if (best) {
    focusId.value = best.id
    nextTick(() => document.getElementById(`key-${uid}-${best!.id}`)?.focus())
  }
}

const uid = useId()

// Keys render once the keyboard nears the viewport. The plate keeps its aspect ratio,
// so the layout doesn't shift, and the server HTML stays small.
const root = shallowRef<HTMLElement | null>(null)
const inView = useInViewOnce(root, '600px 0px')
const nearViewport = computed(() => props.eager || inView.value)
const asset = useAsset()

// Clock on the screen: rendered on the client only, to avoid hydration mismatches.
const now = ref<Date | null>(null)
let clockTimer: ReturnType<typeof setInterval> | undefined
onMounted(() => {
  now.value = new Date()
  clockTimer = setInterval(() => (now.value = new Date()), 15_000)
})
onBeforeUnmount(() => {
  clearInterval(clockTimer)
  timers.forEach(clearTimeout)
})
const clock = computed(() => now.value?.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false }) ?? '')
const date = computed(() => now.value?.toLocaleDateString([], { weekday: 'short', day: 'numeric', month: 'short' }) ?? '')
</script>

<template>
  <div
    ref="root"
    class="kb"
    :class="{ 'kb--dark': dark, [`kb--${lighting.effect}`]: true }"
    :style="{ '--rgb-primary': lighting.color, '--spectrum-duration': `${8 - lighting.speed}s` }"
    role="group"
    :aria-label="label"
  >
    <div class="kb__case">
      <div class="kb__plate">
        <template v-if="nearViewport">
        <!-- Light layer -->
        <div class="kb__leds" aria-hidden="true">
          <span
            v-for="key in keys"
            :key="key.id"
            class="led"
            :class="{ 'led--lit': litIds.has(key.id) || activeIds.has(key.id), 'led--hover': hoveredId === key.id, 'led--hl': highlight.has(key.id) }"
            :style="{ ...keyBox(key), ...lightStyles[key.id] }"
          />
        </div>

        <!-- Keycaps -->
        <component
          :is="interactive ? 'button' : 'span'"
          v-for="key in keys"
          :id="`key-${uid}-${key.id}`"
          :key="key.id"
          :type="interactive ? 'button' : undefined"
          class="cap"
          :class="{ 'cap--selected': selectedId === key.id, 'cap--hl': highlight.has(key.id), 'cap--interactive': interactive, 'cap--lit': litIds.has(key.id) || activeIds.has(key.id), 'cap--down': activeIds.has(key.id) }"
          :style="{ ...keyBox(key), ...lightStyles[key.id] }"
          :tabindex="interactive ? (focusId === key.id ? 0 : -1) : undefined"
          :aria-label="interactive ? key.usage : undefined"
          :aria-pressed="interactive ? selectedId === key.id : undefined"
          :aria-hidden="interactive ? undefined : 'true'"
          @pointerenter="interactive && (hoveredId = key.id)"
          @pointerleave="interactive && hoveredId === key.id && (hoveredId = null)"
          @pointerdown="interactive && press(key)"
          @keydown.enter.prevent="interactive && press(key)"
          @keydown.space.prevent="interactive && press(key)"
          @keydown="interactive && onKeydown($event)"
        >
          <span class="cap__face">
            <span v-if="key.shifted" class="cap__shift">{{ key.shifted }}</span>
            <span class="cap__label" :class="{ 'cap__label--word': (key.mac ?? key.label).length > 2 }">{{ key.mac ?? key.label }}</span>
          </span>
        </component>

        <!-- Screen -->
        <span class="kb__screen" :style="{ left: pct(layout.display.x, layout.width), top: pct(layout.display.y, layout.height), width: pct(layout.display.w, layout.width), height: pct(layout.display.h, layout.height) }" aria-hidden="true">
          <Transition name="screen" mode="out-in">
            <span v-if="dark || screen === 'off'" key="off" class="screen__off" />
            <span v-else-if="screen === 'clock'" key="clock" class="screen__clock">
              <span class="screen__bar"><span>⚡</span><span>82%</span></span>
              <span class="screen__time">{{ clock }}</span>
              <span class="screen__date">{{ date }}</span>
            </span>
            <img v-else-if="screen === 'gif'" key="gif" :src="asset('/images/display/pixel-wave.gif')" alt="" class="screen__img" loading="lazy" decoding="async">
            <img v-else-if="screen === 'image'" key="image" :src="asset('/images/app-icon.webp')" alt="" class="screen__img screen__img--cover" loading="lazy" decoding="async">
            <span v-else-if="screen === 'battery'" key="battery" class="screen__clock">
              <span class="screen__time">82%</span><span class="screen__date">Battery</span>
            </span>
            <span v-else key="cpu" class="screen__clock">
              <span class="screen__time">24%</span><span class="screen__date">CPU</span>
            </span>
          </Transition>
        </span>

        <!-- Knob -->
        <span
          class="kb__knob"
          :style="{ left: pct(layout.knob.x, layout.width), top: pct(layout.knob.y, layout.height), width: pct(layout.knob.size, layout.width), '--angle': `${knobAngle}deg` }"
          aria-hidden="true"
        >
          <span class="knob__face" />
        </span>

        <!-- Hover label -->
        <span
          v-if="interactive && hoveredKey"
          class="kb__tip"
          :style="{ left: pct(hoveredKey.x + hoveredKey.w / 2, layout.width), top: pct(hoveredKey.y, layout.height) }"
          aria-hidden="true"
        >{{ hoveredKey.usage }}</span>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>
.kb {
  container-type: inline-size;
  width: 100%;
}

.kb__case {
  position: relative;
  padding: 3.4cqw;
  border-radius: 2.6cqw;
  background: linear-gradient(180deg, #2a2b30, #151619);
  box-shadow:
    inset 0 1px 0 rgb(255 255 255 / 0.14),
    0 3cqw 8cqw -2cqw rgb(0 0 0 / 0.8);
}

.kb__plate {
  position: relative;
  aspect-ratio: 16 / 6.25;
  border-radius: 1.2cqw;
  background: #0b0c0e;
  box-shadow: inset 0 0.3cqw 0.8cqw rgb(0 0 0 / 0.8);
}

/* ── Light layer ─────────────────────────────── */
.kb__leds {
  position: absolute;
  inset: 0;
}
.kb--spectrum .kb__leds {
  animation: led-spectrum var(--spectrum-duration, 6s) linear infinite;
  will-change: filter;
}
.led {
  position: absolute;
  border-radius: 1cqw;
  opacity: var(--led-strength, 0.85);
  background: rgb(var(--led) / 0.9);
  box-shadow: 0 0 2.2cqw 0.5cqw rgb(var(--led) / 0.75);
  transform: scale(0.86);
  transition: opacity 0.9s var(--ease-out-quint), background-color 0.5s ease, box-shadow 0.5s ease;
}
.kb--spectrum .led {
  filter: hue-rotate(var(--led-hue, 0deg));
}
.kb--wave .led,
.kb--breathing .led {
  animation: var(--led-animation);
  animation-delay: var(--led-delay, 0s);
}
.kb--reactive .led {
  opacity: 0;
}
.kb--reactive .led--lit {
  opacity: 1;
  transition-duration: 0.05s;
}
.led--lit {
  opacity: 1 !important;
  transform: scale(0.96);
  transition-duration: 0.05s;
}
.led--hover {
  opacity: 1 !important;
}
.led--hl {
  opacity: 1 !important;
  animation: none !important;
}
.kb--dark .led {
  opacity: 0 !important;
  animation: none !important;
}

/* ── Keycaps ─────────────────────────────────── */
.cap {
  position: absolute;
  display: block;
  padding: 0.28cqw;
  border-radius: 0.8cqw;
  cursor: default;
  -webkit-tap-highlight-color: transparent;
}
.cap--interactive {
  cursor: pointer;
}
.cap__face {
  position: relative;
  display: flex;
  height: 100%;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 0.7cqw;
  background: linear-gradient(180deg, rgb(46 47 53 / 0.94), rgb(33 34 39 / 0.96));
  box-shadow:
    inset 0 0.08cqw 0 rgb(255 255 255 / 0.08),
    0 0.35cqw 0 rgb(18 19 22 / 0.92);
  transition: transform 0.12s var(--ease-out-quint), background 0.2s ease, box-shadow 0.2s ease;
  color: #e8e8ec;
  line-height: 1;
}
/* Shine-through: light from the LED below catches the lower edge of the cap and the legend. */
.cap__face::after {
  content: "";
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: radial-gradient(130% 95% at 50% 115%, rgb(var(--led) / 0.42), transparent 62%);
  opacity: var(--led-strength, 0.85);
  pointer-events: none;
  transition: opacity 0.9s var(--ease-out-quint);
}
.cap__label,
.cap__shift {
  position: relative;
  text-shadow: 0 0 0.7cqw rgb(var(--led) / 0.55);
}
.kb--wave .cap__face::after,
.kb--breathing .cap__face::after {
  animation: var(--led-animation);
  animation-delay: var(--led-delay, 0s);
}
.kb--spectrum .cap__face::after,
.kb--reactive .cap__face::after {
  opacity: 0;
}
.cap--lit .cap__face::after,
.cap--hl .cap__face::after {
  opacity: 1;
  animation: none;
  transition-duration: 0.05s;
}
.kb--spectrum .cap__label,
.kb--spectrum .cap__shift,
.kb--reactive .cap__label,
.kb--reactive .cap__shift,
.kb--dark .cap__label,
.kb--dark .cap__shift {
  text-shadow: none;
}
.kb--dark .cap__face::after {
  opacity: 0;
  animation: none;
}
.cap--interactive:hover .cap__face {
  background: linear-gradient(180deg, rgb(58 59 66 / 0.95), rgb(38 39 45 / 0.96));
}
.cap--down .cap__face,
.cap--interactive:active .cap__face {
  transform: translateY(0.25cqw);
  box-shadow: inset 0 0.08cqw 0 rgb(255 255 255 / 0.06), 0 0.1cqw 0 rgb(18 19 22 / 0.92);
}
.cap--selected .cap__face {
  box-shadow:
    0 0 0 0.18cqw rgb(255 255 255 / 0.9),
    0 0 1.6cqw rgb(var(--rgb-primary) / 0.8),
    0 0.35cqw 0 rgb(18 19 22 / 0.92);
}
.cap--hl .cap__face {
  box-shadow:
    0 0 0 0.16cqw rgb(var(--rgb-primary) / 0.95),
    0 0.35cqw 0 rgb(18 19 22 / 0.92);
}
.cap__label {
  font-size: 1.35cqw;
  font-weight: 500;
  letter-spacing: -0.01em;
}
.cap__label--word {
  font-size: 0.95cqw;
}
.cap__shift {
  margin-bottom: 0.15cqw;
  font-size: 0.85cqw;
  opacity: 0.55;
}
.cap:focus-visible {
  outline: none;
}
.cap:focus-visible .cap__face {
  box-shadow: 0 0 0 0.2cqw rgb(var(--rgb-primary)), 0 0.35cqw 0 rgb(18 19 22 / 0.92);
}

/* Small containers (phones): keep caps, drop tiny legends. */
@container (max-width: 520px) {
  .cap__shift { display: none; }
  .cap__label--word { font-size: 1.1cqw; }
}

/* ── Screen ──────────────────────────────────── */
.kb__screen {
  position: absolute;
  overflow: hidden;
  padding: 0.25cqw;
  border-radius: 0.7cqw;
  background: #000;
  box-shadow: inset 0 0 0 0.12cqw rgb(255 255 255 / 0.08);
}
.screen__off { display: block; height: 100%; }
.screen__clock {
  display: flex;
  height: 100%;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.2cqw;
  color: #fff;
  font-family: var(--font-sans);
}
.screen__bar { display: flex; width: 100%; justify-content: space-between; padding: 0 0.3cqw; font-size: 0.55cqw; opacity: 0.7; }
.screen__time { font-size: 1.55cqw; font-weight: 700; letter-spacing: -0.03em; color: rgb(var(--rgb-primary)); font-variant-numeric: tabular-nums; }
.screen__date { font-size: 0.6cqw; opacity: 0.7; }
.screen__img { display: block; width: 100%; height: 100%; object-fit: contain; image-rendering: pixelated; border-radius: 0.4cqw; }
.screen__img--cover { object-fit: cover; image-rendering: auto; }
.screen-enter-active, .screen-leave-active { transition: opacity 0.35s ease, transform 0.35s var(--ease-out-quint); }
.screen-enter-from, .screen-leave-to { opacity: 0; transform: scale(0.94); }

/* ── Knob ────────────────────────────────────── */
.kb__knob {
  position: absolute;
  aspect-ratio: 1;
  border-radius: 999px;
  background: conic-gradient(from 0deg, #9a9ca3, #5c5e66, #c4c6cc, #55575e, #9a9ca3);
  box-shadow: 0 0.6cqw 1.2cqw rgb(0 0 0 / 0.6);
  transform: rotate(var(--angle, 0deg));
  transition: transform 0.35s var(--ease-spring);
}
.knob__face {
  position: absolute;
  inset: 13%;
  border-radius: 999px;
  background: radial-gradient(circle at 30% 25%, #3a3b40, #202125);
}
.knob__face::after {
  content: "";
  position: absolute;
  left: 50%;
  top: 12%;
  width: 6%;
  height: 22%;
  translate: -50% 0;
  border-radius: 99px;
  background: rgb(255 255 255 / 0.85);
}

/* ── Tooltip ─────────────────────────────────── */
.kb__tip {
  position: absolute;
  z-index: 5;
  translate: -50% calc(-100% - 0.8cqw);
  padding: 0.5cqw 0.9cqw;
  border-radius: 0.8cqw;
  background: rgb(10 10 12 / 0.85);
  backdrop-filter: blur(12px);
  box-shadow: 0 0 0 1px rgb(255 255 255 / 0.12);
  color: white;
  font-size: max(11px, 1.05cqw);
  font-weight: 500;
  white-space: nowrap;
  pointer-events: none;
}
</style>
