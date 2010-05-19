dnl
dnl G3 documentation.
dnl

# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)

# $Format: "AC_INIT(${package}, ${label}, ${email})"$
AC_INIT(userdocs, userdocs.6, hugo.cornelis@gmail.com)


AC_CONFIG_SRCDIR([configure.ac])
dnl AC_CONFIG_HEADER([heccer/config.h])

dnl dnl all subdirs

dnl AC_CONFIG_SUBDIRS(tests/code glue)

# $Format: "AM_INIT_AUTOMAKE(${package}, ${label})"$
AM_INIT_AUTOMAKE(userdocs, userdocs.6)


# Checks for programs.
AC_CHECK_PROGS(LATEX,latex,[
   echo "Error! latex is not installed!."
   exit -1
])
AC_CHECK_PROGS(MAKEINDEX, makeindex,[
   echo "Error! makeindex is not installed."
   exit -1
])
AC_CHECK_PROGS(BIBTEX, bibtex,[
   echo "Error! bibtex is not installed."
   exit -1
])
AC_CHECK_PROGS(DVIPS, dvips,[
   echo "Error! dvips is not installed."
   exit -1
])
AC_CHECK_PROGS(HTLATEX, htlatex,[
   echo "Error! htlatex is not installed."
   exit -1
])


# Checks for options

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

# determine the test library to install

dnl USERDOCS_FILES=`find . -name "*.tex" && find . -name "*.pdf" && find . -name "*.txt" | perl -pe 's/\n/ /g' `
dnl AC_SUBST(USERDOCS_FILES)

PERL_MODULES=`(cd perl && find . -name "*.pm" | perl -pe 's/\n/ /g')`
AC_SUBST(PERL_MODULES)

PERL_DATA=`(cd perl && find . -name "numbers-7x11.txt" | perl -pe 's/\n/ /g')`
AC_SUBST(PERL_DATA)

# determine the test library to install

TEST_SPECIFICATION_FILES=`/bin/echo -n "tests/introduction.html " && find tests/specifications -name "*.t" && find tests/specifications/strings -name "*.txt" && find tests/data -name "*.yml" | perl -pe 's/\n/ /g' `
AC_SUBST(TEST_SPECIFICATION_FILES)


AC_CONFIG_FILES([Makefile
		 perl/Makefile])

AC_OUTPUT

