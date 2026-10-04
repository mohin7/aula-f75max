import type { SectionId } from '~/data/app-ui'

/**
 * Capabilities shown in "Everything in one place".
 * `status` must stay honest: 'available' only for features the shipping app has.
 */
export type FeatureStatus = 'available' | 'coming-soon'

export interface Feature {
  id: string
  name: string
  status: FeatureStatus
  headline: string
  description: string
  /** RGB triplet used as the accent while the feature is selected. */
  accent: string
  /** Page shown in the recreated app window. */
  section: SectionId
}

export const features: Feature[] = [
  {
    id: 'lighting',
    section: 'lighting',
    name: 'Lighting',
    status: 'available',
    headline: 'Every built-in effect, one click away',
    description: 'Choose from all 20 firmware effects, pick a color, and set brightness, speed and direction. The on-screen keyboard previews it instantly, and the keyboard confirms every change.',
    accent: '139 92 246',
  },
  {
    id: 'display',
    section: 'display',
    name: 'Display',
    status: 'available',
    headline: 'Put your art on the screen',
    description: 'Upload pictures and animated GIFs to the 128×128 display. Choose Fit, Fill or Stretch, preview the animation, and watch the upload progress.',
    accent: '34 211 238',
  },
  {
    id: 'settings',
    section: 'settings',
    name: 'Keyboard settings',
    status: 'available',
    headline: 'Tune how it feels and behaves',
    description: 'Set key response time, the sleep timer, key locks for Windows, Alt+F4 and Alt+Tab, and the Fn switch. The keyboard clock syncs with your Mac automatically.',
    accent: '52 211 153',
  },
  {
    id: 'dashboard',
    section: 'dashboard',
    name: 'Battery & status',
    status: 'available',
    headline: 'See everything at a glance',
    description: 'Battery level over Bluetooth, connection type, firmware version and a live keyboard that mirrors your key presses and knob turns.',
    accent: '59 130 246',
  },
  {
    id: 'keymap',
    section: 'keymap',
    name: 'Key mapping',
    status: 'coming-soon',
    headline: 'Every key can do more',
    description: 'Remap keys to shortcuts, apps and media controls. In development.',
    accent: '251 146 60',
  },
  {
    id: 'macros',
    section: 'macros',
    name: 'Macros',
    status: 'coming-soon',
    headline: 'Automate the repetitive',
    description: 'Record and edit sequences of keys and delays on a timeline. Planned for a future release.',
    accent: '236 72 153',
  },
  {
    id: 'profiles',
    section: 'profiles',
    name: 'Profiles',
    status: 'coming-soon',
    headline: 'One keyboard, every workflow',
    description: 'Save lighting and settings as profiles and switch between them. Planned for a future release.',
    accent: '168 85 247',
  },
  {
    id: 'safety',
    section: 'firmware',
    name: 'Firmware safety',
    status: 'available',
    headline: 'Your keyboard stays safe',
    description: 'AULA Studio reads the firmware version but never flashes firmware. Every command it sends only changes settings you can change back.',
    accent: '250 204 21',
  },
]
