import { guides } from './guides'

/**
 * Every indexable page, used for prerendering and the sitemap.
 * Bump `updated` (YYYY-MM-DD) when a page's content changes in a way that matters to readers.
 */
export const sitePages: ReadonlyArray<{ path: string; updated: string }> = [
  { path: '/', updated: '2026-10-28' },
  { path: '/download/', updated: '2026-10-28' },
  { path: '/guides/', updated: guides.map((g) => g.updated).sort().at(-1)! },
  ...guides.map((g) => ({ path: `/guides/${g.slug}/`, updated: g.updated })),
]
