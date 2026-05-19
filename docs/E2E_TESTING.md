# docs/E2E_TESTING.md — How to test simulator builds

This doc answers the question: **how do we actually verify a feature on a
simulator/emulator, in a way that satisfies the verification list in
`feature_list.json`?**

The harness rule is: a feature is not `done` until its verification list
has been walked **in a running app on at least one platform**. This
document spells out the four practical paths.

---

## TL;DR — pick one path per feature

| Path | When to use | What it gives you | Cost |
| --- | --- | --- | --- |
| **A. Manual sim run** | Single UI tweak, fast loop | Eyeballs on real platform behavior | 30s / iteration |
| **B. Snapshot in CI** | Layout / theming / RTL regressions | Diffable, fast, no device | Setup once |
| **C. Detox / Maestro** | Multi-screen flows, gestures | Real platform automation | Heavy setup |
| **D. EAS dev build** | Native module changes, release rehearsal | Closest to prod | Slow; needs cloud |

Most UI features in this repo use **A + B**. Anything that touches a
native module or release behavior also uses **D**.

---

## Path A — Manual simulator run (the default)

The verification list for `ui-001` calls for this. Steps:

### iOS Simulator

```bash
# 1. Boot a specific simulator (skip if already booted)
xcrun simctl list devices available | head    # see what's installed
xcrun simctl boot "iPhone 16 Pro" || true     # idempotent
open -a Simulator

# 2. Start Metro
npm run ios       # builds + installs + launches; or:
npm run start     # then press 'i' in the Metro prompt

# 3. Walk the verification list. For each step, observe and record:
#    - did the screen render?
#    - any yellow box warnings? red box errors?
#    - did the action complete?

# 4. Take artifacts for the commit message
xcrun simctl io booted screenshot tmp/diagnostics/ui-001-ios.png
```

### Android Emulator

```bash
# 1. Boot an AVD (skip if already booted)
emulator -list-avds
emulator -avd Pixel_8_API_34 &      # background it

# 2. Wait for boot
adb wait-for-device
adb shell getprop sys.boot_completed   # prints 1 when ready

# 3. Launch
npm run android

# 4. Screenshot for the commit
adb exec-out screencap -p > tmp/diagnostics/ui-001-android.png
```

### Recording the result

In `feature_list.json`, set `commitSha` to the verification commit and
`passes: true`. In `claude-progress.md`, the session entry should say
which platform was walked. Example:

```
## Session 2026-05-19 (agent: claude)
- Picked up: ui-001
- Did: implemented home tab showing project name + feature counts
- Verify: green; manual sim walk on iOS 17.5 (iPhone 16 Pro)
- Artifacts: tmp/diagnostics/ui-001-ios.png
- Left: ui-001 done at SHA <abc1234>; next = ui-002
```

---

## Path B — Snapshot testing for layout / theming / RTL

`jest-expo` is already wired up. For layout regressions:

```ts
// __tests__/StatusPill.test.tsx
import { render } from '@testing-library/react-native';
import { StatusPill } from '@/components/StatusPill';

test.each(['todo', 'in_progress', 'blocked', 'done'] as const)(
  'matches snapshot in light mode (%s)',
  status => {
    const tree = render(<StatusPill status={status} />).toJSON();
    expect(tree).toMatchSnapshot();
  },
);
```

For pixel snapshots (catches actual rendering, not just the React tree),
add [`jest-image-snapshot`](https://github.com/americanexpress/jest-image-snapshot)
with [`react-native-view-shot`](https://github.com/gre/react-native-view-shot)
and run on a CI simulator. The verification list for `ui-002` includes a
render test — start with the React-tree snapshot above; only add image
snapshots if the feature is visual enough to warrant it.

Re-baseline command (only after intentional visual changes):

```bash
npm test -- -u    # update snapshots; review the diff in the commit
```

**Watch out:** snapshot tests miss anything that Hermes evaluates
differently from Node. They are necessary, not sufficient.

---

## Path C — Maestro (scaffolded) and Detox (not scaffolded)

### Maestro — the default end-to-end path

This is the path the harness recommends and is wired up out of the box.
The scaffold lives at:

- `.maestro/config.yaml` — shared appId, retry policy
- `.maestro/flows/home.yaml` — the smoke flow (asserts the default home tab
  renders and that tab navigation works)
- `.maestro/README.md` — authoring conventions
- `scripts/run-maestro.sh` — harness wrapper around `maestro test`
  (installs check, device check, structured `[ok]/[fail]` output, copies
  screenshots + JUnit XML into `tmp/diagnostics/`)
- `scripts/sim-ios.sh`, `scripts/sim-android.sh` — sim/emulator helpers
- npm scripts: `npm run e2e`, `npm run e2e:ios`, `npm run e2e:android`,
  `npm run sim:ios[:screenshot]`, `npm run sim:android[:screenshot]`

Smoke run:

```bash
# one-time
curl -Ls 'https://get.maestro.mobile.dev' | bash

# every time
npm run sim:ios         # boot a sim
npm run ios             # build/install/launch the app on it
npm run e2e             # run the smoke flow → exit 0, screenshot in tmp/diagnostics/
```

Authoring a new flow:

```yaml
# .maestro/flows/<feature-id>.yaml
appId: ${APP_ID:-host.exp.exponent}
---
- launchApp:
    clearState: false
- assertVisible: "..."          # one assertion per verification-list item
- tapOn: "..."
- takeScreenshot: <feature-id>  # always end with a screenshot for the agent
```

Then add the invocation (`npm run e2e -- .maestro/flows/<feature-id>.yaml`
or a dedicated npm script) to the feature's `verification[]` array in
`feature_list.json`.

### Detox (heavier, more powerful)

For features that need precise gesture sequences, multi-app coordination,
or push notification flows. Plan it as an explicit feature with a
verification list; do not bolt it on while implementing something else.

---

## Path D — EAS dev / preview builds (closest to prod)

When a feature changes native config (`app.json` plugins, deployment
target, new native dependency), simulator-only verification is not
enough. Add a dev build step:

```bash
# Create or update a dev client
eas build --profile development --platform ios
eas build --profile development --platform android

# Install on a simulator
eas build:run -p ios --latest
eas build:run -p android --latest
```

These are slow (often 10–20 minutes queued). When you need one, kick it
off **before** doing anything else in the session — it runs in the
background while you implement.

Verification list entries for native-touching features should explicitly
say "verified on EAS dev build <build-id>." Without that, the verification
is missing the failure modes that only appear post-prebuild.

---

## Common pitfalls and how the harness catches them

| Pitfall | How the harness catches it |
| --- | --- |
| "It works in Expo Go but not in a dev build" | Verification list requires dev build for native-touching features. |
| "It works on iOS but not Android" | Verification list asks "on at least one platform" — but features with platform-specific code list both. |
| "It works in light mode but breaks in dark" | `docs/UI.md` mandates testing both; verification lists for theme-touching features include both modes. |
| "It works for left-to-right but breaks in Arabic" | Verification list for `ui-002` explicitly includes the RTL toggle. |
| "Tests pass, app doesn't launch" | `passes: true` requires the verification list to have run on a real platform, not just `npm test`. |
| "Looks fine, scrolling is choppy" | `docs/RN_PLATFORM.md` mandates FlatList/FlashList for >20 items, lint-enforced. |

---

## Triage when the simulator misbehaves

The harness assumes the simulator itself can be in a bad state. Standard
recovery order:

1. `xcrun simctl shutdown all && xcrun simctl erase all` (nuclear, ~10s).
2. `npx expo start --clear` (clears Metro cache).
3. `rm -rf node_modules ios/Pods && npm install && cd ios && pod install`.
4. `rm -rf ~/Library/Developer/Xcode/DerivedData/*`.

Record which step fixed it in `claude-progress.md` under "Decisions log,"
because step 4 in particular has been known to silently mask a real bug.
