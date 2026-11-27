      *> @file cobol_orm.cpy
      *> @brief Auto-generated Dual Fixed/Free COBOL ABI Copybook.
      *> @module COBOL-ORM
      *> @details Byte-exact C ABI constants, enums, and records.
      *> @record CDD-FFI-ABI-READY Sentinel ABI readiness constant.
       01 CDD-FFI-ABI-READY CONSTANT AS 1.

      *> | Maximum decimal digits in cobol_orm_decimal_t.
      *> @record COBOL-ORM-DECIMAL-MAX-DIGITS C ABI item.
       01 COBOL-ORM-DECIMAL-MAX-DIGITS CONSTANT AS 38.

      *> | Fixed COMMAREA string buffer capacity.
      *> @record COBOL-ORM-COMMAREA-DATA-CAP C ABI item.
       01 COBOL-ORM-COMMAREA-DATA-CAP CONSTANT AS 256.

      *> | Fixed USAGE DISPLAY COMMAREA byte length.
      *> @record COBOL-ORM-DISPLAY-COMMAREA-57C C ABI item.
       01 COBOL-ORM-DISPLAY-COMMAREA-57C CONSTANT AS 552.

      *> | Maximum concurrent legacy handle slots.
      *> @record COBOL-ORM-LEGACY-MAX-HANDLES C ABI item.
       01 COBOL-ORM-LEGACY-MAX-HANDLES CONSTANT AS 64.

      *> | Library semantic version string.
      *> @record COBOL-ORM-VERSION-STR C ABI item.
       01 COBOL-ORM-VERSION-STR CONSTANT AS "0.1.0".

      *> | @brief Unified error status codes returned by every cobol-orm
      *> | function.
      *> | Values 0..31 match `c_orm_error_t` 1:1 for lossless error
      *> | percolation across
      *> | the C89 and COBOL FFI boundary. Values 32..36 represent COBOL
      *> | FFI facade and
      *> | legacy integer-handle / COMMAREA dispatch errors.
      *> | @brief Operation succeeded.
      *> @record COBOL-ORM-OK C ABI item.
       01 COBOL-ORM-OK CONSTANT AS 0.
      *> | @brief Out of memory / allocation failure.
      *> @record COBOL-ORM-ERROR-MEMORY C ABI item.
       01 COBOL-ORM-ERROR-MEMORY CONSTANT AS 1.
      *> | @brief Database connection failure.
      *> @record COBOL-ORM-ERROR-CONNECTION C ABI item.
       01 COBOL-ORM-ERROR-CONNECTION CONSTANT AS 2.
      *> | @brief SQL syntax or execution error.
      *> @record COBOL-ORM-ERROR-SQL C ABI item.
       01 COBOL-ORM-ERROR-SQL CONSTANT AS 3.
      *> | @brief Statement parameter bind failure.
      *> @record COBOL-ORM-ERROR-BIND C ABI item.
       01 COBOL-ORM-ERROR-BIND CONSTANT AS 4.
      *> | @brief Statement step execution failure.
      *> @record COBOL-ORM-ERROR-STEP C ABI item.
       01 COBOL-ORM-ERROR-STEP CONSTANT AS 5.
      *> | @brief Column or value type mismatch.
      *> @record COBOL-ORM-ERROR-TYPE-MISMATCH C ABI item.
       01 COBOL-ORM-ERROR-TYPE-MISMATCH CONSTANT AS 6.
      *> | @brief Requested row, column, or handle not found.
      *> @record COBOL-ORM-ERROR-NOT-FOUND C ABI item.
       01 COBOL-ORM-ERROR-NOT-FOUND CONSTANT AS 7.
      *> | @brief Feature or driver capability not implemented.
      *> @record COBOL-ORM-ERROR-NOT-IMPLEM-D91 C ABI item.
       01 COBOL-ORM-ERROR-NOT-IMPLEM-D91 CONSTANT AS 8.
      *> | @brief Unclassified internal error.
      *> @record COBOL-ORM-ERROR-UNKNOWN C ABI item.
       01 COBOL-ORM-ERROR-UNKNOWN CONSTANT AS 9.
      *> | @brief Session or identity-map record expired.
      *> @record COBOL-ORM-ERROR-EXPIRED C ABI item.
       01 COBOL-ORM-ERROR-EXPIRED CONSTANT AS 10.
      *> | @brief Invalid argument or domain/level-88 validation
      *> | failure.
      *> @record COBOL-ORM-ERROR-VALIDATION C ABI item.
       01 COBOL-ORM-ERROR-VALIDATION CONSTANT AS 11.
      *> | @brief Cyclic recursion limit exceeded.
      *> @record COBOL-ORM-ERROR-RECURSION C ABI item.
       01 COBOL-ORM-ERROR-RECURSION CONSTANT AS 12.
      *> | @brief Write attempted on read-only database or resource.
      *> @record COBOL-ORM-ERROR-READ-ONLY C ABI item.
       01 COBOL-ORM-ERROR-READ-ONLY CONSTANT AS 13.
      *> | @brief Required pointer argument was NULL.
      *> @record COBOL-ORM-ERROR-NULL-POINTER C ABI item.
       01 COBOL-ORM-ERROR-NULL-POINTER CONSTANT AS 14.
      *> | @brief File or stream I/O failure.
      *> @record COBOL-ORM-ERROR-IO C ABI item.
       01 COBOL-ORM-ERROR-IO CONSTANT AS 15.
      *> | @brief Input or SQL parse failure.
      *> @record COBOL-ORM-ERROR-PARSE C ABI item.
       01 COBOL-ORM-ERROR-PARSE CONSTANT AS 16.
      *> | @brief Buffer or integer capacity overflow.
      *> @record COBOL-ORM-ERROR-OVERFLOW C ABI item.
       01 COBOL-ORM-ERROR-OVERFLOW CONSTANT AS 17.
      *> | @brief Dependency cycle detected.
      *> @record COBOL-ORM-ERROR-CYCLE C ABI item.
       01 COBOL-ORM-ERROR-CYCLE CONSTANT AS 18.
      *> | @brief Database or synchronization lock busy.
      *> @record COBOL-ORM-ERROR-BUSY C ABI item.
       01 COBOL-ORM-ERROR-BUSY CONSTANT AS 19.
      *> | @brief Cryptographic hook failure.
      *> @record COBOL-ORM-ERROR-CRYPTO C ABI item.
       01 COBOL-ORM-ERROR-CRYPTO CONSTANT AS 20.
      *> | @brief Unique, foreign-key, or CHECK constraint violation.
      *> @record COBOL-ORM-ERROR-CONSTRAINT C ABI item.
       01 COBOL-ORM-ERROR-CONSTRAINT CONSTANT AS 21.
      *> | @brief Dynamic database client library failed to load.
      *> @record COBOL-ORM-ERROR-DRIVER-LOAD C ABI item.
       01 COBOL-ORM-ERROR-DRIVER-LOAD CONSTANT AS 22.
      *> | @brief Underlying ODBC or IBM Db2 CLI diagnostic error.
      *> @record COBOL-ORM-ERROR-ODBC-DIAG C ABI item.
       01 COBOL-ORM-ERROR-ODBC-DIAG CONSTANT AS 23.
      *> | @brief Login, pool acquisition, or query timeout.
      *> @record COBOL-ORM-ERROR-TIMEOUT C ABI item.
       01 COBOL-ORM-ERROR-TIMEOUT CONSTANT AS 24.
      *> | @brief Serialization failure or deadlock victim.
      *> @record COBOL-ORM-ERROR-DEADLOCK C ABI item.
       01 COBOL-ORM-ERROR-DEADLOCK CONSTANT AS 25.
      *> | @brief Disallowed string, binary, or fractional truncation.
      *> @record COBOL-ORM-ERROR-TRUNCATION C ABI item.
       01 COBOL-ORM-ERROR-TRUNCATION CONSTANT AS 26.
      *> | @brief Malformed decimal string or invalid BCD/COMP-3 sign
      *> | nybble.
      *> @record COBOL-ORM-ERROR-DECIMAL-SYNTAX C ABI item.
       01 COBOL-ORM-ERROR-DECIMAL-SYNTAX CONSTANT AS 27.
      *> | @brief Decimal precision exceeded or division by zero.
      *> @record COBOL-ORM-ERROR-DECIMAL-OV-440 C ABI item.
       01 COBOL-ORM-ERROR-DECIMAL-OV-440 CONSTANT AS 28.
      *> | @brief Non-zero digits lost under exact rounding mode.
      *> @record COBOL-ORM-ERROR-DECIMAL-IN-8BF C ABI item.
       01 COBOL-ORM-ERROR-DECIMAL-IN-8BF CONSTANT AS 29.
      *> | @brief Unmappable character or malformed UTF/EBCDIC sequence.
      *> @record COBOL-ORM-ERROR-CODEPAGE C ABI item.
       01 COBOL-ORM-ERROR-CODEPAGE CONSTANT AS 30.
      *> | @brief COBOL Copybook (.cpy) lexer or parser syntax error.
      *> @record COBOL-ORM-ERROR-COPYBOOK-S-499 C ABI item.
       01 COBOL-ORM-ERROR-COPYBOOK-S-499 CONSTANT AS 31.
      *> | @brief Opaque handle is invalid, corrupted, or already
      *> | closed.
      *> @record COBOL-ORM-ERROR-INVALID-HANDLE C ABI item.
       01 COBOL-ORM-ERROR-INVALID-HANDLE CONSTANT AS 32.
      *> | @brief Caller-provided output buffer capacity is
      *> | insufficient.
      *> @record COBOL-ORM-ERROR-BUFFER-TOO-40F C ABI item.
       01 COBOL-ORM-ERROR-BUFFER-TOO-40F CONSTANT AS 33.
      *> | @brief Operation requires an active database connection.
      *> @record COBOL-ORM-ERROR-NOT-CONNECTED C ABI item.
       01 COBOL-ORM-ERROR-NOT-CONNECTED CONSTANT AS 34.
      *> | @brief Legacy integer handle registry has no free slots
      *> | available.
      *> @record COBOL-ORM-ERROR-HANDLE-TAB-81E C ABI item.
       01 COBOL-ORM-ERROR-HANDLE-TAB-81E CONSTANT AS 35.
      *> | @brief Unsupported legacy COMMAREA dispatch opcode.
      *> @record COBOL-ORM-ERROR-INVALID-OPCODE C ABI item.
       01 COBOL-ORM-ERROR-INVALID-OPCODE CONSTANT AS 36.
      *> @record COBOL-ORM-ERROR-ITEM C ABI item.
       01 COBOL-ORM-ERROR-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-OK C ABI item.
          88 IS-COBOL-ORM-OK VALUE 0.
      *> @field IS-COBOL-ORM-ERROR-MEMORY C ABI item.
          88 IS-COBOL-ORM-ERROR-MEMORY VALUE 1.
      *> @field IS-COBOL-ORM-ERROR-CONNECTION C ABI item.
          88 IS-COBOL-ORM-ERROR-CONNECTION VALUE 2.
      *> @field IS-COBOL-ORM-ERROR-SQL C ABI item.
          88 IS-COBOL-ORM-ERROR-SQL VALUE 3.
      *> @field IS-COBOL-ORM-ERROR-BIND C ABI item.
          88 IS-COBOL-ORM-ERROR-BIND VALUE 4.
      *> @field IS-COBOL-ORM-ERROR-STEP C ABI item.
          88 IS-COBOL-ORM-ERROR-STEP VALUE 5.
      *> @field IS-COBOL-ORM-ERROR-TYPE-MI-06F C ABI item.
          88 IS-COBOL-ORM-ERROR-TYPE-MI-06F VALUE 6.
      *> @field IS-COBOL-ORM-ERROR-NOT-FOUND C ABI item.
          88 IS-COBOL-ORM-ERROR-NOT-FOUND VALUE 7.
      *> @field IS-COBOL-ORM-ERROR-NOT-IMP-D91 C ABI item.
          88 IS-COBOL-ORM-ERROR-NOT-IMP-D91 VALUE 8.
      *> @field IS-COBOL-ORM-ERROR-UNKNOWN C ABI item.
          88 IS-COBOL-ORM-ERROR-UNKNOWN VALUE 9.
      *> @field IS-COBOL-ORM-ERROR-EXPIRED C ABI item.
          88 IS-COBOL-ORM-ERROR-EXPIRED VALUE 10.
      *> @field IS-COBOL-ORM-ERROR-VALIDATION C ABI item.
          88 IS-COBOL-ORM-ERROR-VALIDATION VALUE 11.
      *> @field IS-COBOL-ORM-ERROR-RECURSION C ABI item.
          88 IS-COBOL-ORM-ERROR-RECURSION VALUE 12.
      *> @field IS-COBOL-ORM-ERROR-READ-ONLY C ABI item.
          88 IS-COBOL-ORM-ERROR-READ-ONLY VALUE 13.
      *> @field IS-COBOL-ORM-ERROR-NULL-PO-FB9 C ABI item.
          88 IS-COBOL-ORM-ERROR-NULL-PO-FB9 VALUE 14.
      *> @field IS-COBOL-ORM-ERROR-IO C ABI item.
          88 IS-COBOL-ORM-ERROR-IO VALUE 15.
      *> @field IS-COBOL-ORM-ERROR-PARSE C ABI item.
          88 IS-COBOL-ORM-ERROR-PARSE VALUE 16.
      *> @field IS-COBOL-ORM-ERROR-OVERFLOW C ABI item.
          88 IS-COBOL-ORM-ERROR-OVERFLOW VALUE 17.
      *> @field IS-COBOL-ORM-ERROR-CYCLE C ABI item.
          88 IS-COBOL-ORM-ERROR-CYCLE VALUE 18.
      *> @field IS-COBOL-ORM-ERROR-BUSY C ABI item.
          88 IS-COBOL-ORM-ERROR-BUSY VALUE 19.
      *> @field IS-COBOL-ORM-ERROR-CRYPTO C ABI item.
          88 IS-COBOL-ORM-ERROR-CRYPTO VALUE 20.
      *> @field IS-COBOL-ORM-ERROR-CONSTRAINT C ABI item.
          88 IS-COBOL-ORM-ERROR-CONSTRAINT VALUE 21.
      *> @field IS-COBOL-ORM-ERROR-DRIVER-LOAD C ABI item.
          88 IS-COBOL-ORM-ERROR-DRIVER-LOAD VALUE 22.
      *> @field IS-COBOL-ORM-ERROR-ODBC-DIAG C ABI item.
          88 IS-COBOL-ORM-ERROR-ODBC-DIAG VALUE 23.
      *> @field IS-COBOL-ORM-ERROR-TIMEOUT C ABI item.
          88 IS-COBOL-ORM-ERROR-TIMEOUT VALUE 24.
      *> @field IS-COBOL-ORM-ERROR-DEADLOCK C ABI item.
          88 IS-COBOL-ORM-ERROR-DEADLOCK VALUE 25.
      *> @field IS-COBOL-ORM-ERROR-TRUNCATION C ABI item.
          88 IS-COBOL-ORM-ERROR-TRUNCATION VALUE 26.
      *> @field IS-COBOL-ORM-ERROR-DECIMAL-4AA C ABI item.
          88 IS-COBOL-ORM-ERROR-DECIMAL-4AA VALUE 27.
      *> @field IS-COBOL-ORM-ERROR-DECIMAL-440 C ABI item.
          88 IS-COBOL-ORM-ERROR-DECIMAL-440 VALUE 28.
      *> @field IS-COBOL-ORM-ERROR-DECIMAL-8BF C ABI item.
          88 IS-COBOL-ORM-ERROR-DECIMAL-8BF VALUE 29.
      *> @field IS-COBOL-ORM-ERROR-CODEPAGE C ABI item.
          88 IS-COBOL-ORM-ERROR-CODEPAGE VALUE 30.
      *> @field IS-COBOL-ORM-ERROR-COPYBOO-499 C ABI item.
          88 IS-COBOL-ORM-ERROR-COPYBOO-499 VALUE 31.
      *> @field IS-COBOL-ORM-ERROR-INVALID-C96 C ABI item.
          88 IS-COBOL-ORM-ERROR-INVALID-C96 VALUE 32.
      *> @field IS-COBOL-ORM-ERROR-BUFFER-40F C ABI item.
          88 IS-COBOL-ORM-ERROR-BUFFER-40F VALUE 33.
      *> @field IS-COBOL-ORM-ERROR-NOT-CON-F94 C ABI item.
          88 IS-COBOL-ORM-ERROR-NOT-CON-F94 VALUE 34.
      *> @field IS-COBOL-ORM-ERROR-HANDLE-81E C ABI item.
          88 IS-COBOL-ORM-ERROR-HANDLE-81E VALUE 35.
      *> @field IS-COBOL-ORM-ERROR-INVALID-219 C ABI item.
          88 IS-COBOL-ORM-ERROR-INVALID-219 VALUE 36.

      *> @record COBOL-ORM-DB-HANDLE C ABI item.
       01 COBOL-ORM-DB-HANDLE USAGE POINTER.

      *> @record COBOL-ORM-STMT-HANDLE C ABI item.
       01 COBOL-ORM-STMT-HANDLE USAGE POINTER.

      *> @record COBOL-ORM-POOL-HANDLE C ABI item.
       01 COBOL-ORM-POOL-HANDLE USAGE POINTER.

      *> @record COBOL-ORM-AST-HANDLE C ABI item.
       01 COBOL-ORM-AST-HANDLE USAGE POINTER.

      *> @record COBOL-ORM-CPY-HANDLE C ABI item.
       01 COBOL-ORM-CPY-HANDLE USAGE POINTER.

      *> @record COBOL-ORM-RS-HANDLE C ABI item.
       01 COBOL-ORM-RS-HANDLE USAGE POINTER.

      *> @record COBOL-ORM-MIG-HANDLE C ABI item.
       01 COBOL-ORM-MIG-HANDLE USAGE POINTER.

      *> | @brief SQL dialect identifiers for query and DDL generation.
      *> | @brief SQLite dialect (`?` placeholders, `LIMIT`/`OFFSET`).
      *> @record COBOL-ORM-DIALECT-SQLITE C ABI item.
       01 COBOL-ORM-DIALECT-SQLITE CONSTANT AS 0.
      *> | @brief PostgreSQL dialect (`$1..$N` placeholders).
      *> @record COBOL-ORM-DIALECT-POSTGRES C ABI item.
       01 COBOL-ORM-DIALECT-POSTGRES CONSTANT AS 1.
      *> | @brief MySQL / MariaDB dialect.
      *> @record COBOL-ORM-DIALECT-MYSQL C ABI item.
       01 COBOL-ORM-DIALECT-MYSQL CONSTANT AS 2.
      *> | @brief IBM Db2 dialect (`FETCH FIRST`, `MERGE INTO`, `WITH
      *> | UR/CS/RS/RR`).
      *> @record COBOL-ORM-DIALECT-DB2 C ABI item.
       01 COBOL-ORM-DIALECT-DB2 CONSTANT AS 3.
      *> | @brief Generic ANSI / ODBC 3.52 dialect.
      *> @record COBOL-ORM-DIALECT-ODBC C ABI item.
       01 COBOL-ORM-DIALECT-ODBC CONSTANT AS 4.
      *> @record COBOL-ORM-DIALECT-ITEM C ABI item.
       01 COBOL-ORM-DIALECT-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-DIALECT-SQLITE C ABI item.
          88 IS-COBOL-ORM-DIALECT-SQLITE VALUE 0.
      *> @field IS-COBOL-ORM-DIALECT-POSTGRES C ABI item.
          88 IS-COBOL-ORM-DIALECT-POSTGRES VALUE 1.
      *> @field IS-COBOL-ORM-DIALECT-MYSQL C ABI item.
          88 IS-COBOL-ORM-DIALECT-MYSQL VALUE 2.
      *> @field IS-COBOL-ORM-DIALECT-DB2 C ABI item.
          88 IS-COBOL-ORM-DIALECT-DB2 VALUE 3.
      *> @field IS-COBOL-ORM-DIALECT-ODBC C ABI item.
          88 IS-COBOL-ORM-DIALECT-ODBC VALUE 4.

      *> | @brief Rounding modes for lossless 38-digit fixed-point
      *> | decimal operations.
      *> | @brief Truncate toward zero (standard COBOL default).
      *> @record COBOL-ORM-ROUND-TRUNCATE C ABI item.
       01 COBOL-ORM-ROUND-TRUNCATE CONSTANT AS 0.
      *> | @brief Round half away from zero (COBOL `ROUNDED`).
      *> @record COBOL-ORM-ROUND-HALF-UP C ABI item.
       01 COBOL-ORM-ROUND-HALF-UP CONSTANT AS 1.
      *> | @brief Round half to even (IBM Db2 Banker's rounding).
      *> @record COBOL-ORM-ROUND-HALF-EVEN C ABI item.
       01 COBOL-ORM-ROUND-HALF-EVEN CONSTANT AS 2.
      *> | @brief Reject any non-zero discarded digits with
      *> | `DECIMAL_INEXACT`.
      *> @record COBOL-ORM-ROUND-ERROR-IF-I-C7C C ABI item.
       01 COBOL-ORM-ROUND-ERROR-IF-I-C7C CONSTANT AS 3.
      *> @record COBOL-ORM-ROUND-MODE-ITEM C ABI item.
       01 COBOL-ORM-ROUND-MODE-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-ROUND-TRUNCATE C ABI item.
          88 IS-COBOL-ORM-ROUND-TRUNCATE VALUE 0.
      *> @field IS-COBOL-ORM-ROUND-HALF-UP C ABI item.
          88 IS-COBOL-ORM-ROUND-HALF-UP VALUE 1.
      *> @field IS-COBOL-ORM-ROUND-HALF-EVEN C ABI item.
          88 IS-COBOL-ORM-ROUND-HALF-EVEN VALUE 2.
      *> @field IS-COBOL-ORM-ROUND-ERROR-I-C7C C ABI item.
          88 IS-COBOL-ORM-ROUND-ERROR-I-C7C VALUE 3.

      *> | @brief Character codepages and IBM CCSIDs for EBCDIC /
      *> | mainframe interop.
      *> | @brief UTF-8 (CCSID 1208).
      *> @record COBOL-ORM-CP-UTF8 C ABI item.
       01 COBOL-ORM-CP-UTF8 CONSTANT AS 0.
      *> | @brief 7-bit ASCII / ISO-8859-1 (CCSID 367/819).
      *> @record COBOL-ORM-CP-ASCII C ABI item.
       01 COBOL-ORM-CP-ASCII CONSTANT AS 1.
      *> | @brief US/Canada z/OS MVS & Db2 EBCDIC (CCSID 37).
      *> @record COBOL-ORM-CP-IBM037 C ABI item.
       01 COBOL-ORM-CP-IBM037 CONSTANT AS 2.
      *> | @brief z/OS USS C/COBOL EBCDIC (CCSID 1047).
      *> @record COBOL-ORM-CP-IBM1047 C ABI item.
       01 COBOL-ORM-CP-IBM1047 CONSTANT AS 3.
      *> | @brief International EBCDIC (CCSID 500).
      *> @record COBOL-ORM-CP-IBM500 C ABI item.
       01 COBOL-ORM-CP-IBM500 CONSTANT AS 4.
      *> | @brief US/Canada EBCDIC with Euro U+20AC (CCSID 1140).
      *> @record COBOL-ORM-CP-IBM1140 C ABI item.
       01 COBOL-ORM-CP-IBM1140 CONSTANT AS 5.
      *> @record COBOL-ORM-CODEPAGE-ITEM C ABI item.
       01 COBOL-ORM-CODEPAGE-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-CP-UTF8 C ABI item.
          88 IS-COBOL-ORM-CP-UTF8 VALUE 0.
      *> @field IS-COBOL-ORM-CP-ASCII C ABI item.
          88 IS-COBOL-ORM-CP-ASCII VALUE 1.
      *> @field IS-COBOL-ORM-CP-IBM037 C ABI item.
          88 IS-COBOL-ORM-CP-IBM037 VALUE 2.
      *> @field IS-COBOL-ORM-CP-IBM1047 C ABI item.
          88 IS-COBOL-ORM-CP-IBM1047 VALUE 3.
      *> @field IS-COBOL-ORM-CP-IBM500 C ABI item.
          88 IS-COBOL-ORM-CP-IBM500 VALUE 4.
      *> @field IS-COBOL-ORM-CP-IBM1140 C ABI item.
          88 IS-COBOL-ORM-CP-IBM1140 VALUE 5.

      *> | @brief COBOL Copybook source column layout format.
      *> | @brief Automatically detect fixed vs. free format.
      *> @record COBOL-ORM-CPY-FORMAT-AUTO C ABI item.
       01 COBOL-ORM-CPY-FORMAT-AUTO CONSTANT AS 0.
      *> | @brief Strict 80-column fixed format (cols 7-72).
      *> @record COBOL-ORM-CPY-FORMAT-FIXED C ABI item.
       01 COBOL-ORM-CPY-FORMAT-FIXED CONSTANT AS 1.
      *> | @brief Modern COBOL free format.
      *> @record COBOL-ORM-CPY-FORMAT-FREE C ABI item.
       01 COBOL-ORM-CPY-FORMAT-FREE CONSTANT AS 2.
      *> @record COBOL-ORM-CPY-FORMAT-ITEM C ABI item.
       01 COBOL-ORM-CPY-FORMAT-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-CPY-FORMAT-AUTO C ABI item.
          88 IS-COBOL-ORM-CPY-FORMAT-AUTO VALUE 0.
      *> @field IS-COBOL-ORM-CPY-FORMAT-FIXED C ABI item.
          88 IS-COBOL-ORM-CPY-FORMAT-FIXED VALUE 1.
      *> @field IS-COBOL-ORM-CPY-FORMAT-FREE C ABI item.
          88 IS-COBOL-ORM-CPY-FORMAT-FREE VALUE 2.

      *> | @brief Transaction isolation levels for IBM Db2 and Generic
      *> | ODBC.
      *> | @brief Uncommitted Read (`WITH UR`).
      *> @record COBOL-ORM-ISO-UR C ABI item.
       01 COBOL-ORM-ISO-UR CONSTANT AS 0.
      *> | @brief Cursor Stability (`WITH CS`).
      *> @record COBOL-ORM-ISO-CS C ABI item.
       01 COBOL-ORM-ISO-CS CONSTANT AS 1.
      *> | @brief Read Stability (`WITH RS`).
      *> @record COBOL-ORM-ISO-RS C ABI item.
       01 COBOL-ORM-ISO-RS CONSTANT AS 2.
      *> | @brief Repeatable Read (`WITH RR`).
      *> @record COBOL-ORM-ISO-RR C ABI item.
       01 COBOL-ORM-ISO-RR CONSTANT AS 3.
      *> @record COBOL-ORM-ISOLATION-ITEM C ABI item.
       01 COBOL-ORM-ISOLATION-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-ISO-UR C ABI item.
          88 IS-COBOL-ORM-ISO-UR VALUE 0.
      *> @field IS-COBOL-ORM-ISO-CS C ABI item.
          88 IS-COBOL-ORM-ISO-CS VALUE 1.
      *> @field IS-COBOL-ORM-ISO-RS C ABI item.
          88 IS-COBOL-ORM-ISO-RS VALUE 2.
      *> @field IS-COBOL-ORM-ISO-RR C ABI item.
          88 IS-COBOL-ORM-ISO-RR VALUE 3.

      *> | @brief Dynamic variant column value discriminants in abstract
      *> | result sets.
      *> | @brief SQL NULL value.
      *> @record COBOL-ORM-VAL-NULL C ABI item.
       01 COBOL-ORM-VAL-NULL CONSTANT AS 0.
      *> | @brief 64-bit signed integer value.
      *> @record COBOL-ORM-VAL-INT C ABI item.
       01 COBOL-ORM-VAL-INT CONSTANT AS 1.
      *> | @brief 64-bit IEEE double floating-point value.
      *> @record COBOL-ORM-VAL-FLOAT C ABI item.
       01 COBOL-ORM-VAL-FLOAT CONSTANT AS 2.
      *> | @brief UTF-8 character string value.
      *> @record COBOL-ORM-VAL-STRING C ABI item.
       01 COBOL-ORM-VAL-STRING CONSTANT AS 3.
      *> | @brief Raw binary BLOB value.
      *> @record COBOL-ORM-VAL-BLOB C ABI item.
       01 COBOL-ORM-VAL-BLOB CONSTANT AS 4.
      *> | @brief Exact 38-digit fixed-point decimal value.
      *> @record COBOL-ORM-VAL-DECIMAL C ABI item.
       01 COBOL-ORM-VAL-DECIMAL CONSTANT AS 5.
      *> @record COBOL-ORM-VARIANT-TYPE-ITEM C ABI item.
       01 COBOL-ORM-VARIANT-TYPE-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-VAL-NULL C ABI item.
          88 IS-COBOL-ORM-VAL-NULL VALUE 0.
      *> @field IS-COBOL-ORM-VAL-INT C ABI item.
          88 IS-COBOL-ORM-VAL-INT VALUE 1.
      *> @field IS-COBOL-ORM-VAL-FLOAT C ABI item.
          88 IS-COBOL-ORM-VAL-FLOAT VALUE 2.
      *> @field IS-COBOL-ORM-VAL-STRING C ABI item.
          88 IS-COBOL-ORM-VAL-STRING VALUE 3.
      *> @field IS-COBOL-ORM-VAL-BLOB C ABI item.
          88 IS-COBOL-ORM-VAL-BLOB VALUE 4.
      *> @field IS-COBOL-ORM-VAL-DECIMAL C ABI item.
          88 IS-COBOL-ORM-VAL-DECIMAL VALUE 5.

      *> | @brief SQL JOIN kinds supported by the fluent AST query
      *> | builder.
      *> | @brief INNER JOIN.
      *> @record COBOL-ORM-JOIN-INNER C ABI item.
       01 COBOL-ORM-JOIN-INNER CONSTANT AS 0.
      *> | @brief LEFT OUTER JOIN.
      *> @record COBOL-ORM-JOIN-LEFT C ABI item.
       01 COBOL-ORM-JOIN-LEFT CONSTANT AS 1.
      *> | @brief RIGHT OUTER JOIN.
      *> @record COBOL-ORM-JOIN-RIGHT C ABI item.
       01 COBOL-ORM-JOIN-RIGHT CONSTANT AS 2.
      *> @record COBOL-ORM-JOIN-TYPE-ITEM C ABI item.
       01 COBOL-ORM-JOIN-TYPE-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-JOIN-INNER C ABI item.
          88 IS-COBOL-ORM-JOIN-INNER VALUE 0.
      *> @field IS-COBOL-ORM-JOIN-LEFT C ABI item.
          88 IS-COBOL-ORM-JOIN-LEFT VALUE 1.
      *> @field IS-COBOL-ORM-JOIN-RIGHT C ABI item.
          88 IS-COBOL-ORM-JOIN-RIGHT VALUE 2.

      *> | @brief Legacy integer-handle COMMAREA dispatcher opcodes for
      *> | COBOL-60
      *> | through COBOL-85 programs lacking `USAGE POINTER` or `BY
      *> | VALUE`.
      *> | @brief Connect database (`data1` = URL, returns `db_id`).
      *> @record COBOL-ORM-OP-CONNECT C ABI item.
       01 COBOL-ORM-OP-CONNECT CONSTANT AS 1.
      *> | @brief Disconnect database (`db_id`).
      *> @record COBOL-ORM-OP-DISCONNECT C ABI item.
       01 COBOL-ORM-OP-DISCONNECT CONSTANT AS 2.
      *> | @brief Execute raw SQL DDL/DML (`db_id`, `data1` = SQL).
      *> @record COBOL-ORM-OP-EXEC-SQL C ABI item.
       01 COBOL-ORM-OP-EXEC-SQL CONSTANT AS 3.
      *> | @brief Begin transaction (`db_id`).
      *> @record COBOL-ORM-OP-TX-BEGIN C ABI item.
       01 COBOL-ORM-OP-TX-BEGIN CONSTANT AS 4.
      *> | @brief Commit transaction (`db_id`).
      *> @record COBOL-ORM-OP-TX-COMMIT C ABI item.
       01 COBOL-ORM-OP-TX-COMMIT CONSTANT AS 5.
      *> | @brief Rollback transaction (`db_id`).
      *> @record COBOL-ORM-OP-TX-ROLLBACK C ABI item.
       01 COBOL-ORM-OP-TX-ROLLBACK CONSTANT AS 6.
      *> | @brief Prepare SQL statement (`db_id`, `data1` = SQL, returns
      *> | `stmt_id`).
      *> @record COBOL-ORM-OP-STMT-PREPARE C ABI item.
       01 COBOL-ORM-OP-STMT-PREPARE CONSTANT AS 7.
      *> | @brief Bind 32-bit integer parameter (`stmt_id`, `param_idx`,
      *> | `val_i32`).
      *> @record COBOL-ORM-OP-STMT-BIND-I32 C ABI item.
       01 COBOL-ORM-OP-STMT-BIND-I32 CONSTANT AS 8.
      *> | @brief Bind text parameter (`stmt_id`, `param_idx`, `data1`).
      *> @record COBOL-ORM-OP-STMT-BIND-STR C ABI item.
       01 COBOL-ORM-OP-STMT-BIND-STR CONSTANT AS 9.
      *> | @brief Step prepared statement (`stmt_id`, returns `val_i32`
      *> | = has_row).
      *> @record COBOL-ORM-OP-STMT-STEP C ABI item.
       01 COBOL-ORM-OP-STMT-STEP CONSTANT AS 10.
      *> | @brief Read 32-bit int column (`stmt_id`, `param_idx`,
      *> | returns `val_i32`).
      *> @record COBOL-ORM-OP-STMT-COL-I32 C ABI item.
       01 COBOL-ORM-OP-STMT-COL-I32 CONSTANT AS 11.
      *> | @brief Read text column (`stmt_id`, `param_idx`, returns
      *> | `data2`).
      *> @record COBOL-ORM-OP-STMT-COL-STR C ABI item.
       01 COBOL-ORM-OP-STMT-COL-STR CONSTANT AS 12.
      *> | @brief Finalize prepared statement (`stmt_id`).
      *> @record COBOL-ORM-OP-STMT-FINALIZE C ABI item.
       01 COBOL-ORM-OP-STMT-FINALIZE CONSTANT AS 13.
      *> | @brief Retrieve last error text (`db_id`, returns `data2`).
      *> @record COBOL-ORM-OP-LAST-ERROR C ABI item.
       01 COBOL-ORM-OP-LAST-ERROR CONSTANT AS 14.
      *> | @brief Retrieve library version string (returns `data2`).
      *> @record COBOL-ORM-OP-VERSION C ABI item.
       01 COBOL-ORM-OP-VERSION CONSTANT AS 15.
      *> | @brief Retrieve last insert rowid (`db_id`, returns
      *> | `val_i32`).
      *> @record COBOL-ORM-OP-LAST-ROWID C ABI item.
       01 COBOL-ORM-OP-LAST-ROWID CONSTANT AS 16.
      *> @record COBOL-ORM-LEGACY-OP-ITEM C ABI item.
       01 COBOL-ORM-LEGACY-OP-ITEM USAGE BINARY-LONG SIGNED.
      *> @field IS-COBOL-ORM-OP-CONNECT C ABI item.
          88 IS-COBOL-ORM-OP-CONNECT VALUE 1.
      *> @field IS-COBOL-ORM-OP-DISCONNECT C ABI item.
          88 IS-COBOL-ORM-OP-DISCONNECT VALUE 2.
      *> @field IS-COBOL-ORM-OP-EXEC-SQL C ABI item.
          88 IS-COBOL-ORM-OP-EXEC-SQL VALUE 3.
      *> @field IS-COBOL-ORM-OP-TX-BEGIN C ABI item.
          88 IS-COBOL-ORM-OP-TX-BEGIN VALUE 4.
      *> @field IS-COBOL-ORM-OP-TX-COMMIT C ABI item.
          88 IS-COBOL-ORM-OP-TX-COMMIT VALUE 5.
      *> @field IS-COBOL-ORM-OP-TX-ROLLBACK C ABI item.
          88 IS-COBOL-ORM-OP-TX-ROLLBACK VALUE 6.
      *> @field IS-COBOL-ORM-OP-STMT-PREPARE C ABI item.
          88 IS-COBOL-ORM-OP-STMT-PREPARE VALUE 7.
      *> @field IS-COBOL-ORM-OP-STMT-BIND-I32 C ABI item.
          88 IS-COBOL-ORM-OP-STMT-BIND-I32 VALUE 8.
      *> @field IS-COBOL-ORM-OP-STMT-BIND-STR C ABI item.
          88 IS-COBOL-ORM-OP-STMT-BIND-STR VALUE 9.
      *> @field IS-COBOL-ORM-OP-STMT-STEP C ABI item.
          88 IS-COBOL-ORM-OP-STMT-STEP VALUE 10.
      *> @field IS-COBOL-ORM-OP-STMT-COL-I32 C ABI item.
          88 IS-COBOL-ORM-OP-STMT-COL-I32 VALUE 11.
      *> @field IS-COBOL-ORM-OP-STMT-COL-STR C ABI item.
          88 IS-COBOL-ORM-OP-STMT-COL-STR VALUE 12.
      *> @field IS-COBOL-ORM-OP-STMT-FINALIZE C ABI item.
          88 IS-COBOL-ORM-OP-STMT-FINALIZE VALUE 13.
      *> @field IS-COBOL-ORM-OP-LAST-ERROR C ABI item.
          88 IS-COBOL-ORM-OP-LAST-ERROR VALUE 14.
      *> @field IS-COBOL-ORM-OP-VERSION C ABI item.
          88 IS-COBOL-ORM-OP-VERSION VALUE 15.
      *> @field IS-COBOL-ORM-OP-LAST-ROWID C ABI item.
          88 IS-COBOL-ORM-OP-LAST-ROWID VALUE 16.

      *> | @brief ABI-identical stack-allocated exact 38-digit
      *> | fixed-point decimal.
      *> | Matches `c_orm_decimal_t` byte-for-byte (`41` bytes,
      *> | alignment `1`).
      *> @record COBOL-ORM-DECIMAL C ABI struct.
       01 COBOL-ORM-DECIMAL.
      *> | @brief 0 for non-negative, 1 for negative.
      *> @field CDD-SIGN C ABI item.
          05 CDD-SIGN USAGE BINARY-CHAR UNSIGNED.
      *> | @brief Active total digits (`1..38`).
      *> @field PRECISION C ABI item.
          05 PRECISION USAGE BINARY-CHAR UNSIGNED.
      *> | @brief Fractional digits after decimal point (`0..38`).
      *> @field SCALE C ABI item.
          05 SCALE USAGE BINARY-CHAR UNSIGNED.
      *> | @brief Little-endian base-10 digits (`0..9`), `digits[0]` is
      *> | `10^-scale`.
      *> @field DIGITS C ABI item.
          05 DIGITS OCCURS 38 TIMES USAGE BINARY-CHAR UNSIGNED.

      *> | @brief Connection pool telemetry snapshot with explicit
      *> | fixed-width fields.
      *> @record COBOL-ORM-POOL-STATS C ABI struct.
       01 COBOL-ORM-POOL-STATS.
      *> | @brief Currently leased active connections.
      *> @field ACTIVE-CONNECTIONS C ABI item.
          05 ACTIVE-CONNECTIONS USAGE BINARY-LONG UNSIGNED.
      *> | @brief Currently available idle connections.
      *> @field IDLE-CONNECTIONS C ABI item.
          05 IDLE-CONNECTIONS USAGE BINARY-LONG UNSIGNED.
      *> | @brief Total pool exhaustion / timeout events recorded.
      *> @field EXHAUSTION-COUNT C ABI item.
          05 EXHAUSTION-COUNT USAGE BINARY-LONG UNSIGNED.
      *> | @brief Total slow queries logged across pooled sessions.
      *> @field SLOW-QUERIES-LOGGED C ABI item.
          05 SLOW-QUERIES-LOGGED USAGE BINARY-LONG UNSIGNED.
      *> | @brief Average acquisition wait latency in milliseconds.
      *> @field AVERAGE-WAIT-TIME-MS C ABI item.
          05 AVERAGE-WAIT-TIME-MS USAGE COMP-2.

      *> | @brief Summary metadata for a parsed COBOL Copybook `01`
      *> | record.
      *> @record COBOL-ORM-CPY-INFO C ABI struct.
       01 COBOL-ORM-CPY-INFO.
      *> | @brief Total static wire byte length of the `01` record.
      *> @field TOTAL-BYTE-SIZE C ABI item.
          05 TOTAL-BYTE-SIZE USAGE BINARY-LONG UNSIGNED.
      *> | @brief Number of flattened elementary/SQL-mapped fields.
      *> @field FIELD-COUNT C ABI item.
          05 FIELD-COUNT USAGE BINARY-LONG UNSIGNED.
      *> | @brief Non-zero if an `EXEC SQL DECLARE` DCLGEN block was
      *> | parsed.
      *> @field HAS-DCLGEN C ABI item.
          05 HAS-DCLGEN USAGE BINARY-LONG SIGNED.

      *> | @brief Metadata descriptor for a single field within a parsed
      *> | Copybook.
      *> @record COBOL-ORM-COL-INFO C ABI struct.
       01 COBOL-ORM-COL-INFO.
      *> | @brief 0-based byte offset inside the COBOL `01` wire record.
      *> @field BYTE-OFFSET C ABI item.
          05 BYTE-OFFSET USAGE BINARY-LONG UNSIGNED.
      *> | @brief Total wire byte length of the field.
      *> @field BYTE-SIZE C ABI item.
          05 BYTE-SIZE USAGE BINARY-LONG UNSIGNED.
      *> | @brief COBOL `USAGE` kind (0=DISPLAY, 1=COMP, 2=COMP-5,
      *> | 5=COMP-3).
      *> @field CDD-USAGE C ABI item.
          05 CDD-USAGE USAGE BINARY-LONG SIGNED.
      *> | @brief Total numeric precision digits (`0` for alphanumeric).
      *> @field TOTAL-DIGITS C ABI item.
          05 TOTAL-DIGITS USAGE BINARY-CHAR UNSIGNED.
      *> | @brief Fractional digits after implied `V` (`0` for
      *> | integer/alpha).
      *> @field FRAC-DIGITS C ABI item.
          05 FRAC-DIGITS USAGE BINARY-CHAR UNSIGNED.
      *> | @brief Non-zero if numeric field is signed (`PIC S9`).
      *> @field IS-SIGNED C ABI item.
          05 IS-SIGNED USAGE BINARY-CHAR UNSIGNED.
      *> | @brief Non-zero if field is marked as primary key.
      *> @field IS-PK C ABI item.
          05 IS-PK USAGE BINARY-CHAR UNSIGNED.

      *> | @brief Fixed-width communication area (`COMMAREA`) for legacy
      *> | COBOL-60
      *> | through COBOL-85 callers invoking ORM operations via a single
      *> | `BY REFERENCE`
      *> | block using integer handle IDs and space-padded `PIC X`
      *> | payloads.
      *> @record COBOL-ORM-COMMAREA C ABI struct.
       01 COBOL-ORM-COMMAREA.
      *> | @brief Operation code (`cobol_orm_legacy_op_t`).
      *> @field OPCODE C ABI item.
          05 OPCODE USAGE BINARY-LONG SIGNED.
      *> | @brief Output status code (`cobol_orm_error_t`).
      *> @field CDD-STATUS C ABI item.
          05 CDD-STATUS USAGE BINARY-LONG SIGNED.
      *> | @brief Integer database handle slot ID (`1..64`, or `0`).
      *> @field DB-ID C ABI item.
          05 DB-ID USAGE BINARY-LONG SIGNED.
      *> | @brief Integer statement handle slot ID (`1..64`, or `0`).
      *> @field STMT-ID C ABI item.
          05 STMT-ID USAGE BINARY-LONG SIGNED.
      *> | @brief 1-based parameter or 0-based column index.
      *> @field PARAM-IDX C ABI item.
          05 PARAM-IDX USAGE BINARY-LONG SIGNED.
      *> | @brief Input or output 32-bit signed integer value / boolean
      *> | flag.
      *> @field VAL-I32 C ABI item.
          05 VAL-I32 USAGE BINARY-LONG SIGNED.
      *> | @brief Length of active data in `data1` (0 to auto-trim
      *> | spaces).
      *> @field DATA1-LEN C ABI item.
          05 DATA1-LEN USAGE BINARY-LONG UNSIGNED.
      *> | @brief Output byte length written to `data2`.
      *> @field DATA2-LEN C ABI item.
          05 DATA2-LEN USAGE BINARY-LONG UNSIGNED.
      *> | @brief Space-padded input string buffer (URL, SQL, bind
      *> | text).
      *> @field DATA1 C ABI item.
          05 DATA1 OCCURS 256 TIMES USAGE BINARY-CHAR SIGNED.
      *> | @brief Space-padded output string buffer (column text, error,
      *> | version).
      *> @field DATA2 C ABI item.
          05 DATA2 OCCURS 256 TIMES USAGE BINARY-CHAR SIGNED.

