      * @file legacy_commarea_payroll.cbl
      * @module cobol_orm_examples
      * @brief Historical COBOL-60 through COBOL-85 pure USAGE DISPLAY
      * payroll batch example using the 552-byte endian-independent
      * COMMAREA bridge with zero USAGE POINTER or BY VALUE syntax.

      * @program EX-LEG-PAY
      * @brief Runs a transactional payroll batch insert and lookup
      * using ANSI COBOL-85 (-std=cobol85) and pure DISPLAY COMMAREA.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-LEG-PAY.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @class WS-PAY-TABLE
      * @brief Static payroll batch input records for three employees.
       01  WS-PAY-TABLE.
      *    @field WS-PAY-E1 First employee batch literal.
           05  WS-PAY-E1               PIC X(16)
                                       VALUE "1001HOPPER      ".
      *    @field WS-PAY-E2 Second employee batch literal.
           05  WS-PAY-E2               PIC X(16)
                                       VALUE "1002TURING      ".
      *    @field WS-PAY-E3 Third employee batch literal.
           05  WS-PAY-E3               PIC X(16)
                                       VALUE "1003LOVELACE    ".
      * @class WS-PAY-ARRAY
      * @brief Redefined OCCURS view of WS-PAY-TABLE.
       01  WS-PAY-ARRAY REDEFINES WS-PAY-TABLE.
      *    @class WS-PAY-ITEM
      *    @brief Single employee entry in payroll batch table.
           05  WS-PAY-ITEM OCCURS 3 TIMES.
      *        @field WS-PAY-ID Employee numeric ID.
               10  WS-PAY-ID           PIC 9(4).
      *        @field WS-PAY-NAME Employee surname.
               10  WS-PAY-NAME         PIC X(12).
      * @field WS-IDX Loop index for batch insertion.
       01  WS-IDX                      PIC 9(2) VALUE 0.
      * @field WS-FETCHED Count of retrieved payroll rows.
       01  WS-FETCHED                  PIC 9(2) VALUE 0.
      * @field WS-LAST-NAME Last fetched employee surname.
       01  WS-LAST-NAME                PIC X(12) VALUE SPACES.
       PROCEDURE DIVISION.
       MAIN-PAYROLL.
           INITIALIZE CORM-DISP-COMMAREA
           MOVE 1 TO CORM-CA-OPCODE
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           IF NOT CORM-ST-OK
               DISPLAY "FAIL: EX-LEG-PAY CONNECT"
               STOP RUN
           END-IF
           MOVE 3 TO CORM-CA-OPCODE
           MOVE "CREATE TABLE PAYROLL (EMP_ID INT, EMP_NM TEXT)"
               TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 4 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 3
               MOVE 7 TO CORM-CA-OPCODE
               MOVE "INSERT INTO PAYROLL VALUES (?, ?)"
                   TO CORM-CA-DATA1
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
               MOVE 8 TO CORM-CA-OPCODE
               MOVE 1 TO CORM-CA-PARAM-IDX
               MOVE "+" TO CORM-CA-VAL-SIGN
               MOVE WS-PAY-ID (WS-IDX) TO CORM-CA-VAL-NUM
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
               MOVE 9 TO CORM-CA-OPCODE
               MOVE 2 TO CORM-CA-PARAM-IDX
               MOVE WS-PAY-NAME (WS-IDX) TO CORM-CA-DATA1
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
               MOVE 10 TO CORM-CA-OPCODE
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
               MOVE 13 TO CORM-CA-OPCODE
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
           END-PERFORM
           MOVE 5 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 7 TO CORM-CA-OPCODE
           MOVE "SELECT EMP_NM FROM PAYROLL ORDER BY EMP_ID"
               TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           PERFORM UNTIL WS-FETCHED = 3
               MOVE 10 TO CORM-CA-OPCODE
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
               IF CORM-CA-VAL-NUM = 0
                   EXIT PERFORM
               END-IF
               MOVE 12 TO CORM-CA-OPCODE
               MOVE 0 TO CORM-CA-PARAM-IDX
               CALL "cobol_orm_display_dispatch"
                   USING BY REFERENCE CORM-DISP-COMMAREA
               END-CALL
               MOVE CORM-CA-DATA2 (1:12) TO WS-LAST-NAME
               ADD 1 TO WS-FETCHED END-ADD
           END-PERFORM
           MOVE 13 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 2 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           IF WS-FETCHED = 3 AND WS-LAST-NAME (1:8) = "LOVELACE"
               DISPLAY "EX-LEG-PAY OK: ROWS=3 LAST=LOVELACE"
           ELSE
               DISPLAY "FAIL: EX-LEG-PAY"
           END-IF
           STOP RUN.
