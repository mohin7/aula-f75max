/** Short facts for "Light, native and private." Qualitative only: no invented numbers. */
export const performance = [
  { title: 'Native SwiftUI', body: 'Built with Apple’s own frameworks. No Electron, no web views.' },
  { title: 'No drivers', body: 'Uses standard macOS HID and Bluetooth. Nothing extra to install.' },
  { title: 'Live sync over USB-C', body: 'Changes apply as you make them, and the keyboard confirms each one.' },
  { title: 'Universal', body: 'Runs natively on Apple silicon and Intel, macOS 15 or later.' },
  { title: 'Private by design', body: 'No network access, no analytics, no accounts. Typing is never recorded.' },
] as const

/** FAQ, also published as FAQPage structured data. Keep answers factual. */
export const faqs = [
  { q: 'Which keyboards are supported?', a: 'The AULA F75 Max. Support for other AULA models is being explored but isn’t available yet.' },
  { q: 'Does it work over Bluetooth?', a: 'Partly. Over Bluetooth you get live key presses, battery level and firmware version. The F75 Max only accepts setting changes over the USB-C cable, so plug it in to change lighting, the screen and settings. The keyboard keeps them when you switch back.' },
  { q: 'How do I open it the first time?', a: 'Drag AULA Studio into Applications and open it. macOS will ask you to confirm because the app isn’t notarized by Apple yet: go to System Settings → Privacy & Security and click Open Anyway. You only do this once.' },
  { q: 'Does it support Apple silicon?', a: 'Yes. AULA Studio is a universal app for Apple silicon and Intel Macs running macOS 15 or later. No drivers needed.' },
  { q: 'Can I remap keys or create macros?', a: 'Not yet. Key mapping, macros and profiles are planned for future versions.' },
  { q: 'Is it official? Is it safe?', a: 'It’s an independent, free and open-source app, not affiliated with AULA or Epomaker. It has no network access, never records what you type, and never changes your keyboard’s firmware.' },
] as const

/** Interactive previews for features in development. Clearly labeled as previews on the page. */
export const keymapPresets: Record<string, { action: string; kind: string }> = {
  capslock: { action: '⌘ Space', kind: 'Keyboard shortcut' },
  f1: { action: 'Play / Pause', kind: 'Media' },
  f2: { action: 'Open Safari', kind: 'App' },
  esc: { action: 'Esc', kind: 'Default' },
  q: { action: 'Q', kind: 'Default' },
}

export const macroSteps = [
  { key: '⌘', label: 'Hold Command', type: 'key' },
  { key: '⇧', label: 'Hold Shift', type: 'key' },
  { key: 'P', label: 'Press P', type: 'key' },
  { key: '120 ms', label: 'Delay', type: 'delay' },
  { key: 'Aa', label: 'Type “format”', type: 'text' },
  { key: '↩', label: 'Press Return', type: 'key' },
] as const

export const profiles = [
  { id: 'work', name: 'Work', accent: '59 130 246', effect: 'static', highlight: ['capslock', 'f1', 'f2'], knob: 'Volume' },
  { id: 'coding', name: 'Coding', accent: '52 211 153', effect: 'wave', highlight: ['lalt', 'p', 'lshift'], knob: 'Scroll' },
  { id: 'gaming', name: 'Gaming', accent: '239 68 68', effect: 'reactive', highlight: ['w', 'a', 's', 'd'], knob: 'Volume' },
  { id: 'design', name: 'Design', accent: '168 85 247', effect: 'breathing', highlight: ['v', 'b', 'lalt', 'space'], knob: 'Zoom' },
  { id: 'video', name: 'Video', accent: '251 146 60', effect: 'spectrum', highlight: ['j', 'k', 'l', 'space'], knob: 'Timeline' },
] as const

export const knobModes = [
  { id: 'volume', name: 'Volume', unit: '%', min: 0, max: 100, start: 45, available: true },
  { id: 'brightness', name: 'Brightness', unit: '%', min: 0, max: 100, start: 70, available: false },
  { id: 'zoom', name: 'Zoom', unit: '%', min: 25, max: 400, start: 100, available: false },
  { id: 'timeline', name: 'Timeline', unit: 's', min: 0, max: 120, start: 18, available: false },
] as const

export const howItWorks = [
  { step: '01', title: 'Download and install', body: 'Download the app, drag it into Applications, and allow it once in System Settings → Privacy & Security.' },
  { step: '02', title: 'Connect your F75 Max', body: 'Plug in the USB-C cable to change settings. Over Bluetooth, the app shows live keys, battery and firmware.' },
  { step: '03', title: 'Customize', body: 'Change lighting, upload to the screen and tune settings. The keyboard keeps them when you switch back to Bluetooth.' },
] as const

export const docs = [
  { title: 'Getting started', body: 'Install, connect your keyboard and build from source.', path: 'readme' },
  { title: 'Lighting & display', body: 'What each feature does and which connection it needs.', path: 'readme' },
  { title: 'Protocol notes', body: 'Verified USB-C and Bluetooth details for the F75 Max.', path: 'protocol' },
  { title: 'Roadmap', body: 'What’s built, what’s next: key mapping, macros, profiles.', path: 'roadmap' },
  { title: 'Security & privacy', body: 'What the app does and doesn’t do, and how to report issues.', path: 'security' },
] as const
