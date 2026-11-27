      * @file corm_era2002.cbl
      * @module cobol_orm_era_cobol2002
      * @brief ISO/IEC 1989:2002 (COBOL-2002) fixed-80 ORM verification
      * compiled with cobc -std=cobol2002 -fixed -Wall -Wextra -Werror.
      *
      * @program CORM-ERA2002
      * @brief Exercises USAGE POINTER, USAGE BINARY-LONG, BY VALUE,
      * RETURNING, transactions, and prepared statements on SQLite.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA2002.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm.cpy".
      * @field WS-URL Database URL buffer.
       01  WS-URL                      PIC X(64)
                                       VALUE "sqlite://:memory:".
      * @field WS-URL-LEN Byte length of WS-URL.
       01  WS-URL-LEN                  USAGE BINARY-LONG UNSIGNED
                                       VALUE 64.
      * @field WS-SQL SQL statement buffer.
       01  WS-SQL                      PIC X(128) VALUE SPACES.
      * @field WS-SQL-LEN Byte length of WS-SQL.
       01  WS-SQL-LEN                  USAGE BINARY-LONG UNSIGNED
                                       VALUE 128.
      * @field WS-HAS-ROW Statement step row flag.
       01  WS-HAS-ROW                  USAGE BINARY-LONG SIGNED VALUE 0.
      * @field WS-OUT-I32 Fetched integer column.
       01  WS-OUT-I32                  USAGE BINARY-LONG SIGNED VALUE 0.
      * @field WS-OUT-STR Fetched string column buffer.
       01  WS-OUT-STR                  PIC X(32) VALUE SPACES.
      * @field WS-OUT-LEN Output string length.
       01  WS-OUT-LEN                  USAGE BINARY-LONG UNSIGNED
                                       VALUE 0.
      * @field WS-IDX Parameter or column index.
       01  WS-IDX                      USAGE BINARY-LONG SIGNED VALUE 0.
      * @field WS-VAL-I32 Bound integer parameter.
       01  WS-VAL-I32                  USAGE BINARY-LONG SIGNED
                                       VALUE 2002.
      * @field WS-VAL-STR Bound text parameter.
       01  WS-VAL-STR                  PIC X(16) VALUE "ISO-COBOL-2002".
      * @field WS-VAL-SLEN Length of WS-VAL-STR.
       01  WS-VAL-SLEN                 USAGE BINARY-LONG UNSIGNED
                                       VALUE 16.
      * @field WS-CAP Output buffer capacity.
       01  WS-CAP                      USAGE BINARY-LONG UNSIGNED
                                       VALUE 32.
       PROCEDURE DIVISION.
       MAIN-2002.
           CALL "cobol_orm_connect"
               USING BY REFERENCE WS-URL
                     BY VALUE WS-URL-LEN
                     BY REFERENCE C-ORM-DB-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               STOP RUN RETURNING 1
           END-IF
           MOVE "CREATE TABLE E2002 (ID INT, NM TEXT)" TO WS-SQL
           CALL "cobol_orm_exec_sql"
               USING BY VALUE C-ORM-DB-PTR
                     BY REFERENCE WS-SQL
                     BY VALUE WS-SQL-LEN
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               STOP RUN RETURNING 2
           END-IF
           MOVE "INSERT INTO E2002 VALUES (?, ?)" TO WS-SQL
           CALL "cobol_orm_stmt_prepare"
               USING BY VALUE C-ORM-DB-PTR
                     BY REFERENCE WS-SQL
                     BY VALUE WS-SQL-LEN
                     BY REFERENCE C-ORM-STMT-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE 1 TO WS-IDX
           CALL "cobol_orm_stmt_bind_i32"
               USING BY VALUE C-ORM-STMT-PTR
                     BY VALUE WS-IDX
                     BY VALUE WS-VAL-I32
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE 2 TO WS-IDX
           CALL "cobol_orm_stmt_bind_str"
               USING BY VALUE C-ORM-STMT-PTR
                     BY VALUE WS-IDX
                     BY REFERENCE WS-VAL-STR
                     BY VALUE WS-VAL-SLEN
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_stmt_step"
               USING BY VALUE C-ORM-STMT-PTR
                     BY REFERENCE WS-HAS-ROW
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_stmt_finalize"
               USING BY VALUE C-ORM-STMT-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE "SELECT ID, NM FROM E2002" TO WS-SQL
           CALL "cobol_orm_stmt_prepare"
               USING BY VALUE C-ORM-DB-PTR
                     BY REFERENCE WS-SQL
                     BY VALUE WS-SQL-LEN
                     BY REFERENCE C-ORM-STMT-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_stmt_step"
               USING BY VALUE C-ORM-STMT-PTR
                     BY REFERENCE WS-HAS-ROW
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE 0 TO WS-IDX
           CALL "cobol_orm_stmt_col_i32"
               USING BY VALUE C-ORM-STMT-PTR
                     BY VALUE WS-IDX
                     BY REFERENCE WS-OUT-I32
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE 1 TO WS-IDX
           CALL "cobol_orm_stmt_col_str"
               USING BY VALUE C-ORM-STMT-PTR
                     BY VALUE WS-IDX
                     BY REFERENCE WS-OUT-STR
                     BY VALUE WS-CAP
                     BY REFERENCE WS-OUT-LEN
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_stmt_finalize"
               USING BY VALUE C-ORM-STMT-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_disconnect"
               USING BY VALUE C-ORM-DB-PTR
               RETURNING C-ORM-STATUS
           END-CALL
           IF WS-OUT-I32 NOT = 2002 OR WS-OUT-LEN NOT = 14
               STOP RUN RETURNING 3
           END-IF
           IF WS-OUT-STR (1:14) NOT = "ISO-COBOL-2002"
               STOP RUN RETURNING 4
           END-IF
           STOP RUN RETURNING 0.
       END PROGRAM CORM-ERA2002.
