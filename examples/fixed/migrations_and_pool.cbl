      * @file migrations_and_pool.cbl
      * @module cobol_orm_examples
      * @brief Demonstrates thread-safe connection pooling, telemetry
      * inspection, statement caching, and versioned UP/DOWN schema
      * migrations in strict fixed 80-column COBOL.

      * @program EX-POOL-DEMO
      * @brief Initializes a SQLite pool, acquires a connection, runs
      * UP/DOWN schema migrations, checks telemetry, and tears down.
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EX-POOL-DEMO.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "cobol_orm_ibm.cpy".
      * @field WS-URL Pool connection URL.
       01 WS-URL                       PIC X(256)
                                       VALUE "sqlite://:memory:".
      * @field WS-MIG-DIR Directory containing SQL migration scripts.
       01 WS-MIG-DIR                   PIC X(256)
                                       VALUE "examples/migrations".
      * @field WS-MIN Minimum pooled connections.
       01 WS-MIN                       PIC S9(9) COMP-5 VALUE 1.
      * @field WS-MAX Maximum pooled connections.
       01 WS-MAX                       PIC S9(9) COMP-5 VALUE 4.
      * @field WS-TMO Acquisition timeout in milliseconds.
       01 WS-TMO                       PIC S9(9) COMP-5 VALUE 250.
      * @field WS-CACHE-CAP Prepared statement cache capacity.
       01 WS-CACHE-CAP                 PIC 9(9) COMP-5 VALUE 16.
      * @field WS-DRY-RUN Migration dry-run flag.
       01 WS-DRY-RUN                   PIC S9(9) COMP-5 VALUE 0.
      * @field WS-STEPS Rollback step count.
       01 WS-STEPS                     PIC 9(9) COMP-5 VALUE 1.
      * @field WS-APPLIED Count of applied migrations.
       01 WS-APPLIED                   PIC 9(9) COMP-5 VALUE 0.
      * @field WS-SQL DML verification statement buffer.
       01 WS-SQL                       PIC X(1024) VALUE
          "INSERT INTO MIG_AUDIT_LOG VALUES (1, 'MIGRATION-OK')".
       PROCEDURE DIVISION.
           CALL "CORM-POOL-INIT"
               USING WS-URL WS-MIN WS-MAX WS-TMO
                     C-ORM-POOL-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-POOL-ACQUIRE"
               USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 2 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "cobol_orm_enable_stmt_cache"
               USING BY VALUE C-ORM-DB-PTR BY VALUE WS-CACHE-CAP
               RETURNING C-ORM-STATUS
           END-CALL
           CALL "CORM-MIG-INIT"
               USING C-ORM-DB-PTR WS-MIG-DIR
                     C-ORM-MIG-PTR C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 3 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-MIG-UP"
               USING C-ORM-MIG-PTR WS-DRY-RUN WS-APPLIED C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR WS-APPLIED NOT = 1
               MOVE 4 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 5 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-MIG-DOWN"
               USING C-ORM-MIG-PTR WS-STEPS WS-DRY-RUN C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK
               MOVE 6 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-MIG-FREE" USING C-ORM-MIG-PTR C-ORM-STATUS
           END-CALL
           CALL "CORM-POOL-STATS"
               USING C-ORM-POOL-PTR C-ORM-POOL-STATS-REC C-ORM-STATUS
           END-CALL
           IF NOT C-ORM-OK OR C-ORM-PS-ACTIVE NOT = 1
               MOVE 7 TO RETURN-CODE
               STOP RUN
           END-IF
           CALL "CORM-POOL-RELEASE"
               USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
           END-CALL
           CALL "CORM-POOL-DESTROY" USING C-ORM-POOL-PTR C-ORM-STATUS
           END-CALL
           DISPLAY "EX-POOL-DEMO OK".
           STOP RUN.
       END PROGRAM EX-POOL-DEMO.
