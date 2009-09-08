dnl
dnl G3 documentation.
dnl

# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)

# $Format: "AC_INIT(${package}, ${label}, ${email})"$
AC_INIT(userdocs, userdocs-5, hugo.cornelis@gmail.com)


AC_CONFIG_SRCDIR([configure.ac])
dnl AC_CONFIG_HEADER([heccer/config.h])

dnl dnl all subdirs

dnl AC_CONFIG_SUBDIRS(tests/code glue)

# $Format: "AM_INIT_AUTOMAKE(${package}, ${label})"$
AM_INIT_AUTOMAKE(userdocs, userdocs-5)


# Checks for programs.

# Checks for options

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

# determine the test library to install

dnl USERDOCS_FILES=`find . -name "*.tex" && find . -name "*.pdf" && find . -name "*.txt" | perl -pe 's/\n/ /g' `
dnl AC_SUBST(USERDOCS_FILES)

# determine the test library to install

TEST_SPECIFICATION_FILES=`/bin/echo -n "tests/introduction.html " && find tests/specifications -name "*.t" && find tests/specifications/strings -name "*.txt" && find tests/data -name "*.yml" | perl -pe 's/\n/ /g' `
AC_SUBST(TEST_SPECIFICATION_FILES)


AC_CONFIG_FILES([Makefile])

AC_OUTPUT

