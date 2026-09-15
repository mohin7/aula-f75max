import type { EffectId } from '~/data/lighting'
import { keys, layout } from '~/data/keyboard-layout'

export interface LightingState {
  effect: EffectId
  /** "r g b" */
  color: string
  /** 1–5, like the firmware. */
  brightness: number
  /** 1–5, like the firmware. */
  speed: number
}

/**
 * Turns lighting settings into per-key CSS variables. Nothing runs per frame:
 * the effects themselves are CSS animations, so JavaScript only reruns when settings change.
 */
export function keyLightStyle(keyX: number, state: LightingState, spread = 1) {
  const position = keyX / layout.width
  const duration = 3.4 - state.speed * 0.5 // seconds: 2.9 (slow) → 0.9 (fast)
  const style: Record<string, string> = {
    '--led': state.color,
    '--led-strength': String(0.25 + state.brightness * 0.15),
  }

  switch (state.effect) {
    case 'wave':
      style['--led-animation'] = `led-wave ${duration}s ease-in-out infinite`
      style['--led-delay'] = `${-(position * duration * spread).toFixed(3)}s`
      break
    case 'breathing':
      style['--led-animation'] = `led-breathe ${duration * 1.6}s ease-in-out infinite`
      style['--led-delay'] = '0s'
      break
    case 'spectrum': {
      // Hue spread across the board; the keyboard container animates hue-rotate.
      const hue = Math.round(position * 300 * spread)
      style['--led-hue'] = `${hue}deg`
      break
    }
    default:
      break
  }
  return style
}
