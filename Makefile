#!/usr/bin/make -f
# Makefile for NexSession #
# ----------------------- #
# Originally created by houston4444 as NexSession
# Rebranded as NexSession
#
PREFIX ?= /usr/local
DESTDIR =
DEST_NEX := $(DESTDIR)$(PREFIX)/share/nexsession

LINK = ln -s -f
LRELEASE ?= lrelease
RCC ?= rcc
QT_VERSION ?= 6

# if you set QT_VERSION environment variable to 5 at the make command
# it will choose the other commands QT_API, pyuic5, pylupdat56.

ifeq ($(QT_VERSION), 6)
	QT_API ?= PyQt6
	PYUIC ?= pyuic6
	PYLUPDATE ?= pylupdate6
	RCC_EXEC := $(shell command -v $(RCC) 2>/dev/null)
	RCC_QT6 := $(shell qtpaths6 --query QT_HOST_LIBEXECS 2>/dev/null)/rcc
	ifeq (/rcc, $(RCC_QT6))
		RCC_QT6 := /usr/lib/qt6/libexec/rcc
	endif

	ifeq (, ${RCC_EXEC})
		RCC := ${RCC_QT6}
	else
		ifeq ($(shell readlink ${RCC_EXEC}), qtchooser)
			ifneq (, $(wildcard ${RCC_QT6}))
				RCC := ${RCC_QT6}
			endif
		endif
	endif

	ifeq (, $(shell which $(LRELEASE)))
		LRELEASE := lrelease-qt6
	endif

else
	QT_API ?= PyQt5
	PYUIC ?= pyuic5
	PYLUPDATE ?= pylupdate5
	ifeq (, $(shell which $(LRELEASE)))
		LRELEASE := lrelease-qt5
	endif
endif

# neeeded for make install
BUILD_CFG_FILE := src/shared/qt_api.py
QT_API_INST := $(shell grep ^QT_API= $(BUILD_CFG_FILE) 2>/dev/null| cut -d'=' -f2| cut -d"'" -f2)
QT_API_INST ?= PyQt5

ICON_SIZES := 16 24 32 48 64 96 128 256

PYTHON := python3
ifeq (, $(shell which $(PYTHON)))
	PYTHON := python
endif

PATCHBAY_DIR=HoustonPatchbay

# ---------------------

all: PATCHBAY QT_PREPARE RES UI LOCALE

PATCHBAY:
	@(cd $(PATCHBAY_DIR) && $(MAKE))

QT_PREPARE:
	$(info compiling for Qt$(QT_VERSION) using $(QT_API))
	$(file > $(BUILD_CFG_FILE),QT_API='$(QT_API)')

    ifneq ($(QT_API), $(QT_API_INST))
		rm -f *~ src/*~ src/*.pyc src/frontend/ui/*.py \
		    resources/locale/*.qm src/resources_rc.py
    endif
	install -d src/gui/ui

# ---------------------
# Resources

RESOURCE_FILES := $(shell sed -n 's|.*<file>\(.*\)</file>.*|resources/\1|p' resources/resources.qrc)

RES: src/gui/resources_rc.py

src/gui/resources_rc.py: resources/resources.qrc $(RESOURCE_FILES)
	${RCC} -g python $< -o $@.tmp
	sed 's/ PySide. / qtpy /' $@.tmp > $@
	rm -f $@.tmp

# ---------------------
# UI code

UI: $(shell \
	ls resources/ui/*.ui| sed 's|\.ui$$|.py|'| sed 's|^resources/|src/gui/|')

src/gui/ui/%.py: resources/ui/%.ui
	$(PYUIC) $< -o $@
	
# ------------------------
# # Translations Files

LOCALE: locale

locale: locale/nexsession_en.qm \
		locale/nexsession_fr.qm \

locale/%.qm: locale/%.ts
	-$(LRELEASE) $< -qm $@

# -------------------------

clean:
	@(cd $(PATCHBAY_DIR) && $(MAKE) $@)
	rm -f *~ src/*~ src/*.pyc src/gui/resources_rc.py locale/*.qm
	rm -f -R src/gui/ui
	rm -f -R src/__pycache__ src/*/__pycache__ src/*/*/__pycache__ \
		  src/*/*/*/__pycache__
	rm -f src/shared/qt_api.py

# -------------------------

debug:
	$(MAKE) DEBUG=true

# -------------------------

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/nexsession
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-daemon
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-proxy
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-jack_checker_daemon
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-jack_config_script
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-pulse2jack
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-alsapatch
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-jackpatch
	rm -f $(DESTDIR)$(PREFIX)/bin/nex-network
	rm -f $(DESTDIR)$(PREFIX)/bin/nex_control
	rm -f $(DESTDIR)$(PREFIX)/bin/nex_git

	rm -f $(DESTDIR)$(PREFIX)/share/applications/nexsession.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/nex-alsapatch.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/nex-jack_checker.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/nex-jackpatch.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/applications/nex-network.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/*/apps/nexsession.png
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/nexsession.svg
	rm -rf $(DESTDIR)/etc/xdg/nexsession/client_templates/40_nex_nsm
	rm -rf $(DESTDIR)/etc/xdg/nexsession/client_templates/60_nex_lash
	rm -f $(DESTDIR)/etc/bash_completion.d/nex_completion.sh
	rm -f $(DESTDIR)$(PREFIX)/share/bash-completion/completions/nex_control
	rm -rf $(DEST_NEX)

install:
	# Create directories
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -d $(DESTDIR)$(PREFIX)/share/applications/
	install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/
	install -d $(DEST_NEX)/
	install -d $(DEST_NEX)/locale/
	install -d $(DEST_NEX)/$(_DIR)/
	install -d $(DEST_NEX)/$(PATCHBAY_DIR)/locale/
	install -d $(DESTDIR)/etc/xdg/nexsession/client_templates/
	install -d $(DESTDIR)$(PREFIX)/share/bash-completion/completions/
	
	# Install icons
	for sz in $(ICON_SIZES);do \
		install -d $(DESTDIR)$(PREFIX)/share/icons/hicolor/$${sz}x$${sz}/apps/ ;\
		install -m 644 resources/main_icon/$${sz}x$${sz}/nexsession.png \
			$(DESTDIR)$(PREFIX)/share/icons/hicolor/$${sz}x$${sz}/apps/ ;\
	done

	# Copy Templates Factory
	cp -r client_templates/40_nex_nsm  $(DESTDIR)/etc/xdg/nexsession/client_templates/
	cp -r client_templates/60_nex_lash $(DESTDIR)/etc/xdg/nexsession/client_templates/
	cp -r client_templates  $(DEST_NEX)/
	cp -r session_templates $(DEST_NEX)/
	cp -r session_scripts   $(DEST_NEX)/
	cp -r data              $(DEST_NEX)/

	# Copy completion script
	cp src/completion/nex_completion.sh $(DESTDIR)$(PREFIX)/share/bash-completion/completions/nex_control
	sed -i "s|XXX_PYCOMPLETION_XXX|$(PREFIX)/share/nexsession/src/completion|" \
		$(DESTDIR)$(PREFIX)/share/bash-completion/completions/nex_control

	# Copy patchbay themes, manual and lib
	cp -r HoustonPatchbay/themes $(DEST_NEX)/$(PATCHBAY_DIR)/
	cp -r HoustonPatchbay/manual $(DEST_NEX)/$(PATCHBAY_DIR)/
	cp -r HoustonPatchbay/source $(DEST_NEX)/$(PATCHBAY_DIR)/

	# Copy Desktop Files
	install -m 644 data/share/applications/*.desktop \
		$(DESTDIR)$(PREFIX)/share/applications/

	# Install icons, scalable
	install -m 644 resources/main_icon/scalable/nexsession.svg \
		$(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/

	# Install main code
	cp -r src $(DEST_NEX)/
	rm -rf $(DEST_NEX)/src/tests
	rm -f $(DEST_NEX)/src/bin/conf_testou.py
	rm -f $(DEST_NEX)/src/bin/qt6_app.py
	find $(DEST_NEX)/src $(DEST_NEX)/$(PATCHBAY_DIR)/source \
		-type d -name __pycache__ -prune -exec rm -rf {} +
	find $(DEST_NEX)/src $(DEST_NEX)/$(PATCHBAY_DIR)/source \
		-type f \( -name '*.pyc' -o -name '*.pyo' \) -delete

	$(LINK) ../share/nexsession/src/bin/nex-jack_checker_daemon $(DESTDIR)$(PREFIX)/bin/
	$(LINK) ../share/nexsession/src/bin/nex-jack_config_script  $(DESTDIR)$(PREFIX)/bin/
	$(LINK) ../share/nexsession/src/bin/nex-pulse2jack          $(DESTDIR)$(PREFIX)/bin/
	$(LINK) ../share/nexsession/src/bin/nex-alsapatch           $(DESTDIR)$(PREFIX)/bin/
	$(LINK) ../share/nexsession/src/bin/nex-jackpatch           $(DESTDIR)$(PREFIX)/bin/
	$(LINK) ../share/nexsession/src/bin/nex-network             $(DESTDIR)$(PREFIX)/bin/
	$(LINK) ../share/nexsession/src/bin/nex_git                 $(DESTDIR)$(PREFIX)/bin/
	
	# install local manual
	cp -r manual $(DEST_NEX)/
	
	# install utility-scripts
	cp -r utility-scripts $(DEST_NEX)/
	
	# install main bash scripts to bin
	install -m 755 data/bin/nexsession  $(DESTDIR)$(PREFIX)/bin/
	install -m 755 data/bin/nex-daemon  $(DESTDIR)$(PREFIX)/bin/
	install -m 755 data/bin/nex_control $(DESTDIR)$(PREFIX)/bin/
	
	# Install Translations
	install -m 644 locale/*.qm $(DEST_NEX)/locale/
	install -m 644 $(PATCHBAY_DIR)/locale/*.qm $(DEST_NEX)/$(PATCHBAY_DIR)/locale
