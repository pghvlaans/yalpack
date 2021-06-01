**yalpack-0.1.3**

This is yalpack (Yet Another Lfs PACKage manager), a basic set of package management tools for LFS/BLFS-based systems. yalpack was inspired by pkgtools from Slackware, although there are differences in functionality and package structure.

yalpack is intended to make managing upgrades and trying new software easier on a Linux From Scratch installation: 
* Install compiled software as packages
* Easily remove unwanted packages (no need to worry about "make uninstall")
* Simple(r) pacakge upgrades
* Handle and log ".new" files automatically
* List installed packages and versions
* Gather, store and check information about dynamic library usage
* Search for which package provided which file/directory/symlink

yalpack requires only a POSIX-compliant shell, util-linux, findutils, grep and tar to operate. gzip is needed for installation. Dependency resolution is not provided, and packages are still meant to be built from source. pkgcheck, libcheck, liblist and libprecise are intended as aids to dependency management, however.

Although the envisioned use case of yalpack is to add, upgrade and remove packages from on top of a "core" LFS system, it could also be used to manage every package once the temporary toolchain has been completed. This has been tested successfully for LFS 10.1 (SysVinit) (x86_64, Linux 5.12.3, gcc 10.3).

For installation and upgrades of yalpack, see INSTALL or run `make all` for details.

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
	* pkgfind: Use search terms or exact file paths to determine which package provided matching files, directories and symlinks

When building from source with the objective of installing a yalpack package, please remember the following considerations:

* At the install stage, use `DESTDIR=/tmp/[NAME]-[VERSION]/dest`, where NAME and VERSION correspond to the correct package name and version, separated by a hyphen. See `sample-dewit.sh` for an idea of how to wrap build instructions in a script to automate this.
	
* Before running pkgmake, supply a file at `/tmp/[NAME]-[VERSION]/NAME` containing the package's name, e.g. `echo frotz > /tmp/frotz-2.52/NAME`
	
* pkginst repairs absolute symlinks such that they are relative to the root directory once installed. LFS/BLFS instructions to make absolute symlinks should be done using `/tmp/[NAME]-[VERSION]/dest/` rather than `/`.

* All installed files in /etc and /home are marked as .new by pkgmake. If other .new files are needed, they should be renamed manually prior to making the package.

* Any executable file at `/tmp/[NAME]-[VERSION]/install.sh` will be executed by pkginst after all new files, directories and symlinks have been created. Bear in mind that moving files and creating symlinks with install.sh will result in said files and symlinks being unaffected by pkgremove (and possibly pkgup).

* At times, it may be desirable to keep more than one version of a package installed on the system (e.g. the kernel and kernel modules). In such cases, the NAME file should be a string with the version information included: `echo linux-5.12.3 > /tmp/linux-5.12.3/NAME`. In case of conflicting files, the more recently-installed package will 'win.' When calling yalpack scripts that take the package name as the input, the proper version information will also be required: `pkgup linux-5.12.2 linux-5.12.3`.

**Library upgrades**

Aside from linux-vdso and ld-linux, the yalpack package installation and/or upgrade process involves the following libraries:

* libacl.so.1	(acl)
* libattr.so.1	(attr)
* libc.so.6 	(glibc)
* libm.so.6	(glibc) (library installations and upgrades only)

*Testing Results*

* attr: package upgrade successful (2.4.48 > 2.5.1)
* acl: package upgrade successful (2.2.53 > 2.3.1)

*Upgrading glibc*

As the Linux From Scratch documentation indicates, glibc upgrades generally entail a full system rebuild. Except in the specific case of replacing the temporary toolchain version of glibc, yalpack upgrades of glibc are currently **untested** and would most likely fail. 

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
		Holds package tarballs; tarballs for all currently-installed
		packages should be retained.
	/var/yalpack/pkgdata	(pkginst)
		Holds reference information about installed packages.
	/var/yalpack/BIN-DEPS	(liblist; called by pkginst)
		Holds information about the dynamic libraries used by those
		binaries checked by liblist.

Any and all of the target directories (including /tmp for the original "install" destination) can be changed by editing the shell scripts in `/sbin` or 
`/usr/bin`. See "Customization" for details and ensure that any edits are consistent.
