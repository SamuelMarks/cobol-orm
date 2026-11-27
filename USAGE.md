# `cobol-orm` Usage Guide

This guide covers building, installing, linking, and writing applications with **`cobol-orm`** across **Free-Format modern COBOL (`COBOL-2014` / `COBOL-2023`)**, **Strict Fixed 80-Column Enterprise COBOL (`IBM Enterprise`, `Micro Focus`, `COBOL-2002`)**, and **Historical COBOL (`COBOL-60` through `COBOL-85`)**.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Building, Testing & Installing](#2-building-testing--installing)
3. [Linking COBOL Programs](#3-linking-cobol-programs)
4. [Free-Format Modern COBOL (`COBOL-2014` / `COBOL-2023`)](#4-free-format-modern-cobol-cobol-2014--cobol-2023)
   - [4.1 Connections, Transactions & Savepoints](#41-connections-transactions--savepoints)
   - [4.2 Prepared & Cached Statements with Direct `COMP-3` Binding](#42-prepared--cached-statements-with-direct-comp-3-binding)
   - [4.3 Copybook-Driven `01`-Record CRUD & Level-88 Validation](#43-copybook-driven-01-record-crud--level-88-validation)
   - [4.4 Fluent Multi-Dialect SQL AST Query Builder](#44-fluent-multi-dialect-sql-ast-query-builder)
   - [4.5 Dynamic Schema-Less Abstract Result Sets](#45-dynamic-schema-less-abstract-result-sets)
   - [4.6 38-Digit Fixed-Point Decimals, EBCDIC & UTF-16 `GRAPHIC`](#46-38-digit-fixed-point-decimals-ebcdic--utf-16-graphic)
   - [4.7 Connection Pooling & Versioned Schema Migrations](#47-connection-pooling--versioned-schema-migrations)
   - [4.8 IBM Db2 & Generic ODBC 3.52 Helpers](#48-ibm-db2--generic-odbc-352-helpers)
5. [Strict Fixed 80-Column Enterprise COBOL (`IBM` / `Micro Focus` / `COBOL-2002`)](#5-strict-fixed-80-column-enterprise-cobol-ibm--micro-focus--cobol-2002)
6. [Historical COBOL (`COBOL-60` .. `COBOL-85`) `COMMAREA` Protocol](#6-historical-cobol-cobol-60--cobol-85-commarea-protocol)
7. [Consuming from CMake & `pkg-config`](#7-consuming-from-cmake--pkg-config)
8. [Regenerating Bindings & Running Quality Gates](#8-regenerating-bindings--running-quality-gates)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. Prerequisites

| Tool | Required For | Notes |
| :--- | :--- | :--- |
| **CMake >= 3.10** | Building C89 libraries & CTest | Uses modern `target_*` APIs |
| **ISO C89 Compiler** | Building `cobol_orm_c` / `cobol_orm_ffi` | Clang, GCC, or MSVC |
| **GnuCOBOL >= 3.2 (`cobc`)** | Compiling COBOL wrappers, tests & examples | Optional if consuming C89 FFI headers only |
| **`cdd-c`** | Regenerating bindings (`generate_bindings.sh`) | Discovered via `COBOL_ORM_CDD_C_BIN`, `../cdd-c/bin/cdd-c`, or `PATH` |
| **Python 3 + `libclang`, `doxygen`, `cppcheck`, `gcovr`, `clang-format`** | Running lint, 100% doc, and 100% coverage gates | Installed automatically in CI |

---

## 2. Building, Testing & Installing

### Standard Build & Full 25-Test Suite

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build --parallel 4
ctest --test-dir build --output-on-failure
```

### Shared Library Build (`BUILD_SHARED_LIBS=ON`)

```sh
cmake -S . -B build-shared -DBUILD_SHARED_LIBS=ON
cmake --build build-shared --parallel 4
ctest --test-dir build-shared --output-on-failure
```

### Coverage Build (100% C89 Function/Line/Branch)

```sh
cmake -S . -B build-cov -DCOBOL_ORM_ENABLE_COVERAGE=ON
cmake --build build-cov --parallel 4 --target test_cobol_orm_c
ctest --test-dir build-cov -R c89_unit_and_oom_suite --output-on-failure
# macOS (AppleClang):
gcovr --gcov-executable "xcrun llvm-cov gcov" -r . --filter 'src/.*\.c' \
  --fail-under-line 100 --fail-under-branch 100 --fail-under-function 100 build-cov
# Linux (GCC):
gcovr -r . --filter 'src/.*\.c' \
  --fail-under-line 100 --fail-under-branch 100 --fail-under-function 100 build-cov
```

### AddressSanitizer + UndefinedBehaviorSanitizer Build

```sh
cmake -S . -B build-asan -DCOBOL_ORM_ENABLE_ASAN=ON
cmake --build build-asan --parallel 4 --target test_cobol_orm_c
ctest --test-dir build-asan -R c89_unit_and_oom_suite --output-on-failure
```

### Installing Locally

```sh
cmake --install build --prefix /usr/local
```

This installs:
- Libraries: `libcobol_orm.{a,so,dylib}`, `libcobol_orm_ffi.{so,dylib}`
- Public C headers: `include/cobol_orm_{export,error,types,ffi}.h`
- Copybooks & COBOL sources: `share/cobol-orm/{copybooks,cobol,generated}/`
- CMake package files: `lib/cmake/cobol-orm/cobol-orm-{config,config-version,targets}.cmake`
- pkg-config metadata: `lib/pkgconfig/cobol-orm.pc`

---

## 3. Linking COBOL Programs

### Option A — Direct Link-Time Binding (Recommended)

Link your compiled COBOL program with the prebuilt COBOL wrapper object (`cobol_orm_lib_free.o` or `cobol_orm_lib_fixed.o`) and `libcobol_orm_ffi`:

```sh
# macOS (Free-Format)
cobc -x -free -Wall -Wextra -Werror \
  -I copybooks/free \
  my_app.cbl \
  build/cobol_modules/cobol_orm_lib_free.o \
  build/libcobol_orm_ffi.dylib \
  -Q -Wl,-rpath,build \
  -o my_app

# Linux (Free-Format)
cobc -x -free -Wall -Wextra -Werror \
  -I copybooks/free \
  my_app.cbl \
  build/cobol_modules/cobol_orm_lib_free.o \
  build/libcobol_orm_ffi.so \
  -Q -Wl,-rpath,'$ORIGIN/build' \
  -o my_app
```

### Option B — Dynamic Runtime Preload (`COB_PRE_LOAD`)

When compiling COBOL executables without link-time C library references, preload `libcobol_orm_ffi` at runtime:

```sh
cobc -x -free -I copybooks/free my_app.cbl build/cobol_modules/cobol_orm_lib_free.o -o my_app
COB_PRE_LOAD=build/libcobol_orm_ffi.dylib ./my_app
```

---

## 4. Free-Format Modern COBOL (`COBOL-2014` / `COBOL-2023`)

Include the umbrella Copybook `COPY "cobol_orm.cpy".` from `copybooks/free/`. It provides:
- `C-ORM-STATUS` with all 37 level-`88` condition predicates (`C-ORM-OK` through `C-ORM-ERR-INV-OP`)
- Distinct pointer handles (`C-ORM-DB-PTR`, `C-ORM-STMT-PTR`, `C-ORM-POOL-PTR`, `C-ORM-AST-PTR`, `C-ORM-CPY-PTR`, `C-ORM-RS-PTR`, `C-ORM-MIG-PTR`)
- Domain enum selectors (`C-ORM-DIALECT`, `C-ORM-ROUND-MODE`, `C-ORM-CODEPAGE`, `C-ORM-CPY-FMT`, `C-ORM-ISOLATION`, `C-ORM-JOIN-KIND`)
- Exact-size POD records (`C-ORM-DECIMAL-REC`, `C-ORM-POOL-STATS-REC`, `C-ORM-CPY-INFO-REC`, `C-ORM-COL-INFO-REC`, `C-ORM-COMMAREA-REC`)

### 4.1 Connections, Transactions & Savepoints

```cobol
>>SOURCE FORMAT IS FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. DEMO-TX.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
01 WS-URL      PIC X(256)  VALUE "sqlite://:memory:".
01 WS-SQL      PIC X(1024) VALUE SPACES.
01 WS-SP       PIC X(32)   VALUE "BEFORE_FEE".
01 WS-ERR-MSG  PIC X(256)  VALUE SPACES.
01 WS-ERR-LEN  USAGE BINARY-LONG UNSIGNED VALUE 0.
PROCEDURE DIVISION.
    CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF

    MOVE "CREATE TABLE LEDGER (ID INT PRIMARY KEY, AMT TEXT)" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL

    CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    MOVE "INSERT INTO LEDGER VALUES (1, '500.00')" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL

    CALL "CORM-TX-SAVEPOINT" USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
    END-CALL
    MOVE "INSERT INTO LEDGER VALUES (2, 'BAD_FEE')" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    CALL "CORM-TX-RB-SP" USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
    END-CALL
    CALL "CORM-TX-REL-SP" USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
    END-CALL
    CALL "CORM-TX-COMMIT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL

    IF NOT C-ORM-OK
        CALL "CORM-LAST-ERROR"
            USING C-ORM-DB-PTR WS-ERR-MSG WS-ERR-LEN C-ORM-STATUS
        END-CALL
        DISPLAY "ERROR: " WS-ERR-MSG(1:WS-ERR-LEN)
        END-DISPLAY
    END-IF

    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    STOP RUN RETURNING 0.
END PROGRAM DEMO-TX.
```

> **Supported connection URLs**: `sqlite://:memory:`, `sqlite:///path/to/file.db`, `memory://`, `postgres://user:pass@host/db`, `mysql://user:pass@host/db`, `odbc://DSN=...`, `db2://DATABASE=...`.

### 4.2 Prepared & Cached Statements with Direct `COMP-3` Binding

Enable LRU statement caching with `cobol_orm_enable_stmt_cache(db, capacity)`, prepare with `cobol_orm_stmt_prepare` or `cobol_orm_stmt_prepare_cached`, and bind/read COBOL `PACKED-DECIMAL` (`COMP-3`) fields losslessly:

```cobol
*> Bind a native PIC S9(7)V99 COMP-3 field directly to parameter ?1
*> byte_len = 5 bytes, frac_digits = 2
CALL "cobol_orm_stmt_bind_comp3"
    USING BY VALUE C-ORM-STMT-PTR
          BY VALUE WS-PARAM-IDX
          BY REFERENCE WS-COMP3-AMT
          BY VALUE WS-COMP3-BYTES
          BY VALUE WS-FRAC-DIGITS
    RETURNING C-ORM-STATUS
END-CALL

*> Read SQL column 0 directly back into a COBOL COMP-3 field
SET C-ORM-RND-HALF-EVEN TO TRUE
CALL "cobol_orm_stmt_col_comp3"
    USING BY VALUE C-ORM-STMT-PTR
          BY VALUE WS-COL-IDX
          BY VALUE WS-INT-DIGITS
          BY VALUE WS-FRAC-DIGITS
          BY VALUE WS-IS-SIGNED
          BY VALUE C-ORM-ROUND-MODE
          BY REFERENCE WS-OUT-COMP3
          BY VALUE WS-OUT-CAP
          BY REFERENCE WS-OUT-WRITTEN
    RETURNING C-ORM-STATUS
END-CALL
```

### 4.3 Copybook-Driven `01`-Record CRUD & Level-88 Validation

Pass any native COBOL `01` Working-Storage record directly to SQLite, PostgreSQL, MySQL, Db2, or ODBC (see [`examples/free/quickstart_crud.cbl`](examples/free/quickstart_crud.cbl) and [`docs/COBOL_COPYBOOK_CRUD.md`](docs/COBOL_COPYBOOK_CRUD.md)):

1. Parse schema with `cobol_orm_cpy_parse_str` or `cobol_orm_cpy_parse_file` (`C-ORM-FMT-AUTO`, `C-ORM-FMT-FIXED`, or `C-ORM-FMT-FREE`).
2. Optionally override the primary key with `cobol_orm_cpy_set_pk`.
3. Create the table via `cobol_orm_cpy_create_table` (or inspect DDL via `cobol_orm_cpy_emit_ddl`).
4. Validate level-`88` values and `THRU` ranges via `cobol_orm_cpy_validate_88` (also enforced automatically on `insert` and `update`).
5. Persist and hydrate directly using `cobol_orm_cpy_insert`, `cobol_orm_cpy_update`, `cobol_orm_cpy_find_i32`, `cobol_orm_cpy_find_all` (into a contiguous COBOL `OCCURS` table), and `cobol_orm_cpy_delete_i32`.
6. Free the parsed Copybook handle with `cobol_orm_cpy_free`.

### 4.4 Fluent Multi-Dialect SQL AST Query Builder

Build one SQL AST and render it cleanly for `C-ORM-DL-SQLITE`, `C-ORM-DL-POSTGRES`, `C-ORM-DL-MYSQL`, `C-ORM-DL-DB2`, or `C-ORM-DL-ODBC` (see [`examples/free/query_builder_demo.cbl`](examples/free/query_builder_demo.cbl)):

- Lifecycle: `cobol_orm_ast_new` -> `cobol_orm_ast_free`
- Statements: `cobol_orm_ast_select`, `cobol_orm_ast_distinct`, `cobol_orm_ast_from`, `cobol_orm_ast_insert_into`, `cobol_orm_ast_update_table`, `cobol_orm_ast_delete_from`
- Clauses: `cobol_orm_ast_set_col`, `cobol_orm_ast_where_eq`, `cobol_orm_ast_join`, `cobol_orm_ast_group_by`, `cobol_orm_ast_order_by`, `cobol_orm_ast_limit_offset`, `cobol_orm_ast_with_lock` (IBM Db2 `WITH UR`/`CS`/`RS`/`RR`)
- Output/Execution: `cobol_orm_ast_to_sql` or live `cobol_orm_ast_exec`

### 4.5 Dynamic Schema-Less Abstract Result Sets

For ad-hoc SQL queries without a compile-time Copybook schema (see [`cobol/era/cobol2023/corm_era2023.cbl`](cobol/era/cobol2023/corm_era2023.cbl)):

- `cobol_orm_query_abstract(db, sql, sql_len, out_rs)`
- Inspect dimensions with `cobol_orm_rs_row_count`, `cobol_orm_rs_col_count`, `cobol_orm_rs_col_name`, `cobol_orm_rs_get_type`
- Read values by column name with `cobol_orm_rs_get_i64`, `cobol_orm_rs_get_f64`, `cobol_orm_rs_get_str`
- Free with `cobol_orm_rs_free(rs)`

### 4.6 38-Digit Fixed-Point Decimals, EBCDIC & UTF-16 `GRAPHIC`

- **Exact 38-Digit Math**: `cobol_orm_dec_from_str`, `cobol_orm_dec_to_str`, `cobol_orm_dec_add`, `cobol_orm_dec_sub`, `cobol_orm_dec_mul`, `cobol_orm_dec_div`, `cobol_orm_dec_cmp`, `cobol_orm_dec_to_comp3`, `cobol_orm_dec_from_comp3`, `cobol_orm_dec_to_zoned`, `cobol_orm_dec_from_zoned`, `cobol_orm_i64_to_comp`, `cobol_orm_i64_from_comp`.
- **EBCDIC Codepages**: Set `C-ORM-CP-IBM037-V`, `C-ORM-CP-IBM1047-V`, `C-ORM-CP-IBM500-V`, or `C-ORM-CP-IBM1140-V` (Euro) and call `cobol_orm_utf8_to_ebcdic` / `cobol_orm_ebcdic_to_utf8`.
- **UTF-16 `GRAPHIC`/`NATIONAL`**: Call `cobol_orm_utf8_to_utf16` / `cobol_orm_utf16_to_utf8` with `big_endian = 1` (IBM z/OS `PIC N`) or `0` (native).

### 4.7 Connection Pooling & Versioned Schema Migrations

Use the idiomatic `CORM-POOL-*` and `CORM-MIG-*` wrappers from `cobol_orm_lib.cbl` (see [`examples/free/migrations_and_pool.cbl`](examples/free/migrations_and_pool.cbl)):

- **Pool**: `CORM-POOL-INIT` -> `CORM-POOL-ACQUIRE` -> `CORM-POOL-STATS` -> `CORM-POOL-RELEASE` -> `CORM-POOL-DESTROY`
- **Migrations**: Place `.sql` files with `-- UP` and `-- DOWN` sections in a directory (see [`examples/migrations/001_create_audit_log.sql`](examples/migrations/001_create_audit_log.sql)), then run:
  `CORM-MIG-INIT` -> `CORM-MIG-UP` (with `dry_run = 0` or `1`) -> `CORM-MIG-DOWN` -> `CORM-MIG-FREE`.

### 4.8 IBM Db2 & Generic ODBC 3.52 Helpers

- `cobol_orm_odbc_sqlstate(db, out_state, cap, out_len)` — reads 5-byte ANSI/ODBC `SQLSTATE`
- `cobol_orm_db2_set_isolation(db, iso)` — configures `UR`, `CS`, `RS`, or `RR`
- `cobol_orm_db2_set_schema(db, schema, schema_len)` — executes `SET CURRENT SCHEMA`

---

## 5. Strict Fixed 80-Column Enterprise COBOL (`IBM` / `Micro Focus` / `COBOL-2002`)

Every file in `copybooks/fixed/`, `cobol/fixed/`, `generated/fixed/`, `copybooks/era/`, `cobol/era/cobol60..cobol2002/`, `tests/cobol/test_e2e_fixed.cbl`, and `examples/fixed/` obeys strict column 1–72 margins.

### Choosing the Right Fixed-80 Copybook

| Target Compiler / Dialect | Copybook to `COPY` | Numeric Types Used | Verification Flag |
| :--- | :--- | :--- | :--- |
| **IBM Enterprise COBOL** | `copybooks/fixed/cobol_orm_ibm.cpy` | `PIC S9(9) COMP-5`, `PIC 9(9) COMP-5`, `COMP-2`, `PIC X(1)`, `USAGE POINTER` | `cobc -fixed -std=ibm-strict -Wall -Wextra -Werror` |
| **Micro Focus COBOL** | `copybooks/fixed/cobol_orm_ibm.cpy` or `cobol_orm.cpy` | `COMP-5` or `BINARY-LONG`, `USAGE POINTER` | `cobc -fixed -std=mf-strict -Wall -Wextra -Werror` |
| **ISO COBOL-2002 Fixed** | `copybooks/fixed/cobol_orm.cpy` | `USAGE BINARY-LONG`, `USAGE FLOAT-LONG`, `USAGE POINTER` | `cobc -fixed -std=cobol2002 -Wall -Wextra -Werror` |

Compile an IBM-strict Enterprise COBOL program with:

```sh
cobc -x -fixed -std=ibm-strict -Wall -Wextra -Werror \
  -I copybooks/fixed \
  examples/fixed/migrations_and_pool.cbl \
  build/cobol_modules/cobol_orm_lib_fixed.o \
  build/libcobol_orm_ffi.dylib \
  -Q -Wl,-rpath,build \
  -o migrations_and_pool
```

Verify fixed-80 column compliance across your own files:

```sh
python3 scripts/free_to_fixed80.py --verify my_fixed_dir/
```

---

## 6. Historical COBOL (`COBOL-60` .. `COBOL-85`) `COMMAREA` Protocol

Historical COBOL compilers prior to COBOL-2002 lack `USAGE POINTER`, `BY VALUE`, and uniform binary endianness. `cobol-orm` solves this with [`copybooks/era/cobol_orm_display_ca.cpy`](copybooks/era/cobol_orm_display_ca.cpy) — a **552-byte pure `USAGE DISPLAY` ASCII communication block** dispatched via `CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA`.

### 6.1 Byte-by-Byte `CORM-DISP-COMMAREA` Layout (552 Bytes)

| Offset | Length | COBOL Field | `PIC` | Description |
| ---: | ---: | :--- | :--- | :--- |
| `0` | `4` | `CORM-CA-OPCODE` | `PIC 9(4)` | Requested operation code (`0001`..`0016`) |
| `4` | `4` | `CORM-CA-STATUS` | `PIC 9(4)` | Output `cobol_orm_error_t` (`0000` = `CORM-ST-OK`) |
| `8` | `4` | `CORM-CA-DB-ID` | `PIC 9(4)` | Integer DB handle slot (`0001`..`0064`) |
| `12` | `4` | `CORM-CA-STMT-ID` | `PIC 9(4)` | Integer statement handle slot (`0001`..`0064`) |
| `16` | `4` | `CORM-CA-PARAM-IDX` | `PIC 9(4)` | 1-based bind parameter or 0-based result column index |
| `20` | `1` | `CORM-CA-VAL-SIGN` | `PIC X` | Explicit ASCII sign (`"+"` or `"-"`) |
| `21` | `11` | `CORM-CA-VAL-NUM` | `PIC 9(11)` | Unsigned magnitude for 32-bit integer I/O or row flag |
| `32` | `4` | `CORM-CA-D1-LEN` | `PIC 9(4)` | Active length in `CORM-CA-DATA1` (`0000` = auto-trim trailing spaces) |
| `36` | `4` | `CORM-CA-D2-LEN` | `PIC 9(4)` | Output payload byte length written to `CORM-CA-DATA2` |
| `40` | `256` | `CORM-CA-DATA1` | `PIC X(256)` | Input payload (URL, SQL, string bind parameter) |
| `296` | `256` | `CORM-CA-DATA2` | `PIC X(256)` | Output payload (fetched column text, last error, version) |

### 6.2 Supported Opcodes (`0001`–`0016`)

| Opcode | Level-88 Condition | Inputs | Outputs |
| ---: | :--- | :--- | :--- |
| `1` | `CORM-OP-CONNECT` | `DATA1` (URL) | `DB-ID`, `STATUS` |
| `2` | `CORM-OP-DISCONN` | `DB-ID` | `STATUS` |
| `3` | `CORM-OP-EXEC-SQL` | `DB-ID`, `DATA1` (SQL) | `STATUS` |
| `4` | `CORM-OP-TX-BEG` | `DB-ID` | `STATUS` |
| `5` | `CORM-OP-TX-CMT` | `DB-ID` | `STATUS` |
| `6` | `CORM-OP-TX-RBK` | `DB-ID` | `STATUS` |
| `7` | `CORM-OP-PREPARE` | `DB-ID`, `DATA1` (SQL) | `STMT-ID`, `STATUS` |
| `8` | `CORM-OP-BIND-I32` | `STMT-ID`, `PARAM-IDX` (1-based), `VAL-SIGN`/`VAL-NUM` | `STATUS` |
| `9` | `CORM-OP-BIND-STR` | `STMT-ID`, `PARAM-IDX` (1-based), `DATA1` | `STATUS` |
| `10` | `CORM-OP-STEP` | `STMT-ID` | `VAL-NUM` (`1` = row, `0` = done), `STATUS` |
| `11` | `CORM-OP-COL-I32` | `STMT-ID`, `PARAM-IDX` (0-based) | `VAL-SIGN`/`VAL-NUM`, `STATUS` |
| `12` | `CORM-OP-COL-STR` | `STMT-ID`, `PARAM-IDX` (0-based) | `DATA2`, `D2-LEN`, `STATUS` |
| `13` | `CORM-OP-FINALIZE` | `STMT-ID` | `STATUS` |
| `14` | `CORM-OP-LAST-ERR` | `DB-ID` | `DATA2`, `D2-LEN`, `STATUS` |
| `15` | `CORM-OP-VERSION` | — | `DATA2` (`"0.1.0"`), `D2-LEN`, `STATUS` |
| `16` | `CORM-OP-ROWID` | `DB-ID` | `VAL-SIGN`/`VAL-NUM`, `STATUS` |

See working end-to-end programs for every historical standard under [`cobol/era/`](cobol/era/):
- [`cobol60/corm_era60.cbl`](cobol/era/cobol60/corm_era60.cbl), [`cobol61/corm_era61.cbl`](cobol/era/cobol61/corm_era61.cbl), [`cobol61x/corm_era61x.cbl`](cobol/era/cobol61x/corm_era61x.cbl), [`cobol65/corm_era65.cbl`](cobol/era/cobol65/corm_era65.cbl), [`cobol68/corm_era68.cbl`](cobol/era/cobol68/corm_era68.cbl), [`cobol74/corm_era74.cbl`](cobol/era/cobol74/corm_era74.cbl), and [`cobol85/corm_era85.cbl`](cobol/era/cobol85/corm_era85.cbl).

---

## 7. Consuming from CMake & `pkg-config`

### CMake `find_package`

```cmake
find_package(cobol-orm CONFIG REQUIRED)
target_link_libraries(my_app PRIVATE cobol_orm::cobol_orm_c)
```

### `pkg-config`

```sh
cc $(pkg-config --cflags cobol-orm) my_bridge.c $(pkg-config --libs cobol-orm) -o my_bridge
```

---

## 8. Regenerating Bindings & Running Quality Gates

```sh
# 1. Regenerate & verify zero drift against ../cdd-c
./scripts/generate_bindings.sh
./scripts/generate_bindings.sh --check

# 2. Verify 100% C89 (incl. src/generated/) and COBOL documentation coverage
python3 scripts/generate_undercovered.py --doc

# 3. Verify 100% real execution COBOL function, line, and branch coverage
python3 scripts/check_cobol_coverage.py --build-dir build

# 4. Update UNDERCOVERED.md & README.md shields from live coverage data
python3 scripts/generate_undercovered.py --cov-dir build-cov --build-dir build
python3 scripts/update_shields.py --cov-dir build-cov --build-dir build

# 5. Run the complete pre-commit quality gate (14 hooks)
pre-commit run --all-files
```

---

## 9. Troubleshooting

| Symptom / Status Code | Likely Cause | Resolution |
| :--- | :--- | :--- |
| `C-ORM-ERR-INV-HANDLE` (`32`) | Handle is `NULL`, uninitialized, or already closed/freed | Ensure handle is initialized (`VALUE NULL`), check `C-ORM-OK` after constructor, and do not reuse after `CORM-DISCONNECT` / `*_free` |
| `C-ORM-ERR-TRUNCATION` (`26`) | Output `PIC X` buffer is shorter than the returned SQL text/error/column | Check `WS-OUT-LEN` for required byte length and enlarge the caller `PIC X(N)` buffer |
| `C-ORM-ERR-VALIDATION` (`11`) | Level-`88` condition or `THRU` range failed during `cpy_validate_88` / `cpy_insert` / `cpy_update` | Populate a legal domain value matching the Copybook's level-`88` definitions |
| `C-ORM-ERR-TIMEOUT` (`24`) | Connection pool has reached `max_conns` and no connection was released within `timeout_ms` | Release leased handles promptly via `CORM-POOL-RELEASE` or increase `max_conns` / `timeout_ms` |
| `C-ORM-ERR-TBL-FULL` (`35`) | Legacy COMMAREA registry has 64 open DB or 64 open statement slots | Close completed statements (`OP=13`) and connections (`OP=2`) or invoke `cobol_orm_legacy_reset` |
| `cobc`: `'BINARY-LONG' is not defined` under `-std=ibm-strict` | Included `cobol_orm.cpy` instead of the IBM-strict Copybook | Use `COPY "cobol_orm_ibm.cpy".` for `-std=ibm-strict` builds |
| Runtime `libcobol_orm_ffi` not found | Shared library path not embedded via `-Wl,-rpath` or `COB_PRE_LOAD` | Pass `-Q -Wl,-rpath,<dir>` to `cobc` or export `COB_PRE_LOAD=/path/to/libcobol_orm_ffi.{dylib,so}` |
