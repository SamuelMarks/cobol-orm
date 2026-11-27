# Fixed 80-Column Mainframe & Enterprise Guide

## Strict Fixed-80 & Dialect Compliance

Every file under `copybooks/fixed/`, `cobol/fixed/`, `generated/fixed/`, `copybooks/era/`, `cobol/era/cobol60..cobol2002`, `tests/cobol/test_e2e_fixed.cbl`, and `examples/fixed/` adheres strictly to classic punched-card / IBM z/OS 80-column formatting:

- **Columns 1–6**: Sequence number area (spaces)
- **Column 7**: Indicator area (`*` comment, `-` continuation, space code)
- **Columns 8–11**: Area A (`DIVISION`, `SECTION`, `PROGRAM-ID`, `01`, `77`, paragraph headers)
- **Columns 12–72**: Area B (executable statements and subordinate data items; zero overflow beyond column 72)

For strict IBM Enterprise COBOL (`-std=ibm-strict`) and Micro Focus (`-std=mf-strict`) builds without ISO-2002 `BINARY-LONG`/`FLOAT-LONG`, import `copybooks/fixed/cobol_orm_ibm.cpy` (using native `PIC S9(9) COMP-5`, `PIC 9(9) COMP-5`, `USAGE COMP-2`, `PIC X(1)`, and `USAGE POINTER`) and link `cobol/fixed/cobol_orm_lib.cbl` (verified cleanly under `-std=ibm-strict`, `-std=mf-strict`, and `-std=default`).

Automated verification runs in pre-commit and CI:

```sh
python3 scripts/free_to_fixed80.py --verify generated/fixed copybooks/fixed cobol/fixed copybooks/era cobol/era/cobol60 cobol/era/cobol61 cobol/era/cobol61x cobol/era/cobol65 cobol/era/cobol68 cobol/era/cobol74 cobol/era/cobol85 cobol/era/cobol2002
```

## Enterprise IBM Db2 & Generic ODBC 3.52

- `cobol_orm_odbc_sqlstate`: Extracts the 5-character ANSI/ODBC `SQLSTATE` into a right-space-padded `PIC X` buffer.
- `cobol_orm_db2_set_isolation`: Configures IBM Db2 isolation levels (`COBOL_ORM_ISO_UR`, `CS`, `RS`, `RR`).
- `cobol_orm_db2_set_schema`: Sets the active Db2 `CURRENT SCHEMA`.
- `cobol_orm_ast_with_lock`: Appends Db2 `WITH UR` / `WITH CS` / `WITH RS` / `WITH RR` clauses when rendering AST SQL for `COBOL_ORM_DIALECT_DB2`.

## EBCDIC & UTF-16 GRAPHIC/NATIONAL Transcoding

- `cobol_orm_utf8_to_ebcdic` / `cobol_orm_ebcdic_to_utf8` support `IBM037` (US/Canada), `IBM1047` (z/OS OpenSystems C), `IBM500` (International), and `IBM1140` (Euro).
- `cobol_orm_utf8_to_utf16` / `cobol_orm_utf16_to_utf8` support big-endian (`big_endian = 1`, IBM z/OS `PIC N`) and little-endian UTF-16 with unpaired surrogate rejection (`COBOL_ORM_ERROR_CODEPAGE`).
