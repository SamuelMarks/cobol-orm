      * @file corm_era85.cbl
      * @module cobol_orm_era_cobol85
      * @brief ANSI COBOL-85 (X3.23-1985) strict fixed-80 ORM program
      * compiled with cobc -std=cobol85 -fixed -Wall -Wextra -Werror.
      *
      * @program CORM-ERA85
      * @brief Exercises structured END-IF, END-CALL, EVALUATE,
      * INITIALIZE, and CONTINUE over live SQLite CRUD and transactions.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA85.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @field WS-OK-COUNT Number of verified assertions.
       01  WS-OK-COUNT                 PIC 9(4) VALUE 0.
       PROCEDURE DIVISION.
       MAIN-85.
           INITIALIZE CORM-DISP-COMMAREA
           MOVE 1 TO CORM-CA-OPCODE
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           EVALUATE TRUE
               WHEN CORM-ST-OK
                   ADD 1 TO WS-OK-COUNT END-ADD
               WHEN OTHER
                   DISPLAY "FAIL: COBOL-85"
                   STOP RUN
           END-EVALUATE
           MOVE 3 TO CORM-CA-OPCODE
           MOVE "CREATE TABLE E85 (ID INT, NM TEXT)"
               TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 4 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 7 TO CORM-CA-OPCODE
           MOVE "INSERT INTO E85 VALUES (?, ?)" TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 8 TO CORM-CA-OPCODE
           MOVE 1 TO CORM-CA-PARAM-IDX
           MOVE "+" TO CORM-CA-VAL-SIGN
           MOVE 85 TO CORM-CA-VAL-NUM
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 9 TO CORM-CA-OPCODE
           MOVE 2 TO CORM-CA-PARAM-IDX
           MOVE "ANSI-COBOL-85" TO CORM-CA-DATA1
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
           MOVE 5 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 7 TO CORM-CA-OPCODE
           MOVE "SELECT NM FROM E85 WHERE ID = 85" TO CORM-CA-DATA1
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 10 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 12 TO CORM-CA-OPCODE
           MOVE 0 TO CORM-CA-PARAM-IDX
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           IF CORM-CA-DATA2 (1:13) = "ANSI-COBOL-85"
               ADD 1 TO WS-OK-COUNT END-ADD
           ELSE
               CONTINUE
           END-IF
           MOVE 13 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           MOVE 15 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           IF CORM-CA-DATA2 (1:5) = "0.1.0"
               ADD 1 TO WS-OK-COUNT END-ADD
           END-IF
           MOVE 2 TO CORM-CA-OPCODE
           CALL "cobol_orm_display_dispatch"
               USING BY REFERENCE CORM-DISP-COMMAREA
           END-CALL
           IF WS-OK-COUNT = 3
               DISPLAY "PASS: COBOL-85"
           ELSE
               DISPLAY "FAIL: COBOL-85"
           END-IF
           STOP RUN.
