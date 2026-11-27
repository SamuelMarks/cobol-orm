      * @file corm_era65.cbl
      * @module cobol_orm_era_cobol65
      * @brief COBOL-65 fixed-80 uppercase ORM verification exercising
      * OCCURS DEPENDING ON and INDEXED BY result tables.
      *
      * @program CORM-ERA65
      * @brief Inserts rows into SQLite and loads them into a
      * COBOL-65 OCCURS DEPENDING ON indexed table via DISPLAY COMMAREA.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA65.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @class WS-ROW-TABLE
      * @brief COBOL-65 variable-length OCCURS DEPENDING ON table.
       01  WS-ROW-TABLE.
      *    @field WS-ROW-CNT Active row count (0..8).
           05  WS-ROW-CNT              PIC 9(4) VALUE 0.
      *    @field WS-ROW-ENTRY Indexed row slot.
           05  WS-ROW-ENTRY            OCCURS 0 TO 8 TIMES
                                       DEPENDING ON WS-ROW-CNT
                                       INDEXED BY WS-IX.
      *        @field WS-ROW-ID Stored integer ID.
               10  WS-ROW-ID           PIC 9(11).
       PROCEDURE DIVISION.
       MAIN-65.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO FAIL-65.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE E65 (ID INT)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E65 VALUES (65)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E65 VALUES (66)" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "SELECT ID FROM E65 ORDER BY ID" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           SET WS-IX TO 1.
           PERFORM FETCH-LOOP THRU FETCH-LOOP-EXIT.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF WS-ROW-CNT NOT EQUAL TO 2 GO TO FAIL-65.
           IF WS-ROW-ID (1) NOT EQUAL TO 65 GO TO FAIL-65.
           IF WS-ROW-ID (2) NOT EQUAL TO 66 GO TO FAIL-65.
           DISPLAY "PASS: COBOL-65".
           STOP RUN.
       FETCH-LOOP.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO FETCH-LOOP-EXIT.
           IF CORM-CA-VAL-NUM EQUAL TO 0 GO TO FETCH-LOOP-EXIT.
           ADD 1 TO WS-ROW-CNT.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           MOVE CORM-CA-VAL-NUM TO WS-ROW-ID (WS-IX).
           SET WS-IX UP BY 1.
           GO TO FETCH-LOOP.
       FETCH-LOOP-EXIT.
           EXIT.
       FAIL-65.
           DISPLAY "FAIL: COBOL-65".
           STOP RUN.
