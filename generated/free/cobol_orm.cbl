>>SOURCE FORMAT IS FREE
*> @file cobol_orm.cbl
*> @brief Auto-generated COBOL FFI wrapper subprograms.

*> | @brief Resolves a `cobol_orm_error_t` code to its canonical uppercase name
*> | into a COBOL `PIC X` space-padded buffer.
*> | @param[in] err Error status code to describe.
*> | @param[out] out_buf Caller-allocated character buffer receiving space-padded
*> | name.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length of the error name.
*> | @return `COBOL_ORM_OK` on success, `COBOL_ORM_ERROR_NULL_POINTER` if
*> | `out_buf` or `out_len` is NULL, or `COBOL_ORM_ERROR_TRUNCATION` if `buf_cap`
*> | is smaller than the name length.
*> @module COBOL-ORM-ERROR-NAME
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_error_name.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-ERROR-NAME.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-ERROR-NAME Invoke C symbol cobol_orm_error_name.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_error_name"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-ERROR-NAME.

*> | @brief Connects to any supported database backend (`sqlite://`, `memory://`,
*> | `odbc://`, `db2://`, `postgres://`, `mysql://`) via a COBOL `PIC X` URL.
*> | @param[in] url Space-padded or NUL-terminated connection URL buffer.
*> | @param[in] url_len Length of `url` buffer in bytes.
*> | @param[out] out_db Receives the strongly-typed database handle on success.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CONNECT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_connect.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CONNECT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CONNECT Invoke C symbol cobol_orm_connect.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_connect"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CONNECT.

*> | @brief Disconnects and frees a database connection handle.
*> | @param[in] db Database handle previously returned by `cobol_orm_connect`.
*> | @return `COBOL_ORM_OK` on success, or `COBOL_ORM_ERROR_INVALID_HANDLE`.
*> @module COBOL-ORM-DISCONNECT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_disconnect.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DISCONNECT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DISCONNECT Invoke C symbol cobol_orm_disconnect.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_disconnect"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DISCONNECT.

*> | @brief Executes a raw SQL DDL or DML statement returning no result rows.
*> | @param[in] db Active database connection handle.
*> | @param[in] sql Space-padded SQL text buffer (supports arbitrary length).
*> | @param[in] sql_len Length of `sql` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-EXEC-SQL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_exec_sql.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-EXEC-SQL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-EXEC-SQL Invoke C symbol cobol_orm_exec_sql.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_exec_sql"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-EXEC-SQL.

*> | @brief Copies the driver's last error message into a COBOL `PIC X` buffer.
*> | @param[in] db Active database connection handle.
*> | @param[out] out_buf Destination buffer space-padded to `buf_cap`.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length of message.
*> | @return `COBOL_ORM_OK` on success, or error code on truncation/failure.
*> @module COBOL-ORM-LAST-ERROR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_last_error.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-LAST-ERROR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-LAST-ERROR Invoke C symbol cobol_orm_last_error.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_last_error"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-LAST-ERROR.

*> | @brief Copies the contextual error trace stack into a COBOL `PIC X` buffer.
*> | @param[in] db Active database connection handle.
*> | @param[out] out_buf Destination buffer space-padded to `buf_cap`.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length of trace.
*> | @return `COBOL_ORM_OK` on success, or error code on truncation/failure.
*> @module COBOL-ORM-LAST-TRACE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_last_trace.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-LAST-TRACE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-LAST-TRACE Invoke C symbol cobol_orm_last_trace.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_last_trace"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-LAST-TRACE.

*> | @brief Retrieves the 64-bit row ID generated by the most recent `INSERT`.
*> | @param[in] db Active database connection handle.
*> | @param[out] out_rowid Receives the 64-bit last insert row ID.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-LAST-INSERT-ROWID
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_last_insert_rowid.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-LAST-INSERT-ROWID.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-DOUBLE SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-LAST-INSERT-ROWID Invoke C symbol cobol_orm_last_insert_rowid.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_last_insert_rowid"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-LAST-INSERT-ROWID.

*> | @brief Enables or disables the per-connection prepared-statement LRU cache.
*> | @param[in] db Active database connection handle.
*> | @param[in] capacity Maximum cached statements (`0` disables caching).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-ENABLE-STMT-CACHE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_enable_stmt_cache.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-ENABLE-STMT-CACHE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-ENABLE-STMT-CACHE Invoke C symbol cobol_orm_enable_stmt_cache.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_enable_stmt_cache"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-ENABLE-STMT-CACHE.

*> | @brief Configures the session UTC timezone offset and optional IANA name.
*> | @param[in] db Active database connection handle.
*> | @param[in] offset_minutes Offset from UTC in minutes.
*> | @param[in] tz_name Optional timezone name buffer (may be NULL if
*> | `tz_len==0`).
*> | @param[in] tz_len Length of `tz_name` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-SET-TIMEZONE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_set_timezone.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-SET-TIMEZONE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-SET-TIMEZONE Invoke C symbol cobol_orm_set_timezone.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_set_timezone"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-SET-TIMEZONE.

*> | @brief Configures the slow-query telemetry logging threshold in milliseconds.
*> | @param[in] db Active database connection handle.
*> | @param[in] threshold_ms Milliseconds threshold (`0` disables slow-query log).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-SET-SLOW-QUERY-MS
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_set_slow_query_ms.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-SET-SLOW-QUERY-MS.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-SET-SLOW-QUERY-MS Invoke C symbol cobol_orm_set_slow_query_ms.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_set_slow_query_ms"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-SET-SLOW-QUERY-MS.

*> | @brief Writes the `cobol-orm` semantic version string into a `PIC X` buffer.
*> | @param[out] out_buf Destination space-padded buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length of version string.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-VERSION
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_version.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-VERSION.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-VERSION Invoke C symbol cobol_orm_version.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_version"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-VERSION.

*> | @brief Initializes a bounded thread-safe database connection pool.
*> | @param[in] url Connection URL buffer.
*> | @param[in] url_len Length of `url` buffer in bytes.
*> | @param[in] min_conns Minimum pre-warmed connections.
*> | @param[in] max_conns Maximum pool connections.
*> | @param[in] timeout_ms Acquisition wait timeout in milliseconds.
*> | @param[out] out_pool Receives initialized connection pool handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-POOL-INIT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_pool_init.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-POOL-INIT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-POOL-INIT Invoke C symbol cobol_orm_pool_init.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_pool_init"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-POOL-INIT.

*> | @brief Leases a database connection handle from a connection pool.
*> | @param[in] pool Connection pool handle.
*> | @param[out] out_db Receives leased database handle.
*> | @return `COBOL_ORM_OK` on success, `COBOL_ORM_ERROR_TIMEOUT` if exhausted, or
*> | other error code.
*> @module COBOL-ORM-POOL-ACQUIRE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_pool_acquire.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-POOL-ACQUIRE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-POOL-ACQUIRE Invoke C symbol cobol_orm_pool_acquire.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_pool_acquire"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-POOL-ACQUIRE.

*> | @brief Returns a previously leased database connection back to the pool.
*> | @param[in] pool Connection pool handle.
*> | @param[in] db Database handle acquired via `cobol_orm_pool_acquire`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-POOL-RELEASE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_pool_release.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-POOL-RELEASE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-POOL-RELEASE Invoke C symbol cobol_orm_pool_release.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_pool_release"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-POOL-RELEASE.

*> | @brief Snapshots live pool utilization and wait telemetry metrics.
*> | @param[in] pool Connection pool handle.
*> | @param[out] out_stats Receives populated `cobol_orm_pool_stats_t`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-POOL-TELEMETRY
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_pool_telemetry.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-POOL-TELEMETRY.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(24).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-POOL-TELEMETRY Invoke C symbol cobol_orm_pool_telemetry.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_pool_telemetry"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-POOL-TELEMETRY.

*> | @brief Destroys a connection pool and closes all pooled sessions.
*> | @param[in] pool Connection pool handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-POOL-DESTROY
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_pool_destroy.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-POOL-DESTROY.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-POOL-DESTROY Invoke C symbol cobol_orm_pool_destroy.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_pool_destroy"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-POOL-DESTROY.

*> | @brief Begins an explicit database transaction.
*> | @param[in] db Active database connection handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-TX-BEGIN
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_tx_begin.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-TX-BEGIN.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-TX-BEGIN Invoke C symbol cobol_orm_tx_begin.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_tx_begin"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-TX-BEGIN.

*> | @brief Commits the active database transaction.
*> | @param[in] db Active database connection handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-TX-COMMIT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_tx_commit.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-TX-COMMIT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-TX-COMMIT Invoke C symbol cobol_orm_tx_commit.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_tx_commit"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-TX-COMMIT.

*> | @brief Rolls back the active database transaction.
*> | @param[in] db Active database connection handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-TX-ROLLBACK
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_tx_rollback.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-TX-ROLLBACK.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-TX-ROLLBACK Invoke C symbol cobol_orm_tx_rollback.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_tx_rollback"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-TX-ROLLBACK.

*> | @brief Creates a named savepoint inside an active transaction.
*> | @param[in] db Active database connection handle.
*> | @param[in] name Savepoint identifier buffer.
*> | @param[in] name_len Length of `name` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-TX-SAVEPOINT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_tx_savepoint.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-TX-SAVEPOINT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-TX-SAVEPOINT Invoke C symbol cobol_orm_tx_savepoint.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_tx_savepoint"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-TX-SAVEPOINT.

*> | @brief Releases a named savepoint.
*> | @param[in] db Active database connection handle.
*> | @param[in] name Savepoint identifier buffer.
*> | @param[in] name_len Length of `name` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-TX-RELEASE-SP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_tx_release_sp.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-TX-RELEASE-SP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-TX-RELEASE-SP Invoke C symbol cobol_orm_tx_release_sp.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_tx_release_sp"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-TX-RELEASE-SP.

*> | @brief Rolls back work performed after a named savepoint.
*> | @param[in] db Active database connection handle.
*> | @param[in] name Savepoint identifier buffer.
*> | @param[in] name_len Length of `name` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-TX-ROLLBACK-SP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_tx_rollback_sp.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-TX-ROLLBACK-SP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-TX-ROLLBACK-SP Invoke C symbol cobol_orm_tx_rollback_sp.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_tx_rollback_sp"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-TX-ROLLBACK-SP.

*> | @brief Prepares a parameterized SQL statement on `db`.
*> | @param[in] db Active database connection handle.
*> | @param[in] sql SQL statement buffer.
*> | @param[in] sql_len Length of `sql` buffer in bytes.
*> | @param[out] out_stmt Receives prepared statement handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-PREPARE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_prepare.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-PREPARE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-PREPARE Invoke C symbol cobol_orm_stmt_prepare.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_prepare"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-PREPARE.

*> | @brief Prepares a parameterized SQL statement using the session LRU cache.
*> | @param[in] db Active database connection handle.
*> | @param[in] sql SQL statement buffer.
*> | @param[in] sql_len Length of `sql` buffer in bytes.
*> | @param[out] out_stmt Receives cached prepared statement handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-PREPARE-CACHED
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_prepare_cached.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-PREPARE-CACHED.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-PREPARE-CACHED Invoke C symbol cobol_orm_stmt_prepare_cached.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_prepare_cached"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-PREPARE-CACHED.

*> | @brief Binds a 32-bit signed integer parameter (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] val Signed 32-bit integer value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-I32
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_i32.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-I32.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-I32 Invoke C symbol cobol_orm_stmt_bind_i32.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_i32"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-I32.

*> | @brief Binds a 64-bit signed integer parameter (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] val Signed 64-bit integer value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-I64
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_i64.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-I64.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-DOUBLE SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-I64 Invoke C symbol cobol_orm_stmt_bind_i64.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_i64"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-I64.

*> | @brief Binds a 64-bit IEEE double floating-point parameter (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] val Double-precision value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-F64
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_f64.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-F64.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE COMP-2.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-F64 Invoke C symbol cobol_orm_stmt_bind_f64.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_f64"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-F64.

*> | @brief Binds a space-trimmed COBOL `PIC X` text parameter (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] val Source `PIC X` buffer.
*> | @param[in] val_len Length of `val` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-STR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_str.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-STR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-STR Invoke C symbol cobol_orm_stmt_bind_str.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_str"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-STR.

*> | @brief Binds a raw binary BLOB parameter (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] data Binary byte buffer.
*> | @param[in] data_len Number of bytes in `data`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-BLOB
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_blob.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-BLOB.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-BLOB Invoke C symbol cobol_orm_stmt_bind_blob.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_blob"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
            BY VALUE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-BLOB.

*> | @brief Binds an exact 38-digit fixed-point decimal parameter (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] dec Exact fixed-point decimal value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-DECIMAL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_decimal.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-DECIMAL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-DECIMAL Invoke C symbol cobol_orm_stmt_bind_decimal.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_decimal"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-DECIMAL.

*> | @brief Binds a native COBOL `COMP-3` (packed decimal) buffer directly as an
*> | exact fixed-point SQL parameter.
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @param[in] comp3 Raw COBOL `COMP-3` byte buffer.
*> | @param[in] byte_len Length of `comp3` in bytes (`1..20`).
*> | @param[in] frac_digits Implied fractional digits after `V` (`0..38`).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-COMP3
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_comp3.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-COMP3.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-COMP3 Invoke C symbol cobol_orm_stmt_bind_comp3.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_comp3"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-COMP3.

*> | @brief Binds SQL `NULL` to a parameter position (1-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 1-based parameter index.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-BIND-NULL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_bind_null.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-BIND-NULL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-BIND-NULL Invoke C symbol cobol_orm_stmt_bind_null.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_bind_null"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-BIND-NULL.

*> | @brief Advances execution of a prepared statement by one row.
*> | @param[in] stmt Prepared statement handle.
*> | @param[out] out_has_row Set to `1` if a result row is available, else `0`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-STEP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_step.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-STEP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-STEP Invoke C symbol cobol_orm_stmt_step.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_step"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-STEP.

*> | @brief Resets a prepared statement for re-binding and re-execution.
*> | @param[in] stmt Prepared statement handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-RESET
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_reset.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-RESET.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-RESET Invoke C symbol cobol_orm_stmt_reset.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_reset"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-RESET.

*> | @brief Finalizes a statement (or returns it to cache) and frees its handle.
*> | @param[in] stmt Prepared statement handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-FINALIZE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_finalize.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-FINALIZE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-FINALIZE Invoke C symbol cobol_orm_stmt_finalize.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_finalize"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-FINALIZE.

*> | @brief Retrieves the number of columns in the current statement result set.
*> | @param[in] stmt Prepared statement handle.
*> | @param[out] out_count Receives column count.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-COUNT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_count.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-COUNT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-COUNT Invoke C symbol cobol_orm_stmt_col_count.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_count"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-COUNT.

*> | @brief Retrieves a result column's name (0-based index) into `PIC X`.
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_buf Destination space-padded character buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-NAME
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_name.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-NAME.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-NAME Invoke C symbol cobol_orm_stmt_col_name.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_name"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-NAME.

*> | @brief Checks whether a result column (0-based index) is SQL `NULL`.
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_is_null Set to `1` if NULL, `0` otherwise.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-IS-NULL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_is_null.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-IS-NULL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-IS-NULL Invoke C symbol cobol_orm_stmt_col_is_null.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_is_null"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-IS-NULL.

*> | @brief Reads a 32-bit signed integer column value (0-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_val Receives 32-bit integer value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-I32
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_i32.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-I32.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-I32 Invoke C symbol cobol_orm_stmt_col_i32.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_i32"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-I32.

*> | @brief Reads a 64-bit signed integer column value (0-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_val Receives 64-bit integer value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-I64
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_i64.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-I64.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-DOUBLE SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-I64 Invoke C symbol cobol_orm_stmt_col_i64.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_i64"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-I64.

*> | @brief Reads a 64-bit IEEE double column value (0-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_val Receives double value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-F64
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_f64.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-F64.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE COMP-2.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-F64 Invoke C symbol cobol_orm_stmt_col_f64.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_f64"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-F64.

*> | @brief Reads a text column value (0-based index) into a `PIC X` buffer.
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_buf Destination space-padded buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on truncation/failure.
*> @module COBOL-ORM-STMT-COL-STR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_str.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-STR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-STR Invoke C symbol cobol_orm_stmt_col_str.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_str"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-STR.

*> | @brief Reads a raw BLOB column value (0-based index) into a byte buffer.
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_buf Destination byte buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives actual BLOB byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on truncation/failure.
*> @module COBOL-ORM-STMT-COL-BLOB
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_blob.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-BLOB.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-BLOB Invoke C symbol cobol_orm_stmt_col_blob.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_blob"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-BLOB.

*> | @brief Reads an exact 38-digit fixed-point decimal column (0-based index).
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[out] out_dec Receives exact decimal value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-DECIMAL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_decimal.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-DECIMAL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-DECIMAL Invoke C symbol cobol_orm_stmt_col_decimal.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_decimal"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-DECIMAL.

*> | @brief Reads a decimal SQL column directly into a COBOL `COMP-3` buffer.
*> | @param[in] stmt Prepared statement handle.
*> | @param[in] idx 0-based column index.
*> | @param[in] int_digits Integer digits before implied `V`.
*> | @param[in] frac_digits Fractional digits after implied `V`.
*> | @param[in] is_signed Non-zero for `PIC S9`, 0 for unsigned `PIC 9`.
*> | @param[in] round_mode Rounding mode if rescaling is required.
*> | @param[out] out_comp3 Destination `COMP-3` byte buffer.
*> | @param[in] buf_cap Capacity of `out_comp3` in bytes.
*> | @param[out] out_written Receives bytes written to `out_comp3`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-STMT-COL-COMP3
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_stmt_col_comp3.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-STMT-COL-COMP3.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-7 FFI linkage parameter 7.
01 LS-ARG-7 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-8 FFI linkage parameter 8.
01 LS-ARG-8 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-STMT-COL-COMP3 Invoke C symbol cobol_orm_stmt_col_comp3.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-ARG-7 Linkage argument 7.
*> @param LS-ARG-8 Linkage argument 8.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-ARG-7 LS-ARG-8 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_stmt_col_comp3"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
            BY REFERENCE LS-ARG-6
            BY VALUE LS-ARG-7
            BY REFERENCE LS-ARG-8
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-STMT-COL-COMP3.

*> | @brief Executes a SQL query and hydrates all rows into a dynamic result set.
*> | @param[in] db Active database connection handle.
*> | @param[in] sql SQL query text buffer.
*> | @param[in] sql_len Length of `sql` buffer in bytes.
*> | @param[out] out_rs Receives allocated result set handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-QUERY-ABSTRACT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_query_abstract.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-QUERY-ABSTRACT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-QUERY-ABSTRACT Invoke C symbol cobol_orm_query_abstract.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_query_abstract"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-QUERY-ABSTRACT.

*> | @brief Retrieves total hydrated row count in a dynamic result set.
*> | @param[in] rs Result set handle.
*> | @param[out] out_count Receives number of rows.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-ROW-COUNT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_row_count.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-ROW-COUNT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-ROW-COUNT Invoke C symbol cobol_orm_rs_row_count.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_row_count"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-ROW-COUNT.

*> | @brief Retrieves column count for a specific row in a dynamic result set.
*> | @param[in] rs Result set handle.
*> | @param[in] row_idx 0-based row index.
*> | @param[out] out_count Receives number of columns in `row_idx`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-COL-COUNT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_col_count.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-COL-COUNT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-COL-COUNT Invoke C symbol cobol_orm_rs_col_count.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_col_count"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-COL-COUNT.

*> | @brief Retrieves a column name by 0-based index in a dynamic result set.
*> | @param[in] rs Result set handle.
*> | @param[in] row_idx 0-based row index.
*> | @param[in] col_idx 0-based column index.
*> | @param[out] out_buf Destination space-padded buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-COL-NAME
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_col_name.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-COL-NAME.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-COL-NAME Invoke C symbol cobol_orm_rs_col_name.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_col_name"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-COL-NAME.

*> | @brief Retrieves the variant type of a named column in a dynamic result set.
*> | @param[in] rs Result set handle.
*> | @param[in] row_idx 0-based row index.
*> | @param[in] col_name Column name buffer.
*> | @param[in] name_len Length of `col_name` buffer in bytes.
*> | @param[out] out_type Receives `cobol_orm_variant_type_t`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-GET-TYPE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_get_type.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-GET-TYPE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-GET-TYPE Invoke C symbol cobol_orm_rs_get_type.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_get_type"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-GET-TYPE.

*> | @brief Retrieves a 64-bit integer value by column name from a result set.
*> | @param[in] rs Result set handle.
*> | @param[in] row_idx 0-based row index.
*> | @param[in] col_name Column name buffer.
*> | @param[in] name_len Length of `col_name` buffer in bytes.
*> | @param[out] out_val Receives 64-bit integer value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-GET-I64
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_get_i64.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-GET-I64.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-DOUBLE SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-GET-I64 Invoke C symbol cobol_orm_rs_get_i64.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_get_i64"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-GET-I64.

*> | @brief Retrieves a 64-bit double value by column name from a result set.
*> | @param[in] rs Result set handle.
*> | @param[in] row_idx 0-based row index.
*> | @param[in] col_name Column name buffer.
*> | @param[in] name_len Length of `col_name` buffer in bytes.
*> | @param[out] out_val Receives double value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-GET-F64
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_get_f64.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-GET-F64.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE COMP-2.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-GET-F64 Invoke C symbol cobol_orm_rs_get_f64.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_get_f64"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-GET-F64.

*> | @brief Retrieves a text value by column name into a `PIC X` buffer.
*> | @param[in] rs Result set handle.
*> | @param[in] row_idx 0-based row index.
*> | @param[in] col_name Column name buffer.
*> | @param[in] name_len Length of `col_name` buffer in bytes.
*> | @param[out] out_buf Destination space-padded buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-GET-STR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_get_str.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-GET-STR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE POINTER.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-GET-STR Invoke C symbol cobol_orm_rs_get_str.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_get_str"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
            BY REFERENCE LS-ARG-6
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-GET-STR.

*> | @brief Frees a dynamic result set handle and all hydrated row memory.
*> | @param[in] rs Result set handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-RS-FREE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_rs_free.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-RS-FREE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-RS-FREE Invoke C symbol cobol_orm_rs_free.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_rs_free"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-RS-FREE.

*> | @brief Creates a new fluent SQL AST query builder handle.
*> | @param[out] out_ast Receives allocated AST builder handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-NEW
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_new.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-NEW.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-NEW Invoke C symbol cobol_orm_ast_new.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_new"
        USING
            BY REFERENCE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-NEW.

*> | @brief Sets the `SELECT` projection columns on an AST query.
*> | @param[in] ast AST query handle.
*> | @param[in] cols Comma-separated column projection string.
*> | @param[in] cols_len Length of `cols` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-SELECT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_select.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-SELECT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-SELECT Invoke C symbol cobol_orm_ast_select.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_select"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-SELECT.

*> | @brief Enables `SELECT DISTINCT` on an AST query.
*> | @param[in] ast AST query handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-DISTINCT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_distinct.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-DISTINCT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-DISTINCT Invoke C symbol cobol_orm_ast_distinct.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_distinct"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-DISTINCT.

*> | @brief Sets the `FROM` target table on an AST query.
*> | @param[in] ast AST query handle.
*> | @param[in] table Table name buffer.
*> | @param[in] table_len Length of `table` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-FROM
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_from.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-FROM.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-FROM Invoke C symbol cobol_orm_ast_from.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_from"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-FROM.

*> | @brief Configures the AST query as an `INSERT INTO <table>` statement.
*> | @param[in] ast AST query handle.
*> | @param[in] table Target table name buffer.
*> | @param[in] table_len Length of `table` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-INSERT-INTO
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_insert_into.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-INSERT-INTO.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-INSERT-INTO Invoke C symbol cobol_orm_ast_insert_into.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_insert_into"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-INSERT-INTO.

*> | @brief Configures the AST query as an `UPDATE <table>` statement.
*> | @param[in] ast AST query handle.
*> | @param[in] table Target table name buffer.
*> | @param[in] table_len Length of `table` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-UPDATE-TABLE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_update_table.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-UPDATE-TABLE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-UPDATE-TABLE Invoke C symbol cobol_orm_ast_update_table.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_update_table"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-UPDATE-TABLE.

*> | @brief Configures the AST query as a `DELETE FROM <table>` statement.
*> | @param[in] ast AST query handle.
*> | @param[in] table Target table name buffer.
*> | @param[in] table_len Length of `table` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-DELETE-FROM
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_delete_from.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-DELETE-FROM.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-DELETE-FROM Invoke C symbol cobol_orm_ast_delete_from.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_delete_from"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-DELETE-FROM.

*> | @brief Appends a column assignment (`SET col = val`) for `INSERT`/`UPDATE`.
*> | @param[in] ast AST query handle.
*> | @param[in] col Column name buffer.
*> | @param[in] col_len Length of `col` buffer in bytes.
*> | @param[in] val Literal value text buffer.
*> | @param[in] val_len Length of `val` buffer in bytes.
*> | @param[in] is_string Non-zero if value is a quoted string literal, 0 numeric.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-SET-COL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_set_col.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-SET-COL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-SET-COL Invoke C symbol cobol_orm_ast_set_col.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_set_col"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-SET-COL.

*> | @brief Appends a `WHERE` (or `AND WHERE`) equality predicate.
*> | @param[in] ast AST query handle.
*> | @param[in] col Column name buffer.
*> | @param[in] col_len Length of `col` buffer in bytes.
*> | @param[in] val Value literal text buffer.
*> | @param[in] val_len Length of `val` buffer in bytes.
*> | @param[in] is_string Non-zero for string literal, 0 for numeric literal.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-WHERE-EQ
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_where_eq.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-WHERE-EQ.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-WHERE-EQ Invoke C symbol cobol_orm_ast_where_eq.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_where_eq"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-WHERE-EQ.

*> | @brief Appends a `JOIN` clause to an AST query.
*> | @param[in] ast AST query handle.
*> | @param[in] join_type Join type (`INNER`, `LEFT`, `RIGHT`).
*> | @param[in] table Target join table name buffer.
*> | @param[in] table_len Length of `table` buffer in bytes.
*> | @param[in] on_sql Raw SQL join `ON` condition expression.
*> | @param[in] on_len Length of `on_sql` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-JOIN
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_join.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-JOIN.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE POINTER.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-JOIN Invoke C symbol cobol_orm_ast_join.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_join"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-JOIN.

*> | @brief Appends a `GROUP BY` clause to an AST query.
*> | @param[in] ast AST query handle.
*> | @param[in] cols Comma-separated grouping column list.
*> | @param[in] cols_len Length of `cols` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-GROUP-BY
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_group_by.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-GROUP-BY.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-GROUP-BY Invoke C symbol cobol_orm_ast_group_by.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_group_by"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-GROUP-BY.

*> | @brief Appends an `ORDER BY` clause to an AST query.
*> | @param[in] ast AST query handle.
*> | @param[in] col Sort column expression buffer.
*> | @param[in] col_len Length of `col` buffer in bytes.
*> | @param[in] is_desc Non-zero for `DESC`, 0 for `ASC`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-ORDER-BY
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_order_by.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-ORDER-BY.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-ORDER-BY Invoke C symbol cobol_orm_ast_order_by.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_order_by"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-ORDER-BY.

*> | @brief Sets `LIMIT` and `OFFSET` pagination clauses on an AST query.
*> | @param[in] ast AST query handle.
*> | @param[in] limit Maximum rows (`0` omits `LIMIT`).
*> | @param[in] offset Rows to skip (`0` omits `OFFSET`).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-LIMIT-OFFSET
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_limit_offset.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-LIMIT-OFFSET.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-LIMIT-OFFSET Invoke C symbol cobol_orm_ast_limit_offset.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_limit_offset"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-LIMIT-OFFSET.

*> | @brief Adds an IBM Db2 isolation lock clause (`WITH UR/CS/RS/RR`) to AST.
*> | @param[in] ast AST query handle.
*> | @param[in] iso Isolation level (`UR`, `CS`, `RS`, `RR`).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-WITH-LOCK
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_with_lock.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-WITH-LOCK.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-WITH-LOCK Invoke C symbol cobol_orm_ast_with_lock.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_with_lock"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-WITH-LOCK.

*> | @brief Renders an AST query into dialect-specific parameterized SQL text.
*> | @param[in] ast AST query handle.
*> | @param[in] dialect Target SQL dialect (`SQLITE`, `POSTGRES`, `MYSQL`, `DB2`,
*> | `ODBC`).
*> | @param[out] out_sql Destination space-padded SQL buffer.
*> | @param[in] sql_cap Capacity of `out_sql` in bytes.
*> | @param[out] out_len Receives exact unpadded SQL byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on truncation/failure.
*> @module COBOL-ORM-AST-TO-SQL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_to_sql.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-TO-SQL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-TO-SQL Invoke C symbol cobol_orm_ast_to_sql.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_to_sql"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-TO-SQL.

*> | @brief Executes an AST `INSERT`/`UPDATE`/`DELETE` statement on `db`.
*> | @param[in] db Active database connection handle.
*> | @param[in] ast AST query handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-EXEC
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_exec.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-EXEC.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-EXEC Invoke C symbol cobol_orm_ast_exec.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_exec"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-EXEC.

*> | @brief Frees an AST query handle and its entire bump arena.
*> | @param[in] ast AST query handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-AST-FREE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ast_free.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-AST-FREE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-AST-FREE Invoke C symbol cobol_orm_ast_free.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ast_free"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-AST-FREE.

*> | @brief Parses a base-10 decimal string into an exact `cobol_orm_decimal_t`.
*> | @param[in] str Decimal string buffer.
*> | @param[in] str_len Length of `str` buffer in bytes.
*> | @param[out] out_dec Receives parsed fixed-point decimal.
*> | @return `COBOL_ORM_OK` on success, or error code on syntax/overflow error.
*> @module COBOL-ORM-DEC-FROM-STR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_from_str.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-FROM-STR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-FROM-STR Invoke C symbol cobol_orm_dec_from_str.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_from_str"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-FROM-STR.

*> | @brief Formats an exact `cobol_orm_decimal_t` into a space-padded `PIC X`.
*> | @param[in] dec Source fixed-point decimal value.
*> | @param[out] out_buf Destination space-padded buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_len Receives exact unpadded byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-TO-STR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_to_str.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-TO-STR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-TO-STR Invoke C symbol cobol_orm_dec_to_str.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_to_str"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-TO-STR.

*> | @brief Computes exact fixed-point addition (`a + b`).
*> | @param[in] a Left addend.
*> | @param[in] b Right addend.
*> | @param[out] out_res Receives sum.
*> | @return `COBOL_ORM_OK` on success, or error code on overflow.
*> @module COBOL-ORM-DEC-ADD
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_add.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-ADD.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(41).
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-ADD Invoke C symbol cobol_orm_dec_add.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_add"
        USING
            BY REFERENCE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-ADD.

*> | @brief Computes exact fixed-point subtraction (`a - b`).
*> | @param[in] a Minuend.
*> | @param[in] b Subtrahend.
*> | @param[out] out_res Receives difference.
*> | @return `COBOL_ORM_OK` on success, or error code on overflow.
*> @module COBOL-ORM-DEC-SUB
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_sub.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-SUB.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(41).
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-SUB Invoke C symbol cobol_orm_dec_sub.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_sub"
        USING
            BY REFERENCE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-SUB.

*> | @brief Computes fixed-point multiplication (`a * b`) with rounding.
*> | @param[in] a Multiplicand.
*> | @param[in] b Multiplier.
*> | @param[in] max_scale Maximum fractional scale to retain (`0..38`).
*> | @param[in] mode Rounding mode when scale is reduced.
*> | @param[out] out_res Receives product.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-MUL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_mul.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-MUL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(41).
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-MUL Invoke C symbol cobol_orm_dec_mul.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_mul"
        USING
            BY REFERENCE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-MUL.

*> | @brief Computes fixed-point division (`a / b`) rounded to `result_scale`.
*> | @param[in] a Dividend.
*> | @param[in] b Divisor.
*> | @param[in] result_scale Desired quotient fractional scale (`0..38`).
*> | @param[in] mode Rounding mode applied to remainder.
*> | @param[out] out_res Receives quotient.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-DIV
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_div.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-DIV.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(41).
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-DIV Invoke C symbol cobol_orm_dec_div.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_div"
        USING
            BY REFERENCE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-DIV.

*> | @brief Compares two exact decimals numerically (`-1`, `0`, or `+1`).
*> | @param[in] a Left decimal.
*> | @param[in] b Right decimal.
*> | @param[out] out_cmp Receives `-1` if `a < b`, `0` if equal, `1` if `a > b`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-CMP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_cmp.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-CMP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(41).
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-CMP Invoke C symbol cobol_orm_dec_cmp.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_cmp"
        USING
            BY REFERENCE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-CMP.

*> | @brief Packs a `cobol_orm_decimal_t` into a COBOL `COMP-3` byte buffer.
*> | @param[in] dec Source decimal value.
*> | @param[in] int_digits Integer digits before `V`.
*> | @param[in] frac_digits Fractional digits after `V`.
*> | @param[in] is_signed Non-zero for `PIC S9`, 0 for unsigned `PIC 9`.
*> | @param[out] out_buf Destination `COMP-3` buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_written Receives bytes written.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-TO-COMP3
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_to_comp3.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-TO-COMP3.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-TO-COMP3 Invoke C symbol cobol_orm_dec_to_comp3.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_to_comp3"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
            BY VALUE LS-ARG-5
            BY REFERENCE LS-ARG-6
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-TO-COMP3.

*> | @brief Unpacks a COBOL `COMP-3` byte buffer into a `cobol_orm_decimal_t`.
*> | @param[in] buf Source `COMP-3` bytes.
*> | @param[in] buf_len Length of `buf` in bytes (`1..20`).
*> | @param[in] frac_digits Implied fractional digits after `V`.
*> | @param[out] out_dec Receives unpacked decimal value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-FROM-COMP3
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_from_comp3.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-FROM-COMP3.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-FROM-COMP3 Invoke C symbol cobol_orm_dec_from_comp3.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_from_comp3"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-FROM-COMP3.

*> | @brief Packs a `cobol_orm_decimal_t` into COBOL Zoned Decimal (`DISPLAY`).
*> | @param[in] dec Source decimal value.
*> | @param[in] int_digits Integer digits before `V`.
*> | @param[in] frac_digits Fractional digits after `V`.
*> | @param[in] is_signed Non-zero for `PIC S9`.
*> | @param[in] sign_leading Non-zero for `SIGN IS LEADING`, 0 for trailing.
*> | @param[in] sign_separate Non-zero for `SEPARATE CHARACTER`, 0 overpunch.
*> | @param[in] use_ebcdic Non-zero for EBCDIC zones, 0 for ASCII.
*> | @param[out] out_buf Destination buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @param[out] out_written Receives bytes written.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-TO-ZONED
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_to_zoned.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-TO-ZONED.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(41).
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-7 FFI linkage parameter 7.
01 LS-ARG-7 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-8 FFI linkage parameter 8.
01 LS-ARG-8 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-9 FFI linkage parameter 9.
01 LS-ARG-9 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-TO-ZONED Invoke C symbol cobol_orm_dec_to_zoned.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-ARG-7 Linkage argument 7.
*> @param LS-ARG-8 Linkage argument 8.
*> @param LS-ARG-9 Linkage argument 9.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-ARG-7 LS-ARG-8 LS-ARG-9 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_to_zoned"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
            BY VALUE LS-ARG-6
            BY REFERENCE LS-ARG-7
            BY VALUE LS-ARG-8
            BY REFERENCE LS-ARG-9
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-TO-ZONED.

*> | @brief Unpacks a COBOL Zoned Decimal (`DISPLAY`) buffer into a decimal.
*> | @param[in] buf Source zoned-decimal bytes.
*> | @param[in] buf_len Length of `buf` in bytes.
*> | @param[in] frac_digits Implied fractional digits after `V`.
*> | @param[in] is_signed Non-zero for `PIC S9`.
*> | @param[in] sign_leading Non-zero for `SIGN IS LEADING`.
*> | @param[in] sign_separate Non-zero for `SEPARATE CHARACTER`.
*> | @param[in] use_ebcdic Non-zero for EBCDIC zones, 0 for ASCII.
*> | @param[out] out_dec Receives unpacked decimal value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DEC-FROM-ZONED
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_dec_from_zoned.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DEC-FROM-ZONED.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-7 FFI linkage parameter 7.
01 LS-ARG-7 PIC X(41).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DEC-FROM-ZONED Invoke C symbol cobol_orm_dec_from_zoned.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-ARG-7 Linkage argument 7.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-ARG-7 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_dec_from_zoned"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
            BY VALUE LS-ARG-6
            BY REFERENCE LS-ARG-7
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DEC-FROM-ZONED.

*> | @brief Encodes a 64-bit integer into 2/4/8-byte COBOL `COMP`/`COMP-5`.
*> | @param[in] val Signed 64-bit integer.
*> | @param[in] byte_width Width in bytes (`2`, `4`, or `8`).
*> | @param[in] is_big_endian Non-zero for big-endian `COMP`, 0 for `COMP-5`.
*> | @param[out] out_buf Destination byte buffer.
*> | @param[in] buf_cap Capacity of `out_buf` in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-I64-TO-COMP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_i64_to_comp.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-I64-TO-COMP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-DOUBLE SIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-I64-TO-COMP Invoke C symbol cobol_orm_i64_to_comp.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_i64_to_comp"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
            BY VALUE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-I64-TO-COMP.

*> | @brief Decodes a 2/4/8-byte COBOL `COMP`/`COMP-5` buffer into `int64`.
*> | @param[in] buf Source binary buffer.
*> | @param[in] byte_width Width in bytes (`2`, `4`, or `8`).
*> | @param[in] is_signed Non-zero for two's-complement signed.
*> | @param[in] is_big_endian Non-zero for big-endian `COMP`, 0 for `COMP-5`.
*> | @param[out] out_val Receives decoded 64-bit integer.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-I64-FROM-COMP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_i64_from_comp.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-I64-FROM-COMP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-DOUBLE SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-I64-FROM-COMP Invoke C symbol cobol_orm_i64_from_comp.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_i64_from_comp"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-I64-FROM-COMP.

*> | @brief Transcodes mainframe EBCDIC bytes (`IBM037`/`1047`/`500`/`1140`) to
*> | space-padded UTF-8 `PIC X`.
*> | @param[in] cp Source EBCDIC codepage.
*> | @param[in] in_bytes Source EBCDIC byte buffer.
*> | @param[in] in_len Length of `in_bytes` in bytes.
*> | @param[out] out_utf8 Destination space-padded UTF-8 buffer.
*> | @param[in] out_cap Capacity of `out_utf8` in bytes.
*> | @param[out] out_len Receives exact unpadded UTF-8 byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-EBCDIC-TO-UTF8
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_ebcdic_to_utf8.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-EBCDIC-TO-UTF8.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-EBCDIC-TO-UTF8 Invoke C symbol cobol_orm_ebcdic_to_utf8.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_ebcdic_to_utf8"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-EBCDIC-TO-UTF8.

*> | @brief Transcodes UTF-8 text into mainframe EBCDIC bytes.
*> | @param[in] cp Target EBCDIC codepage.
*> | @param[in] in_utf8 Source UTF-8 text buffer.
*> | @param[in] in_len Length of `in_utf8` in bytes.
*> | @param[out] out_bytes Destination EBCDIC byte buffer.
*> | @param[in] out_cap Capacity of `out_bytes` in bytes.
*> | @param[out] out_len Receives encoded EBCDIC byte count.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-UTF8-TO-EBCDIC
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_utf8_to_ebcdic.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-UTF8-TO-EBCDIC.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-UTF8-TO-EBCDIC Invoke C symbol cobol_orm_utf8_to_ebcdic.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_utf8_to_ebcdic"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-UTF8-TO-EBCDIC.

*> | @brief Transcodes UTF-8 text to UTF-16 `GRAPHIC`/`NATIONAL` code units.
*> | @param[in] in_utf8 Source UTF-8 text buffer.
*> | @param[in] in_len Length of `in_utf8` in bytes.
*> | @param[in] big_endian Non-zero for big-endian `GRAPHIC`, 0 for host-endian.
*> | @param[out] out_u16 Destination UTF-16 code unit array.
*> | @param[in] out_cap Capacity of `out_u16` in 16-bit code units.
*> | @param[out] out_units Receives number of 16-bit code units written.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-UTF8-TO-UTF16
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_utf8_to_utf16.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-UTF8-TO-UTF16.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-SHORT UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-UTF8-TO-UTF16 Invoke C symbol cobol_orm_utf8_to_utf16.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_utf8_to_utf16"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-UTF8-TO-UTF16.

*> | @brief Transcodes UTF-16 `GRAPHIC`/`NATIONAL` code units into UTF-8 `PIC X`.
*> | @param[in] in_u16 Source UTF-16 code unit array.
*> | @param[in] in_units Number of 16-bit units in `in_u16`.
*> | @param[in] big_endian Non-zero if `in_u16` is big-endian.
*> | @param[out] out_utf8 Destination space-padded UTF-8 buffer.
*> | @param[in] out_cap Capacity of `out_utf8` in bytes.
*> | @param[out] out_len Receives exact unpadded UTF-8 byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-UTF16-TO-UTF8
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_utf16_to_utf8.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-UTF16-TO-UTF8.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE BINARY-SHORT UNSIGNED.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-UTF16-TO-UTF8 Invoke C symbol cobol_orm_utf16_to_utf8.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_utf16_to_utf8"
        USING
            BY REFERENCE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-UTF16-TO-UTF8.

*> | @brief Parses a COBOL Copybook (`.cpy`) source string into a reusable handle.
*> | @param[in] src Copybook source text buffer.
*> | @param[in] src_len Length of `src` in bytes.
*> | @param[in] fmt Source layout format (`AUTO`, `FIXED`, `FREE`).
*> | @param[out] out_cpy Receives allocated Copybook handle.
*> | @return `COBOL_ORM_OK` on success, or error code on syntax/OOM failure.
*> @module COBOL-ORM-CPY-PARSE-STR
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_parse_str.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-PARSE-STR.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-PARSE-STR Invoke C symbol cobol_orm_cpy_parse_str.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_parse_str"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-PARSE-STR.

*> | @brief Parses a COBOL Copybook (`.cpy`) file from disk into a handle.
*> | @param[in] path File path buffer.
*> | @param[in] path_len Length of `path` buffer in bytes.
*> | @param[in] fmt Source layout format (`AUTO`, `FIXED`, `FREE`).
*> | @param[out] out_cpy Receives allocated Copybook handle.
*> | @return `COBOL_ORM_OK` on success, or error code on I/O/syntax failure.
*> @module COBOL-ORM-CPY-PARSE-FILE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_parse_file.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-PARSE-FILE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-PARSE-FILE Invoke C symbol cobol_orm_cpy_parse_file.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_parse_file"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-PARSE-FILE.

*> | @brief Retrieves summary layout metadata for a parsed Copybook record.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[out] out_info Receives `cobol_orm_cpy_info_t`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-INFO
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_info.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-INFO.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 PIC X(12).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-INFO Invoke C symbol cobol_orm_cpy_info.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_info"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-INFO.

*> | @brief Retrieves metadata for a single field (0-based index) in a Copybook.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] field_idx 0-based elementary field index.
*> | @param[out] out_col Receives `cobol_orm_col_info_t`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-FIELD-INFO
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_field_info.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-FIELD-INFO.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 PIC X(16).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-FIELD-INFO Invoke C symbol cobol_orm_cpy_field_info.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_field_info"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-FIELD-INFO.

*> | @brief Overrides the SQL primary key column name for Copybook-driven CRUD.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] col_name Primary key COBOL or SQL column name buffer.
*> | @param[in] name_len Length of `col_name` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-SET-PK
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_set_pk.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-SET-PK.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-SET-PK Invoke C symbol cobol_orm_cpy_set_pk.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_set_pk"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-SET-PK.

*> | @brief Emits dialect-specific `CREATE TABLE` DDL from a parsed Copybook.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] dialect Target SQL dialect.
*> | @param[out] out_sql Destination space-padded SQL buffer.
*> | @param[in] sql_cap Capacity of `out_sql` in bytes.
*> | @param[out] out_len Receives exact unpadded SQL byte length.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-EMIT-DDL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_emit_ddl.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-EMIT-DDL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE POINTER.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-EMIT-DDL Invoke C symbol cobol_orm_cpy_emit_ddl.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_emit_ddl"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-EMIT-DDL.

*> | @brief Creates the SQL table corresponding to a parsed Copybook on `db`.
*> | @param[in] db Active database connection handle.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] dialect Target SQL dialect.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-CREATE-TABLE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_create_table.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-CREATE-TABLE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-CREATE-TABLE Invoke C symbol cobol_orm_cpy_create_table.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_create_table"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-CREATE-TABLE.

*> | @brief Validates all level-`88` domain conditions against a raw COBOL `01`
*> | record buffer.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] rec_buf Raw COBOL `01` record bytes.
*> | @param[in] rec_len Length of `rec_buf` in bytes.
*> | @param[in] cp Wire character codepage (`ASCII`/`UTF8`/`IBM037`/...).
*> | @param[in] big_endian Non-zero for mainframe big-endian `COMP`.
*> | @return `COBOL_ORM_OK` if all level-88 rules hold,
*> | `COBOL_ORM_ERROR_VALIDATION` if violated, or other error code.
*> @module COBOL-ORM-CPY-VALIDATE-88
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_validate_88.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-VALIDATE-88.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-VALIDATE-88 Invoke C symbol cobol_orm_cpy_validate_88.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_validate_88"
        USING
            BY VALUE LS-ARG-0
            BY REFERENCE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-VALIDATE-88.

*> | @brief Inserts a raw COBOL `01` working-storage record directly into `db`.
*> | @param[in] db Active database connection handle.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] rec_buf Raw COBOL `01` record bytes.
*> | @param[in] rec_len Length of `rec_buf` in bytes.
*> | @param[in] cp Wire character codepage.
*> | @param[in] big_endian Non-zero for mainframe big-endian `COMP`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-INSERT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_insert.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-INSERT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-INSERT Invoke C symbol cobol_orm_cpy_insert.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_insert"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-INSERT.

*> | @brief Updates an existing SQL row from a raw COBOL `01` record by its PK.
*> | @param[in] db Active database connection handle.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] rec_buf Raw COBOL `01` record bytes.
*> | @param[in] rec_len Length of `rec_buf` in bytes.
*> | @param[in] cp Wire character codepage.
*> | @param[in] big_endian Non-zero for mainframe big-endian `COMP`.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-UPDATE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_update.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-UPDATE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-UPDATE Invoke C symbol cobol_orm_cpy_update.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_update"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY VALUE LS-ARG-5
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-UPDATE.

*> | @brief Finds a SQL row by 32-bit integer PK and hydrates it directly into a
*> | raw COBOL `01` record buffer.
*> | @param[in] db Active database connection handle.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] id_val 32-bit integer primary key value.
*> | @param[in] cp Target wire character codepage.
*> | @param[in] big_endian Non-zero for mainframe big-endian `COMP`.
*> | @param[out] out_rec_buf Destination COBOL `01` record buffer.
*> | @param[in] rec_cap Capacity of `out_rec_buf` in bytes.
*> | @return `COBOL_ORM_OK` on success, `COBOL_ORM_ERROR_NOT_FOUND` if missing, or
*> | other error code.
*> @module COBOL-ORM-CPY-FIND-I32
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_find_i32.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-FIND-I32.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-FIND-I32 Invoke C symbol cobol_orm_cpy_find_i32.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_find_i32"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY VALUE LS-ARG-4
            BY REFERENCE LS-ARG-5
            BY VALUE LS-ARG-6
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-FIND-I32.

*> | @brief Deletes a SQL row by 32-bit integer PK for a Copybook table.
*> | @param[in] db Active database connection handle.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] id_val 32-bit integer primary key value.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-DELETE-I32
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_delete_i32.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-DELETE-I32.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-DELETE-I32 Invoke C symbol cobol_orm_cpy_delete_i32.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_delete_i32"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-DELETE-I32.

*> | @brief Hydrates up to `max_rows` records into a contiguous COBOL `OCCURS`
*> | record table buffer.
*> | @param[in] db Active database connection handle.
*> | @param[in] cpy Parsed Copybook handle.
*> | @param[in] cp Target wire character codepage.
*> | @param[in] big_endian Non-zero for mainframe big-endian `COMP`.
*> | @param[out] out_rec_array Contiguous array of `max_rows * total_byte_size`
*> | bytes.
*> | @param[in] max_rows Maximum records that fit in `out_rec_array`.
*> | @param[out] out_row_count Receives number of records hydrated.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-FIND-ALL
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_find_all.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-FIND-ALL.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-4 FFI linkage parameter 4.
01 LS-ARG-4 USAGE BINARY-CHAR UNSIGNED.
*> @record LS-ARG-5 FFI linkage parameter 5.
01 LS-ARG-5 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-6 FFI linkage parameter 6.
01 LS-ARG-6 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-FIND-ALL Invoke C symbol cobol_orm_cpy_find_all.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-ARG-4 Linkage argument 4.
*> @param LS-ARG-5 Linkage argument 5.
*> @param LS-ARG-6 Linkage argument 6.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-ARG-4 LS-ARG-5 LS-ARG-6 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_find_all"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY VALUE LS-ARG-3
            BY REFERENCE LS-ARG-4
            BY VALUE LS-ARG-5
            BY REFERENCE LS-ARG-6
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-FIND-ALL.

*> | @brief Frees a parsed Copybook handle and associated metadata.
*> | @param[in] cpy Parsed Copybook handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-CPY-FREE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_cpy_free.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-CPY-FREE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-CPY-FREE Invoke C symbol cobol_orm_cpy_free.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_cpy_free"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-CPY-FREE.

*> | @brief Creates a schema migration runner bound to `db` and a directory path.
*> | @param[in] db Active database connection handle.
*> | @param[in] dir_path Path to migration `.sql` directory.
*> | @param[in] dir_len Length of `dir_path` buffer in bytes.
*> | @param[out] out_mig Receives migration runner handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-MIG-INIT
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_mig_init.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-MIG-INIT.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-MIG-INIT Invoke C symbol cobol_orm_mig_init.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_mig_init"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-MIG-INIT.

*> | @brief Applies all pending `UP` schema migrations (optionally as dry-run).
*> | @param[in] mig Migration runner handle.
*> | @param[in] dry_run Non-zero to simulate without executing SQL.
*> | @param[out] out_applied Receives total count of applied migrations.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-MIG-UP
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_mig_up.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-MIG-UP.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-MIG-UP Invoke C symbol cobol_orm_mig_up.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_mig_up"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY REFERENCE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-MIG-UP.

*> | @brief Reverts the last `steps` applied migrations using `DOWN` scripts.
*> | @param[in] mig Migration runner handle.
*> | @param[in] steps Number of migrations to roll back (`0` rolls back all).
*> | @param[in] dry_run Non-zero to simulate without executing SQL.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-MIG-DOWN
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_mig_down.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-MIG-DOWN.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-MIG-DOWN Invoke C symbol cobol_orm_mig_down.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_mig_down"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-MIG-DOWN.

*> | @brief Frees a schema migration runner handle.
*> | @param[in] mig Migration runner handle.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-MIG-FREE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_mig_free.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-MIG-FREE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-MIG-FREE Invoke C symbol cobol_orm_mig_free.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_mig_free"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-MIG-FREE.

*> | @brief Retrieves the 5-character ODBC/Db2 `SQLSTATE` for `db`.
*> | @param[in] db Active ODBC or Db2 database handle.
*> | @param[out] out_state Destination buffer (at least 5 bytes).
*> | @param[in] cap Capacity of `out_state` in bytes.
*> | @param[out] out_len Receives exact length written (`5` when available).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-ODBC-SQLSTATE
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_odbc_sqlstate.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-ODBC-SQLSTATE.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-ARG-3 FFI linkage parameter 3.
01 LS-ARG-3 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-ODBC-SQLSTATE Invoke C symbol cobol_orm_odbc_sqlstate.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-ARG-3 Linkage argument 3.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-ARG-3 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_odbc_sqlstate"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
            BY REFERENCE LS-ARG-3
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-ODBC-SQLSTATE.

*> | @brief Configures transaction isolation level on an IBM Db2 connection.
*> | @param[in] db Active Db2 database handle.
*> | @param[in] iso Target Db2 isolation level (`UR`, `CS`, `RS`, `RR`).
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DB2-SET-ISOLATION
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_db2_set_isolation.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DB2-SET-ISOLATION.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE BINARY-LONG SIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DB2-SET-ISOLATION Invoke C symbol cobol_orm_db2_set_isolation.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_db2_set_isolation"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DB2-SET-ISOLATION.

*> | @brief Executes `SET CURRENT SCHEMA` on an IBM Db2 connection.
*> | @param[in] db Active Db2 database handle.
*> | @param[in] schema Target schema name buffer.
*> | @param[in] schema_len Length of `schema` buffer in bytes.
*> | @return `COBOL_ORM_OK` on success, or error code on failure.
*> @module COBOL-ORM-DB2-SET-SCHEMA
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_db2_set_schema.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DB2-SET-SCHEMA.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-ARG-1 FFI linkage parameter 1.
01 LS-ARG-1 USAGE POINTER.
*> @record LS-ARG-2 FFI linkage parameter 2.
01 LS-ARG-2 USAGE BINARY-LONG UNSIGNED.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DB2-SET-SCHEMA Invoke C symbol cobol_orm_db2_set_schema.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-ARG-1 Linkage argument 1.
*> @param LS-ARG-2 Linkage argument 2.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-ARG-1 LS-ARG-2 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_db2_set_schema"
        USING
            BY VALUE LS-ARG-0
            BY VALUE LS-ARG-1
            BY VALUE LS-ARG-2
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DB2-SET-SCHEMA.

*> | @brief Dispatches a single fixed-width `COMMAREA` ORM request using integer
*> | handle slot IDs (`1..64`) for COBOL-60, COBOL-61, COBOL-61 Extended,
*> | COBOL-65, COBOL-68, COBOL-74, and COBOL-85 callers without `USAGE POINTER`.
*> | @param[in,out] commarea Pointer to caller-owned `cobol_orm_commarea_t`.
*> | @return `COBOL_ORM_OK` on success, or the mirrored `commarea->status` error
*> | code.
*> @module COBOL-ORM-COMMAREA-DISPATCH
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_commarea_dispatch.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-COMMAREA-DISPATCH.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 PIC X(544).
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-COMMAREA-DISPATCH Invoke C symbol cobol_orm_commarea_dispatch.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_commarea_dispatch"
        USING
            BY REFERENCE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-COMMAREA-DISPATCH.

*> | @brief Endian-independent pure `USAGE DISPLAY` (552-byte ASCII `PIC 9`/`X`)
*> | COMMAREA dispatcher for COBOL-60, COBOL-61, COBOL-61 Extended, COBOL-65,
*> | COBOL-68, COBOL-74, and COBOL-85 programs with zero binary-endian dependency.
*> | Layout: `[0..3] opcode`, `[4..7] status`, `[8..11] db_id`, `[12..15]
*> | stmt_id`,
*> | `[16..19] param_idx`, `[20..31] val_i32 (signed ASCII)`, `[32..35]
*> | data1_len`,
*> | `[36..39] data2_len`, `[40..295] data1`, `[296..551] data2`.
*> | @param[in,out] display_buf Caller-owned 552-byte `USAGE DISPLAY` buffer.
*> | @return `COBOL_ORM_OK` on success, or mirrored status error code.
*> @module COBOL-ORM-DISPLAY-DISPATCH
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_display_dispatch.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-DISPLAY-DISPATCH.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-ARG-0 FFI linkage parameter 0.
01 LS-ARG-0 USAGE POINTER.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-DISPLAY-DISPATCH Invoke C symbol cobol_orm_display_dispatch.
*> @param LS-ARG-0 Linkage argument 0.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-ARG-0 LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_display_dispatch"
        USING
            BY VALUE LS-ARG-0
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-DISPLAY-DISPATCH.

*> | @brief Resets the global legacy integer handle table and closes any open
*> | handles (useful for clean shutdown and deterministic test isolation).
*> | @return `COBOL_ORM_OK` on success, or first error encountered during cleanup.
*> @module COBOL-ORM-LEGACY-RESET
*> @details Auto-generated COBOL FFI wrapper for C symbol cobol_orm_legacy_reset.
IDENTIFICATION DIVISION.
PROGRAM-ID. COBOL-ORM-LEGACY-RESET.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "cobol_orm.cpy".
LINKAGE SECTION.
*> @record LS-RET FFI scalar return slot.
01 LS-RET USAGE BINARY-LONG SIGNED.
*> @subprogram COBOL-ORM-LEGACY-RESET Invoke C symbol cobol_orm_legacy_reset.
*> @param LS-RET Output return slot.
*> @return Populates LS-RET when non-void and executes GOBACK.
*> @errors Propagates C status via LS-RET; zero STOP RUN.
PROCEDURE DIVISION USING LS-RET.
*> @paragraph MAIN-ENTRY Marshal arguments and invoke C target.
MAIN-ENTRY.
    CALL "cobol_orm_legacy_reset"
        RETURNING LS-RET
    END-CALL
    GOBACK.
END PROGRAM COBOL-ORM-LEGACY-RESET.

