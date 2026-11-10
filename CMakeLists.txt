cmake_minimum_required(VERSION 3.16)
project(example-personal-site VERSION 0.1.1 LANGUAGES NONE)

# Pure Tcl: installation copies source, templates, and seed content without compiling.
set(PACKAGE_DIR "lib/example-personal-site${PROJECT_VERSION}")
install(FILES pkgIndex.tcl main.tcl usage.txt readme.md LICENSE DESTINATION "${PACKAGE_DIR}")
install(DIRECTORY library assets content DESTINATION "${PACKAGE_DIR}")
install(PROGRAMS bin/example-personal-site DESTINATION bin)

include(CTest)
if(BUILD_TESTING)
    find_program(TCLSH NAMES tclsh9.1 tclsh9.0 tclsh8.6 tclsh REQUIRED)
    add_test(NAME personal-site COMMAND "${TCLSH}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/all.tcl")
endif()
