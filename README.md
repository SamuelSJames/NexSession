# NexSession

A GNU/Linux audio session manager focused on Fedora and PipeWire workflows.

NexSession is a GNU/Linux session manager for audio programs such as Ardour, Carla, QTractor, Guitarix, Patroneo, Jack Mixer, etc.<br>
The principle is to load together audio programs, then be able to save or close all documents together.<br>
Its main purpose is to manage NSM compatible programs, but it also helps for other programs.<br>

Project status
---------------------

NexSession is an active modernization fork of RaySession. The current development tree has completed the NexSession rebrand, Fedora Qt 6 build repair, application icon replacement, GUI startup repair, and patchbay theme-default repair.

Audio routing currently uses PipeWire's JACK compatibility path. The next major milestone is a PipeWire-native engine; see [NEXSESSION_ROADMAP.md](NEXSESSION_ROADMAP.md). Developers and AI agents should read [HANDOFF.md](HANDOFF.md) before changing the current worktree because it contains the exact implementation decisions, verification history, known gaps, and next steps.

Features
---------------------

* Load many programs together and remember their documents and JACK connections in a unified folder
* Nice patchbay with stereo connections, wrappable boxes and a search tool
* Snapshot at each save (optional), then you can go back to the snapshot (it uses `git`)
* Save client as template, and then restore it easily
* Save session as template
* Make almost all actions and get several informations with the CLI named `nex_control`
* Script sessions and clients actions with shell scripts
* Remember and recall JACK configuration with the jack_config session scripts
* Having sub-sessions working through the network with the "Network Session" template
* Remember the virtual desktop of the programs (requires `wmctrl`, doesn't work with Wayland)
* Bookmark the current session folder in your file manager and file pickers (gtk, kde, qt, fltk)
* Many others...


Install
---------------------

Read [INSTALL.md](INSTALL.md). Fedora users should also read [docs/fedora-pipewire.md](docs/fedora-pipewire.md).

The verified Fedora development commands are:

```bash
git submodule update --init
make LRELEASE=lrelease-qt6
./src/bin/nexsession
sudo make install PREFIX=/usr/local LRELEASE=lrelease-qt6
```

The build discovers Fedora's Qt 6 resource compiler through `qtpaths6`; a distribution-specific `RCC` override is normally unnecessary.


Credits
---------------------

NexSession respectfully began as a fork of **RaySession**, originally developed by **Mathieu Picot (houston4444)**.

- Original project: https://github.com/Houston4444/RaySession
- Original author's support page: https://liberapay.com/Houston4444

NexSession is built on top of Mathieu's excellent work and the translator/contributor community around the original project. Full translator credits are listed in [TRANSLATORS](TRANSLATORS).

License: GNU General Public License v2 — see [COPYING](COPYING).


Infos
---------------------

You can see documentation on NSM protocol at: https://new-session-manager.jackaudio.org/api/index.html
