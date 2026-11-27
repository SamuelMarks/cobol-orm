      * @file test_e2e_fixed.cbl
      * @module cobol_orm_tests
      * @brief Strict fixed 80-column IBM Enterprise (-std=ibm-strict),
      * Micro Focus (-std=mf-strict), and GnuCOBOL E2E test suite
      * exercising every CORM-* wrapper subprogram (happy and error
      * branches for 100% function/line/branch coverage).

      * @program TEST-E2E-FIXED
      * @brief End-to-end fixed-80 GnuCOBOL verification executable.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TEST-E2E-FIXED.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_ibm.cpy".
      * @field WS-URL SQLite in-memory database URL.
       01 WS-URL                       PIC X(256)
                                       VALUE "sqlite://:memory:".
      * @field WS-BAD-URL Invalid connection URL for error test.
       01 WS-BAD-URL                   PIC X(256)
                                       VALUE "badscheme://x".
      * @field WS-SQL SQL buffer for CORM-EXEC-SQL.
       01 WS-SQL                       PIC X(1024) VALUE SPACES.
      * @field WS-SP Savepoint name buffer (32 bytes).
       01 WS-SP                        PIC X(32) VALUE "SP1".
      * @field WS-ERR-MSG Last error message buffer.
       01 WS-ERR-MSG                   PIC X(256) VALUE SPACES.
      * @field WS-VER-BUF Library version buffer.
       01 WS-VER-BUF                   PIC X(32) VALUE SPACES.
      * @field WS-MIG-DIR Path to committed SQL migration scripts.
       01 WS-MIG-DIR                   PIC X(256)
                                       VALUE "examples/migrations".
      * @field WS-LEN Buffer length argument.
       01 WS-LEN                       PIC 9(9) COMP-5 VALUE 0.
      * @field WS-OUT-LEN Output length argument.
       01 WS-OUT-LEN                   PIC 9(9) COMP-5 VALUE 0.
      * @field WS-DRY-RUN Migration dry-run flag.
       01 WS-DRY-RUN                   PIC S9(9) COMP-5 VALUE 0.
      * @field WS-STEPS Migration rollback steps.
       01 WS-STEPS                     PIC 9(9) COMP-5 VALUE 1.
      * @field WS-APPLIED Applied migration count.
       01 WS-APPLIED                   PIC 9(9) COMP-5 VALUE 0.
      * @field WS-POOL-MIN Minimum pool connections.
       01 WS-POOL-MIN                  PIC S9(9) COMP-5 VALUE 1.
      * @field WS-POOL-MAX Maximum pool connections.
       01 WS-POOL-MAX                  PIC S9(9) COMP-5 VALUE 1.
      * @field WS-POOL-TMO Pool acquisition timeout in ms.
       01 WS-POOL-TMO                  PIC S9(9) COMP-5 VALUE 10.
      * @field WS-DB2-PTR Second DB handle for exhaustion test.
       01 WS-DB2-PTR                   USAGE POINTER VALUE NULL.
      * @class WS-COMM-BUF
      * @brief Fixed 544-byte binary COMMAREA test record.
       01 WS-COMM-BUF.
      * @field WS-CA-OP Operation code (15 = version).
           05 WS-CA-OP                 PIC S9(9) COMP-5 VALUE 15.
      * @field WS-CA-ST Output status.
           05 WS-CA-ST                 PIC S9(9) COMP-5 VALUE 0.
      * @field WS-CA-DB DB slot.
           05 WS-CA-DB                 PIC S9(9) COMP-5 VALUE 0.
      * @field WS-CA-SM Statement slot.
           05 WS-CA-SM                 PIC S9(9) COMP-5 VALUE 0.
      * @field WS-CA-PX Param index.
           05 WS-CA-PX                 PIC S9(9) COMP-5 VALUE 0.
      * @field WS-CA-V32 Integer value.
           05 WS-CA-V32                PIC S9(9) COMP-5 VALUE 0.
      * @field WS-CA-L1 Data1 length.
           05 WS-CA-L1                 PIC 9(9) COMP-5 VALUE 0.
      * @field WS-CA-L2 Data2 length.
           05 WS-CA-L2                 PIC 9(9) COMP-5 VALUE 0.
      * @field WS-CA-D1 Input payload.
           05 WS-CA-D1                 PIC X(256) VALUE SPACES.
      * @field WS-CA-D2 Output payload.
           05 WS-CA-D2                 PIC X(256) VALUE SPACES.
      * @class WS-DEC-A
      * @brief First exact decimal value.
       01 WS-DEC-A.
      * @field WS-DA-RAW Raw 41-byte decimal storage.
           05 WS-DA-RAW                PIC X(41) VALUE LOW-VALUES.
      * @class WS-DEC-B
      * @brief Second exact decimal value.
       01 WS-DEC-B.
      * @field WS-DB-RAW Raw 41-byte decimal storage.
           05 WS-DB-RAW                PIC X(41) VALUE LOW-VALUES.
      * @class WS-DEC-R
      * @brief Result exact decimal value.
       01 WS-DEC-R.
      * @field WS-DR-RAW Raw 41-byte decimal storage.
           05 WS-DR-RAW                PIC X(41) VALUE LOW-VALUES.
      * @field WS-STR-A Input decimal string A.
       01 WS-STR-A                     PIC X(16) VALUE "100.25".
      * @field WS-STR-B Input decimal string B.
       01 WS-STR-B                     PIC X(16) VALUE "25.75".
      * @field WS-STR-OUT Formatted output string buffer.
       01 WS-STR-OUT                   PIC X(32) VALUE SPACES.
       PROCEDURE DIVISION.
           SET C-ORM-DB-PTR TO NULL
           CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-ERR-INV-HANDLE
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           SET C-ORM-POOL-PTR TO NULL
           CALL "CORM-POOL-DESTROY" USING C-ORM-POOL-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-ERR-INV-HANDLE
               MOVE 17 TO RETURN-CODE
               STOP RUN
           END-IF
           SET C-ORM-MIG-PTR TO NULL
           CALL "CORM-MIG-FREE" USING C-ORM-MIG-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-ERR-INV-HANDLE
               MOVE 18 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-CONNECT"
               USING WS-BAD-URL C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF C-ORM-OK
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-VERSION"
               USING WS-VER-BUF WS-OUT-LEN C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-VER-BUF(1:5) NOT = "0.1.0"
               MOVE 19 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 2 TO RETURN-CODE
               STOP RUN
           END-IF

           MOVE "INVALID SQL SYNTAX" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           CALL "CORM-LAST-ERROR"
               USING C-ORM-DB-PTR WS-ERR-MSG WS-OUT-LEN C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 20 TO RETURN-CODE
               STOP RUN
           END-IF

           MOVE "CREATE TABLE TX_TEST (ID INT PRIMARY KEY)" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 3 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 4 TO RETURN-CODE
               STOP RUN
           END-IF
           MOVE "INSERT INTO TX_TEST VALUES (1)" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 5 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-TX-SAVEPOINT"
               USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 21 TO RETURN-CODE
               STOP RUN
           END-IF
           MOVE "INSERT INTO TX_TEST VALUES (2)" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           CALL "CORM-TX-RB-SP"
               USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 22 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-TX-REL-SP"
               USING C-ORM-DB-PTR WS-SP C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 23 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-TX-COMMIT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 6 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           CALL "CORM-TX-ROLLBACK" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 7 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-MIG-INIT"
               USING C-ORM-DB-PTR WS-MIG-DIR C-ORM-MIG-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 24 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-MIG-UP"
               USING C-ORM-MIG-PTR WS-DRY-RUN WS-APPLIED C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-APPLIED NOT = 1
               MOVE 25 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-MIG-DOWN"
               USING C-ORM-MIG-PTR WS-STEPS WS-DRY-RUN C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 26 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-MIG-FREE" USING C-ORM-MIG-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 27 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-COMMAREA" USING WS-COMM-BUF
           END-CALL
           IF WS-CA-ST NOT = 0 OR WS-CA-D2(1:5) NOT = "0.1.0"
               MOVE 9 TO RETURN-CODE
               STOP RUN
           END-IF

           CALL "CORM-POOL-INIT"
               USING WS-URL WS-POOL-MIN WS-POOL-MAX WS-POOL-TMO
                     C-ORM-POOL-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 10 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-POOL-ACQUIRE"
               USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 11 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-POOL-ACQUIRE"
               USING C-ORM-POOL-PTR WS-DB2-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-ERR-TIMEOUT
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-POOL-STATS"
               USING C-ORM-POOL-PTR C-ORM-POOL-STATS-REC C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR C-ORM-PS-ACTIVE NOT = 1
               MOVE 13 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-POOL-RELEASE"
               USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           CALL "CORM-POOL-DESTROY" USING C-ORM-POOL-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 14 TO RETURN-CODE
               STOP RUN
           END-IF

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
               MOVE 15 TO RETURN-CODE
               STOP RUN
           END-IF

           GOBACK.
       END PROGRAM TEST-E2E-FIXED.
