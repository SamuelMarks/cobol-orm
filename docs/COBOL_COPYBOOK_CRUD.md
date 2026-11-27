# COBOL Copybook-Driven CRUD Guide

`cobol-orm` enables zero-boilerplate persistence directly from standard COBOL Copybooks (`.cpy`) and IBM Db2 `DCLGEN` (`EXEC SQL DECLARE ... END-EXEC`) definitions.

## Workflow

1. **Parse Copybook**: Call `cobol_orm_cpy_parse_str` or `cobol_orm_cpy_parse_file` with `COBOL_ORM_CPY_FORMAT_AUTO`, `FIXED`, or `FREE`.
2. **Introspect Layout**: Inspect exact record byte size (`cobol_orm_cpy_info`) and per-field byte offsets, usages, digits, scale, and PK flag (`cobol_orm_cpy_field_info`). Override the primary key column if needed via `cobol_orm_cpy_set_pk`.
3. **Create Schema**: Emit dialect-specific `CREATE TABLE` DDL (`cobol_orm_cpy_emit_ddl`) or apply it directly (`cobol_orm_cpy_create_table`).
4. **Validate Level-`88` Domain Conditions**: `cobol_orm_cpy_insert` and `cobol_orm_cpy_update` automatically enforce all level-`88` single-value and `THRU`-range predicates before issuing SQL; you may also call `cobol_orm_cpy_validate_88` standalone.
5. **Direct `01`-Record CRUD**: Pass your raw COBOL `01` record buffer directly to:
   - `cobol_orm_cpy_insert`
   - `cobol_orm_cpy_find_i32`
   - `cobol_orm_cpy_find_all`
   - `cobol_orm_cpy_update`
   - `cobol_orm_cpy_delete_i32`

## Supported COBOL Wire Encodings

- `PIC X(n)` alphanumeric (ASCII, UTF-8, or EBCDIC `IBM037`/`1047`/`500`/`1140`)
- `PIC S9(p)V9(s) COMP-3` / `PACKED-DECIMAL` (exact up to 38 digits)
- `PIC S9(p)V9(s)` Zoned Decimal (`USAGE DISPLAY`)
- `PIC S9(n) COMP` (big-endian or native endian via `big_endian` flag) and `COMP-5`
- `COMP-1` (32-bit IEEE float) and `COMP-2` (64-bit IEEE double)
- IBM Db2 `DCLGEN` `VARCHAR` (`49` length + text group) and `CHAR(n) FOR BIT DATA` (`BLOB`)
- `FILLER`, `REDEFINES`, and level-`66 RENAMES` are safely skipped during SQL projection while preserving exact byte offsets.
