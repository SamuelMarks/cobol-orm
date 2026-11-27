>>SOURCE FORMAT IS FREE
*> @file corm_era2014.cbl
*> @module cobol_orm_era_cobol2014
*> @brief ISO/IEC 1989:2014 (COBOL-2014) free-format ORM verification compiled
*> with cobc -std=cobol2014 -free -Wall -Wextra -Werror.

*> @program CORM-ERA2014
*> @brief Exercises COBOL-2014 COMP-3 packed decimal bind/read, fluent AST
*> multi-dialect SQL rendering, and Copybook-driven COBOL 01-record CRUD.
IDENTIFICATION DIVISION.
PROGRAM-ID. CORM-ERA2014.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
*> @field WS-URL Database URL buffer.
01 WS-URL                             PIC X(64) VALUE "sqlite://:memory:".
*> @field WS-URL-LEN Byte length of WS-URL.
01 WS-URL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-CPY-SRC Copybook source defining a COBOL 01 ledger record.
01 WS-CPY-SRC                         PIC X(256) VALUE
   "01 LEDGER-REC. 05 ACCT-ID PIC S9(9) COMP. 05 ACCT-BAL PIC S9(7)V99 COMP-3. 05 ACCT-STAT PIC X(1). 88 STAT-OPEN VALUE 'O'. 88 STAT-CLOSED VALUE 'C'.".
*> @field WS-CPY-LEN Byte length of WS-CPY-SRC.
01 WS-CPY-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @class WS-LEDGER-REC
*> @brief Native COBOL 01 record matching WS-CPY-SRC (10 bytes exact).
01 WS-LEDGER-REC.
   *> @field WS-ACCT-ID Big-endian COMP 4-byte account ID.
   05 WS-ACCT-ID                      PIC S9(9) USAGE COMP VALUE 2014.
   *> @field WS-ACCT-BAL Packed decimal PACKED-DECIMAL 5-byte balance.
   05 WS-ACCT-BAL                     PIC S9(7)V99 USAGE PACKED-DECIMAL VALUE 12345.67.
   *> @field WS-ACCT-STAT Status code ('O' open / 'C' closed).
   05 WS-ACCT-STAT                    PIC X(1) VALUE "O".
*> @class WS-OUT-REC
*> @brief Destination COBOL 01 record hydrated directly from SQLite.
01 WS-OUT-REC.
   *> @field WS-OUT-ID Hydrated account ID.
   05 WS-OUT-ID                       PIC S9(9) USAGE COMP VALUE 0.
   *> @field WS-OUT-BAL Hydrated PACKED-DECIMAL balance.
   05 WS-OUT-BAL                      PIC S9(7)V99 USAGE PACKED-DECIMAL VALUE 0.
   *> @field WS-OUT-STAT Hydrated status byte.
   05 WS-OUT-STAT                     PIC X(1) VALUE SPACE.
*> @field WS-REC-LEN Byte length of WS-LEDGER-REC.
01 WS-REC-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-BIG-END Big-endian COMP wire flag (1 = true).
01 WS-BIG-END                         USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-KEY-ID Primary key lookup value.
01 WS-KEY-ID                          USAGE BINARY-LONG SIGNED VALUE 2014.
*> @field WS-SQL-OUT Generated AST SQL buffer.
01 WS-SQL-OUT                         PIC X(256) VALUE SPACES.
*> @field WS-SQL-CAP Capacity of WS-SQL-OUT.
01 WS-SQL-CAP                         USAGE BINARY-LONG UNSIGNED VALUE 256.
*> @field WS-SQL-LEN Output SQL length.
01 WS-SQL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-TBL Table identifier for AST test.
01 WS-TBL                             PIC X(16) VALUE "LEDGER_REC".
*> @field WS-TBL-LEN Length of WS-TBL.
01 WS-TBL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 16.
*> @field WS-COLS Column projection for AST test.
01 WS-COLS                            PIC X(16) VALUE "ACCT_ID".
*> @field WS-COLS-LEN Length of WS-COLS.
01 WS-COLS-LEN                        USAGE BINARY-LONG UNSIGNED VALUE 16.
PROCEDURE DIVISION.
    MOVE FUNCTION BYTE-LENGTH(WS-URL) TO WS-URL-LEN
    CALL "cobol_orm_connect"
        USING BY REFERENCE WS-URL
              BY VALUE WS-URL-LEN
              BY REFERENCE C-ORM-DB-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF

    MOVE FUNCTION BYTE-LENGTH(WS-CPY-SRC) TO WS-CPY-LEN
    SET C-ORM-FMT-FREE TO TRUE
    CALL "cobol_orm_cpy_parse_str"
        USING BY REFERENCE WS-CPY-SRC
              BY VALUE WS-CPY-LEN
              BY VALUE C-ORM-CPY-FMT
              BY REFERENCE C-ORM-CPY-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 2
    END-IF

    SET C-ORM-DL-SQLITE TO TRUE
    CALL "cobol_orm_cpy_create_table"
        USING BY VALUE C-ORM-DB-PTR
              BY VALUE C-ORM-CPY-PTR
              BY VALUE C-ORM-DIALECT
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 3
    END-IF

    MOVE FUNCTION BYTE-LENGTH(WS-LEDGER-REC) TO WS-REC-LEN
    SET C-ORM-CP-ASCII-V TO TRUE
    CALL "cobol_orm_cpy_insert"
        USING BY VALUE C-ORM-DB-PTR
              BY VALUE C-ORM-CPY-PTR
              BY REFERENCE WS-LEDGER-REC
              BY VALUE WS-REC-LEN
              BY VALUE C-ORM-CODEPAGE
              BY VALUE WS-BIG-END
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 4
    END-IF

    CALL "cobol_orm_cpy_find_i32"
        USING BY VALUE C-ORM-DB-PTR
              BY VALUE C-ORM-CPY-PTR
              BY VALUE WS-KEY-ID
              BY VALUE C-ORM-CODEPAGE
              BY VALUE WS-BIG-END
              BY REFERENCE WS-OUT-REC
              BY VALUE WS-REC-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 5
    END-IF
    IF WS-OUT-ID NOT = 2014 OR WS-OUT-BAL NOT = 12345.67 OR WS-OUT-STAT NOT = "O"
        STOP RUN RETURNING 6
    END-IF

    CALL "cobol_orm_ast_new"
        USING BY REFERENCE C-ORM-AST-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_ast_select"
        USING BY VALUE C-ORM-AST-PTR
              BY REFERENCE WS-COLS
              BY VALUE WS-COLS-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_ast_from"
        USING BY VALUE C-ORM-AST-PTR
              BY REFERENCE WS-TBL
              BY VALUE WS-TBL-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    SET C-ORM-DL-DB2 TO TRUE
    CALL "cobol_orm_ast_to_sql"
        USING BY VALUE C-ORM-AST-PTR
              BY VALUE C-ORM-DIALECT
              BY REFERENCE WS-SQL-OUT
              BY VALUE WS-SQL-CAP
              BY REFERENCE WS-SQL-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-SQL-LEN = 0
        STOP RUN RETURNING 7
    END-IF

    CALL "cobol_orm_ast_free"
        USING BY VALUE C-ORM-AST-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_cpy_free"
        USING BY VALUE C-ORM-CPY-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_disconnect"
        USING BY VALUE C-ORM-DB-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    STOP RUN RETURNING 0.
END PROGRAM CORM-ERA2014.
