# Find QJSON - JSON handling library for Qt
#
# This module defines
#  QJSON_FOUND - whether the qsjon library was found
#  QJSON_LIBRARIES - the qjson library
#  QJSON_INCLUDE_DIR - the include path of the qjson library
#

if (QJSON_INCLUDE_DIR AND QJSON_LIBRARIES)

  # Already in cache
  set (QJSON_FOUND TRUE)

else (QJSON_INCLUDE_DIR AND QJSON_LIBRARIES)

  if (NOT WIN32)
    # use pkg-config to get the values of QJSON_INCLUDE_DIRS
    # and QJSON_LIBRARY_DIRS to add as hints to the find commands.
    find_package(PkgConfig QUIET)

    if(PKG_CONFIG_FOUND)
        pkg_check_modules (PC_QJSON QJson>=0.5)
    endif()
  endif (NOT WIN32)

  find_library (QJSON_LIBRARIES
    NAMES
    qjson
    PATHS
    ${PC_QJSON_LIBRARY_DIRS}
    ${LIB_INSTALL_DIR}
    ${KDE4_LIB_DIR}
  )

  find_path (QJSON_INCLUDE_DIR
    NAMES
    qjson/parser.h
    PATHS
    ${PC_QJSON_INCLUDE_DIRS}
    ${INCLUDE_INSTALL_DIR}
    ${KDE4_INCLUDE_DIR}
  )

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(QJSON DEFAULT_MSG QJSON_LIBRARIES QJSON_INCLUDE_DIR)

endif (QJSON_INCLUDE_DIR AND QJSON_LIBRARIES)
