/** Facts about the app that the whole site relies on. Keep these true to the shipping app. */
export const site = {
  name: 'AULA Studio',
  tagline: 'Your keyboard. Your way.',
  title: 'AULA Studio: Native macOS App for the AULA F75 Max Keyboard',
  description:
    'Free, open-source macOS app for the AULA F75 Max. Change lighting, put GIFs on the screen, sync the clock and tune settings. No drivers needed.',
  keyboard: 'AULA F75 Max',
  requirements: 'macOS 15 or later',
  architectures: 'Apple silicon and Intel',
  license: 'MIT',
  author: {
    name: 'mohin7',
    github: 'https://github.com/mohin7',
    linkedin: 'https://www.linkedin.com/in/mohin7/',
  },
} as const

/** Paths inside the GitHub repository, joined with the repo URL at runtime. */
export const repoPaths = {
  readme: '#readme',
  contributing: '/blob/main/CONTRIBUTING.md',
  security: '/blob/main/SECURITY.md',
  roadmap: '/blob/main/Docs/Roadmap.md',
  protocol: '/blob/main/Docs/Hardware-Protocol-Notes.md',
  license: '/blob/main/LICENSE',
  issues: '/issues/new',
  releases: '/releases',
} as const
