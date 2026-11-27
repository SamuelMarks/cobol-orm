/**
 * @file cobol_orm_types.h
 * @brief Strongly-typed opaque handle declarations, domain enumerations, and
 * ABI-aligned POD record structures for cobol-orm.
 */

#ifndef COBOL_ORM_TYPES_H
/** @brief Header guard for cobol_orm_types.h. */
#define COBOL_ORM_TYPES_H

/* clang-format off */
#include "cobol_orm_error.h"
#include "cobol_orm_export.h"
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/** @brief Maximum decimal digits representable in `cobol_orm_decimal_t`. */
#define COBOL_ORM_DECIMAL_MAX_DIGITS 38

/** @brief Fixed payload capacity of a legacy `COMMAREA` request/response. */
#define COBOL_ORM_COMMAREA_DATA_CAP 256

/** @brief Exact byte size of a pure `USAGE DISPLAY` legacy COMMAREA block. */
#define COBOL_ORM_DISPLAY_COMMAREA_SIZE 552

/** @brief Maximum concurrent legacy integer handle registry slots. */
#define COBOL_ORM_LEGACY_MAX_HANDLES 64

/**
 * @brief Opaque database connection handle (distinct strongly-typed struct).
 */
typedef struct cobol_orm_db cobol_orm_db_t;

/**
 * @brief Opaque prepared statement handle (distinct strongly-typed struct).
 */
typedef struct cobol_orm_stmt cobol_orm_stmt_t;

/**
 * @brief Opaque thread-safe connection pool handle.
 */
typedef struct cobol_orm_pool cobol_orm_pool_t;

/**
 * @brief Opaque fluent SQL AST query builder handle.
 */
typedef struct cobol_orm_ast cobol_orm_ast_t;

/**
 * @brief Opaque parsed COBOL Copybook & table-binding handle.
 */
typedef struct cobol_orm_cpy cobol_orm_cpy_t;

/**
 * @brief Opaque dynamic/abstract SQL result set handle.
 */
typedef struct cobol_orm_rs cobol_orm_rs_t;

/**
 * @brief Opaque schema migration runner handle.
 */
typedef struct cobol_orm_mig cobol_orm_mig_t;

/**
 * @brief SQL dialect identifiers for query and DDL generation.
 */
typedef enum cobol_orm_dialect {
  /** @brief SQLite dialect (`?` placeholders, `LIMIT`/`OFFSET`). */
  COBOL_ORM_DIALECT_SQLITE = 0,
  /** @brief PostgreSQL dialect (`$1..$N` placeholders). */
  COBOL_ORM_DIALECT_POSTGRES = 1,
  /** @brief MySQL / MariaDB dialect. */
  COBOL_ORM_DIALECT_MYSQL = 2,
  /** @brief IBM Db2 dialect (`FETCH FIRST`, `MERGE INTO`, `WITH UR/CS/RS/RR`).
   */
  COBOL_ORM_DIALECT_DB2 = 3,
  /** @brief Generic ANSI / ODBC 3.52 dialect. */
  COBOL_ORM_DIALECT_ODBC = 4
} cobol_orm_dialect_t;

/**
 * @brief Rounding modes for lossless 38-digit fixed-point decimal operations.
 */
typedef enum cobol_orm_round_mode {
  /** @brief Truncate toward zero (standard COBOL default). */
  COBOL_ORM_ROUND_TRUNCATE = 0,
  /** @brief Round half away from zero (COBOL `ROUNDED`). */
  COBOL_ORM_ROUND_HALF_UP = 1,
  /** @brief Round half to even (IBM Db2 Banker's rounding). */
  COBOL_ORM_ROUND_HALF_EVEN = 2,
  /** @brief Reject any non-zero discarded digits with `DECIMAL_INEXACT`. */
  COBOL_ORM_ROUND_ERROR_IF_INEXACT = 3
} cobol_orm_round_mode_t;

/**
 * @brief Character codepages and IBM CCSIDs for EBCDIC / mainframe interop.
 */
typedef enum cobol_orm_codepage {
  /** @brief UTF-8 (CCSID 1208). */
  COBOL_ORM_CP_UTF8 = 0,
  /** @brief 7-bit ASCII / ISO-8859-1 (CCSID 367/819). */
  COBOL_ORM_CP_ASCII = 1,
  /** @brief US/Canada z/OS MVS & Db2 EBCDIC (CCSID 37). */
  COBOL_ORM_CP_IBM037 = 2,
  /** @brief z/OS USS C/COBOL EBCDIC (CCSID 1047). */
  COBOL_ORM_CP_IBM1047 = 3,
  /** @brief International EBCDIC (CCSID 500). */
  COBOL_ORM_CP_IBM500 = 4,
  /** @brief US/Canada EBCDIC with Euro U+20AC (CCSID 1140). */
  COBOL_ORM_CP_IBM1140 = 5
} cobol_orm_codepage_t;

/**
 * @brief COBOL Copybook source column layout format.
 */
typedef enum cobol_orm_cpy_format {
  /** @brief Automatically detect fixed vs. free format. */
  COBOL_ORM_CPY_FORMAT_AUTO = 0,
  /** @brief Strict 80-column fixed format (cols 7-72). */
  COBOL_ORM_CPY_FORMAT_FIXED = 1,
  /** @brief Modern COBOL free format. */
  COBOL_ORM_CPY_FORMAT_FREE = 2
} cobol_orm_cpy_format_t;

/**
 * @brief Transaction isolation levels for IBM Db2 and Generic ODBC.
 */
typedef enum cobol_orm_isolation {
  /** @brief Uncommitted Read (`WITH UR`). */
  COBOL_ORM_ISO_UR = 0,
  /** @brief Cursor Stability (`WITH CS`). */
  COBOL_ORM_ISO_CS = 1,
  /** @brief Read Stability (`WITH RS`). */
  COBOL_ORM_ISO_RS = 2,
  /** @brief Repeatable Read (`WITH RR`). */
  COBOL_ORM_ISO_RR = 3
} cobol_orm_isolation_t;

/**
 * @brief Dynamic variant column value discriminants in abstract result sets.
 */
typedef enum cobol_orm_variant_type {
  /** @brief SQL NULL value. */
  COBOL_ORM_VAL_NULL = 0,
  /** @brief 64-bit signed integer value. */
  COBOL_ORM_VAL_INT = 1,
  /** @brief 64-bit IEEE double floating-point value. */
  COBOL_ORM_VAL_FLOAT = 2,
  /** @brief UTF-8 character string value. */
  COBOL_ORM_VAL_STRING = 3,
  /** @brief Raw binary BLOB value. */
  COBOL_ORM_VAL_BLOB = 4,
  /** @brief Exact 38-digit fixed-point decimal value. */
  COBOL_ORM_VAL_DECIMAL = 5
} cobol_orm_variant_type_t;

/**
 * @brief SQL JOIN kinds supported by the fluent AST query builder.
 */
typedef enum cobol_orm_join_type {
  /** @brief INNER JOIN. */
  COBOL_ORM_JOIN_INNER = 0,
  /** @brief LEFT OUTER JOIN. */
  COBOL_ORM_JOIN_LEFT = 1,
  /** @brief RIGHT OUTER JOIN. */
  COBOL_ORM_JOIN_RIGHT = 2
} cobol_orm_join_type_t;

/**
 * @brief Legacy integer-handle COMMAREA dispatcher opcodes for COBOL-60
 * through COBOL-85 programs lacking `USAGE POINTER` or `BY VALUE`.
 */
typedef enum cobol_orm_legacy_op {
  /** @brief Connect database (`data1` = URL, returns `db_id`). */
  COBOL_ORM_OP_CONNECT = 1,
  /** @brief Disconnect database (`db_id`). */
  COBOL_ORM_OP_DISCONNECT = 2,
  /** @brief Execute raw SQL DDL/DML (`db_id`, `data1` = SQL). */
  COBOL_ORM_OP_EXEC_SQL = 3,
  /** @brief Begin transaction (`db_id`). */
  COBOL_ORM_OP_TX_BEGIN = 4,
  /** @brief Commit transaction (`db_id`). */
  COBOL_ORM_OP_TX_COMMIT = 5,
  /** @brief Rollback transaction (`db_id`). */
  COBOL_ORM_OP_TX_ROLLBACK = 6,
  /** @brief Prepare SQL statement (`db_id`, `data1` = SQL, returns `stmt_id`).
   */
  COBOL_ORM_OP_STMT_PREPARE = 7,
  /** @brief Bind 32-bit integer parameter (`stmt_id`, `param_idx`, `val_i32`).
   */
  COBOL_ORM_OP_STMT_BIND_I32 = 8,
  /** @brief Bind text parameter (`stmt_id`, `param_idx`, `data1`). */
  COBOL_ORM_OP_STMT_BIND_STR = 9,
  /** @brief Step prepared statement (`stmt_id`, returns `val_i32` = has_row).
   */
  COBOL_ORM_OP_STMT_STEP = 10,
  /** @brief Read 32-bit int column (`stmt_id`, `param_idx`, returns `val_i32`).
   */
  COBOL_ORM_OP_STMT_COL_I32 = 11,
  /** @brief Read text column (`stmt_id`, `param_idx`, returns `data2`). */
  COBOL_ORM_OP_STMT_COL_STR = 12,
  /** @brief Finalize prepared statement (`stmt_id`). */
  COBOL_ORM_OP_STMT_FINALIZE = 13,
  /** @brief Retrieve last error text (`db_id`, returns `data2`). */
  COBOL_ORM_OP_LAST_ERROR = 14,
  /** @brief Retrieve library version string (returns `data2`). */
  COBOL_ORM_OP_VERSION = 15,
  /** @brief Retrieve last insert rowid (`db_id`, returns `val_i32`). */
  COBOL_ORM_OP_LAST_ROWID = 16
} cobol_orm_legacy_op_t;

/**
 * @brief ABI-identical stack-allocated exact 38-digit fixed-point decimal.
 *
 * Matches `c_orm_decimal_t` byte-for-byte (`41` bytes, alignment `1`).
 */
typedef struct cobol_orm_decimal {
  /** @brief 0 for non-negative, 1 for negative. */
  cobol_orm_u8_t sign;
  /** @brief Active total digits (`1..38`). */
  cobol_orm_u8_t precision;
  /** @brief Fractional digits after decimal point (`0..38`). */
  cobol_orm_u8_t scale;
  /** @brief Little-endian base-10 digits (`0..9`), `digits[0]` is `10^-scale`.
   */
  cobol_orm_u8_t digits[COBOL_ORM_DECIMAL_MAX_DIGITS];
} cobol_orm_decimal_t;

/**
 * @brief Connection pool telemetry snapshot with explicit fixed-width fields.
 */
typedef struct cobol_orm_pool_stats {
  /** @brief Currently leased active connections. */
  cobol_orm_u32_t active_connections;
  /** @brief Currently available idle connections. */
  cobol_orm_u32_t idle_connections;
  /** @brief Total pool exhaustion / timeout events recorded. */
  cobol_orm_u32_t exhaustion_count;
  /** @brief Total slow queries logged across pooled sessions. */
  cobol_orm_u32_t slow_queries_logged;
  /** @brief Average acquisition wait latency in milliseconds. */
  double average_wait_time_ms;
} cobol_orm_pool_stats_t;

/**
 * @brief Summary metadata for a parsed COBOL Copybook `01` record.
 */
typedef struct cobol_orm_cpy_info {
  /** @brief Total static wire byte length of the `01` record. */
  cobol_orm_u32_t total_byte_size;
  /** @brief Number of flattened elementary/SQL-mapped fields. */
  cobol_orm_u32_t field_count;
  /** @brief Non-zero if an `EXEC SQL DECLARE` DCLGEN block was parsed. */
  cobol_orm_i32_t has_dclgen;
} cobol_orm_cpy_info_t;

/**
 * @brief Metadata descriptor for a single field within a parsed Copybook.
 */
typedef struct cobol_orm_col_info {
  /** @brief 0-based byte offset inside the COBOL `01` wire record. */
  cobol_orm_u32_t byte_offset;
  /** @brief Total wire byte length of the field. */
  cobol_orm_u32_t byte_size;
  /** @brief COBOL `USAGE` kind (0=DISPLAY, 1=COMP, 2=COMP-5, 5=COMP-3). */
  cobol_orm_i32_t usage;
  /** @brief Total numeric precision digits (`0` for alphanumeric). */
  cobol_orm_u8_t total_digits;
  /** @brief Fractional digits after implied `V` (`0` for integer/alpha). */
  cobol_orm_u8_t frac_digits;
  /** @brief Non-zero if numeric field is signed (`PIC S9`). */
  cobol_orm_u8_t is_signed;
  /** @brief Non-zero if field is marked as primary key. */
  cobol_orm_u8_t is_pk;
} cobol_orm_col_info_t;

/**
 * @brief Fixed-width communication area (`COMMAREA`) for legacy COBOL-60
 * through COBOL-85 callers invoking ORM operations via a single `BY REFERENCE`
 * block using integer handle IDs and space-padded `PIC X` payloads.
 */
typedef struct cobol_orm_commarea {
  /** @brief Operation code (`cobol_orm_legacy_op_t`). */
  cobol_orm_i32_t opcode;
  /** @brief Output status code (`cobol_orm_error_t`). */
  cobol_orm_i32_t status;
  /** @brief Integer database handle slot ID (`1..64`, or `0`). */
  cobol_orm_i32_t db_id;
  /** @brief Integer statement handle slot ID (`1..64`, or `0`). */
  cobol_orm_i32_t stmt_id;
  /** @brief 1-based parameter or 0-based column index. */
  cobol_orm_i32_t param_idx;
  /** @brief Input or output 32-bit signed integer value / boolean flag. */
  cobol_orm_i32_t val_i32;
  /** @brief Length of active data in `data1` (0 to auto-trim spaces). */
  cobol_orm_u32_t data1_len;
  /** @brief Output byte length written to `data2`. */
  cobol_orm_u32_t data2_len;
  /** @brief Space-padded input string buffer (URL, SQL, bind text). */
  char data1[COBOL_ORM_COMMAREA_DATA_CAP];
  /** @brief Space-padded output string buffer (column text, error, version). */
  char data2[COBOL_ORM_COMMAREA_DATA_CAP];
} cobol_orm_commarea_t;

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* COBOL_ORM_TYPES_H */
