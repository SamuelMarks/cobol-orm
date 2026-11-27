      * @file corm_era61x.cbl
      * @module cobol_orm_era_cobol61x
      * @brief COBOL-61 Extended fixed-80 uppercase ORM program
      * exercising COMPUTE arithmetic over SQLite query results.
      *
      * @program CORM-ERA61X
      * @brief Inserts numeric ledger values and verifies COMPUTE total
      * via the pure USAGE DISPLAY COMMAREA bridge.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA61X.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @field WS-A First fetched integer value.
       01  WS-A                        PIC 9(11) VALUE 0.
      * @field WS-B Second fetched integer value.
       01  WS-B                        PIC 9(11) VALUE 0.
      * @field WS-TOTAL Computed sum using COBOL-61 Extended COMPUTE.
       01  WS-TOTAL                    PIC 9(12) VALUE 0.
       PROCEDURE DIVISION.
       MAIN-61X.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO ERR-61X.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE E61X (AMT INT)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E61X VALUES (120)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E61X VALUES (380)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "SELECT AMT FROM E61X ORDER BY AMT" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE CORM-CA-VAL-NUM TO WS-A.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE CORM-CA-VAL-NUM TO WS-B.
           COMPUTE WS-TOTAL = WS-A + WS-B.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF WS-TOTAL NOT EQUAL TO 500 GO TO ERR-61X.
           DISPLAY "PASS: COBOL-61X".
           STOP RUN.
       ERR-61X.
           DISPLAY "FAIL: COBOL-61X".
           STOP RUN.
