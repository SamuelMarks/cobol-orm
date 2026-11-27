/**
 * @file cobol_orm_copybook.c
 * @brief COBOL Copybook (.cpy / DCLGEN) parser, metadata introspection, DDL
 * generation, level-88 domain validation, and direct Copybook-driven COBOL
 * 01-record ORM CRUD bridge.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
#include "c_orm_string_builder.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* clang-format on */

/**
 * @brief Validates a `cobol_orm_cpy_t` handle pointer and magic tag.
 *
 * @param[in] cpy Candidate Copybook handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
check_cpy(const cobol_orm_cpy_t *cpy) {
  if (!cpy || cpy->magic != COBOL_ORM_MAGIC_CPY) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

/**
 * @brief Appends `text` to `sb` only when `*io_crc == C_ORM_OK`.
 *
 * @param[in,out] sb String builder instance.
 * @param[in] text NUL-terminated string to append.
 * @param[in,out] io_crc Accumulated `c-orm` status code.
 * @return Mapped `cobol_orm_error_t` matching `*io_crc`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t sb_append_if_ok(
    c_orm_string_builder_t *sb, const char *text, c_orm_error_t *io_crc) {
  if (*io_crc == C_ORM_OK) {
    *io_crc = c_orm_string_builder_append(sb, text);
  }
  return cobol_orm_from_c_orm(*io_crc);
}

/**
 * @brief Maps `cobol_orm_cpy_format_t` to `c_orm_cobol_format_t`.
 *
 * @param[in] fmt Public format enum.
 * @param[out] out_fmt Receives `c_orm_cobol_format_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_VALIDATION`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
map_cpy_format(cobol_orm_cpy_format_t fmt, c_orm_cobol_format_t *out_fmt) {
  switch (fmt) {
  case COBOL_ORM_CPY_FORMAT_AUTO:
    *out_fmt = C_ORM_COBOL_FORMAT_AUTO;
    return COBOL_ORM_OK;
  case COBOL_ORM_CPY_FORMAT_FIXED:
    *out_fmt = C_ORM_COBOL_FORMAT_FIXED;
    return COBOL_ORM_OK;
  case COBOL_ORM_CPY_FORMAT_FREE:
    *out_fmt = C_ORM_COBOL_FORMAT_FREE;
    return COBOL_ORM_OK;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
}

/**
 * @brief Maps `cobol_orm_dialect_t` to `c_to_sql_dialect_t`.
 *
 * @param[in] dialect Public dialect enum.
 * @param[out] out_d Receives `c_to_sql_dialect_t`.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_VALIDATION`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
map_ddl_dialect(cobol_orm_dialect_t dialect, c_to_sql_dialect_t *out_d) {
  switch (dialect) {
  case COBOL_ORM_DIALECT_SQLITE:
    *out_d = C_TO_SQL_DIALECT_SQLITE;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_POSTGRES:
    *out_d = C_TO_SQL_DIALECT_POSTGRESQL;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_MYSQL:
    *out_d = C_TO_SQL_DIALECT_MYSQL;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_DB2:
    *out_d = C_TO_SQL_DIALECT_DB2;
    return COBOL_ORM_OK;
  case COBOL_ORM_DIALECT_ODBC:
    *out_d = C_TO_SQL_DIALECT_ODBC;
    return COBOL_ORM_OK;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
}

/**
 * @brief Case-insensitive ASCII string equality helper.
 *
 * @param[in] a First NUL-terminated string.
 * @param[in] b Second NUL-terminated string.
 * @param[out] out_eq Set to 1 if equal, 0 otherwise.
 * @return `COBOL_ORM_OK`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t str_eq_ci(const char *a,
                                                        const char *b,
                                                        int *out_eq) {
  size_t i = 0;
  *out_eq = 0;
  while (a[i] != '\0' && b[i] != '\0') {
    if (tolower((unsigned char)a[i]) != tolower((unsigned char)b[i])) {
      return COBOL_ORM_OK;
    }
    i++;
  }
  *out_eq = (a[i] == '\0' && b[i] == '\0') ? 1 : 0;
  return COBOL_ORM_OK;
}

/**
 * @brief Recursively counts or collects non-filler, non-REDEFINES elementary
 * fields from a COBOL field tree.
 *
 * @param[in] fields Field array.
 * @param[in] count Number of elements in `fields`.
 * @param[out] out_list Optional flat output array (NULL when counting only).
 * @param[in,out] io_idx Running index / count accumulator.
 * @return `COBOL_ORM_OK`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
collect_elem_fields(const c_orm_cobol_field_t *fields, size_t count,
                    const c_orm_cobol_field_t **out_list, size_t *io_idx) {
  size_t i;
  cobol_orm_error_t rc = COBOL_ORM_OK;
  for (i = 0; i < count; i++) {
    const c_orm_cobol_field_t *f = &fields[i];
    if (f->is_filler || f->redefines_name != NULL || f->level == 66) {
      continue;
    }
    if (f->num_children > 0 && !f->is_dclgen_varchar) {
      rc = cobol_orm_keep_err(
          rc,
          collect_elem_fields(f->children, f->num_children, out_list, io_idx));
    } else {
      if (out_list) {
        out_list[*io_idx] = f;
      }
      (*io_idx)++;
    }
  }
  return rc;
}

/**
 * @brief Wraps a parsed `c_orm_cobol_record_t` into a `cobol_orm_cpy_t` handle
 * with flattened elementary field metadata and default PK resolution.
 *
 * @param[in] rec Ownership-transferred `c_orm_cobol_record_t`.
 * @param[out] out_cpy Receives allocated Copybook handle.
 * @return `COBOL_ORM_OK` on success, or error code on OOM.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
wrap_cpy_record(c_orm_cobol_record_t *rec, cobol_orm_cpy_t **out_cpy) {
  cobol_orm_cpy_t *handle = NULL;
  size_t count = 0;
  size_t i;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_cpy_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(
        cobol_orm_from_c_orm(crc),
        cobol_orm_from_c_orm(c_orm_copybook_record_free(rec)));
  }

  rc = collect_elem_fields(rec->fields, rec->num_fields, NULL, &count);
  if (count > 0) {
    crc = c_orm_system_calloc(count, sizeof(const c_orm_cobol_field_t *),
                              (void **)&handle->elem_fields);
    if (crc != C_ORM_OK) {
      rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
    } else {
      size_t idx = 0;
      rc = cobol_orm_keep_err(rc,
                              collect_elem_fields(rec->fields, rec->num_fields,
                                                  handle->elem_fields, &idx));
      handle->elem_count = idx;
    }
  }
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(
        rc, cobol_orm_keep_err(
                cobol_orm_from_c_orm(c_orm_copybook_record_free(rec)),
                cobol_orm_from_c_orm(c_orm_system_free(handle))));
  }

  handle->magic = COBOL_ORM_MAGIC_CPY;
  handle->rec = rec;
  handle->pk_index = 0;
  for (i = 0; i < handle->elem_count; i++) {
    if (handle->elem_fields[i]->sql_is_pk) {
      handle->pk_index = i;
      break;
    }
  }
  *out_cpy = handle;
  return COBOL_ORM_OK;
}

/**
 * @brief Binds a single `cdd_c_variant_t` onto a prepared statement at 1-based
 * `idx`.
 *
 * @param[in] db Underlying `c-orm` DB handle.
 * @param[in] q Underlying prepared statement.
 * @param[in] idx 1-based parameter index.
 * @param[in] var Variant value to bind.
 * @return `COBOL_ORM_OK` on success, or error code on bind failure.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t bind_variant_param(
    c_orm_db_t *db, c_orm_query_t *q, int idx, const cdd_c_variant_t *var) {
  if (var->type == CDD_C_VARIANT_TYPE_INT) {
    return cobol_orm_from_c_orm(
        db->vtable->bind_int64(q, idx, (int64_t)var->value.i_val));
  }
  if (var->type == CDD_C_VARIANT_TYPE_FLOAT) {
    return cobol_orm_from_c_orm(
        db->vtable->bind_double(q, idx, var->value.f_val));
  }
  if (var->type == CDD_C_VARIANT_TYPE_STRING) {
    return cobol_orm_from_c_orm(
        db->vtable->bind_string(q, idx, var->value.s_val));
  }
  if (var->type == CDD_C_VARIANT_TYPE_DECIMAL) {
    return cobol_orm_from_c_orm(
        db->vtable->bind_decimal(q, idx, &var->value.d_val));
  }
  return cobol_orm_from_c_orm(db->vtable->bind_blob(
      q, idx, var->value.b_val.data, var->value.b_val.size));
}

/**
 * @brief Hydrates the current row of statement `q` into a
 * `cdd_c_abstract_struct_t` keyed by `f->c_name` for every field in `cpy`.
 *
 * @param[in] db Underlying `c-orm` DB handle.
 * @param[in] q Stepped prepared statement positioned on a row.
 * @param[in] cpy Copybook handle defining expected field types.
 * @param[out] out_abs Initialized abstract struct to populate.
 * @return `COBOL_ORM_OK` on success, or error code on failure.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t hydrate_row_for_cpy(
    c_orm_db_t *db, c_orm_query_t *q, const cobol_orm_cpy_t *cpy,
    cdd_c_abstract_struct_t *out_abs) {
  size_t i;
  cobol_orm_error_t rc = COBOL_ORM_OK;
  for (i = 0; i < cpy->elem_count; i++) {
    const c_orm_cobol_field_t *f = cpy->elem_fields[i];
    cdd_c_variant_t var;
    int is_null = 0;
    c_orm_error_t crc;

    memset(&var, 0, sizeof(var));
    crc = db->vtable->is_null(q, (int)i, &is_null);
    if (crc != C_ORM_OK) {
      return cobol_orm_from_c_orm(crc);
    }
    if (is_null) {
      var.type = CDD_C_VARIANT_TYPE_NULL;
    } else if (f->pic_category == C_ORM_COBOL_PIC_NUMERIC &&
               (f->usage == C_ORM_COBOL_USAGE_COMP_3 || f->frac_digits > 0)) {
      var.type = CDD_C_VARIANT_TYPE_DECIMAL;
      crc = db->vtable->get_decimal(q, (int)i, &var.value.d_val);
    } else if (f->pic_category == C_ORM_COBOL_PIC_NUMERIC) {
      int64_t iv = 0;
      var.type = CDD_C_VARIANT_TYPE_INT;
      crc = db->vtable->get_int64(q, (int)i, &iv);
      var.value.i_val = (c_orm_int64_t)iv;
    } else if (f->usage == C_ORM_COBOL_USAGE_COMP_1 ||
               f->usage == C_ORM_COBOL_USAGE_COMP_2) {
      var.type = CDD_C_VARIANT_TYPE_FLOAT;
      crc = db->vtable->get_double(q, (int)i, &var.value.f_val);
    } else if (f->sql_for_bit_data) {
      const void *bv = NULL;
      size_t blen = 0;
      var.type = CDD_C_VARIANT_TYPE_BLOB;
      crc = db->vtable->get_blob(q, (int)i, &bv, &blen);
      if (crc == C_ORM_OK) {
        crc = c_orm_system_malloc(blen + 1, (void **)&var.value.b_val.data);
        if (crc == C_ORM_OK) {
          if (blen > 0) {
            memcpy(var.value.b_val.data, bv, blen);
          }
          var.value.b_val.size = blen;
        }
      }
    } else {
      const char *sv = NULL;
      var.type = CDD_C_VARIANT_TYPE_STRING;
      crc = db->vtable->get_string(q, (int)i, &sv);
      if (crc == C_ORM_OK) {
        size_t slen = strlen(sv);
        crc = c_orm_system_malloc(slen + 1, (void **)&var.value.s_val);
        if (crc == C_ORM_OK) {
          memcpy(var.value.s_val, sv, slen + 1);
        }
      }
    }
    if (crc != C_ORM_OK) {
      return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                                cobol_orm_from_c_orm(cdd_c_variant_free(&var)));
    }
    crc = cdd_c_abstract_set(out_abs, f->c_name, &var);
    if (crc != C_ORM_OK) {
      return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                                cobol_orm_from_c_orm(cdd_c_variant_free(&var)));
    }
    rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(cdd_c_variant_free(&var)));
  }
  return rc;
}

/**
 * @brief Validates all level-`88` conditions declared on `cpy` against an
 * unpacked `cdd_c_abstract_struct_t`.
 *
 * @param[in] cpy Copybook handle.
 * @param[in] abs_row Unpacked abstract row dictionary.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_VALIDATION` on violation.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t validate_88_abstract(
    const cobol_orm_cpy_t *cpy, const cdd_c_abstract_struct_t *abs_row) {
  size_t i;
  cobol_orm_error_t rc = COBOL_ORM_OK;
  for (i = 0; i < cpy->elem_count; i++) {
    const c_orm_cobol_field_t *f = cpy->elem_fields[i];
    cdd_c_variant_t *var = NULL;
    size_t ci;
    int matched = 0;
    c_orm_error_t crc;

    if (f->num_conditions == 0) {
      continue;
    }
    crc = cdd_c_abstract_get(abs_row, f->c_name, &var);
    rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
    for (ci = 0; ci < f->num_conditions && !matched; ci++) {
      const c_orm_cobol_condition_t *cond = &f->conditions[ci];
      size_t vi;
      for (vi = 0; vi < cond->num_values && !matched; vi++) {
        const c_orm_cobol_value_range_t *vr = &cond->values[vi];
        if (vr->is_numeric && var->type == CDD_C_VARIANT_TYPE_INT) {
          long lo = strtol(vr->low_val, NULL, 10);
          long hi = vr->is_range ? strtol(vr->high_val, NULL, 10) : lo;
          long actual = (long)var->value.i_val;
          if (actual >= lo && actual <= hi) {
            matched = 1;
          }
        } else if (var->type == CDD_C_VARIANT_TYPE_STRING) {
          if (vr->is_range) {
            if (strcmp(var->value.s_val, vr->low_val) >= 0 &&
                strcmp(var->value.s_val, vr->high_val) <= 0) {
              matched = 1;
            }
          } else if (strcmp(var->value.s_val, vr->low_val) == 0) {
            matched = 1;
          }
        }
      }
    }
    if (!matched) {
      return COBOL_ORM_ERROR_VALIDATION;
    }
  }
  return rc;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_parse_str(const char *src, cobol_orm_u32_t src_len,
                        cobol_orm_cpy_format_t fmt, cobol_orm_cpy_t **out_cpy) {
  c_orm_cobol_format_t core_fmt;
  char *src_c = NULL;
  c_orm_cobol_record_t *rec = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!src || !out_cpy) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_cpy = NULL;
  rc = map_cpy_format(fmt, &core_fmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(src, src_len, &src_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_copybook_parse_string(src_c, core_fmt, NULL, 0, &rec);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(src_c)));
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return wrap_cpy_record(rec, out_cpy);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_parse_file(const char *path, cobol_orm_u32_t path_len,
                         cobol_orm_cpy_format_t fmt,
                         cobol_orm_cpy_t **out_cpy) {
  c_orm_cobol_format_t core_fmt;
  char *path_c = NULL;
  c_orm_cobol_record_t *rec = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!path || !out_cpy) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_cpy = NULL;
  rc = map_cpy_format(fmt, &core_fmt);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(path, path_len, &path_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_copybook_parse_file(path_c, core_fmt, NULL, 0, &rec);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(path_c)));
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return wrap_cpy_record(rec, out_cpy);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_info(cobol_orm_cpy_t *cpy, cobol_orm_cpy_info_t *out_info) {
  cobol_orm_error_t rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_info) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  out_info->total_byte_size = (cobol_orm_u32_t)cpy->rec->total_byte_size;
  out_info->field_count = (cobol_orm_u32_t)cpy->elem_count;
  out_info->has_dclgen = (cobol_orm_i32_t)cpy->rec->has_exec_sql_declare;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_field_info(cobol_orm_cpy_t *cpy, cobol_orm_u32_t field_idx,
                         cobol_orm_col_info_t *out_col) {
  const c_orm_cobol_field_t *f;
  cobol_orm_error_t rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_col) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  if ((size_t)field_idx >= cpy->elem_count) {
    return COBOL_ORM_ERROR_NOT_FOUND;
  }
  f = cpy->elem_fields[field_idx];
  out_col->byte_offset = (cobol_orm_u32_t)f->byte_offset;
  out_col->byte_size = (cobol_orm_u32_t)f->total_byte_size;
  out_col->usage = (cobol_orm_i32_t)f->usage;
  out_col->total_digits = f->total_digits;
  out_col->frac_digits = f->frac_digits;
  out_col->is_signed = (cobol_orm_u8_t)(f->is_signed ? 1 : 0);
  out_col->is_pk = (cobol_orm_u8_t)((size_t)field_idx == cpy->pk_index ? 1 : 0);
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_cpy_set_pk(
    cobol_orm_cpy_t *cpy, const char *col_name, cobol_orm_u32_t name_len) {
  char *name_c = NULL;
  size_t i;
  cobol_orm_error_t rc = check_cpy(cpy);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(col_name, name_len, &name_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  for (i = 0; i < cpy->elem_count; i++) {
    int eq1 = 0;
    int eq2 = 0;
    int eq3 = 0;
    rc = str_eq_ci(cpy->elem_fields[i]->cobol_name, name_c, &eq1);
    rc = cobol_orm_keep_err(
        rc, str_eq_ci(cpy->elem_fields[i]->c_name, name_c, &eq2));
    rc = cobol_orm_keep_err(
        rc, str_eq_ci(cpy->elem_fields[i]->sql_name, name_c, &eq3));
    if (eq1 || eq2 || eq3) {
      cpy->pk_index = i;
      return cobol_orm_keep_err(
          rc, cobol_orm_from_c_orm(c_orm_system_free(name_c)));
    }
  }
  return cobol_orm_keep_err(COBOL_ORM_ERROR_NOT_FOUND,
                            cobol_orm_from_c_orm(c_orm_system_free(name_c)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_cpy_emit_ddl(
    const cobol_orm_cpy_t *cpy, cobol_orm_dialect_t dialect, char *out_sql,
    cobol_orm_u32_t sql_cap, cobol_orm_u32_t *out_len) {
  c_to_sql_dialect_t ddl_d;
  char *sql = NULL;
  cobol_orm_error_t rc = check_cpy(cpy);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = map_ddl_dialect(dialect, &ddl_d);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_copybook_emit_sql_ddl(cpy->rec, ddl_d, &sql);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  rc = cobol_orm_cstr_to_picx(sql, out_sql, sql_cap, out_len);
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(sql)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_create_table(cobol_orm_db_t *db, const cobol_orm_cpy_t *cpy,
                           cobol_orm_dialect_t dialect) {
  c_to_sql_dialect_t ddl_d;
  char *sql = NULL;
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = map_ddl_dialect(dialect, &ddl_d);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_copybook_emit_sql_ddl(cpy->rec, ddl_d, &sql);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_execute_raw(db->raw, sql);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(sql)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_validate_88(const cobol_orm_cpy_t *cpy,
                          const cobol_orm_u8_t *rec_buf,
                          cobol_orm_u32_t rec_len, cobol_orm_codepage_t cp,
                          cobol_orm_i32_t big_endian) {
  c_orm_codepage_t core_cp;
  cdd_c_abstract_struct_t abs_row;
  cobol_orm_error_t rc = check_cpy(cpy);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!rec_buf) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = cdd_c_abstract_struct_init(&abs_row);
  rc = cobol_orm_from_c_orm(crc);
  crc = c_orm_copybook_unpack_abstract(cpy->rec, rec_buf, (size_t)rec_len,
                                       core_cp, (int)big_endian, &abs_row);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(cdd_c_abstract_struct_free(&abs_row)));
  }
  rc = validate_88_abstract(cpy, &abs_row);
  return cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(cdd_c_abstract_struct_free(&abs_row)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_insert(cobol_orm_db_t *db, const cobol_orm_cpy_t *cpy,
                     const cobol_orm_u8_t *rec_buf, cobol_orm_u32_t rec_len,
                     cobol_orm_codepage_t cp, cobol_orm_i32_t big_endian) {
  c_orm_codepage_t core_cp;
  cdd_c_abstract_struct_t abs_row;
  c_orm_string_builder_t *sb = NULL;
  const char *sql = NULL;
  c_orm_query_t *q = NULL;
  int has_row = 0;
  size_t i;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!rec_buf) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = cdd_c_abstract_struct_init(&abs_row);
  rc = cobol_orm_from_c_orm(crc);
  crc = c_orm_copybook_unpack_abstract(cpy->rec, rec_buf, (size_t)rec_len,
                                       core_cp, (int)big_endian, &abs_row);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    goto done_abs;
  }
  rc = validate_88_abstract(cpy, &abs_row);
  if (rc != COBOL_ORM_OK) {
    goto done_abs;
  }

  crc = c_orm_string_builder_init(&sb);
  if (crc != C_ORM_OK) {
    rc = cobol_orm_from_c_orm(crc);
    goto done_abs;
  }
  rc = sb_append_if_ok(sb, "INSERT INTO ", &crc);
  rc = cobol_orm_keep_err(rc,
                          sb_append_if_ok(sb, cpy->rec->sql_table_name, &crc));
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " (", &crc));
  for (i = 0; i < cpy->elem_count; i++) {
    if (i > 0) {
      rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, ", ", &crc));
    }
    rc = cobol_orm_keep_err(
        rc, sb_append_if_ok(sb, cpy->elem_fields[i]->sql_name, &crc));
  }
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, ") VALUES (", &crc));
  for (i = 0; i < cpy->elem_count; i++) {
    rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, i > 0 ? ", ?" : "?", &crc));
  }
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, ")", &crc));
  if (rc != COBOL_ORM_OK) {
    goto done_sb;
  }
  crc = c_orm_string_builder_get(sb, &sql);
  rc = cobol_orm_from_c_orm(crc);

  crc = db->raw->vtable->prepare(db->raw, sql, &q);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    goto done_sb;
  }
  for (i = 0; i < cpy->elem_count; i++) {
    cdd_c_variant_t *var = NULL;
    crc = cdd_c_abstract_get(&abs_row, cpy->elem_fields[i]->c_name, &var);
    rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            bind_variant_param(db->raw, q, (int)(i + 1), var));
    if (rc != COBOL_ORM_OK) {
      goto done_q;
    }
  }
  crc = db->raw->vtable->step(q, &has_row);
  rc = cobol_orm_from_c_orm(crc);

done_q:
  rc = cobol_orm_keep_err(rc,
                          cobol_orm_from_c_orm(db->raw->vtable->finalize(q)));
done_sb:
  rc = cobol_orm_keep_err(rc,
                          cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
done_abs:
  return cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(cdd_c_abstract_struct_free(&abs_row)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_update(cobol_orm_db_t *db, const cobol_orm_cpy_t *cpy,
                     const cobol_orm_u8_t *rec_buf, cobol_orm_u32_t rec_len,
                     cobol_orm_codepage_t cp, cobol_orm_i32_t big_endian) {
  c_orm_codepage_t core_cp;
  cdd_c_abstract_struct_t abs_row;
  c_orm_string_builder_t *sb = NULL;
  const char *sql = NULL;
  c_orm_query_t *q = NULL;
  int has_row = 0;
  size_t i;
  int param_pos = 1;
  int first_set = 1;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!rec_buf) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  if (cpy->elem_count < 2) {
    return COBOL_ORM_ERROR_VALIDATION;
  }
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = cdd_c_abstract_struct_init(&abs_row);
  rc = cobol_orm_from_c_orm(crc);
  crc = c_orm_copybook_unpack_abstract(cpy->rec, rec_buf, (size_t)rec_len,
                                       core_cp, (int)big_endian, &abs_row);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    goto done_abs;
  }
  rc = validate_88_abstract(cpy, &abs_row);
  if (rc != COBOL_ORM_OK) {
    goto done_abs;
  }

  crc = c_orm_string_builder_init(&sb);
  if (crc != C_ORM_OK) {
    rc = cobol_orm_from_c_orm(crc);
    goto done_abs;
  }
  rc = sb_append_if_ok(sb, "UPDATE ", &crc);
  rc = cobol_orm_keep_err(rc,
                          sb_append_if_ok(sb, cpy->rec->sql_table_name, &crc));
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " SET ", &crc));
  for (i = 0; i < cpy->elem_count; i++) {
    if (i == cpy->pk_index) {
      continue;
    }
    if (!first_set) {
      rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, ", ", &crc));
    }
    first_set = 0;
    rc = cobol_orm_keep_err(
        rc, sb_append_if_ok(sb, cpy->elem_fields[i]->sql_name, &crc));
    rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " = ?", &crc));
  }
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " WHERE ", &crc));
  rc = cobol_orm_keep_err(
      rc, sb_append_if_ok(sb, cpy->elem_fields[cpy->pk_index]->sql_name, &crc));
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " = ?", &crc));
  if (rc != COBOL_ORM_OK) {
    goto done_sb;
  }
  crc = c_orm_string_builder_get(sb, &sql);
  rc = cobol_orm_from_c_orm(crc);

  crc = db->raw->vtable->prepare(db->raw, sql, &q);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    goto done_sb;
  }
  for (i = 0; i < cpy->elem_count; i++) {
    cdd_c_variant_t *var = NULL;
    if (i == cpy->pk_index) {
      continue;
    }
    crc = cdd_c_abstract_get(&abs_row, cpy->elem_fields[i]->c_name, &var);
    rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            bind_variant_param(db->raw, q, param_pos++, var));
    if (rc != COBOL_ORM_OK) {
      goto done_q;
    }
  }
  {
    cdd_c_variant_t *pk_var = NULL;
    crc = cdd_c_abstract_get(&abs_row, cpy->elem_fields[cpy->pk_index]->c_name,
                             &pk_var);
    rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            bind_variant_param(db->raw, q, param_pos, pk_var));
    if (rc != COBOL_ORM_OK) {
      goto done_q;
    }
  }
  crc = db->raw->vtable->step(q, &has_row);
  rc = cobol_orm_from_c_orm(crc);

done_q:
  rc = cobol_orm_keep_err(rc,
                          cobol_orm_from_c_orm(db->raw->vtable->finalize(q)));
done_sb:
  rc = cobol_orm_keep_err(rc,
                          cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
done_abs:
  return cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(cdd_c_abstract_struct_free(&abs_row)));
}

/**
 * @brief Builds `SELECT col1, col2, ... FROM table [WHERE pk = ?]`.
 *
 * @param[in] cpy Copybook handle.
 * @param[in] with_pk_where Non-zero to append `WHERE <pk> = ?`.
 * @param[out] out_sb Receives initialized string builder containing SQL.
 * @return `COBOL_ORM_OK` on success, or error code on OOM.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
build_select_sql(const cobol_orm_cpy_t *cpy, int with_pk_where,
                 c_orm_string_builder_t **out_sb) {
  c_orm_string_builder_t *sb = NULL;
  size_t i;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  crc = c_orm_string_builder_init(&sb);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  rc = sb_append_if_ok(sb, "SELECT ", &crc);
  for (i = 0; i < cpy->elem_count; i++) {
    if (i > 0) {
      rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, ", ", &crc));
    }
    rc = cobol_orm_keep_err(
        rc, sb_append_if_ok(sb, cpy->elem_fields[i]->sql_name, &crc));
  }
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " FROM ", &crc));
  rc = cobol_orm_keep_err(rc,
                          sb_append_if_ok(sb, cpy->rec->sql_table_name, &crc));
  if (with_pk_where) {
    rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " WHERE ", &crc));
    rc = cobol_orm_keep_err(
        rc,
        sb_append_if_ok(sb, cpy->elem_fields[cpy->pk_index]->sql_name, &crc));
    rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " = ?", &crc));
  }
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
  }
  *out_sb = sb;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_cpy_find_i32(
    cobol_orm_db_t *db, const cobol_orm_cpy_t *cpy, cobol_orm_i32_t id_val,
    cobol_orm_codepage_t cp, cobol_orm_i32_t big_endian,
    cobol_orm_u8_t *out_rec_buf, cobol_orm_u32_t rec_cap) {
  c_orm_codepage_t core_cp;
  c_orm_string_builder_t *sb = NULL;
  const char *sql = NULL;
  c_orm_query_t *q = NULL;
  cdd_c_abstract_struct_t abs_row;
  int has_row = 0;
  size_t packed_len = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_rec_buf) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = build_select_sql(cpy, 1, &sb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_string_builder_get(sb, &sql);
  rc = cobol_orm_from_c_orm(crc);
  crc = db->raw->vtable->prepare(db->raw, sql, &q);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
  }
  crc = db->raw->vtable->bind_int32(q, 1, (int32_t)id_val);
  if (crc == C_ORM_OK) {
    crc = db->raw->vtable->step(q, &has_row);
  }
  if (crc != C_ORM_OK) {
    rc = cobol_orm_from_c_orm(crc);
    goto done_q;
  }
  if (!has_row) {
    rc = COBOL_ORM_ERROR_NOT_FOUND;
    goto done_q;
  }
  crc = cdd_c_abstract_struct_init(&abs_row);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          hydrate_row_for_cpy(db->raw, q, cpy, &abs_row));
  if (rc == COBOL_ORM_OK) {
    crc = c_orm_copybook_pack_abstract(cpy->rec, &abs_row, core_cp,
                                       (int)big_endian, out_rec_buf,
                                       (size_t)rec_cap, &packed_len);
    rc = cobol_orm_from_c_orm(crc);
  }
  rc = cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(cdd_c_abstract_struct_free(&abs_row)));

done_q:
  rc = cobol_orm_keep_err(rc,
                          cobol_orm_from_c_orm(db->raw->vtable->finalize(q)));
  return cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_delete_i32(cobol_orm_db_t *db, const cobol_orm_cpy_t *cpy,
                         cobol_orm_i32_t id_val) {
  c_orm_string_builder_t *sb = NULL;
  const char *sql = NULL;
  c_orm_query_t *q = NULL;
  int has_row = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_string_builder_init(&sb);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  rc = sb_append_if_ok(sb, "DELETE FROM ", &crc);
  rc = cobol_orm_keep_err(rc,
                          sb_append_if_ok(sb, cpy->rec->sql_table_name, &crc));
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " WHERE ", &crc));
  rc = cobol_orm_keep_err(
      rc, sb_append_if_ok(sb, cpy->elem_fields[cpy->pk_index]->sql_name, &crc));
  rc = cobol_orm_keep_err(rc, sb_append_if_ok(sb, " = ?", &crc));
  if (rc == COBOL_ORM_OK) {
    crc = c_orm_string_builder_get(sb, &sql);
    rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
    crc = db->raw->vtable->prepare(db->raw, sql, &q);
    rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  }
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
  }
  crc = db->raw->vtable->bind_int32(q, 1, (int32_t)id_val);
  if (crc == C_ORM_OK) {
    crc = db->raw->vtable->step(q, &has_row);
  }
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(db->raw->vtable->finalize(q)));
  return cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_cpy_find_all(
    cobol_orm_db_t *db, const cobol_orm_cpy_t *cpy, cobol_orm_codepage_t cp,
    cobol_orm_i32_t big_endian, cobol_orm_u8_t *out_rec_array,
    cobol_orm_u32_t max_rows, cobol_orm_u32_t *out_row_count) {
  c_orm_codepage_t core_cp;
  c_orm_string_builder_t *sb = NULL;
  const char *sql = NULL;
  c_orm_query_t *q = NULL;
  cobol_orm_u32_t count = 0;
  size_t stride;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_cpy(cpy);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_rec_array || !out_row_count) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_row_count = 0;
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = build_select_sql(cpy, 0, &sb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_string_builder_get(sb, &sql);
  rc = cobol_orm_from_c_orm(crc);
  crc = db->raw->vtable->prepare(db->raw, sql, &q);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
  }

  stride = cpy->rec->total_byte_size;
  while (count < max_rows) {
    int has_row = 0;
    cdd_c_abstract_struct_t abs_row;
    size_t packed_len = 0;

    crc = db->raw->vtable->step(q, &has_row);
    if (crc != C_ORM_OK) {
      rc = cobol_orm_from_c_orm(crc);
      break;
    }
    if (!has_row) {
      break;
    }
    crc = cdd_c_abstract_struct_init(&abs_row);
    rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            hydrate_row_for_cpy(db->raw, q, cpy, &abs_row));
    if (rc == COBOL_ORM_OK) {
      crc = c_orm_copybook_pack_abstract(
          cpy->rec, &abs_row, core_cp, (int)big_endian,
          out_rec_array + ((size_t)count * stride), stride, &packed_len);
      rc = cobol_orm_from_c_orm(crc);
    }
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(cdd_c_abstract_struct_free(&abs_row)));
    if (rc != COBOL_ORM_OK) {
      break;
    }
    count++;
  }

  *out_row_count = count;
  rc = cobol_orm_keep_err(rc,
                          cobol_orm_from_c_orm(db->raw->vtable->finalize(q)));
  return cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(c_orm_string_builder_free(sb)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_cpy_free(cobol_orm_cpy_t *cpy) {
  cobol_orm_error_t rc = check_cpy(cpy);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_copybook_record_free(cpy->rec);
  rc = cobol_orm_from_c_orm(crc);
  if (cpy->elem_fields) {
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_system_free(cpy->elem_fields)));
  }
  cpy->elem_fields = NULL;
  cpy->rec = NULL;
  cpy->magic = 0;
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(cpy)));
}
