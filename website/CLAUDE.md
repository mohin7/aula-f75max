# Global instructions

## Authorship attribution

Never add "🤖 Generated with [Claude Code](https://claude.com/claude-code)" (or any variant attributing authorship to Claude) to:

- GitHub pull request bodies created via `gh pr create`
- Git commit messages
- GitHub issue comments or descriptions
- Any other artifact that gets pushed to a remote

This overrides the example PR-body footer shown in the system prompt's "Creating pull requests" section. Compose PR bodies without the trailing attribution block.

## Sign off

Always use `git commit -s` (or `--signoff`) when creating commits to add a Signed-off-by trailer.

## Icons

Reach for **Lucide** first: `import { Network } from 'lucide-vue-next'`.

Only when Lucide has no icon for what you need, fall back to **Phosphor** via unplugin-icons: `import IconPhCrosshair from '~icons/ph/crosshair'`.

For brand/company logos, use **simple-icons** via unplugin-icons: `import IconSimpleIconsGithub from '~icons/simple-icons/github'`.

Don't add a fourth icon set
## Vue `<script setup>` order

Keep sections in this order (each only uses what's above it):

1. Imports — vue → third-party → components → composables/stores → utils → `import type` last
2. Local types / interfaces
3. Macros — `defineProps` → `defineModel` → `defineEmits` → `defineSlots` (enforced by `vue/define-macros-order`)
4. Static constants (non-reactive lookup maps, option lists)
5. Composables — `useRoute()`, stores, `useXxx()`
6. State — `ref` / `reactive`
7. Computed
8. Functions — `function` declarations, not `const fn = () =>`
9. Watchers
10. Lifecycle hooks — `onMounted` → `onBeforeUnmount` → `onUnmounted`
11. `defineExpose`

Use type-based `defineEmits<{ ... }>()` with payload tuples. Section comments only in large files. Reference: `src/components/base/ListInputField.vue`.

## Comments and readability

- Write code that explains itself: clear names, small functions, early returns. Clean, human-readable code comes first; comments are the fallback.
- Comment only the **why** — a non-obvious reason, workaround, constraint, or gotcha (e.g. `// New array — model is readonly`). Never restate what the code already says (`// Check max items limit` above an `if (… >= maxItems)` is noise).
- Keep comments brief and clear: one short line, plain words. Use a short block only when the reasoning genuinely needs it.
- Update or delete a comment when the code it describes changes — a stale comment is worse than none.