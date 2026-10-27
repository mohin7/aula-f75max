/**
 * Help guides, each published at /guides/<slug>/ and listed in the sitemap.
 * Every step and option must match the shipping app (Sources/AULAStudio, Sources/AulaKit).
 */
export interface GuideSection {
  heading: string
  paragraphs?: string[]
  /** Numbered steps. */
  steps?: string[]
  /** Bulleted list. */
  list?: string[]
  table?: { head: string[]; rows: string[][] }
  /** Internal link shown after the section. */
  link?: { label: string; to: string }
}

export interface Guide {
  slug: string
  /** The page's h1. */
  title: string
  /** Short name for breadcrumbs and the footer. */
  shortTitle: string
  /** The <title> tag, kept under about 60 characters. */
  metaTitle: string
  description: string
  /** One line for guide cards. */
  summary: string
  /** Date the content last changed in a meaningful way (YYYY-MM-DD). Used for the sitemap and Article schema. */
  updated: string
  intro: string
  sections: GuideSection[]
  related: string[]
}

export const guides: Guide[] = [
  {
    slug: 'setup',
    shortTitle: 'Set up on a Mac',
    title: 'How to set up the AULA F75 Max on a Mac',
    metaTitle: 'How to Set Up the AULA F75 Max on a Mac | AULA Studio',
    description: 'Install the free AULA Studio app, open it the first time, connect your AULA F75 Max and learn which connection does what: USB-C, 2.4G or Bluetooth.',
    summary: 'Install the app, connect the keyboard and allow the permissions it asks for.',
    updated: '2026-10-28',
    intro: 'The AULA F75 Max works as a keyboard on macOS straight away. To change its lighting, screen and settings from a Mac you need an app, because AULA’s own software is for Windows. This guide sets up AULA Studio, a free and open-source app made for macOS.',
    sections: [
      {
        heading: 'What you need',
        list: [
          'A Mac with macOS 15 or later. Apple silicon and Intel Macs both work.',
          'Your AULA F75 Max and its USB-C cable.',
          'About two minutes.',
        ],
      },
      {
        heading: 'Install AULA Studio',
        steps: [
          'Download AULA Studio from the download page. It’s a small disk image (.dmg).',
          'Open the disk image and drag AULA Studio into the Applications folder.',
          'Open AULA Studio from Applications.',
          'The app isn’t notarized by Apple yet, so macOS asks you to confirm the first time. Open System Settings → Privacy & Security and click Open Anyway. You only do this once.',
        ],
        link: { label: 'Download AULA Studio for Mac', to: '/download/' },
      },
      {
        heading: 'Connect the keyboard with the USB-C cable',
        paragraphs: [
          'Plug the F75 Max into your Mac with the USB-C cable. AULA Studio finds it on its own; there’s no driver to install. The keyboard clock syncs with your Mac as soon as you plug in.',
          'Use the cable whenever you want to change something. The F75 Max only accepts lighting, screen and setting changes over USB-C, and it keeps them when you unplug and go back to wireless.',
        ],
      },
      {
        heading: 'What works over each connection',
        table: {
          head: ['', 'USB-C', '2.4G', 'Bluetooth'],
          rows: [
            ['Live key preview', 'Yes', 'Yes', 'Yes'],
            ['Lighting, screen, clock and settings', 'Yes', 'Not yet', 'No, the keyboard doesn’t allow it'],
            ['Battery level', 'Charging', 'Not reported yet', 'Yes'],
          ],
        },
        paragraphs: [
          'Over Bluetooth the F75 Max has no channel for settings, so this isn’t something an app can work around. Switching between Bluetooth devices is done on the keyboard itself with Fn+1, Fn+2 and Fn+3.',
        ],
      },
      {
        heading: 'Allow Input Monitoring for the live key preview',
        paragraphs: [
          'The Dashboard shows an on-screen F75 Max that lights up as you type and turn the knob, and Settings has a Key Tester. Both need macOS’s Input Monitoring permission. They’re optional: lighting, the screen and settings work without it.',
          'Click Allow on the Dashboard notice. If you turned it down before, open System Settings → Privacy & Security → Input Monitoring and switch on AULA Studio. The app uses key presses only to animate the on-screen keyboard. It never records or stores what you type, and it has no network access.',
        ],
      },
      {
        heading: 'Allow Bluetooth for the battery level',
        paragraphs: [
          'The F75 Max reports its battery level and firmware version over Bluetooth only. When macOS asks, allow AULA Studio to use Bluetooth, and the Dashboard shows the live level. The last reading is remembered while you’re on the cable.',
        ],
      },
      {
        heading: 'Match the Win/Mac switch',
        paragraphs: [
          'The F75 Max has a Win/Mac switch. In AULA Studio, open Settings → Keyboard → Legends and pick the same option (Mac or Win), so the on-screen keyboard shows the right modifier keys.',
        ],
      },
      {
        heading: 'If the keyboard doesn’t show up',
        list: [
          'If AULA Studio says “Connect USB-C to change these”, the keyboard is connected over Bluetooth or 2.4G. Plug in the cable.',
          'Settings → Developer → HID interfaces lists every AULA interface the app can see. Include it if you report a problem.',
          'No keyboard at hand? Settings → Developer → Demo keyboard simulates a wired F75 Max, so you can look around first.',
        ],
      },
    ],
    related: ['rgb-lighting', 'screen-gif', 'keyboard-settings'],
  },
  {
    slug: 'rgb-lighting',
    shortTitle: 'RGB lighting',
    title: 'How to change the AULA F75 Max RGB lighting on a Mac',
    metaTitle: 'Change AULA F75 Max RGB Lighting on a Mac | AULA Studio',
    description: 'Choose any of the AULA F75 Max’s 20 built-in lighting effects from macOS, then set the color, brightness, speed and direction. Free, no driver needed.',
    summary: 'All 20 built-in effects, with color, brightness, speed and direction.',
    updated: '2026-10-28',
    intro: 'The F75 Max has 20 lighting effects built into its firmware. AULA Studio lets you pick any of them from your Mac and adjust it, with a live preview on an on-screen keyboard. The keyboard confirms every change.',
    sections: [
      {
        heading: 'Change the lighting',
        steps: [
          'Connect the keyboard with the USB-C cable.',
          'Open AULA Studio and choose Lighting in the sidebar.',
          'Click an effect. It applies to the keyboard straight away.',
          'Pick a color, then set brightness, speed and, for some effects, direction.',
        ],
        paragraphs: [
          'Without the cable, the Lighting page still previews effects, but it says “Preview only” and doesn’t change the keyboard. Once set, the lighting stays on the keyboard after you unplug.',
        ],
      },
      {
        heading: 'All 20 lighting effects',
        paragraphs: [
          'These are the names AULA Studio uses. Reactive, Reactive Fade, Ripple, Explode and Launch light up as you press keys.',
        ],
        list: [
          'Off and Static',
          'Reactive and Reactive Fade',
          'Glitter, Rain and Colourful',
          'Breathing and Spectrum Cycle',
          'Outward, Wave, Rolling and Rotating',
          'Explode, Launch and Ripple',
          'Flowing, Pulse, Tilt and Shuttle',
        ],
      },
      {
        heading: 'Color, brightness, speed and direction',
        table: {
          head: ['Control', 'Options'],
          rows: [
            ['Color', 'Preset swatches, a hue strip, a hex field or the macOS color picker. Turn on Multicolor to use the firmware’s rainbow palette instead.'],
            ['Brightness', 'Five levels, from 20% to 100%.'],
            ['Speed', 'Five levels, for every animated effect.'],
            ['Direction', 'Right, Down, Left or Up, for Rain, Wave, Rolling, Flowing, Tilt and Shuttle.'],
          ],
        },
        paragraphs: [
          'Spectrum Cycle always uses its own colors, so the color controls are greyed out for it and for Off.',
        ],
      },
      {
        heading: 'Change the lighting from the menu bar',
        paragraphs: [
          'AULA Studio also has a menu bar icon with quick lighting controls and the keyboard’s status. You can hide it in Settings → General → Show menu bar icon.',
        ],
      },
      {
        heading: 'What isn’t supported yet',
        list: [
          'Per-key colors, where you paint each key by hand.',
          'Software effects that react to music or CPU load. These aren’t built into the firmware and are planned for later.',
        ],
      },
    ],
    related: ['screen-gif', 'keyboard-settings', 'setup'],
  },
  {
    slug: 'screen-gif',
    shortTitle: 'GIFs on the screen',
    title: 'How to put a GIF on the AULA F75 Max screen from a Mac',
    metaTitle: 'Put a GIF on the AULA F75 Max Screen from a Mac | AULA Studio',
    description: 'Upload a picture or animated GIF to the AULA F75 Max’s 128×128 screen from macOS. Which formats work, Fit, Fill or Stretch, and how many frames fit.',
    summary: 'Upload pictures and animated GIFs to the 128×128 screen.',
    updated: '2026-10-28',
    intro: 'The F75 Max has a small 128×128 pixel screen. AULA Studio can put any picture or animated GIF on it from your Mac, and shows you a preview before it uploads.',
    sections: [
      {
        heading: 'Upload a picture or GIF',
        steps: [
          'Connect the keyboard with the USB-C cable.',
          'Open AULA Studio and choose Display in the sidebar.',
          'Drop an image or GIF onto the preview, or click Choose File….',
          'Choose how it fits the square screen: Fit, Fill or Stretch.',
          'Click Upload to Keyboard and keep the cable connected until the upload finishes.',
        ],
        paragraphs: [
          'Before you upload, the Display page shows the number of frames, the animation length and an upload time estimate. When it’s done, the app tells you the keyboard confirmed every part of the upload.',
        ],
      },
      {
        heading: 'Supported files',
        list: [
          'PNG, JPEG, GIF, HEIC, WebP, BMP or TIFF.',
          'Animations keep up to 255 frames. Longer GIFs are cut at frame 255.',
          'Every frame is resized to 128×128 pixels, so square images look best.',
        ],
      },
      {
        heading: 'Fit, Fill or Stretch',
        table: {
          head: ['Option', 'What it does'],
          rows: [
            ['Fit', 'Shows the whole image, with black bars if it isn’t square.'],
            ['Fill', 'Fills the screen and crops what doesn’t fit. This is the default.'],
            ['Stretch', 'Fills the screen by stretching the image to a square.'],
          ],
        },
      },
      {
        heading: 'Tips for a sharp screen',
        list: [
          'Pixel art made at exactly 128×128 stays crisp, because it isn’t resized.',
          'Upload over USB-C only. Over Bluetooth the Display page says “Connect USB-C to upload”.',
        ],
      },
      {
        heading: 'From the command line',
        paragraphs: [
          'If you build AULA Studio from source, the aulactl developer tool can upload too: aulactl upload picture.gif fill. Add --trace to see each packet.',
        ],
      },
    ],
    related: ['rgb-lighting', 'keyboard-settings', 'setup'],
  },
  {
    slug: 'keyboard-settings',
    shortTitle: 'Keyboard settings',
    title: 'AULA F75 Max settings on a Mac: key response, sleep, key locks and clock',
    metaTitle: 'AULA F75 Max Sleep, Key Lock and Clock Settings on Mac',
    description: 'Change the AULA F75 Max key response time, sleep timer, Windows and Alt+Tab locks and Fn switch from macOS, and keep the keyboard clock in sync.',
    summary: 'Key response, sleep timer, key locks, the Fn switch and clock sync.',
    updated: '2026-10-28',
    intro: 'The F75 Max’s own settings, like the sleep timer and the key locks, are in AULA Studio under Settings → Keyboard. Changes apply instantly over the USB-C cable, and the keyboard keeps them.',
    sections: [
      {
        heading: 'Key response time',
        paragraphs: [
          'Choose a level from 1 (fastest) to 5 (most stable). Raise it if keys type twice. The app shows AULA’s published latency for each level:',
        ],
        table: {
          head: ['Level', 'Wired', '2.4G', 'Bluetooth'],
          rows: [
            ['1 · Fastest', '2–3 ms', '5–6 ms', '12–13 ms'],
            ['2', '5–6 ms', '7–9 ms', '15–16 ms'],
            ['3', '8–9 ms', '10–12 ms', '18–19 ms'],
            ['4', '13–14 ms', '15–17 ms', '23–24 ms'],
            ['5 · Stable', '17–18 ms', '19–21 ms', '27–28 ms'],
          ],
        },
      },
      {
        heading: 'Sleep timer',
        paragraphs: [
          'Sleep after sets how long the keyboard waits before sleeping on battery: Never, 1 min, 5 min or 30 min.',
        ],
      },
      {
        heading: 'Key locks and the Fn switch',
        table: {
          head: ['Setting', 'What it does'],
          rows: [
            ['Disable Windows / ⌘ key', 'Stops accidental presses, for example while gaming.'],
            ['Disable Alt + F4', 'Turns off the Alt+F4 shortcut on the keyboard.'],
            ['Disable Alt + Tab', 'Turns off the Alt+Tab shortcut on the keyboard.'],
            ['Fn switch', 'Swaps the top row between F1–F12 and media keys.'],
          ],
        },
      },
      {
        heading: 'Keyboard clock',
        paragraphs: [
          'With Sync automatically on, AULA Studio sets the keyboard clock when you plug in the cable, after your Mac wakes, when the time zone changes and every hour while connected. Sync Now does it straight away.',
          'Keyboard clock format switches between 24-hour and 12-hour. The firmware has no AM/PM, so in 12-hour mode the app corrects the clock every hour while the cable is connected. On Bluetooth or unplugged it can show 13:00 until the next sync.',
        ],
      },
      {
        heading: 'Battery level',
        paragraphs: [
          'The Dashboard shows the live battery level over Bluetooth, with an estimate of the time left. On the cable it shows that the keyboard is charging and remembers the last Bluetooth reading.',
        ],
      },
      {
        heading: 'Not available yet',
        paragraphs: [
          'Key remapping, macros and profiles aren’t in AULA Studio yet. They’re planned for future versions. AULA Studio never flashes firmware, so firmware updates aren’t part of it.',
        ],
      },
    ],
    related: ['rgb-lighting', 'screen-gif', 'setup'],
  },
]

export function findGuide(slug: string) {
  return guides.find((guide) => guide.slug === slug)
}
