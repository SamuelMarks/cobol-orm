/**
 * @file cobol_orm_abstract.c
 * @brief Dynamic schema-less SQL query hydration and variant result-set
 * accessors.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

/**
 * @brief Validates a `cobol_orm_rs_t` handle pointer and magic tag.
 *
 * @param[in] rs Candidate result-set handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
check_rs(const cobol_orm_rs_t *rs) {
  if (!rs || rs->magic != COBOL_ORM_MAGIC_RS) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

/**
 * @brief Looks up a named variant column inside `rs` at `row_idx`.
 *
 * @param[in] rs Validated result-set handle.
 * @param[in] row_idx 0-based row index.
 * @param[in] col_name Space-padded column name buffer.
 * @param[in] name_len Length of `col_name` buffer in bytes.
 * @param[out] out_var Receives pointer to matching `cdd_c_variant_t`.
 * @return `COBOL_ORM_OK` on success, or error code if out-of-range/missing.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t lookup_rs_variant(
    cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, const char *col_name,
    cobol_orm_u32_t name_len, cdd_c_variant_t **out_var) {
  char *key_c = NULL;
  cobol_orm_error_t rc = check_rs(rs);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if ((size_t)row_idx >= rs->rows.count) {
    return COBOL_ORM_ERROR_NOT_FOUND;
  }
  rc = cobol_orm_picx_to_cstr(col_name, name_len, &key_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = cdd_c_abstract_get(&rs->rows.items[row_idx], key_c, out_var);
  rc = (crc == C_ORM_ERROR_VALIDATION) ? COBOL_ORM_ERROR_NOT_FOUND
                                       : cobol_orm_from_c_orm(crc);
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(key_c)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_query_abstract(cobol_orm_db_t *db, const char *sql,
                         cobol_orm_u32_t sql_len, cobol_orm_rs_t **out_rs) {
  char *sql_c = NULL;
  cobol_orm_rs_t *handle = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_rs) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_rs = NULL;

  rc = cobol_orm_picx_to_cstr(sql, sql_len, &sql_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_rs_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(sql_c)));
  }

  crc = c_orm_find_all_abstract(db->raw, sql_c, &handle->rows);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(sql_c)));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(rc,
                              cobol_orm_from_c_orm(c_orm_system_free(handle)));
  }

  handle->magic = COBOL_ORM_MAGIC_RS;
  *out_rs = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_rs_row_count(cobol_orm_rs_t *rs, cobol_orm_u32_t *out_count) {
  cobol_orm_error_t rc = check_rs(rs);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_count) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_count = (cobol_orm_u32_t)rs->rows.count;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_rs_col_count(
    cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, cobol_orm_u32_t *out_count) {
  cobol_orm_error_t rc = check_rs(rs);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_count) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  if ((size_t)row_idx >= rs->rows.count) {
    return COBOL_ORM_ERROR_NOT_FOUND;
  }
  *out_count = (cobol_orm_u32_t)rs->rows.items[row_idx].count;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_rs_col_name(
    const cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, cobol_orm_u32_t col_idx,
    char *out_buf, cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  cobol_orm_error_t rc = check_rs(rs);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if ((size_t)row_idx >= rs->rows.count ||
      (size_t)col_idx >= rs->rows.items[row_idx].count) {
    return COBOL_ORM_ERROR_NOT_FOUND;
  }
  return cobol_orm_cstr_to_picx(rs->rows.items[row_idx].kvs[col_idx].key,
                                out_buf, buf_cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_rs_get_type(
    cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, const char *col_name,
    cobol_orm_u32_t name_len, cobol_orm_variant_type_t *out_type) {
  cdd_c_variant_t *var = NULL;
  cobol_orm_error_t rc;

  if (!out_type) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = lookup_rs_variant(rs, row_idx, col_name, name_len, &var);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  *out_type = (cobol_orm_variant_type_t)var->type;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_rs_get_i64(
    cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, const char *col_name,
    cobol_orm_u32_t name_len, cobol_orm_i64_t *out_val) {
  cdd_c_variant_t *var = NULL;
  cobol_orm_error_t rc;

  if (!out_val) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = lookup_rs_variant(rs, row_idx, col_name, name_len, &var);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (var->type != CDD_C_VARIANT_TYPE_INT) {
    return COBOL_ORM_ERROR_TYPE_MISMATCH;
  }
  *out_val = (cobol_orm_i64_t)var->value.i_val;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_rs_get_f64(
    cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, const char *col_name,
    cobol_orm_u32_t name_len, double *out_val) {
  cdd_c_variant_t *var = NULL;
  cobol_orm_error_t rc;

  if (!out_val) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = lookup_rs_variant(rs, row_idx, col_name, name_len, &var);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (var->type != CDD_C_VARIANT_TYPE_FLOAT) {
    return COBOL_ORM_ERROR_TYPE_MISMATCH;
  }
  *out_val = var->value.f_val;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_rs_get_str(
    cobol_orm_rs_t *rs, cobol_orm_u32_t row_idx, const char *col_name,
    cobol_orm_u32_t name_len, char *out_buf, cobol_orm_u32_t buf_cap,
    cobol_orm_u32_t *out_len) {
  cdd_c_variant_t *var = NULL;
  cobol_orm_error_t rc;

  rc = lookup_rs_variant(rs, row_idx, col_name, name_len, &var);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (var->type != CDD_C_VARIANT_TYPE_STRING) {
    return COBOL_ORM_ERROR_TYPE_MISMATCH;
  }
  return cobol_orm_cstr_to_picx(var->value.s_val, out_buf, buf_cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_rs_free(cobol_orm_rs_t *rs) {
  cobol_orm_error_t rc = check_rs(rs);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_abstract_free(&rs->rows);
  rs->magic = 0;
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(rs)));
}
