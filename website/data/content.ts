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

/** Install steps, shown on the home page and the download page. */
export const installSteps = [
  { title: 'Download', body: 'Click the button. AULA Studio downloads as a small disk image.' },
  { title: 'Drag to Applications', body: 'Open the downloaded file and drag AULA Studio into the Applications folder.' },
  { title: 'Allow it once', body: 'The first time, open System Settings → Privacy & Security and click Open Anyway.' },
] as const

/** FAQ on the download page, also published as FAQPage structured data. Keep answers factual. */
export const downloadFaqs = [
  { q: 'Is there an official AULA F75 Max driver for Mac?', a: 'AULA doesn’t make software for Mac; its F75 Max software is for Windows. AULA Studio is an independent, free alternative made for macOS. It isn’t affiliated with AULA or Epomaker.' },
  { q: 'Do I need to install a driver?', a: 'No. macOS already sees the F75 Max as a keyboard. AULA Studio talks to it through Apple’s own IOKit and CoreBluetooth frameworks, with no kernel extension or driver.' },
  { q: 'Can I remap keys or record macros?', a: 'Not yet. Key mapping, macros and profiles are planned for future versions.' },
  { q: 'Does it work with other AULA keyboards?', a: 'Only the AULA F75 Max is supported today. It was tested on an F75 Max with its 2024 firmware. Support for other AULA models is being explored.' },
  { q: 'Will it change my keyboard’s firmware?', a: 'No. AULA Studio reads the firmware version but never flashes firmware. Every command it sends only changes settings you can change back.' },
  { q: 'Is it safe to download?', a: 'The app is open source under the MIT License, so anyone can read the code. It has no network access and never records what you type. It isn’t notarized by Apple yet, which is why macOS asks you to confirm the first time.' },
] as const
