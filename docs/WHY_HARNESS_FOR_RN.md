# docs/WHY_HARNESS_FOR_RN.md — Why harness engineering pays off for React Native

Harness engineering's claim is general: environment design beats model
capability on long-horizon tasks. But React Native is a *particularly*
strong fit for the discipline. The reason is structural: RN has more
silent-failure modes than most stacks, and silent failures are exactly
what harnesses convert into loud, recoverable ones.

This doc walks the twelve principles and shows, for each, the concrete
React Native engineering failure it prevents — with examples grounded in
this repo.

---

## 1. Strong models don't mean reliable execution

> *Why it matters more in RN:* the model can write syntactically perfect
> React Native code that **does not run** on either platform. JSX
> compiles, types pass, lint passes — and the bundle red-boxes on launch
> because of a Hermes-specific runtime quirk.

### Examples we have seen in the wild

- An agent imports `crypto` from Node and writes a UUID helper. TypeScript
  is fine. The app boots. The first call crashes Hermes with `crypto is
  undefined`.
- An agent uses optional chaining on a getter that throws — Hermes
  evaluates the LHS before the `?.` check on certain versions.
- An agent writes `await import('./foo')` for code-splitting. Metro on
  Hermes won't honour the dynamic import the way the model expects from
  webpack.

**Harness response in this repo:** the verification list for any UI
feature in `feature_list.json` includes "launch on at least one platform"
(see `ui-001`). `passes: true` cannot be set from typecheck alone.

---

## 2. A harness is five subsystems

> *Why it matters more in RN:* RN dev environments are stateful in ways
> JS-only stacks aren't. Pods, simulators, gradle daemons, EAS build state,
> Metro cache, watchman, Hermes engine flags. A "prompt" cannot manage
> state of this shape; only a repository-resident set of files can.

**Harness response:** `init.sh` enforces environment health (node
version, dependency freshness, type/lint baseline). It is idempotent — you
can run it as many times as you like and only the actually-broken steps
will fail. That property matters because RN agents *will* run it a lot.

---

## 3. The repository is the system of record

> *Why it matters more in RN:* "what version of Expo do we use?" "is the
> new architecture on?" "what's the minimum iOS deployment target?" — these
> answers live in `package.json`, `app.json`, and Podfile properties, but
> the *rationale* (why those answers, what we tried, what broke) tends to
> live in someone's head, or worse, in a Slack thread.

**Harness response:** every non-obvious platform decision goes in
`docs/RN_PLATFORM.md` or the "Decisions log" section of
`claude-progress.md`. Example entries you would see in a mature project:

> *2026-03-04* — Disabled the New Architecture because
> `react-native-svg@15.x` regresses TextPath on Fabric. Reconsider when
> SVG ≥ 16 ships. **Why:** caught by `ui-008` verification, three hours
> lost before noticing.

> *2026-03-12* — `react-native-mmkv` crashes on Android x86_64 emulator
> only. We use it anyway; emulator testing falls back to arm64. **Why:**
> production is arm64; the failure is emulator-architecture-specific.

If those facts only live in a person's head, the next session repeats
the three lost hours.

---

## 4. Split instructions across files

> *Why it matters more in RN:* there are at least four distinct
> sub-disciplines (JS/TS layer, native platform, build pipeline, design
> system). A monolithic `AGENTS.md` either covers one and ignores the
> others, or grows past the point where agents skim it.

**Harness response:** `AGENTS.md` is ~100 lines and is a router. Topic
detail lives in `docs/ARCHITECTURE.md`, `docs/RN_PLATFORM.md`, `docs/UI.md`,
`docs/E2E_TESTING.md`, etc.

---

## 5. Keep context alive across sessions

> *Why it matters more in RN:* RN feature work routinely takes multiple
> sessions because each platform's verification is its own loop (iOS sim
> warm-up alone can be 30–60 seconds per cycle). If you can't pick up
> mid-feature, the cost is not "lost 20 minutes" — it's "rebuild the
> simulator state."

**Harness response:** `claude-progress.md`'s **Next action** block points
at the next concrete step. Example handoff that pays for itself:

```
## Next action
Pick up ui-002 mid-feature. The FlashList renders but the status pill
colours are inverted on Android (RTL bug — see commit a1b2c3d in
__tests__/StatusPill.test.tsx). Reproduce: launch iOS sim, toggle
Settings → General → Language to العربية, reopen app. Fix candidate:
swap `marginLeft` for `marginStart` in StatusPill.tsx:24.
```

The next session does not need to re-build the simulator from cold to
remember which two lines were suspicious.

---

## 6. Initialize before every session

> *Why it matters more in RN:* RN's broken-environment modes are diverse
> and look identical from chat. "Build fails" might mean: wrong Node
> version, missing pod, stale Metro cache, Xcode CLI tools out of date,
> dependency drift after `npm install`, JDK mismatch. Without a structured
> init phase, the agent burns iterations guessing.

**Harness response:** `init.sh` is staged: node check → dep check →
typecheck → lint → schema → progress tail. Each step prints `[ok]` /
`[fail]` so the failing step is the first one to look at. **Foundation
before walls.**

---

## 7. WIP = 1

> *Why it matters more in RN:* RN refactors are tempting. While editing a
> screen, the agent notices a stale dep, a missing accessibility label,
> an outdated icon font. None of these are the feature. Bundling them is
> how a 1-hour feature becomes a 4-hour PR that nobody can review.

**Harness response:** `wipLimit: 1` in `feature_list.json` is enforced by
`scripts/feature-list-check.js`. Drive-by debt goes in as a new
`todo` feature, not as an extra change in this commit.

---

## 8. Feature lists as harness primitives

> *Why it matters more in RN:* "done" is genuinely ambiguous in RN. Is it
> done when iOS works? Android too? Web? With dark mode? RTL? Tablet
> layouts? Reduced-motion? Without a written `verification[]`, the agent
> picks the easiest subset and declares victory.

**Harness response:** each feature has a `verification[]` array. The
verification for `ui-002` includes "RTL layout renders correctly (toggle
device language to Arabic in the sim)" — making explicit a check that
most teams discover via bug reports, weeks later.

---

## 9. Don't declare victory too early

> *Why it matters more in RN:* the Metro red box is much further away
> than a stack trace. An agent that "fixes a bug" by deleting the calling
> code, or by wrapping the failure in `try {} catch {}`, looks the same
> as one that fixed it — until you run the app.

**Harness response:** `passes: true` requires the verification list to
have *run*, not just the code to compile. The commit SHA in
`feature_list.json[].commitSha` makes the claim auditable.

---

## 10. End-to-end testing changes the result

> *Why it matters more in RN:* the platform gap is enormous. Behavior
> differs between Hermes/JSC, iOS/Android, Old/New Architecture,
> simulator/device. Unit tests run in jsdom and cannot see most of it.

**Harness response:** every UI feature's verification list ends in a
simulator/emulator step. See `docs/E2E_TESTING.md` for **how** —
specifically how to test simulator builds, including `xcrun simctl`, EAS
dev builds, Detox, and Maestro flows.

---

## 11. Observability inside the harness

> *Why it matters more in RN:* "it didn't work" in RN can mean: silent
> JS thread crash, native crash with sourcemap-less stack, Metro
> watcher misbehavior, EAS build queued behind another, simulator out of
> disk. The agent needs structured signal, not "the screen is blank."

**Harness response:** `lib/log.ts` is the single logger. All scripts use
`[ok]/[fail]` lines. Diagnostics (Metro logs, Hermes stacks) drop in
`tmp/diagnostics/` keyed by timestamp; the agent grep's one place.

---

## 12. Every session must leave a clean state

> *Why it matters more in RN:* leaving a session with `pod install`
> half-run, `eas build` queued, a half-bumped SDK, or the simulator in
> a wedged state can cost the *next* session an hour before it can
> reproduce anything. The cost compounds.

**Harness response:** `npm run harness:clean-state` checks working tree,
verify status, debug markers, progress-log freshness, and stray `tmp/`
files. It fails loudly if anything is off. The `docs/SESSION.md`
checklist covers what the script can't (e.g., "is the simulator
unblocked?").

---

## Putting it together: the cost without a harness

A representative RN session without a harness:

```
00:00  Agent reads chat, starts on "Add a feature list screen."
00:08  Implements. Lint passes. Types pass. Says "done."
00:09  Human runs the app — red box: "FlashList not found."
00:11  Agent says "Install FlashList." Bumps Expo. EAS now wants a new build.
00:25  Different error on Android. Agent edits AndroidManifest.xml directly.
00:31  Next prebuild blows away the edit. Agent doesn't know.
00:45  Session ends. Next session starts cold. No notes. Repeats 00:08.
```

The same session with a harness in this repo:

```
00:00  Agent reads claude-progress.md → next action: pick ui-002.
00:01  ./init.sh → node ok, deps ok, types/lint ok.
00:02  npm run verify → green baseline.
00:03  Implements feature; FlashList is already in deps (decision logged
       in claude-progress.md from a prior feature).
00:18  Walks ui-002's verification list in iOS sim. Found RTL bug.
00:24  Fixes it. Verification list passes. status=done, commitSha set.
00:25  npm run harness:clean-state — green.
00:26  Commit, push, next action updated to ui-003. Session ends.
```

The difference is not "the agent got smarter." The difference is the
environment around the agent did its job.
