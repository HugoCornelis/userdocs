dnl
dnl G3 documentation.
dnl

# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)

# $Format: "AC_INIT(${package}, ${major}.${minor}.${micro}-${label}, ${email})"$
AC_INIT(userdocs, 0.0.0-alpha, hugo.cornelis@gmail.com)


AC_CONFIG_SRCDIR([configure.ac])
dnl AC_CONFIG_HEADER([heccer/config.h])

dnl dnl all subdirs

dnl AC_CONFIG_SUBDIRS(tests/code glue)

# $Format: "AM_INIT_AUTOMAKE(${package}, ${major}.${minor}.${micro}-${label})"$
AM_INIT_AUTOMAKE(userdocs, 0.0.0-alpha)


# see https://metacpan.org/source/ASPIERS/Stow-v2.1.2/configure.ac

dnl Check for perl on our system.
dnl Call to AC_SUBST(PERL) is implicit
AC_PATH_PROGS([PERL], [perl] [perl5], [false])
if test "x$PERL" = xfalse
then
  AC_MSG_ERROR([Perl not found; check your \$PATH.])
fi
 
# N.B. ${var#pattern} will not work with some shells, such as
# Solaris 10's /bin/sh :-(
#
#   http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
#
#   eval `$PERL -V:siteprefix -V:installsitelib`
#   pmdir_relative_path="${installsitelib#$siteprefix/}"
#
# This will work:
#
#   pmdir_relative_path=`echo "${installsitelib}" | sed -e "s!^$siteprefix/!!"`
#
# but this is cleaner:
pmdir_relative_path=`\
  $PERL -MConfig \
        -wle '($_ = $Config{installsitelib})
              =~ s!^\Q$Config{siteprefix}/!!; \
              print'`
 
AC_ARG_WITH(
    [pmdir],
    AS_HELP_STRING(
      [--with-pmdir=DIR],
      [Install Perl modules in DIR]),
    [PMDIR=${withval}],
    [PMDIR='${prefix}'/"$pmdir_relative_path"])
AC_CONFIG_COMMANDS_POST([[
  eval pmdir="$PMDIR"
  cat <<EOF
 
# Perl modules will be installed to $PMDIR
EOF
  if [ "$pmdir" != "$PMDIR" ]; then
    cat <<EOF
# which will expand to
#
#   $pmdir
#
# unless you override the value of prefix at make-time.
EOF
    echo
  fi
]])
AC_SUBST([PMDIR])


AC_MSG_CHECKING(whether we build universal binaries.)
AC_ARG_WITH(universal,
[AS_HELP_STRING([--with-universal],
              [Build universal binaries on Mac OS X.])],
[ case "$val" in
  no)

    AC_MSG_RESULT(no)
    OSX_UNIVERSAL="no"

    ;;
  *)

    AC_MSG_RESULT(yes)
    OSX_UNIVERSAL="yes"

    ;;
  esac ],
  AC_MSG_RESULT(no)
  OSX_UNIVERSAL="no"
)
AC_SUBST(OSX_UNIVERSAL)


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

