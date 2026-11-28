# `cobol-orm`

[![C89 Strict](https://img.shields.io/badge/C-ISO%20C89%20pedantic%20-blue)](#quality-gates)
[![COBOL Standards](https://img.shields.io/badge/COBOL-60%20..%202023%20(10%2F10)-brightgreen)](#multi-era-cobol-compatibility-matrix)
[![Doc Coverage](https://img.shields.io/badge/doc%20coverage-100%25-brightgreen)](#quality-gates)
[![Line Coverage](https://img.shields.io/badge/line%20coverage-100%25%20(2330%2F2330)-brightgreen)](#quality-gates)
[![Branch Coverage](https://img.shields.io/badge/branch%20coverage-100%25%20(1039%2F1039)-brightgreen)](#quality-gates)
[![Function Coverage](https://img.shields.io/badge/function%20coverage-100%25%20(150%2F150)-brightgreen)](#quality-gates)
[![cobol-orm CI](https://github.com/SamuelMarks/cobol-orm/actions/workflows/ci.yml/badge.svg)](https://github.com/SamuelMarks/cobol-orm/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0%20OR%20MIT-blue)](#license)

**`cobol-orm`** is a production-grade, strongly-typed COBOL ORM and database FFI library exposing [`c-orm`](../c-orm) to **all 10 historical and modern COBOL standards** (`COBOL-60` through `COBOL-2023`), reproducibly generated with [`cdd-c`](../cdd-c) (`cdd-c bind -l cobol`) and backed by an ISO C89 FFI facade, dual **free-format** and **strict fixed 80-column** COBOL libraries, and an endian-independent `USAGE DISPLAY` `COMMAREA` bridge for legacy dialects.

---

## Table of Contents

- [Key Capabilities](#key-capabilities)
- [Multi-Era COBOL Compatibility Matrix](#multi-era-cobol-compatibility-matrix)
- [Quickstart](#quickstart)
  - [Build & Run All 34 Verification Tests](#build--run-all-34-verification-tests)
  - [Free-Format COBOL-2014/2023 Example](#free-format-cobol-20142023-example)
  - [Strict Fixed-80 IBM Enterprise COBOL Example](#strict-fixed-80-ibm-enterprise-cobol-example)
  - [Historical COBOL-60..COBOL-85 Example](#historical-cobol-60cobol-85-example)
- [Feature Matrix (Modules A–L)](#feature-matrix-modules-al)
- [CMake Build Options](#cmake-build-options)
- [Runnable Examples](#runnable-examples)
- [Quality Gates & Verification](#quality-gates--verification)
- [Repository Layout](#repository-layout)
- [Documentation Index](#documentation-index)
- [License](#license)

---

## Key Capabilities

- **All 10 COBOL Standards Supported & Tested**: Verified end-to-end across **COBOL-60**, **COBOL-61**, **COBOL-61 Extended**, **COBOL-65**, **COBOL-68**, **COBOL-74**, **COBOL-85**, **COBOL-2002**, **COBOL-2014**, and **COBOL-2023**, plus strict **IBM Enterprise COBOL** (`-std=ibm-strict`) and **Micro Focus** (`-std=mf-strict`) fixed-80 compliance checks.
- **Reproducible `cdd-c` FFI Pipeline**: `include/cobol_orm_ffi.h` -> `libclang` IR JSON (`ffi/cobol_orm_ffi.json`) -> `cdd-c bind -l cobol` -> dual free-format (`generated/free/`), fixed 80-column (`generated/fixed/`), and Doxygen-complete C89 ABI shim (`src/generated/`) with automated byte-for-byte drift checks (`./scripts/generate_bindings.sh --check`).
- **Copybook-Driven `01`-Record CRUD**: Parse `.cpy` and IBM Db2 `DCLGEN` Copybooks (`AUTO`/`FIXED`/`FREE`), emit dialect-specific `CREATE TABLE` DDL, enforce level-`88` domain rules (single values and `THRU` ranges), and directly `INSERT`, `UPDATE`, `FIND`, `FIND_ALL` (into `OCCURS` arrays), and `DELETE` raw COBOL `01` Working-Storage records in ASCII, UTF-8, or EBCDIC wire formats.
- **Mainframe Financial & Character Fidelity**:
  - Lossless 38-digit fixed-point `DECIMAL` arithmetic (`add`/`sub`/`mul`/`div`/`cmp`) with all 4 rounding modes (`TRUNCATE`, `HALF_UP`, `HALF_EVEN`, `ERROR_IF_INEXACT`).
  - Direct `COMP-3` (`PACKED-DECIMAL`) bind/read on SQL statements without intermediate floating-point conversion, plus Zoned Decimal (`DISPLAY`) and 2/4/8-byte `COMP`/`COMP-5` wire codecs.
  - EBCDIC transcoding (`IBM037`, `IBM1047`, `IBM500`, `IBM1140` with Euro `U+20AC`) and UTF-16 `GRAPHIC`/`NATIONAL` (big-endian and host-endian) with strict surrogate validation.
- **Full Relational Stack**: Built-in linked SQLite + `memory://`, dynamic PostgreSQL/MySQL, Generic ODBC 3.52, and IBM Db2 CLI (`SQLSTATE`, isolation levels `UR`/`CS`/`RS`/`RR`, `SET CURRENT SCHEMA`), thread-safe connection pooling with telemetry, nested savepoints, prepared-statement LRU cache, dynamic abstract result sets, arena-backed multi-dialect SQL AST query builder, and versioned `UP`/`DOWN` SQL migrations.
- **Zero-Compromise Engineering**:
  - **100.0% test coverage** (function `150/150`, line `2330/2330`, branch `1039/1039`) across all C89 sources and generated shims via `gcovr`, plus **100.0% real execution coverage** (functions `42/42`, lines `114/114`, branches `12/12`) across both free and fixed COBOL wrapper libraries via `cobc -C -fsource-location` + `gcov -b`.
  - **100.0% doc coverage** across every C89 file/struct/enum/function/param/macro (including `src/generated/`, `Doxygen WARN_AS_ERROR=YES`) and every COBOL `.cpy`/`.cbl` file/class/field/level-88/`PROGRAM-ID`/`USING` parameter.
  - **Strong typing & universal error-enum percolation**: 7 distinct magic-tagged opaque handle structs, every C function returns `cobol_orm_error_t` with `COBOL_ORM_NO_DISCARD`, zero `(void)` return discards, zero `-Wno-*` warning suppressions, ASan + UBSan clean, and deterministic OOM fault injection.

---

## Multi-Era COBOL Compatibility Matrix

| Standard | Year | Source Format | Transport / ABI | Dialect Flags | CTest Target |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **COBOL-60** | 1960 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA | `-fixed -std=cobol85` | `cobol_era_60` |
| **COBOL-61** | 1961 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA (`PERFORM THRU`, `COMPUTATIONAL`) | `-fixed -std=cobol85` | `cobol_era_61` |
| **COBOL-61 Extended** | 1962 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA (`COMPUTE`) | `-fixed -std=cobol85` | `cobol_era_61x` |
| **COBOL-65** | 1965 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA (`OCCURS DEPENDING ON`, `INDEXED BY`) | `-fixed -std=cobol85` | `cobol_era_65` |
| **COBOL-68** | 1968 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA (`COPY`, `PERFORM VARYING`) | `-fixed -std=cobol85` | `cobol_era_68` |
| **COBOL-74** | 1974 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA (`CALL USING`, transactions) | `-fixed -std=cobol85` | `cobol_era_74` |
| **COBOL-85** | 1985 | Fixed-80 (Cols 1–72) | 552B pure `USAGE DISPLAY` COMMAREA (`EVALUATE`, `INITIALIZE`, `END-IF`) | `-fixed -std=cobol85 -Wall -Wextra -Werror` | `cobol_era_85` |
| **COBOL-2002** | 2002 | Fixed-80 (Cols 1–72) | Direct `USAGE POINTER`, `BINARY-LONG`, `BY VALUE`, `RETURNING` | `-fixed -std=cobol2002 -Wall -Wextra -Werror` | `cobol_era_2002` |
| **COBOL-2014** | 2014 | Free-Format | Direct `PACKED-DECIMAL`, Copybook `01`-Record CRUD, AST SQL | `-free -std=cobol2014 -Wall -Wextra -Werror` | `cobol_era_2014` |
| **COBOL-2023** | 2023 | Free-Format | Full `cobol_orm_lib.cbl` + Pool + 38-Digit Decimal + EBCDIC + Abstract RS | `-free -Wall -Wextra -Werror` | `cobol_era_2023` |
| **IBM Enterprise** | — | Fixed-80 (Cols 1–72) | `cobol_orm_ibm.cpy` (`COMP-5`, `COMP-2`, `USAGE POINTER`) + `cobol_orm_lib.cbl` | `-fixed -std=ibm-strict -Wall -Wextra -Werror` | `cobol_ibm_strict_syntax` & `example_fixed_migrations_pool` |
| **Micro Focus** | — | Fixed-80 (Cols 1–72) | `cobol_orm_ibm.cpy` / `cobol_orm.cpy` + `cobol_orm_lib.cbl` | `-fixed -std=mf-strict -Wall -Wextra -Werror` | `cobol_mf_strict_syntax` |

---

## Quickstart

### Build & Run All 34 Verification Tests

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --parallel 4
ctest --test-dir build --output-on-failure
```

Regenerate or drift-check `cdd-c` COBOL bindings:

```sh
./scripts/generate_bindings.sh          # Regenerate ffi/, generated/free, generated/fixed, src/generated
./scripts/generate_bindings.sh --check  # Fail if committed bindings drift from live cdd-c output
```

### Free-Format COBOL-2014/2023 Example

```cobol
>>SOURCE FORMAT IS FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. HELLO-CORM.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
01 WS-URL PIC X(256) VALUE "sqlite://:memory:".
01 WS-SQL PIC X(1024) VALUE "CREATE TABLE ACCOUNTS (ID INT PRIMARY KEY, BAL TEXT)".
PROCEDURE DIVISION.
    CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    STOP RUN RETURNING 0.
END PROGRAM HELLO-CORM.
```

### Strict Fixed-80 IBM Enterprise COBOL Example

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. IBM-CORM.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_ibm.cpy".
       01 WS-URL                       PIC X(256)
                                       VALUE "sqlite://:memory:".
       01 WS-SQL                       PIC X(1024)
                                       VALUE "CREATE TABLE T1 (ID INT)".
       PROCEDURE DIVISION.
           CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           STOP RUN.
       END PROGRAM IBM-CORM.
```

### Historical COBOL-60..COBOL-85 Example

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LEGACY-ORM.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK STOP RUN.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE HIST (ID INT)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           STOP RUN.
```

---

## Feature Matrix (Modules A–L)

| Module | C89 Source | Primary Capabilities |
| :--- | :--- | :--- |
| **A — Connections & Diagnostics** | [`src/cobol_orm_db.c`](src/cobol_orm_db.c) | `connect`, `disconnect`, `exec_sql`, `last_error`, `last_trace`, `last_insert_rowid`, `enable_stmt_cache`, `set_timezone`, `set_slow_query_ms`, `version`, `error_name` |
| **B — Connection Pooling** | [`src/cobol_orm_pool.c`](src/cobol_orm_pool.c) | Bounded thread-safe pool (`init`, `acquire`, `release`, `telemetry`, `destroy`) with timeout enforcement |
| **C — Transactions & Savepoints** | [`src/cobol_orm_tx.c`](src/cobol_orm_tx.c) | `begin`, `commit`, `rollback`, named `savepoint`, `release_sp`, `rollback_sp` |
| **D — Prepared & Cached Statements** | [`src/cobol_orm_stmt.c`](src/cobol_orm_stmt.c) | Prepared & LRU-cached statements, typed binds (`i32`/`i64`/`f64`/`str`/`blob`/`decimal`/`comp3`/`null`), `step`/`reset`/`finalize`, typed column readers including direct `col_comp3` |
| **E — Abstract Result Sets** | [`src/cobol_orm_abstract.c`](src/cobol_orm_abstract.c) | Schema-less `query_abstract` with dynamic row/col counts, column names, variant types, and named getters |
| **F — Fluent SQL AST Builder** | [`src/cobol_orm_query.c`](src/cobol_orm_query.c) | Arena-backed `SELECT`/`DISTINCT`/`INSERT`/`UPDATE`/`DELETE`/`JOIN`/`WHERE`/`GROUP BY`/`ORDER BY`/`LIMIT`/`OFFSET`/Db2 `WITH UR/CS/RS/RR` rendered across 5 SQL dialects + live `ast_exec` |
| **G — 38-Digit Decimal & Codecs** | [`src/cobol_orm_decimal.c`](src/cobol_orm_decimal.c) | Exact 38-digit `from_str`/`to_str`/`add`/`sub`/`mul`/`div`/`cmp`, `COMP-3`, Zoned Decimal (ASCII & EBCDIC), 2/4/8B `COMP`/`COMP-5` |
| **H — EBCDIC & UTF-16 GRAPHIC** | [`src/cobol_orm_ebcdic.c`](src/cobol_orm_ebcdic.c) | `IBM037`, `IBM1047`, `IBM500`, `IBM1140` transcoding and big/little-endian UTF-16 `GRAPHIC`/`NATIONAL` |
| **I — Copybook `.cpy` CRUD** | [`src/cobol_orm_copybook.c`](src/cobol_orm_copybook.c) | `.cpy`/DCLGEN parsing, layout introspection, PK override, DDL emission, table creation, level-`88` validation, direct `01`-record `insert`/`update`/`find_i32`/`find_all`/`delete_i32` |
| **J — Schema Migrations** | [`src/cobol_orm_migrations.c`](src/cobol_orm_migrations.c) | Versioned `-- UP` / `-- DOWN` SQL migration runner with dry-run support |
| **K — IBM Db2 & ODBC Helpers** | [`src/cobol_orm_enterprise.c`](src/cobol_orm_enterprise.c) | 5-character `SQLSTATE`, Db2 isolation level (`UR`/`CS`/`RS`/`RR`), `SET CURRENT SCHEMA` |
| **L — Legacy COMMAREA Bridge** | [`src/cobol_orm_legacy.c`](src/cobol_orm_legacy.c) | 64-slot integer handle table, 544B binary `commarea_dispatch`, 552B endian-independent `display_dispatch`, `legacy_reset` |

---

## CMake Build Options

| Option | Default | Description |
| :--- | :--- | :--- |
| `BUILD_SHARED_LIBS` | `OFF` | Build `cobol_orm_c` as a shared library (`cobol_orm_ffi` is always shared for `cobc` / `COB_PRE_LOAD`) |
| `COBOL_ORM_BUILD_TESTS` | `ON` | Build and register C89, ABI layout, 10-era COBOL, E2E free/fixed, and IBM/MF syntax tests in CTest |
| `COBOL_ORM_BUILD_EXAMPLES` | `ON` | Build and register all 17 free & fixed runnable COBOL examples in CTest |
| `COBOL_ORM_BUILD_FREE` | `ON` | Build free-format COBOL library, tests, and examples |
| `COBOL_ORM_BUILD_FIXED` | `ON` | Build strict fixed 80-column COBOL library, tests, examples, and IBM/MF dialect checks |
| `COBOL_ORM_ENABLE_COVERAGE` | `OFF` | Instrument `cobol_orm_c` and `test_cobol_orm_c` with `--coverage -O0 -g` (deps excluded) |
| `COBOL_ORM_ENABLE_ASAN` | `OFF` | Enable `-fsanitize=address,undefined` on `cobol-orm` targets |
| `COBOL_ORM_C_ORM_DIR` | `../c-orm` (auto) | Local path to `c-orm`; falls back to `FetchContent` when omitted/absent |
| `C_ORM_SQLITE` | `LINKED` | SQLite backend mode (`LINKED`, `DYNAMIC`, `OFF`) |
| `C_ORM_POSTGRESQL` / `C_ORM_MYSQL` | `DYNAMIC` | PostgreSQL / MySQL backend mode (`LINKED`, `DYNAMIC`, `OFF`) |
| `C_ORM_ENABLE_ODBC` / `C_ORM_ENABLE_DB2` | `ON` | Enable Generic ODBC 3.52 & IBM Db2 CLI backends |

---

## Runnable Examples

All modern examples exist in **both** free-format (`examples/free/`) and strict fixed 80-column format (`examples/fixed/`, verified under `-std=ibm-strict` and `-std=mf-strict`), plus a dedicated COBOL-60..85 pure `USAGE DISPLAY` COMMAREA batch example — all 17 examples are built and verified in CTest:

| Example | Free-Format | Fixed 80-Column | Demonstrates |
| :--- | :--- | :--- | :--- |
| Quickstart CRUD | [`examples/free/quickstart_crud.cbl`](examples/free/quickstart_crud.cbl) | [`examples/fixed/quickstart_crud.cbl`](examples/fixed/quickstart_crud.cbl) | Copybook parsing, table creation, `01`-record `COMP-3` insert, find, delete |
| Banking Ledger | [`examples/free/banking_ledger.cbl`](examples/free/banking_ledger.cbl) | [`examples/fixed/banking_ledger.cbl`](examples/fixed/banking_ledger.cbl) | Transactions, savepoints, rollback-to-savepoint, 38-digit decimal math, `IBM037` EBCDIC |
| Query Builder | [`examples/free/query_builder_demo.cbl`](examples/free/query_builder_demo.cbl) | [`examples/fixed/query_builder_demo.cbl`](examples/fixed/query_builder_demo.cbl) | Arena-backed fluent AST with Db2 `WITH UR` isolation lock and multi-dialect SQL rendering |
| Migrations & Pool | [`examples/free/migrations_and_pool.cbl`](examples/free/migrations_and_pool.cbl) | [`examples/fixed/migrations_and_pool.cbl`](examples/fixed/migrations_and_pool.cbl) (`-std=ibm-strict`) | Connection pool init/acquire/telemetry/release/destroy, stmt cache, and versioned `UP`/`DOWN` SQL migrations |
| Prepared Statements | [`examples/free/prepared_statements.cbl`](examples/free/prepared_statements.cbl) | [`examples/fixed/prepared_statements.cbl`](examples/fixed/prepared_statements.cbl) (`-std=ibm-strict`) | LRU-cached prepared statements, typed binds (`INT32`, `PIC X`, direct `COMP-3`, `NULL`), `reset`/reuse, `last_insert_rowid`, and direct `COMP-3` cursor reads |
| Abstract Result Set | [`examples/free/abstract_result_set.cbl`](examples/free/abstract_result_set.cbl) | [`examples/fixed/abstract_result_set.cbl`](examples/fixed/abstract_result_set.cbl) (`-std=ibm-strict`) | Live fluent AST `INSERT`/`UPDATE` execution (`ast_exec`) + schema-less `query_abstract` row/column metadata, variant types, and named getters |
| Copybook Batch & DCLGEN | [`examples/free/copybook_batch_validation.cbl`](examples/free/copybook_batch_validation.cbl) | [`examples/fixed/copybook_batch_validation.cbl`](examples/fixed/copybook_batch_validation.cbl) (`-std=ibm-strict`) | IBM Db2 `EXEC SQL DECLARE` DCLGEN parsing, layout introspection, multi-dialect DDL emission, level-`88` `THRU` validation, `update`, and `OCCURS` batch hydration (`find_all`) |
| Mainframe Codecs & COMMAREA | [`examples/free/mainframe_codecs_and_commarea.cbl`](examples/free/mainframe_codecs_and_commarea.cbl) | [`examples/fixed/mainframe_codecs_and_commarea.cbl`](examples/fixed/mainframe_codecs_and_commarea.cbl) (`-std=ibm-strict`) | 38-digit decimal `mul`/`div`/`cmp` (`HALF_EVEN`), EBCDIC Zoned Decimal & big-endian `COMP` codecs, `IBM1047` & UTF-16 `GRAPHIC` round-trips, and 544B `CORM-COMMAREA` |
| Legacy Payroll Batch (COBOL-60..85) | — | [`examples/fixed/legacy_commarea_payroll.cbl`](examples/fixed/legacy_commarea_payroll.cbl) (`-std=cobol85`) | Endian-independent 552B pure `USAGE DISPLAY` `COMMAREA` transactional batch insert & cursor query with zero `USAGE POINTER` or `BY VALUE` |

---

## Quality Gates & Verification

| Gate | Command | Requirement |
| :--- | :--- | :--- |
| Full CTest Suite (34 tests) | `ctest --test-dir build --output-on-failure` | 34/34 passing (C89, ABI, 10 eras, E2E, IBM/MF strict, 17 examples) |
| C89 Coverage (100%) | `gcovr --gcov-executable "xcrun llvm-cov gcov" -r . --filter 'src/.*\.c' --fail-under-line 100 --fail-under-branch 100 --fail-under-function 100 build-cov` | 100.0% fn (`150/150`), 100.0% line (`2330/2330`), 100.0% branch (`1039/1039`) |
| COBOL Coverage (100%) | `python3 scripts/check_cobol_coverage.py --build-dir build` | 100.0% fn (`42/42`), 100.0% line (`114/114`), 100.0% branch (`12/12`), 10/10 eras |
| Documentation Coverage (100%) | `python3 scripts/generate_undercovered.py --doc` | Zero Doxygen warnings (incl. `src/generated/`) + zero COBOL doc gaps |
| Strong Typing & Linters | `pre-commit run --all-files` | `clang-format`, `cppcheck`, `libclang` enum-return & no-discard checks, fixed-80 margins, binding drift, `cobc` strict syntax |
| Memory & UB Safety | `cmake -S . -B build-asan -DCOBOL_ORM_ENABLE_ASAN=ON && cmake --build build-asan --target test_cobol_orm_c && ctest --test-dir build-asan -R c89` | Zero leaks, zero undefined behavior |

---

## Repository Layout

```text
cobol-orm/
├── CMakeLists.txt                   # Multi-target C89 + GnuCOBOL build, CTest, package export & pkg-config
├── Doxyfile.in                      # Strict Doxygen config (WARN_AS_ERROR=YES, zero exclusions)
├── include/                         # Public C89 FFI headers (cobol_orm_{export,error,types,ffi}.h)
├── src/                             # ISO C89 FFI facade modules (A-L) + src/generated/ ABI shim
├── ffi/cobol_orm_ffi.json           # Normalized libclang FFI IR consumed by cdd-c
├── generated/{free,fixed}/          # Reproducible cdd-c generated .cpy, .cbl, and ABI layout tests
├── copybooks/{free,fixed,era}/      # Idiomatic error/type/IBM-Enterprise & 552B DISPLAY Copybooks
├── cobol/{free,fixed}/              # 21-subprogram CORM-* wrapper library (free + IBM-strict fixed-80)
├── cobol/era/cobol60..cobol2023/    # 10-standard COBOL verification suites (COBOL-60 .. COBOL-2023)
├── examples/{free,fixed,migrations}/# 17 runnable free & fixed COBOL examples + sample SQL migrations
├── tests/{c,cobol}/                 # C89 unit/ABI/OOM suite (greatest.h) + free/fixed COBOL E2E suites
├── scripts/                         # Codegen, fixed-80 converter, real coverage, doc, clang-lint & shield scripts
└── docs/                            # Detailed API, Copybook CRUD, Enterprise Fixed-80, Error & Memory guides
```

---

## Documentation Index

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — 4-layer architecture, Mermaid diagrams, ABI contracts, handle lifecycle, and codegen pipeline
- [`USAGE.md`](USAGE.md) — Complete build, link, dialect, `CORM-*` wrapper, Copybook CRUD, and legacy `COMMAREA` handbook
- [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md) — Complete Modules A–L function and `CORM-*` subprogram reference
- [`docs/COBOL_COPYBOOK_CRUD.md`](docs/COBOL_COPYBOOK_CRUD.md) — `.cpy`/DCLGEN parsing, DDL, level-`88`, and `01`-record CRUD
- [`docs/FIXED_80_ENTERPRISE.md`](docs/FIXED_80_ENTERPRISE.md) — Fixed-80 margins, IBM Enterprise (`-std=ibm-strict`), Micro Focus, Db2, ODBC, EBCDIC, and UTF-16
- [`docs/ERRORS.md`](docs/ERRORS.md) — Complete `cobol_orm_error_t` (`0..36`) and COBOL level-`88` predicate table
- [`docs/MEMORY.md`](docs/MEMORY.md) — Handle ownership, deterministic OOM safety, and ASan/UBSan verification

---

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <https://www.apache.org/licenses/Apache-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <https://opensource.org/licenses/MIT>)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
