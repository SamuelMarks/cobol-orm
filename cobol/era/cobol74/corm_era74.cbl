      * @file corm_era74.cbl
      * @module cobol_orm_era_cobol74
      * @brief ANSI COBOL-74 (X3.23-1974) fixed-80 ORM verification
      * exercising CALL USING, transactions, and rollback.
      *
      * @program CORM-ERA74
      * @brief Verifies transaction rollback and count check using
      * ANSI COBOL-74 syntax and the DISPLAY COMMAREA bridge.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA74.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @field WS-ERR Non-zero when any assertion fails.
       01  WS-ERR                      PIC 9(4) VALUE 0.
       PROCEDURE DIVISION.
       MAIN-74.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK MOVE 1 TO WS-ERR.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE E74 (ID INT, NM TEXT)"
               TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 4 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E74 VALUES (74, 'ROLLED')"
               TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 6 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "SELECT COUNT(*) FROM E74" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF CORM-CA-VAL-NUM NOT EQUAL TO 0 MOVE 1 TO WS-ERR.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF WS-ERR EQUAL TO 0
               DISPLAY "PASS: COBOL-74"
           ELSE
               DISPLAY "FAIL: COBOL-74".
           STOP RUN.
