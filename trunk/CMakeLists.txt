cmake_minimum_required(VERSION 2.6)
project(collabedit CXX C)

##########################################################
## Build generator
##########################################################
if(NOT SECOND_RUN)

option(ALLOW_IN_SOURCE_BUILDS "Allow in-source builds" "OFF")
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR AND NOT ALLOW_IN_SOURCE_BUILDS)
    message(FATAL_ERROR "In-source builds are not allowed.
        Please create a directory and run cmake from there, passing the path
        to this source directory as the last argument.
        This process created the file `CMakeCache.txt` and the directory `CMakeFiles'.
        Please delete them.
        
        Or you can restart cmake with `-DALLOW_IN_SOURCE_BUILDS=1`, but it is not
        recommended.")
endif(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR AND NOT ALLOW_IN_SOURCE_BUILDS)

find_package(Qt4 REQUIRED)

##--------------------------------------------
## Settings
##--------------------------------------------

## Options
option(VERBOSE_DEBUG "Verbose debug" "OFF")
#option(CEDIT_BUILD_SVN "Build SVN Plugin" "ON") # some people dont want to use svn, so we should allow userspecific build options

## Init D toolkit
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(D REQUIRED)

# Check D compiler version
if(D_VERSION EQUAL "1")
    if (D_FRONTEND LESS "050")
        message(STATUS "Minimum required version of D compiler is 1.050 (or compiler based on this version)")
    endif(D_FRONTEND LESS "050")
    set(D_TARGET d1-tango CACHE INTERNAL "")   
elseif(D_VERSION EQUAL "2")
    set(D_TARGET d2-phobos CACHE INTERNAL "")
endif(D_VERSION EQUAL "1")

# Debug and release flags
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif (NOT CMAKE_BUILD_TYPE)
if(${CMAKE_BUILD_TYPE} MATCHES [dD][eE][bB][uU][gG])
    set(CMAKE_BUILD_TYPE Debug)
    #set(SUFFIXLIB "${SUFFIXLIB}-debug")
    #set(SUFFIXBIN "${SUFFIXBIN}-debug")
    add_definitions(-DDEBUG)
elseif (NOT ${CMAKE_BUILD_TYPE} MATCHES [rR][eE][lL][eE][aA][sS])
    message(STATUS "Only debug and release configurations are supported. The configuration is changed to 'Release'")
    set(CMAKE_BUILD_TYPE Release)
endif (${CMAKE_BUILD_TYPE} MATCHES [dD][eE][bB][uU][gG]) 
if (${CMAKE_BUILD_TYPE} MATCHES [rR][eE][lL][eE][aA][sS])
    #add_definitions(-UNO_DEBUG)
endif(${CMAKE_BUILD_TYPE} MATCHES [rR][eE][lL][eE][aA][sS] )

# System specific settings.
if(CMAKE_HOST_WIN32)
    set(implib implib)
    find_program(IMPLIB ${implib})
    if (NOT IMPLIB)
        message(FATAL_ERROR "implib is not found. You can donwload it from http://ftp.digitalmars.com/bup.zip")
    endif (NOT IMPLIB)
    if(D_IS_MARS)
        set(GEN_OPT ${GEN_OPT} --cpp_shared)
        add_definitions(-DCPP_SHARED)
    endif(D_IS_MARS)
endif(CMAKE_HOST_WIN32)

set(GEN_OPT ${GEN_OPT} --d-target=${D_TARGET})

if(${CMAKE_GENERATOR} STREQUAL "NMake Makefiles")
    set(make_util nmake)
elseif(${CMAKE_GENERATOR} STREQUAL "MinGW Makefiles" OR
    ${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
    set(make_util $(MAKE))
else(${CMAKE_GENERATOR} STREQUAL "NMake Makefiles")
    message(FATAL_ERROR "${CMAKE_GENERATOR} is not supported")
endif(${CMAKE_GENERATOR} STREQUAL "NMake Makefiles")

if(${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
    set(cd_path ${CMAKE_SOURCE_DIR})
else(${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
    set(cd_path ${CMAKE_BINARY_DIR}/bin)
endif(${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_SOURCE_DIR})

make_native_path(cd_path)
add_custom_command(TARGET main POST_BUILD   
     COMMAND ${CMAKE_COMMAND} ARGS -E make_directory ${CMAKE_BINARY_DIR}/bin
     COMMAND cd  ARGS ${cd_path} && ${CMAKE_COMMAND} -G${CMAKE_GENERATOR} -DSECOND_RUN=1 ${CMAKE_SOURCE_DIR} && ${make_util}
     COMMENT "") 

## "Make install" command.
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES ${CMAKE_BINARY_DIR}/bin)
add_custom_target(install
    COMMAND cd ${CMAKE_BINARY_DIR}/bin && ${make_util} install
    COMMENT "") 
add_dependencies(install preinstall)

##--------------------------------------------
## CPack.
##--------------------------------------------
set(CPACK_PACKAGE_VERSION_PATCH 1)
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "collabEdit is a real-time collaborative editor,
    which allows several people to write on a project at the same time.")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/changelog.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/license.txt")
set(CPACK_PACKAGE_VENDOR "collabEdit team")
set(CPACK_PACKAGE_CONTACT "lmartin92@users.sourceforge.net, danny90@users.sourceforge.net" )
set(CPACK_PACKAGE_VERSION "0.1")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "collabedit ${CPACK_PACKAGE_VERSION}")
set(CPACK_PACKAGE_FILE_NAME "collabedit-${CPACK_PACKAGE_VERSION}")
set(CPACK_SOURCE_PACKAGE_FILE_NAME "collabedit-${CPACK_PACKAGE_VERSION}")
if(CMAKE_HOST_WIN32)
    set(CPACK_GENERATOR "ZIP")
elseif(CMAKE_HOST_UNIX)
    set(CPACK_GENERATOR "TBZ2;DEB;RPM")
endif(CMAKE_HOST_WIN32)
include(CPack)

##########################################################
## Build collabEdit
##########################################################
else(NOT SECOND_RUN)

PROJECT(qtd CXX C)
if(NOT ${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
    load_cache(${CMAKE_BINARY_DIR}/.. INCLUDE_INTERNALS CEDIT_VERSION_STR CEDIT_VERSION)
endif(NOT ${CMAKE_BINARY_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(D REQUIRED)
find_package(Qt4 REQUIRED)

set(CEDIT_VERSION_STR ${CEDIT_VERSION_MAJOR}.${CEDIT_VERSION_MINOR}.${CEDIT_VERSION_PATCH})
math(EXPR CEDIT_VERSION "(${CEDIT_VERSION_MAJOR} << 16) + (${CEDIT_VERSION_MINOR} << 8) + ${CEDIT_VERSION_PATCH}")

# System specifc settings.
if(CMAKE_HOST_WIN32 AND D_IS_MARS)
    set(CPP_SHARED 1 CACHE INTERNAL "")
endif(CMAKE_HOST_WIN32 AND D_IS_MARS)

if(D_IS_MARS)
    set(D_FLAGS -version=cpp_shared)   
    add_definitions(-DCPP_SHARED)
endif(D_IS_MARS)

if(VERBOSE_DEBUG)
    add_d_debugs(ceditVerbose)
endif(VERBOSE_DEBUG)

## Bootstrap settings for collabEdit
set(CEDIT_IMPORT_PATH ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR} CACHE INTERNAL "")

## Add main target
add_d_program(cedit ${CMAKE_SOURCE_DIR}/src/Main NO_DEPS_SOURCES INCLUDES ${CMAKE_CURRENT_BINARY_DIR})

set(SECOND_RUN 0 CACHE INTERNAL "")

endif(NOT SECOND_RUN)