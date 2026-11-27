      * @file corm_era61.cbl
      * @module cobol_orm_era_cobol61
      * @brief COBOL-61 fixed-80 uppercase ORM program exercising
      * COMPUTATIONAL counters, PERFORM THRU, and transactions.
      *
      * @program CORM-ERA61
      * @brief Verifies SQLite transaction commit and row count using
      * COBOL-61 idioms and the DISPLAY COMMAREA bridge.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA61.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @field WS-COUNT Row count fetched from SQLite.
       01  WS-COUNT                    PIC 9(11) COMPUTATIONAL VALUE 0.
       PROCEDURE DIVISION.
       MAIN-61.
           PERFORM OPEN-DB THRU OPEN-DB-EXIT.
           IF NOT CORM-ST-OK GO TO ERR-61.
           PERFORM RUN-TX THRU RUN-TX-EXIT.
           IF NOT CORM-ST-OK GO TO ERR-61.
           PERFORM CLOSE-DB THRU CLOSE-DB-EXIT.
           IF WS-COUNT NOT EQUAL TO 1 GO TO ERR-61.
           DISPLAY "PASS: COBOL-61".
           STOP RUN.
       OPEN-DB.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       OPEN-DB-EXIT.
           EXIT.
       RUN-TX.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE E61 (ID INT)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 4 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E61 VALUES (61)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 5 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "SELECT COUNT(*) FROM E61" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE CORM-CA-VAL-NUM TO WS-COUNT.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       RUN-TX-EXIT.
           EXIT.
       CLOSE-DB.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       CLOSE-DB-EXIT.
           EXIT.
       ERR-61.
           DISPLAY "FAIL: COBOL-61".
           STOP RUN.
