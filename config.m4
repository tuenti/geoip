dnl $Id$
dnl config.m4 for extension geoip

dnl Base file contributed by Jonathan Whiteman of cyberflowsolutions.com

PHP_ARG_WITH(geoip, for geoip support,
dnl Make sure that the comment is aligned:
[  --with-geoip             Include GeoIP support])

if test "$PHP_GEOIP" != "no"; then

  # --with-geoip -> check with-path
  SEARCH_PATH="/usr/local /usr /sw /opt/local"
  SEARCH_FOR="/include/GeoIP.h"
  if test -r $PHP_GEOIP/$SEARCH_FOR; then
    GEOIP_DIR=$PHP_GEOIP
  else # search default path list
    AC_MSG_CHECKING([for geoip files in default path])
    for i in $SEARCH_PATH ; do
      if test -r $i/$SEARCH_FOR; then
        GEOIP_DIR=$i
        AC_MSG_RESULT([found in $i])
      fi
    done
  fi

  if test -z "$GEOIP_DIR"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Please reinstall the geoip distribution])
  fi

  # --with-geoip -> add include path
  PHP_ADD_INCLUDE($GEOIP_DIR/include)

  # --with-geoip -> check for lib and symbol presence
  LIBNAME=GeoIP # you may want to change this
  LIBSYMBOL=GeoIP_open # you most likely want to change this

  PHP_CHECK_LIBRARY($LIBNAME,$LIBSYMBOL,
  [
    PHP_ADD_LIBRARY_WITH_PATH($LIBNAME, $GEOIP_DIR/lib, GEOIP_SHARED_LIBADD)
    AC_DEFINE(HAVE_GEOIPLIB,1,[ ])
  ],[
    AC_MSG_ERROR([wrong geoip lib version or lib not found])
  ],[
    -L$GEOIP_DIR/lib -lm -ldl
  ])

  # Checking for GeoIP_setup_custom_directory in newer lib
  PHP_CHECK_LIBRARY($LIBNAME,GeoIP_setup_custom_directory,
  [
    AC_DEFINE(HAVE_CUSTOM_DIRECTORY,1,[ ])
  ],[
  ],[
    -L$GEOIP_DIR/lib -lm -ldl
  ])

  # Checking for GeoIP_continent_by_id in newer lib
  PHP_CHECK_LIBRARY($LIBNAME,GeoIP_continent_by_id,
  [
    AC_DEFINE(HAVE_CONTINENT_BY_ID,1,[ ])
  ],[
  ],[
    -L$GEOIP_DIR/lib -lm -ldl
  ])

  # Check to see if we are using the LGPL library (version 1.4.0 and newer)
  AC_MSG_CHECKING([for LGPL compatible GeoIP libs])
  libgeoip_full_version=`find $GEOIP_DIR/lib/ -name libGeoIP.\*.\*.\*.\* | cut -d . -f 2-5`
  ac_IFS=$IFS
  IFS="."
  set $libgeoip_full_version
  IFS=$ac_IFS

  # Version after the suffix (eg: .so.1.4.0)
  if test "[$]1" = "$SHLIB_SUFFIX_NAME"; then
    LIBGEOIP_VERSION=`expr [$]2 \* 1000000 + [$]3 \* 1000 + [$]4`
  # Version before the suffix (eg: 1.4.0.dylib on OS X)
  else
    LIBGEOIP_VERSION=`expr [$]1 \* 1000000 + [$]2 \* 1000 + [$]3`
  fi

  if test "$LIBGEOIP_VERSION" -lt "1004000"; then
    AC_MSG_RESULT([wrong version])
    AC_MSG_ERROR([You need version 1.4.0 or higher of the C API])
  else
    AC_MSG_RESULT([found $LIBGEOIP_VERSION])
    AC_DEFINE_UNQUOTED(LIBGEOIP_VERSION, $LIBGEOIP_VERSION, [ ])
  fi

  PHP_SUBST(GEOIP_SHARED_LIBADD)

  PHP_NEW_EXTENSION(geoip, geoip.c, $ext_shared)
fi

