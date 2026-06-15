# NexSession

A GNU/Linux audio session manager — fork of [RaySession](https://github.com/Houston4444/RaySession) by Mathieu Picot (houston4444).

NexSession is a GNU/Linux session manager for audio programs such as Ardour, Carla, QTractor, Guitarix, Patroneo, Jack Mixer, etc.<br>
The principle is to load together audio programs, then be able to save or close all documents together.<br>
Its main purpose is to manage NSM compatible programs, but it also helps for other programs.<br>

Features
---------------------

* Load many programs together and remember their documents and JACK connections in a unified folder
* Nice patchbay with stereo connections, wrappable boxes and a search tool
* Snapshot at each save (optional), then you can go back to the snapshot (it uses `git`)
* Save client as template, and then restore it easily
* Save session as template
* Make almost all actions and get several informations with the CLI named `ray_control`
* Script sessions and clients actions with shell scripts
* Remember and recall JACK configuration with the jack_config session scripts
* Having sub-sessions working through the network with the "Network Session" template
* Remember the virtual desktop of the programs (requires `wmctrl`, doesn't work with Wayland)
* Bookmark the current session folder in your file manager and file pickers (gtk, kde, qt, fltk)
* Many others...


Install
---------------------

Read [INSTALL.md](INSTALL.md)


Credits
---------------------

NexSession is a fork of **RaySession**, originally developed by **Mathieu Picot (houston4444)**.

- Original project: https://github.com/Houston4444/RaySession
- Original author's support page: https://liberapay.com/Houston4444

NexSession is built on top of the excellent work done by Mathieu and the RaySession community of translators and contributors. Full translator credits are listed in [TRANSLATORS](TRANSLATORS).

License: GNU General Public License v2 — see [COPYING](COPYING).


Infos
---------------------

You can see documentation on NSM protocol at: https://new-session-manager.jackaudio.org/api/index.html
