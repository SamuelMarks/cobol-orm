/**
 * @file cobol_orm_db.c
 * @brief Database connection lifecycle, raw SQL execution, diagnostics,
 * statement caching, timezone, and slow-query configuration.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_connect(
    const char *url, cobol_orm_u32_t url_len, cobol_orm_db_t **out_db) {
  char *url_c = NULL;
  cobol_orm_db_t *handle = NULL;
  c_orm_db_t *raw = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!url || !out_db) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_db = NULL;

  rc = cobol_orm_picx_to_cstr(url, url_len, &url_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_db_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(url_c)));
  }

  crc = c_orm_connect_url(url_c, &raw);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(url_c)));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(rc,
                              cobol_orm_from_c_orm(c_orm_system_free(handle)));
  }

  handle->magic = COBOL_ORM_MAGIC_DB;
  handle->raw = raw;
  handle->from_pool = 0;
  handle->tz_name = NULL;
  *out_db = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_disconnect(cobol_orm_db_t *db) {
  cobol_orm_error_t rc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }

  if (db->tz_name) {
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_system_free(db->tz_name)));
    db->tz_name = NULL;
  }
  if (!db->from_pool) {
    c_orm_error_t crc = db->raw->vtable->disconnect(db->raw);
    rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  }
  db->magic = 0;
  db->raw = NULL;
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(db)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_exec_sql(
    cobol_orm_db_t *db, const char *sql, cobol_orm_u32_t sql_len) {
  char *sql_c = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(sql, sql_len, &sql_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_execute_raw(db->raw, sql_c);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(sql_c)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_last_error(cobol_orm_db_t *db, char *out_buf, cobol_orm_u32_t buf_cap,
                     cobol_orm_u32_t *out_len) {
  const char *msg = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_get_last_error_message(db->raw, &msg);
  return cobol_orm_keep_err(
      cobol_orm_from_c_orm(crc),
      cobol_orm_cstr_to_picx(msg, out_buf, buf_cap, out_len));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_last_trace(cobol_orm_db_t *db, char *out_buf, cobol_orm_u32_t buf_cap,
                     cobol_orm_u32_t *out_len) {
  const char *trace = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_get_last_error_trace(db->raw, &trace);
  return cobol_orm_keep_err(
      cobol_orm_from_c_orm(crc),
      cobol_orm_cstr_to_picx(trace, out_buf, buf_cap, out_len));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_last_insert_rowid(cobol_orm_db_t *db, cobol_orm_i64_t *out_rowid) {
  int64_t rowid = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_rowid) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = db->raw->vtable->get_last_insert_rowid(db->raw, &rowid);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_rowid = (cobol_orm_i64_t)rowid;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_enable_stmt_cache(cobol_orm_db_t *db, cobol_orm_u32_t capacity) {
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (capacity == 0) {
    crc = c_orm_disable_statement_caching(db->raw);
  } else {
    crc = c_orm_enable_statement_caching(db->raw, (size_t)capacity);
  }
  return cobol_orm_from_c_orm(crc);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_set_timezone(cobol_orm_db_t *db, cobol_orm_i32_t offset_minutes,
                       const char *tz_name, cobol_orm_u32_t tz_len) {
  char *tz_copy = NULL;
  c_orm_timezone_t tz;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (tz_name && tz_len > 0) {
    rc = cobol_orm_picx_to_cstr(tz_name, tz_len, &tz_copy);
    if (rc != COBOL_ORM_OK) {
      return rc;
    }
  }
  tz.offset_minutes = (int)offset_minutes;
  tz.name = tz_copy;
  crc = c_orm_set_timezone(db->raw, tz);
  rc = cobol_orm_from_c_orm(crc);
  if (db->tz_name) {
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_system_free(db->tz_name)));
  }
  db->tz_name = tz_copy;
  return rc;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_set_slow_query_ms(cobol_orm_db_t *db, cobol_orm_u32_t threshold_ms) {
  cobol_orm_error_t rc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      c_orm_set_slow_query_threshold(db->raw, (uint32_t)threshold_ms));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_version(
    char *out_buf, cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  return cobol_orm_cstr_to_picx(COBOL_ORM_VERSION_STR, out_buf, buf_cap,
                                out_len);
}
