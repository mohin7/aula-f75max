/** Effects the website can animate with CSS. The keyboard's 20 real modes are in data/app-ui.ts. */
export type EffectId = 'static' | 'wave' | 'breathing' | 'spectrum' | 'reactive'

/** Swatches from the app's color picker (sRGB, "r g b"). */
export const swatches = [
  { name: 'Violet', rgb: '139 92 246' },
  { name: 'Blue', rgb: '59 130 246' },
  { name: 'Cyan', rgb: '34 211 238' },
  { name: 'Green', rgb: '52 211 153' },
  { name: 'Pink', rgb: '236 72 153' },
  { name: 'Orange', rgb: '251 146 60' },
] as const
