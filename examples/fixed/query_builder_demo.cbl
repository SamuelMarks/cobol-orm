      * @file query_builder_demo.cbl
      * @module cobol_orm_examples
      * @brief Demonstrates the arena-backed fluent SQL AST query
      * builder compiling
      * a single AST into both SQLite and IBM Db2 WITH UR SQL dialects.

      * @program EX-QUERY-AST
      * @brief Builds a filtered SELECT AST with Db2 WITH UR isolation
      * lock and
      * renders dialect-specific SQL.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-QUERY-AST.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm.cpy".
      * @field WS-COLS Projected column list.
       01 WS-COLS PIC X(32) VALUE "ACCT_ID, BALANCE".
      * @field WS-TBL Source table name.
       01 WS-TBL                             PIC X(16) VALUE "ACCOUNTS".
      * @field WS-COL Filter column name.
       01 WS-COL                             PIC X(16) VALUE "STATUS".
      * @field WS-VAL Filter literal value.
       01 WS-VAL                             PIC X(16) VALUE "ACTIVE".
      * @field WS-LEN32 32-byte length argument.
       01 WS-LEN32 USAGE BINARY-LONG UNSIGNED VALUE 32.
      * @field WS-LEN16 16-byte length argument.
       01 WS-LEN16 USAGE BINARY-LONG UNSIGNED VALUE 16.
      * @field WS-IS-STR String literal flag (1 = quoted string).
       01 WS-IS-STR USAGE BINARY-LONG SIGNED VALUE 1.
      * @field WS-LIM Query row limit.
       01 WS-LIM USAGE BINARY-LONG UNSIGNED VALUE 25.
      * @field WS-OFF Query row offset.
       01 WS-OFF USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field WS-SQL Rendered SQL output buffer.
       01 WS-SQL                             PIC X(256) VALUE SPACES.
      * @field WS-CAP Capacity of WS-SQL.
       01 WS-CAP USAGE BINARY-LONG UNSIGNED VALUE 256.
      * @field WS-OLEN Rendered SQL byte length.
       01 WS-OLEN USAGE BINARY-LONG UNSIGNED VALUE 0.
       PROCEDURE DIVISION.
           CALL "cobol_orm_ast_new"
           USING BY REFERENCE C-ORM-AST-PTR
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_select"
           USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COLS BY VALUE
               WS-LEN32
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_from"
           USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-TBL BY VALUE
               WS-LEN16
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_where_eq"
           USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COL BY VALUE
               WS-LEN16
           BY REFERENCE WS-VAL BY VALUE WS-LEN16 BY VALUE WS-IS-STR
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_limit_offset"
           USING BY VALUE C-ORM-AST-PTR BY VALUE WS-LIM BY VALUE WS-OFF
           RETURNING C-ORM-STATUS
           END-CALL
           SET C-ORM-ISO-UR-V TO TRUE
           CALL "cobol_orm_ast_with_lock"
           USING BY VALUE C-ORM-AST-PTR BY VALUE C-ORM-ISOLATION
           RETURNING C-ORM-STATUS
           END-CALL
           SET C-ORM-DL-DB2 TO TRUE
           CALL "cobol_orm_ast_to_sql"
           USING BY VALUE C-ORM-AST-PTR BY VALUE C-ORM-DIALECT
           BY REFERENCE WS-SQL BY VALUE WS-CAP BY REFERENCE WS-OLEN
           RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-OLEN = 0
           STOP RUN RETURNING 1
           END-IF
           CALL "cobol_orm_ast_free"
           USING BY VALUE C-ORM-AST-PTR
           RETURNING C-ORM-STATUS
           END-CALL
           DISPLAY "EX-QUERY-AST OK: " WS-SQL(1:WS-OLEN)
           END-DISPLAY
           STOP RUN RETURNING 0.
       END PROGRAM EX-QUERY-AST.
