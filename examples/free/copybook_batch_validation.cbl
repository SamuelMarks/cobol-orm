>>SOURCE FORMAT IS FREE
*> @file copybook_batch_validation.cbl
*> @module cobol_orm_examples
*> @brief Demonstrates IBM Db2 DCLGEN Copybook parsing, layout introspection,
*> multi-dialect DDL emission, level-88 THRU/value validation enforcement,
*> record updates, and batch OCCURS hydration via cobol_orm_cpy_find_all.

*> @program EX-CPY-BATCH
*> @brief Parses a payroll DCLGEN Copybook, enforces level-88 grade rules,
*> inserts and updates employee records, and hydrates an OCCURS table.
IDENTIFICATION DIVISION.
PROGRAM-ID. EX-CPY-BATCH.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
*> @field WS-URL In-memory SQLite connection URL.
01 WS-URL                             PIC X(256) VALUE "sqlite://:memory:".
*> @field WS-CPY DCLGEN + 01 employee record Copybook text.
01 WS-CPY                             PIC X(512) VALUE SPACES.
*> @field WS-CPY-LEN Byte length of WS-CPY.
01 WS-CPY-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-DDL Emitted multi-dialect CREATE TABLE DDL buffer.
01 WS-DDL                             PIC X(512) VALUE SPACES.
*> @field WS-DDL-CAP Capacity of WS-DDL.
01 WS-DDL-CAP                         USAGE BINARY-LONG UNSIGNED VALUE 512.
*> @field WS-DDL-LEN Unpadded byte length of emitted DDL.
01 WS-DDL-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-FLD0 First field index for layout introspection.
01 WS-FLD0                            USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @class WS-EMP-REC
*> @brief Working-Storage 01 employee payroll record (20 bytes).
01 WS-EMP-REC.
   *> @field WS-EMP-ID Employee primary key (4 bytes big-endian COMP).
   05 WS-EMP-ID                       PIC S9(9) USAGE COMP VALUE 10.
   *> @field WS-EMP-NAME Employee full name (10 bytes PIC X).
   05 WS-EMP-NAME                     PIC X(10) VALUE "ADA LOVEL ".
   *> @field WS-EMP-GRADE Pay grade code ('A'..'C' enforced by level-88).
   05 WS-EMP-GRADE                    PIC X(2) VALUE "ZZ".
   *> @field WS-EMP-SAL Monthly salary in COMP-3 (4 bytes).
   05 WS-EMP-SAL                      PIC S9(5)V99 USAGE PACKED-DECIMAL VALUE 7500.00.
*> @class WS-EMP-TABLE
*> @brief Contiguous OCCURS array hydrated by cobol_orm_cpy_find_all.
01 WS-EMP-TABLE.
   *> @class WS-EMP-ROW
   *> @brief Single row entry in WS-EMP-TABLE.
   05 WS-EMP-ROW OCCURS 4 TIMES.
      *> @field WS-T-ID Hydrated employee ID.
      10 WS-T-ID                      PIC S9(9) USAGE COMP VALUE 0.
      *> @field WS-T-NAME Hydrated employee name.
      10 WS-T-NAME                    PIC X(10) VALUE SPACES.
      *> @field WS-T-GRADE Hydrated pay grade.
      10 WS-T-GRADE                   PIC X(2) VALUE SPACES.
      *> @field WS-T-SAL Hydrated COMP-3 salary.
      10 WS-T-SAL                     PIC S9(5)V99 USAGE PACKED-DECIMAL VALUE 0.
*> @field WS-REC-LEN Byte length of WS-EMP-REC.
01 WS-REC-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-BIG-END Big-endian COMP flag (1 = big-endian).
01 WS-BIG-END                         USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-MAX-ROWS Maximum rows capacity in WS-EMP-TABLE.
01 WS-MAX-ROWS                        USAGE BINARY-LONG UNSIGNED VALUE 4.
*> @field WS-HYDRATED Number of rows hydrated by find_all.
01 WS-HYDRATED                        USAGE BINARY-LONG UNSIGNED VALUE 0.
PROCEDURE DIVISION.
    CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF
    STRING "EXEC SQL DECLARE EMP_MASTER TABLE ("
           "EMP_ID INT PRIMARY KEY, EMP_NAME CHAR(10), "
           "EMP_GRADE CHAR(2), EMP_SAL DECIMAL(7,2)) END-EXEC. "
           "01 EMP-REC. "
           "05 EMP-ID PIC S9(9) COMP. "
           "05 EMP-NAME PIC X(10). "
           "05 EMP-GRADE PIC X(2). "
           "88 GRADE-VALID VALUE 'A' THRU 'C'. "
           "05 EMP-SAL PIC S9(5)V99 COMP-3."
           DELIMITED BY SIZE INTO WS-CPY
    END-STRING
    MOVE FUNCTION BYTE-LENGTH(WS-CPY) TO WS-CPY-LEN
    SET C-ORM-FMT-FREE TO TRUE
    CALL "cobol_orm_cpy_parse_str"
        USING BY REFERENCE WS-CPY BY VALUE WS-CPY-LEN
              BY VALUE C-ORM-CPY-FMT BY REFERENCE C-ORM-CPY-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 2
    END-IF
    CALL "cobol_orm_cpy_info"
        USING BY VALUE C-ORM-CPY-PTR BY REFERENCE C-ORM-CPY-INFO-REC
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_cpy_field_info"
        USING BY VALUE C-ORM-CPY-PTR BY VALUE WS-FLD0
              BY REFERENCE C-ORM-COL-INFO-REC
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR C-ORM-CI-DCLGEN NOT = 1 OR C-ORM-CI-FIELDS NOT = 4
       OR C-ORM-COL-IS-PK NOT = 1
        STOP RUN RETURNING 3
    END-IF
    SET C-ORM-DL-DB2 TO TRUE
    CALL "cobol_orm_cpy_emit_ddl"
        USING BY VALUE C-ORM-CPY-PTR BY VALUE C-ORM-DIALECT
              BY REFERENCE WS-DDL BY VALUE WS-DDL-CAP BY REFERENCE WS-DDL-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-DDL-LEN = 0
        STOP RUN RETURNING 4
    END-IF
    SET C-ORM-DL-SQLITE TO TRUE
    CALL "cobol_orm_cpy_create_table"
        USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-CPY-PTR
              BY VALUE C-ORM-DIALECT
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 5
    END-IF
    MOVE FUNCTION BYTE-LENGTH(WS-EMP-REC) TO WS-REC-LEN
    SET C-ORM-CP-ASCII-V TO TRUE
    CALL "cobol_orm_cpy_validate_88"
        USING BY VALUE C-ORM-CPY-PTR BY REFERENCE WS-EMP-REC
              BY VALUE WS-REC-LEN BY VALUE C-ORM-CODEPAGE BY VALUE WS-BIG-END
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-ERR-VALIDATION
        STOP RUN RETURNING 6
    END-IF
    MOVE "A " TO WS-EMP-GRADE
    CALL "cobol_orm_cpy_validate_88"
        USING BY VALUE C-ORM-CPY-PTR BY REFERENCE WS-EMP-REC
              BY VALUE WS-REC-LEN BY VALUE C-ORM-CODEPAGE BY VALUE WS-BIG-END
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 7
    END-IF
    CALL "cobol_orm_cpy_insert"
        USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-CPY-PTR
              BY REFERENCE WS-EMP-REC BY VALUE WS-REC-LEN
              BY VALUE C-ORM-CODEPAGE BY VALUE WS-BIG-END
        RETURNING C-ORM-STATUS
    END-CALL
    MOVE 8250.50 TO WS-EMP-SAL
    CALL "cobol_orm_cpy_update"
        USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-CPY-PTR
              BY REFERENCE WS-EMP-REC BY VALUE WS-REC-LEN
              BY VALUE C-ORM-CODEPAGE BY VALUE WS-BIG-END
        RETURNING C-ORM-STATUS
    END-CALL
    MOVE 20 TO WS-EMP-ID
    MOVE "ALAN TURIN" TO WS-EMP-NAME
    MOVE "B " TO WS-EMP-GRADE
    MOVE 9100.25 TO WS-EMP-SAL
    CALL "cobol_orm_cpy_insert"
        USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-CPY-PTR
              BY REFERENCE WS-EMP-REC BY VALUE WS-REC-LEN
              BY VALUE C-ORM-CODEPAGE BY VALUE WS-BIG-END
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_cpy_find_all"
        USING BY VALUE C-ORM-DB-PTR BY VALUE C-ORM-CPY-PTR
              BY VALUE C-ORM-CODEPAGE BY VALUE WS-BIG-END
              BY REFERENCE WS-EMP-TABLE BY VALUE WS-MAX-ROWS
              BY REFERENCE WS-HYDRATED
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-HYDRATED NOT = 2
       OR WS-T-SAL(1) NOT = 8250.50 OR WS-T-ID(2) NOT = 20
        STOP RUN RETURNING 8
    END-IF
    CALL "cobol_orm_cpy_free"
        USING BY VALUE C-ORM-CPY-PTR
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    DISPLAY "EX-CPY-BATCH OK: HYDRATED=2"
    END-DISPLAY
    STOP RUN RETURNING 0.
END PROGRAM EX-CPY-BATCH.
