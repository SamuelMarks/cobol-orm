# FindGnuCOBOL.cmake
# Locates GnuCOBOL compiler (cobc), runtime runner (cobcrun), and libcob.

find_program(GNUCOBOL_COBC_EXECUTABLE
    NAMES cobc
    PATHS
        /opt/homebrew/bin
        /usr/local/bin
        /usr/bin
)

find_program(GNUCOBOL_COBCRUN_EXECUTABLE
    NAMES cobcrun
    PATHS
        /opt/homebrew/bin
        /usr/local/bin
        /usr/bin
)

find_path(GNUCOBOL_INCLUDE_DIR
    NAMES libcob.h
    PATHS
        /opt/homebrew/include
        /usr/local/include
        /usr/include
)

find_library(GNUCOBOL_LIBRARY
    NAMES cob libcob
    PATHS
        /opt/homebrew/lib
        /usr/local/lib
        /usr/lib
)

if(GNUCOBOL_COBC_EXECUTABLE)
    execute_process(
        COMMAND "${GNUCOBOL_COBC_EXECUTABLE}" --version
        OUTPUT_VARIABLE _cobc_ver_out
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(_cobc_ver_out MATCHES "cobc \\(GnuCOBOL\\) ([0-9]+\\.[0-9]+\\.[0-9]+)")
        set(GNUCOBOL_VERSION "${CMAKE_MATCH_1}")
    endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GnuCOBOL
    REQUIRED_VARS GNUCOBOL_COBC_EXECUTABLE
    VERSION_VAR GNUCOBOL_VERSION
)

if(GnuCOBOL_FOUND AND NOT TARGET GnuCOBOL::cobc)
    add_executable(GnuCOBOL::cobc IMPORTED)
    set_target_properties(GnuCOBOL::cobc PROPERTIES
        IMPORTED_LOCATION "${GNUCOBOL_COBC_EXECUTABLE}"
    )
endif()

if(GnuCOBOL_FOUND AND GNUCOBOL_LIBRARY AND NOT TARGET GnuCOBOL::libcob)
    add_library(GnuCOBOL::libcob UNKNOWN IMPORTED)
    set_target_properties(GnuCOBOL::libcob PROPERTIES
        IMPORTED_LOCATION "${GNUCOBOL_LIBRARY}"
    )
    if(GNUCOBOL_INCLUDE_DIR)
        set_target_properties(GnuCOBOL::libcob PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${GNUCOBOL_INCLUDE_DIR}"
        )
    endif()
endif()
