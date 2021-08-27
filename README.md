*This is the dev branch. Although it will eventually become yalpack-0.2.0, it has not been tested as thoroughly as the most recent release version in `main`. Some of the documentation has not yet been updated except for the version name, and may be inaccurate.*

**yalpack-0.2.0**

This is yalpack (Yet Another Lfs PACKage manager), a basic set of package management tools for LFS/BLFS-based systems. yalpack was inspired by `pkgtools` from Slackware, although there are differences in functionality and package structure.

yalpack is intended to make managing upgrades and trying new software easier on a Linux From Scratch installation: 
* Install compiled software as packages
* Easily remove unwanted packages (no need to worry about "make uninstall")
* Simple(r) pacakge upgrades
* Handle and log ".new" files automatically, with a script for easy .new file management
* List installed packages and versions
* Gather, store and check information about dynamic library usage
* Search for which package provided which file/directory/symlink
* Easily regenerate the yalpack data directory from a backup collection of installed package trees

yalpack requires only a POSIX-compliant shell, `coreutils`, `util-linux`, `findutils`, `ncurses`, `grep` and `tar` to operate. `gzip` is needed for installation. Dependency resolution is not provided, and packages are still meant to be built from source. A number of the included scripts are intended as aids to dependency management, however.

Although the envisioned use case of yalpack is to add, upgrade and remove packages from on top of a "core" LFS system, it could also be used to manage every package once the temporary toolchain has been completed. This has been tested successfully for LFS 10.1 (SysVinit) and 11.0 (SysVInit, systemd).

yalpack has not been tested on earlier versions of Linux from Scratch. Because `ldd` is used to collect information about binaries, moreover, it should never be used with versions of glibc earlier than 2.27. For an explanation, see the "Security" section in the `ldd` man page.

For installation and upgrades of yalpack, see INSTALL or run `make all` for details.

*POSIX compliance*

Providing a POSIX-compliant package management solution is a priority for this project. All yalpack-0.2.0 scripts have been tested to run with `/bin/sh` linked to `dash`, `bash` and `zsh`. As indicated in the Linux From Scratch instructions, `/bin/sh` should nevertheless be a symlink to `/bin/bash` when building the base system.

**USING YALPACK OUTSIDE OF AN LFS BOOT OR CHROOT CONTEXT WOULD INSTALL AND/OR REMOVE PACKAGES ON THE HOST SYSTEM, RESULTING IN MAYHEM.**

yalpack provides the following tools for package management on LFS-based systems:
* For root:
	* `pkgmake`: Making yalpack packages
	* `pkginst`: Installing yalpack packages
	* `pkgup`: Upgrading yalpack packages
	* `pkgremove`: Removing yalpack packages
	* `pkgcheck`: Checking for information about yalpack packages
	* `liblist`: Generating information about dynamic libraries used by all binaries
* For all users:
	* `libcheck`: Checking for binaries and yalpack packages using dynamic libraries matching a search term
	* `pkglist`: Providing a list of yalpack-installed packages
	* `yalfind`: Use search terms or exact file paths to determine which package provided matching files, directories and symlinks

In addition, the following utility scripts can be found in `/usr/share/yalpack`:
* `newfiles`: Update the NEWFILES directory to reflect currently-existing files; optionally, manage .new files.
* `restore-yalpack`: Regenerate the yalpack data directory using a package tree backup in case of data loss or other accidents.
* `backups`: Set up a parallel package tree in the backup locations, if necessary. Can be used in case of data loss or changes to /etc/yalpack.conf.

**Building software**

When building from source with the objective of installing a yalpack package, please remember the following considerations:

* At the install stage, use `DESTDIR=/tmp/[NAME]-[VERSION]/dest`, where NAME and VERSION correspond to the correct package name and version, separated by a hyphen. See `sample-dewit.sh` for an idea of how to wrap build instructions in a script to automate this. Read other LFS instructions on copying, installing and making symlinks carefully, and ensure that the appropriate directories exist under `dest/`. 
	
* Before running pkgmake, supply a file at `/tmp/[NAME]-[VERSION]/NAME` containing the package's name, e.g. `echo frotz > /tmp/frotz-2.52/NAME`
	
* `pkgmake` repairs absolute symlinks such that they are relative to the root directory once installed. LFS/BLFS instructions to make absolute symlinks can be done either as-is or by using `/tmp/[NAME]-[VERSION]/dest/` rather than `/`.

* All installed text files in `/etc` and `/home` are marked as .new by pkgmake. If other .new files are needed, they should be renamed manually prior to making the package. `pkginst` handles the renaming of .new files.

* Any executable file at `/tmp/[NAME]-[VERSION]/install.sh` will be executed by `pkginst` after all new files, directories and symlinks have been created. Bear in mind that moving files and creating symlinks with `install.sh` will result in said files and symlinks being unaffected by `pkgremove` (and possibly `pkgup`).

* At times, it may be desirable to keep more than one version of a package installed on the system (e.g. the kernel and kernel modules). In such cases, the NAME file should be a string with the version information included: `echo linux-5.12.3 > /tmp/linux-5.12.3/NAME`. In case of conflicting files, the more recently-installed package will 'win.' When calling yalpack scripts that take the package name as the input, the proper version information will also be required: `pkgup linux-5.12.2 linux-5.12.3`.

*Packages without DESTDIR*

As of LFS 11.0, some packages in the book cannot use DESTDIR with `make install`. To install or upgrade `bzip2`, `sysvinit` or `sysklogd` with yalpack, see the man page for `pkgmake`.

**Libraries**

Aside from `linux-vdso` and `ld-linux`, the yalpack package installation and/or upgrade process involves the following libraries:

* `libacl.so.1`	(`acl`)
* `libattr.so.1`	(`attr`)
* `libc.so.6` 	(`glibc`)
* `libm.so.6`	(`glibc`)

*Upgrading glibc and init*

As the Linux From Scratch documentation indicates, `glibc` upgrades generally entail a full system rebuild. Although yalpack-0.1.4+ has been tested to upgrade `glibc`, this type of upgrade should be treated with care and is not necessarily advisable. *glibc downgrades (especially downgrades to versions older than the one used to build LFS) are unsupported altogether.*

In order to avoid unmounting problems at the next halt or reboot, `pkgup` reloads `init` if `glibc`, `sysvinit` or `systemd` upgrades are detected.

If upgrades to any of these packages are desired, please ensure that yalpack's version is **at least 0.1.4**. `systemd` upgrades were tested for the first time in **yalpack-0.2.0**.

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

	`/var/yalpack/packages`	(`pkgmake`)
		Holds package tarballs; once a package has been installed, the package tarball need not be retained.
	`/var/yalpack/pkgdata`	(`pkginst` or yalpack's `install.sh` script)
		Holds reference information about installed packages.
	`/var/yalpack/BIN-DEPS`	(`liblist`; called by `pkginst`)
		Holds information about the dynamic libraries used by those binaries checked by `liblist`.

The yalpack main data directory, backup locations, build destination and sbin directory can all be changed by editing `/etc/yalpack.conf`. See "Customization" for details and instructions. 

Please note that the `/var/yalpack` directory and the backup locations will not be removed by running `pkgremove yalpack`.

**Package tree backups**

yalpack relies on the contents of `/var/yalpack` to operate. If this directory is lost (in whole or in part), using yalpack scripts could become inconvenient or impossible. For this reason, yalpack retains parallel package tree directories (main copy at `/var/yalpack/pkgdata/TREES`) in the following locations:

* `/var/log/yalpack`
* `/root/.yalpack-backup`

If either of these directories (or the `TREES` directory itself) is intact, and yalpack is installed, `/usr/share/yalpack/restore-yalpack` can be used to regenerate the rest of the `/var/yalpack` directory. Any lost package tarballs are unrecoverable, so it would still be best not to delete `/var/yalpack` if possible.

`install.sh` will set up the backups for new installations and any upgrades from versions of yalpack without backup capabilities.
