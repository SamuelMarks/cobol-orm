/**
 * @file cobol_orm_stmt.c
 * @brief Prepared statements, typed parameter binding (including direct COBOL
 * COMP-3 packed decimal), execution stepping, and typed column extraction.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

/**
 * @brief Shared helper preparing either a direct or LRU-cached statement.
 *
 * @param[in] db Active database handle.
 * @param[in] sql Space-padded SQL text buffer.
 * @param[in] sql_len Length of `sql` buffer in bytes.
 * @param[in] cached Non-zero to use `c_orm_prepare_cached`.
 * @param[out] out_stmt Receives allocated statement handle.
 * @return `COBOL_ORM_OK` on success, or error code on failure.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
prepare_impl(cobol_orm_db_t *db, const char *sql, cobol_orm_u32_t sql_len,
             int cached, cobol_orm_stmt_t **out_stmt) {
  char *sql_c = NULL;
  cobol_orm_stmt_t *handle = NULL;
  c_orm_query_t *raw = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_stmt) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_stmt = NULL;

  rc = cobol_orm_picx_to_cstr(sql, sql_len, &sql_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_stmt_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(sql_c)));
  }

  if (cached) {
    crc = c_orm_prepare_cached(db->raw, sql_c, &raw);
  } else {
    crc = db->raw->vtable->prepare(db->raw, sql_c, &raw);
  }
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(sql_c)));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(rc,
                              cobol_orm_from_c_orm(c_orm_system_free(handle)));
  }

  handle->magic = COBOL_ORM_MAGIC_STMT;
  handle->db = db;
  handle->raw = raw;
  handle->is_cached = cached;
  *out_stmt = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_prepare(cobol_orm_db_t *db, const char *sql,
                       cobol_orm_u32_t sql_len, cobol_orm_stmt_t **out_stmt) {
  return prepare_impl(db, sql, sql_len, 0, out_stmt);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_prepare_cached(cobol_orm_db_t *db, const char *sql,
                              cobol_orm_u32_t sql_len,
                              cobol_orm_stmt_t **out_stmt) {
  return prepare_impl(db, sql, sql_len, 1, out_stmt);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_bind_i32(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, cobol_orm_i32_t val) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      stmt->db->raw->vtable->bind_int32(stmt->raw, (int)idx, (int32_t)val));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_bind_i64(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, cobol_orm_i64_t val) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      stmt->db->raw->vtable->bind_int64(stmt->raw, (int)idx, (int64_t)val));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_bind_f64(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, double val) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      stmt->db->raw->vtable->bind_double(stmt->raw, (int)idx, val));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_bind_str(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                        const char *val, cobol_orm_u32_t val_len) {
  char *val_c = NULL;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(val, val_len, &val_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = stmt->db->raw->vtable->bind_string(stmt->raw, (int)idx, val_c);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(val_c)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_bind_blob(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                         const cobol_orm_u8_t *data, cobol_orm_u32_t data_len) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!data && data_len > 0) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  return cobol_orm_from_c_orm(stmt->db->raw->vtable->bind_blob(
      stmt->raw, (int)idx, data, (size_t)data_len));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_bind_decimal(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                            const cobol_orm_decimal_t *dec) {
  c_orm_decimal_t core;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_dec_to_core(dec, &core);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      stmt->db->raw->vtable->bind_decimal(stmt->raw, (int)idx, &core));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_bind_comp3(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                          const cobol_orm_u8_t *comp3, cobol_orm_u32_t byte_len,
                          cobol_orm_u8_t frac_digits) {
  c_orm_decimal_t core;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_from_comp3(comp3, (size_t)byte_len, frac_digits, &core);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_from_c_orm(
      stmt->db->raw->vtable->bind_decimal(stmt->raw, (int)idx, &core));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_bind_null(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      stmt->db->raw->vtable->bind_null(stmt->raw, (int)idx));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_step(cobol_orm_stmt_t *stmt, cobol_orm_i32_t *out_has_row) {
  int has_row = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_has_row) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->step(stmt->raw, &has_row);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_has_row = (cobol_orm_i32_t)has_row;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_reset(cobol_orm_stmt_t *stmt) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(stmt->db->raw->vtable->reset(stmt->raw));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_finalize(cobol_orm_stmt_t *stmt) {
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (stmt->is_cached) {
    crc = c_orm_finalize_cached(stmt->db->raw, stmt->raw);
  } else {
    crc = stmt->db->raw->vtable->finalize(stmt->raw);
  }
  stmt->magic = 0;
  stmt->raw = NULL;
  stmt->db = NULL;
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(stmt)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_col_count(cobol_orm_stmt_t *stmt, cobol_orm_i32_t *out_count) {
  int cnt = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_count) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->get_column_count(stmt->raw, &cnt);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_count = (cobol_orm_i32_t)cnt;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_col_name(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, char *out_buf,
    cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  const char *name = NULL;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = stmt->db->raw->vtable->get_column_name(stmt->raw, (int)idx, &name);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_cstr_to_picx(name, out_buf, buf_cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_col_is_null(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                           cobol_orm_i32_t *out_is_null) {
  int is_null = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_is_null) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->is_null(stmt->raw, (int)idx, &is_null);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_is_null = (cobol_orm_i32_t)is_null;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_col_i32(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, cobol_orm_i32_t *out_val) {
  int32_t val = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->get_int32(stmt->raw, (int)idx, &val);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_val = (cobol_orm_i32_t)val;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_col_i64(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, cobol_orm_i64_t *out_val) {
  int64_t val = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->get_int64(stmt->raw, (int)idx, &val);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_val = (cobol_orm_i64_t)val;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_col_f64(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, double *out_val) {
  double val = 0.0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_val) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->get_double(stmt->raw, (int)idx, &val);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_val = val;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_col_str(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, char *out_buf,
    cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  const char *val = NULL;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = stmt->db->raw->vtable->get_string(stmt->raw, (int)idx, &val);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_cstr_to_picx(val, out_buf, buf_cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_stmt_col_blob(
    cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx, cobol_orm_u8_t *out_buf,
    cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  const void *data = NULL;
  size_t data_len = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = stmt->db->raw->vtable->get_blob(stmt->raw, (int)idx, &data, &data_len);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_bytes_to_buf((const unsigned char *)data, data_len, out_buf,
                                buf_cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_col_decimal(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                           cobol_orm_decimal_t *out_dec) {
  c_orm_decimal_t core;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_dec) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = stmt->db->raw->vtable->get_decimal(stmt->raw, (int)idx, &core);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&core, out_dec);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_stmt_col_comp3(cobol_orm_stmt_t *stmt, cobol_orm_i32_t idx,
                         cobol_orm_u8_t int_digits, cobol_orm_u8_t frac_digits,
                         cobol_orm_i32_t is_signed,
                         cobol_orm_round_mode_t round_mode,
                         cobol_orm_u8_t *out_comp3, cobol_orm_u32_t buf_cap,
                         cobol_orm_u32_t *out_written) {
  c_orm_decimal_t core;
  c_orm_decimal_t scaled;
  c_orm_round_mode_t rmode;
  size_t written = 0;
  cobol_orm_error_t rc = cobol_orm_check_stmt(stmt);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_comp3 || !out_written) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_map_round_mode(round_mode, &rmode);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = stmt->db->raw->vtable->get_decimal(stmt->raw, (int)idx, &core);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_decimal_rescale(&core, (unsigned char)(int_digits + frac_digits),
                              frac_digits, rmode, &scaled);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_decimal_to_comp3(&scaled, int_digits, frac_digits, (int)is_signed,
                               out_comp3, (size_t)buf_cap, &written);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_written = (cobol_orm_u32_t)written;
  return COBOL_ORM_OK;
}
