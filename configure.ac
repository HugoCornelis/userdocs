dnl
dnl G3 documentation.
dnl

# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)

# $Format: "AC_INIT(${package}, ${major}.${minor}.${micro}-${label}, ${email})"$
AC_INIT(userdocs, 0.0.0-alpha, hugo.cornelis@gmail.com)

dnl Obtain operating system information.
AC_CANONICAL_TARGET

AC_CONFIG_SRCDIR([configure.ac])
dnl AC_CONFIG_HEADER([heccer/config.h])

dnl dnl all subdirs

dnl AC_CONFIG_SUBDIRS(tests/code glue)

# $Format: "AM_INIT_AUTOMAKE(${package}, ${major}.${minor}.${micro}-${label})"$
AM_INIT_AUTOMAKE(userdocs, 0.0.0-alpha)


# see https://metacpan.org/source/ASPIERS/Stow-v2.1.2/configure.ac

dnl Check for perl on our system.
dnl Call to AC_SUBST(PERL) is implicit
dnl AC_PATH_PROGS([PERL], [perl] [perl5], [false])
dnl if test "x$PERL" = xfalse
dnl then
dnl   AC_MSG_ERROR([Perl not found; check your \$PATH.])
dnl fi
 
dnl # N.B. ${var#pattern} will not work with some shells, such as
dnl # Solaris 10's /bin/sh :-(
dnl #
dnl #   http://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
dnl #
dnl #   eval `$PERL -V:siteprefix -V:installsitelib`
dnl #   pmdir_relative_path="${installsitelib#$siteprefix/}"
dnl #
dnl # This will work:
dnl #
dnl #   pmdir_relative_path=`echo "${installsitelib}" | sed -e "s!^$siteprefix/!!"`
dnl #
dnl # but this is cleaner:
dnl pmdir_relative_path=`\
dnl   $PERL -MConfig \
dnl         -wle '($_ = $Config{installsitelib})
dnl               =~ s!^\Q$Config{siteprefix}/!!; \
dnl               print'`
 
dnl AC_ARG_WITH(
dnl     [pmdir],
dnl     AS_HELP_STRING(
dnl       [--with-pmdir=DIR],
dnl       [Install Perl modules in DIR]),
dnl     [PMDIR=${withval}],
dnl     [PMDIR='${prefix}'/"$pmdir_relative_path"])
dnl AC_CONFIG_COMMANDS_POST([[
dnl   eval pmdir="$PMDIR"
dnl   cat <<EOF
 
dnl # Perl modules will be installed to $PMDIR
dnl EOF
dnl   if [ "$pmdir" != "$PMDIR" ]; then
dnl     cat <<EOF
dnl # which will expand to
dnl #
dnl #   $pmdir
dnl #
dnl # unless you override the value of prefix at make-time.
dnl EOF
dnl     echo
dnl   fi
dnl ]])
dnl AC_SUBST([PMDIR])


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


AC_MSG_CHECKING([OS specifics...])
AC_MSG_RESULT([Host is running $host_os.])
dnl Here we'll select which version of perl to set up for
dnl {{{
case "$host_os" in

  darwin*)
    dnl On the MAC we will only look for perl in the standard location for the Apple
    dnl native perl. 
    AC_CHECK_PROG(PERL, perl, NULL, [/usr/bin/perl],[/usr/local/bin/perl /opt/local/bin/perl])
    AC_SUBST(PERL)

    AC_MSG_CHECKING([Checking the perl installation])
    case $PERL in
      NULL*)
        echo ""
        echo "Error, the standard version of perl for Mac OSX is not found."
        echo "Non standard versions of perl are known to cause problems."
        AC_ERROR([Perl for Mac OSX is not found.])
        ;;
      *)
        AC_MSG_RESULT([ $PERL ])
        ;;
    esac


    #-- Here we determine the install path for perl modules --
    AC_MSG_CHECKING([Checking the perl module installation path])	
    pmdir_relative_path=`\
      $PERL -MConfig \
        -wle '($_ = $Config{installsitelib}) \
              =~ s!^\Q$Config{siteprefix}/!!; \
              print'`
 
    AC_ARG_WITH(
      [pmdir],
    AS_HELP_STRING(
      [--with-pmdir=DIR],
      [Install Perl modules in DIR]),
      [PMDIR=${withval}],
      [PMDIR="$pmdir_relative_path"])

    AC_SUBST([PMDIR])
    AC_MSG_RESULT([ $PMDIR ])
    # --- End perl module directory selection --------------
  ;;

  *)

    dnl Check for some needed programs.
    AC_CHECK_PROGS(PERL, perl5 perl)
    AC_SUBST(PERL)

    #-- Here we determine the install path for perl modules --
    AC_MSG_CHECKING([Checking the perl module installation path])	

dnl Commenting out the relative path call
dnl     pmdir_relative_path=`\
dnl       $PERL -MConfig \
dnl         -wle '($_ = $Config{installsitelib})
dnl               =~ s!^\Q$Config{siteprefix}/!!; \
dnl               print'`

    pmdir_path=`\
      $PERL -MConfig \
        -wle '($_ = $Config{installsitelib});print'`
 
    AC_ARG_WITH(
      [pmdir],
    AS_HELP_STRING(
      [--with-pmdir=DIR],
      [Install Perl modules in DIR]),
      [PMDIR=${withval}],
      [PMDIR="$pmdir_path"])

    AC_SUBST([PMDIR])
    AC_MSG_RESULT([ $PMDIR ])
    # --- End perl module directory selection --------------

  ;;

esac




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

