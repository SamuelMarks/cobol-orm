      * @file cobol_orm_ibm.cpy
      * @module cobol_orm_copybooks
      * @brief Strict IBM Enterprise COBOL (-std=ibm-strict) and Micro
      * Focus (-std=mf-strict) fixed 80-column Copybook using native
      * COMP-5, COMP-2, PIC X(1), and USAGE POINTER with 1:1 C89 ABI.

      * @class C-ORM-STATUS
      * @brief Unified level-01 error status code returned by cobol-orm.
      * @field C-ORM-STATUS Signed 32-bit native error status (0 = OK).
       01 C-ORM-STATUS                 PIC S9(9) COMP-5 VALUE 0.
      * @cond C-ORM-OK Operation succeeded.
           88 C-ORM-OK                 VALUE 0.
      * @cond C-ORM-ERR-MEMORY Out of memory allocation failure.
           88 C-ORM-ERR-MEMORY         VALUE 1.
      * @cond C-ORM-ERR-CONNECTION Database connection failure.
           88 C-ORM-ERR-CONNECTION     VALUE 2.
      * @cond C-ORM-ERR-SQL SQL syntax or execution error.
           88 C-ORM-ERR-SQL            VALUE 3.
      * @cond C-ORM-ERR-BIND Parameter bind failure.
           88 C-ORM-ERR-BIND           VALUE 4.
      * @cond C-ORM-ERR-STEP Statement step failure.
           88 C-ORM-ERR-STEP           VALUE 5.
      * @cond C-ORM-ERR-TYPE-MISMATCH Column or variant type mismatch.
           88 C-ORM-ERR-TYPE-MISMATCH  VALUE 6.
      * @cond C-ORM-ERR-NOT-FOUND Row, column, or key not found.
           88 C-ORM-ERR-NOT-FOUND      VALUE 7.
      * @cond C-ORM-ERR-NOT-IMPL Feature or driver not implemented.
           88 C-ORM-ERR-NOT-IMPL       VALUE 8.
      * @cond C-ORM-ERR-UNKNOWN Unclassified internal error.
           88 C-ORM-ERR-UNKNOWN        VALUE 9.
      * @cond C-ORM-ERR-EXPIRED Session record expired.
           88 C-ORM-ERR-EXPIRED        VALUE 10.
      * @cond C-ORM-ERR-VALIDATION Argument or level-88 validation fail.
           88 C-ORM-ERR-VALIDATION     VALUE 11.
      * @cond C-ORM-ERR-RECURSION Recursion limit exceeded.
           88 C-ORM-ERR-RECURSION      VALUE 12.
      * @cond C-ORM-ERR-READ-ONLY Write attempted on read-only DB.
           88 C-ORM-ERR-READ-ONLY      VALUE 13.
      * @cond C-ORM-ERR-NULL-PTR Required pointer argument was NULL.
           88 C-ORM-ERR-NULL-PTR       VALUE 14.
      * @cond C-ORM-ERR-IO File or stream I/O failure.
           88 C-ORM-ERR-IO             VALUE 15.
      * @cond C-ORM-ERR-PARSE Input or SQL parse failure.
           88 C-ORM-ERR-PARSE          VALUE 16.
      * @cond C-ORM-ERR-OVERFLOW Buffer or integer overflow.
           88 C-ORM-ERR-OVERFLOW       VALUE 17.
      * @cond C-ORM-ERR-CYCLE Dependency cycle detected.
           88 C-ORM-ERR-CYCLE          VALUE 18.
      * @cond C-ORM-ERR-BUSY Database or mutex lock busy.
           88 C-ORM-ERR-BUSY           VALUE 19.
      * @cond C-ORM-ERR-CRYPTO Cryptographic hook failure.
           88 C-ORM-ERR-CRYPTO         VALUE 20.
      * @cond C-ORM-ERR-CONSTRAINT Constraint violation.
           88 C-ORM-ERR-CONSTRAINT     VALUE 21.
      * @cond C-ORM-ERR-DRIVER-LOAD Dynamic DB client library load fail.
           88 C-ORM-ERR-DRIVER-LOAD    VALUE 22.
      * @cond C-ORM-ERR-ODBC-DIAG ODBC or IBM Db2 diagnostic error.
           88 C-ORM-ERR-ODBC-DIAG      VALUE 23.
      * @cond C-ORM-ERR-TIMEOUT Login, pool, or query timeout.
           88 C-ORM-ERR-TIMEOUT        VALUE 24.
      * @cond C-ORM-ERR-DEADLOCK Deadlock or serialization failure.
           88 C-ORM-ERR-DEADLOCK       VALUE 25.
      * @cond C-ORM-ERR-TRUNCATION Disallowed truncation.
           88 C-ORM-ERR-TRUNCATION     VALUE 26.
      * @cond C-ORM-ERR-DEC-SYNTAX Malformed decimal or COMP-3 syntax.
           88 C-ORM-ERR-DEC-SYNTAX     VALUE 27.
      * @cond C-ORM-ERR-DEC-OVERFLOW Decimal overflow or div by zero.
           88 C-ORM-ERR-DEC-OVERFLOW   VALUE 28.
      * @cond C-ORM-ERR-DEC-INEXACT Inexact rounding under exact mode.
           88 C-ORM-ERR-DEC-INEXACT    VALUE 29.
      * @cond C-ORM-ERR-CODEPAGE Invalid UTF or EBCDIC sequence.
           88 C-ORM-ERR-CODEPAGE       VALUE 30.
      * @cond C-ORM-ERR-CPY-SYNTAX Copybook parse syntax error.
           88 C-ORM-ERR-CPY-SYNTAX     VALUE 31.
      * @cond C-ORM-ERR-INV-HANDLE Opaque handle invalid or closed.
           88 C-ORM-ERR-INV-HANDLE     VALUE 32.
      * @cond C-ORM-ERR-BUF-SMALL Caller output buffer too small.
           88 C-ORM-ERR-BUF-SMALL      VALUE 33.
      * @cond C-ORM-ERR-NOT-CONN Database connection not active.
           88 C-ORM-ERR-NOT-CONN       VALUE 34.
      * @cond C-ORM-ERR-TBL-FULL Legacy integer handle registry full.
           88 C-ORM-ERR-TBL-FULL       VALUE 35.
      * @cond C-ORM-ERR-INV-OP Unsupported legacy COMMAREA opcode.
           88 C-ORM-ERR-INV-OP         VALUE 36.

      * @field C-ORM-DB-PTR Opaque database connection handle pointer.
       01 C-ORM-DB-PTR                 USAGE POINTER VALUE NULL.
      * @field C-ORM-STMT-PTR Opaque prepared statement handle pointer.
       01 C-ORM-STMT-PTR               USAGE POINTER VALUE NULL.
      * @field C-ORM-POOL-PTR Opaque connection pool handle pointer.
       01 C-ORM-POOL-PTR               USAGE POINTER VALUE NULL.
      * @field C-ORM-AST-PTR Opaque fluent AST query builder pointer.
       01 C-ORM-AST-PTR                USAGE POINTER VALUE NULL.
      * @field C-ORM-CPY-PTR Opaque parsed Copybook handle pointer.
       01 C-ORM-CPY-PTR                USAGE POINTER VALUE NULL.
      * @field C-ORM-RS-PTR Opaque dynamic result-set handle pointer.
       01 C-ORM-RS-PTR                 USAGE POINTER VALUE NULL.
      * @field C-ORM-MIG-PTR Opaque migration runner handle pointer.
       01 C-ORM-MIG-PTR                USAGE POINTER VALUE NULL.

      * @class C-ORM-ENUM-DOMAINS
      * @brief Strongly-typed domain enum variables (IBM COMP-5).
       01 C-ORM-ENUM-DOMAINS.
      * @field C-ORM-DIALECT Target SQL dialect selector.
           05 C-ORM-DIALECT            PIC S9(9) COMP-5 VALUE 0.
      * @cond C-ORM-DL-SQLITE SQLite SQL dialect.
           88 C-ORM-DL-SQLITE          VALUE 0.
      * @cond C-ORM-DL-POSTGRES PostgreSQL SQL dialect.
           88 C-ORM-DL-POSTGRES        VALUE 1.
      * @cond C-ORM-DL-MYSQL MySQL/MariaDB SQL dialect.
           88 C-ORM-DL-MYSQL           VALUE 2.
      * @cond C-ORM-DL-DB2 IBM Db2 SQL dialect.
           88 C-ORM-DL-DB2             VALUE 3.
      * @cond C-ORM-DL-ODBC Generic ANSI/ODBC SQL dialect.
           88 C-ORM-DL-ODBC            VALUE 4.
      * @field C-ORM-ROUND-MODE Fixed-point decimal rounding mode.
           05 C-ORM-ROUND-MODE         PIC S9(9) COMP-5 VALUE 0.
      * @cond C-ORM-RND-TRUNC Truncate toward zero.
           88 C-ORM-RND-TRUNC          VALUE 0.
      * @cond C-ORM-RND-HALF-UP Round half away from zero.
           88 C-ORM-RND-HALF-UP        VALUE 1.
      * @cond C-ORM-RND-HALF-EVEN Banker rounding.
           88 C-ORM-RND-HALF-EVEN      VALUE 2.
      * @cond C-ORM-RND-EXACT Error if inexact.
           88 C-ORM-RND-EXACT          VALUE 3.
      * @field C-ORM-CODEPAGE Character codepage / IBM CCSID selector.
           05 C-ORM-CODEPAGE           PIC S9(9) COMP-5 VALUE 0.
      * @cond C-ORM-CP-UTF8-V UTF-8 CCSID 1208.
           88 C-ORM-CP-UTF8-V          VALUE 0.
      * @cond C-ORM-CP-ASCII-V ASCII CCSID 819.
           88 C-ORM-CP-ASCII-V         VALUE 1.
      * @cond C-ORM-CP-IBM037-V EBCDIC CCSID 37.
           88 C-ORM-CP-IBM037-V        VALUE 2.
      * @cond C-ORM-CP-IBM1047-V EBCDIC CCSID 1047.
           88 C-ORM-CP-IBM1047-V       VALUE 3.
      * @cond C-ORM-CP-IBM500-V EBCDIC CCSID 500.
           88 C-ORM-CP-IBM500-V        VALUE 4.
      * @cond C-ORM-CP-IBM1140-V EBCDIC CCSID 1140 Euro.
           88 C-ORM-CP-IBM1140-V       VALUE 5.
      * @field C-ORM-CPY-FMT Copybook source layout format selector.
           05 C-ORM-CPY-FMT            PIC S9(9) COMP-5 VALUE 0.
      * @cond C-ORM-FMT-AUTO Auto-detect fixed vs free.
           88 C-ORM-FMT-AUTO           VALUE 0.
      * @cond C-ORM-FMT-FIXED Fixed 80-column format.
           88 C-ORM-FMT-FIXED          VALUE 1.
      * @cond C-ORM-FMT-FREE Free format.
           88 C-ORM-FMT-FREE           VALUE 2.
      * @field C-ORM-ISOLATION Db2/ODBC transaction isolation level.
           05 C-ORM-ISOLATION          PIC S9(9) COMP-5 VALUE 1.
      * @cond C-ORM-ISO-UR-V Uncommitted Read.
           88 C-ORM-ISO-UR-V           VALUE 0.
      * @cond C-ORM-ISO-CS-V Cursor Stability.
           88 C-ORM-ISO-CS-V           VALUE 1.
      * @cond C-ORM-ISO-RS-V Read Stability.
           88 C-ORM-ISO-RS-V           VALUE 2.
      * @cond C-ORM-ISO-RR-V Repeatable Read.
           88 C-ORM-ISO-RR-V           VALUE 3.
      * @field C-ORM-JOIN-KIND AST SQL JOIN kind selector.
           05 C-ORM-JOIN-KIND          PIC S9(9) COMP-5 VALUE 0.
      * @cond C-ORM-JOIN-INNER-V INNER JOIN.
           88 C-ORM-JOIN-INNER-V       VALUE 0.
      * @cond C-ORM-JOIN-LEFT-V LEFT OUTER JOIN.
           88 C-ORM-JOIN-LEFT-V        VALUE 1.
      * @cond C-ORM-JOIN-RIGHT-V RIGHT OUTER JOIN.
           88 C-ORM-JOIN-RIGHT-V       VALUE 2.

      * @class C-ORM-DECIMAL-REC
      * @brief Exact 41-byte ABI mirror of cobol_orm_decimal_t.
       01 C-ORM-DECIMAL-REC.
      * @field C-ORM-DEC-SIGN Sign byte (0 positive, 1 negative).
           05 C-ORM-DEC-SIGN           PIC X(1) VALUE LOW-VALUE.
      * @field C-ORM-DEC-PREC Active precision digits (1..38).
           05 C-ORM-DEC-PREC           PIC X(1) VALUE LOW-VALUE.
      * @field C-ORM-DEC-SCALE Fractional scale digits (0..38).
           05 C-ORM-DEC-SCALE          PIC X(1) VALUE LOW-VALUE.
      * @field C-ORM-DEC-DIGITS Little-endian base-10 unpacked digits.
           05 C-ORM-DEC-DIGITS         PIC X(38) VALUE LOW-VALUES.

      * @class C-ORM-POOL-STATS-REC
      * @brief Exact 24-byte ABI mirror of cobol_orm_pool_stats_t.
       01 C-ORM-POOL-STATS-REC.
      * @field C-ORM-PS-ACTIVE Active leased connection count.
           05 C-ORM-PS-ACTIVE          PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-PS-IDLE Idle available connection count.
           05 C-ORM-PS-IDLE            PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-PS-EXHAUST Total pool exhaustion timeout events.
           05 C-ORM-PS-EXHAUST         PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-PS-SLOW Total slow queries logged.
           05 C-ORM-PS-SLOW            PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-PS-AVG-WAIT Average acquisition wait time in ms.
           05 C-ORM-PS-AVG-WAIT        USAGE COMP-2 VALUE 0.

      * @class C-ORM-CPY-INFO-REC
      * @brief Exact 12-byte ABI mirror of cobol_orm_cpy_info_t.
       01 C-ORM-CPY-INFO-REC.
      * @field C-ORM-CI-BYTES Total static wire byte length of 01 rec.
           05 C-ORM-CI-BYTES           PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-CI-FIELDS Number of mapped SQL columns.
           05 C-ORM-CI-FIELDS          PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-CI-DCLGEN Non-zero if EXEC SQL DECLARE was parsed.
           05 C-ORM-CI-DCLGEN          PIC S9(9) COMP-5 VALUE 0.

      * @class C-ORM-COL-INFO-REC
      * @brief Exact 16-byte ABI mirror of cobol_orm_col_info_t.
       01 C-ORM-COL-INFO-REC.
      * @field C-ORM-COL-OFFSET 0-based byte offset inside 01 record.
           05 C-ORM-COL-OFFSET         PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-COL-SIZE Wire byte length of field.
           05 C-ORM-COL-SIZE           PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-COL-USAGE COBOL USAGE kind code.
           05 C-ORM-COL-USAGE          PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-COL-DIGITS Total numeric digits.
           05 C-ORM-COL-DIGITS         PIC X(1) VALUE LOW-VALUE.
      * @field C-ORM-COL-FRAC Fractional digits after V.
           05 C-ORM-COL-FRAC           PIC X(1) VALUE LOW-VALUE.
      * @field C-ORM-COL-SIGNED Non-zero if signed.
           05 C-ORM-COL-SIGNED         PIC X(1) VALUE LOW-VALUE.
      * @field C-ORM-COL-IS-PK Non-zero if primary key column.
           05 C-ORM-COL-IS-PK          PIC X(1) VALUE LOW-VALUE.

      * @class C-ORM-COMMAREA-REC
      * @brief Exact 544-byte ABI mirror of cobol_orm_commarea_t.
       01 C-ORM-COMMAREA-REC.
      * @field C-ORM-CA-OPCODE Requested dispatch opcode (1..16).
           05 C-ORM-CA-OPCODE          PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-STATUS Returned cobol_orm_error_t status code.
           05 C-ORM-CA-STATUS          PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-DB-ID Integer DB handle slot ID (1..64).
           05 C-ORM-CA-DB-ID           PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-STMT-ID Integer statement slot ID (1..64).
           05 C-ORM-CA-STMT-ID         PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-PARAM-IDX 1-based param or 0-based col index.
           05 C-ORM-CA-PARAM-IDX       PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-VAL-I32 Signed 32-bit integer I/O slot.
           05 C-ORM-CA-VAL-I32         PIC S9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-D1-LEN Active byte length of C-ORM-CA-DATA1.
           05 C-ORM-CA-D1-LEN          PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-D2-LEN Output byte length in C-ORM-CA-DATA2.
           05 C-ORM-CA-D2-LEN          PIC 9(9) COMP-5 VALUE 0.
      * @field C-ORM-CA-DATA1 Input space-padded string buffer.
           05 C-ORM-CA-DATA1           PIC X(256) VALUE SPACES.
      * @field C-ORM-CA-DATA2 Output space-padded string buffer.
           05 C-ORM-CA-DATA2           PIC X(256) VALUE SPACES.
