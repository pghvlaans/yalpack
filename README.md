**Notice**

`yalpack` is no longer in development. If anyone wants to use it as a starting point for their own LFS package management system, please see the "dev" branch. It has various improvements over `yalpack-0.1.8`, although it has not been fully tested. Many thanks to everyone who tried `yalpack` over the last several months, and I apologize for any inconvenience.

**yalpack-0.1.8**

This is yalpack (Yet Another Lfs PACKage manager), a basic set of package management tools for LFS/BLFS-based systems. yalpack was inspired by pkgtools from Slackware, although there are differences in functionality and package structure.

yalpack is intended to make managing upgrades and trying new software easier on a Linux From Scratch installation: 
* Install compiled software as packages
* Easily remove unwanted packages (no need to worry about "make uninstall")
* Simple(r) pacakge upgrades
* Handle and log ".new" files automatically, with a script for easy .new file management
* List installed packages and versions
* Gather, store and check information about dynamic library usage
* Search for which package provided which file/directory/symlink
* Easily regenerate the yalpack data directory from a backup collection of installed package trees

yalpack requires only a POSIX-compliant shell, coreutils, util-linux, findutils, ncurses, grep and tar to operate. gzip is needed for installation. Dependency resolution is not provided, and packages are still meant to be built from source. A number of the included scripts are intended as aids to dependency management, however.

Although the envisioned use case of yalpack is to add, upgrade and remove packages from on top of a "core" LFS system, it could also be used to manage every package once the temporary toolchain has been completed. This has been tested successfully for LFS 10.1 (SysVinit) (x86_64, Linux 5.12.3, host gcc 10.3) and the LFS r10.1-99 development version, which has a merged-usr setup.

yalpack has not been tested on earlier versions of Linux from Scratch. Because ldd is used to collect information about binaries, moreover, it should never be used with versions of glibc earlier than 2.27. For an explanation, see the "Security" section in the ldd man page.

For installation and upgrades of yalpack, see INSTALL or run `make all` for details.

*POSIX compliance*

Providing a POSIX-compliant package management solution is a priority for this project. All yalpack-0.1.8 scripts have been tested to run with /bin/sh linked to dash, bash and zsh. As indicated in the Linux From Scratch instructions, /bin/sh should nevertheless be a symlink to /bin/bash when building the base system.

**USING YALPACK OUTSIDE OF AN LFS BOOT OR CHROOT CONTEXT WOULD INSTALL AND/OR REMOVE PACKAGES ON THE HOST SYSTEM, RESULTING IN MAYHEM.**

yalpack provides the following tools for package management on LFS-based systems:
* For root:
	* pkgmake: Making yalpack packages
	* pkginst: Installing yalpack packages
	* pkgup: Upgrading yalpack packages
	* pkgremove: Removing yalpack packages
	* pkgcheck: Checking for information about yalpack packages
	* liblist: Generating information about dynamic libraries used by all binaries in the following directories:
		* `/bin`
		* `/sbin`
		* `/usr/*`
		* `/opt/*`
	  
	  To add more locations, edit the shell script at `/sbin/liblist`. A full file path can be passed to liblist to update information about a single binary.
* For all users:
	* libcheck: Checking for binaries and yalpack packages using dynamic libraries matching a search term
	* libprecise: Checking for binaries and yalpack packages using a particular dynamic library
	* pkglist: Providing a list of yalpack-installed packages
	* yalfind: Use search terms or exact file paths to determine which package provided matching files, directories and symlinks

In addition, the following utility scripts can be found in /usr/share/yalpack:
* newfiles: Update the NEWFILES directory to reflect currently-existing files; optionally, manage .new files.
* restore-yalpack: Regenerate the yalpack data directory using a package tree backup in case of data loss or other accidents.
* backups: Set up a parallel package tree in the backup locations, if necessary. Can be used in case of data loss or changes to /etc/yalpack.conf.

When building from source with the objective of installing a yalpack package, please remember the following considerations:

* At the install stage, use `DESTDIR=/tmp/[NAME]-[VERSION]/dest`, where NAME and VERSION correspond to the correct package name and version, separated by a hyphen. See `sample-dewit.sh` for an idea of how to wrap build instructions in a script to automate this. Read other LFS instructions on copying, installing and making symlinks carefully, and ensure that the appropriate directories exist under `dest/`. 
	
* Before running pkgmake, supply a file at `/tmp/[NAME]-[VERSION]/NAME` containing the package's name, e.g. `echo frotz > /tmp/frotz-2.52/NAME`
	
* pkginst repairs absolute symlinks such that they are relative to the root directory once installed. LFS/BLFS instructions to make absolute symlinks can be done either as-is or by using `/tmp/[NAME]-[VERSION]/dest/` rather than `/`.

* All installed text files in /etc and /home are marked as .new by pkgmake. If other .new files are needed, they should be renamed manually prior to making the package. pkginst handles the renaming of .new files.

* Any executable file at `/tmp/[NAME]-[VERSION]/install.sh` will be executed by pkginst after all new files, directories and symlinks have been created. Bear in mind that moving files and creating symlinks with install.sh will result in said files and symlinks being unaffected by pkgremove (and possibly pkgup).

* At times, it may be desirable to keep more than one version of a package installed on the system (e.g. the kernel and kernel modules). In such cases, the NAME file should be a string with the version information included: `echo linux-5.12.3 > /tmp/linux-5.12.3/NAME`. In case of conflicting files, the more recently-installed package will 'win.' When calling yalpack scripts that take the package name as the input, the proper version information will also be required: `pkgup linux-5.12.2 linux-5.12.3`.

**Library upgrades**

Aside from linux-vdso and ld-linux, the yalpack package installation and/or upgrade process involves the following libraries:

* libacl.so.1	(acl)
* libattr.so.1	(attr)
* libc.so.6 	(glibc)
* libm.so.6	(glibc)

Upgrade and downgrade tests were successful for acl and attr (10.1 stable and dev).

As might be expected, the situation for glibc is more complicated. For yalpack-0.1.8, it was possible to move between glibc-2.32 and 2.33 on a 10.1 LFS (stable) system that had been built with glibc-2.32, provided that no critical packages (e.g. acl, attr) had been built with glibc-2.33 in the mean time.

The 10.1 LFS dev system used for testing had been built with glibc-2.33; an attempted downgrade to 2.32 managed to install the files, but calls of cat, etc. relying on glibc-2.33 subsequently failed, resulting in the full installation process being incomplete. The system was bricked thereafter.

In summary, then, findings for glibc upgrades and downgrades with yalpack-0.1.8 are as follows:

* With LFS 10.1 stable:
	* Upgrades: tested to work (2.32 to 2.33)
	* Downgrades: if the "new" version is older than the version used to build the system, unknown and highly likely to fail.
* With LFS 10.1 dev:
	* Upgrades: to remain untested until glibc-2.34
	* Downgrades: known to fail if the "new" version is older than the version used to build the system.

Once glibc-2.34 is released in August 2021, upgrading glibc with yalpack will be tested for both the stable and development versions and this document updated accordingly. In the meantime, glibc downgrades and upgrades to versions beyond glibc-2.33 are unsupported.

*Packages without DESTDIR*

As of LFS 10.1, some packages in the book cannot use DESTDIR with `make install`. To install or upgrade bzip2, sysvinit or sysklogd with yalpack, use the following workarounds:

* bzip2: Use `make PREFIX=/tmp/bzip2-1.0.8/dest/usr install` in lieu of `make PREFIX=/usr install`
* sysvinit: Use the following steps:
	* Extract the sysvinit source tarball.
	* Copy /usr/share/doc/yalpack-0.1.8/sysvinit.dewit into the source directory.
	* To install a version other than 2.98, or to upgrade, edit the file accordingly (explanatory comments included).
	* Make the script executable and run.
* sysklogd: Use the following steps:
	* Extract the sysklogd source tarball.
	* Copy /usr/share/doc/yalpack-0.1.8/sysklogd.dewit into the source directory.
	* To install a version other than 1.5.1, select a job level or upgrade, edit the file accordingly (explanatory comments included).
	* Make the script executable and run.
	* Follow the post-installation instructions in the LFS book, or write them in to an install.sh script.

The build scripts provided in /usr/share/doc/yalpack-0.1.8 have hardcoded values. If TMP was changed in /etc/yalpack.conf, the value of TMP in the scripts should be changed accordingly.

The installation procedure in sysvinit.dewit was adapted from sysvinit.SlackBuild, provided by Slackware. Except for inordinately complicated installation procedures for packages in the Linux From Scratch book, distributing build scripts is beyond the scope of this project.

*Upgrading glibc and SysVinit*

As the Linux From Scratch documentation indicates, glibc upgrades generally entail a full system rebuild. Although yalpack 0.1.4+ has been tested to upgrade glibc up to 2.33, this type of upgrade should be treated with care and is not necessarily advisable. glibc downgrades (especially downgrades to versions older than the one used to build LFS) are unsupported altogether.

In order to avoid unmounting problems at the next halt or reboot, pkgup uses /sbin/telinit to reload /sbin/init if glibc or sysvinit upgrades are detected. *This procedure is untested on systemd-based installations.*

If upgrades to either of these packages are desired, please ensure that yalpack's version is **at least 0.1.4**.

**The directory structure of a yalpack package:**

	[NAME]-[VERSION].tar.xz
 	  |
	  |
	NAME VER TREE (install.sh) dest/
		     		     |
		                     |
				   (contents of package)

Everything under `dest/` is installed relative to root. `NAME` (and `install.sh`, if needed) must be supplied by the administrator; all other files are generated automatically.

yalpack makes use of the following directories, which will be made when the script in parentheses is run for the first time:

	/var/yalpack/packages	(pkgmake)
		Holds package tarballs; once a package has been installed, the package tarball need not be retained.
	/var/yalpack/pkgdata	(pkginst or yalpack's install.sh script)
		Holds reference information about installed packages.
	/var/yalpack/BIN-DEPS	(liblist; called by pkginst)
		Holds information about the dynamic libraries used by those binaries checked by liblist.

The yalpack main data directory, backup locations, build destination and sbin directory can all be changed by editing /etc/yalpack.conf. See "Customization" for details and instructions. 

Please note that the /var/yalpack directory and the backup locations will not be removed by running `pkgremove yalpack.`

**Package tree backups**

yalpack relies on the contents of `/var/yalpack` to operate. If this directory is lost (in whole or in part), using yalpack scripts could become inconvenient or impossible. For this reason, yalpack retains parallel package tree directories (main copy at `/var/yalpack/pkgdata/TREES`) in the following locations:

* `/var/log/yalpack`
* `/root/.yalpack-backup`

If either of these directories (or the TREES directory itself) is intact, and yalpack is installed, `/usr/share/yalpack/restore-yalpack` can be used to regenerate the rest of the `/var/yalpack` directory. Any lost package tarballs are unrecoverable, so it would still be best not to delete `/var/yalpack` if possible.

install.sh will set up the backups for new installations and any upgrades from versions of yalpack without backup capabilities.
