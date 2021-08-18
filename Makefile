VER = 0.2.0

TMP ?= /tmp
PREFIX ?= /usr
SHAREDIR ?= $(PREFIX)/share
MANDIR ?= $(SHAREDIR)/man
DOCDIR ?= $(SHAREDIR)/doc
BINDIR ?= $(PREFIX)/bin
SBINDIR ?= $(PREFIX)/sbin
PKGDIR = $(TMP)/yalpack-$(VER)
PKGDEST = $(PKGDIR)/dest
SYSCONFDIR = /etc
all:
	@echo
	@echo \'make package\' is intended for both first-time installations and upgrades. It will install the scripts to the system and then reinstall \(or re-upgrade\) as a yalpack package.
	@echo
	@echo \'make no-use\' is for placing yalpack in a DESTDIR for later packaging only. To install yalpack to the system for actual use, call \'make package\' instead.
	@echo
	@echo \'make clean\' will remove compressed man pages from this directory and delete copies of top-level files from src/doc.
	@echo
	@echo \'make uninstall\' will uninstall yalpack from the specified DESTDIR. Please note that /var/yalpack and its subdirectories are generated by running yalpack scripts, and must be removed manually if desired.
	@echo

package:
	@echo
	@rm -rf man-gz
	@chmod 744 validate-config.sh
	@./validate-config.sh $(SBINDIR) $(TMP) $(VER)
	@chmod 644 validate-config.sh
	@mkdir -pv $(DESTDIR)$(BINDIR)
	@mkdir -pv $(DESTDIR)$(SBINDIR)
	@cp -v --preserve=mode,timestamps --dereference src/bin/* $(DESTDIR)$(BINDIR)/
	@cp -v --preserve=mode,timestamps --dereference src/sbin/* $(DESTDIR)$(SBINDIR)/
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgcheck
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkginst
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgmake
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgremove
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgup
	@chmod 744 $(DESTDIR)$(SBINDIR)/liblist
	@chmod 755 $(DESTDIR)$(BINDIR)/libcheck
	@chmod 755 $(DESTDIR)$(BINDIR)/libprecise
	@chmod 755 $(DESTDIR)$(BINDIR)/pkglist
	@chmod 755 $(DESTDIR)$(BINDIR)/yalfind
	@rm -rvf $(PKGDEST)
	@mkdir -pv $(PKGDEST)
	@mkdir -pv $(PKGDEST)$(BINDIR)
	@mkdir -pv $(PKGDEST)$(SBINDIR)
	@mkdir -pv $(PKGDEST)$(SYSCONFDIR)
	@mkdir -pv $(PKGDEST)$(SHAREDIR)/yalpack
	@mkdir -pv $(PKGDEST)$(MANDIR)/man1
	@mkdir -pv $(PKGDEST)$(MANDIR)/man5
	@mkdir -pv $(PKGDEST)$(DOCDIR)/yalpack-$(VER)
	@mkdir -pv man-gz
	@cp -v --preserve=mode,timestamps ./LICENSE src/doc/
	@cp -v --preserve=mode,timestamps ./README src/doc/
	@cp -v --preserve=mode,timestamps ./Customization src/doc/
	@cp -v --preserve=mode,timestamps ./man-pages src/doc/
	@cp -v --preserve=mode,timestamps src/etc/yalpack.conf $(PKGDEST)$(SYSCONFDIR)/
	@cp -v --preserve=mode,timestamps src/doc/* $(PKGDEST)$(DOCDIR)/yalpack-$(VER)/
	@cp -v --preserve=mode,timestamps src/bin/* $(PKGDEST)$(BINDIR)/
	@cp -v --preserve=mode,timestamps src/sbin/* $(PKGDEST)$(SBINDIR)/
	@cp -v --preserve=mode,timestamps src/share/* $(PKGDEST)$(SHAREDIR)/yalpack/
	@cp -v --preserve=mode,timestamps src/man/* man-gz/
	@gzip man-gz/*
	@cp -v --preserve=mode,timestamps man-gz/*1* $(PKGDEST)$(MANDIR)/man1
	@cp -v --preserve=mode,timestamps man-gz/*5* $(PKGDEST)$(MANDIR)/man5
	@chmod 744 $(PKGDEST)$(SBINDIR)/pkgcheck
	@chmod 744 $(PKGDEST)$(SBINDIR)/pkginst
	@chmod 744 $(PKGDEST)$(SBINDIR)/pkgmake
	@chmod 744 $(PKGDEST)$(SBINDIR)/pkgremove
	@chmod 744 $(PKGDEST)$(SBINDIR)/pkgup
	@chmod 744 $(PKGDEST)$(SBINDIR)/liblist
	@chmod 755 $(PKGDEST)$(BINDIR)/libcheck
	@chmod 755 $(PKGDEST)$(BINDIR)/libprecise
	@chmod 755 $(PKGDEST)$(BINDIR)/pkglist
	@chmod 755 $(PKGDEST)$(BINDIR)/yalfind
	@chmod 744 $(PKGDEST)$(SHAREDIR)/yalpack/*
	@cp -v --preserve=mode,timestamps src/install.sh $(PKGDIR)
	@chmod 744 $(PKGDIR)/install.sh
	@echo yalpack > $(PKGDIR)/NAME
	@pkgmake yalpack-$(VER)
	@chmod 744 ./make-package.sh	
	@./make-package.sh $(VER) $(DESTDIR)$(SBINDIR)
	@chmod 644 ./make-package.sh
	@echo '	'$(tput smul)yalpack$(tput rmul) should now be installed as a package. Run $(tput smul)pkglist$(tput rmul) to confirm.
	@echo

no-use:
	@echo
	@rm -rf man-gz
	@mkdir -pv $(DESTDIR)$(BINDIR)
	@mkdir -pv $(DESTDIR)$(SBINDIR)
	@cp -v --preserve=mode,timestamps --dereference src/bin/* $(DESTDIR)$(BINDIR)/
	@cp -v --preserve=mode,timestamps --dereference src/sbin/* $(DESTDIR)$(SBINDIR)/
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgcheck
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkginst
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgmake
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgremove
	@chmod 744 $(DESTDIR)$(SBINDIR)/pkgup
	@chmod 744 $(DESTDIR)$(SBINDIR)/liblist
	@chmod 755 $(DESTDIR)$(BINDIR)/libcheck
	@chmod 755 $(DESTDIR)$(BINDIR)/libprecise
	@chmod 755 $(DESTDIR)$(BINDIR)/pkglist
	@chmod 755 $(DESTDIR)$(BINDIR)/yalfind
	@mkdir -pv $(DESTDIR)$(SYSCONFDIR)
	@mkdir -pv $(DESTDIR)$(SHAREDIR)/yalpack
	@mkdir -pv $(DESTDIR)$(MANDIR)/man1
	@mkdir -pv $(DESTDIR)$(MANDIR)/man5
	@mkdir -pv $(DESTDIR)$(DOCDIR)/yalpack-$(VER)
	@mkdir -pv man-gz
	@cp -v --preserve=mode,timestamps ./LICENSE src/doc/
	@cp -v --preserve=mode,timestamps ./README src/doc/
	@cp -v --preserve=mode,timestamps ./Customization src/doc/
	@cp -v --preserve=mode,timestamps ./man-pages src/doc/
	@cp -v --preserve=mode,timestamps src/etc/yalpack.conf $(DESTDIR)$(SYSCONFDIR)/
	@cp -v --preserve=mode,timestamps src/doc/* $(DESTDIR)$(DOCDIR)/yalpack-$(VER)/
	@cp -v --preserve=mode,timestamps src/share/* $(DESTDIR)$(SHAREDIR)/yalpack/
	@cp -v --preserve=mode,timestamps src/man/* man-gz/
	@gzip man-gz/*
	@cp -v --preserve=mode,timestamps man-gz/*1* $(DESTDIR)$(MANDIR)/man1
	@cp -v --preserve=mode,timestamps man-gz/*5* $(DESTDIR)$(MANDIR)/man5
	@chmod 744 $(DESTDIR)$(SHAREDIR)/yalpack/*
	@cp -v --preserve=mode,timestamps src/install.sh $(DESTDIR)
	@cp -v --preserve=mode,timestamps validate-config.sh $(DESTDIR)
	@chmod 744 $(DESTDIR)/validate-config.sh
	@chmod 744 $(DESTDIR)/install.sh
	@echo
	@echo '	'$(tput smul)yalpack$(tput rmul) is now ready for packaging in DESTDIR.
	@echo

clean:
	@echo
	@rm -rvf man-gz
	@rm -vf src/doc/LICENSE
	@rm -vf src/doc/README
	@rm -vf src/doc/Customization
	@rm -vf src/doc/man-pages
	@echo
	
uninstall:
	@echo
	@rm -vf $(DESTDIR)$(SBINDIR)/pkgcheck
	@rm -vf $(DESTDIR)$(SBINDIR)/pkginst
	@rm -vf $(DESTDIR)$(SBINDIR)/pkgmake
	@rm -vf $(DESTDIR)$(SBINDIR)/pkgremove
	@rm -vf $(DESTDIR)$(SBINDIR)/pkgup
	@rm -vf $(DESTDIR)$(SBINDIR)/liblist
	@rm -vf $(DESTDIR)$(BINDIR)/libcheck
	@rm -vf $(DESTDIR)$(BINDIR)/libprecise
	@rm -vf $(DESTDIR)$(BINDIR)/pkglist
	@rm -vf $(DESTDIR)$(BINDIR)/yalfind
	@rm -vf $(SYSCONFDIR)/yalpack.conf
	@rm -vf $(DESTDIR)$(MANDIR)/man1/pkgcheck.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/yalfind.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/pkginst.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/pkgmake.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/pkglist.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/pkgremove.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/pkgup.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/liblist.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/libcheck.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man1/libprecise.1*
	@rm -vf $(DESTDIR)$(MANDIR)/man5/restore-yalpack.5*
	@rm -vf $(DESTDIR)$(MANDIR)/man5/newfile-yalpack.5*
	@rm -rvf $(DESTDIR)$(SHAREDIR)/yalpack
	@rm -rvf $(DESTDIR)$(DOCDIR)/yalpack-$(VER)
	@echo
	@echo Complete. The yalpack directory in /var \(which includes package and library information\) can be removed by administrator discretion if it exists.
	@echo
