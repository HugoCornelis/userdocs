###
### RPM spec file of the Neurospaces developer package
###
Summary: Neurospaces developer utilities
Name: neurospacesdeveloper
Version: alpha.1
Release: 1
License: GPL
Group: Science
URL: http://www.neurospaces.org/
Source0: %{name}-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
Vendor: Hugo Cornelis <hugo.cornelis@gmail.com>
Packager: Hugo Cornelis <hugo.cornelis@gmail.com>
BuildArch: i386

%description
The Neurospaces developer package contains essential tools for Neurospaces development. 
 The Neurospaces project develops software components of neuronal
 simulator that integrate in a just-in-time manner for the
 exploration, simulation and validation of accurate neuronal models.
 Neurospaces spans the range from single molecules to subcellular
 networks, over single cells to neuronal networks.  Neurospaces is
 backwards-compatible with the GENESIS simulator, integrates with
 Python and Perl, separates models from experimental protocols, and
 reads model definitions from declarative specifications in a variety
 of formats.
 This package contains utilities requires for Neurospaces development.

%prep
%setup -n %{name}-%{version}

%build
./configure --prefix=/usr/local
make

%install
make DESTDIR=%{buildroot} install

%clean
rm -rf %{buildroot}


%files
[03:08] (1,1) 0 $ make install
make[1]: Entering directory `/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0'
make[2]: Entering directory `/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0'
test -z "/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin" || mkdir -p -- "/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin"
 /usr/bin/install -c 'bin/mcad2doxy' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/mcad2doxy'
 /usr/bin/install -c 'bin/neurospaces_build' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_build'
 /usr/bin/install -c 'bin/neurospaces_check' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_check'
 /usr/bin/install -c 'bin/neurospaces_clean' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_clean'
 /usr/bin/install -c 'bin/neurospaces_configure' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_configure'
 /usr/bin/install -c 'bin/neurospaces_create_directories' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_create_directories'
 /usr/bin/install -c 'bin/neurospaces_cron' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_cron'
 /usr/bin/install -c 'bin/neurospaces_docs' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_docs'
 /usr/bin/install -c 'bin/neurospaces_install' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_install'
 /usr/bin/install -c 'bin/neurospaces_kill_servers' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_kill_servers'
 /usr/bin/install -c 'bin/neurospaces_packages' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_packages'
 /usr/bin/install -c 'bin/neurospaces_pull' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_pull'
 /usr/bin/install -c 'bin/neurospaces_push' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_push'
 /usr/bin/install -c 'bin/neurospaces_serve' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_serve'
 /usr/bin/install -c 'bin/neurospaces_status' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_status'
 /usr/bin/install -c 'bin/neurospaces_sync' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_sync'
 /usr/bin/install -c 'bin/neurospaces_uninstall' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_uninstall'
 /usr/bin/install -c 'bin/neurospaces_update' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_update'
 /usr/bin/install -c 'bin/neurospaces_versions' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_versions'
 /usr/bin/install -c 'bin/neurospaces_website_prepare' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/neurospaces_website_prepare'
 /usr/bin/install -c 'bin/nstest_query' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/nstest_query'
 /usr/bin/install -c 'bin/release-expand' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/release-expand'
 /usr/bin/install -c 'bin/release-extract' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/bin/release-extract'
test -z "/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer" || mkdir -p -- "/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer"
 /local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/install-sh -c -m 644 'tests/introduction.html' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer/tests/introduction.html'
 /local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/install-sh -c -m 644 'tests/specifications/global.t' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer/tests/specifications/global.t'
 /local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/install-sh -c -m 644 'tests/specifications/downloads.t' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer/tests/specifications/downloads.t'
 /local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/install-sh -c -m 644 'tests/specifications/developer.t' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer/tests/specifications/developer.t'
 /local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/install-sh -c -m 644 'tests/specifications/strings/neurospaces_build--no-compile--no-configure--no-install--regex-installer--dry-run--developer--verbose--verbose--verbose.txt' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer/tests/specifications/strings/neurospaces_build--no-compile--no-configure--no-install--regex-installer--dry-run--developer--verbose--verbose--verbose.txt'
 /local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/install-sh -c -m 644 'tests/specifications/strings/neurospaces_build--tag-build-10--no-compile--no-configure--no-install--regex-installer--dry-run--developer--verbose--verbose--verbose.txt' '/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0/installed/neurospaces/installer/tests/specifications/strings/neurospaces_build--tag-build-10--no-compile--no-configure--no-install--regex-installer--dry-run--developer--verbose--verbose--verbose.txt'
make[2]: Leaving directory `/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0'
make[1]: Leaving directory `/local_home/local_home/hugo/neurospaces_project/installer/source/snapshots/0'
%defattr(-,root,root,-)
%doc


%changelog
* Sat Aug  8 2009 Hugo Cornelis <hugo.cornelis@gmail.com> - 
- Initial build.

