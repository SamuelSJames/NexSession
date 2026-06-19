# Fedora PipeWire Test Notes

NexSession's Fedora audio target is PipeWire with WirePlumber, plus PulseAudio
and JACK compatibility through PipeWire.

## Fedora Documentation Sources

- Fedora Default PipeWire change:
  https://fedoraproject.org/wiki/Changes/DefaultPipeWire
- Fedora WirePlumber change:
  https://fedoraproject.org/wiki/Changes/WirePlumber
- Fedora package: pipewire:
  https://packages.fedoraproject.org/pkgs/pipewire/pipewire/
- Fedora package: wireplumber:
  https://packages.fedoraproject.org/pkgs/wireplumber/wireplumber/
- Fedora package: pipewire-pulseaudio:
  https://packages.fedoraproject.org/pkgs/pipewire/pipewire-pulseaudio/
- Fedora package: pipewire-jack-audio-connection-kit:
  https://packages.fedoraproject.org/pkgs/pipewire/pipewire-jack-audio-connection-kit/

## Install Or Repair

```sh
sudo dnf install -y \
  pipewire \
  wireplumber \
  pipewire-pulseaudio \
  pipewire-alsa \
  pipewire-utils \
  pipewire-jack-audio-connection-kit
```

If a Fedora system is still using the old PipeWire media session manager:

```sh
sudo dnf swap --allowerasing pipewire-media-session wireplumber
```

If PulseAudio compatibility is not backed by PipeWire:

```sh
sudo dnf install --allowerasing pipewire-pulseaudio
```

## User Services

Run from the real desktop user session:

```sh
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## Verification

```sh
rpm -q pipewire wireplumber pipewire-pulseaudio pipewire-alsa pipewire-utils pipewire-jack-audio-connection-kit
systemctl --user is-active pipewire pipewire-pulse wireplumber
wpctl status
pactl info
pw-link -io
pw-jack -h
```

Expected signals:

- `systemctl --user is-active` prints `active` for PipeWire, PipeWire Pulse,
  and WirePlumber.
- `pactl info` reports `Server Name: PulseAudio (on PipeWire ...)`.
- `wpctl status` lists the PipeWire graph and WirePlumber client.
- `pw-link -io` lists audio and MIDI ports.
- `pw-jack -h` prints the PipeWire JACK compatibility wrapper help.

## Current Laptop Check

On the Fedora 44 laptop used for NexSession testing:

- All target RPM packages were already installed.
- `pipewire`, `pipewire-pulse`, and `wireplumber` were active.
- PulseAudio compatibility reported `PulseAudio (on PipeWire 1.6.6)`.
- `pw-link -io` listed audio, MIDI, and video ports.
- `pw-jack -h` worked; `pw-jack --version` is not supported by this wrapper.

## NexSession Application Verification

The Fedora 44 development tree was built with:

```sh
make LRELEASE=lrelease-qt6
```

Qt's resource compiler is discovered with:

```sh
qtpaths6 --query QT_HOST_LIBEXECS
```

On the tested system this prints `/usr/lib64/qt6/libexec`. Do not hardcode the Debian `/usr/lib/qt6/libexec/rcc` path in Fedora-specific instructions.

Use this non-interactive startup smoke test after build or installation:

```sh
env QT_QPA_PLATFORM=offscreen timeout --signal=INT 5s ./src/bin/nexsession
env QT_QPA_PLATFORM=offscreen timeout --signal=INT 5s nexsession
```

Exit status `124` is expected because `timeout` stops the running event loop. Healthy output contains `GUI connected` and `Bye Bye...`, with no Python traceback, missing Qt resource warning, or empty patchbay-theme warning.

This smoke test validates startup and daemon communication only. It does not validate connection persistence. The remaining acceptance test is to launch Ardour or Carla in a session, create PipeWire/JACK connections, save and close the session, reopen it, and confirm that the graph is restored.
