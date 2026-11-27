      * @file cobol_orm_lib.cbl
      * @module cobol_orm_runtime
      * @brief Strict fixed 80-column IBM Enterprise (-std=ibm-strict),
      * Micro Focus (-std=mf-strict), and GnuCOBOL wrapper subprograms
      * using native COMP-5 and USAGE POINTER with C-ORM-STATUS checks.

      * @program CORM-CONNECT
      * @brief Connects to any c-orm database backend.
      * @param[in] LS-URL Space-padded database connection URL.
      * @param[out] LS-DB-PTR Receives opaque database handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-CONNECT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-URL-LEN Computed byte length of LS-URL.
       01 WS-URL-LEN                   PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-URL Caller database connection URL buffer.
       01 LS-URL                       PIC X(256).
      * @field LS-DB-PTR Output opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-URL LS-DB-PTR LS-STATUS.
           MOVE FUNCTION LENGTH(LS-URL) TO WS-URL-LEN
           CALL "cobol_orm_connect"
               USING BY REFERENCE LS-URL
                     BY VALUE WS-URL-LEN
                     BY REFERENCE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-CONNECT.

      * @program CORM-DISCONNECT
      * @brief Disconnects and frees a database connection handle.
      * @param[in,out] LS-DB-PTR Opaque DB handle (cleared on OK).
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-DISCONNECT.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-DB-PTR Opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-STATUS.
           CALL "cobol_orm_disconnect"
               USING BY VALUE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           IF LS-STATUS = 0
               SET LS-DB-PTR TO NULL
           END-IF
           GOBACK.
       END PROGRAM CORM-DISCONNECT.

      * @program CORM-EXEC-SQL
      * @brief Executes a raw SQL DDL or DML statement returning no
      * rows.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[in] LS-SQL Space-padded SQL statement buffer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-EXEC-SQL.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-SQL-LEN Computed byte length of LS-SQL.
       01 WS-SQL-LEN                   PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-SQL Caller SQL text buffer.
       01 LS-SQL                       PIC X(1024).
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-SQL LS-STATUS.
           MOVE FUNCTION LENGTH(LS-SQL) TO WS-SQL-LEN
           CALL "cobol_orm_exec_sql"
               USING BY VALUE LS-DB-PTR
                     BY REFERENCE LS-SQL
                     BY VALUE WS-SQL-LEN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-EXEC-SQL.

      * @program CORM-LAST-ERROR
      * @brief Copies the database driver's last error text into LS-MSG.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[out] LS-MSG Destination 256-byte space-padded buffer.
      * @param[out] LS-OUT-LEN Receives unpadded byte length of message.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-LAST-ERROR.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-MSG-CAP Computed capacity of LS-MSG.
       01 WS-MSG-CAP                   PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-MSG Destination message buffer.
       01 LS-MSG                       PIC X(256).
      * @field LS-OUT-LEN Exact unpadded byte length written.
       01 LS-OUT-LEN                   PIC 9(9) COMP-5.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-MSG LS-OUT-LEN LS-STATUS.
           MOVE FUNCTION LENGTH(LS-MSG) TO WS-MSG-CAP
           CALL "cobol_orm_last_error"
               USING BY VALUE LS-DB-PTR
                     BY REFERENCE LS-MSG
                     BY VALUE WS-MSG-CAP
                     BY REFERENCE LS-OUT-LEN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-LAST-ERROR.

      * @program CORM-VERSION
      * @brief Retrieves the semantic cobol-orm version into LS-VER.
      * @param[out] LS-VER Destination 32-byte space-padded buffer.
      * @param[out] LS-OUT-LEN Receives unpadded byte length of version.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-VERSION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-VER-CAP Computed capacity of LS-VER.
       01 WS-VER-CAP                   PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-VER Destination version buffer.
       01 LS-VER                       PIC X(32).
      * @field LS-OUT-LEN Exact unpadded byte length written.
       01 LS-OUT-LEN                   PIC 9(9) COMP-5.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-VER LS-OUT-LEN LS-STATUS.
           MOVE FUNCTION LENGTH(LS-VER) TO WS-VER-CAP
           CALL "cobol_orm_version"
               USING BY REFERENCE LS-VER
                     BY VALUE WS-VER-CAP
                     BY REFERENCE LS-OUT-LEN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-VERSION.

      * @program CORM-TX-BEGIN
      * @brief Begins an explicit database transaction on LS-DB-PTR.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-TX-BEGIN.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-STATUS.
           CALL "cobol_orm_tx_begin"
               USING BY VALUE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-TX-BEGIN.

      * @program CORM-TX-COMMIT
      * @brief Commits the active database transaction on LS-DB-PTR.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-TX-COMMIT.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-STATUS.
           CALL "cobol_orm_tx_commit"
               USING BY VALUE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-TX-COMMIT.

      * @program CORM-TX-ROLLBACK
      * @brief Rolls back the active database transaction on LS-DB-PTR.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-TX-ROLLBACK.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-STATUS.
           CALL "cobol_orm_tx_rollback"
               USING BY VALUE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-TX-ROLLBACK.

      * @program CORM-TX-SAVEPOINT
      * @brief Creates a named savepoint inside the active transaction.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[in] LS-NAME Space-padded savepoint identifier.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-TX-SAVEPOINT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-NAME-LEN Computed byte length of LS-NAME.
       01 WS-NAME-LEN                  PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-NAME Savepoint name buffer.
       01 LS-NAME                      PIC X(32).
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-NAME LS-STATUS.
           MOVE FUNCTION LENGTH(LS-NAME) TO WS-NAME-LEN
           CALL "cobol_orm_tx_savepoint"
               USING BY VALUE LS-DB-PTR
                     BY REFERENCE LS-NAME
                     BY VALUE WS-NAME-LEN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-TX-SAVEPOINT.

      * @program CORM-TX-REL-SP
      * @brief Releases a named savepoint inside the active transaction.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[in] LS-NAME Space-padded savepoint identifier.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-TX-REL-SP.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-NAME-LEN Computed byte length of LS-NAME.
       01 WS-NAME-LEN                  PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-NAME Savepoint name buffer.
       01 LS-NAME                      PIC X(32).
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-NAME LS-STATUS.
           MOVE FUNCTION LENGTH(LS-NAME) TO WS-NAME-LEN
           CALL "cobol_orm_tx_release_sp"
               USING BY VALUE LS-DB-PTR
                     BY REFERENCE LS-NAME
                     BY VALUE WS-NAME-LEN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-TX-REL-SP.

      * @program CORM-TX-RB-SP
      * @brief Rolls back work performed after a named savepoint.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[in] LS-NAME Space-padded savepoint identifier.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-TX-RB-SP.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-NAME-LEN Computed byte length of LS-NAME.
       01 WS-NAME-LEN                  PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-NAME Savepoint name buffer.
       01 LS-NAME                      PIC X(32).
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-NAME LS-STATUS.
           MOVE FUNCTION LENGTH(LS-NAME) TO WS-NAME-LEN
           CALL "cobol_orm_tx_rollback_sp"
               USING BY VALUE LS-DB-PTR
                     BY REFERENCE LS-NAME
                     BY VALUE WS-NAME-LEN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-TX-RB-SP.

      * @program CORM-POOL-INIT
      * @brief Initializes a bounded thread-safe connection pool.
      * @param[in] LS-URL Space-padded database connection URL.
      * @param[in] LS-MIN Minimum pre-warmed connections.
      * @param[in] LS-MAX Maximum pool connections.
      * @param[in] LS-TMO Acquisition timeout in milliseconds.
      * @param[out] LS-POOL-PTR Receives opaque pool handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-POOL-INIT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-URL-LEN Computed byte length of LS-URL.
       01 WS-URL-LEN                   PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-URL Caller database connection URL buffer.
       01 LS-URL                       PIC X(256).
      * @field LS-MIN Minimum pool size.
       01 LS-MIN                       PIC S9(9) COMP-5.
      * @field LS-MAX Maximum pool size.
       01 LS-MAX                       PIC S9(9) COMP-5.
      * @field LS-TMO Acquisition timeout in milliseconds.
       01 LS-TMO                       PIC S9(9) COMP-5.
      * @field LS-POOL-PTR Output opaque connection pool handle.
       01 LS-POOL-PTR                  USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-URL LS-MIN LS-MAX LS-TMO
                                LS-POOL-PTR LS-STATUS.
           MOVE FUNCTION LENGTH(LS-URL) TO WS-URL-LEN
           CALL "cobol_orm_pool_init"
               USING BY REFERENCE LS-URL
                     BY VALUE WS-URL-LEN
                     BY VALUE LS-MIN
                     BY VALUE LS-MAX
                     BY VALUE LS-TMO
                     BY REFERENCE LS-POOL-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-POOL-INIT.

      * @program CORM-POOL-ACQUIRE
      * @brief Acquires a leased database connection from a pool.
      * @param[in] LS-POOL-PTR Active opaque pool handle pointer.
      * @param[out] LS-DB-PTR Receives leased database handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-POOL-ACQUIRE.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-POOL-PTR Active opaque pool handle pointer.
       01 LS-POOL-PTR                  USAGE POINTER.
      * @field LS-DB-PTR Receives leased database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-POOL-PTR LS-DB-PTR LS-STATUS.
           CALL "cobol_orm_pool_acquire"
               USING BY VALUE LS-POOL-PTR
                     BY REFERENCE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-POOL-ACQUIRE.

      * @program CORM-POOL-RELEASE
      * @brief Returns a leased database connection back to the pool.
      * @param[in] LS-POOL-PTR Active opaque pool handle pointer.
      * @param[in] LS-DB-PTR Leased database handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-POOL-RELEASE.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-POOL-PTR Active opaque pool handle pointer.
       01 LS-POOL-PTR                  USAGE POINTER.
      * @field LS-DB-PTR Leased database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-POOL-PTR LS-DB-PTR LS-STATUS.
           CALL "cobol_orm_pool_release"
               USING BY VALUE LS-POOL-PTR
                     BY VALUE LS-DB-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-POOL-RELEASE.

      * @program CORM-POOL-STATS
      * @brief Snapshots live pool utilization and wait telemetry.
      * @param[in] LS-POOL-PTR Active opaque pool handle pointer.
      * @param[out] LS-STATS Receives 24-byte telemetry record.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-POOL-STATS.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-POOL-PTR Active opaque pool handle pointer.
       01 LS-POOL-PTR                  USAGE POINTER.
      * @field LS-STATS 24-byte pool telemetry output structure.
       01 LS-STATS                     PIC X(24).
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-POOL-PTR LS-STATS LS-STATUS.
           CALL "cobol_orm_pool_telemetry"
               USING BY VALUE LS-POOL-PTR
                     BY REFERENCE LS-STATS
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-POOL-STATS.

      * @program CORM-POOL-DESTROY
      * @brief Destroys a connection pool and clears LS-POOL-PTR on OK.
      * @param[in,out] LS-POOL-PTR Opaque pool handle (cleared on OK).
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-POOL-DESTROY.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-POOL-PTR Opaque pool handle pointer.
       01 LS-POOL-PTR                  USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-POOL-PTR LS-STATUS.
           CALL "cobol_orm_pool_destroy"
               USING BY VALUE LS-POOL-PTR
               RETURNING LS-STATUS
           END-CALL
           IF LS-STATUS = 0
               SET LS-POOL-PTR TO NULL
           END-IF
           GOBACK.
       END PROGRAM CORM-POOL-DESTROY.

      * @program CORM-MIG-INIT
      * @brief Initializes a versioned SQL schema migration runner.
      * @param[in] LS-DB-PTR Active opaque database handle pointer.
      * @param[in] LS-DIR Space-padded path to migrations directory.
      * @param[out] LS-MIG-PTR Receives opaque migration handle pointer.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-MIG-INIT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-DIR-LEN Computed byte length of LS-DIR.
       01 WS-DIR-LEN                   PIC 9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-DB-PTR Active opaque database handle pointer.
       01 LS-DB-PTR                    USAGE POINTER.
      * @field LS-DIR Migrations directory path buffer.
       01 LS-DIR                       PIC X(256).
      * @field LS-MIG-PTR Output opaque migration runner handle.
       01 LS-MIG-PTR                   USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-DB-PTR LS-DIR LS-MIG-PTR LS-STATUS.
           MOVE FUNCTION LENGTH(LS-DIR) TO WS-DIR-LEN
           CALL "cobol_orm_mig_init"
               USING BY VALUE LS-DB-PTR
                     BY REFERENCE LS-DIR
                     BY VALUE WS-DIR-LEN
                     BY REFERENCE LS-MIG-PTR
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-MIG-INIT.

      * @program CORM-MIG-UP
      * @brief Applies pending UP schema migrations (or dry-run).
      * @param[in] LS-MIG-PTR Active migration runner handle pointer.
      * @param[in] LS-DRY-RUN Non-zero for dry-run, 0 to execute.
      * @param[out] LS-APPLIED Receives count of applied migrations.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-MIG-UP.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-MIG-PTR Active migration runner handle pointer.
       01 LS-MIG-PTR                   USAGE POINTER.
      * @field LS-DRY-RUN Dry-run flag.
       01 LS-DRY-RUN                   PIC S9(9) COMP-5.
      * @field LS-APPLIED Count of applied migrations.
       01 LS-APPLIED                   PIC 9(9) COMP-5.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-MIG-PTR LS-DRY-RUN
                                LS-APPLIED LS-STATUS.
           CALL "cobol_orm_mig_up"
               USING BY VALUE LS-MIG-PTR
                     BY VALUE LS-DRY-RUN
                     BY REFERENCE LS-APPLIED
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-MIG-UP.

      * @program CORM-MIG-DOWN
      * @brief Reverts the last LS-STEPS applied schema migrations.
      * @param[in] LS-MIG-PTR Active migration runner handle pointer.
      * @param[in] LS-STEPS Number of migrations to revert.
      * @param[in] LS-DRY-RUN Non-zero for dry-run, 0 to execute.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-MIG-DOWN.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-MIG-PTR Active migration runner handle pointer.
       01 LS-MIG-PTR                   USAGE POINTER.
      * @field LS-STEPS Number of migrations to roll back.
       01 LS-STEPS                     PIC 9(9) COMP-5.
      * @field LS-DRY-RUN Dry-run flag.
       01 LS-DRY-RUN                   PIC S9(9) COMP-5.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-MIG-PTR LS-STEPS
                                LS-DRY-RUN LS-STATUS.
           CALL "cobol_orm_mig_down"
               USING BY VALUE LS-MIG-PTR
                     BY VALUE LS-STEPS
                     BY VALUE LS-DRY-RUN
               RETURNING LS-STATUS
           END-CALL
           GOBACK.
       END PROGRAM CORM-MIG-DOWN.

      * @program CORM-MIG-FREE
      * @brief Frees a migration runner handle and clears it on OK.
      * @param[in,out] LS-MIG-PTR Opaque migration handle.
      * @param[out] LS-STATUS Receives C-ORM-STATUS error enum value.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-MIG-FREE.
       DATA DIVISION.
       LINKAGE SECTION.
      * @field LS-MIG-PTR Opaque migration handle pointer.
       01 LS-MIG-PTR                   USAGE POINTER.
      * @field LS-STATUS Output error status code.
       01 LS-STATUS                    PIC S9(9) COMP-5.
       PROCEDURE DIVISION USING LS-MIG-PTR LS-STATUS.
           CALL "cobol_orm_mig_free"
               USING BY VALUE LS-MIG-PTR
               RETURNING LS-STATUS
           END-CALL
           IF LS-STATUS = 0
               SET LS-MIG-PTR TO NULL
           END-IF
           GOBACK.
       END PROGRAM CORM-MIG-FREE.

      * @program CORM-COMMAREA
      * @brief Legacy-compatible single-argument BY REFERENCE COMMAREA
      * dispatcher callable from COBOL-60 through COBOL-2023 programs.
      * @param[in,out] LS-COMMAREA Fixed 544-byte COMMAREA block.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CORM-COMMAREA.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * @field WS-RC Temporary status code mirrored into LS-COMMAREA.
       01 WS-RC                        PIC S9(9) COMP-5 VALUE 0.
       LINKAGE SECTION.
      * @field LS-COMMAREA Fixed 544-byte COMMAREA record.
       01 LS-COMMAREA                  PIC X(544).
       PROCEDURE DIVISION USING LS-COMMAREA.
           CALL "cobol_orm_commarea_dispatch"
               USING BY REFERENCE LS-COMMAREA
               RETURNING WS-RC
           END-CALL
           GOBACK.
       END PROGRAM CORM-COMMAREA.
