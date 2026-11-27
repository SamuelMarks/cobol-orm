cmake_minimum_required(VERSION 3.10)

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()
if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
  set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
endif()
if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

project(cobol-orm VERSION 0.1.0 LANGUAGES C)

# Ensure static dependencies (c-orm, parson, sqlite3) are compiled with -fPIC so
# they link cleanly into shared targets (cobol_orm_ffi and BUILD_SHARED_LIBS=ON)
# on Linux ELF (preventing R_X86_64_TPOFF32 local-exec TLS relocation errors).
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(GNUInstallDirs)
include(FetchContent)

option(COBOL_ORM_BUILD_TESTS "Build C89 and GnuCOBOL test suites" ON)
option(COBOL_ORM_BUILD_EXAMPLES "Build COBOL example programs" ON)
option(COBOL_ORM_BUILD_FREE "Build free-format COBOL modules and tests" ON)
option(COBOL_ORM_BUILD_FIXED "Build fixed 80-column COBOL modules and tests" ON)
option(COBOL_ORM_ENABLE_COVERAGE "Enable GCC/Clang coverage instrumentation on cobol-orm targets" OFF)
option(COBOL_ORM_ENABLE_ASAN "Enable AddressSanitizer and UndefinedBehaviorSanitizer" OFF)

# Propagate default c-orm backend configuration
set(C_ORM_SQLITE "LINKED" CACHE STRING "Enable SQLite driver (LINKED, DYNAMIC, OFF)")
set(C_ORM_POSTGRESQL "DYNAMIC" CACHE STRING "Enable PostgreSQL driver (LINKED, DYNAMIC, OFF)")
set(C_ORM_MYSQL "DYNAMIC" CACHE STRING "Enable MySQL driver (LINKED, DYNAMIC, OFF)")
option(C_ORM_ENABLE_ODBC "Enable Generic ODBC driver support" ON)
option(C_ORM_ENABLE_DB2 "Enable IBM Db2 CLI/ODBC driver support" ON)
option(C_ORM_ENABLE_COPYBOOK "Enable COBOL Copybook parser and codegen" ON)
option(C_ORM_THREADING "Enable multi-threading" ON)

# Save coverage/sanitizer flags before adding dependencies so deps stay clean
set(_cobol_orm_saved_c_flags "${CMAKE_C_FLAGS}")
set(_cobol_orm_saved_exe_flags "${CMAKE_EXE_LINKER_FLAGS}")
set(_cobol_orm_saved_shared_flags "${CMAKE_SHARED_LINKER_FLAGS}")

set(_cobol_orm_old_build_testing "${BUILD_TESTING}")
set(_cobol_orm_old_shared_libs "${BUILD_SHARED_LIBS}")
set(BUILD_TESTING OFF)
set(BUILD_SHARED_LIBS OFF)
set(C_ORM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(C_ORM_TESTING OFF CACHE BOOL "" FORCE)
set(C_ORM_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(C_ORM_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
set(C_CDD_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(C_FS_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(C_FS_BUILD_TESTING OFF CACHE BOOL "" FORCE)

# Consume ../c-orm when present locally, else fallback to FetchContent
set(COBOL_ORM_C_ORM_DIR "" CACHE PATH "Optional local path to c-orm repository")
if(NOT COBOL_ORM_C_ORM_DIR AND EXISTS "${CMAKE_CURRENT_LIST_DIR}/../c-orm/CMakeLists.txt")
  set(COBOL_ORM_C_ORM_DIR "${CMAKE_CURRENT_LIST_DIR}/../c-orm")
endif()

if(COBOL_ORM_C_ORM_DIR AND EXISTS "${COBOL_ORM_C_ORM_DIR}/CMakeLists.txt")
  FetchContent_Declare(c_orm SOURCE_DIR "${COBOL_ORM_C_ORM_DIR}")
else()
  FetchContent_Declare(
    c_orm
    GIT_REPOSITORY https://github.com/SamuelMarks/c-orm.git
    GIT_TAG master
  )
endif()
if(NOT TARGET c-orm)
  FetchContent_MakeAvailable(c_orm)
endif()

set(BUILD_TESTING "${_cobol_orm_old_build_testing}")
set(BUILD_SHARED_LIBS "${_cobol_orm_old_shared_libs}")
set(CMAKE_C_FLAGS "${_cobol_orm_saved_c_flags}")
set(CMAKE_EXE_LINKER_FLAGS "${_cobol_orm_saved_exe_flags}")
set(CMAKE_SHARED_LINKER_FLAGS "${_cobol_orm_saved_shared_flags}")

# Strict ISO C89 warning flags (zero -Wno-* suppressions)
if(MSVC)
  set(COBOL_ORM_STRICT_OPTIONS /W4 /WX)
  if(NOT MSVC_VERSION LESS 1700)
    list(APPEND COBOL_ORM_STRICT_OPTIONS /sdl)
  endif()
else()
  set(COBOL_ORM_STRICT_OPTIONS
    -std=c90
    -pedantic
    -Wall
    -Wextra
    -Werror
    -Wdeclaration-after-statement
    -Wmissing-prototypes
    -Wstrict-prototypes
    -Wold-style-definition
    -Wwrite-strings
    -Wcast-qual
  )
endif()

set(COBOL_ORM_INSTR_COMPILE_FLAGS)
set(COBOL_ORM_INSTR_LINK_FLAGS)
if(COBOL_ORM_ENABLE_COVERAGE AND NOT MSVC)
  list(APPEND COBOL_ORM_INSTR_COMPILE_FLAGS --coverage -O0 -g)
  list(APPEND COBOL_ORM_INSTR_LINK_FLAGS --coverage)
endif()
if(COBOL_ORM_ENABLE_ASAN AND NOT MSVC)
  list(APPEND COBOL_ORM_INSTR_COMPILE_FLAGS -fsanitize=address,undefined -fno-omit-frame-pointer -g)
  list(APPEND COBOL_ORM_INSTR_LINK_FLAGS -fsanitize=address,undefined)
endif()

set(COBOL_ORM_C_SOURCES
  src/cobol_orm_str.c
  src/cobol_orm_db.c
  src/cobol_orm_pool.c
  src/cobol_orm_tx.c
  src/cobol_orm_stmt.c
  src/cobol_orm_abstract.c
  src/cobol_orm_query.c
  src/cobol_orm_decimal.c
  src/cobol_orm_ebcdic.c
  src/cobol_orm_copybook.c
  src/cobol_orm_migrations.c
  src/cobol_orm_enterprise.c
  src/cobol_orm_legacy.c
  src/generated/cobol_orm_cobol_shim.c
)

# Primary library target (respects BUILD_SHARED_LIBS)
add_library(cobol_orm_c ${COBOL_ORM_C_SOURCES})
set_target_properties(cobol_orm_c PROPERTIES
  OUTPUT_NAME "cobol_orm"
  WINDOWS_EXPORT_ALL_SYMBOLS ON
  POSITION_INDEPENDENT_CODE ON
)
target_include_directories(cobol_orm_c
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/generated>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_link_libraries(cobol_orm_c PRIVATE $<BUILD_INTERFACE:c-orm>)
target_compile_definitions(cobol_orm_c PUBLIC $<$<BOOL:${BUILD_SHARED_LIBS}>:COBOL_ORM_SHARED>)
target_compile_options(cobol_orm_c PRIVATE ${COBOL_ORM_STRICT_OPTIONS} ${COBOL_ORM_INSTR_COMPILE_FLAGS})
if(COBOL_ORM_INSTR_LINK_FLAGS)
  target_link_options(cobol_orm_c PUBLIC ${COBOL_ORM_INSTR_LINK_FLAGS})
endif()

# Self-contained shared FFI library for direct GnuCOBOL cobc linking & COB_PRE_LOAD
add_library(cobol_orm_ffi SHARED ${COBOL_ORM_C_SOURCES})
set_target_properties(cobol_orm_ffi PROPERTIES
  OUTPUT_NAME "cobol_orm_ffi"
  WINDOWS_EXPORT_ALL_SYMBOLS ON
  INSTALL_RPATH "@loader_path;$ORIGIN"
)
target_include_directories(cobol_orm_ffi
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/generated>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_link_libraries(cobol_orm_ffi PRIVATE $<BUILD_INTERFACE:c-orm>)
target_compile_definitions(cobol_orm_ffi PUBLIC COBOL_ORM_SHARED)
target_compile_options(cobol_orm_ffi PRIVATE ${COBOL_ORM_STRICT_OPTIONS})

# Reproducible binding regeneration target using ../cdd-c
add_custom_target(cobol_orm_regen
  COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/scripts/generate_bindings.sh"
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  COMMENT "Regenerating COBOL FFI bindings via cdd-c"
)

# Optional GnuCOBOL toolchain integration
find_package(GnuCOBOL QUIET)
if(GnuCOBOL_FOUND)
  message(STATUS "Found GnuCOBOL ${GNUCOBOL_VERSION}: ${GNUCOBOL_COBC_EXECUTABLE}")

  set(_cobol_mod_dir "${CMAKE_CURRENT_BINARY_DIR}/cobol_modules")
  file(MAKE_DIRECTORY "${_cobol_mod_dir}")

  if(COBOL_ORM_BUILD_FREE)
    add_custom_command(
      OUTPUT "${_cobol_mod_dir}/cobol_orm_lib_free.o"
      COMMAND "${GNUCOBOL_COBC_EXECUTABLE}" -c -free -Wall -Wextra -Werror
        -I "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
        -I "${CMAKE_CURRENT_SOURCE_DIR}/generated/free"
        -o "${_cobol_mod_dir}/cobol_orm_lib_free.o"
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/free/cobol_orm_lib.cbl"
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/cobol/free/cobol_orm_lib.cbl"
              "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free/cobol_orm.cpy"
      COMMENT "Compiling free-format COBOL wrapper library object"
    )
    add_custom_target(cobol_orm_lib_free ALL DEPENDS "${_cobol_mod_dir}/cobol_orm_lib_free.o")
  endif()

  if(COBOL_ORM_BUILD_FIXED)
    add_custom_command(
      OUTPUT "${_cobol_mod_dir}/cobol_orm_lib_fixed.o"
      COMMAND "${GNUCOBOL_COBC_EXECUTABLE}" -c -fixed -Wall -Wextra -Werror
        -I "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
        -I "${CMAKE_CURRENT_SOURCE_DIR}/generated/fixed"
        -o "${_cobol_mod_dir}/cobol_orm_lib_fixed.o"
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/fixed/cobol_orm_lib.cbl"
      DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/cobol/fixed/cobol_orm_lib.cbl"
              "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed/cobol_orm.cpy"
      COMMENT "Compiling fixed-80 COBOL wrapper library object"
    )
    add_custom_target(cobol_orm_lib_fixed ALL DEPENDS "${_cobol_mod_dir}/cobol_orm_lib_fixed.o")
  endif()
endif()

# Tests
if(COBOL_ORM_BUILD_TESTS)
  include(CTest)
  enable_testing()

  set(_greatest_inc "${greatest_SOURCE_DIR}")
  if(NOT _greatest_inc AND EXISTS "${CMAKE_BINARY_DIR}/_deps/greatest-src")
    set(_greatest_inc "${CMAKE_BINARY_DIR}/_deps/greatest-src")
  endif()

  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/c/test_cobol_orm.c")
    add_executable(test_cobol_orm_c tests/c/test_cobol_orm.c)
    target_link_libraries(test_cobol_orm_c PRIVATE cobol_orm_c c-orm)
    target_include_directories(test_cobol_orm_c PRIVATE "${_greatest_inc}" "${CMAKE_CURRENT_SOURCE_DIR}/src")
    target_compile_definitions(test_cobol_orm_c PRIVATE C_ORM_TEST_ALLOCATOR=1)
    target_compile_options(test_cobol_orm_c PRIVATE ${COBOL_ORM_STRICT_OPTIONS} ${COBOL_ORM_INSTR_COMPILE_FLAGS})
    if(COBOL_ORM_INSTR_LINK_FLAGS)
      target_link_options(test_cobol_orm_c PRIVATE ${COBOL_ORM_INSTR_LINK_FLAGS})
    endif()
    add_test(NAME c89_unit_and_oom_suite COMMAND test_cobol_orm_c)
  endif()

  if(GnuCOBOL_FOUND)
    set(_cobol_test_bin_dir "${CMAKE_CURRENT_BINARY_DIR}/cobol_tests")
    file(MAKE_DIRECTORY "${_cobol_test_bin_dir}")

    # Helper macro to compile & register a GnuCOBOL executable test linked to cobol_orm_ffi
    macro(cobol_orm_add_cobol_test TEST_NAME SRC_FILE STD_FLAG FMT_FLAG WARN_FLAGS INC_DIR EXTRA_OBJ PASS_REGEX)
      set(_out_bin "${_cobol_test_bin_dir}/${TEST_NAME}")
      set(_cobc_args -x ${FMT_FLAG} ${WARN_FLAGS})
      if(NOT "${STD_FLAG}" STREQUAL "")
        list(APPEND _cobc_args "${STD_FLAG}")
      endif()
      list(APPEND _cobc_args
        -I "${INC_DIR}"
        -o "${_out_bin}"
        "${SRC_FILE}"
      )
      if(NOT "${EXTRA_OBJ}" STREQUAL "")
        list(APPEND _cobc_args "${EXTRA_OBJ}")
      endif()
      if(APPLE OR WIN32)
        list(APPEND _cobc_args
          "$<TARGET_FILE:cobol_orm_ffi>"
          "-Q" "-Wl,-rpath,$<TARGET_FILE_DIR:cobol_orm_ffi>"
        )
      else()
        list(APPEND _cobc_args
          "-Q" "-Wl,--no-as-needed"
          "-Q" "$<TARGET_FILE:cobol_orm_ffi>"
          "-Q" "-Wl,--as-needed"
          "-Q" "-Wl,-rpath,$<TARGET_FILE_DIR:cobol_orm_ffi>"
          "-Q" "-Wl,--export-dynamic"
        )
      endif()
      set(_deps "${SRC_FILE}" cobol_orm_ffi)
      if(NOT "${EXTRA_OBJ}" STREQUAL "")
        list(APPEND _deps "${EXTRA_OBJ}")
      endif()
      add_custom_command(
        OUTPUT "${_out_bin}"
        COMMAND "${GNUCOBOL_COBC_EXECUTABLE}" ${_cobc_args}
        DEPENDS ${_deps}
        COMMENT "Building COBOL test ${TEST_NAME}"
      )
      add_custom_target("build_${TEST_NAME}" ALL DEPENDS "${_out_bin}")
      add_test(NAME "${TEST_NAME}" COMMAND "${_out_bin}" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
      if(NOT "${PASS_REGEX}" STREQUAL "")
        set_tests_properties("${TEST_NAME}" PROPERTIES PASS_REGULAR_EXPRESSION "${PASS_REGEX}")
      endif()
    endmacro()

    set(_cobc_warn_strict -Wall -Wextra -Werror)
    set(_cobc_warn_pre85 -Wall -Werror)

    # Generated ABI layout verification tests (free & fixed)
    if(COBOL_ORM_BUILD_FREE)
      cobol_orm_add_cobol_test(cobol_abi_layout_free
        "${CMAKE_CURRENT_SOURCE_DIR}/generated/free/cobol_orm_test.cbl"
        "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/generated/free" "" "")
    endif()
    if(COBOL_ORM_BUILD_FIXED)
      cobol_orm_add_cobol_test(cobol_abi_layout_fixed
        "${CMAKE_CURRENT_SOURCE_DIR}/generated/fixed/cobol_orm_test.cbl"
        "" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/generated/fixed" "" "")
    endif()

    # All 10 COBOL Standard Era Verification Suites (COBOL-60 .. COBOL-2023)
    if(COBOL_ORM_BUILD_FIXED)
      cobol_orm_add_cobol_test(cobol_era_60
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol60/corm_era60.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_pre85}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-60")
      cobol_orm_add_cobol_test(cobol_era_61
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol61/corm_era61.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_pre85}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-61")
      cobol_orm_add_cobol_test(cobol_era_61x
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol61x/corm_era61x.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_pre85}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-61X")
      cobol_orm_add_cobol_test(cobol_era_65
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol65/corm_era65.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_pre85}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-65")
      cobol_orm_add_cobol_test(cobol_era_68
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol68/corm_era68.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_pre85}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-68")
      cobol_orm_add_cobol_test(cobol_era_74
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol74/corm_era74.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_pre85}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-74")
      cobol_orm_add_cobol_test(cobol_era_85
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol85/corm_era85.cbl"
        "-std=cobol85" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era" "" "PASS: COBOL-85")
      cobol_orm_add_cobol_test(cobol_era_2002
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol2002/corm_era2002.cbl"
        "-std=cobol2002" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed" "" "")
    endif()
    if(COBOL_ORM_BUILD_FREE)
      cobol_orm_add_cobol_test(cobol_era_2014
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol2014/corm_era2014.cbl"
        "-std=cobol2014" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free" "" "")
      cobol_orm_add_cobol_test(cobol_era_2023
        "${CMAKE_CURRENT_SOURCE_DIR}/cobol/era/cobol2023/corm_era2023.cbl"
        "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
        "${_cobol_mod_dir}/cobol_orm_lib_free.o" "")
    endif()

    # Additional E2E COBOL integration tests when present
    if(COBOL_ORM_BUILD_FREE AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/cobol/test_e2e_free.cbl")
      cobol_orm_add_cobol_test(cobol_e2e_free
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/cobol/test_e2e_free.cbl"
        "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
        "${_cobol_mod_dir}/cobol_orm_lib_free.o" "")
    endif()
    if(COBOL_ORM_BUILD_FIXED AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/cobol/test_e2e_fixed.cbl")
      cobol_orm_add_cobol_test(cobol_e2e_fixed
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/cobol/test_e2e_fixed.cbl"
        "" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
        "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "")
    endif()

    # Enterprise IBM & Micro Focus strict fixed-80 syntax verification gates
    if(COBOL_ORM_BUILD_FIXED)
      add_test(NAME cobol_ibm_strict_syntax
        COMMAND "${GNUCOBOL_COBC_EXECUTABLE}" -fsyntax-only -fixed -std=ibm-strict -Wall -Wextra -Werror
          -I "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${CMAKE_CURRENT_SOURCE_DIR}/cobol/fixed/cobol_orm_lib.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/tests/cobol/test_e2e_fixed.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/migrations_and_pool.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/prepared_statements.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/abstract_result_set.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/copybook_batch_validation.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/mainframe_codecs_and_commarea.cbl"
      )
      add_test(NAME cobol_mf_strict_syntax
        COMMAND "${GNUCOBOL_COBC_EXECUTABLE}" -fsyntax-only -fixed -std=mf-strict -Wall -Wextra -Werror
          -I "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${CMAKE_CURRENT_SOURCE_DIR}/cobol/fixed/cobol_orm_lib.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/tests/cobol/test_e2e_fixed.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/quickstart_crud.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/banking_ledger.cbl"
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/query_builder_demo.cbl"
      )
    endif()

    # Runnable COBOL Examples (Free & Fixed 80-Column)
    if(COBOL_ORM_BUILD_EXAMPLES)
      if(COBOL_ORM_BUILD_FREE)
        cobol_orm_add_cobol_test(example_free_quickstart
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/quickstart_crud.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-QUICKSTART OK")
        cobol_orm_add_cobol_test(example_free_banking
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/banking_ledger.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-BANKING OK")
        cobol_orm_add_cobol_test(example_free_query_ast
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/query_builder_demo.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-QUERY-AST OK")
        cobol_orm_add_cobol_test(example_free_migrations_pool
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/migrations_and_pool.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-POOL-DEMO OK")
        cobol_orm_add_cobol_test(example_free_prepared_statements
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/prepared_statements.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-PREP-STMT OK")
        cobol_orm_add_cobol_test(example_free_abstract_rs
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/abstract_result_set.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-ABSTRACT-RS OK")
        cobol_orm_add_cobol_test(example_free_copybook_batch
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/copybook_batch_validation.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-CPY-BATCH OK")
        cobol_orm_add_cobol_test(example_free_mainframe_codecs
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/free/mainframe_codecs_and_commarea.cbl"
          "" "-free" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/free"
          "${_cobol_mod_dir}/cobol_orm_lib_free.o" "EX-MAINFRAME OK")
      endif()
      if(COBOL_ORM_BUILD_FIXED)
        cobol_orm_add_cobol_test(example_fixed_quickstart
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/quickstart_crud.cbl"
          "" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-QUICKSTART OK")
        cobol_orm_add_cobol_test(example_fixed_banking
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/banking_ledger.cbl"
          "" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-BANKING OK")
        cobol_orm_add_cobol_test(example_fixed_query_ast
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/query_builder_demo.cbl"
          "" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-QUERY-AST OK")
        cobol_orm_add_cobol_test(example_fixed_migrations_pool
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/migrations_and_pool.cbl"
          "-std=ibm-strict" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-POOL-DEMO OK")
        cobol_orm_add_cobol_test(example_fixed_prepared_statements
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/prepared_statements.cbl"
          "-std=ibm-strict" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-PREP-STMT OK")
        cobol_orm_add_cobol_test(example_fixed_abstract_rs
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/abstract_result_set.cbl"
          "-std=ibm-strict" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-ABSTRACT-RS OK")
        cobol_orm_add_cobol_test(example_fixed_copybook_batch
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/copybook_batch_validation.cbl"
          "-std=ibm-strict" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-CPY-BATCH OK")
        cobol_orm_add_cobol_test(example_fixed_mainframe_codecs
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/mainframe_codecs_and_commarea.cbl"
          "-std=ibm-strict" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/fixed"
          "${_cobol_mod_dir}/cobol_orm_lib_fixed.o" "EX-MAINFRAME OK")
        cobol_orm_add_cobol_test(example_fixed_legacy_payroll
          "${CMAKE_CURRENT_SOURCE_DIR}/examples/fixed/legacy_commarea_payroll.cbl"
          "-std=cobol85" "-fixed" "${_cobc_warn_strict}" "${CMAKE_CURRENT_SOURCE_DIR}/copybooks/era"
          "" "EX-LEG-PAY OK")
      endif()
    endif()
  endif()
endif()

# Install, CMake package config & pkg-config
include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cobol-orm-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cobol-orm-config.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/cobol-orm"
)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/cobol-orm-config-version.cmake"
  VERSION "${PROJECT_VERSION}"
  COMPATIBILITY SameMajorVersion
)
install(TARGETS cobol_orm_c cobol_orm_ffi
  EXPORT cobol-orm-targets
  ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
  RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)
install(EXPORT cobol-orm-targets
  FILE cobol-orm-targets.cmake
  NAMESPACE cobol_orm::
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/cobol-orm"
)
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/cobol-orm-config.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/cobol-orm-config-version.cmake"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/cobol-orm"
)
install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(DIRECTORY copybooks/ DESTINATION "${CMAKE_INSTALL_DATADIR}/cobol-orm/copybooks")
install(DIRECTORY cobol/ DESTINATION "${CMAKE_INSTALL_DATADIR}/cobol-orm/cobol")
install(DIRECTORY generated/free/ DESTINATION "${CMAKE_INSTALL_DATADIR}/cobol-orm/generated/free" FILES_MATCHING PATTERN "*.cpy" PATTERN "*.cbl")
install(DIRECTORY generated/fixed/ DESTINATION "${CMAKE_INSTALL_DATADIR}/cobol-orm/generated/fixed" FILES_MATCHING PATTERN "*.cpy" PATTERN "*.cbl")

set(COBOL_ORM_PC_FILE "${CMAKE_CURRENT_BINARY_DIR}/cobol-orm.pc")
file(WRITE "${COBOL_ORM_PC_FILE}"
  "prefix=${CMAKE_INSTALL_PREFIX}\n"
  "exec_prefix=\${prefix}\n"
  "libdir=\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}\n"
  "includedir=\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}\n\n"
  "Name: cobol-orm\n"
  "Description: COBOL FFI Library for c-orm generated via cdd-c (COBOL-60..COBOL-2023)\n"
  "Version: ${PROJECT_VERSION}\n"
  "Libs: -L\${libdir} -lcobol_orm -lc-orm\n"
  "Cflags: -I\${includedir}\n"
)
install(FILES "${COBOL_ORM_PC_FILE}" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
