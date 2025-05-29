cmake_minimum_required(VERSION 3.12)
project(dbusmenu-qt)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR
        "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    add_compile_options("$<$<CONFIG:DEBUG>:-Wall;-Wextra;-pedantic>")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules")

# Build options
option(WITH_DOC "Build documentation (requires Doxygen)" ON)

# Versions
## Package version
set(dbusmenu_qt_VERSION_MAJOR 0)
set(dbusmenu_qt_VERSION_MINOR 9)
set(dbusmenu_qt_VERSION_PATCH 2)
set(dbusmenu_qt_VERSION ${dbusmenu_qt_VERSION_MAJOR}.${dbusmenu_qt_VERSION_MINOR}.${dbusmenu_qt_VERSION_PATCH})

## Lib version
### Bump this one when a binary-incompatible change is introduced
set(dbusmenu_qt_lib_SOVERSION 2)

### Bump this one when the API is extended in a binary-compatible way
set(dbusmenu_qt_lib_API_VERSION 6)

### Bump this one when changes do not extend the API
set(dbusmenu_qt_lib_PATCH_VERSION 0)

set(dbusmenu_qt_lib_VERSION ${dbusmenu_qt_lib_SOVERSION}.${dbusmenu_qt_lib_API_VERSION}.${dbusmenu_qt_lib_PATCH_VERSION})

# Detect for which Qt version we're building
find_package(Qt4 REQUIRED)

set(QT_SUFFIX "qt")

include (CheckCXXCompilerFlag)
# Check some compiler flags
check_cxx_compiler_flag(-fvisibility=hidden __DBUSMENU_HAVE_GCC_VISIBILITY)
if (__DBUSMENU_HAVE_GCC_VISIBILITY AND NOT WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
endif (__DBUSMENU_HAVE_GCC_VISIBILITY AND NOT WIN32)

check_cxx_compiler_flag(-Woverloaded-virtual __DBUSMENU_HAVE_W_OVERLOADED_VIRTUAL)
if (__DBUSMENU_HAVE_W_OVERLOADED_VIRTUAL)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Woverloaded-virtual")
endif (__DBUSMENU_HAVE_W_OVERLOADED_VIRTUAL)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
set(CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/dbusmenu-${QT_SUFFIX}")
set(INCLUDE_INSTALL_DIR "include/dbusmenu-${QT_SUFFIX}")

# dist targets
set(ARCHIVE_NAME libdbusmenu-${QT_SUFFIX}-${dbusmenu_qt_VERSION})
add_custom_target(dist
    COMMAND bzr export --root=${ARCHIVE_NAME} ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.bz2
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

add_custom_target(distcheck
    COMMAND cd ${CMAKE_BINARY_DIR}
    && rm -rf ${ARCHIVE_NAME}
    && tar xf ${ARCHIVE_NAME}.tar.bz2
    && mkdir ${ARCHIVE_NAME}/build
    && cd ${ARCHIVE_NAME}/build
    && cmake -DCMAKE_INSTALL_PREFIX=../install ..
    && make
    && make install
    && make check
    )
add_dependencies(distcheck dist)

configure_file(dbusmenu-qt.pc.in ${CMAKE_BINARY_DIR}/dbusmenu-${QT_SUFFIX}.pc @ONLY)

install(FILES ${CMAKE_BINARY_DIR}/dbusmenu-${QT_SUFFIX}.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )

add_subdirectory(src)
add_subdirectory(tests)
add_subdirectory(tools)

if(WITH_DOC)
    configure_file(Doxyfile.in ${CMAKE_BINARY_DIR}/Doxyfile @ONLY)

    add_custom_target(doc ALL doxygen
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        )

    install(DIRECTORY ${CMAKE_BINARY_DIR}/html/
        DESTINATION share/doc/libdbusmenu-${QT_SUFFIX}-doc
        )
endif(WITH_DOC)

# Generate dbusmenu-qt-config* files
configure_package_config_file(
    dbusmenu-qt-config.cmake.in
    ${CMAKE_BINARY_DIR}/dbusmenu-${QT_SUFFIX}-config.cmake
    INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR}
    PATH_VARS INCLUDE_INSTALL_DIR
    )

write_basic_package_version_file(
    ${CMAKE_BINARY_DIR}/dbusmenu-${QT_SUFFIX}-config-version.cmake
    VERSION ${dbusmenu_qt_VERSION}
    COMPATIBILITY SameMajorVersion
    )

# Install dbusmenu-qt-config* files
install(FILES
    ${CMAKE_BINARY_DIR}/dbusmenu-${QT_SUFFIX}-config.cmake
    ${CMAKE_BINARY_DIR}/dbusmenu-${QT_SUFFIX}-config-version.cmake
    DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
    COMPONENT Devel
    )
