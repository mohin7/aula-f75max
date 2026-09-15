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
