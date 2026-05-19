# docs/UI.md — UI rules

## Theming

- Use the `useColorScheme` hook (already scaffolded) — never hardcode `#fff`
  or `#000` in a component. Light/dark must both work; the verifier should
  flip the system theme as part of any UI feature's verification list.
- Spacing scale: 4 / 8 / 12 / 16 / 24 / 32. Anything else needs a comment
  explaining why.

## Accessibility

- Every touchable has `accessibilityRole` and `accessibilityLabel`.
- Text scales with the system font-size setting — don't lock font sizes.
- Minimum tap target: 44×44 dp.

## RTL

- Use `start`/`end` (e.g., `marginStart`, `paddingEnd`) instead of `left`/`right`
  in styles. The verifier flips device language to Arabic to catch
  regressions (see `ui-002`).

## Lists

- See `docs/RN_PLATFORM.md` — use `FlatList` or `FlashList` for any list
  >20 items.

## Animations

- Prefer Reanimated worklets over `Animated.timing` — they run on the UI
  thread.
- Animations should never block user input. If a transition needs to feel
  instant, keep it under 150ms.

## Status pill colours (used by ui-002)

| Status | Token |
| --- | --- |
| `todo` | grey 500 |
| `in_progress` | blue 500 |
| `blocked` | red 500 |
| `done` | green 500 |
