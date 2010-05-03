# integrator between neurospaces_build and the documentation system.

SUBDIRS = perl

dist_bin_SCRIPTS = \
	bin/userdocs-build \
	bin/userdocs-check \
	bin/userdocs-sync \
	bin/userdocs-tag-filter \
	bin/userdocs-tag-replace-items \
	bin/userdocs-version \
	bin/userdocs-create

dist_noinst_SCRIPTS = \
	MonotoneSetup.txt \
	NewDocument/NewDocument.tex \
	README/README.tex \
	autogen/autogen.tex \
	backward-compatibility/backward-compatibility.tex \
	build-debian/build-debian.tex \
	cable-theory-digression/cable-theory-digression.tex \
	common-suffixes/common-suffixes.tex \
	compneurosci-1/compneurosci-1.tex \
	bog-ch2/bog-ch2.pdf \
	bog-ch3/bog-ch3.pdf \
	bog-ch4/bog-ch4.pdf \
	bog-ch5/bog-ch5.pdf \
	bog-ch6/bog-ch6.pdf \
	compneurosci-1/compneurosci-1.tex \
	compneurosci-2/compneurosci-2.tex \
	contents-level1/contents-level1.tex \
	contents-level2/contents-level2.tex \
	contents-level3/contents-level3.tex \
	contents-level4/contents-level4.tex \
	contents-level5/contents-level5.tex \
	contents-level6/contents-level6.tex \
	contents-level7/contents-level7.tex \
	cxref/cxref.tex \
	developer-intro/developer-intro.tex \
	developer-package/developer-package.tex \
	developer-repository/developer-repository.tex \
	do-nothing/do-nothing.tex \
	document-create/document-create.tex \
	document-notation/document-notation.tex \
	documentation-homepage/documentation-homepage.tex \
	documentation-overview/documentation-overview.tex \
	g2-gap-junction/g2-gap-junction.tex \
	genesis-dependencies/genesis-dependencies.tex \
	genesis-installation/genesis-installation.tex \
	genesis-overview/genesis-overview.tex \
	genesis-system/genesis-system.tex \
	gshell/gshell.tex \
	gui/gui.tex \
	gtube/gtube.tex \
	heccer/heccer.tex \
	hh-model-details/hh-model-details.tex \
	install-procedure/install-procedure.tex
	installation-debian/installation-debian.tex
	installation-developer/installation-developer.tex
	installation-fedora10/installation-fedora10.tex
	installation-osx/installation-osx.tex
	installation-ubuntu-lennysid/installation-ubuntu-lennysid.tex
	installation-user/installation-user.tex	developer-package/developer-package.tex \
	mercurial-testing/mercurial-testing.tex \
	model-container/model-container.tex \
	ndf-file-format/ndf-file-format.tex \
	neurospaces-tester/neurospaces-tester.tex \
	neurospaces-cron/neurospaces-cron.tex \
	pclamp/pclamp.tex \
	project-browser-screenshots/project-browser-screenshots.tex \
	project-browser/project-browser.tex \
	project-todo/project-todo.tex \
	publication/publication.tex \
	purkinje-cell-model/purkinje-cell-model.tex \
	release-expand/release-expand.tex \
	release-expand.config \
	release-notes/release-notes.tex \
	release-procedure/release-procedure.tex \
	reserved-words/reserved-words.tex \
	rtxi-injector-validation/rtxi-injector-validation.tex \
	shell-tokens/shell-tokens.tex \
	ssp/ssp.tex \
	studio/studio.tex \
	tested-distributions/tested-distributions.tex
	tester-configuration/tester-configuration.tex
	tests-g2-backward-compatibility/tests-g2-backward-compatibility.tex
	tests-gshell/tests-gshell.tex \
	tests-heccer/tests-heccer.tex \
	tests-model-container/tests-model-container.tex \
	tests-ssp/tests-ssp.tex \
	tests-studio/tests-studio.tex \
	tests.config \
	tutorial-jaeger/tutorial-jaeger.pdf \
	tutorial1/tutorial1.tex \
	tutorial2/tutorial2.tex \
	unix-linux/unix-linux.tex \
	version-control/version-control.tex \
	workflow-developer/workflow-developer.tex \
	workflow-documentation/workflow-documentation.tex \
	workflow-intro/workflow-intro.tex \
	workflow-user-query/workflow-user-query.tex \
	workflow-user/workflow-user.tex

#cable-theory-disgression/cable-theory-disgression.tex

RELEASE_MAJOR=`release-extract --major`
RELEASE_MINOR=`release-extract --minor`
RELEASE_MICRO=`release-extract --micro`

show-release-labels:
	echo "Release information (major-minor-micro): $(RELEASE_MAJOR)-$(RELEASE_MINOR)-$(RELEASE_MICRO)"

dist-keywords:
	release-expand userdocs $(RELEASE_MAJOR) $(RELEASE_MINOR) $(RELEASE_MICRO) $(RELEASE_MAJOR)-$(RELEASE_MINOR) hugo.cornelis@gmail.com --verbose
#	release-expand neurospacesread des 10 0 des-10 hugo.cornelis@gmail.com --verbose

clean-local: website-clean
	find $(srcdir) -type d -exec chmod -R u+w \{\} \;
	$(RM) -fr `find $(srcdir) -name _Inline`
	$(RM) -rf */output/*
	$(RM) -f */*.log
#	$(RM) -fr $(srcdir)/hierarchy/output
#	$(RM) -rf $(top_srcdir)/docs/html

TESTS = /usr/local/bin/neurospaces_harness

test: check

html-upload-prepare:
	( cd tests && ./tests_2_html --introduction introduction.html )
	$(srcdir)/install-sh -d html
	$(srcdir)/install-sh -d html/htdocs
	$(srcdir)/install-sh -d html/htdocs/neurospaces_project
	$(srcdir)/install-sh -d html/htdocs/neurospaces_project/userdocs
	$(srcdir)/install-sh -d html/htdocs/neurospaces_project/userdocs/html_source
	tar cfh - tests/html | ( cd html/htdocs/neurospaces_project/userdocs && tar vxf - )

html-upload: html-upload-prepare
	scp -pr html/htdocs/* hcornelis,neurospaces@web.sourceforge.net:/home/groups/n/ne/neurospaces/htdocs/

website-clean:
	$(RM) -fr html/htdocs/neurospaces_project/userdocs/

website-prepare:
	userdocs-build --tags published

website-prepare-local:
	userdocs-build --tags local --tags published

website-upload: website-clean website-prepare html-upload

webcheck:
	rm -rf html/htdocs/neurospaces_project/userdocs/webcheck
	mkdir html/htdocs/neurospaces_project/userdocs/webcheck
	webcheck -o html/htdocs/neurospaces_project/userdocs/webcheck html/htdocs/neurospaces_project/userdocs --redirects=10

docs-level1:

docs-level2:

docs-level3: html-upload-prepare
	echo "Converted the regression tests to HTML"

docs-level4:

docs-level5:

docs-level6:

docs-level7:

docs: docs-level1 docs-level2 docs-level3 docs-level4 docs-level5 docs-level6 docs-level7

TMP_DIR = tmp

# Create a deb package
pkg-deb: dist
	nspkg-deb $(TMP_DIR) $(PACKAGE) $(VERSION)
