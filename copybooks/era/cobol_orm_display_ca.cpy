      * @file cobol_orm_display_ca.cpy
      * @module cobol_orm_era_copybooks
      * @brief Pure USAGE DISPLAY 552-byte endian-independent COMMAREA
      * Copybook compatible with COBOL-60, COBOL-61, COBOL-61 Extended,
      * COBOL-65, COBOL-68, COBOL-74, and COBOL-85 (fixed 80-column).
      *
      * @class CORM-DISP-COMMAREA
      * @brief Fixed 552-byte pure DISPLAY ORM request/response record.
       01  CORM-DISP-COMMAREA.
      *    @field CORM-CA-OPCODE Requested ORM opcode (0001-0016).
           05  CORM-CA-OPCODE          PIC 9(4) VALUE 0.
      *        @cond CORM-OP-CONNECT Connect database URL.
               88  CORM-OP-CONNECT     VALUE 1.
      *        @cond CORM-OP-DISCONN Disconnect database handle.
               88  CORM-OP-DISCONN     VALUE 2.
      *        @cond CORM-OP-EXEC-SQL Execute raw SQL statement.
               88  CORM-OP-EXEC-SQL    VALUE 3.
      *        @cond CORM-OP-TX-BEG Begin transaction.
               88  CORM-OP-TX-BEG      VALUE 4.
      *        @cond CORM-OP-TX-CMT Commit transaction.
               88  CORM-OP-TX-CMT      VALUE 5.
      *        @cond CORM-OP-TX-RBK Rollback transaction.
               88  CORM-OP-TX-RBK      VALUE 6.
      *        @cond CORM-OP-PREPARE Prepare SQL statement.
               88  CORM-OP-PREPARE     VALUE 7.
      *        @cond CORM-OP-BIND-I32 Bind 32-bit integer parameter.
               88  CORM-OP-BIND-I32    VALUE 8.
      *        @cond CORM-OP-BIND-STR Bind character string parameter.
               88  CORM-OP-BIND-STR    VALUE 9.
      *        @cond CORM-OP-STEP Step prepared statement execution.
               88  CORM-OP-STEP        VALUE 10.
      *        @cond CORM-OP-COL-I32 Read 32-bit integer result column.
               88  CORM-OP-COL-I32     VALUE 11.
      *        @cond CORM-OP-COL-STR Read text result column.
               88  CORM-OP-COL-STR     VALUE 12.
      *        @cond CORM-OP-FINALIZE Finalize prepared statement.
               88  CORM-OP-FINALIZE    VALUE 13.
      *        @cond CORM-OP-LAST-ERR Retrieve last error message.
               88  CORM-OP-LAST-ERR    VALUE 14.
      *        @cond CORM-OP-VERSION Retrieve library version string.
               88  CORM-OP-VERSION     VALUE 15.
      *        @cond CORM-OP-ROWID Retrieve last insert row ID.
               88  CORM-OP-ROWID       VALUE 16.
      *    @field CORM-CA-STATUS Returned error status code (0000=OK).
           05  CORM-CA-STATUS          PIC 9(4) VALUE 0.
      *        @cond CORM-ST-OK Operation completed successfully.
               88  CORM-ST-OK          VALUE 0.
      *        @cond CORM-ST-NOT-FND Requested row or key not found.
               88  CORM-ST-NOT-FND     VALUE 7.
      *    @field CORM-CA-DB-ID Integer DB handle slot ID (0001-0064).
           05  CORM-CA-DB-ID           PIC 9(4) VALUE 0.
      *    @field CORM-CA-STMT-ID Integer statement slot ID (0001-0064).
           05  CORM-CA-STMT-ID         PIC 9(4) VALUE 0.
      *    @field CORM-CA-PARAM-IDX 1-based param or 0-based col index.
           05  CORM-CA-PARAM-IDX       PIC 9(4) VALUE 0.
      *    @field CORM-CA-VAL-SIGN Explicit ASCII sign (+ or -).
           05  CORM-CA-VAL-SIGN        PIC X VALUE "+".
      *    @field CORM-CA-VAL-NUM 11-digit magnitude for 32-bit integer.
           05  CORM-CA-VAL-NUM         PIC 9(11) VALUE 0.
      *    @field CORM-CA-D1-LEN Input length (0000 = auto-trim).
           05  CORM-CA-D1-LEN          PIC 9(4) VALUE 0.
      *    @field CORM-CA-D2-LEN Output payload length written to DATA2.
           05  CORM-CA-D2-LEN          PIC 9(4) VALUE 0.
      *    @field CORM-CA-DATA1 Input space-padded text payload.
           05  CORM-CA-DATA1           PIC X(256) VALUE SPACES.
      *    @field CORM-CA-DATA2 Output space-padded text payload.
           05  CORM-CA-DATA2           PIC X(256) VALUE SPACES.
