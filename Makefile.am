# integrator between neurospaces_build and the documentation system.

SUBDIRS =

dist_bin_SCRIPTS = \
	bin/userdocs-sync \
	bin/userdocs-version

RELEASE_MAJOR=`release-extract --major`
RELEASE_MINOR=`release-extract --minor`
RELEASE_MICRO=`release-extract --micro`

show-release-labels:
	echo "Release information (major-minor-micro): $(RELEASE_MAJOR)-$(RELEASE_MINOR)-$(RELEASE_MICRO)"

dist-keywords:
	release-expand userdocs $(RELEASE_MAJOR) $(RELEASE_MINOR) $(RELEASE_MICRO) $(RELEASE_MAJOR)-$(RELEASE_MINOR) hugo.cornelis@gmail.com --verbose
#	release-expand neurospacesread des 10 0 des-10 hugo.cornelis@gmail.com --verbose

clean-local:
	find $(srcdir) -type d -exec chmod -R u+w \{\} \;
	$(RM) -fr `find $(srcdir) -name _Inline`
#	$(RM) -fr $(srcdir)/hierarchy/output
#	$(RM) -rf $(top_srcdir)/docs/html

TESTS = $(srcdir)/tests/neurospaces_harness

test: check

html-upload-prepare:
	( cd tests && ./tests_2_html --introduction introduction.html )
	$(RM) -fr html/htdocs/neurospaces_project/userdocs/
	$(srcdir)/install-sh -d html
	$(srcdir)/install-sh -d html/htdocs
	$(srcdir)/install-sh -d html/htdocs/neurospaces_project
	$(srcdir)/install-sh -d html/htdocs/neurospaces_project/userdocs
	$(srcdir)/install-sh -d html/htdocs/neurospaces_project/userdocs/html_source
	tar cfh - tests/html | ( cd html/htdocs/neurospaces_project/userdocs && tar vxf - )

html-upload: html-upload-prepare
	scp -pr html/htdocs/* hcornelis,neurospaces@web.sourceforge.net:/home/groups/n/ne/neurospaces/htdocs/

