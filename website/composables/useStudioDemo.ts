import type { InjectionKey } from 'vue'
import { lightingModes, type SectionId } from '~/data/app-ui'
import type { LightingState } from '~/composables/useKeyboardRGB'

/** State for one recreated AULA Studio window. Lives in memory only. */
export function createStudioDemo(section: SectionId = 'dashboard') {
  const state = reactive({
    section,
    mode: 'scrolling',
    color: '139 92 246',
    brightness: 4,
    speed: 3,
    multicolor: false,
    responseLevel: 1,
    sleep: '5 min' as string,
    disableWindowsKey: false,
    disableAltF4: true,
    disableAltTab: false,
    fnSwitch: false,
    autoSync: true,
    twelveHour: true,
  })

  const mode = computed(() => lightingModes.find((m) => m.id === state.mode) ?? lightingModes[0]!)

  /** What the on-page keyboard animates. */
  const lighting = computed<LightingState>(() => {
    const demo = mode.value.demo
    const effect = demo === 'off' ? 'static' : state.multicolor && demo !== 'reactive' ? 'spectrum' : demo
    return { effect, color: state.color, brightness: state.brightness, speed: state.speed }
  })
  const lightsOff = computed(() => mode.value.demo === 'off')

  return { state, mode, lighting, lightsOff }
}

export type StudioDemo = ReturnType<typeof createStudioDemo>

const key: InjectionKey<StudioDemo> = Symbol('studio-demo')

export function provideStudioDemo(demo: StudioDemo) {
  provide(key, demo)
}

export function useStudioDemo() {
  const demo = inject(key)
  if (!demo) throw new Error('useStudioDemo() needs an <AppWindow> ancestor')
  return demo
}

/** A clock that ticks every second on the client and renders nothing on the server. */
export function useLiveClock() {
  const now = ref<Date | null>(null)
  let timer: ReturnType<typeof setInterval> | undefined
  onMounted(() => {
    now.value = new Date()
    timer = setInterval(() => (now.value = new Date()), 1000)
  })
  onBeforeUnmount(() => clearInterval(timer))
  return now
}
