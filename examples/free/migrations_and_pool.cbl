>>SOURCE FORMAT IS FREE
*> @file migrations_and_pool.cbl
*> @module cobol_orm_examples
*> @brief Demonstrates thread-safe connection pooling, telemetry inspection,
*> statement caching, and versioned UP/DOWN schema migrations from COBOL.

*> @program EX-POOL-DEMO
*> @brief Initializes a SQLite pool, acquires a connection, runs UP/DOWN
*> schema migrations, reads pool telemetry, releases, and destroys the pool.
IDENTIFICATION DIVISION.
PROGRAM-ID. EX-POOL-DEMO.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
*> @field WS-URL Pool connection URL.
01 WS-URL                             PIC X(256) VALUE "sqlite://:memory:".
*> @field WS-MIG-DIR Directory containing versioned SQL migrations.
01 WS-MIG-DIR                         PIC X(256) VALUE "examples/migrations".
*> @field WS-MIN Minimum pooled connections.
01 WS-MIN                             USAGE BINARY-LONG SIGNED VALUE 1.
*> @field WS-MAX Maximum pooled connections.
01 WS-MAX                             USAGE BINARY-LONG SIGNED VALUE 4.
*> @field WS-TMO Acquisition timeout in milliseconds.
01 WS-TMO                             USAGE BINARY-LONG SIGNED VALUE 250.
*> @field WS-CACHE-CAP Prepared statement cache capacity.
01 WS-CACHE-CAP                       USAGE BINARY-LONG UNSIGNED VALUE 16.
*> @field WS-DRY-RUN Migration dry-run flag (0 = apply live).
01 WS-DRY-RUN                         USAGE BINARY-LONG SIGNED VALUE 0.
*> @field WS-STEPS Rollback step count.
01 WS-STEPS                           USAGE BINARY-LONG UNSIGNED VALUE 1.
*> @field WS-APPLIED Count of applied migrations.
01 WS-APPLIED                         USAGE BINARY-LONG UNSIGNED VALUE 0.
*> @field WS-SQL DML verification statement buffer.
01 WS-SQL                             PIC X(1024) VALUE
   "INSERT INTO MIG_AUDIT_LOG VALUES (1, 'MIGRATION-OK')".
PROCEDURE DIVISION.
    CALL "CORM-POOL-INIT"
        USING WS-URL WS-MIN WS-MAX WS-TMO C-ORM-POOL-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 1
    END-IF
    CALL "CORM-POOL-ACQUIRE" USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 2
    END-IF
    CALL "cobol_orm_enable_stmt_cache"
        USING BY VALUE C-ORM-DB-PTR BY VALUE WS-CACHE-CAP
        RETURNING C-ORM-STATUS
    END-CALL
    CALL "CORM-MIG-INIT"
        USING C-ORM-DB-PTR WS-MIG-DIR C-ORM-MIG-PTR C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 3
    END-IF
    CALL "CORM-MIG-UP"
        USING C-ORM-MIG-PTR WS-DRY-RUN WS-APPLIED C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR WS-APPLIED NOT = 1
        STOP RUN RETURNING 4
    END-IF
    CALL "CORM-EXEC-SQL" USING C-ORM-DB-PTR WS-SQL C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 5
    END-IF
    CALL "CORM-MIG-DOWN"
        USING C-ORM-MIG-PTR WS-STEPS WS-DRY-RUN C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK
        STOP RUN RETURNING 6
    END-IF
    CALL "CORM-MIG-FREE" USING C-ORM-MIG-PTR C-ORM-STATUS
    END-CALL
    CALL "CORM-POOL-STATS"
        USING C-ORM-POOL-PTR C-ORM-POOL-STATS-REC C-ORM-STATUS
    END-CALL
    IF NOT C-ORM-OK OR C-ORM-PS-ACTIVE NOT = 1
        STOP RUN RETURNING 7
    END-IF
    CALL "CORM-POOL-RELEASE" USING C-ORM-POOL-PTR C-ORM-DB-PTR C-ORM-STATUS
    END-CALL
    CALL "CORM-POOL-DESTROY" USING C-ORM-POOL-PTR C-ORM-STATUS
    END-CALL
    DISPLAY "EX-POOL-DEMO OK"
    END-DISPLAY
    STOP RUN RETURNING 0.
END PROGRAM EX-POOL-DEMO.
