      * @file mainframe_codecs_and_commarea.cbl
      * @module cobol_orm_examples
      * @brief Demonstrates 38-digit fixed-point Banker rounding,
      * EBCDIC Zoned Decimal & COMP codecs, IBM1047/UTF-16 GRAPHIC
      * round-trips, and 544-byte COMMAREA dispatch in fixed-80 COBOL.

      * @program EX-MAINFRAME
      * @brief Exercises decimal settlement, EBCDIC/UTF-16 codecs, and
      * binary COMMAREA dispatch in strict IBM/MF fixed-80 COBOL.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-MAINFRAME.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_ibm.cpy".
      * @field WS-DEC-A First 41-byte exact decimal operand.
       01 WS-DEC-A                     PIC X(41) VALUE LOW-VALUES.
      * @field WS-DEC-B Second 41-byte exact decimal operand.
       01 WS-DEC-B                     PIC X(41) VALUE LOW-VALUES.
      * @field WS-DEC-PROD Product 41-byte exact decimal.
       01 WS-DEC-PROD                  PIC X(41) VALUE LOW-VALUES.
      * @field WS-DEC-QUOT Quotient 41-byte exact decimal.
       01 WS-DEC-QUOT                  PIC X(41) VALUE LOW-VALUES.
      * @field WS-DEC-RT Round-tripped zoned decimal value.
       01 WS-DEC-RT                    PIC X(41) VALUE LOW-VALUES.
      * @field WS-SA Principal amount string.
       01 WS-SA                        PIC X(16) VALUE "1000.00".
      * @field WS-SB FX rate multiplier string.
       01 WS-SB                        PIC X(16) VALUE "1.0855".
      * @field WS-SC Divisor string.
       01 WS-SC                        PIC X(16) VALUE "3".
      * @field WS-LEN16 Fixed 16-byte string length.
       01 WS-LEN16                     PIC 9(9) COMP-5 VALUE 16.
      * @field WS-SCALE2 Target scale of 2 fractional digits.
       01 WS-SCALE2                    PIC 9(9) COMP-5 VALUE 2.
      * @field WS-INT5 Integer digits for zoned decimal (5).
       01 WS-INT5                      PIC 9(9) COMP-5 VALUE 5.
      * @field WS-SIGNED Signed flag (1).
       01 WS-SIGNED                    PIC S9(9) COMP-5 VALUE 1.
      * @field WS-FLAG0 Zero flag for trailing overpunch sign.
       01 WS-FLAG0                     PIC S9(9) COMP-5 VALUE 0.
      * @field WS-FLAG1 One flag for EBCDIC / big-endian mode.
       01 WS-FLAG1                     PIC S9(9) COMP-5 VALUE 1.
      * @field WS-CMP Comparison result (-1, 0, +1).
       01 WS-CMP                       PIC S9(9) COMP-5 VALUE 9.
      * @field WS-ZONED EBCDIC zoned-decimal wire buffer.
       01 WS-ZONED                     PIC X(16) VALUE LOW-VALUES.
      * @field WS-ZLEN Bytes written to WS-ZONED.
       01 WS-ZLEN                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-COMP-VAL Input 64-bit integer for COMP wire encoding.
       01 WS-COMP-VAL                  PIC S9(18) COMP-5 VALUE -424242.
      * @field WS-COMP-OUT Decoded 64-bit integer from COMP buffer.
       01 WS-COMP-OUT                  PIC S9(18) COMP-5 VALUE 0.
      * @field WS-COMP-BUF 4-byte big-endian COMP wire buffer.
       01 WS-COMP-BUF                  PIC X(8) VALUE LOW-VALUES.
      * @field WS-WIDTH4 4-byte COMP width.
       01 WS-WIDTH4                    PIC 9(9) COMP-5 VALUE 4.
      * @field WS-CAP8 8-byte buffer capacity.
       01 WS-CAP8                      PIC 9(9) COMP-5 VALUE 8.
      * @field WS-UTF8-IN Source UTF-8 mainframe tag.
       01 WS-UTF8-IN                   PIC X(16) VALUE "ZOS-DB2-OK".
      * @field WS-LEN10 Exact 10-byte payload length.
       01 WS-LEN10                     PIC 9(9) COMP-5 VALUE 10.
      * @field WS-EBCDIC Encoded IBM1047 EBCDIC buffer.
       01 WS-EBCDIC                    PIC X(32) VALUE LOW-VALUES.
      * @field WS-UTF8-OUT Decoded UTF-8 buffer.
       01 WS-UTF8-OUT                  PIC X(32) VALUE SPACES.
      * @field WS-UTF16 Big-endian UTF-16 GRAPHIC buffer.
       01 WS-UTF16                     PIC X(64) VALUE LOW-VALUES.
      * @field WS-CAP32 32-byte/unit capacity.
       01 WS-CAP32                     PIC 9(9) COMP-5 VALUE 32.
      * @field WS-OLEN Output byte/unit length.
       01 WS-OLEN                      PIC 9(9) COMP-5 VALUE 0.
      * @field WS-U16-UNITS Output UTF-16 code unit count.
       01 WS-U16-UNITS                 PIC 9(9) COMP-5 VALUE 0.
       PROCEDURE DIVISION.
           CALL "cobol_orm_dec_from_str"
               USING BY REFERENCE WS-SA BY VALUE WS-LEN16
                     BY REFERENCE WS-DEC-A
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_from_str"
               USING BY REFERENCE WS-SB BY VALUE WS-LEN16
                     BY REFERENCE WS-DEC-B
               RETURNING C-ORM-STATUS
           END-CALL
           SET C-ORM-RND-HALF-EVEN TO TRUE
           CALL "cobol_orm_dec_mul"
               USING BY REFERENCE WS-DEC-A BY REFERENCE WS-DEC-B
                     BY VALUE WS-SCALE2 BY VALUE C-ORM-ROUND-MODE
                     BY REFERENCE WS-DEC-PROD
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_dec_from_str"
               USING BY REFERENCE WS-SC BY VALUE WS-LEN16
                     BY REFERENCE WS-DEC-B
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_div"
               USING BY REFERENCE WS-DEC-PROD BY REFERENCE WS-DEC-B
                     BY VALUE WS-SCALE2 BY VALUE C-ORM-ROUND-MODE
                     BY REFERENCE WS-DEC-QUOT
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_to_zoned"
               USING BY REFERENCE WS-DEC-QUOT BY VALUE WS-INT5
                     BY VALUE WS-SCALE2 BY VALUE WS-SIGNED
                     BY VALUE WS-FLAG0 BY VALUE WS-FLAG0
                     BY VALUE WS-FLAG1 BY REFERENCE WS-ZONED
                     BY VALUE WS-LEN16 BY REFERENCE WS-ZLEN
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_from_zoned"
               USING BY REFERENCE WS-ZONED BY VALUE WS-ZLEN
                     BY VALUE WS-SCALE2 BY VALUE WS-SIGNED
                     BY VALUE WS-FLAG0 BY VALUE WS-FLAG0
                     BY VALUE WS-FLAG1 BY REFERENCE WS-DEC-RT
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_dec_cmp"
               USING BY REFERENCE WS-DEC-QUOT BY REFERENCE WS-DEC-RT
                     BY REFERENCE WS-CMP
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-CMP NOT = 0
               MOVE 2 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_i64_to_comp"
               USING BY VALUE WS-COMP-VAL BY VALUE WS-WIDTH4
                     BY VALUE WS-FLAG1 BY REFERENCE WS-COMP-BUF
                     BY VALUE WS-CAP8
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_i64_from_comp"
               USING BY REFERENCE WS-COMP-BUF BY VALUE WS-WIDTH4
                     BY VALUE WS-SIGNED BY VALUE WS-FLAG1
                     BY REFERENCE WS-COMP-OUT
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-COMP-OUT NOT = -424242
               MOVE 3 TO RETURN-CODE
               STOP RUN
           END-IF
           SET C-ORM-CP-IBM1047-V TO TRUE
           CALL "cobol_orm_utf8_to_ebcdic"
               USING BY VALUE C-ORM-CODEPAGE BY REFERENCE WS-UTF8-IN
                     BY VALUE WS-LEN10 BY REFERENCE WS-EBCDIC
                     BY VALUE WS-CAP32 BY REFERENCE WS-OLEN
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "cobol_orm_ebcdic_to_utf8"
               USING BY VALUE C-ORM-CODEPAGE BY REFERENCE WS-EBCDIC
                     BY VALUE WS-OLEN BY REFERENCE WS-UTF8-OUT
                     BY VALUE WS-CAP32 BY REFERENCE WS-OLEN
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-UTF8-OUT(1:10) NOT = "ZOS-DB2-OK"
               MOVE 4 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_utf8_to_utf16"
               USING BY REFERENCE WS-UTF8-IN BY VALUE WS-LEN10
                     BY VALUE WS-FLAG1 BY REFERENCE WS-UTF16
                     BY VALUE WS-CAP32 BY REFERENCE WS-U16-UNITS
               RETURNING C-ORM-STATUS
           END-CALL
           MOVE SPACES TO WS-UTF8-OUT
           CALL "cobol_orm_utf16_to_utf8"
               USING BY REFERENCE WS-UTF16 BY VALUE WS-U16-UNITS
                     BY VALUE WS-FLAG1 BY REFERENCE WS-UTF8-OUT
                     BY VALUE WS-CAP32 BY REFERENCE WS-OLEN
               RETURNING C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-UTF8-OUT(1:10) NOT = "ZOS-DB2-OK"
               MOVE 5 TO RETURN-CODE
               STOP RUN
           END-IF
           MOVE 15 TO C-ORM-CA-OPCODE
           CALL "CORM-COMMAREA" USING C-ORM-COMMAREA-REC
           END-CALL
           IF C-ORM-CA-STATUS NOT = 0
              OR C-ORM-CA-DATA2(1:5) NOT = "0.1.0"
               MOVE 6 TO RETURN-CODE
               STOP RUN
           END-IF
           DISPLAY "EX-MAINFRAME OK: " WS-UTF8-OUT(1:10).
           STOP RUN.
       END PROGRAM EX-MAINFRAME.
