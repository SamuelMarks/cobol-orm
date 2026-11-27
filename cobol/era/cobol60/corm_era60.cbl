      * @file corm_era60.cbl
      * @module cobol_orm_era_cobol60
      * @brief COBOL-60 fixed-80 uppercase ORM verification program
      * using pure USAGE DISPLAY COMMAREA, PERFORM THRU, and GO TO.
      *
      * @program CORM-ERA60
      * @brief Executes SQLite connect, DDL, INSERT, SELECT, and
      * disconnect using pure COBOL-60 control flow and DISPLAY data.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-ERA60.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_display_ca.cpy".
      * @field WS-OK-FLAG Set to 1 when all COBOL-60 checks succeed.
       01  WS-OK-FLAG                  PIC 9(1) VALUE 0.
       PROCEDURE DIVISION.
       MAIN-CONTROL.
           PERFORM DO-CONNECT THRU DO-CONNECT-EXIT.
           IF NOT CORM-ST-OK GO TO ERR-STOP.
           PERFORM DO-DDL-AND-INSERT THRU DO-DDL-EXIT.
           IF NOT CORM-ST-OK GO TO ERR-STOP.
           PERFORM DO-QUERY THRU DO-QUERY-EXIT.
           IF NOT CORM-ST-OK GO TO ERR-STOP.
           PERFORM DO-DISCONNECT THRU DO-DISCONNECT-EXIT.
           IF NOT CORM-ST-OK GO TO ERR-STOP.
           MOVE 1 TO WS-OK-FLAG.
           DISPLAY "PASS: COBOL-60".
           STOP RUN.
       DO-CONNECT.
           MOVE 1 TO CORM-CA-OPCODE.
           MOVE "sqlite://:memory:" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       DO-CONNECT-EXIT.
           EXIT.
       DO-DDL-AND-INSERT.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "CREATE TABLE E60 (ID INT, NM TEXT)"
               TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO DO-DDL-EXIT.
           MOVE 3 TO CORM-CA-OPCODE.
           MOVE "INSERT INTO E60 VALUES (60, 'COBOL-60')"
               TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       DO-DDL-EXIT.
           EXIT.
       DO-QUERY.
           MOVE 7 TO CORM-CA-OPCODE.
           MOVE "SELECT ID, NM FROM E60" TO CORM-CA-DATA1.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO DO-QUERY-EXIT.
           MOVE 10 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF NOT CORM-ST-OK GO TO DO-QUERY-EXIT.
           IF CORM-CA-VAL-NUM NOT EQUAL TO 1
               MOVE 1 TO CORM-CA-STATUS
               GO TO DO-QUERY-EXIT.
           MOVE 11 TO CORM-CA-OPCODE.
           MOVE 0 TO CORM-CA-PARAM-IDX.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
           IF CORM-CA-VAL-NUM NOT EQUAL TO 60
               MOVE 1 TO CORM-CA-STATUS
               GO TO DO-QUERY-EXIT.
           MOVE 13 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       DO-QUERY-EXIT.
           EXIT.
       DO-DISCONNECT.
           MOVE 2 TO CORM-CA-OPCODE.
           CALL "cobol_orm_display_dispatch" USING CORM-DISP-COMMAREA.
       DO-DISCONNECT-EXIT.
           EXIT.
       ERR-STOP.
           DISPLAY "FAIL: COBOL-60".
           STOP RUN.
