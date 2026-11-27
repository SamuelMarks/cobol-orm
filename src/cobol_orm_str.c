/**
 * @file cobol_orm_str.c
 * @brief Error-code mapping, handle guards, and bounded COBOL PIC X / binary
 * marshaling helpers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
#include <string.h>
/* clang-format on */

/** @brief Canonical uppercase names indexed by `cobol_orm_error_t`. */
static const char *const k_error_names[] = {"COBOL_ORM_OK",
                                            "COBOL_ORM_ERROR_MEMORY",
                                            "COBOL_ORM_ERROR_CONNECTION",
                                            "COBOL_ORM_ERROR_SQL",
                                            "COBOL_ORM_ERROR_BIND",
                                            "COBOL_ORM_ERROR_STEP",
                                            "COBOL_ORM_ERROR_TYPE_MISMATCH",
                                            "COBOL_ORM_ERROR_NOT_FOUND",
                                            "COBOL_ORM_ERROR_NOT_IMPLEMENTED",
                                            "COBOL_ORM_ERROR_UNKNOWN",
                                            "COBOL_ORM_ERROR_EXPIRED",
                                            "COBOL_ORM_ERROR_VALIDATION",
                                            "COBOL_ORM_ERROR_RECURSION",
                                            "COBOL_ORM_ERROR_READ_ONLY",
                                            "COBOL_ORM_ERROR_NULL_POINTER",
                                            "COBOL_ORM_ERROR_IO",
                                            "COBOL_ORM_ERROR_PARSE",
                                            "COBOL_ORM_ERROR_OVERFLOW",
                                            "COBOL_ORM_ERROR_CYCLE",
                                            "COBOL_ORM_ERROR_BUSY",
                                            "COBOL_ORM_ERROR_CRYPTO",
                                            "COBOL_ORM_ERROR_CONSTRAINT",
                                            "COBOL_ORM_ERROR_DRIVER_LOAD",
                                            "COBOL_ORM_ERROR_ODBC_DIAG",
                                            "COBOL_ORM_ERROR_TIMEOUT",
                                            "COBOL_ORM_ERROR_DEADLOCK",
                                            "COBOL_ORM_ERROR_TRUNCATION",
                                            "COBOL_ORM_ERROR_DECIMAL_SYNTAX",
                                            "COBOL_ORM_ERROR_DECIMAL_OVERFLOW",
                                            "COBOL_ORM_ERROR_DECIMAL_INEXACT",
                                            "COBOL_ORM_ERROR_CODEPAGE",
                                            "COBOL_ORM_ERROR_COPYBOOK_SYNTAX",
                                            "COBOL_ORM_ERROR_INVALID_HANDLE",
                                            "COBOL_ORM_ERROR_BUFFER_TOO_SMALL",
                                            "COBOL_ORM_ERROR_NOT_CONNECTED",
                                            "COBOL_ORM_ERROR_HANDLE_TABLE_FULL",
                                            "COBOL_ORM_ERROR_INVALID_OPCODE"};

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_keep_err(cobol_orm_error_t primary, cobol_orm_error_t cleanup_rc) {
  return (primary != COBOL_ORM_OK) ? primary : cleanup_rc;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_from_c_orm(c_orm_error_t err) {
  int code = (int)err;
  if (code < 0 || code > (int)C_ORM_ERROR_COPYBOOK_SYNTAX) {
    return COBOL_ORM_ERROR_UNKNOWN;
  }
  return (cobol_orm_error_t)code;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_error_name(cobol_orm_error_t err, char *out_buf,
                     cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  int idx = (int)err;
  const char *name;
  size_t count = sizeof(k_error_names) / sizeof(k_error_names[0]);

  if (idx < 0 || (size_t)idx >= count) {
    name = "COBOL_ORM_ERROR_UNKNOWN";
  } else {
    name = k_error_names[idx];
  }
  return cobol_orm_cstr_to_picx(name, out_buf, buf_cap, out_len);
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_picx_to_cstr(const char *buf, cobol_orm_u32_t len, char **out_str) {
  size_t eff_len;
  char *copy;
  c_orm_error_t crc;

  if (!buf || !out_str) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_str = NULL;

  eff_len = 0;
  while (eff_len < (size_t)len && buf[eff_len] != '\0') {
    eff_len++;
  }
  while (eff_len > 0 && buf[eff_len - 1] == ' ') {
    eff_len--;
  }

  crc = c_orm_system_malloc(eff_len + 1, (void **)&copy);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  if (eff_len > 0) {
    memcpy(copy, buf, eff_len);
  }
  copy[eff_len] = '\0';
  *out_str = copy;
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cstr_to_picx(const char *src, char *out_buf, cobol_orm_u32_t buf_cap,
                       cobol_orm_u32_t *out_len) {
  size_t slen;
  size_t copy_n;

  if (!out_buf || !out_len) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  slen = src ? strlen(src) : 0;
  *out_len = (cobol_orm_u32_t)slen;

  if (buf_cap > 0) {
    memset(out_buf, ' ', (size_t)buf_cap);
  }
  copy_n = slen < (size_t)buf_cap ? slen : (size_t)buf_cap;
  if (copy_n > 0) {
    memcpy(out_buf, src, copy_n);
  }
  if (slen > (size_t)buf_cap) {
    return COBOL_ORM_ERROR_TRUNCATION;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_bytes_to_buf(
    const unsigned char *src, size_t src_len, cobol_orm_u8_t *out_buf,
    cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  size_t copy_n;

  if (!out_buf || !out_len || (!src && src_len > 0)) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_len = (cobol_orm_u32_t)src_len;
  copy_n = src_len < (size_t)buf_cap ? src_len : (size_t)buf_cap;
  if (copy_n > 0) {
    memcpy(out_buf, src, copy_n);
  }
  if (src_len > (size_t)buf_cap) {
    return COBOL_ORM_ERROR_TRUNCATION;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_check_db(const cobol_orm_db_t *db) {
  if (!db || db->magic != COBOL_ORM_MAGIC_DB) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_check_stmt(const cobol_orm_stmt_t *stmt) {
  if (!stmt || stmt->magic != COBOL_ORM_MAGIC_STMT) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_to_core(const cobol_orm_decimal_t *src, c_orm_decimal_t *dst) {
  if (!src || !dst) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  dst->sign = src->sign;
  dst->precision = src->precision;
  dst->scale = src->scale;
  memcpy(dst->digits, src->digits, COBOL_ORM_DECIMAL_MAX_DIGITS);
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_from_core(const c_orm_decimal_t *src, cobol_orm_decimal_t *dst) {
  if (!src || !dst) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  dst->sign = src->sign;
  dst->precision = src->precision;
  dst->scale = src->scale;
  memcpy(dst->digits, src->digits, COBOL_ORM_DECIMAL_MAX_DIGITS);
  return COBOL_ORM_OK;
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_map_codepage(cobol_orm_codepage_t cp, c_orm_codepage_t *out_cp) {
  switch (cp) {
  case COBOL_ORM_CP_UTF8:
    *out_cp = C_ORM_CP_UTF8;
    return COBOL_ORM_OK;
  case COBOL_ORM_CP_ASCII:
    *out_cp = C_ORM_CP_ASCII;
    return COBOL_ORM_OK;
  case COBOL_ORM_CP_IBM037:
    *out_cp = C_ORM_CP_IBM037;
    return COBOL_ORM_OK;
  case COBOL_ORM_CP_IBM1047:
    *out_cp = C_ORM_CP_IBM1047;
    return COBOL_ORM_OK;
  case COBOL_ORM_CP_IBM500:
    *out_cp = C_ORM_CP_IBM500;
    return COBOL_ORM_OK;
  case COBOL_ORM_CP_IBM1140:
    *out_cp = C_ORM_CP_IBM1140;
    return COBOL_ORM_OK;
  default:
    return COBOL_ORM_ERROR_CODEPAGE;
  }
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_map_round_mode(
    cobol_orm_round_mode_t mode, c_orm_round_mode_t *out_mode) {
  switch (mode) {
  case COBOL_ORM_ROUND_TRUNCATE:
    *out_mode = C_ORM_ROUND_TRUNCATE;
    return COBOL_ORM_OK;
  case COBOL_ORM_ROUND_HALF_UP:
    *out_mode = C_ORM_ROUND_HALF_UP;
    return COBOL_ORM_OK;
  case COBOL_ORM_ROUND_HALF_EVEN:
    *out_mode = C_ORM_ROUND_HALF_EVEN;
    return COBOL_ORM_OK;
  case COBOL_ORM_ROUND_ERROR_IF_INEXACT:
    *out_mode = C_ORM_ROUND_ERROR_IF_INEXACT;
    return COBOL_ORM_OK;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
}

COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_map_dialect(
    cobol_orm_dialect_t dialect, c_orm_dialect_t *out_dialect) {
  switch (dialect) {
  case COBOL_ORM_DIALECT_SQLITE:
    *out_dialect = C_ORM_DIALECT_SQLITE;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_POSTGRES:
    *out_dialect = C_ORM_DIALECT_POSTGRES;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_MYSQL:
    *out_dialect = C_ORM_DIALECT_MYSQL;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_DB2:
    *out_dialect = C_ORM_DIALECT_DB2;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_ODBC:
    *out_dialect = C_ORM_DIALECT_ODBC;
    return COBOL_ORM_OK;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
}
