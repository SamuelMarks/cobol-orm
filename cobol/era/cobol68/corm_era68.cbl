      * @file corm_era68.cbl
      * @module cobol_orm_era_cobol68
      * @brief ANSI COBOL-68 (X3.23-1968) fixed-80 uppercase ORM program
      * exercising COPY inclusion and PERFORM VARYING binds.
      *
      * @program CORM-ERA68
      * @brief Runs parameterized INSERT and SELECT over SQLite using
      * pure ANSI COBOL-68 idioms and the DISPLAY COMMAREA bridge.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA68.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @field WS-I Loop counter for PERFORM VARYING.
       01  WS-I                        PIC 9(4) VALUE 0.
      * @field WS-SUM Running sum of fetched rows.
       01  WS-SUM                      PIC 9(11) VALUE 0.
       PROCEDURE DIVISION.
       MAIN-68.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO FAIL-68.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE E68 (N INT)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           PERFORM INS-ROW THRU INS-ROW-EXIT
               VARYING WS-I FROM 1 BY 1 UNTIL WS-I GREATER THAN 3.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "SELECT SUM(N) FROM E68" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE CORM-CA-VAL-NUM TO WS-SUM.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF WS-SUM NOT EQUAL TO 6 GO TO FAIL-68.
           DISPLAY "PASS: COBOL-68".
           STOP RUN.
       INS-ROW.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E68 VALUES (?)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 8 TO CORM-CA-OPCODE.
           MOVE 1 TO CORM-CA-PARAM-IDX.
           MOVE "+" TO CORM-CA-VAL-SIGN.
           MOVE WS-I TO CORM-CA-VAL-NUM.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       INS-ROW-EXIT.
           EXIT.
       FAIL-68.
           DISPLAY "FAIL: COBOL-68".
           STOP RUN.
