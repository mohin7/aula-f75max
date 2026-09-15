import { useMounted, usePreferredReducedMotion } from '@vueuse/core'

/**
 * True when the visitor asked for reduced motion. It stays `false` on the server and until the
 * component has mounted, so the first client render matches the server HTML (no hydration mismatch).
 */
export function useReducedMotion() {
  const preference = usePreferredReducedMotion()
  const mounted = useMounted()
  return computed(() => mounted.value && preference.value === 'reduce')
}

/** Fine pointer (mouse or trackpad) and not reduced motion: the only case where hover effects run. */
export function useRichPointer() {
  const reduced = useReducedMotion()
  const finePointer = useMediaQuery('(hover: hover) and (pointer: fine)')
  return computed(() => finePointer.value && !reduced.value)
}

/**
 * Pointer parallax for one element. Pointer moves are coalesced into a single
 * requestAnimationFrame write of two CSS variables, so layout is never touched.
 */
export function useMouseParallax(target: Ref<HTMLElement | null>, strength = 1) {
  const enabled = useRichPointer()
  let frame = 0
  let nextX = 0
  let nextY = 0

  function write() {
    frame = 0
    target.value?.style.setProperty('--px', nextX.toFixed(3))
    target.value?.style.setProperty('--py', nextY.toFixed(3))
  }

  function onMove(event: PointerEvent) {
    if (!enabled.value || !target.value) return
    const rect = target.value.getBoundingClientRect()
    nextX = ((event.clientX - rect.left) / rect.width - 0.5) * strength
    nextY = ((event.clientY - rect.top) / rect.height - 0.5) * strength
    if (!frame) frame = requestAnimationFrame(write)
  }

  function reset() {
    nextX = 0
    nextY = 0
    if (!frame) frame = requestAnimationFrame(write)
  }

  useEventListener(target, 'pointermove', onMove, { passive: true })
  useEventListener(target, 'pointerleave', reset, { passive: true })
  onBeforeUnmount(() => cancelAnimationFrame(frame))
}

/** Becomes true once the element has entered the viewport (never flips back). */
export function useInViewOnce(target: Ref<HTMLElement | null>, rootMargin = '0px 0px -15% 0px') {
  const seen = ref(false)
  const { stop } = useIntersectionObserver(target, ([entry]) => {
    if (entry?.isIntersecting) {
      seen.value = true
      stop()
    }
  }, { rootMargin })
  return seen
}
