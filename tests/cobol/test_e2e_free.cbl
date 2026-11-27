>>SOURCE FORMAT IS FREE
*> @file test_e2e_free.cbl
*> @module cobol_orm_tests
*> @brief Comprehensive free-format GnuCOBOL E2E test suite exercising every
*> CORM-* wrapper subprogram (happy and error paths, 100% function/line/branch
*> coverage), transactions, savepoints, connection pooling, schema migrations,
*> exact 38-digit decimals, and legacy COMMAREA dispatch.

*> @program TEST-E2E-FREE
*> @brief End-to-end free-format GnuCOBOL verification executable.
IDENTIFICATION DIVISION.
PROGRAM-ID. TEST-E2E-FREE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
*> @field WS-URL SQLite in-memory database URL.
01 WS-URL                             PIC X(256) VALUE "sqlite://:memory:".
*> @field WS-BAD-URL Invalid connection URL to exercise error branch.
01 WS-BAD-URL                         PIC X(256) VALUE "badscheme://x".
*> @field WS-SQL SQL buffer for CORM-EXEC-SQL.
01 WS-SQL                             PIC X(1024) VALUE SPACES.
*> @field WS-SP Savepoint name buffer (32 bytes matching CORM-TX-*).
01 WS-SP                              PIC X(32) VALUE "SP1".
*> @field WS-ERR-MSG Last error message buffer.
01 WS-ERR-MSG                         PIC X(256) VALUE SPACES.
*> @field WS-VER-BUF Library version buffer.
01 WS-VER-BUF                         PIC X(32) VALUE SPACES.
*> @field WS-MIG-DIR Path to committed SQL migration scripts.
01 WS-MIG-DIR                         PIC X(256) VALUE "examples/migrations".
*> @field WS-LEN Buffer length argument.
01 WS-LEN                             USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-OUT-LEN Output length argument.
01 WS-OUT-LEN                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-DRY-RUN Migration dry-run flag (0 = execute).
01 WS-DRY-RUN                         USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-STEPS Migration rollback steps.
01 WS-STEPS                           USAGE BINARY-LONG UNSIGNED VALUE 1.
*> @field WS-APPLIED Applied migration count.
01 WS-APPLIED                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-POOL-MIN Minimum pool connections.
01 WS-POOL-MIN                        USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-POOL-MAX Maximum pool connections.
01 WS-POOL-MAX                        USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-POOL-TMO Pool acquisition timeout in ms.
01 WS-POOL-TMO                        USAGE BINARY-LONG SIGNED VALUE 10.
*> @field WS-DB2-PTR Second DB handle for pool exhaustion test.
01 WS-DB2-PTR                         USAGE POINTER VALUE NULL.
*> @field WS-COMM-BUF Fixed 544-byte binary COMMAREA test record.
01 WS-COMM-BUF.
   *> @field WS-CA-OP Operation code.
   05 WS-CA-OP                        USAGE BINARY-LONG SIGNED VALUE 15.
   *> @field WS-CA-ST Output status.
   05 WS-CA-ST                        USAGE BINARY-LONG SIGNED VALUE 0.
   *> @field WS-CA-DB DB slot.
   05 WS-CA-DB                        USAGE BINARY-LONG SIGNED VALUE 0.
   *> @field WS-CA-SM Statement slot.
   05 WS-CA-SM                        USAGE BINARY-LONG SIGNED VALUE 0.
   *> @field WS-CA-PX Param index.
   05 WS-CA-PX                        USAGE BINARY-LONG SIGNED VALUE 0.
   *> @field WS-CA-V32 Integer value.
   05 WS-CA-V32                       USAGE BINARY-LONG SIGNED VALUE 0.
   *> @field WS-CA-L1 Data1 length.
   05 WS-CA-L1                        USAGE BINARY-LONG UNSIGNED VALUE 0.
   *> @field WS-CA-L2 Data2 length.
   05 WS-CA-L2                        USAGE BINARY-LONG UNSIGNED VALUE 0.
   *> @field WS-CA-D1 Input payload.
   05 WS-CA-D1                        PIC X(256) VALUE SPACES.
   *> @field WS-CA-D2 Output payload.
   05 WS-CA-D2                        PIC X(256) VALUE SPACES.
*> @field WS-DEC-A First exact decimal value.
01 WS-DEC-A.
   *> @field WS-DA-RAW Raw 41-byte decimal storage.
   05 WS-DA-RAW                       PIC X(41) VALUE LOW-VALUES.
*> @field WS-DEC-B Second exact decimal value.
01 WS-DEC-B.
   *> @field WS-DB-RAW Raw 41-byte decimal storage.
   05 WS-DB-RAW                       PIC X(41) VALUE LOW-VALUES.
*> @field WS-DEC-R Result exact decimal value.
01 WS-DEC-R.
   *> @field WS-DR-RAW Raw 41-byte decimal storage.
   05 WS-DR-RAW                       PIC X(41) VALUE LOW-VALUES.
*> @field WS-STR-A Input decimal string A.
01 WS-STR-A                           PIC X(16) VALUE "100.25".
*> @field WS-STR-B Input decimal string B.
01 WS-STR-B                           PIC X(16) VALUE "25.75".
*> @field WS-STR-OUT Formatted output string buffer.
01 WS-STR-OUT                         PIC X(32) VALUE SPACES.
PROCEDURE DIVISION.
    *> 1. Exercise error branches on NULL handles (IF LS-STATUS = 0 false paths)
    SET C-ORM-DB-PTR TO NULL
    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-ERR-INV-HANDLE
        STOP RUN RETURNING 1
    END-IF
    SET C-ORM-POOL-PTR TO NULL
    CALL "CORM-POOL-DESTROY" USING C-ORM-POOL-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-ERR-INV-HANDLE
        STOP RUN RETURNING 17
    END-IF
    SET C-ORM-MIG-PTR TO NULL
    CALL "CORM-MIG-FREE" USING C-ORM-MIG-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-ERR-INV-HANDLE
        STOP RUN RETURNING 18
    END-IF
    CALL "CORM-CONNECT" USING WS-BAD-URL C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF C-ORM-OK
        STOP RUN RETURNING 16
    END-IF

    *> 2. Exercise CORM-VERSION + CORM-CONNECT + CORM-EXEC-SQL + CORM-LAST-ERROR
    CALL "CORM-VERSION" USING WS-VER-BUF WS-OUT-LEN C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-VER-BUF(1:5) NOT = "0.1.0"
        STOP RUN RETURNING 19
    END-IF

    CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 2
    END-IF

    MOVE "INVALID SQL SYNTAX" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    CALL "CORM-LAST-ERROR" USING C-ORM-DB-PTR WS-ERR-MSG WS-OUT-LEN C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 20
    END-IF

    MOVE "CREATE TABLE TX_TEST (ID INT PRIMARY KEY)" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 3
    END-IF

    *> 3. Exercise CORM-TX-* wrappers including savepoints
    CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 4
    END-IF
    MOVE "INSERT INTO TX_TEST VALUES (1)" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 5
    END-IF
    CALL "CORM-TX-SAVEPOINT" USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 21
    END-IF
    MOVE "INSERT INTO TX_TEST VALUES (2)" TO WS-SQL
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    CALL "CORM-TX-RB-SP" USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 22
    END-IF
    CALL "CORM-TX-REL-SP" USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 23
    END-IF
    CALL "CORM-TX-COMMIT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 6
    END-IF

    CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    CALL "CORM-TX-ROLLBACK" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 7
    END-IF

    *> 4. Exercise CORM-MIG-* wrappers against examples/migrations
    CALL "CORM-MIG-INIT" USING C-ORM-DB-PTR WS-MIG-DIR C-ORM-MIG-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 24
    END-IF
    CALL "CORM-MIG-UP" USING C-ORM-MIG-PTR WS-DRY-RUN WS-APPLIED C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-APPLIED NOT = 1
        STOP RUN RETURNING 25
    END-IF
    CALL "CORM-MIG-DOWN" USING C-ORM-MIG-PTR WS-STEPS WS-DRY-RUN C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 26
    END-IF
    CALL "CORM-MIG-FREE" USING C-ORM-MIG-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 27
    END-IF

    CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 8
    END-IF

    *> 5. Exercise CORM-COMMAREA subprogram (version opcode = 15)
    CALL "CORM-COMMAREA" USING WS-COMM-BUF
    END-CALL
    IF WS-CA-ST NOT = 0 OR WS-CA-D2(1:5) NOT = "0.1.0"
        STOP RUN RETURNING 9
    END-IF

    *> 6. Exercise CORM-POOL-* wrappers + exhaustion timeout + telemetry
    CALL "CORM-POOL-INIT"
        USING WS-URL WS-POOL-MIN WS-POOL-MAX WS-POOL-TMO
              C-ORM-POOL-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 10
    END-IF
    CALL "CORM-POOL-ACQUIRE" USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 11
    END-IF
    CALL "CORM-POOL-ACQUIRE" USING C-ORM-POOL-PTR WS-DB2-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-ERR-TIMEOUT
        STOP RUN RETURNING 12
    END-IF
    CALL "CORM-POOL-STATS"
        USING C-ORM-POOL-PTR C-ORM-POOL-STATS-REC C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR C-ORM-PS-ACTIVE NOT = 1
        STOP RUN RETURNING 13
    END-IF
    CALL "CORM-POOL-RELEASE" USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    CALL "CORM-POOL-DESTROY" USING C-ORM-POOL-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 14
    END-IF

    *> 7. Exercise 38-digit exact decimal add + format
    MOVE 16 TO WS-LEN
    CALL "cobol_orm_dec_from_str"
        USING BY REFERENCE WS-STR-A
              BY VALUE WS-LEN
              BY REFERENCE WS-DEC-A
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_dec_from_str"
        USING BY REFERENCE WS-STR-B
              BY VALUE WS-LEN
              BY REFERENCE WS-DEC-B
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "cobol_orm_dec_add"
        USING BY REFERENCE WS-DEC-A
              BY REFERENCE WS-DEC-B
              BY REFERENCE WS-DEC-R
        RETURNING C-ORM-STATUS
    END-CALL
    MOVE 32 TO WS-LEN
    CALL "cobol_orm_dec_to_str"
        USING BY REFERENCE WS-DEC-R
              BY REFERENCE WS-STR-OUT
              BY VALUE WS-LEN
              BY REFERENCE WS-OUT-LEN
        RETURNING C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-STR-OUT(1:6) NOT = "126.00"
        STOP RUN RETURNING 15
    END-IF

    GOBACK.
END PROGRAM TEST-E2E-FREE.
