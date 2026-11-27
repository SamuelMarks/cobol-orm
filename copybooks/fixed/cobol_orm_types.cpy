      * @file cobol_orm_types.cpy
      * @module cobol_orm_copybooks
      * @brief Strongly-typed opaque handle definitions, domain
      * enumerations, and
      * ABI-matched POD structures for COBOL-2002 / COBOL-2014 /
      * COBOL-2023.

      * @class C-ORM-HANDLES
      * @brief Strongly-typed level-01 opaque pointer handles for ISO
      * COBOL-2002+.
      * @field C-ORM-DB-PTR Opaque database connection handle pointer.
       01 C-ORM-DB-PTR                       USAGE POINTER VALUE NULL.
      * @field C-ORM-STMT-PTR Opaque prepared statement handle pointer.
       01 C-ORM-STMT-PTR                     USAGE POINTER VALUE NULL.
      * @field C-ORM-POOL-PTR Opaque connection pool handle pointer.
       01 C-ORM-POOL-PTR                     USAGE POINTER VALUE NULL.
      * @field C-ORM-AST-PTR Opaque fluent AST query builder handle
      * pointer.
       01 C-ORM-AST-PTR                      USAGE POINTER VALUE NULL.
      * @field C-ORM-CPY-PTR Opaque parsed Copybook handle pointer.
       01 C-ORM-CPY-PTR                      USAGE POINTER VALUE NULL.
      * @field C-ORM-RS-PTR Opaque dynamic result-set handle pointer.
       01 C-ORM-RS-PTR                       USAGE POINTER VALUE NULL.
      * @field C-ORM-MIG-PTR Opaque migration runner handle pointer.
       01 C-ORM-MIG-PTR                      USAGE POINTER VALUE NULL.

      * @class C-ORM-ENUM-DOMAINS
      * @brief Strongly-typed domain enum variables with level-88
      * condition names.
       01 C-ORM-ENUM-DOMAINS.
      * @field C-ORM-DIALECT Target SQL dialect selector.
           05 C-ORM-DIALECT USAGE BINARY-LONG SIGNED VALUE 0.
      * @cond C-ORM-DL-SQLITE SQLite SQL dialect.
           88 C-ORM-DL-SQLITE              VALUE 0.
      * @cond C-ORM-DL-POSTGRES PostgreSQL SQL dialect.
           88 C-ORM-DL-POSTGRES            VALUE 1.
      * @cond C-ORM-DL-MYSQL MySQL/MariaDB SQL dialect.
           88 C-ORM-DL-MYSQL               VALUE 2.
      * @cond C-ORM-DL-DB2 IBM Db2 SQL dialect.
           88 C-ORM-DL-DB2                 VALUE 3.
      * @cond C-ORM-DL-ODBC Generic ANSI/ODBC SQL dialect.
           88 C-ORM-DL-ODBC                VALUE 4.
      * @field C-ORM-ROUND-MODE Fixed-point decimal rounding mode.
           05 C-ORM-ROUND-MODE USAGE BINARY-LONG SIGNED VALUE 0.
      * @cond C-ORM-RND-TRUNC Truncate toward zero.
           88 C-ORM-RND-TRUNC              VALUE 0.
      * @cond C-ORM-RND-HALF-UP Round half away from zero.
           88 C-ORM-RND-HALF-UP            VALUE 1.
      * @cond C-ORM-RND-HALF-EVEN Banker rounding.
           88 C-ORM-RND-HALF-EVEN          VALUE 2.
      * @cond C-ORM-RND-EXACT Error if inexact.
           88 C-ORM-RND-EXACT              VALUE 3.
      * @field C-ORM-CODEPAGE Character codepage / IBM CCSID selector.
           05 C-ORM-CODEPAGE USAGE BINARY-LONG SIGNED VALUE 0.
      * @cond C-ORM-CP-UTF8-V UTF-8 CCSID 1208.
           88 C-ORM-CP-UTF8-V              VALUE 0.
      * @cond C-ORM-CP-ASCII-V ASCII CCSID 819.
           88 C-ORM-CP-ASCII-V             VALUE 1.
      * @cond C-ORM-CP-IBM037-V EBCDIC CCSID 37.
           88 C-ORM-CP-IBM037-V            VALUE 2.
      * @cond C-ORM-CP-IBM1047-V EBCDIC CCSID 1047.
           88 C-ORM-CP-IBM1047-V           VALUE 3.
      * @cond C-ORM-CP-IBM500-V EBCDIC CCSID 500.
           88 C-ORM-CP-IBM500-V            VALUE 4.
      * @cond C-ORM-CP-IBM1140-V EBCDIC CCSID 1140 Euro.
           88 C-ORM-CP-IBM1140-V           VALUE 5.
      * @field C-ORM-CPY-FMT Copybook source layout format selector.
           05 C-ORM-CPY-FMT USAGE BINARY-LONG SIGNED VALUE 0.
      * @cond C-ORM-FMT-AUTO Auto-detect fixed vs free.
           88 C-ORM-FMT-AUTO               VALUE 0.
      * @cond C-ORM-FMT-FIXED Fixed 80-column format.
           88 C-ORM-FMT-FIXED              VALUE 1.
      * @cond C-ORM-FMT-FREE Free format.
           88 C-ORM-FMT-FREE               VALUE 2.
      * @field C-ORM-ISOLATION Db2/ODBC transaction isolation level.
           05 C-ORM-ISOLATION USAGE BINARY-LONG SIGNED VALUE 1.
      * @cond C-ORM-ISO-UR-V Uncommitted Read.
           88 C-ORM-ISO-UR-V               VALUE 0.
      * @cond C-ORM-ISO-CS-V Cursor Stability.
           88 C-ORM-ISO-CS-V               VALUE 1.
      * @cond C-ORM-ISO-RS-V Read Stability.
           88 C-ORM-ISO-RS-V               VALUE 2.
      * @cond C-ORM-ISO-RR-V Repeatable Read.
           88 C-ORM-ISO-RR-V               VALUE 3.
      * @field C-ORM-JOIN-KIND AST SQL JOIN kind selector.
           05 C-ORM-JOIN-KIND USAGE BINARY-LONG SIGNED VALUE 0.
      * @cond C-ORM-JOIN-INNER-V INNER JOIN.
           88 C-ORM-JOIN-INNER-V           VALUE 0.
      * @cond C-ORM-JOIN-LEFT-V LEFT OUTER JOIN.
           88 C-ORM-JOIN-LEFT-V            VALUE 1.
      * @cond C-ORM-JOIN-RIGHT-V RIGHT OUTER JOIN.
           88 C-ORM-JOIN-RIGHT-V           VALUE 2.

      * @class C-ORM-DECIMAL-REC
      * @brief Exact 41-byte ABI mirror of cobol_orm_decimal_t.
       01 C-ORM-DECIMAL-REC.
      * @field C-ORM-DEC-SIGN Sign byte (0 positive, 1 negative).
           05 C-ORM-DEC-SIGN USAGE BINARY-CHAR UNSIGNED VALUE 0.
      * @field C-ORM-DEC-PREC Active precision digits (1..38).
           05 C-ORM-DEC-PREC USAGE BINARY-CHAR UNSIGNED VALUE 1.
      * @field C-ORM-DEC-SCALE Fractional scale digits (0..38).
           05 C-ORM-DEC-SCALE USAGE BINARY-CHAR UNSIGNED VALUE 0.
      * @field C-ORM-DEC-DIGITS Little-endian base-10 unpacked digits.
           05 C-ORM-DEC-DIGITS PIC X(38) VALUE LOW-VALUES.

      * @class C-ORM-POOL-STATS-REC
      * @brief Exact 24-byte ABI mirror of cobol_orm_pool_stats_t.
       01 C-ORM-POOL-STATS-REC.
      * @field C-ORM-PS-ACTIVE Active leased connection count.
           05 C-ORM-PS-ACTIVE USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-PS-IDLE Idle available connection count.
           05 C-ORM-PS-IDLE USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-PS-EXHAUST Total pool exhaustion timeout events.
           05 C-ORM-PS-EXHAUST USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-PS-SLOW Total slow queries logged.
           05 C-ORM-PS-SLOW USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-PS-AVG-WAIT Average acquisition wait time in ms.
           05 C-ORM-PS-AVG-WAIT               USAGE FLOAT-LONG VALUE 0.

      * @class C-ORM-CPY-INFO-REC
      * @brief Exact 12-byte ABI mirror of cobol_orm_cpy_info_t.
       01 C-ORM-CPY-INFO-REC.
      * @field C-ORM-CI-BYTES Total static wire byte length of 01
      * record.
           05 C-ORM-CI-BYTES USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-CI-FIELDS Number of mapped SQL columns.
           05 C-ORM-CI-FIELDS USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-CI-DCLGEN Non-zero if EXEC SQL DECLARE was parsed.
           05 C-ORM-CI-DCLGEN USAGE BINARY-LONG SIGNED VALUE 0.

      * @class C-ORM-COL-INFO-REC
      * @brief Exact 16-byte ABI mirror of cobol_orm_col_info_t.
       01 C-ORM-COL-INFO-REC.
      * @field C-ORM-COL-OFFSET 0-based byte offset inside 01 record.
           05 C-ORM-COL-OFFSET USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-COL-SIZE Wire byte length of field.
           05 C-ORM-COL-SIZE USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-COL-USAGE COBOL USAGE kind code.
           05 C-ORM-COL-USAGE USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-COL-DIGITS Total numeric digits.
           05 C-ORM-COL-DIGITS USAGE BINARY-CHAR UNSIGNED VALUE 0.
      * @field C-ORM-COL-FRAC Fractional digits after V.
           05 C-ORM-COL-FRAC USAGE BINARY-CHAR UNSIGNED VALUE 0.
      * @field C-ORM-COL-SIGNED Non-zero if signed.
           05 C-ORM-COL-SIGNED USAGE BINARY-CHAR UNSIGNED VALUE 0.
      * @field C-ORM-COL-IS-PK Non-zero if primary key column.
           05 C-ORM-COL-IS-PK USAGE BINARY-CHAR UNSIGNED VALUE 0.

      * @class C-ORM-COMMAREA-REC
      * @brief Exact 544-byte ABI mirror of cobol_orm_commarea_t for
      * legacy callers.
       01 C-ORM-COMMAREA-REC.
      * @field C-ORM-CA-OPCODE Requested dispatch opcode (1..16).
           05 C-ORM-CA-OPCODE USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-CA-STATUS Returned cobol_orm_error_t status code.
           05 C-ORM-CA-STATUS USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-CA-DB-ID Integer DB handle slot ID (1..64).
           05 C-ORM-CA-DB-ID USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-CA-STMT-ID Integer statement handle slot ID
      * (1..64).
           05 C-ORM-CA-STMT-ID USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-CA-PARAM-IDX 1-based parameter or 0-based column
      * index.
           05 C-ORM-CA-PARAM-IDX USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-CA-VAL-I32 Signed 32-bit integer input/output slot.
           05 C-ORM-CA-VAL-I32 USAGE BINARY-LONG SIGNED VALUE 0.
      * @field C-ORM-CA-D1-LEN Active byte length of C-ORM-CA-DATA1.
           05 C-ORM-CA-D1-LEN USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-CA-D2-LEN Output byte length written to
      * C-ORM-CA-DATA2.
           05 C-ORM-CA-D2-LEN USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field C-ORM-CA-DATA1 Input space-padded string buffer.
           05 C-ORM-CA-DATA1                  PIC X(256) VALUE SPACES.
      * @field C-ORM-CA-DATA2 Output space-padded string buffer.
           05 C-ORM-CA-DATA2                  PIC X(256) VALUE SPACES.
