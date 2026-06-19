# Building and installing NexSession

## Preparing the source tree

NexSession uses HoustonPatchbay as a Git submodule:

```bash
git submodule update --init
```

The current development worktree may contain intentional rebrand changes in both the main repository and submodule. Read `HANDOFF.md` before cleaning or resetting a development checkout.

## Fedora 44 development environment

The repaired Qt 6 build and GUI startup were verified on Fedora 44 GNOME Wayland with Python 3.14.

Install the system build and runtime dependencies:

```bash
sudo dnf install -y \
  gcc \
  git \
  make \
  pipewire-jack-audio-connection-kit \
  pipewire-jack-audio-connection-kit-devel \
  python3-pyliblo3 \
  python3-pyqt6 \
  qt6-linguist \
  qt6-qtbase-devel \
  qt6-qtsvg
```

The tested system used `QtPy 2.4.3` and `JACK-Client 0.5.5` from the user Python environment:

```bash
python3 -m pip install --user QtPy JACK-Client
```

Prefer distribution packages when Fedora provides compatible versions. Optional ALSA MIDI support requires Python ALSA bindings, and the default patchbay themes benefit from the Roboto font family.

Confirm QtPy selects PyQt6:

```bash
python3 -c "import qtpy; print(qtpy.API_NAME)"
```

Expected output:

```text
PyQt6
```

See `docs/fedora-pipewire.md` for PipeWire and WirePlumber service verification.

## Debian and Ubuntu dependencies

For a Qt 6 build:

```bash
sudo apt install \
  fonts-roboto \
  git \
  pyqt6-dev-tools \
  python3-jack-client \
  python3-liblo \
  python3-pyalsa \
  python3-pyqt6 \
  python3-pyqt6.qtsvg \
  python3-qtpy \
  qt6-base-dev-tools \
  qt6-svg-plugins \
  qtchooser \
  qttools5-dev-tools
```

Package names vary between distribution releases. Since the original `pyliblo` project is unmaintained, use a packaged `pyliblo3` where available or install the maintained fork from <https://github.com/gesellkammer/pyliblo3>.

## Building

Qt 6 is the default:

```bash
make
```

Fedora names the translation compiler `lrelease-qt6`, so the verified command is:

```bash
make LRELEASE=lrelease-qt6
```

For a Qt 5 build:

```bash
QT_VERSION=5 make LRELEASE=lrelease-qt5
```

The Makefiles locate Qt 6's resource compiler with:

```bash
qtpaths6 --query QT_HOST_LIBEXECS
```

This resolves Fedora's `/usr/lib64/qt6/libexec/rcc` and Debian's corresponding Qt libexec directory. `RCC` can still be overridden explicitly for unusual installations:

```bash
make RCC=/custom/qt6/libexec/rcc LRELEASE=/custom/qt6/bin/lrelease
```

Resource generation is failure-safe: output is written to a temporary file before replacing `src/gui/resources_rc.py` or HoustonPatchbay's resource module. Never accept a zero-byte generated resource file as a successful build.

## Running from the source tree

```bash
./src/bin/nexsession
```

Run graphical tests from the actual desktop user session. A remote or restricted shell may fail to access Wayland/X11 even when the application itself is healthy.

For a headless startup and daemon-communication smoke test:

```bash
env QT_QPA_PLATFORM=offscreen \
  timeout --signal=INT 5s ./src/bin/nexsession
```

Exit status `124` is expected because `timeout` ends the healthy Qt event loop. Healthy output includes `GUI connected` and `Bye Bye...` and does not include a traceback or missing-resource warning.

## Installing

The default prefix is `/usr/local`:

```bash
sudo make install LRELEASE=lrelease-qt6
```

The installation used during Fedora testing was explicit:

```bash
sudo make install PREFIX=/usr/local LRELEASE=lrelease-qt6
```

Distribution packagers can use `PREFIX` and `DESTDIR`:

```bash
make install PREFIX=/usr DESTDIR="$PWD/package-root"
```

Verify the installed copy:

```bash
env QT_QPA_PLATFORM=offscreen \
  timeout --signal=INT 5s nexsession
```

## Uninstalling

Use the same prefix selected during installation:

```bash
sudo make uninstall PREFIX=/usr/local
```

## Troubleshooting

### Missing icons or fonts followed by `IndexError`

Check that both generated resource modules are non-empty:

```bash
test -s src/gui/resources_rc.py
test -s HoustonPatchbay/source/patchbay/resources_rc.py
```

Then force resource regeneration:

```bash
make -B RES LRELEASE=lrelease-qt6
make -C HoustonPatchbay -B RES LRELEASE=lrelease-qt6
```

If `rcc` cannot be found, verify:

```bash
command -v qtpaths6
qtpaths6 --query QT_HOST_LIBEXECS
```

### Empty patchbay theme warning

Current code normalizes an empty `Canvas/theme_name` setting to NexSession's `Yellow Boards` fallback and persists it on shutdown. Build and reinstall current sources if an older installed copy repeats:

```text
Unable to find theme
theme '' has not been found,use 'Yellow Boards' instead.
```

The user setting is normally stored under `~/.config/NexSession/NexSession.conf`.

### Qt platform plugin/display failure

Errors such as `Failed to create wl_display` or `could not connect to display` can be caused by running outside the real desktop session or inside a restricted sandbox. Confirm `WAYLAND_DISPLAY`, `DISPLAY`, `XDG_RUNTIME_DIR`, and `DBUS_SESSION_BUS_ADDRESS` belong to the logged-in desktop user. Use the offscreen smoke test to separate display access from application startup problems.
