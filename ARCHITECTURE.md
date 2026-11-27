# `cobol-orm` Architecture

This document describes the complete layered architecture, Foreign Function Interface (FFI) generation pipeline, binary ABI contracts, memory ownership model, error percolation semantics, multi-era COBOL standard transport protocols (`COBOL-60` through `COBOL-2023`), and verification infrastructure of **`cobol-orm`**.

---

## 1. System Overview (4-Layer Architecture)

`cobol-orm` bridges the strict ISO C89 relational ORM engine ([`c-orm`](../c-orm)) to all ten historical and modern COBOL standards via a reproducible, zero-drift [`cdd-c`](../cdd-c) code generation pipeline and a strongly-typed C89 FFI facade.

```mermaid
flowchart TB
    subgraph L4["Layer 4: Idiomatic & Multi-Era COBOL API"]
        direction LR
        FREE["Free-Format COBOL-2014/2023\ncopybooks/free/*.cpy\ncobol/free/cobol_orm_lib.cbl"]
        FIXED["Fixed-80 Enterprise & COBOL-2002\ncopybooks/fixed/*.cpy (incl. cobol_orm_ibm.cpy)\ncobol/fixed/cobol_orm_lib.cbl"]
        ERA["Historical COBOL-60 .. COBOL-85\ncopybooks/era/cobol_orm_display_ca.cpy\ncobol/era/cobol60..cobol85/*.cbl"]
    end

    subgraph L3["Layer 3: Reproducible cdd-c FFI Bindings"]
        direction LR
        GEN_FREE["generated/free/\ncobol_orm.cpy, cobol_orm.cbl\ncobol_orm_test.cbl"]
        GEN_FIXED["generated/fixed/\ncobol_orm.cpy, cobol_orm.cbl\ncobol_orm_test.cbl"]
        GEN_SHIM["src/generated/\ncobol_orm_cobol_shim.h/.c"]
    end

    subgraph L2["Layer 2: Strict ISO C89 Strongly-Typed FFI Facade"]
        direction LR
        MOD_CORE["Modules A-D: DB, Pool, TX, Stmt\n(src/cobol_orm_db/pool/tx/stmt.c)"]
        MOD_DATA["Modules E-H: Abstract RS, AST,\n38-Digit Decimal, EBCDIC/UTF-16"]
        MOD_ENT["Modules I-L: Copybook CRUD,\nMigrations, Db2/ODBC, Legacy COMMAREA"]
    end

    subgraph L1["Layer 1: c-orm ISO C89 Core Engine"]
        direction LR
        DRIVERS["Drivers: SQLite (linked), memory://,\nPostgres/MySQL (dynamic), ODBC, Db2"]
        ENGINE["Core: AST, Pool, Cache, Migrations,\nDecimal/COMP-3, EBCDIC, Copybook Parser"]
    end

    FREE --> GEN_FREE
    FREE --> MOD_CORE
    FIXED --> GEN_FIXED
    FIXED --> MOD_CORE
    ERA --> MOD_ENT

    GEN_FREE --> MOD_CORE
    GEN_FREE --> GEN_SHIM
    GEN_FIXED --> MOD_CORE
    GEN_FIXED --> GEN_SHIM
    GEN_SHIM --> MOD_CORE

    MOD_CORE --> DRIVERS
    MOD_CORE --> ENGINE
    MOD_DATA --> ENGINE
    MOD_ENT --> DRIVERS
    MOD_ENT --> ENGINE
```

### Architectural Separation of Concerns

| Layer | Location | Language / Standard | Primary Responsibility |
| :--- | :--- | :--- | :--- |
| **Layer 1** | `../c-orm` (or FetchContent) | ISO C89 (`-std=c90`) | Database drivers, SQL AST, migrations, 38-digit decimal math, EBCDIC tables, `.cpy`/DCLGEN parser |
| **Layer 2** | `include/`, `src/` | ISO C89 (`-std=c90 -pedantic -Werror`) | Distinct magic-tagged opaque handles, bounded `PIC X` marshaling, universal `cobol_orm_error_t` percolation, legacy 64-slot handle registry & COMMAREA dispatchers |
| **Layer 3** | `ffi/`, `generated/`, `src/generated/` | Normalized IR JSON, C89, Free & Fixed-80 COBOL | Machine-generated 1:1 COBOL Copybooks, subprogram stubs, ABI layout checks, and documented C89 ABI shims |
| **Layer 4** | `copybooks/`, `cobol/`, `examples/` | COBOL-60 .. COBOL-2023 (Free & Fixed-80) | Idiomatic `CORM-*` wrapper subprograms, level-`88` error/domain Copybooks, IBM Enterprise (`COMP-5`) Copybook, and 10-era compatibility suites |

---

## 2. Reproducible `cdd-c` Codegen & Drift-Check Pipeline

All FFI bindings are regenerated deterministically via [`scripts/generate_bindings.sh`](scripts/generate_bindings.sh) and verified byte-for-byte in pre-commit and CI (`--check` mode).

```mermaid
flowchart LR
    HDR["include/cobol_orm_ffi.h\n(include/cobol_orm_*.h)"] --> EXTRACT["scripts/header_to_cdd_ir.py\n(libclang AST Extractor)"]
    EXTRACT --> IR["ffi/cobol_orm_ffi.json\n(Normalized FFI IR + Docs)"]
    IR --> CDDC["cdd-c bind -l cobol\n(--generate-tests)"]

    CDDC --> FREE_OUT["generated/free/\ncobol_orm.cpy\ncobol_orm.cbl\ncobol_orm_test.cbl"]
    CDDC --> SHIM_RAW["generated/free/\ncobol_orm_cobol_shim.h/.c"]

    SHIM_RAW --> DOC_SHIM["scripts/doc_cobol_shim.py\n(IR -> Doxygen Annotation)"]
    IR --> DOC_SHIM
    DOC_SHIM --> SRC_GEN["src/generated/\ncobol_orm_cobol_shim.h/.c"]

    FREE_OUT --> FIX80["scripts/free_to_fixed80.py\n(Cols 1-6 seq, Col 7 ind,\nCols 8-72 Area A/B)"]
    FIX80 --> FIXED_OUT["generated/fixed/\ncobol_orm.cpy\ncobol_orm.cbl\ncobol_orm_test.cbl"]

    FIXED_OUT --> DRIFT["generate_bindings.sh --check\n(diff -ru against temp stage)"]
    SRC_GEN --> DRIFT
```

### Pipeline Invariants

1. **Lossless IR Extraction**: [`scripts/header_to_cdd_ir.py`](scripts/header_to_cdd_ir.py) uses `libclang` to preserve exact typedef widths, `const` qualifiers, pointer depths (`*`, `**`), fixed array bounds, enum integer values, and full Doxygen docblocks into [`ffi/cobol_orm_ffi.json`](ffi/cobol_orm_ffi.json).
2. **Doxygen-Complete Generated Shims**: [`scripts/doc_cobol_shim.py`](scripts/doc_cobol_shim.py) injects IR-sourced Doxygen comments into every struct, field, typedef, guard macro, and helper inside `src/generated/cobol_orm_cobol_shim.h` so `Doxyfile.in` enforces 100% documentation coverage with **zero exclusions** (`WARN_AS_ERROR = YES`).
3. **Strict Fixed-80 Emission**: [`scripts/free_to_fixed80.py`](scripts/free_to_fixed80.py) transforms free-format COBOL into strict punched-card 80-column fixed format (columns 1–6 blank sequence area, column 7 `*` comment or `-` continuation indicator, Area A columns 8–11, Area B columns 12–72, zero `>>SOURCE FORMAT` or `*>` free-format tokens) and verifies all fixed files in `--verify` mode.
4. **Zero-Drift Enforcement**: Running `./scripts/generate_bindings.sh --check` stages a fresh build in a temporary directory and runs `diff -ru` across `ffi/`, `generated/free/`, `generated/fixed/`, and `src/generated/`. Any uncommitted drift fails the gate immediately.

---

## 3. Strong Typing, Opaque Handles & ABI Layout Contracts

### 3.1 Distinct Magic-Tagged Opaque Handle Hierarchy

`cobol-orm` forbids raw `void *` handle aliasing across C boundaries. Every resource type is a distinct incomplete `struct` in [`include/cobol_orm_types.h`](include/cobol_orm_types.h) backed by a unique 32-bit magic tag validated on every FFI entry point and zero-scrubbed upon destruction.

```mermaid
classDiagram
    class cobol_orm_db_t {
        +uint32_t magic = 0x434F4442
        +c_orm_db_t* raw
        +int owned_by_pool
        +cobol_orm_error_t last_err
    }
    class cobol_orm_stmt_t {
        +uint32_t magic = 0x434F5354
        +cobol_orm_db_t* db
        +c_orm_query_t* raw
        +int is_cached
    }
    class cobol_orm_pool_t {
        +uint32_t magic = 0x434F504C
        +c_orm_pool_t* raw
    }
    class cobol_orm_ast_t {
        +uint32_t magic = 0x434F4153
        +c_orm_ast_query_t* raw
    }
    class cobol_orm_cpy_t {
        +uint32_t magic = 0x434F4350
        +c_orm_cobol_record_t* record
        +char* pk_col
        +char* table_name
    }
    class cobol_orm_rs_t {
        +uint32_t magic = 0x434F5253
        +cdd_c_abstract_struct_t* rows
        +uint32_t row_count
    }
    class cobol_orm_mig_t {
        +uint32_t magic = 0x434F4D47
        +cobol_orm_db_t* db
        +char* dir_path
    }

    cobol_orm_pool_t "1" --> "0..*" cobol_orm_db_t : leases
    cobol_orm_db_t "1" --> "0..*" cobol_orm_stmt_t : prepares
    cobol_orm_db_t "1" --> "0..*" cobol_orm_mig_t : migrates
    cobol_orm_db_t "1" --> "0..*" cobol_orm_rs_t : hydrates
    cobol_orm_cpy_t ..> cobol_orm_db_t : persists 01-record
    cobol_orm_ast_t ..> cobol_orm_db_t : compiles & executes
```

### 3.2 Handle Lifecycle State Machine

```mermaid
stateDiagram-v2
    [*] --> Uninitialized: COBOL VALUE NULL
    Uninitialized --> Active: Constructor returns COBOL_ORM_OK\n(magic tag stamped)
    Uninitialized --> Uninitialized: Constructor fails\n(out handle set to NULL)

    Active --> Active: Validated FFI calls\n(check_handle verifies magic != 0)
    Active --> Scrubbed: Destructor called\n(underlying c-orm resource freed,\nmagic zeroed)
    Scrubbed --> Freed: c_orm_system_free(handle)\nCORM-* wrapper sets PTR TO NULL
    Freed --> [*]

    Uninitialized --> Rejected: Passed to FFI call\nreturns COBOL_ORM_ERROR_INVALID_HANDLE (32)
    Scrubbed --> Rejected: Stale pointer guard\nmagic mismatch -> INVALID_HANDLE (32)
```

### 3.3 Exact-Size ABI POD Structures

All five value-type structs crossing the C89 <-> COBOL boundary are layout-locked and asserted at runtime on **both** C (`sizeof` / `offsetof` in `tests/c/test_cobol_orm.c`) and COBOL (`FUNCTION BYTE-LENGTH` in `generated/free/cobol_orm_test.cbl` and `generated/fixed/cobol_orm_test.cbl`):

| C89 Struct (`include/cobol_orm_types.h`) | COBOL Record (`copybooks/*/cobol_orm_types.cpy` & `cobol_orm_ibm.cpy`) | Exact Size | Purpose |
| :--- | :--- | ---: | :--- |
| `cobol_orm_decimal_t` | `C-ORM-DECIMAL-REC` | **41 bytes** | Lossless 38-digit base-10 fixed-point decimal (1:1 with `c_orm_decimal_t`) |
| `cobol_orm_pool_stats_t` | `C-ORM-POOL-STATS-REC` | **24 bytes** | Pool active/idle counts, exhaustion count, slow query count, average wait ms (`double`/`FLOAT-LONG`/`COMP-2`) |
| `cobol_orm_cpy_info_t` | `C-ORM-CPY-INFO-REC` | **12 bytes** | Parsed Copybook wire byte size, mapped field count, DCLGEN indicator |
| `cobol_orm_col_info_t` | `C-ORM-COL-INFO-REC` | **16 bytes** | Single field byte offset, wire size, `USAGE`, total digits, scale, signed flag, PK flag |
| `cobol_orm_commarea_t` | `C-ORM-COMMAREA-REC` | **544 bytes** | Native-binary single-argument COMMAREA request/response block |
| Pure `USAGE DISPLAY` buffer | `CORM-DISP-COMMAREA` (`copybooks/era/cobol_orm_display_ca.cpy`) | **552 bytes** | Endian-independent pure ASCII `PIC 9`/`PIC X` COMMAREA for `COBOL-60`..`COBOL-85` |

---

## 4. Dual Transport Protocols: Modern Pointer ABI vs. Legacy `COMMAREA`

Because COBOL spans over 65 years of ISO/ANSI standards, `cobol-orm` provides two first-class call transports over the exact same C89 FFI implementation:

```mermaid
sequenceDiagram
    autonumber
    participant Mod as Modern COBOL (2002 / 2014 / 2023)
    participant Lib as CORM-* Wrapper (cobol_orm_lib.cbl)
    participant Fac as C89 FFI Facade (libcobol_orm_ffi)
    participant Core as c-orm Engine (SQLite / Db2 / PG / ...)

    Mod->>Lib: CALL "CORM-CONNECT" USING WS-URL, C-ORM-DB-PTR, C-ORM-STATUS
    Lib->>Lib: Compute BYTE-LENGTH / LENGTH(WS-URL)
    Lib->>Fac: CALL "cobol_orm_connect" BY REF WS-URL, BY VAL len, BY REF ptr RETURNING status
    Fac->>Fac: cobol_orm_picx_to_cstr (right-trim ASCII 0x20, heap alloc)
    Fac->>Core: c_orm_connect_url(url_c, &raw_db)
    Core-->>Fac: C_ORM_OK + raw_db
    Fac->>Fac: Allocate cobol_orm_db_t, stamp COBOL_ORM_MAGIC_DB
    Fac-->>Lib: COBOL_ORM_OK (0) + out_db pointer
    Lib-->>Mod: C-ORM-DB-PTR populated, C-ORM-OK is TRUE

    participant Leg as Historical COBOL (60 / 61 / 61X / 65 / 68 / 74 / 85)
    participant Reg as Legacy 64-Slot Registry (cobol_orm_legacy.c)

    Leg->>Reg: CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA (552B)
    Reg->>Reg: Decode ASCII PIC 9(4) opcode=0001, trim DATA1 URL
    Reg->>Fac: cobol_orm_connect(url, len, &db_ptr)
    Fac->>Core: c_orm_connect_url(...)
    Core-->>Fac: C_ORM_OK
    Fac-->>Reg: db_ptr
    Reg->>Reg: Store db_ptr in g_db_slots[slot], encode ASCII DB-ID & STATUS=0000
    Reg-->>Leg: CORM-CA-DB-ID = 0001, CORM-ST-OK is TRUE
```

### Why Two Transports?

1. **COBOL-2002 / COBOL-2014 / COBOL-2023 / IBM Enterprise / Micro Focus**:
   - Have native `USAGE POINTER`, `BY VALUE`, `RETURNING`, and fixed-width binary types (`USAGE BINARY-LONG` in ISO 2002+, or `PIC S9(9) COMP-5` in strict IBM Enterprise / Micro Focus).
   - Call either the idiomatic short-named [`cobol/{free,fixed}/cobol_orm_lib.cbl`](cobol/free/cobol_orm_lib.cbl) wrappers (`CORM-*`) or the full 87-function `cdd-c` surface (`cobol_orm_*` / `COBOL-ORM-*`).
2. **COBOL-60 / COBOL-61 / COBOL-61 Extended / COBOL-65 / COBOL-68 / COBOL-74 / COBOL-85**:
   - Lack `USAGE POINTER`, `BY VALUE`, `RETURNING`, and uniform `COMP` byte order across big-endian mainframes and little-endian ARM64/x86-64 hosts.
   - Invoke `CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA` with a single `BY REFERENCE` 552-byte pure `USAGE DISPLAY` ASCII block ([`copybooks/era/cobol_orm_display_ca.cpy`](copybooks/era/cobol_orm_display_ca.cpy)).
   - Integer slot IDs (`0001`–`0064`) index into the 64-slot database and 64-slot statement registry in [`src/cobol_orm_legacy.c`](src/cobol_orm_legacy.c), completely immune to pointer width (32-bit vs 64-bit) and CPU endianness.

---

## 5. Copybook-Driven `01`-Record CRUD Architecture

One of `cobol-orm`'s flagship capabilities is persisting and hydrating raw COBOL `01` Working-Storage records directly without writing manual field-by-field marshaling code.

```mermaid
flowchart TD
    CPY_SRC["COBOL Copybook (.cpy or Db2 DCLGEN)\n01 LEDGER-REC.\n  05 ACCT-ID PIC S9(9) COMP.\n  05 ACCT-BAL PIC S9(7)V99 COMP-3.\n  05 ACCT-STAT PIC X(1). 88 STAT-OPEN VALUE 'O'."]
    CPY_SRC --> PARSE["cobol_orm_cpy_parse_str / parse_file\n(AUTO / FIXED / FREE)"]
    PARSE --> META["cobol_orm_cpy_t\nByte offsets, wire sizes, USAGE,\nprecision/scale, level-88 rules, PK"]

    META --> DDL["cobol_orm_cpy_emit_ddl / create_table\n(SQLite / Postgres / MySQL / Db2 / ODBC)"]
    META --> WRITE["cobol_orm_cpy_insert / update\n(Raw 01 record buffer + codepage + endian)"]

    WRITE --> VAL88{"cobol_orm_cpy_validate_88\nAll level-88 values & THRU ranges valid?"}
    VAL88 -- "No" --> ERR88["Return COBOL_ORM_ERROR_VALIDATION (11)\n(Zero SQL executed)"]
    VAL88 -- "Yes" --> UNPACK["Unpack COBOL Wire Fields\nCOMP/COMP-5 -> int64\nCOMP-3/Zoned -> 38-digit decimal\nPIC X (ASCII/UTF8/EBCDIC) -> UTF-8"]
    UNPACK --> SQL_EXEC["Parameterized SQL INSERT / UPDATE\nvia c-orm prepared statement"]

    META --> READ["cobol_orm_cpy_find_i32 / find_all\n(Hydrate single 01 or OCCURS array)"]
    READ --> SQL_SEL["Parameterized SQL SELECT"]
    SQL_SEL --> PACK["Pack SQL Columns into COBOL Wire Buffer\nint64 -> big/native COMP\ndecimal -> COMP-3 / Zoned\nUTF-8 -> ASCII / EBCDIC fixed-width PIC X"]
    PACK --> OUT_REC["Populated COBOL 01 Record\n(or contiguous OCCURS table)"]
```

---

## 6. String, Binary, Decimal & Codepage Marshaling

| COBOL Representation | C89 FFI Marshal Strategy | Overflow / Failure Semantics |
| :--- | :--- | :--- |
| Input `PIC X(N)` (URLs, SQL, DDL, identifiers) | `cobol_orm_picx_to_cstr()` right-trims trailing ASCII spaces (`0x20`) and allocates exact `len + 1` bytes via `c_orm_system_malloc` (no 256-byte cap, no stack VLAs) | `COBOL_ORM_ERROR_NULL_POINTER` (14) or `COBOL_ORM_ERROR_MEMORY` (1) |
| Output `PIC X(N)` (error text, column text, SQL, version) | `cobol_orm_cstr_to_picx()` copies up to `buf_cap` bytes, right-pads remaining bytes with `0x20`, writes exact unpadded source length to `*out_len` | Returns `COBOL_ORM_ERROR_TRUNCATION` (26) if source exceeds `buf_cap` while still reporting required length in `*out_len` |
| Binary `BLOB` / `COMP-3` / `EBCDIC` | `cobol_orm_bytes_copy()` exact byte copy with explicit `(buf, len)` / `(out_buf, cap, out_len)` | `COBOL_ORM_ERROR_TRUNCATION` (26) or `COBOL_ORM_ERROR_BUFFER_TOO_SMALL` (33) |
| 38-Digit Fixed-Point Decimal | Stack-allocated 41-byte `cobol_orm_decimal_t` (zero floating-point loss), 4 rounding modes (`TRUNCATE`, `HALF_UP`, `HALF_EVEN`, `ERROR_IF_INEXACT`) | `DECIMAL_SYNTAX` (27), `DECIMAL_OVERFLOW` (28), `DECIMAL_INEXACT` (29) |
| Mainframe EBCDIC & UTF-16 `GRAPHIC` | Codepage tables for `IBM037`, `IBM1047`, `IBM500`, `IBM1140` (Euro `U+20AC`), plus big/little-endian UTF-16 with unpaired surrogate rejection | `COBOL_ORM_ERROR_CODEPAGE` (30) |

---

## 7. Universal Error Percolation & Memory / OOM Guarantees

### Universal `cobol_orm_error_t` Discipline

- **Every** C89 function in `include/` and `src/` returns `cobol_orm_error_t` annotated with `COBOL_ORM_NO_DISCARD`, statically verified by [`scripts/check_enum_returns_clang.py`](scripts/check_enum_returns_clang.py).
- **Zero `(void)` return discards**: Statically verified by [`scripts/check_no_discard_void_clang.py`](scripts/check_no_discard_void_clang.py).
- **Primary-Error Preservation**: Cleanup calls combine return codes via `cobol_orm_keep_err(primary, cleanup)` so teardown errors are neither silently discarded nor allowed to overwrite an earlier failure code.
- **1:1 `c-orm` Error Parity**: Codes `0..31` mirror `c_orm_error_t` identically; codes `32..36` cover FFI handle/buffer/legacy-dispatch conditions. Every code maps to an explicit COBOL level-`88` predicate (`C-ORM-OK` through `C-ORM-ERR-INV-OP`).

### Deterministic OOM & Sanitizer Safety

- All dynamic allocations route through `c_orm_system_malloc`, `c_orm_system_calloc`, and `c_orm_system_free`.
- [`tests/c/test_cobol_orm.c`](tests/c/test_cobol_orm.c) injects deterministic allocation failures via `c_orm_set_allocators` across every allocation-bearing API path to exercise 100% of cleanup unwind branches with zero leaks.
- Every build configuration is verified clean under `-fsanitize=address,undefined` (`-DCOBOL_ORM_ENABLE_ASAN=ON`) and Linux Valgrind in CI.

---

## 8. Multi-Dialect CMake Build & Quality-Gate Architecture

```mermaid
flowchart LR
    SRC["C89 Sources\n(src/*.c + src/generated/*.c)"] --> LIB_C["cobol_orm_c\n(static or shared via BUILD_SHARED_LIBS)"]
    SRC --> LIB_FFI["cobol_orm_ffi\n(self-contained shared library\nwith c-orm statically linked in)"]
    LIB_C --> TEST_C["test_cobol_orm_c\n(C89 unit, ABI & OOM suite)"]
    LIB_C --> COV_C["gcovr + llvm-cov\n(100% fn / line / branch)"]

    COB_FREE["cobol/free/cobol_orm_lib.cbl"] --> OBJ_FREE["cobol_orm_lib_free.o"]
    COB_FIX["cobol/fixed/cobol_orm_lib.cbl"] --> OBJ_FIX["cobol_orm_lib_fixed.o"]

    OBJ_FREE --> E2E_FREE["Free E2E, ABI & 4 Free Examples"]
    OBJ_FIX --> E2E_FIX["Fixed E2E, ABI, IBM/MF Strict & 4 Fixed Examples"]
    LIB_FFI --> E2E_FREE
    LIB_FFI --> E2E_FIX
    LIB_FFI --> ERA10["10-Era Verification Suite\n(COBOL-60 .. COBOL-2023)"]

    OBJ_FREE --> COV_COB["scripts/check_cobol_coverage.py\n(cobc -C -fsource-location + gcov -b\n100% fn / line / branch)"]
    OBJ_FIX --> COV_COB
```

### Build Encapsulation & Distribution

- **`c-orm` Consumption**: Automatically consumes a local sibling `../c-orm` checkout when present, falling back transparently to `FetchContent` (`https://github.com/SamuelMarks/c-orm.git`) for standalone builds.
- **Self-Contained Shared Artifacts**: `BUILD_SHARED_LIBS` is temporarily held `OFF` while fetching `c-orm` so `libcobol_orm` (when built shared) and `libcobol_orm_ffi` embed `c-orm` cleanly with no broken runtime export dependencies, enabling clean `install(EXPORT cobol-orm-targets ...)` + `cobol-orm-config.cmake` + `cobol-orm.pc`.
- **Zero Warning Suppressions**: Compiled with `-std=c90 -pedantic -Wall -Wextra -Werror -Wdeclaration-after-statement -Wmissing-prototypes -Wstrict-prototypes -Wold-style-definition -Wwrite-strings -Wcast-qual` (GCC/Clang) or `/W4 /WX /sdl` (MSVC), and `cobc -Wall -Wextra -Werror` (including `-std=ibm-strict`, `-std=mf-strict`, `-std=cobol85`, `-std=cobol2002`, and `-std=cobol2014`).
