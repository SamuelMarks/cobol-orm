# cobol-orm Error Codes & Level-88 Conditions

Every C89 FFI function returns `cobol_orm_error_t` (mapped 1:1 to `c_orm_error_t` codes `0..31`, plus FFI-specific codes `32..36`). COBOL callers test status using idiomatic level-`88` condition names from `copybooks/{free,fixed}/cobol_orm_errors.cpy`.

| Code | C Enum Symbol | COBOL Level-88 Condition | Meaning |
| ---: | :--- | :--- | :--- |
| `0` | `COBOL_ORM_OK` | `C-ORM-OK` | Operation succeeded |
| `1` | `COBOL_ORM_ERROR_MEMORY` | `C-ORM-ERR-MEMORY` | Heap allocation failed |
| `2` | `COBOL_ORM_ERROR_CONNECTION` | `C-ORM-ERR-CONNECTION` | Database connection failed |
| `3` | `COBOL_ORM_ERROR_SQL` | `C-ORM-ERR-SQL` | SQL syntax or execution error |
| `4` | `COBOL_ORM_ERROR_BIND` | `C-ORM-ERR-BIND` | Statement parameter bind failed |
| `5` | `COBOL_ORM_ERROR_STEP` | `C-ORM-ERR-STEP` | Statement step failed |
| `6` | `COBOL_ORM_ERROR_TYPE_MISMATCH` | `C-ORM-ERR-TYPE-MISMATCH` | Variant/column type mismatch |
| `7` | `COBOL_ORM_ERROR_NOT_FOUND` | `C-ORM-ERR-NOT-FOUND` | Row, column, or index not found |
| `8` | `COBOL_ORM_ERROR_NOT_IMPLEMENTED` | `C-ORM-ERR-NOT-IMPL` | Operation unsupported by backend |
| `9` | `COBOL_ORM_ERROR_UNKNOWN` | `C-ORM-ERR-UNKNOWN` | Unknown/unmapped error code |
| `10` | `COBOL_ORM_ERROR_EXPIRED` | `C-ORM-ERR-EXPIRED` | Lease or token expired |
| `11` | `COBOL_ORM_ERROR_VALIDATION` | `C-ORM-ERR-VALIDATION` | Input or level-`88` validation failed |
| `12` | `COBOL_ORM_ERROR_RECURSION` | `C-ORM-ERR-RECURSION` | Recursion depth exceeded |
| `13` | `COBOL_ORM_ERROR_READ_ONLY` | `C-ORM-ERR-READ-ONLY` | Write attempted on read-only DB |
| `14` | `COBOL_ORM_ERROR_NULL_POINTER` | `C-ORM-ERR-NULL-PTR` | Required pointer argument was NULL |
| `15` | `COBOL_ORM_ERROR_IO` | `C-ORM-ERR-IO` | File or stream I/O failure |
| `16` | `COBOL_ORM_ERROR_PARSE` | `C-ORM-ERR-PARSE` | Input parse error |
| `17` | `COBOL_ORM_ERROR_OVERFLOW` | `C-ORM-ERR-OVERFLOW` | Buffer capacity or arithmetic overflow |
| `18` | `COBOL_ORM_ERROR_CYCLE` | `C-ORM-ERR-CYCLE` | Dependency cycle detected |
| `19` | `COBOL_ORM_ERROR_BUSY` | `C-ORM-ERR-BUSY` | Database lock busy |
| `20` | `COBOL_ORM_ERROR_CRYPTO` | `C-ORM-ERR-CRYPTO` | Cryptographic hook error |
| `21` | `COBOL_ORM_ERROR_CONSTRAINT` | `C-ORM-ERR-CONSTRAINT` | Unique/FK/check constraint violation |
| `22` | `COBOL_ORM_ERROR_DRIVER_LOAD` | `C-ORM-ERR-DRIVER-LOAD` | Dynamic driver library failed to load |
| `23` | `COBOL_ORM_ERROR_ODBC_DIAG` | `C-ORM-ERR-ODBC-DIAG` | ODBC / Db2 CLI diagnostic error |
| `24` | `COBOL_ORM_ERROR_TIMEOUT` | `C-ORM-ERR-TIMEOUT` | Pool or query timeout |
| `25` | `COBOL_ORM_ERROR_DEADLOCK` | `C-ORM-ERR-DEADLOCK` | Transaction deadlock victim |
| `26` | `COBOL_ORM_ERROR_TRUNCATION` | `C-ORM-ERR-TRUNCATION` | Output string/bytes truncated to `buf_cap` |
| `27` | `COBOL_ORM_ERROR_DECIMAL_SYNTAX` | `C-ORM-ERR-DEC-SYNTAX` | Invalid decimal text or BCD nibble |
| `28` | `COBOL_ORM_ERROR_DECIMAL_OVERFLOW` | `C-ORM-ERR-DEC-OVERFLOW` | Precision exceeded or divide-by-zero |
| `29` | `COBOL_ORM_ERROR_DECIMAL_INEXACT` | `C-ORM-ERR-DEC-INEXACT` | Exact rounding lost non-zero digits |
| `30` | `COBOL_ORM_ERROR_CODEPAGE` | `C-ORM-ERR-CODEPAGE` | Invalid codepage or surrogate |
| `31` | `COBOL_ORM_ERROR_COPYBOOK_SYNTAX` | `C-ORM-ERR-CPY-SYNTAX` | Copybook `.cpy` parse error |
| `32` | `COBOL_ORM_ERROR_INVALID_HANDLE` | `C-ORM-ERR-INV-HANDLE` | NULL or bad-magic opaque handle |
| `33` | `COBOL_ORM_ERROR_BUFFER_TOO_SMALL` | `C-ORM-ERR-BUF-SMALL` | Output buffer smaller than minimum |
| `34` | `COBOL_ORM_ERROR_NOT_CONNECTED` | `C-ORM-ERR-NOT-CONN` | Operation requires active connection |
| `35` | `COBOL_ORM_ERROR_HANDLE_TABLE_FULL` | `C-ORM-ERR-TBL-FULL` | Legacy 64-slot handle table exhausted |
| `36` | `COBOL_ORM_ERROR_INVALID_OPCODE` | `C-ORM-ERR-INV-OPCODE` | Unrecognized COMMAREA opcode |
