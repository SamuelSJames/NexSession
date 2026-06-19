from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import shutil
import subprocess


@dataclass(frozen=True)
class CheckResult:
    name: str
    ok: bool
    detail: str = ''


@dataclass(frozen=True)
class SystemHealth:
    distro: str
    checks: tuple[CheckResult, ...]

    @property
    def ok(self) -> bool:
        return all(check.ok for check in self.checks)

    def summary(self) -> str:
        failed = [check for check in self.checks if not check.ok]
        if not failed:
            return f'{self.distro}: PipeWire production setup detected'
        return f'{self.distro}: {len(failed)} setup issue(s) need attention'

    def detail_lines(self) -> list[str]:
        lines = []
        for check in self.checks:
            marker = 'OK' if check.ok else 'Needs setup'
            detail = f' - {check.detail}' if check.detail and not check.ok else ''
            lines.append(f'{marker}: {check.name}{detail}')
        return lines

    def report(self) -> str:
        return '\n'.join((self.summary(), '', *self.detail_lines()))


def _command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def _run_command(command: list[str], timeout: float = 1.5) -> subprocess.CompletedProcess[str] | None:
    try:
        return subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout)
    except (OSError, subprocess.TimeoutExpired):
        return None


def _user_service_active(service: str) -> bool:
    if not _command_exists('systemctl'):
        return False

    proc = _run_command(
        ['systemctl', '--user', 'is-active', '--quiet', service])
    if proc is None:
        return False

    return proc.returncode == 0


def _command_success(command: list[str], timeout: float = 1.5) -> bool:
    proc = _run_command(command, timeout)
    return bool(proc is not None and proc.returncode == 0)


def _command_output(command: list[str], timeout: float = 1.5) -> str:
    proc = _run_command(command, timeout)
    if proc is None or proc.returncode != 0:
        return ''

    return proc.stdout


def _pipewire_graph_available() -> bool:
    if not _command_exists('wpctl'):
        return False

    output = _command_output(['wpctl', 'status'], 2.5)
    return bool("PipeWire '" in output or 'WirePlumber' in output)


def _pipewire_pulse_available() -> bool:
    if not _command_exists('pactl'):
        return False

    output = _command_output(['pactl', 'info'], 2.5)
    return 'Server Name:' in output and 'PipeWire' in output


def _pipewire_link_available() -> bool:
    return _command_exists('pw-link') and _command_success(['pw-link', '-io'], 2.5)


def _jack_compat_available() -> bool:
    return (
        (_command_exists('pw-jack') and _command_success(['pw-jack', '-h']))
        or _command_exists('jack_lsp'))


def fedora_pipewire_repair_commands() -> str:
    return '''sudo dnf install -y \\
  pipewire \\
  wireplumber \\
  pipewire-pulseaudio \\
  pipewire-alsa \\
  pipewire-utils \\
  pipewire-jack-audio-connection-kit

sudo dnf swap --allowerasing pipewire-media-session wireplumber
sudo dnf install --allowerasing pipewire-pulseaudio

systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl --user restart pipewire pipewire-pulse wireplumber

wpctl status
pactl info
pw-link -io
pw-jack -h'''


def _distro_name() -> str:
    os_release = Path('/etc/os-release')
    if not os_release.exists():
        return 'Linux'

    values = {}
    try:
        for line in os_release.read_text(errors='replace').splitlines():
            key, sep, value = line.partition('=')
            if sep:
                values[key] = value.strip().strip('"')
    except OSError:
        return 'Linux'

    return values.get('PRETTY_NAME') or values.get('NAME') or 'Linux'


def get_system_health() -> SystemHealth:
    distro = _distro_name()
    pipewire_runtime = (
        _pipewire_graph_available()
        or _pipewire_link_available()
        or _user_service_active('pipewire.service'))
    wireplumber_runtime = (
        _pipewire_graph_available()
        or _user_service_active('wireplumber.service'))
    checks = (
        CheckResult(
            'PipeWire runtime',
            pipewire_runtime,
            'wpctl status, pw-link -io, or systemctl --user status pipewire.service'),
        CheckResult(
            'WirePlumber session manager',
            wireplumber_runtime,
            'wpctl status or systemctl --user status wireplumber.service'),
        CheckResult(
            'PulseAudio compatibility on PipeWire',
            _pipewire_pulse_available(),
            'install pipewire-pulseaudio'),
        CheckResult(
            'PipeWire link tools',
            _pipewire_link_available(),
            'install pipewire-utils'),
        CheckResult(
            'PipeWire JACK compatibility',
            _jack_compat_available(),
            'install pipewire-jack-audio-connection-kit'),
        CheckResult(
            'Git snapshots',
            _command_exists('git'),
            'install git'),
    )
    return SystemHealth(distro, checks)
