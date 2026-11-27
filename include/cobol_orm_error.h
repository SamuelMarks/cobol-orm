/**
 * @file cobol_orm_error.h
 * @brief Unified error status enumeration percolated across all cobol-orm C89
 * and COBOL FFI entry points.
 */

#ifndef COBOL_ORM_ERROR_H
/** @brief Header guard for cobol_orm_error.h. */
#define COBOL_ORM_ERROR_H

/* clang-format off */
#include "cobol_orm_export.h"
/* clang-format on */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/**
 * @brief Unified error status codes returned by every cobol-orm function.
 *
 * Values 0..31 match `c_orm_error_t` 1:1 for lossless error percolation across
 * the C89 and COBOL FFI boundary. Values 32..36 represent COBOL FFI facade and
 * legacy integer-handle / COMMAREA dispatch errors.
 */
typedef enum cobol_orm_error {
  /** @brief Operation succeeded. */
  COBOL_ORM_OK = 0,
  /** @brief Out of memory / allocation failure. */
  COBOL_ORM_ERROR_MEMORY = 1,
  /** @brief Database connection failure. */
  COBOL_ORM_ERROR_CONNECTION = 2,
  /** @brief SQL syntax or execution error. */
  COBOL_ORM_ERROR_SQL = 3,
  /** @brief Statement parameter bind failure. */
  COBOL_ORM_ERROR_BIND = 4,
  /** @brief Statement step execution failure. */
  COBOL_ORM_ERROR_STEP = 5,
  /** @brief Column or value type mismatch. */
  COBOL_ORM_ERROR_TYPE_MISMATCH = 6,
  /** @brief Requested row, column, or handle not found. */
  COBOL_ORM_ERROR_NOT_FOUND = 7,
  /** @brief Feature or driver capability not implemented. */
  COBOL_ORM_ERROR_NOT_IMPLEMENTED = 8,
  /** @brief Unclassified internal error. */
  COBOL_ORM_ERROR_UNKNOWN = 9,
  /** @brief Session or identity-map record expired. */
  COBOL_ORM_ERROR_EXPIRED = 10,
  /** @brief Invalid argument or domain/level-88 validation failure. */
  COBOL_ORM_ERROR_VALIDATION = 11,
  /** @brief Cyclic recursion limit exceeded. */
  COBOL_ORM_ERROR_RECURSION = 12,
  /** @brief Write attempted on read-only database or resource. */
  COBOL_ORM_ERROR_READ_ONLY = 13,
  /** @brief Required pointer argument was NULL. */
  COBOL_ORM_ERROR_NULL_POINTER = 14,
  /** @brief File or stream I/O failure. */
  COBOL_ORM_ERROR_IO = 15,
  /** @brief Input or SQL parse failure. */
  COBOL_ORM_ERROR_PARSE = 16,
  /** @brief Buffer or integer capacity overflow. */
  COBOL_ORM_ERROR_OVERFLOW = 17,
  /** @brief Dependency cycle detected. */
  COBOL_ORM_ERROR_CYCLE = 18,
  /** @brief Database or synchronization lock busy. */
  COBOL_ORM_ERROR_BUSY = 19,
  /** @brief Cryptographic hook failure. */
  COBOL_ORM_ERROR_CRYPTO = 20,
  /** @brief Unique, foreign-key, or CHECK constraint violation. */
  COBOL_ORM_ERROR_CONSTRAINT = 21,
  /** @brief Dynamic database client library failed to load. */
  COBOL_ORM_ERROR_DRIVER_LOAD = 22,
  /** @brief Underlying ODBC or IBM Db2 CLI diagnostic error. */
  COBOL_ORM_ERROR_ODBC_DIAG = 23,
  /** @brief Login, pool acquisition, or query timeout. */
  COBOL_ORM_ERROR_TIMEOUT = 24,
  /** @brief Serialization failure or deadlock victim. */
  COBOL_ORM_ERROR_DEADLOCK = 25,
  /** @brief Disallowed string, binary, or fractional truncation. */
  COBOL_ORM_ERROR_TRUNCATION = 26,
  /** @brief Malformed decimal string or invalid BCD/COMP-3 sign nybble. */
  COBOL_ORM_ERROR_DECIMAL_SYNTAX = 27,
  /** @brief Decimal precision exceeded or division by zero. */
  COBOL_ORM_ERROR_DECIMAL_OVERFLOW = 28,
  /** @brief Non-zero digits lost under exact rounding mode. */
  COBOL_ORM_ERROR_DECIMAL_INEXACT = 29,
  /** @brief Unmappable character or malformed UTF/EBCDIC sequence. */
  COBOL_ORM_ERROR_CODEPAGE = 30,
  /** @brief COBOL Copybook (.cpy) lexer or parser syntax error. */
  COBOL_ORM_ERROR_COPYBOOK_SYNTAX = 31,
  /** @brief Opaque handle is invalid, corrupted, or already closed. */
  COBOL_ORM_ERROR_INVALID_HANDLE = 32,
  /** @brief Caller-provided output buffer capacity is insufficient. */
  COBOL_ORM_ERROR_BUFFER_TOO_SMALL = 33,
  /** @brief Operation requires an active database connection. */
  COBOL_ORM_ERROR_NOT_CONNECTED = 34,
  /** @brief Legacy integer handle registry has no free slots available. */
  COBOL_ORM_ERROR_HANDLE_TABLE_FULL = 35,
  /** @brief Unsupported legacy COMMAREA dispatch opcode. */
  COBOL_ORM_ERROR_INVALID_OPCODE = 36
} cobol_orm_error_t;

/**
 * @brief Resolves a `cobol_orm_error_t` code to its canonical uppercase name
 * into a COBOL `PIC X` space-padded buffer.
 *
 * @param[in] err Error status code to describe.
 * @param[out] out_buf Caller-allocated character buffer receiving space-padded
 * name.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives exact unpadded byte length of the error name.
 * @return `COBOL_ORM_OK` on success, `COBOL_ORM_ERROR_NULL_POINTER` if
 * `out_buf` or `out_len` is NULL, or `COBOL_ORM_ERROR_TRUNCATION` if `buf_cap`
 * is smaller than the name length.
 */
COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_error_name(cobol_orm_error_t err, char *out_buf,
                     cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* COBOL_ORM_ERROR_H */
