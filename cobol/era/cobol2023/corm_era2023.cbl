>>SOURCE FORMAT IS FREE
*> @file corm_era2023.cbl
*> @module cobol_orm_era_cobol2023
*> @brief ISO/IEC 1989:2023 (COBOL-2023) free-format full-stack ORM
*> verification exercising connection pooling, EBCDIC IBM037/IBM1140,
*> 38-digit DECIMAL arithmetic, abstract result sets, and cobol_orm_lib.cbl.

*> @program CORM-ERA2023
*> @brief Exercises modern COBOL-2023 ORM stack end-to-end.
IDENTIFICATION DIVISION.
PROGRAM-ID. CORM-ERA2023.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
*> @field WS-URL Connection URL buffer for pool and CORM-CONNECT.
01 WS-URL                             PIC X(256) VALUE "sqlite://:memory:".
*> @field WS-SQL SQL statement buffer for CORM-EXEC-SQL.
01 WS-SQL                             PIC X(1024) VALUE SPACES.
*> @field WS-UTF8-IN UTF-8 input text for EBCDIC roundtrip.
01 WS-UTF8-IN                         PIC X(16) VALUE "COBOL-2023".
*> @field WS-UTF8-LEN Length of WS-UTF8-IN.
01 WS-UTF8-LEN                        USAGE BINARY-LONG UNSIGNED VALUE 10.
*> @field WS-EBCDIC-BUF Transcoded IBM037 EBCDIC bytes.
01 WS-EBCDIC-BUF                      PIC X(32) VALUE LOW-VALUES.
*> @field WS-EBCDIC-CAP Capacity of WS-EBCDIC-BUF.
01 WS-EBCDIC-CAP                      USAGE BINARY-LONG UNSIGNED VALUE 32.
*> @field WS-EBCDIC-LEN Actual encoded EBCDIC byte count.
01 WS-EBCDIC-LEN                      USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-UTF8-OUT Roundtripped UTF-8 output buffer.
01 WS-UTF8-OUT                        PIC X(32) VALUE SPACES.
*> @field WS-UTF8-OLEN Roundtripped UTF-8 byte length.
01 WS-UTF8-OLEN                       USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-DEC-A First 38-digit fixed-point decimal operand.
01 WS-DEC-A                           PIC X(41) VALUE LOW-VALUES.
*> @field WS-DEC-B Second 38-digit fixed-point decimal operand.
01 WS-DEC-B                           PIC X(41) VALUE LOW-VALUES.
*> @field WS-DEC-SUM Sum of WS-DEC-A and WS-DEC-B.
01 WS-DEC-SUM                         PIC X(41) VALUE LOW-VALUES.
*> @field WS-STR-A Decimal literal A.
01 WS-STR-A                           PIC X(32) VALUE "10000000000000000000.25".
*> @field WS-STR-B Decimal literal B.
01 WS-STR-B                           PIC X(32) VALUE "23456789012345678901.75".
*> @field WS-STR-OUT Formatted sum string.
01 WS-STR-OUT                         PIC X(64) VALUE SPACES.
*> @field WS-STR-LEN Length parameter.
01 WS-STR-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 32.
*> @field WS-STR-CAP Output string buffer capacity.
01 WS-STR-CAP                         USAGE BINARY-LONG UNSIGNED VALUE 64.
*> @field WS-STR-OLEN Formatted sum byte length.
01 WS-STR-OLEN                        USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-ROWS Dynamic result-set row count.
01 WS-ROWS                            USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-ROW0 Row index 0.
01 WS-ROW0                            USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-COL-NM Column name lookup buffer.
01 WS-COL-NM                          PIC X(16) VALUE "LABEL".
*> @field WS-COL-NLEN Length of WS-COL-NM.
01 WS-COL-NLEN                        USAGE BINARY-LONG UNSIGNED VALUE 16.
*> @field WS-MIN-C Pool minimum connections.
01 WS-MIN-C                           USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-MAX-C Pool maximum connections.
01 WS-MAX-C                           USAGE BINARY-LONG SIGNED VALUE 2.
*> @field WS-TMO Pool timeout in milliseconds.
01 WS-TMO                             USAGE BINARY-LONG SIGNED VALUE 100.
*> @field WS-URL-LEN Length of WS-URL.
01 WS-URL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 256.
*> @field WS-SQL-LEN Length of WS-SQL.
01 WS-SQL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 1024.
PROCEDURE DIVISION.
    *> 1. Exercise idiomatic COBOL wrapper library (CORM-CONNECT / EXEC / TX)
    CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF
    MOVE "CREATE TABLE E2023 (ID INT, LABEL TEXT)" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 2
    END-IF
    CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS END-CALL
    MOVE "INSERT INTO E2023 VALUES (2023, 'ISO-COBOL-2023')" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS END-CALL
    CALL "CORM-TX-COMMIT" USING C-ORM-DB-PTR C-ORM-STATUS END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 3
    END-IF

    *> 2. Dynamic abstract result set hydration
    MOVE "SELECT ID, LABEL FROM E2023" TO WS-SQL
    CALL "cobol_orm_query_abstract"
        USING BY VALUE C-ORM-DB-PTR
              BY REFERENCE WS-SQL
              BY VALUE WS-SQL-LEN
              BY REFERENCE C-ORM-RS-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_rs_row_count"
        USING BY VALUE C-ORM-RS-PTR
              BY REFERENCE WS-ROWS
        RETURNING C-ORM-STATUS
    END-CALL
    IF WS-ROWS NOT = 1
        STOP RUN RETURNING 4
    END-IF
    CALL "cobol_orm_rs_get_str"
        USING BY VALUE C-ORM-RS-PTR
              BY VALUE WS-ROW0
              BY REFERENCE WS-COL-NM
              BY VALUE WS-COL-NLEN
              BY REFERENCE WS-STR-OUT
              BY VALUE WS-STR-CAP
              BY REFERENCE WS-STR-OLEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF WS-STR-OUT (1:14) NOT = "ISO-COBOL-2023"
        STOP RUN RETURNING 5
    END-IF
    CALL "cobol_orm_rs_free"
        USING BY VALUE C-ORM-RS-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS END-CALL

    *> 3. Exact 38-digit DECIMAL arithmetic (exceeds 64-bit integer & double!)
    CALL "cobol_orm_dec_from_str"
        USING BY REFERENCE WS-STR-A
              BY VALUE WS-STR-LEN
              BY REFERENCE WS-DEC-A
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_dec_from_str"
        USING BY REFERENCE WS-STR-B
              BY VALUE WS-STR-LEN
              BY REFERENCE WS-DEC-B
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_dec_add"
        USING BY REFERENCE WS-DEC-A
              BY REFERENCE WS-DEC-B
              BY REFERENCE WS-DEC-SUM
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_dec_to_str"
        USING BY REFERENCE WS-DEC-SUM
              BY REFERENCE WS-STR-OUT
              BY VALUE WS-STR-CAP
              BY REFERENCE WS-STR-OLEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF WS-STR-OUT (1:23) NOT = "33456789012345678902.00"
        STOP RUN RETURNING 6
    END-IF

    *> 4. IBM037 EBCDIC roundtrip
    SET C-ORM-CP-IBM037-V TO TRUE
    CALL "cobol_orm_utf8_to_ebcdic"
        USING BY VALUE C-ORM-CODEPAGE
              BY REFERENCE WS-UTF8-IN
              BY VALUE WS-UTF8-LEN
              BY REFERENCE WS-EBCDIC-BUF
              BY VALUE WS-EBCDIC-CAP
              BY REFERENCE WS-EBCDIC-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_ebcdic_to_utf8"
        USING BY VALUE C-ORM-CODEPAGE
              BY REFERENCE WS-EBCDIC-BUF
              BY VALUE WS-EBCDIC-LEN
              BY REFERENCE WS-UTF8-OUT
              BY VALUE WS-EBCDIC-CAP
              BY REFERENCE WS-UTF8-OLEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF WS-UTF8-OLEN NOT = 10 OR WS-UTF8-OUT (1:10) NOT = "COBOL-2023"
        STOP RUN RETURNING 7
    END-IF

    *> 5. Connection Pool acquire, telemetry, release, destroy
    CALL "cobol_orm_pool_init"
        USING BY REFERENCE WS-URL
              BY VALUE WS-URL-LEN
              BY VALUE WS-MIN-C
              BY VALUE WS-MAX-C
              BY VALUE WS-TMO
              BY REFERENCE C-ORM-POOL-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_pool_acquire"
        USING BY VALUE C-ORM-POOL-PTR
              BY REFERENCE C-ORM-DB-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_pool_telemetry"
        USING BY VALUE C-ORM-POOL-PTR
              BY REFERENCE C-ORM-POOL-STATS-REC
        RETURNING C-ORM-STATUS
    END-CALL
    IF C-ORM-PS-ACTIVE NOT = 1
        STOP RUN RETURNING 8
    END-IF
    CALL "cobol_orm_pool_release"
        USING BY VALUE C-ORM-POOL-PTR
              BY VALUE C-ORM-DB-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_pool_destroy"
        USING BY VALUE C-ORM-POOL-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 9
    END-IF
    STOP RUN RETURNING 0.
END PROGRAM CORM-ERA2023.
