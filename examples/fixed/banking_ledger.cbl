      * @file banking_ledger.cbl
      * @module cobol_orm_examples
      * @brief Mainframe banking ledger example using transactions,
      * savepoints,
      * 38-digit fixed-point decimal math, and IBM037 EBCDIC
      * transcoding.

      * @program EX-BANKING
      * @brief Posts an atomic debit/credit transfer with savepoint
      * rollback and
      * IBM037 EBCDIC audit string transcoding.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-BANKING.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm.cpy".
      * @field WS-URL Database URL.
       01 WS-URL PIC X(256) VALUE "sqlite://:memory:".
      * @field WS-SQL SQL buffer.
       01 WS-SQL                             PIC X(1024) VALUE SPACES.
      * @field WS-SP Savepoint identifier.
       01 WS-SP                              PIC X(8) VALUE "FEE_SP".
      * @field WS-SP-LEN Length of savepoint name.
       01 WS-SP-LEN USAGE BINARY-LONG UNSIGNED VALUE 8.
      * @field WS-DEC-A Opening ledger balance (41-byte fixed-point
      * struct).
       01 WS-DEC-A                           PIC X(41) VALUE LOW-VALUES.
      * @field WS-DEC-B Deposit amount (41-byte fixed-point struct).
       01 WS-DEC-B                           PIC X(41) VALUE LOW-VALUES.
      * @field WS-DEC-SUM Resulting ledger balance.
       01 WS-DEC-SUM                         PIC X(41) VALUE LOW-VALUES.
      * @field WS-SA Opening balance string.
       01 WS-SA PIC X(16) VALUE "500000.50".
      * @field WS-SB Deposit amount string.
       01 WS-SB                              PIC X(16) VALUE "12500.75".
      * @field WS-SLEN Input decimal string length.
       01 WS-SLEN USAGE BINARY-LONG UNSIGNED VALUE 16.
      * @field WS-SOUT Formatted balance buffer.
       01 WS-SOUT                            PIC X(32) VALUE SPACES.
      * @field WS-SCAP Formatted buffer capacity.
       01 WS-SCAP USAGE BINARY-LONG UNSIGNED VALUE 32.
      * @field WS-OLEN Output string byte count.
       01 WS-OLEN USAGE BINARY-LONG UNSIGNED VALUE 0.
      * @field WS-EBCDIC Encoded IBM037 EBCDIC audit tag.
       01 WS-EBCDIC                          PIC X(32) VALUE LOW-VALUES.
      * @field WS-ELEN Output EBCDIC byte count.
       01 WS-ELEN USAGE BINARY-LONG UNSIGNED VALUE 0.
       PROCEDURE DIVISION.
           CALL "CORM-CONNECT" USING WS-URL C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
           STOP RUN RETURNING 1
           END-IF
           MOVE "CREATE TABLE LEDGER (ID INT, AMT TEXT)" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           CALL "CORM-TX-BEGIN" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           MOVE "INSERT INTO LEDGER VALUES (1, '500000.50')" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_tx_savepoint"
           USING BY VALUE C-ORM-DB-PTR
           BY REFERENCE WS-SP
           BY VALUE WS-SP-LEN
           RETURNING C-ORM-STATUS
           END-CALL
           MOVE "INSERT INTO LEDGER VALUES (2, 'CANCELLED')" TO WS-SQL
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_tx_rollback_sp"
           USING BY VALUE C-ORM-DB-PTR
           BY REFERENCE WS-SP
           BY VALUE WS-SP-LEN
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "CORM-TX-COMMIT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_from_str"
           USING BY REFERENCE WS-SA BY VALUE WS-SLEN BY REFERENCE
               WS-DEC-A
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_from_str"
           USING BY REFERENCE WS-SB BY VALUE WS-SLEN BY REFERENCE
               WS-DEC-B
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_add"
           USING BY REFERENCE WS-DEC-A BY REFERENCE WS-DEC-B BY
               REFERENCE WS-DEC-SUM
           RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_to_str"
           USING BY REFERENCE WS-DEC-SUM BY REFERENCE WS-SOUT BY VALUE
               WS-SCAP
           BY REFERENCE WS-OLEN
           RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-SOUT(1:9) NOT = "512501.25"
           STOP RUN RETURNING 2
           END-IF
           SET C-ORM-CP-IBM037-V TO TRUE
           CALL "cobol_orm_utf8_to_ebcdic"
           USING BY VALUE C-ORM-CODEPAGE BY REFERENCE WS-SOUT BY VALUE
               WS-OLEN
           BY REFERENCE WS-EBCDIC BY VALUE WS-SCAP BY REFERENCE WS-ELEN
           RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-ELEN NOT = 9
           STOP RUN RETURNING 3
           END-IF
           CALL "CORM-DISCONNECT" USING C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           DISPLAY "EX-BANKING OK: " WS-SOUT(1:9)
           END-DISPLAY
           STOP RUN RETURNING 0.
       END PROGRAM EX-BANKING.
