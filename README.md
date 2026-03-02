# IntensityMinutesField

A data field for the Garmin Venu 3 that shows intensity minutes earned during the current activity session — broken down into total, moderate, and vigorous — fixing a gap in Garmin's native data field options.

---

## About This Project

This app was built through **vibecoding** — a development approach where the human provides direction, intent, and testing, and an AI (in this case, Claude by Anthropic) writes all of the code. I have no formal programming background; this is an experiment in what's possible when curiosity and AI assistance meet.

Every line of Monkey C in this project was written by Claude. My role was to describe what I wanted, test each iteration on a real Garmin Venu 3, report back what worked and what didn't, and keep pushing until the result was something I was happy with.

As part of this process, I've been building a knowledge base — a growing collection of Markdown documents that capture the real-world lessons Claude and I have uncovered together: non-obvious API behaviours, compiler quirks, layout constraints specific to the Venu 3's circular display, and fixes for bugs that aren't covered anywhere in the official SDK documentation. These files are fed back into Claude at the start of each new session so the knowledge carries forward rather than being rediscovered from scratch every time.

The knowledge base is open source. If you're building Connect IQ apps for the Venu 3 and want to skip some of the trial and error, you're welcome to use it:

**[Venu 3 Claude Coding Knowledge Base](https://github.com/MJenkinsonGIT/Venu3ClaudeCodingKnowledge)**

---

## What It Displays

```
      Intensity Mins
           42
   Mod           Vig
    18            12
```

| Value | Description |
|-------|-------------|
| **Total** (large, centre) | Intensity minutes earned this session: `moderate + (vigorous × 2)` |
| **Mod** (bottom left) | Moderate intensity minutes earned this session |
| **Vig** (bottom right) | Vigorous intensity minutes earned this session |

All three values reset to zero when a new activity is started and count up from there. Before the activity timer starts, all values show zero.

### Why vigorous counts double

This matches Garmin's own "Intensity Minutes" field behaviour and the WHO physical activity guidelines, which recognise that one minute of vigorous activity provides the same cardiovascular benefit as two minutes of moderate activity. A vigorous minute therefore contributes 2 to your total.

### Why this app exists

The Connect IQ SDK does not expose per-activity intensity minutes directly — it only provides cumulative weekly totals. Garmin's built-in intensity minutes data field shares this limitation. This app works around it by snapshotting the weekly totals the moment the activity timer starts, then subtracting that baseline from the running weekly total to derive what was earned in the current session.

---

## Layout

This field was designed and tested in the **1-of-4 slot** layout — the compact quarter-screen position used when four data fields are displayed simultaneously. It has not been tested in full-screen, half-screen, or other slot configurations and may not display correctly in those layouts.

---

## Installation

### Which file should I download?

Each release includes three files. All three contain the same app — the difference is how they were compiled:

| File | Size | Best for |
|------|------|----------|
| `IntensityMinutesField-release.prg` | Smallest | Most users — just install and run |
| `IntensityMinutesField-debug.prg` | ~4× larger | Troubleshooting crashes — includes debug symbols |
| `IntensityMinutesField.iq` | Small (7-zip archive) | Developers / advanced users |

**Release `.prg`** is a fully optimised build with debug symbols and logging stripped out. This is what you want if you just want to use the app.

**Debug `.prg` + `.prg.debug.xml`** — these two files must be kept together. The `.prg` is the app binary; the `.prg.debug.xml` is the symbol map that translates raw crash addresses into source file names and line numbers. If the app crashes, the watch writes a log to `GARMIN\APPS\LOGS\CIQ_LOG.YAML` — cross-referencing that log against the `.prg.debug.xml` tells you exactly which line of code caused the crash. Without the `.prg.debug.xml`, the crash addresses in the log are unreadable hex. The app behaves identically to the release build; there is no difference in features or behaviour.

**`.iq` file** is a 7-zip archive containing the release `.prg` plus metadata (manifest, settings schema, signature). It is the format used for Connect IQ Store submissions. You can extract the `.prg` from it by renaming it to `.7z` and extracting — Windows 11 (22H2 and later) supports 7-zip natively via File Explorer's right-click menu. On older Windows versions you will need [7-Zip](https://www.7-zip.org/) (free).

---

**Option A — direct `.prg` download (simplest)**
1. Download the `.prg` file from the [Releases](#) section
2. Connect your Venu 3 via USB
3. Copy the `.prg` to `GARMIN\APPS\` on the watch
4. Press the **Back button** on the watch — it will show "Verifying Apps"
5. Unplug once the watch finishes

**Option B — debug build (for crash analysis)**
1. Download both `IntensityMinutesField-debug.prg` and `IntensityMinutesField.prg.debug.xml` — keep them together in the same folder on your PC
2. Copy `IntensityMinutesField-debug.prg` to `GARMIN\APPS\` on the watch
3. Press the **Back button** on the watch — it will show "Verifying Apps"
4. If the app crashes, retrieve `GARMIN\APPS\LOGS\CIQ_LOG.YAML` from the watch and cross-reference it against the `.prg.debug.xml` to identify the crash location

**Option C — extracting from the `.iq` file**
1. Rename `IntensityMinutesField.iq` to `IntensityMinutesField.7z`
2. Right-click it → **Extract All** (Windows 11 22H2+) or use [7-Zip](https://www.7-zip.org/) on older Windows
3. Inside the extracted folder, find the `.prg` file inside the device ID subfolder
4. Copy the `.prg` to `GARMIN\APPS\` on the watch
5. Press the **Back button** on the watch — it will show "Verifying Apps"
6. Unplug once the watch finishes

To add the field to an activity data screen: start an activity, long-press the lower button, navigate to **Data Screens**, and add the field to a slot. For best results, add it to a screen configured for **4 data fields** and place it in any one of the four positions.

> **To uninstall:** Use Garmin Express. Sideloaded apps cannot be removed directly from the watch or the Garmin Connect phone app.

---

## Device Compatibility

Built and tested on: **Garmin Venu 3**
SDK Version: **8.4.1 / API Level 5.2**

Compatibility with other devices has not been tested.

---

## Notes

- Values show zero before the activity timer starts. This is intentional — the baseline is captured at timer start, so there is nothing to display until then.
- If you pause and resume an activity, the baseline is not reset. The totals continue accumulating from the original start.
- Intensity minutes update on the watch's standard data field refresh cycle, not in real time. There may be a short lag before a completed vigorous effort is reflected.
