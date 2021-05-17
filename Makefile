VER = 0.1.2

PREFIX ?= /usr
MANDIR ?= $(PREFIX)/share/man
DOCDIR ?= $(PREFIX)/share/doc
BINDIR ?= $(PREFIX)/bin
SBINDIR ?= /sbin
PKGDIR = /tmp/yalpack-$(VER)
PKGDEST = $(PKGDIR)/dest

all:
	@echo To install to the system, and then reinstall as a package \(recommended for first-time installations\), run \'make package\'.
	@echo
	@echo For upgrades, use \'DESTDIR=$(PKGDEST) make install\' and make a NAME file. Then, use pkgmake and pkgup as usual.
	@echo
	@echo \'make clean\' will remove compressed man pages from this directory and delete LICENSE and README from src/doc.
	@echo
	@echo \'make uninstall\' will uninstall yalpack from the specified DESTDIR. Please note that /var/yalpack and its subdirectories are generated by running yalpack scripts, and must be removed manually if desired.

install:
	@rm -rf man-gz
	@mkdir -pv $(DESTDIR)$(PREFIX)/bin
	@mkdir -pv $(DESTDIR)$(SBINDIR)
	@mkdir -pv man-gz
	@mkdir -pv $(DESTDIR)$(MANDIR)/man1
	@mkdir -pv $(DESTDIR)$(DOCDIR)/yalpack-$(VER)
	@cp -v --preserve=mode,timestamps ./{LICENSE,README} src/doc/
	@cp -v --preserve=mode,timestamps src/doc/* $(DESTDIR)$(DOCDIR)/yalpack-$(VER)/
	@cp -v --preserve=mode,timestamps src/bin/* $(DESTDIR)$(PREFIX)/bin/
	@cp -v --preserve=mode,timestamps src/sbin/* $(DESTDIR)$(SBINDIR)/
	@cp -v --preserve=mode,timestamps src/man/* man-gz/
	@gzip man-gz/*
	@cp -v --preserve=mode,timestamps man-gz/* $(DESTDIR)$(MANDIR)/man1
	@chmod 744 $(DESTDIR)$(SBINDIR)/{pkgcheck,pkginst,pkgmake,pkgremove,pkgup,liblist}
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/{libcheck,libprecise,pkglist}
	@echo
	@echo Files moved to $(DESTDIR)
	@echo
	@echo If an existing yalpack installation is to be upgraded, make a NAME file at $(PKGDIR) before running pkgmake and pkgup.

package:
	@rm -rf man-gz
	@mkdir -pv $(DESTDIR)$(PREFIX)/bin
	@mkdir -pv $(DESTDIR)$(SBINDIR)
	@cp -v --preserve=mode,timestamps src/bin/* $(DESTDIR)$(PREFIX)/bin/
	@cp -v --preserve=mode,timestamps src/sbin/* $(DESTDIR)$(SBINDIR)/
	@chmod 744 $(DESTDIR)$(SBINDIR)/{pkgcheck,pkginst,pkgmake,pkgremove,pkgup,liblist}
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/{libcheck,libprecise,pkglist}
	@mkdir -pv $(PKGDEST)
	@mkdir -pv $(PKGDEST)$(PREFIX)/bin
	@mkdir -pv $(PKGDEST)$(SBINDIR)
	@mkdir -pv $(PKGDEST)$(MANDIR)/man1
	@mkdir -pv $(PKGDEST)$(DOCDIR)/yalpack-$(VER)
	@mkdir -pv man-gz
	@cp -v --preserve=mode,timestamps ./{LICENSE,README} src/doc/
	@cp -v --preserve=mode,timestamps src/doc/* $(PKGDEST)$(DOCDIR)/yalpack-$(VER)/
	@cp -v --preserve=mode,timestamps src/bin/* $(PKGDEST)$(PREFIX)/bin/
	@cp -v --preserve=mode,timestamps src/sbin/* $(PKGDEST)$(SBINDIR)/
	@cp -v --preserve=mode,timestamps src/man/* man-gz/
	@gzip man-gz/*
	@cp -v --preserve=mode,timestamps man-gz/* $(PKGDEST)$(MANDIR)/man1
	@chmod 744 $(PKGDEST)$(SBINDIR)/{pkgcheck,pkginst,pkgmake,pkgremove,pkgup,liblist}
	@chmod 755 $(PKGDEST)$(PREFIX)/bin/{libcheck,libprecise,pkglist}
	@echo yalpack > $(PKGDIR)/NAME
	@pkgmake yalpack-$(VER)
	@pkginst yalpack-$(VER)
	@echo yalpack should now be installed as a package. Run pkglist to confirm.

clean:
	@rm -rvf man-gz
	@rm -vf src/doc/{LICENSE,README}

uninstall:
	@rm -vf $(DESTDIR)$(SBINDIR)/{pkgcheck,pkginst,pkgmake,pkgremove,pkgup,liblist}
	@rm -vf $(DESTDIR)$(PREFIX)/bin/{libcheck,libprecise,pkglist}
	@rm -vf $(DESTDIR)$(MANDIR)/man1/{pkgcheck,pkginst,pkgmake,pkgremove,pkgup,liblist,libcheck,libprecise}.1*
	@rm -vf $(DESTDIR)$(DOCDIR)/yalpack-$(VER)
	@echo
	@echo Complete. The yalpack directory in /var \(which includes package and library information\) can be removed by administrator discretion if it exists.
