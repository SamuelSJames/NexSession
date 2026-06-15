# NexSession — Feature Roadmap

> Fork of [RaySession](https://github.com/Houston4444/RaySession) by Mathieu Picot (houston4444).  
> Goal: Native Linux audio session manager — kernel-aware, standalone, Flatpak-distributable.

---

## Community Research Summary

### What users love about RaySession (keep and build on)
- Integrated patchbay with stereo port detection (unique in the NSM ecosystem)
- Git-based snapshot history — save states, instant rollback
- Ray-Hack protocol — wraps non-NSM apps without an extra process
- `ray_control` CLI — scriptable, keyboard-bindable
- Session scripts — shell hooks on load/save/close
- Network sessions — master-slave across networked machines
- Active, reliable, production-ready

### Top community complaints (fix these first)
- **PipeWire** — connections drop when PW quantum changes; JACK compat layer is fragile
- **No dark mode** for the main window (only patchbay is themeable)
- **No global transport controls** (play/pause/stop) in the main UI
- **No Save As** for sessions
- **No client grouping** for batch start/stop
- **HiDPI** partially fixed, not complete
- **Window geometry** not restored on reopen (marked wontfix upstream — we fix it)
- Python dependency conflicts (`pyliblo` vs `pyliblo3`, `PyQt5.QtSvg`)
- Build/packaging complexity

### Requested features from GitHub issues
| Issue | Feature |
|-------|---------|
| #221 | Save As / session branching |
| #216 | Client grouping (batch start/stop) |
| #139 | JACK transport controls in main UI |
| #228 | Exclusive patch mode (enforce saved connections, auto-disconnect others) |
| #225 | Rule-based automatic routing (device-triggered) |
| #207 | Plugin hosting (LV2/CLAP directly inside a session) |
| #253 | Per-client startup delay + dependency ordering |
| #236 | Dark mode / full app theming |
| #197 | Patchbay mini-map |
| #72  | Custom icons stored inside the session folder |
| #74  | Global start/stop all clients |

### HoustonPatchbay planned features (carry forward)
- Matrix connections view (grid alternative to canvas)
- Zones — colored areas to group boxes on canvas
- VU-meters next to ports (requires C JACK client)
- Multiple canvas views with switching
- Auto-arrange scripts
- PipeWire video port support
- JACK metadata write support (port renaming persistence)

### Competing session managers — gaps to close
| Feature | Agordejo | NexSession target |
|---------|----------|-------------------|
| Integrated patchbay | No | Yes (keep + improve) |
| Network sessions | No | Yes (keep) |
| Git snapshots | No | Yes (keep) |
| Dark mode | System theme | Full QSS theming |
| Double-click crashed client to reopen | Yes | Add |
| Pure save from system tray | Yes | Add |
| NSM spec compliance | Strict | Compatible + extended |

---

## Feature Phases

### Phase 1 — Fix the Foundation (PipeWire + systemd)
**Priority: highest. Fixes the loudest community complaint.**

- [ ] **PipeWire native API** — replace JACK compat layer dependency with direct `libpipewire` integration
  - Survive quantum/sample-rate changes without dropping connections
  - See PW-native apps (browsers, Bluetooth, HDMI) not visible in JACK mode
  - Use PipeWire link objects directly for faster, more reliable routing
- [ ] **systemd user service** — ship `nexsession-daemon.socket` unit
  - Zero startup latency via socket activation
  - Auto-start daemon on first GUI connection
  - Proper `ExecStop` for clean shutdown
- [ ] **udev audio device detection** — react to interface plug/unplug events
  - Trigger session template swaps when a specific interface appears
  - Restore connections after device reconnect

### Phase 2 — UX & Workflow (Most-requested features)
- [ ] **Full app theming** — QSS-based dark/light/custom themes for main window, not just patchbay
- [ ] **Save As / session branching** — duplicate session under a new name; branch from any git snapshot
- [ ] **Client grouping** — group clients ("Synths", "FX", "Recording"), start/stop whole group at once
- [ ] **JACK/PipeWire transport controls** — play/pause/stop/rewind in the main window
- [ ] **Per-client startup delay + dependency graph** — define start order ("launch Guitarix only after Ardour is ready")
- [ ] **Window geometry restore** — save and restore main window and dialog sizes/positions
- [ ] **Recent sessions widget** — toolbar widget with pinnable favorites, one-click open
- [ ] **Reopen crashed client** — double-click a crashed/stopped client to relaunch it (from Agordejo)
- [ ] **Pure save from system tray** — save all clients without closing the session

### Phase 3 — Power Features
- [ ] **Plugin hosting (LV2/CLAP/VST3)** — embed Jalv or CLAP-host as first-class clients; add "Add Plugin" button to main UI
- [ ] **Rule-based routing** — define conditional routing rules triggered by device presence or running apps
- [ ] **Exclusive patch mode** — enforce saved connections; auto-disconnect anything not in the saved patch
- [ ] **Audio device profiles** — per-session PipeWire/JACK config; auto-swap when interface changes (udev-triggered)
- [ ] **Session Notes / journal** — rich-text notes panel per session; auto-timestamp on save
- [ ] **Custom icons in session folder** — store icons for self-compiled/non-repo software inside the session

### Phase 4 — Native Linux Architecture (Kernel-Level)
**Goal: make the daemon truly native, lightweight, and system-integrated.**

- [ ] **C daemon rewrite** — replace Python daemon with a C (or Rust) process
  - `SCHED_FIFO`/`SCHED_RR` real-time scheduling for zero-latency session events
  - D-Bus native IPC (replace OSC/UDP for local communication)
  - `cgroups v2` — isolate clients per session, track CPU/memory, kill cleanly
  - `inotify` — watch session files for external changes (editor edits, git merges)
  - `PR_SET_CHILD_SUBREAPER` — be the true parent of all session processes, handle orphans
- [ ] **Real-time process priority management** — set `RLIMIT_RTPRIO` for clients at launch; no rtirq/rtkit required separately
- [ ] **Wayland full support** — replace `wmctrl` (X11-only) with `xdg-foreign` + `wlr-foreign-toplevel` protocols for virtual desktop memory
- [ ] **HiDPI / multi-monitor** — proper per-screen DPI scaling throughout

### Phase 5 — Patchbay Improvements
- [ ] **Matrix view** — grid-style connection view as alternative to node canvas
- [ ] **Canvas zones** — colored semi-transparent areas to group and label boxes
- [ ] **Patchbay mini-map** — bird's-eye navigator for dense routing setups
- [ ] **VU-meters on ports** — real-time level meters (requires native JACK client)
- [ ] **Auto-arrange** — on-demand layout algorithm to tidy the canvas
- [ ] **JACK metadata write** — persist port renames across sessions via JACK metadata API

### Phase 6 — Flatpak Distribution
- [ ] Write Flatpak manifest (`org.nexsession.NexSession.json`)
  - Runtime: `org.freedesktop.Platform`
  - Audio portal: `org.pipewire.pipewire`
  - D-Bus policy for daemon IPC
  - Split architecture: GUI in sandbox, daemon as user service outside
- [ ] Submit to Flathub

---

## Build Requirements (Fedora)

### Install all dependencies

```bash
# Build dependencies
sudo dnf install -y \
  python3-pyqt6-devel \
  qt6-linguist \
  qt6-qttools-devel

# Runtime dependencies
sudo dnf install -y \
  python3-pyqt6 \
  python3-pyqt6-base \
  qt6-qtsvg \
  python3-QtPy \
  python-jack-client \
  python3-pyliblo3 \
  python3-alsa \
  pipewire-jack-audio-connection-kit \
  google-roboto-fonts \
  git

# Initialize git submodule (HoustonPatchbay)
cd ~/Documents/RaySession
git submodule update --init
```

### Build

```bash
cd ~/Documents/RaySession
make
```

### Run without installing

```bash
./src/bin/raysession
```

### Install system-wide

```bash
sudo make install PREFIX=/usr
```

---

## Notes

- Internal tool names (`ray-daemon`, `ray_control`, `ray-jackpatch`, etc.) are intentionally kept as-is — renaming them would break NSM protocol compatibility with existing client apps.
- The main executable and all user-facing paths use the `nexsession`/`NexSession` name.
- The `COPYING` (GPLv2) and `TRANSLATORS` files are preserved from the original RaySession project.
