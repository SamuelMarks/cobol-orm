/**
 * @file cobol_orm_internal.h
 * @brief Internal opaque handle structures, magic-tag guards, and shared C89
 * marshaling helpers for cobol-orm.
 */

#ifndef COBOL_ORM_INTERNAL_H
/** @brief Header guard for cobol_orm_internal.h. */
#define COBOL_ORM_INTERNAL_H

/* clang-format off */
#include "cobol_orm_ffi.h"
#include "abstract_struct.h"
#include "c_orm_api.h"
#include "c_orm_ast.h"
#include "c_orm_copybook.h"
#include "c_orm_db.h"
#include "c_orm_db2.h"
#include "c_orm_decimal.h"
#include "c_orm_ebcdic.h"
#include "c_orm_memory.h"
#include "c_orm_migrations.h"
#include "c_orm_odbc.h"
/* clang-format on */

/** @brief Magic tag identifying a live `cobol_orm_db_t` handle. */
#define COBOL_ORM_MAGIC_DB 0x434F4442UL
/** @brief Magic tag identifying a live `cobol_orm_stmt_t` handle. */
#define COBOL_ORM_MAGIC_STMT 0x434F5354UL
/** @brief Magic tag identifying a live `cobol_orm_pool_t` handle. */
#define COBOL_ORM_MAGIC_POOL 0x434F504CUL
/** @brief Magic tag identifying a live `cobol_orm_ast_t` handle. */
#define COBOL_ORM_MAGIC_AST 0x434F4153UL
/** @brief Magic tag identifying a live `cobol_orm_cpy_t` handle. */
#define COBOL_ORM_MAGIC_CPY 0x434F4350UL
/** @brief Magic tag identifying a live `cobol_orm_rs_t` handle. */
#define COBOL_ORM_MAGIC_RS 0x434F5253UL
/** @brief Magic tag identifying a live `cobol_orm_mig_t` handle. */
#define COBOL_ORM_MAGIC_MIG 0x434F4D47UL

/**
 * @brief Internal database handle wrapper.
 */
struct cobol_orm_db {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_DB`) for handle validation. */
  unsigned long magic;
  /** @brief Underlying `c-orm` database session handle. */
  c_orm_db_t *raw;
  /** @brief Non-zero when leased from a pool (skip disconnect on release). */
  int from_pool;
  /** @brief Owned copy of session timezone IANA name, or NULL. */
  char *tz_name;
};

/**
 * @brief Internal prepared statement handle wrapper.
 */
struct cobol_orm_stmt {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_STMT`) for handle validation. */
  unsigned long magic;
  /** @brief Owning database handle. */
  cobol_orm_db_t *db;
  /** @brief Underlying `c-orm` prepared statement handle. */
  c_orm_query_t *raw;
  /** @brief Non-zero if prepared via statement LRU cache. */
  int is_cached;
};

/**
 * @brief Internal connection pool handle wrapper.
 */
struct cobol_orm_pool {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_POOL`) for handle validation. */
  unsigned long magic;
  /** @brief Underlying `c-orm` connection pool. */
  c_orm_pool_t *raw;
};

/**
 * @brief Internal fluent AST query builder handle wrapper.
 */
struct cobol_orm_ast {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_AST`) for handle validation. */
  unsigned long magic;
  /** @brief Underlying `c-orm` fluent AST query handle. */
  c_orm_ast_query_t *raw;
  /** @brief Non-zero once a root `WHERE` predicate has been added. */
  int has_where;
};

/**
 * @brief Internal parsed COBOL Copybook handle wrapper.
 */
struct cobol_orm_cpy {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_CPY`) for handle validation. */
  unsigned long magic;
  /** @brief Underlying parsed `c_orm_cobol_record_t` AST. */
  c_orm_cobol_record_t *rec;
  /** @brief Flattened array of pointers to non-filler elementary fields. */
  const c_orm_cobol_field_t **elem_fields;
  /** @brief Count of entries in `elem_fields`. */
  size_t elem_count;
  /** @brief 0-based index of primary key field in `elem_fields`. */
  size_t pk_index;
};

/**
 * @brief Internal dynamic/abstract result set handle wrapper.
 */
struct cobol_orm_rs {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_RS`) for handle validation. */
  unsigned long magic;
  /** @brief Hydrated `cdd_c_abstract_struct_array_t` rows. */
  cdd_c_abstract_struct_array_t rows;
};

/**
 * @brief Internal schema migration runner handle wrapper.
 */
struct cobol_orm_mig {
  /** @brief Magic tag (`COBOL_ORM_MAGIC_MIG`) for handle validation. */
  unsigned long magic;
  /** @brief Owning database handle. */
  cobol_orm_db_t *db;
  /** @brief Owned directory path string containing `.sql` migrations. */
  char *dir_path;
};

/**
 * @brief Preserves the first non-OK error code across primary and cleanup
 * steps.
 *
 * @param[in] primary Primary operation error code.
 * @param[in] cleanup_rc Cleanup operation error code.
 * @return `primary` when non-OK, otherwise `cleanup_rc`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_keep_err(cobol_orm_error_t primary, cobol_orm_error_t cleanup_rc);

/**
 * @brief Maps a `c_orm_error_t` value into its 1:1 `cobol_orm_error_t` value.
 *
 * @param[in] err Source `c-orm` error code.
 * @return Corresponding `cobol_orm_error_t` code.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_from_c_orm(c_orm_error_t err);

/**
 * @brief Allocates a NUL-terminated C string from a COBOL space-padded `PIC X`
 * buffer, stripping trailing ASCII spaces (`0x20`) and embedded NUL tails.
 *
 * @param[in] buf Source COBOL character buffer.
 * @param[in] len Byte length of `buf`.
 * @param[out] out_str Receives heap-allocated NUL-terminated C string (freed
 * via `c_orm_system_free`).
 * @return `COBOL_ORM_OK`, `COBOL_ORM_ERROR_NULL_POINTER`, or
 * `COBOL_ORM_ERROR_MEMORY`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_picx_to_cstr(const char *buf, cobol_orm_u32_t len, char **out_str);

/**
 * @brief Copies a NUL-terminated C string into a COBOL `PIC X` buffer,
 * space-padding remaining bytes with ASCII `0x20`.
 *
 * @param[in] src Source C string (NULL treated as empty string `""`).
 * @param[out] out_buf Destination COBOL `PIC X` buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives exact unpadded byte length of `src`.
 * @return `COBOL_ORM_OK` on full fit, `COBOL_ORM_ERROR_TRUNCATION` when `src`
 * exceeds `buf_cap`, or `COBOL_ORM_ERROR_NULL_POINTER`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cstr_to_picx(const char *src, char *out_buf, cobol_orm_u32_t buf_cap,
                       cobol_orm_u32_t *out_len);

/**
 * @brief Copies raw binary bytes into a caller buffer with explicit length
 * reporting and truncation detection.
 *
 * @param[in] src Source byte buffer (may be NULL when `src_len == 0`).
 * @param[in] src_len Number of source bytes.
 * @param[out] out_buf Destination byte buffer.
 * @param[in] buf_cap Capacity of `out_buf` in bytes.
 * @param[out] out_len Receives `src_len`.
 * @return `COBOL_ORM_OK`, `COBOL_ORM_ERROR_TRUNCATION`, or
 * `COBOL_ORM_ERROR_NULL_POINTER`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_bytes_to_buf(
    const unsigned char *src, size_t src_len, cobol_orm_u8_t *out_buf,
    cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len);

/**
 * @brief Validates a `cobol_orm_db_t` handle pointer and magic tag.
 *
 * @param[in] db Candidate database handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_check_db(const cobol_orm_db_t *db);

/**
 * @brief Validates a `cobol_orm_stmt_t` handle pointer and magic tag.
 *
 * @param[in] stmt Candidate statement handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_check_stmt(const cobol_orm_stmt_t *stmt);

/**
 * @brief Copies a `cobol_orm_decimal_t` into a `c_orm_decimal_t`.
 *
 * @param[in] src Source `cobol_orm_decimal_t`.
 * @param[out] dst Destination `c_orm_decimal_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_NULL_POINTER`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_to_core(const cobol_orm_decimal_t *src, c_orm_decimal_t *dst);

/**
 * @brief Copies a `c_orm_decimal_t` into a `cobol_orm_decimal_t`.
 *
 * @param[in] src Source `c_orm_decimal_t`.
 * @param[out] dst Destination `cobol_orm_decimal_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_NULL_POINTER`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_from_core(const c_orm_decimal_t *src, cobol_orm_decimal_t *dst);

/**
 * @brief Maps `cobol_orm_codepage_t` to `c_orm_codepage_t`.
 *
 * @param[in] cp Public codepage enum.
 * @param[out] out_cp Receives validated `c_orm_codepage_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_CODEPAGE`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_map_codepage(cobol_orm_codepage_t cp, c_orm_codepage_t *out_cp);

/**
 * @brief Maps `cobol_orm_round_mode_t` to `c_orm_round_mode_t`.
 *
 * @param[in] mode Public rounding mode enum.
 * @param[out] out_mode Receives validated `c_orm_round_mode_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_VALIDATION`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_map_round_mode(
    cobol_orm_round_mode_t mode, c_orm_round_mode_t *out_mode);

/**
 * @brief Maps `cobol_orm_dialect_t` to `c_orm_dialect_t`.
 *
 * @param[in] dialect Public SQL dialect enum.
 * @param[out] out_dialect Receives validated `c_orm_dialect_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_VALIDATION`.
 */
COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_map_dialect(
    cobol_orm_dialect_t dialect, c_orm_dialect_t *out_dialect);

#endif /* COBOL_ORM_INTERNAL_H */
