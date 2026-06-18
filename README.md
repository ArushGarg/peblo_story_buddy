# Peblo Story Buddy — AI Story Buddy & Quiz Component

Pip reads a short story aloud, then a quiz built entirely from a JSON payload appears the moment narration ends.

## Screenshots

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/55621485-ea56-4415-96cd-96ba7295edf5" width="170"/><br/><sub>Idle</sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/2dc33833-acf8-407c-a385-7744591a0228" width="170"/><br/><sub>Reading aloud</sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/c9337a80-4996-4aab-b8bc-a107ddd3c918" width="170"/><br/><sub>Quiz revealed</sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/2471e1ac-5698-410c-be2f-95e406dc1e55" width="170"/><br/><sub>Wrong answer</sub></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/007993df-4649-42b6-b3fc-46b0f1af1f71" width="170"/><br/><sub>Correct → success</sub></td>
  </tr>
</table>

## Getting started

This repo ships the Flutter source only (`lib/`, `pubspec.yaml`, `test/`) so it stays easy to read — no generated native folders. To run it:

1. `flutter create --org com.peblo --project-name peblo_story_buddy .` in this folder (generates `android/`, `ios/`, etc. — it will not overwrite the existing `lib/` or `pubspec.yaml`, only add what's missing).
2. `flutter pub get`
3. `flutter run`

Built against Flutter 3.x / Dart 3.3+.

## Framework choice

**Flutter**, with **Provider** for state management.

Flutter is the better-supported choice given Peblo's own stated audience — mid-range Android devices in India — and it's the framework I already have production, hands-on experience with. Provider is proportionate to a single-screen feature: a clear split between UI and the narration/quiz state machine, without the extra ceremony BLoC would add at this scope.

## Architecture, in three pieces

- **`StoryBuddyProvider`** (`ChangeNotifier`) — owns two small state machines: `NarrationState` (idle → loading → playing → idle/error) and `QuizPhase` (hidden → revealed → wrongAnswer/correct).
- **`StoryNarrator`** — an interface around "read this text aloud," implemented by `DeviceTtsNarrator` (`flutter_tts`). Tests inject a fake implementation instead of touching a real TTS engine.
- Presentational widgets (`AiBuddy`, `StoryCard`, `QuizCard`, `ReadStoryButton`, `ConfettiOverlay`) that only read from the provider and never own narration/quiz logic themselves.

## Managing the audio → quiz transition

`flutter_tts` exposes a completion *handler*, not just a future that resolves when speech starts. `DeviceTtsNarrator` wires that handler through `StoryNarrator.setOnComplete`, and `StoryBuddyProvider._handleNarrationComplete()` is the single place that flips `NarrationState` back to idle **and** `QuizPhase` to `revealed` in the same `notifyListeners()` call — so the UI never sees a frame where audio has stopped but the quiz hasn't appeared yet. The screen catches that with an `AnimatedSwitcher` (slide + fade), so the quiz visibly arrives the instant narration ends.

## Building the quiz to be data-driven

`QuizQuestion.fromJson` parses `question`, an arbitrary-length `options` list, and `answer`, with an assertion that the answer is actually one of the options (a guard against a malformed payload, not against legitimate variation). `QuizCard` builds one button per item in `options` via `.map()` — there's no `options[0]` / `options[1]` anywhere, so a payload with 3 or 5 entries renders correctly with zero code changes. Swap `_sampleQuiz` in `main.dart` for a different shape to verify.

## Matching the wireframe

The wireframe came with explicit brand colours (`#6F2BC2` primary, `#36165E` secondary) and typeface (Poppins) — those are used directly, not approximated. Structure follows the wireframe closely: an app bar reading "AI Story Buddy," the buddy in a card-shaped slot above the story card, a full-width "Read Me a Story" button, and quiz options as individual white rows below a question that sits directly on the page rather than inside its own boxed card.

Two deliberate departures, both for the "what delights a young child" half of the brief rather than against the wireframe:

- **Pip is custom-painted, not a placeholder graphic.** The brief explicitly says any placeholder is fine, so the empty box in the wireframe became an opportunity rather than something to fill with a stock icon.
- **Each quiz option is a full tappable row, with the radio circle as a status indicator rather than the only hit target.** A literal small radio button is a precise target that's harder for a 6-10 year old to hit reliably; the wireframe's row-sized options already support a full-row tap without losing the visual cue the circle provides.

Wrong/correct feedback intentionally stays off-brand (coral/moss rather than two shades of purple) since a child needs to tell them apart at a glance, not recognise the brand.

## Caching

On-device TTS (`flutter_tts` / `AVSpeechSynthesizer`) synthesizes audio locally in real time, so there's no remote audio file for the required path to cache.

If the **bonus** remote engine (ElevenLabs) were wired in, `StoryNarrator` is the seam for it: a `RemoteTtsNarrator` implementing the same interface, swapped in at the `StoryBuddyProvider` constructor with no UI changes. Its caching would hash the story text (+ voice id) with SHA-256, check `path_provider`'s app cache directory for `<hash>.mp3` before any network call, write the response bytes on a miss, and evict the oldest files past a fixed size cap (e.g. 20MB) on each successful fetch — relevant for the budget-data audience the brief calls out.

## Audio loading & failure handling

- `NarrationState.loading` covers the gap between tapping the button and speech actually starting; the button itself swaps its label and shows a spinner, so there's no separate loading widget to keep in sync.
- `flutter_tts`'s error handler is wired through `StoryNarrator.setOnError` to `_handleNarrationError`, which surfaces a friendly `ErrorBanner` with a Retry button instead of letting the app hang.
- A 20-second watchdog `Timer` is a defensive backstop: if neither the completion nor error handler ever fires, the provider times out into the same error state rather than leaving the button stuck on "Reading aloud…" forever.
- One real gotcha worth flagging: on Android 11+, `flutter_tts` can fail silently with "No TTS engine found" due to package-visibility restrictions unless `android/app/src/main/AndroidManifest.xml` declares:
```xml
  <queries>
    <intent>
      <action android:name="android.intent.action.TTS_SERVICE" />
    </intent>
  </queries>
```

## Performance profiling

The application was profiled using flutter run --profile and Flutter DevTools on an Android device.

What's already built with this in mind:
- `RepaintBoundary` around `AiBuddy` and `ConfettiOverlay` — the two widgets doing continuous custom painting/particles — so their raster layers don't force the rest of the screen to repaint.
- `Selector<StoryBuddyProvider, ...>` instead of a screen-wide `Consumer` for those two widgets specifically, so a quiz-state change doesn't rebuild the buddy and vice versa.
- `CustomPainter.shouldRepaint` on the buddy's face only returns true when emotion or blink value actually changed.
- Confetti capped at 24 particles / 2 seconds — enough to read as celebratory, cheap enough not to matter.

**Checklist:**
1. `flutter run --profile` on a real or emulated mid-range-equivalent device.
2. DevTools → Performance, tick "Track widget builds."
3. Run the full flow once (tap → wait for quiz → wrong answer → correct answer) while recording.
4. Screenshot the frame chart, flag any frame over 16ms, and note what you changed if you had to fix one.

## Staying lightweight on mid-range Android

- Pip is drawn entirely with `CustomPainter` — no bundled raster assets, so the character adds ~0KB to the APK and stays crisp at any density.
- `const` constructors throughout the static parts of the tree (card and button decorations) so Flutter can skip rebuilding subtrees that haven't changed.
- No blur/backdrop filters anywhere — some of the more GPU-expensive effects on budget GPUs — the design leans on flat color, shadow, and shape instead.
- `google_fonts` fetches Poppins once over the network and caches it. Worth flagging honestly: a fully offline-first build would bundle the `.ttf` as a local asset instead, removing the first-launch network dependency. That's the change I'd make before shipping this for real.

## AI usage & judgment

I used AI assistance (Claude and ChatGPT) primarily for brainstorming architecture choices, reviewing Flutter design decisions, and refining documentation.

- Evaluating state management approaches (Provider vs Riverpod/BLoC).
-Designing the separation between StoryBuddyProvider, StoryNarrator, and presentational widgets.
-Suggesting performance optimizations such as RepaintBoundary and limiting widget rebuilds.
-Improving documentation wording and explaining implementation decisions clearly.

AI initially suggested using a more complex state-management approach such as BLoC/Riverpod. I chose Provider instead because this project contains a single-screen flow with relatively simple state transitions, and Provider offered a cleaner and more proportionate solution with less boilerplate.
