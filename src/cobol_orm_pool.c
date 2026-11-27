/**
 * @file cobol_orm_pool.c
 * @brief Thread-safe connection pool lifecycle and telemetry wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
#include <string.h>
/* clang-format on */

/**
 * @brief Validates a `cobol_orm_pool_t` handle pointer and magic tag.
 *
 * @param[in] pool Candidate connection pool handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
check_pool(const cobol_orm_pool_t *pool) {
  if (!pool || pool->magic != COBOL_ORM_MAGIC_POOL) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_pool_init(const char *url, cobol_orm_u32_t url_len,
                    cobol_orm_i32_t min_conns, cobol_orm_i32_t max_conns,
                    cobol_orm_i32_t timeout_ms, cobol_orm_pool_t **out_pool) {
  char *url_c = NULL;
  cobol_orm_pool_t *handle = NULL;
  c_orm_pool_t *raw = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!url || !out_pool) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_pool = NULL;

  rc = cobol_orm_picx_to_cstr(url, url_len, &url_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_pool_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(url_c)));
  }

  crc = c_orm_pool_init(url_c, (int)min_conns, (int)max_conns, (int)timeout_ms,
                        &raw);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(url_c)));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(rc,
                              cobol_orm_from_c_orm(c_orm_system_free(handle)));
  }

  handle->magic = COBOL_ORM_MAGIC_POOL;
  handle->raw = raw;
  *out_pool = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_pool_acquire(cobol_orm_pool_t *pool, cobol_orm_db_t **out_db) {
  cobol_orm_db_t *handle = NULL;
  c_orm_db_t *raw = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = check_pool(pool);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_db) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_db = NULL;

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_db_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }

  crc = c_orm_pool_acquire(pool->raw, &raw);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(handle)));
  }

  handle->magic = COBOL_ORM_MAGIC_DB;
  handle->raw = raw;
  handle->from_pool = 1;
  handle->tz_name = NULL;
  *out_db = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_pool_release(cobol_orm_pool_t *pool, cobol_orm_db_t *db) {
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = check_pool(pool);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_pool_release(pool->raw, db->raw);
  rc = cobol_orm_from_c_orm(crc);
  if (db->tz_name) {
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(c_orm_system_free(db->tz_name)));
    db->tz_name = NULL;
  }
  db->magic = 0;
  db->raw = NULL;
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(db)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_pool_telemetry(cobol_orm_pool_t *pool,
                         cobol_orm_pool_stats_t *out_stats) {
  c_orm_pool_telemetry_t raw_t;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = check_pool(pool);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_stats) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  memset(&raw_t, 0, sizeof(raw_t));
  crc = c_orm_pool_get_telemetry(pool->raw, &raw_t);
  out_stats->active_connections = (cobol_orm_u32_t)raw_t.active_connections;
  out_stats->idle_connections = (cobol_orm_u32_t)raw_t.idle_connections;
  out_stats->exhaustion_count = (cobol_orm_u32_t)raw_t.exhaustion_count;
  out_stats->slow_queries_logged = (cobol_orm_u32_t)raw_t.slow_queries_logged;
  out_stats->average_wait_time_ms = raw_t.average_wait_time_ms;
  return cobol_orm_from_c_orm(crc);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_pool_destroy(cobol_orm_pool_t *pool) {
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = check_pool(pool);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_pool_destroy(pool->raw);
  pool->magic = 0;
  pool->raw = NULL;
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(pool)));
}
