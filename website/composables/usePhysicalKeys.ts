/**
 * Mirrors the visitor's real key presses onto the on-page F75 Max, like the app's live keyboard.
 * Key presses stay in memory for as long as a key is held. Nothing is stored or sent anywhere.
 */

// KeyboardEvent.code → F75 Max key id. In Mac mode the keycap next to Ctrl is Option (⌥), then Command (⌘).
const codeToKey: Record<string, string> = {
  Escape: 'esc', Backquote: 'grave', Minus: 'minus', Equal: 'equal', Backspace: 'backspace', Delete: 'delete',
  Tab: 'tab', BracketLeft: 'lbracket', BracketRight: 'rbracket', Backslash: 'backslash', PageUp: 'pageup',
  CapsLock: 'capslock', Semicolon: 'semicolon', Quote: 'quote', Enter: 'enter', PageDown: 'pagedown',
  ShiftLeft: 'lshift', Comma: 'comma', Period: 'period', Slash: 'slash', ShiftRight: 'rshift', ArrowUp: 'up', End: 'end',
  ControlLeft: 'lctrl', AltLeft: 'lgui', MetaLeft: 'lalt', Space: 'space', MetaRight: 'ralt', ControlRight: 'rctrl',
  ArrowLeft: 'left', ArrowDown: 'down', ArrowRight: 'right',
}
for (let i = 1; i <= 12; i++) codeToKey[`F${i}`] = `f${i}`
for (let i = 0; i <= 9; i++) codeToKey[`Digit${i}`] = `num${i}`
for (const c of 'ABCDEFGHIJKLMNOPQRSTUVWXYZ') codeToKey[`Key${c}`] = c.toLowerCase()

export function usePhysicalKeys(target: Ref<HTMLElement | null>) {
  const held = ref<ReadonlySet<string>>(new Set())
  const last = ref<string | null>(null)
  /** Increments on every new key press (not auto-repeat), so repeated keys can be counted. */
  const presses = ref(0)
  const visible = ref(false)
  const timers = new Map<string, ReturnType<typeof setTimeout>>()

  useIntersectionObserver(target, ([entry]) => {
    visible.value = (entry?.intersectionRatio ?? 0) > 0.35
    if (!visible.value) clear()
  }, { threshold: [0, 0.35, 1] })

  function set(id: string, down: boolean) {
    const next = new Set(held.value)
    if (down) next.add(id)
    else next.delete(id)
    held.value = next
  }

  function clear() {
    timers.forEach(clearTimeout)
    timers.clear()
    if (held.value.size) held.value = new Set()
  }

  function release(id: string) {
    clearTimeout(timers.get(id))
    timers.delete(id)
    set(id, false)
  }

  function isTyping(event: KeyboardEvent) {
    const el = event.target as HTMLElement | null
    return !!el && (el.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(el.tagName))
  }

  useEventListener('keydown', (event: KeyboardEvent) => {
    if (!visible.value || isTyping(event)) return
    const id = codeToKey[event.code]
    if (!id) return
    // Space would scroll the page away from the keyboard while someone is trying it.
    if (id === 'space' && document.activeElement === document.body) event.preventDefault()
    set(id, true)
    last.value = id
    if (!event.repeat) presses.value++
    // macOS doesn't send keyup for keys pressed while ⌘ is held, and Caps Lock only reports toggles,
    // so every key also releases itself.
    clearTimeout(timers.get(id))
    timers.set(id, setTimeout(() => release(id), id === 'capslock' ? 180 : 1200))
  })

  useEventListener('keyup', (event: KeyboardEvent) => {
    const id = codeToKey[event.code]
    if (!id) return
    if (id === 'lalt' || id === 'ralt') clear()
    else release(id)
  })

  useEventListener('blur', clear)
  onBeforeUnmount(clear)

  return { held, last, presses, active: visible }
}
