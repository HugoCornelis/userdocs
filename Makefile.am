# integrator between neurospaces_build and the documentation system.

SUBDIRS =

dist_bin_SCRIPTS = \
	bin/userdocs-build \
	bin/userdocs-sync \
	bin/userdocs-tag-filter \
	bin/userdocs-version

dist_noinst_SCRIPTS = \
	MonotoneSetup.txt \
	NewDocument/NewDocument.tex \
	README/README.tex \
	backward-compatibility/backward-compatibility.tex \
	bog-ch2/bog-ch2.pdf \
	bog-ch3/bog-ch3.pdf \
	bog-ch4/bog-ch4.pdf \
	bog-ch5/bog-ch5.pdf \
	bog-ch6/bog-ch6.pdf \
	cable-theory/G3-Digression-CableTheory-V1.tex \
	contents-level1/contents-level1.tex \
	contents-level2/contents-level2.tex \
	contents-level3/contents-level3.tex \
	contents-level4/contents-level4.tex \
	contents-level5/contents-level5.tex \
	contents-level6/contents-level6.tex \
	contents-level7/contents-level7.tex \
	document-create/document-create.tex \
	document-homepage/document-homepage.tex \
	document-model-container/document-model-container.tex \
	document-overview/document-overview.tex \
	document-project-browser-screenshots/document-project-browser-screenshots.tex \
	document-project-browser/document-project-browser.tex \
	document-publication/document-publication.tex \
	document-purkinje-cell-model/document-purkinje-cell-model.tex \
	document-studio/document-studio.tex \
	document-versionctrl/document-versionctrl.tex \
	genesis-overview/genesis-overview.tex \
	hh-model-details/hh-model-details.tex \
	introduction-compneurosci-1/introduction-compneurosci-1.tex \
	introduction-compneurosci-2/introduction-compneurosci-2.tex \
	introduction-installation-developer/introduction-installation-developer.tex \
	introduction-installation-user/introduction-installation-user.tex \
	introduction-shell-tokens/introduction-shell-tokens.tex \
	introduction-unix-linux/introduction-unix-linux.tex \
	release-expand.config \
	tests.config \
	tutorial-jaeger/tutorial-jaeger.pdf \
	tutorial1/tutorial1.tex \
	tutorial2/tutorial2.tex

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
	userdocs-build --tags level1 --tags level2 --tags level3 --tags level4 --tags level5 --tags level6 --tags level7 --verbose

website-upload: website-clean website-prepare html-upload

