      * @file abstract_result_set.cbl
      * @module cobol_orm_examples
      * @brief Demonstrates live fluent AST DML execution paired with
      * dynamic abstract result set hydration, column metadata, variant
      * types, and named getters in strict fixed 80-column IBM COBOL.

      * @program EX-ABSTRACT-RS
      * @brief Populates a regional sales table via fluent AST DML and
      * inspects analytics rows through cobol_orm_query_abstract.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-ABSTRACT-RS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_ibm.cpy".
      * @field WS-URL In-memory SQLite connection URL.
       01 WS-URL                       PIC X(256)
                                       VALUE "sqlite://:memory:".
      * @field WS-SQL SQL DDL or query text buffer.
       01 WS-SQL                       PIC X(1024) VALUE SPACES.
      * @field WS-SQL-LEN Byte length of WS-SQL.
       01 WS-SQL-LEN                   PIC 9(9) COMP-5 VALUE 1024.
      * @field WS-TBL Target table name for AST DML.
       01 WS-TBL                       PIC X(16) VALUE "SALES".
      * @field WS-COL-ID Column name ID.
       01 WS-COL-ID                    PIC X(16) VALUE "ID".
      * @field WS-COL-REG Column name REGION.
       01 WS-COL-REG                   PIC X(16) VALUE "REGION".
      * @field WS-COL-REV Column name REVENUE.
       01 WS-COL-REV                   PIC X(16) VALUE "REVENUE".
      * @field WS-VAL1 Literal value 1.
       01 WS-VAL1                      PIC X(16) VALUE "1".
      * @field WS-VAL-REG Literal region name.
       01 WS-VAL-REG                   PIC X(16) VALUE "EMEA".
      * @field WS-VAL-REV Literal initial revenue.
       01 WS-VAL-REV                   PIC X(16) VALUE "1250.5".
      * @field WS-VAL-REV2 Literal updated revenue.
       01 WS-VAL-REV2                  PIC X(16) VALUE "2500.75".
      * @field WS-LEN16 Fixed 16-byte string length argument.
       01 WS-LEN16                     PIC 9(9) COMP-5 VALUE 16.
      * @field WS-IS-NUM Numeric literal flag (0).
       01 WS-IS-NUM                    PIC S9(9) COMP-5 VALUE 0.
      * @field WS-IS-STR String literal flag (1).
       01 WS-IS-STR                    PIC S9(9) COMP-5 VALUE 1.
      * @field WS-ROWS Hydrated row count.
       01 WS-ROWS                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-COLS Hydrated column count.
       01 WS-COLS                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-ROW0 0-based row index 0.
       01 WS-ROW0                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-COL0 0-based column index 0.
       01 WS-COL0                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-CNAME-OUT Introspected column name buffer.
       01 WS-CNAME-OUT                 PIC X(32) VALUE SPACES.
      * @field WS-STR-OUT Hydrated string value buffer.
       01 WS-STR-OUT                   PIC X(32) VALUE SPACES.
      * @field WS-CAP32 32-byte buffer capacity.
       01 WS-CAP32                     PIC 9(9) COMP-5 VALUE 32.
      * @field WS-OLEN Output byte length.
       01 WS-OLEN                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-VTYPE Variant type enum returned by rs_get_type.
       01 WS-VTYPE                     PIC S9(9) COMP-5 VALUE 0.
      * @field WS-ID-OUT Hydrated 64-bit integer ID.
       01 WS-ID-OUT                    PIC S9(18) COMP-5 VALUE 0.
      * @field WS-REV-OUT Hydrated 64-bit float revenue.
       01 WS-REV-OUT                   USAGE COMP-2 VALUE 0.
       PROCEDURE DIVISION.
           CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           STRING "CREATE TABLE SALES (ID INT PRIMARY KEY, "
                  "REGION TEXT, REVENUE REAL)"
                  DELIMITED BY SIZE INTO WS-SQL
           END-STRING
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 2 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_ast_new" USING BY REFERENCE C-ORM-AST-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_insert_into"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-TBL
                     BY VALUE WS-LEN16
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_set_col"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COL-ID
                     BY VALUE WS-LEN16 BY REFERENCE WS-VAL1
                     BY VALUE WS-LEN16 BY VALUE WS-IS-NUM
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_set_col"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COL-REG
                     BY VALUE WS-LEN16 BY REFERENCE WS-VAL-REG
                     BY VALUE WS-LEN16 BY VALUE WS-IS-STR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_set_col"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COL-REV
                     BY VALUE WS-LEN16 BY REFERENCE WS-VAL-REV
                     BY VALUE WS-LEN16 BY VALUE WS-IS-NUM
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_exec"
               USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-AST-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 3 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_ast_free" USING BY VALUE C-ORM-AST-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_new" USING BY REFERENCE C-ORM-AST-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_update_table"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-TBL
                     BY VALUE WS-LEN16
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_set_col"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COL-REV
                     BY VALUE WS-LEN16 BY REFERENCE WS-VAL-REV2
                     BY VALUE WS-LEN16 BY VALUE WS-IS-NUM
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_where_eq"
               USING BY VALUE C-ORM-AST-PTR BY REFERENCE WS-COL-ID
                     BY VALUE WS-LEN16 BY REFERENCE WS-VAL1
                     BY VALUE WS-LEN16 BY VALUE WS-IS-NUM
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ast_exec"
               USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-AST-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 4 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_ast_free" USING BY VALUE C-ORM-AST-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE "SELECT ID, REGION, REVENUE FROM SALES" TO WS-SQL
           CALL "cobol_orm_query_abstract"
               USING BY VALUE C-ORM-DB-PTR BY REFERENCE WS-SQL
                     BY VALUE WS-SQL-LEN BY REFERENCE C-ORM-RS-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 5 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_rs_row_count"
               USING BY VALUE C-ORM-RS-PTR BY REFERENCE WS-ROWS
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_col_count"
               USING BY VALUE C-ORM-RS-PTR BY VALUE WS-ROW0
                     BY REFERENCE WS-COLS
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_col_name"
               USING BY VALUE C-ORM-RS-PTR BY VALUE WS-ROW0
                     BY VALUE WS-COL0 BY REFERENCE WS-CNAME-OUT
                     BY VALUE WS-CAP32 BY REFERENCE WS-OLEN
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_get_type"
               USING BY VALUE C-ORM-RS-PTR BY VALUE WS-ROW0
                     BY REFERENCE WS-COL-REG BY VALUE WS-LEN16
                     BY REFERENCE WS-VTYPE
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_get_i64"
               USING BY VALUE C-ORM-RS-PTR BY VALUE WS-ROW0
                     BY REFERENCE WS-COL-ID BY VALUE WS-LEN16
                     BY REFERENCE WS-ID-OUT
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_get_str"
               USING BY VALUE C-ORM-RS-PTR BY VALUE WS-ROW0
                     BY REFERENCE WS-COL-REG BY VALUE WS-LEN16
                     BY REFERENCE WS-STR-OUT BY VALUE WS-CAP32
                     BY REFERENCE WS-OLEN
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_get_f64"
               USING BY VALUE C-ORM-RS-PTR BY VALUE WS-ROW0
                     BY REFERENCE WS-COL-REV BY VALUE WS-LEN16
                     BY REFERENCE WS-REV-OUT
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_rs_free" USING BY VALUE C-ORM-RS-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF WS-ROWS NOT = 1 OR WS-COLS NOT = 3
              OR WS-CNAME-OUT(1:2) NOT = "ID" OR WS-VTYPE NOT = 3
              OR WS-ID-OUT NOT = 1 OR WS-STR-OUT(1:4) NOT = "EMEA"
              OR WS-REV-OUT < 2500.0 OR WS-REV-OUT > 2501.0
               MOVE 6 TO RETURN-CODE
               STOP RUN
           END-IF
           DISPLAY "EX-ABSTRACT-RS OK: " WS-STR-OUT(1:4).
           STOP RUN.
       END PROGRAM EX-ABSTRACT-RS.
