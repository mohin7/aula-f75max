import type { EffectId } from '~/data/lighting'

/**
 * Labels and options for the recreated AULA Studio interface.
 * Every name here matches the shipping app (Sources/AULAStudio and Sources/AulaKit).
 */

export type SectionId = 'dashboard' | 'lighting' | 'display' | 'keymap' | 'macros' | 'profiles' | 'firmware' | 'settings'

export const appSections: ReadonlyArray<{ id: SectionId; title: string; soon?: boolean; icon: string }> = [
  { id: 'dashboard', title: 'Dashboard', icon: 'M4 4h7v7H4zM13 4h7v7h-7zM4 13h7v7H4zM13 13h7v7h-7z' },
  { id: 'lighting', title: 'Lighting', icon: 'M12 3v2M12 19v2M4.2 4.2l1.4 1.4M18.4 18.4l1.4 1.4M3 12h2M19 12h2M4.2 19.8l1.4-1.4M18.4 5.6l1.4-1.4M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z' },
  { id: 'display', title: 'Display', icon: 'M4 5h16v12H4zM4 14l4-4 4 4 3-3 5 5M15.5 8.5h.01' },
  { id: 'keymap', title: 'Keymap', soon: true, icon: 'M3 7h18v10H3zM7 10h.01M11 10h.01M15 10h.01M8 14h8' },
  { id: 'macros', title: 'Macros', soon: true, icon: 'M12 4a8 8 0 1 0 0 16 8 8 0 0 0 0-16zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z' },
  { id: 'profiles', title: 'Profiles', soon: true, icon: 'M7 4h10v4H7zM5 10h14v4H5zM3 16h18v4H3z' },
  { id: 'firmware', title: 'Firmware', icon: 'M7 7h10v10H7zM10 10h4v4h-4zM10 3v4M14 3v4M10 17v4M14 17v4M3 10h4M3 14h4M17 10h4M17 14h4' },
  { id: 'settings', title: 'Settings', icon: 'M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6zM19.4 13a7.5 7.5 0 0 0 0-2l2-1.5-2-3.5-2.4 1a7 7 0 0 0-1.7-1L15 3.5h-4L10.7 6a7 7 0 0 0-1.7 1l-2.4-1-2 3.5 2 1.5a7.5 7.5 0 0 0 0 2l-2 1.5 2 3.5 2.4-1a7 7 0 0 0 1.7 1l.3 2.5h4l.3-2.5a7 7 0 0 0 1.7-1l2.4 1 2-3.5z' },
]

/**
 * The keyboard's 20 lighting modes, as named in the app.
 * `demo` is the closest effect the website can animate with CSS; the keyboard renders the real one.
 */
export const lightingModes: ReadonlyArray<{ id: string; name: string; demo: EffectId | 'off'; direction?: boolean }> = [
  { id: 'off', name: 'Off', demo: 'off' },
  { id: 'static', name: 'Static', demo: 'static' },
  { id: 'single-on', name: 'Reactive', demo: 'reactive' },
  { id: 'single-off', name: 'Reactive Fade', demo: 'reactive' },
  { id: 'glittering', name: 'Glitter', demo: 'breathing' },
  { id: 'falling', name: 'Rain', demo: 'wave', direction: true },
  { id: 'colourful', name: 'Colourful', demo: 'spectrum' },
  { id: 'breathing', name: 'Breathing', demo: 'breathing' },
  { id: 'spectrum', name: 'Spectrum Cycle', demo: 'spectrum' },
  { id: 'outward', name: 'Outward', demo: 'wave' },
  { id: 'scrolling', name: 'Wave', demo: 'wave', direction: true },
  { id: 'rolling', name: 'Rolling', demo: 'wave', direction: true },
  { id: 'rotating', name: 'Rotating', demo: 'spectrum' },
  { id: 'explode', name: 'Explode', demo: 'reactive' },
  { id: 'launch', name: 'Launch', demo: 'reactive' },
  { id: 'ripples', name: 'Ripple', demo: 'reactive' },
  { id: 'flowing', name: 'Flowing', demo: 'wave', direction: true },
  { id: 'pulsating', name: 'Pulse', demo: 'breathing' },
  { id: 'tilt', name: 'Tilt', demo: 'wave', direction: true },
  { id: 'shuttle', name: 'Shuttle', demo: 'wave', direction: true },
]

export const sleepOptions = ['Never', '1 min', '5 min', '30 min'] as const

/** AULA's published latency figures for each key response level, as shown in the app. */
export const responseLevels: Record<number, string> = {
  1: 'Wired 2–3 ms · 2.4G 5–6 ms · Bluetooth 12–13 ms',
  2: 'Wired 5–6 ms · 2.4G 7–9 ms · Bluetooth 15–16 ms',
  3: 'Wired 8–9 ms · 2.4G 10–12 ms · Bluetooth 18–19 ms',
  4: 'Wired 13–14 ms · 2.4G 15–17 ms · Bluetooth 23–24 ms',
  5: 'Wired 17–18 ms · 2.4G 19–21 ms · Bluetooth 27–28 ms',
}

/** Sample images for the Display page. Both are original artwork made for this site. */
export const displaySamples = [
  { id: 'wave', name: 'pixel-wave.gif', src: '/images/display/pixel-wave.gif', frames: 24, pixelated: true },
  { id: 'dusk', name: 'dusk.svg', src: '/images/display/dusk.svg', frames: 1, pixelated: false },
] as const

/**
 * Chunks the app sends for an upload: a 256-byte header plus 128×128 RGB565 frames, in 4096-byte reports.
 */
export function uploadChunks(frames: number) {
  return Math.ceil((256 + frames * 128 * 128 * 2) / 4096)
}
