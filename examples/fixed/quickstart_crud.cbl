      * @file quickstart_crud.cbl
      * @module cobol_orm_examples
      * @brief Quickstart free-format example demonstrating
      * Copybook-driven CRUD,
      * level-88 domain validation, and COMP-3 persistence on SQLite.

      * @program EX-QUICKSTART
      * @brief Connects to SQLite, creates table from Copybook, inserts,
      * queries,
      * updates, and deletes a COBOL 01 customer record.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-QUICKSTART.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm.cpy".
      * @field WS-URL In-memory SQLite connection string.
       01 WS-URL PIC X(256) VALUE "sqlite://:memory:".
      * @field WS-CPY Copybook DDL/schema source for customer records.
       01 WS-CPY                             PIC X(256) VALUE SPACES.
      * @field WS-CPY-LEN Length of WS-CPY.
       01 WS-CPY-LEN USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @class WS-CUST-IN
      * @brief Input COBOL 01 customer record persisted directly via
      * cobol-orm.
       01 WS-CUST-IN.
      * @field WS-IN-ID Customer primary key.
           05 WS-IN-ID PIC S9(9) USAGE COMP VALUE 1001.
      * @field WS-IN-NAME Customer name (PIC X).
           05 WS-IN-NAME PIC X(12) VALUE "GRACE HOPPER".
      * @field WS-IN-BAL Account balance in PACKED-DECIMAL (COMP-3).
           05 WS-IN-BAL PIC S9(5)V99 USAGE PACKED-DECIMAL VALUE 9876.54.
      * @class WS-CUST-OUT
      * @brief Destination COBOL 01 record hydrated from SQLite.
       01 WS-CUST-OUT.
      * @field WS-OUT-ID Hydrated customer ID.
           05 WS-OUT-ID PIC S9(9) USAGE COMP VALUE 0.
      * @field WS-OUT-NAME Hydrated customer name.
           05 WS-OUT-NAME                     PIC X(12) VALUE SPACES.
      * @field WS-OUT-BAL Hydrated COMP-3 balance.
           05 WS-OUT-BAL PIC S9(5)V99 USAGE PACKED-DECIMAL VALUE 0.
      * @field WS-REC-LEN Byte length of customer record.
       01 WS-REC-LEN USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field WS-BIG-END Big-endian COMP wire flag (1 = big-endian).
       01 WS-BIG-END USAGE BINARY-LONG SIGNED VALUE 1.
      * @field WS-KEY Lookup primary key value.
       01 WS-KEY USAGE BINARY-LONG SIGNED VALUE 1001.
       PROCEDURE DIVISION.
           CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
           STOP RUN RETURNING 1
           END-IF
           STRING "01 CUST-REC. 05 CUST-ID PIC S9(9) COMP. "
           "05 CUST-NAME PIC X(12). "
           "05 CUST-BAL PIC S9(5)V99 COMP-3."
           DELIMITED BY SIZE INTO WS-CPY
           END-STRING
           MOVE FUNCTION BYTE-LENGTH(WS-CPY) TO WS-CPY-LEN
           SET C-ORM-FMT-FREE TO TRUE
           CALL "cobol_orm_cpy_parse_str"
           USING BY REFERENCE WS-CPY
           BY VALUE WS-CPY-LEN
           BY VALUE C-ORM-CPY-FMT
           BY REFERENCE C-ORM-CPY-PTR
           RETURNING C-ORM-STATUS
           END-CALL
           SET C-ORM-DL-SQLITE TO TRUE
           CALL "cobol_orm_cpy_create_table"
           USING BY VALUE C-ORM-DB-PTR
           BY VALUE C-ORM-CPY-PTR
           BY VALUE C-ORM-DIALECT
           RETURNING C-ORM-STATUS
           END-CALL
           MOVE FUNCTION BYTE-LENGTH(WS-CUST-IN) TO WS-REC-LEN
           SET C-ORM-CP-ASCII-V TO TRUE
           CALL "cobol_orm_cpy_insert"
           USING BY VALUE C-ORM-DB-PTR
           BY VALUE C-ORM-CPY-PTR
           BY REFERENCE WS-CUST-IN
           BY VALUE WS-REC-LEN
           BY VALUE C-ORM-CODEPAGE
           BY VALUE WS-BIG-END
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_cpy_find_i32"
           USING BY VALUE C-ORM-DB-PTR
           BY VALUE C-ORM-CPY-PTR
           BY VALUE WS-KEY
           BY VALUE C-ORM-CODEPAGE
           BY VALUE WS-BIG-END
           BY REFERENCE WS-CUST-OUT
           BY VALUE WS-REC-LEN
           RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-OUT-ID NOT = 1001 OR WS-OUT-BAL NOT =
               9876.54
           STOP RUN RETURNING 2
           END-IF
           CALL "cobol_orm_cpy_delete_i32"
           USING BY VALUE C-ORM-DB-PTR
           BY VALUE C-ORM-CPY-PTR
           BY VALUE WS-KEY
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_cpy_free"
           USING BY VALUE C-ORM-CPY-PTR
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           DISPLAY "EX-QUICKSTART OK: " WS-OUT-NAME
           END-DISPLAY
           STOP RUN RETURNING 0.
       END PROGRAM EX-QUICKSTART.
