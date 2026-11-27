>>SOURCE FORMAT IS FREE
*> @file prepared_statements.cbl
*> @module cobol_orm_examples
*> @brief Demonstrates LRU-cached prepared statements, typed parameter binds
*> (INT32, PIC X, direct COMP-3, NULL), statement reset/reuse, last insert
*> rowid, and direct COMP-3 column hydration without floating-point loss.

*> @program EX-PREP-STMT
*> @brief Manages an inventory catalog using cached prepared statements,
*> native COMP-3 pricing, and NULL-safe cursor iteration on SQLite.
IDENTIFICATION DIVISION.
PROGRAM-ID. EX-PREP-STMT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
*> @field WS-URL In-memory SQLite connection URL.
01 WS-URL                             PIC X(256) VALUE "sqlite://:memory:".
*> @field WS-SQL DDL or prepared SQL statement buffer.
01 WS-SQL                             PIC X(1024) VALUE SPACES.
*> @field WS-SQL-LEN Byte length of WS-SQL.
01 WS-SQL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-CACHE-CAP Prepared statement LRU cache capacity.
01 WS-CACHE-CAP                       USAGE BINARY-LONG UNSIGNED VALUE 8.
*> @field WS-IDX1 Parameter index 1.
01 WS-IDX1                            USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-IDX2 Parameter index 2.
01 WS-IDX2                            USAGE BINARY-LONG SIGNED VALUE 2.
*> @field WS-IDX3 Parameter index 3.
01 WS-IDX3                            USAGE BINARY-LONG SIGNED VALUE 3.
*> @field WS-IDX4 Parameter index 4.
01 WS-IDX4                            USAGE BINARY-LONG SIGNED VALUE 4.
*> @field WS-COL0 Column index 0 (SKU).
01 WS-COL0                            USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-COL1 Column index 1 (LABEL).
01 WS-COL1                            USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-COL2 Column index 2 (PRICE).
01 WS-COL2                            USAGE BINARY-LONG SIGNED VALUE 2.
*> @field WS-COL3 Column index 3 (NOTE).
01 WS-COL3                            USAGE BINARY-LONG SIGNED VALUE 3.
*> @field WS-SKU-IN Input SKU integer value.
01 WS-SKU-IN                          USAGE BINARY-LONG SIGNED VALUE 101.
*> @field WS-LABEL-IN Input product label buffer.
01 WS-LABEL-IN                        PIC X(24) VALUE "MAINFRAME TAPE".
*> @field WS-LABEL-LEN Byte length of WS-LABEL-IN.
01 WS-LABEL-LEN                       USAGE BINARY-LONG UNSIGNED VALUE 24.
*> @field WS-PRICE-IN Native COMP-3 unit price (4 bytes, scale 2).
01 WS-PRICE-IN                        PIC S9(5)V99 USAGE PACKED-DECIMAL VALUE 49.95.
*> @field WS-NOTE-IN Optional warehouse note buffer.
01 WS-NOTE-IN                         PIC X(24) VALUE "RACK-B12".
*> @field WS-NOTE-LEN Byte length of WS-NOTE-IN.
01 WS-NOTE-LEN                        USAGE BINARY-LONG UNSIGNED VALUE 24.
*> @field WS-C3-LEN Byte length of COMP-3 price field.
01 WS-C3-LEN                          USAGE BINARY-LONG UNSIGNED VALUE 4.
*> @field WS-INT-DIG Integer digits for COMP-3 price (5).
01 WS-INT-DIG                         USAGE BINARY-CHAR UNSIGNED VALUE 5.
*> @field WS-FRAC-DIG Fractional digits for COMP-3 price (2).
01 WS-FRAC-DIG                        USAGE BINARY-CHAR UNSIGNED VALUE 2.
*> @field WS-SIGNED Signed flag for COMP-3 output (1 = signed).
01 WS-SIGNED                          USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-ROWID Last inserted SQLite row ID.
01 WS-ROWID                           USAGE BINARY-DOUBLE SIGNED VALUE 0.
*> @field WS-HAS-ROW Statement step row-available indicator.
01 WS-HAS-ROW                         USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-IS-NULL Column SQL NULL indicator.
01 WS-IS-NULL                         USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-SKU-OUT Hydrated SKU integer.
01 WS-SKU-OUT                         USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-LABEL-OUT Hydrated label string buffer.
01 WS-LABEL-OUT                       PIC X(24) VALUE SPACES.
*> @field WS-PRICE-OUT Hydrated COMP-3 unit price.
01 WS-PRICE-OUT                       PIC S9(5)V99 USAGE PACKED-DECIMAL VALUE 0.
*> @field WS-OUT-LEN Output byte length written by getters.
01 WS-OUT-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-ROWS-SEEN Counter of fetched inventory rows.
01 WS-ROWS-SEEN                       USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-NULL-SEEN Counter of NULL notes observed.
01 WS-NULL-SEEN                       USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-PRICE-SUM Accumulated exact COMP-3 total of fetched prices.
01 WS-PRICE-SUM                       PIC S9(7)V99 USAGE PACKED-DECIMAL VALUE 0.
PROCEDURE DIVISION.
    CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF
    CALL "cobol_orm_enable_stmt_cache"
        USING BY VALUE C-ORM-DB-PTR BY VALUE WS-CACHE-CAP
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 2
    END-IF
    MOVE "CREATE TABLE INV (SKU INTEGER PRIMARY KEY, LBL TEXT, PRC NUMERIC, NOTE TEXT)"
        TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 3
    END-IF
    MOVE "INSERT INTO INV VALUES (?, ?, ?, ?)" TO WS-SQL
    MOVE FUNCTION BYTE-LENGTH(WS-SQL) TO WS-SQL-LEN
    CALL "cobol_orm_stmt_prepare_cached"
        USING BY VALUE C-ORM-DB-PTR BY REFERENCE WS-SQL BY VALUE WS-SQL-LEN
              BY REFERENCE C-ORM-STMT-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 4
    END-IF
    CALL "cobol_orm_stmt_bind_i32"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX1 BY VALUE WS-SKU-IN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_bind_str"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX2
              BY REFERENCE WS-LABEL-IN BY VALUE WS-LABEL-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_bind_comp3"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX3
              BY REFERENCE WS-PRICE-IN BY VALUE WS-C3-LEN BY VALUE WS-FRAC-DIG
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_bind_null"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX4
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_step"
        USING BY VALUE C-ORM-STMT-PTR BY REFERENCE WS-HAS-ROW
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 5
    END-IF
    CALL "cobol_orm_stmt_reset"
        USING BY VALUE C-ORM-STMT-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    MOVE 102 TO WS-SKU-IN
    MOVE "CARD READER" TO WS-LABEL-IN
    MOVE 125.50 TO WS-PRICE-IN
    CALL "cobol_orm_stmt_bind_i32"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX1 BY VALUE WS-SKU-IN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_bind_str"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX2
              BY REFERENCE WS-LABEL-IN BY VALUE WS-LABEL-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_bind_comp3"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX3
              BY REFERENCE WS-PRICE-IN BY VALUE WS-C3-LEN BY VALUE WS-FRAC-DIG
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_bind_str"
        USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-IDX4
              BY REFERENCE WS-NOTE-IN BY VALUE WS-NOTE-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_stmt_step"
        USING BY VALUE C-ORM-STMT-PTR BY REFERENCE WS-HAS-ROW
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 6
    END-IF
    CALL "cobol_orm_last_insert_rowid"
        USING BY VALUE C-ORM-DB-PTR BY REFERENCE WS-ROWID
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-ROWID NOT = 102
        STOP RUN RETURNING 7
    END-IF
    CALL "cobol_orm_stmt_finalize"
        USING BY VALUE C-ORM-STMT-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    MOVE "SELECT SKU, LBL, PRC, NOTE FROM INV ORDER BY SKU" TO WS-SQL
    CALL "cobol_orm_stmt_prepare_cached"
        USING BY VALUE C-ORM-DB-PTR BY REFERENCE WS-SQL BY VALUE WS-SQL-LEN
              BY REFERENCE C-ORM-STMT-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    SET C-ORM-RND-HALF-UP TO TRUE
    PERFORM UNTIL EXIT
        CALL "cobol_orm_stmt_step"
            USING BY VALUE C-ORM-STMT-PTR BY REFERENCE WS-HAS-ROW
            RETURNING C-ORM-STATUS
        END-CALL
        IF NOT C-ORM-OK OR WS-HAS-ROW = 0
            EXIT PERFORM
        END-IF
        ADD 1 TO WS-ROWS-SEEN
        END-ADD
        CALL "cobol_orm_stmt_col_i32"
            USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-COL0
                  BY REFERENCE WS-SKU-OUT
            RETURNING C-ORM-STATUS
        END-CALL
        CALL "cobol_orm_stmt_col_str"
            USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-COL1
                  BY REFERENCE WS-LABEL-OUT BY VALUE WS-LABEL-LEN
                  BY REFERENCE WS-OUT-LEN
            RETURNING C-ORM-STATUS
        END-CALL
        CALL "cobol_orm_stmt_col_comp3"
            USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-COL2
                  BY VALUE WS-INT-DIG BY VALUE WS-FRAC-DIG
                  BY VALUE WS-SIGNED BY VALUE C-ORM-ROUND-MODE
                  BY REFERENCE WS-PRICE-OUT BY VALUE WS-C3-LEN
                  BY REFERENCE WS-OUT-LEN
            RETURNING C-ORM-STATUS
        END-CALL
        ADD WS-PRICE-OUT TO WS-PRICE-SUM
        END-ADD
        CALL "cobol_orm_stmt_col_is_null"
            USING BY VALUE C-ORM-STMT-PTR BY VALUE WS-COL3
                  BY REFERENCE WS-IS-NULL
            RETURNING C-ORM-STATUS
        END-CALL
        IF WS-IS-NULL = 1
            ADD 1 TO WS-NULL-SEEN
            END-ADD
        END-IF
    END-PERFORM
    CALL "cobol_orm_stmt_finalize"
        USING BY VALUE C-ORM-STMT-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF WS-ROWS-SEEN NOT = 2 OR WS-NULL-SEEN NOT = 1 OR WS-PRICE-SUM NOT = 175.45
        STOP RUN RETURNING 8
    END-IF
    DISPLAY "EX-PREP-STMT OK: ROWS=2 SUM=175.45"
    END-DISPLAY
    STOP RUN RETURNING 0.
END PROGRAM EX-PREP-STMT.
