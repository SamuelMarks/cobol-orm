      * @file cobol_orm_errors.cpy
      * @module cobol_orm_copybooks
      * @brief Strongly-typed COBOL error status item and level-88
      * condition names
      * matching cobol_orm_error_t (0..36) 1:1.

      * @class C-ORM-STATUS
      * @brief Unified level-01 error status code returned by all
      * cobol-orm calls.
      * @field C-ORM-STATUS Signed 32-bit error status code (0 = OK).
       01 C-ORM-STATUS USAGE BINARY-LONG SIGNED VALUE 0.
      * @cond C-ORM-OK Operation succeeded.
           88 C-ORM-OK                     VALUE 0.
      * @cond C-ORM-ERR-MEMORY Out of memory allocation failure.
           88 C-ORM-ERR-MEMORY             VALUE 1.
      * @cond C-ORM-ERR-CONNECTION Database connection failure.
           88 C-ORM-ERR-CONNECTION         VALUE 2.
      * @cond C-ORM-ERR-SQL SQL syntax or execution error.
           88 C-ORM-ERR-SQL                VALUE 3.
      * @cond C-ORM-ERR-BIND Parameter bind failure.
           88 C-ORM-ERR-BIND               VALUE 4.
      * @cond C-ORM-ERR-STEP Statement step failure.
           88 C-ORM-ERR-STEP               VALUE 5.
      * @cond C-ORM-ERR-TYPE-MISMATCH Column or variant type mismatch.
           88 C-ORM-ERR-TYPE-MISMATCH      VALUE 6.
      * @cond C-ORM-ERR-NOT-FOUND Row, column, or key not found.
           88 C-ORM-ERR-NOT-FOUND          VALUE 7.
      * @cond C-ORM-ERR-NOT-IMPL Feature or driver not implemented.
           88 C-ORM-ERR-NOT-IMPL           VALUE 8.
      * @cond C-ORM-ERR-UNKNOWN Unclassified internal error.
           88 C-ORM-ERR-UNKNOWN            VALUE 9.
      * @cond C-ORM-ERR-EXPIRED Session record expired.
           88 C-ORM-ERR-EXPIRED            VALUE 10.
      * @cond C-ORM-ERR-VALIDATION Argument or level-88 validation
      * failure.
           88 C-ORM-ERR-VALIDATION         VALUE 11.
      * @cond C-ORM-ERR-RECURSION Recursion limit exceeded.
           88 C-ORM-ERR-RECURSION          VALUE 12.
      * @cond C-ORM-ERR-READ-ONLY Write attempted on read-only DB.
           88 C-ORM-ERR-READ-ONLY          VALUE 13.
      * @cond C-ORM-ERR-NULL-PTR Required pointer argument was NULL.
           88 C-ORM-ERR-NULL-PTR           VALUE 14.
      * @cond C-ORM-ERR-IO File or stream I/O failure.
           88 C-ORM-ERR-IO                 VALUE 15.
      * @cond C-ORM-ERR-PARSE Input or SQL parse failure.
           88 C-ORM-ERR-PARSE              VALUE 16.
      * @cond C-ORM-ERR-OVERFLOW Buffer or integer overflow.
           88 C-ORM-ERR-OVERFLOW           VALUE 17.
      * @cond C-ORM-ERR-CYCLE Dependency cycle detected.
           88 C-ORM-ERR-CYCLE              VALUE 18.
      * @cond C-ORM-ERR-BUSY Database or mutex lock busy.
           88 C-ORM-ERR-BUSY               VALUE 19.
      * @cond C-ORM-ERR-CRYPTO Cryptographic hook failure.
           88 C-ORM-ERR-CRYPTO             VALUE 20.
      * @cond C-ORM-ERR-CONSTRAINT Constraint violation.
           88 C-ORM-ERR-CONSTRAINT         VALUE 21.
      * @cond C-ORM-ERR-DRIVER-LOAD Dynamic DB client library load
      * failed.
           88 C-ORM-ERR-DRIVER-LOAD        VALUE 22.
      * @cond C-ORM-ERR-ODBC-DIAG ODBC or IBM Db2 diagnostic error.
           88 C-ORM-ERR-ODBC-DIAG          VALUE 23.
      * @cond C-ORM-ERR-TIMEOUT Login, pool, or query timeout.
           88 C-ORM-ERR-TIMEOUT            VALUE 24.
      * @cond C-ORM-ERR-DEADLOCK Deadlock or serialization failure.
           88 C-ORM-ERR-DEADLOCK           VALUE 25.
      * @cond C-ORM-ERR-TRUNCATION Disallowed string or binary
      * truncation.
           88 C-ORM-ERR-TRUNCATION         VALUE 26.
      * @cond C-ORM-ERR-DEC-SYNTAX Malformed decimal or COMP-3 syntax.
           88 C-ORM-ERR-DEC-SYNTAX         VALUE 27.
      * @cond C-ORM-ERR-DEC-OVERFLOW Decimal overflow or division by
      * zero.
           88 C-ORM-ERR-DEC-OVERFLOW       VALUE 28.
      * @cond C-ORM-ERR-DEC-INEXACT Inexact rounding under exact mode.
           88 C-ORM-ERR-DEC-INEXACT        VALUE 29.
      * @cond C-ORM-ERR-CODEPAGE Invalid UTF or EBCDIC sequence.
           88 C-ORM-ERR-CODEPAGE           VALUE 30.
      * @cond C-ORM-ERR-CPY-SYNTAX COBOL Copybook parse syntax error.
           88 C-ORM-ERR-CPY-SYNTAX         VALUE 31.
      * @cond C-ORM-ERR-INV-HANDLE Opaque handle invalid or closed.
           88 C-ORM-ERR-INV-HANDLE         VALUE 32.
      * @cond C-ORM-ERR-BUF-SMALL Caller output buffer too small.
           88 C-ORM-ERR-BUF-SMALL          VALUE 33.
      * @cond C-ORM-ERR-NOT-CONN Database connection not active.
           88 C-ORM-ERR-NOT-CONN           VALUE 34.
      * @cond C-ORM-ERR-TBL-FULL Legacy integer handle registry full.
           88 C-ORM-ERR-TBL-FULL           VALUE 35.
      * @cond C-ORM-ERR-INV-OP Unsupported legacy COMMAREA opcode.
           88 C-ORM-ERR-INV-OP             VALUE 36.
