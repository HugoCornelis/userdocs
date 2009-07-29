# integrator between neurospaces_build and the documentation system.

SUBDIRS =

dist_bin_SCRIPTS = \
	bin/userdocs-build \
	bin/userdocs-copy \
	bin/userdocs-sync \
	bin/userdocs-tag-filter \
	bin/userdocs-tag-replace-items \
	bin/userdocs-version

dist_noinst_SCRIPTS = \
	MonotoneSetup.txt \
	NewDocument/NewDocument.tex \
	README/README.tex \
	autogen/autogen.tex \
	backward-compatibility/backward-compatibility.tex \
	bog-ch2/bog-ch2.pdf \
	bog-ch3/bog-ch3.pdf \
	bog-ch4/bog-ch4.pdf \
	bog-ch5/bog-ch5.pdf \
	bog-ch6/bog-ch6.pdf \
	#cable-theory-disgression/cable-theory-disgression.tex \
	compneurosci-1/compneurosci-1.tex \
	compneurosci-2/compneurosci-2.tex \
	contents-level1/contents-level1.tex \
	contents-level2/contents-level2.tex \
	contents-level3/contents-level3.tex \
	contents-level4/contents-level4.tex \
	contents-level5/contents-level5.tex \
	contents-level6/contents-level6.tex \
	contents-level7/contents-level7.tex \
	developers-intro/developers-intro.tex \
	document-create/document-create.tex \
	document-homepage/document-homepage.tex \
	document-overview/document-overview.tex \
	genesis-overview/genesis-overview.tex \
	gshell/gshell.tex \
	gui/gui.tex \
	heccer/heccer.tex \
	hh-model-details/hh-model-details.tex \
	installation-developer/installation-developer.tex \
	installation-user/installation-user.tex \
	installer-package/installer-package.tex \
	model-container/model-container.tex \
	ndf-file-format/ndf-file-format.tex \
	neurospaces-tester/neurospaces-tester.tex \
	notation/notation.tex \
	pclamp/pclamp.tex \
	prerequisite/prerequisite.tex \
	project-browser/project-browser.tex \
	project-browser-screenshots/project-browser-screenshots.tex \
	publication/publication.tex \
	purkinje-cell-model/purkinje-cell-model.tex \
	release-expand/release-expand.tex \
	release-expand.config \
	reserved-words/reserved-words.tex \
	rtxi-injector-validation/rtxi-injector-validation.tex \
	shell-tokens/shell-tokens.tex \
	ssp/ssp.tex \
	studio/studio.tex \
	tests.config \
	tutorial-jaeger/tutorial-jaeger.pdf \
	tutorial1/tutorial1.tex \
	tutorial2/tutorial2.tex \
	unix-linux/unix-linux.tex \
	version-control/version-control.tex \
	work-flow/work-flow.tex

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
	$(RM) -rf */output/*
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
	userdocs-copy --tags level1 --tags level2 --tags level3 --tags level4 --tags level5 --tags level6 --tags level7 --verbose
	userdocs-tag-replace-items level1 contents-level1/contents-level1.tex --verbose
	userdocs-tag-replace-items level2 contents-level2/contents-level2.tex --verbose
	userdocs-tag-replace-items level3 contents-level3/contents-level3.tex --verbose
	userdocs-tag-replace-items level4 contents-level4/contents-level4.tex --verbose
	userdocs-tag-replace-items level5 contents-level5/contents-level5.tex --verbose
	userdocs-tag-replace-items level6 contents-level6/contents-level6.tex --verbose
	userdocs-tag-replace-items level7 contents-level7/contents-level7.tex --verbose
	userdocs-build --tags level1 --tags level2 --tags level3 --tags level4 --tags level5 --tags level6 --tags level7 --verbose

website-upload: website-clean website-prepare html-upload

webcheck:
	rm -rf html/htdocs/neurospaces_project/userdocs/webcheck
	mkdir html/htdocs/neurospaces_project/userdocs/webcheck
	webcheck -o html/htdocs/neurospaces_project/userdocs/webcheck html/htdocs/neurospaces_project/userdocs

