/**
 * @file test_cobol_orm.c
 * @brief Comprehensive ISO C89 unit, ABI-parity, error-percolation, and
 * deterministic OOM fault-injection test suite targeting 100% function, line,
 * and branch coverage across cobol-orm.
 */

/* clang-format off */
#ifndef C_ORM_TEST_ALLOCATOR
#define C_ORM_TEST_ALLOCATOR 1
#endif
#include "cobol_orm_internal.h"
#include "c_orm_odbc_abi.h"
#include "greatest.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined(_WIN32)
#include <direct.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#endif
/* clang-format on */

/**
 * @brief Forward declaration of generated C89 COBOL PIC X padding shim helper.
 *
 * @param[in] c_str Input C string.
 * @param[out] cob_buf Destination COBOL PIC X buffer.
 * @param[in] cob_len Destination buffer length.
 * @return 0 on success, -1 if cob_buf is NULL.
 */
extern int cdd_cobol_str_to_pic_x(const char *c_str, char *cob_buf,
                                  unsigned int cob_len);

/** @brief Countdown for deterministic OOM fault injection (0 = disabled). */
static int g_oom_countdown = 0;

/**
 * @brief Fault-injecting malloc wrapper for deterministic OOM testing.
 *
 * @param[in] sz Requested allocation size in bytes.
 * @param[out] out_ptr Receives allocated pointer or NULL when fault-injected.
 * @return `C_ORM_OK` on success, `C_ORM_ERROR_MEMORY` on OOM.
 */
static c_orm_error_t test_oom_malloc(size_t sz, void **out_ptr) {
  if (g_oom_countdown > 0) {
    g_oom_countdown--;
    if (g_oom_countdown == 0) {
      if (out_ptr) {
        *out_ptr = NULL;
      }
      return C_ORM_ERROR_MEMORY;
    }
  }
  return c_orm_default_malloc(sz, out_ptr);
}

/**
 * @brief Fault-injecting realloc wrapper for deterministic OOM testing.
 *
 * @param[in] ptr Existing allocation pointer.
 * @param[in] sz New requested size in bytes.
 * @param[out] out_ptr Receives reallocated pointer or NULL when fault-injected.
 * @return `C_ORM_OK` on success, `C_ORM_ERROR_MEMORY` on OOM.
 */
static c_orm_error_t test_oom_realloc(void *ptr, size_t sz, void **out_ptr) {
  if (g_oom_countdown > 0) {
    g_oom_countdown--;
    if (g_oom_countdown == 0) {
      if (out_ptr) {
        *out_ptr = NULL;
      }
      return C_ORM_ERROR_MEMORY;
    }
  }
  return c_orm_default_realloc(ptr, sz, out_ptr);
}

/**
 * @brief Standard free wrapper paired with fault-injecting allocators.
 *
 * @param[in] ptr Pointer to free.
 * @return `C_ORM_OK` on success.
 */
static c_orm_error_t test_oom_free(void *ptr) {
  return c_orm_default_free(ptr);
}

/**
 * @brief Installs or restores the deterministic OOM fault-injection allocator.
 *
 * @param[in] fail_at Positive 1-based allocation step to fail, or 0 to reset.
 * @return `COBOL_ORM_OK` on success.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t set_oom_at(int fail_at) {
  g_oom_countdown = fail_at;
  if (fail_at > 0) {
    return cobol_orm_from_c_orm(
        c_orm_set_allocators(test_oom_malloc, test_oom_realloc, test_oom_free));
  }
  return cobol_orm_from_c_orm(c_orm_reset_allocators());
}

/**
 * @brief Verifies ABI sizes, error name mapping, enum mappers, and PIC X /
 * binary marshaling helpers.
 */
TEST test_abi_str_and_errors(void) {
  char buf[64];
  cobol_orm_u8_t bbuf[8];
  cobol_orm_u32_t out_len = 0;
  char *cstr = NULL;
  int i;
  c_orm_codepage_t cp = C_ORM_CP_UTF8;
  c_orm_round_mode_t rm = C_ORM_ROUND_TRUNCATE;
  c_orm_dialect_t dl = C_ORM_DIALECT_SQLITE;
  cobol_orm_decimal_t d1;
  c_orm_decimal_t dc;
  cobol_orm_error_t rc;

  ASSERT_EQ((size_t)41, sizeof(cobol_orm_decimal_t));
  ASSERT_EQ((size_t)24, sizeof(cobol_orm_pool_stats_t));
  ASSERT_EQ((size_t)12, sizeof(cobol_orm_cpy_info_t));
  ASSERT_EQ((size_t)16, sizeof(cobol_orm_col_info_t));
  ASSERT_EQ((size_t)544, sizeof(cobol_orm_commarea_t));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_keep_err(COBOL_ORM_OK, COBOL_ORM_OK));
  ASSERT_EQ(COBOL_ORM_ERROR_IO,
            cobol_orm_keep_err(COBOL_ORM_OK, COBOL_ORM_ERROR_IO));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL,
            cobol_orm_keep_err(COBOL_ORM_ERROR_SQL, COBOL_ORM_ERROR_IO));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_from_c_orm(C_ORM_OK));
  ASSERT_EQ(COBOL_ORM_ERROR_UNKNOWN, cobol_orm_from_c_orm((c_orm_error_t)-1));
  ASSERT_EQ(COBOL_ORM_ERROR_UNKNOWN, cobol_orm_from_c_orm((c_orm_error_t)99));

  for (i = -1; i <= 37; i++) {
    rc = cobol_orm_error_name((cobol_orm_error_t)i, buf,
                              (cobol_orm_u32_t)sizeof(buf), &out_len);
    ASSERT_EQ(COBOL_ORM_OK, rc);
    ASSERT(out_len > 0);
  }
  ASSERT_EQ(COBOL_ORM_ERROR_TRUNCATION,
            cobol_orm_error_name(COBOL_ORM_OK, buf, 4, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_error_name(COBOL_ORM_OK, NULL, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_error_name(COBOL_ORM_OK, buf, 16, NULL));

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_picx_to_cstr(NULL, 4, &cstr));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_picx_to_cstr("AB  ", 4, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_picx_to_cstr("AB  ", 4, &cstr));
  ASSERT_STR_EQ("AB", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_picx_to_cstr("   ", 3, &cstr));
  ASSERT_STR_EQ("", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_picx_to_cstr("HI\0ZZ", 5, &cstr));
  ASSERT_STR_EQ("HI", cstr);
  ASSERT_EQ(C_ORM_OK, c_orm_system_free(cstr));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cstr_to_picx(NULL, buf, 4, &out_len));
  ASSERT_EQ(0u, out_len);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cstr_to_picx("", buf, 0, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_bytes_to_buf(NULL, 0, NULL, 4, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_bytes_to_buf(NULL, 0, bbuf, 4, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_bytes_to_buf(NULL, 0, bbuf, 4, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_TRUNCATION,
            cobol_orm_bytes_to_buf((const unsigned char *)"12345", 5, bbuf, 2,
                                   &out_len));
  ASSERT_EQ(5u, out_len);

  memset(&d1, 0, sizeof(d1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_to_core(NULL, &dc));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_to_core(&d1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_from_core(NULL, &d1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_from_core(&dc, NULL));

  for (i = 0; i <= 5; i++) {
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_map_codepage((cobol_orm_codepage_t)i, &cp));
  }
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_map_codepage((cobol_orm_codepage_t)99, &cp));
  for (i = 0; i <= 3; i++) {
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_map_round_mode((cobol_orm_round_mode_t)i, &rm));
  }
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_map_round_mode((cobol_orm_round_mode_t)99, &rm));
  for (i = 0; i <= 4; i++) {
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_map_dialect((cobol_orm_dialect_t)i, &dl));
  }
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_map_dialect((cobol_orm_dialect_t)99, &dl));

  PASS();
}

/**
 * @brief Exercises DB connection, raw SQL, diagnostics, cache, timezone, slow
 * query, version, transactions, savepoints, and invalid handles.
 */
TEST test_db_and_tx(void) {
  cobol_orm_db_t *db = NULL;
  char buf[128];
  cobol_orm_u32_t out_len = 0;
  cobol_orm_i64_t rowid = 0;

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_connect(NULL, 5, &db));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_connect("sqlite://:memory:", 17, NULL));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_connect("unknown://bad", 13, &db));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_disconnect(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_exec_sql(NULL, "X", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_last_error(NULL, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_last_trace(NULL, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_last_insert_rowid(NULL, &rowid));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_enable_stmt_cache(NULL, 4));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_set_timezone(NULL, 0, NULL, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_set_slow_query_ms(NULL, 10));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_tx_begin(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_tx_commit(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_tx_rollback(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_tx_savepoint(NULL, "S", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_tx_release_sp(NULL, "S", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_tx_rollback_sp(NULL, "S", 1));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_version(buf, sizeof(buf), &out_len));
  ASSERT_EQ(5u, out_len);

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_last_insert_rowid(db, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_exec_sql(db, NULL, 4));
  ASSERT_EQ(
      COBOL_ORM_OK,
      cobol_orm_exec_sql(db, "CREATE TABLE T (ID INTEGER PRIMARY KEY)", 39));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_exec_sql(db, "INSERT INTO T VALUES (42)", 25));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_last_insert_rowid(db, &rowid));
  ASSERT_EQ((cobol_orm_i64_t)42, rowid);

  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_exec_sql(db, "BAD SQL", 7));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_last_error(db, buf, sizeof(buf), &out_len));
  ASSERT(out_len > 0);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_last_trace(db, buf, sizeof(buf), &out_len));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_enable_stmt_cache(db, 8));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_enable_stmt_cache(db, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_set_timezone(db, 60, "UTC", 3));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_set_timezone(db, 0, NULL, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_set_timezone(db, -300, "EST", 3));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_set_slow_query_ms(db, 50));

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_tx_savepoint(db, NULL, 2));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_tx_release_sp(db, NULL, 2));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_tx_rollback_sp(db, NULL, 2));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_begin(db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_savepoint(db, "SP1", 3));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_rollback_sp(db, "SP1", 3));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_release_sp(db, "SP1", 3));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_commit(db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_begin(db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_tx_rollback(db));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
  PASS();
}

/**
 * @brief Exercises connection pool lifecycle, timeout, telemetry, and errors.
 */
TEST test_pool(void) {
  cobol_orm_pool_t *pool = NULL;
  cobol_orm_db_t *db1 = NULL;
  cobol_orm_db_t *db2 = NULL;
  cobol_orm_pool_stats_t stats;

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_pool_init(NULL, 4, 1, 1, 5, &pool));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_pool_init("sqlite://:memory:", 17, 1, 1, 5, NULL));
  ASSERT_NEQ(COBOL_ORM_OK,
             cobol_orm_pool_init("sqlite://:memory:", 17, 5, 1, 5, &pool));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_pool_acquire(NULL, &db1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_pool_release(NULL, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_pool_telemetry(NULL, &stats));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_pool_destroy(NULL));

  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_pool_init("sqlite://:memory:", 17, 1, 1, 5, &pool));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_pool_acquire(pool, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_pool_telemetry(pool, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_pool_release(pool, NULL));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_acquire(pool, &db1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_set_timezone(db1, 0, "UTC", 3));
  ASSERT_EQ(COBOL_ORM_ERROR_TIMEOUT, cobol_orm_pool_acquire(pool, &db2));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_telemetry(pool, &stats));
  ASSERT_EQ(1u, stats.active_connections);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_release(pool, db1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_destroy(pool));
  PASS();
}

/**
 * @brief Exercises prepared/cached statements, all bind/column types, COMP-3
 * bind/read, and dynamic abstract result sets.
 */
TEST test_stmt_and_abstract(void) {
  cobol_orm_db_t *db = NULL;
  cobol_orm_stmt_t *stmt = NULL;
  cobol_orm_rs_t *rs = NULL;
  cobol_orm_decimal_t dec_in;
  cobol_orm_decimal_t dec_out;
  cobol_orm_u8_t comp3_in[5];
  cobol_orm_u8_t comp3_out[5];
  cobol_orm_u8_t blob_in[3] = {0xDE, 0xAD, 0xBE};
  cobol_orm_u8_t blob_out[8];
  cobol_orm_u32_t written = 0;
  cobol_orm_u32_t out_len = 0;
  cobol_orm_i32_t has_row = 0;
  cobol_orm_i32_t i32v = 0;
  cobol_orm_i64_t i64v = 0;
  double f64v = 0.0;
  char sbuf[64];
  cobol_orm_variant_type_t vtype = COBOL_ORM_VAL_NULL;

  memset(&dec_in, 0, sizeof(dec_in));
  memset(&dec_out, 0, sizeof(dec_out));
  memset(comp3_in, 0, sizeof(comp3_in));
  memset(comp3_out, 0, sizeof(comp3_out));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_enable_stmt_cache(db, 4));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_exec_sql(
                db,
                "CREATE TABLE S (A INT, B BIGINT, C REAL, D TEXT, E BLOB, F "
                "DECIMAL(9,2), G DECIMAL(9,2), H TEXT)",
                96));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_prepare(NULL, "SELECT 1", 8, &stmt));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_prepare(db, "SELECT 1", 8, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_prepare(db, NULL, 8, &stmt));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_stmt_prepare(db, "BAD SQL", 7, &stmt));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_i32(NULL, 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_i64(NULL, 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_f64(NULL, 1, 0.0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_str(NULL, 1, "A", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_blob(NULL, 1, blob_in, 3));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_decimal(NULL, 1, &dec_in));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_bind_comp3(NULL, 1, comp3_in, 5, 2));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_stmt_bind_null(NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_step(NULL, &has_row));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_stmt_reset(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_stmt_finalize(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_count(NULL, &i32v));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_name(NULL, 0, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_is_null(NULL, 0, &i32v));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_i32(NULL, 0, &i32v));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_i64(NULL, 0, &i64v));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_f64(NULL, 0, &f64v));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_str(NULL, 0, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_blob(NULL, 0, blob_out, 8, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_decimal(NULL, 0, &dec_out));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_stmt_col_comp3(NULL, 0, 7, 2, 1, COBOL_ORM_ROUND_HALF_UP,
                                     comp3_out, 5, &written));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_str("123.45", 6, &dec_in));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_dec_to_comp3(&dec_in, 7, 2, 1, comp3_in, 5, &written));

  ASSERT_EQ(
      COBOL_ORM_OK,
      cobol_orm_stmt_prepare_cached(
          db, "INSERT INTO S VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 45, &stmt));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_bind_str(stmt, 4, NULL, 2));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_bind_blob(stmt, 5, NULL, 3));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_bind_decimal(stmt, 6, NULL));
  ASSERT_EQ(
      COBOL_ORM_ERROR_DECIMAL_SYNTAX,
      cobol_orm_stmt_bind_comp3(stmt, 7, (const cobol_orm_u8_t *)"\xFF", 1, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_i32(stmt, 1, 7));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_stmt_bind_i64(stmt, 2, (cobol_orm_i64_t)999999999L));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_f64(stmt, 3, 2.5));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_str(stmt, 4, "HELLO  ", 7));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_blob(stmt, 5, blob_in, 3));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_decimal(stmt, 6, &dec_in));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_comp3(stmt, 7, comp3_in, 5, 2));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_null(stmt, 8));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_stmt_step(stmt, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_step(stmt, &has_row));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_reset(stmt));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_finalize(stmt));

  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_stmt_prepare(db, "SELECT A, B, C, D, E, F, G, H FROM S",
                                   37, &stmt));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_step(stmt, &has_row));
  ASSERT_EQ(1, has_row);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_stmt_col_count(stmt, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_count(stmt, &i32v));
  ASSERT_EQ(8, i32v);
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_stmt_col_name(stmt, 0, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_is_null(stmt, 7, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_is_null(stmt, 7, &i32v));
  ASSERT_EQ(1, i32v);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_i32(stmt, 0, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_i32(stmt, 0, &i32v));
  ASSERT_EQ(7, i32v);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_i64(stmt, 1, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_i64(stmt, 1, &i64v));
  ASSERT_EQ((cobol_orm_i64_t)999999999L, i64v);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_f64(stmt, 2, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_f64(stmt, 2, &f64v));
  ASSERT(f64v > 2.4 && f64v < 2.6);
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_stmt_col_str(stmt, 3, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(5u, out_len);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_blob(stmt, 4, blob_out,
                                                  sizeof(blob_out), &out_len));
  ASSERT_EQ(3u, out_len);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_decimal(stmt, 5, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_col_decimal(stmt, 5, &dec_out));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_comp3(stmt, 6, 7, 2, 1, COBOL_ORM_ROUND_HALF_UP,
                                     NULL, 5, &written));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_stmt_col_comp3(stmt, 6, 7, 2, 1,
                                     (cobol_orm_round_mode_t)99, comp3_out, 5,
                                     &written));
  ASSERT_EQ(COBOL_ORM_ERROR_OVERFLOW,
            cobol_orm_stmt_col_comp3(stmt, 6, 7, 2, 1, COBOL_ORM_ROUND_HALF_UP,
                                     comp3_out, 1, &written));
  ASSERT_EQ(COBOL_ORM_ERROR_DECIMAL_OVERFLOW,
            cobol_orm_stmt_col_comp3(stmt, 6, 1, 2, 1, COBOL_ORM_ROUND_HALF_UP,
                                     comp3_out, 5, &written));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_stmt_col_comp3(stmt, 6, 7, 2, 1, COBOL_ORM_ROUND_HALF_UP,
                                     comp3_out, 5, &written));
  ASSERT_EQ(5u, written);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_finalize(stmt));

  /* Dynamic abstract result set tests */
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_query_abstract(NULL, "SELECT 1", 8, &rs));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_query_abstract(db, "SELECT 1", 8, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_query_abstract(db, NULL, 8, &rs));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_query_abstract(db, "BAD SQL", 7, &rs));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_rs_row_count(NULL, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_rs_col_count(NULL, 0, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_rs_col_name(NULL, 0, 0, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_rs_get_type(NULL, 0, "A", 1, &vtype));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_rs_free(NULL));

  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_query_abstract(db, "SELECT A, C, D FROM S", 21, &rs));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_rs_row_count(rs, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_row_count(rs, &out_len));
  ASSERT_EQ(1u, out_len);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_rs_col_count(rs, 0, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND, cobol_orm_rs_col_count(rs, 9, &out_len));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_col_count(rs, 0, &out_len));
  ASSERT_EQ(3u, out_len);
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND,
            cobol_orm_rs_col_name(rs, 9, 0, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND,
            cobol_orm_rs_col_name(rs, 0, 9, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_rs_col_name(rs, 0, 0, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_rs_get_type(rs, 0, "A", 1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND,
            cobol_orm_rs_get_type(rs, 9, "A", 1, &vtype));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_rs_get_type(rs, 0, NULL, 1, &vtype));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_get_type(rs, 0, "A", 1, &vtype));
  ASSERT_EQ(COBOL_ORM_VAL_INT, vtype);

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_rs_get_i64(rs, 0, "A", 1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND,
            cobol_orm_rs_get_i64(rs, 0, "NOPE", 4, &i64v));
  ASSERT_EQ(COBOL_ORM_ERROR_TYPE_MISMATCH,
            cobol_orm_rs_get_i64(rs, 0, "D", 1, &i64v));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_get_i64(rs, 0, "A", 1, &i64v));
  ASSERT_EQ((cobol_orm_i64_t)7, i64v);

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_rs_get_f64(rs, 0, "C", 1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND,
            cobol_orm_rs_get_f64(rs, 0, "NOPE", 4, &f64v));
  ASSERT_EQ(COBOL_ORM_ERROR_TYPE_MISMATCH,
            cobol_orm_rs_get_f64(rs, 0, "A", 1, &f64v));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_get_f64(rs, 0, "C", 1, &f64v));

  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND,
            cobol_orm_rs_get_str(rs, 0, "NOPE", 4, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_TYPE_MISMATCH,
            cobol_orm_rs_get_str(rs, 0, "A", 1, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_rs_get_str(rs, 0, "D", 1, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(5u, out_len);

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_free(rs));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
  PASS();
}

/**
 * @brief Exercises fluent AST query construction, dialect rendering, and exec.
 */
TEST test_query_ast(void) {
  cobol_orm_db_t *db = NULL;
  cobol_orm_ast_t *ast = NULL;
  char sql[256];
  cobol_orm_u32_t out_len = 0;
  int d;

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_ast_new(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_select(NULL, "*", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_distinct(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_from(NULL, "T", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_insert_into(NULL, "T", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_update_table(NULL, "T", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_delete_from(NULL, "T", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_set_col(NULL, "A", 1, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_where_eq(NULL, "A", 1, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_join(NULL, COBOL_ORM_JOIN_INNER, "B", 1, "1=1", 3));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_group_by(NULL, "A", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_order_by(NULL, "A", 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_limit_offset(NULL, 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_ast_with_lock(NULL, COBOL_ORM_ISO_UR));
  ASSERT_EQ(
      COBOL_ORM_ERROR_INVALID_HANDLE,
      cobol_orm_ast_to_sql(NULL, COBOL_ORM_DIALECT_SQLITE, sql, 32, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_exec(NULL, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_free(NULL));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_new(&ast));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_ast_select(ast, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_ast_from(ast, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_insert_into(ast, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_update_table(ast, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_delete_from(ast, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_set_col(ast, NULL, 1, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_set_col(ast, "A", 1, NULL, 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_where_eq(ast, NULL, 1, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_where_eq(ast, "A", 1, NULL, 1, 0));
  ASSERT_EQ(
      COBOL_ORM_ERROR_VALIDATION,
      cobol_orm_ast_join(ast, (cobol_orm_join_type_t)99, "B", 1, "1=1", 3));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_join(ast, COBOL_ORM_JOIN_INNER, NULL, 1, "1=1", 3));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_join(ast, COBOL_ORM_JOIN_LEFT, "B", 1, NULL, 3));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_ast_group_by(ast, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ast_order_by(ast, NULL, 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_ast_with_lock(ast, (cobol_orm_isolation_t)99));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_ast_to_sql(ast, (cobol_orm_dialect_t)99, sql, sizeof(sql),
                                 &out_len));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_select(ast, "A.ID", 4));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_distinct(ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_from(ast, "A", 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_join(ast, COBOL_ORM_JOIN_INNER, "B", 1,
                                             "A.ID=B.ID", 9));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_join(ast, COBOL_ORM_JOIN_LEFT, "C", 1,
                                             "A.ID=C.ID", 9));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_join(ast, COBOL_ORM_JOIN_RIGHT, "D", 1,
                                             "A.ID=D.ID", 9));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_where_eq(ast, "A.ID", 4, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_where_eq(ast, "A.NM", 4, "X", 1, 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_group_by(ast, "A.ID", 4));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_order_by(ast, "A.ID", 4, 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_limit_offset(ast, 0, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_limit_offset(ast, 10, 5));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_with_lock(ast, COBOL_ORM_ISO_UR));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_with_lock(ast, COBOL_ORM_ISO_CS));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_with_lock(ast, COBOL_ORM_ISO_RS));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_with_lock(ast, COBOL_ORM_ISO_RR));

  for (d = 0; d <= 4; d++) {
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_to_sql(ast, (cobol_orm_dialect_t)d,
                                                 sql, sizeof(sql), &out_len));
    ASSERT(out_len > 0);
  }
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_free(ast));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_exec(db, NULL));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_exec_sql(db, "CREATE TABLE Q (ID INT, V TEXT)", 31));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_new(&ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_insert_into(ast, "Q", 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_set_col(ast, "ID", 2, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_set_col(ast, "V", 1, "HI", 2, 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_exec(db, ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_free(ast));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_new(&ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_update_table(ast, "Q", 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_set_col(ast, "V", 1, "OK", 2, 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_where_eq(ast, "ID", 2, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_exec(db, ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_free(ast));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_new(&ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_delete_from(ast, "Q", 1));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_where_eq(ast, "ID", 2, "1", 1, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_exec(db, ast));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_free(ast));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
  PASS();
}

/**
 * @brief Exercises 38-digit decimal arithmetic, COMP-3, Zoned, COMP, EBCDIC,
 * and UTF-16 GRAPHIC transcoders.
 */
TEST test_decimal_and_ebcdic(void) {
  cobol_orm_decimal_t a;
  cobol_orm_decimal_t b;
  cobol_orm_decimal_t r;
  cobol_orm_decimal_t z;
  cobol_orm_u8_t buf[32];
  cobol_orm_u16_t u16[16];
  char sbuf[64];
  cobol_orm_u32_t out_len = 0;
  cobol_orm_i32_t cmp_v = 0;
  cobol_orm_i64_t iv = 0;

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_from_str("1", 1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_from_str(NULL, 1, &a));
  ASSERT_EQ(COBOL_ORM_ERROR_DECIMAL_SYNTAX,
            cobol_orm_dec_from_str("BAD", 3, &a));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_str("10.50", 5, &a));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_str("2.50", 4, &b));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_str("0", 1, &z));

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_to_str(NULL, sbuf, 32, &out_len));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_to_str(&a, sbuf, 32, &out_len));

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_add(NULL, &b, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_add(&a, NULL, &r));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_add(&a, &b, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_sub(NULL, &b, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_sub(&a, NULL, &r));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_sub(&a, &b, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_mul(NULL, &b, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_mul(&a, NULL, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_dec_mul(&a, &b, 2, (cobol_orm_round_mode_t)99, &r));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_dec_mul(&a, &b, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_div(NULL, &b, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_div(&a, NULL, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_dec_div(&a, &b, 2, (cobol_orm_round_mode_t)99, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_DECIMAL_OVERFLOW,
            cobol_orm_dec_div(&a, &z, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_dec_div(&a, &b, 2, COBOL_ORM_ROUND_HALF_UP, &r));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_cmp(&a, &b, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_cmp(NULL, &b, &cmp_v));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_dec_cmp(&a, NULL, &cmp_v));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_cmp(&a, &b, &cmp_v));
  ASSERT_EQ(1, cmp_v);

  /* Invalid decimal struct triggers core validation error */
  memset(&r, 0xFF, sizeof(r));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_dec_to_str(&r, sbuf, 32, &out_len));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_dec_add(&r, &b, &r));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_dec_sub(&r, &b, &r));
  ASSERT_NEQ(COBOL_ORM_OK,
             cobol_orm_dec_mul(&r, &b, 2, COBOL_ORM_ROUND_TRUNCATE, &r));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_dec_cmp(&r, &b, &cmp_v));

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_to_comp3(&a, 5, 2, 1, buf, 16, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_to_comp3(NULL, 5, 2, 1, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_OVERFLOW,
            cobol_orm_dec_to_comp3(&a, 5, 2, 1, buf, 1, &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_dec_to_comp3(&a, 5, 2, 1, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_from_comp3(buf, out_len, 2, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_DECIMAL_SYNTAX,
            cobol_orm_dec_from_comp3((const cobol_orm_u8_t *)"\xFF", 1, 0, &r));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_comp3(buf, out_len, 2, &r));

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_to_zoned(&a, 5, 2, 1, 0, 0, 1, buf, 16, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_to_zoned(NULL, 5, 2, 1, 0, 0, 1, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_OVERFLOW,
            cobol_orm_dec_to_zoned(&a, 5, 2, 1, 0, 0, 1, buf, 1, &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_dec_to_zoned(&a, 5, 2, 1, 0, 0, 1, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_dec_from_zoned(buf, out_len, 2, 1, 0, 0, 1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_DECIMAL_SYNTAX,
            cobol_orm_dec_from_zoned((const cobol_orm_u8_t *)"\x01", 1, 0, 1, 0,
                                     0, 1, &r));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_dec_from_zoned(buf, out_len, 2, 1, 0, 0, 1, &r));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_i64_to_comp(12345, 4, 1, buf, 8));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_i64_from_comp(buf, 4, 1, 1, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_i64_from_comp(buf, 3, 1, 1, &iv));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_i64_from_comp(buf, 4, 1, 1, &iv));
  ASSERT_EQ((cobol_orm_i64_t)12345, iv);

  /* EBCDIC & UTF-16 */
  ASSERT_EQ(
      COBOL_ORM_ERROR_NULL_POINTER,
      cobol_orm_utf8_to_ebcdic(COBOL_ORM_CP_IBM037, NULL, 1, buf, 8, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_utf8_to_ebcdic((cobol_orm_codepage_t)99, "A", 1, buf, 8,
                                     &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_OVERFLOW,
            cobol_orm_utf8_to_ebcdic(COBOL_ORM_CP_IBM037, "HELLO", 5, buf, 2,
                                     &out_len));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_utf8_to_ebcdic(COBOL_ORM_CP_IBM037, "HELLO",
                                                   5, buf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ebcdic_to_utf8(COBOL_ORM_CP_IBM037, NULL, 1, sbuf, 16,
                                     &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_ebcdic_to_utf8((cobol_orm_codepage_t)99, buf, 5, sbuf, 16,
                                     &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_ebcdic_to_utf8(COBOL_ORM_CP_IBM037, buf, 5, sbuf,
                                     sizeof(sbuf), &out_len));
  ASSERT_EQ(5u, out_len);

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_utf8_to_utf16(NULL, 1, 1, u16, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_OVERFLOW,
            cobol_orm_utf8_to_utf16("HELLO", 5, 1, u16, 2, &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_utf8_to_utf16("HI", 2, 1, u16, 16, &out_len));
  ASSERT_EQ(2u, out_len);
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_utf16_to_utf8(NULL, 1, 1, sbuf, 16, &out_len));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_utf16_to_utf8(u16, 2, 1, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(2u, out_len);
  /* Unpaired surrogate triggers codepage error in utf16_to_utf8 */
  u16[0] = 0xD800u;
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_utf16_to_utf8(u16, 1, 0, sbuf, sizeof(sbuf), &out_len));

  PASS();
}

/**
 * @brief Exercises Copybook parser, metadata, DDL, level-88 validation, and
 * full Copybook-driven CRUD.
 */
TEST test_copybook_crud(void) {
  static const char k_cpy[] = "01 ACCT-REC.\n"
                              "   05 ACCT-GRP.\n"
                              "      10 ACCT-ID   PIC S9(9) COMP-5.\n"
                              "      10 FILLER    PIC X(1).\n"
                              "   05 ACCT-STAT    PIC X(1).\n"
                              "      88 ST-OK     VALUE 'A' THRU 'C'.\n"
                              "      88 ST-X      VALUE 'X'.\n"
                              "   05 ACCT-TIER    PIC S9(4) COMP-5.\n"
                              "      88 TIER-OK   VALUE 1 THRU 5.\n"
                              "   05 ACCT-NAME    PIC X(8).\n"
                              "   05 ACCT-BAL     PIC S9(5)V99 COMP-3.\n"
                              "   05 ACCT-RATE    COMP-2.\n";
  static const char k_single[] = "01 ONE-REC. 05 ONLY-ID PIC S9(9) COMP-5.";
  cobol_orm_db_t *db = NULL;
  cobol_orm_cpy_t *cpy = NULL;
  cobol_orm_cpy_t *one = NULL;
  cobol_orm_cpy_info_t info;
  cobol_orm_col_info_t col;
  char ddl[1024];
  cobol_orm_u32_t out_len = 0;
  cobol_orm_u8_t rec_in[64];
  cobol_orm_u8_t rec_out[128];
  cobol_orm_u32_t row_cnt = 0;
  int d;
  FILE *fp = NULL;
  const char *tmp_cpy = "/tmp/cobol_orm_test_acct.cpy";

  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_parse_str(NULL, 4, COBOL_ORM_CPY_FORMAT_FREE, &cpy));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NULL_POINTER,
      cobol_orm_cpy_parse_str(k_cpy, 10, COBOL_ORM_CPY_FORMAT_FREE, NULL));
  ASSERT_EQ(
      COBOL_ORM_ERROR_VALIDATION,
      cobol_orm_cpy_parse_str(k_cpy, 10, (cobol_orm_cpy_format_t)99, &cpy));
  ASSERT_EQ(
      COBOL_ORM_ERROR_COPYBOOK_SYNTAX,
      cobol_orm_cpy_parse_str("NOT VALID", 9, COBOL_ORM_CPY_FORMAT_FREE, &cpy));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_parse_file(NULL, 4, COBOL_ORM_CPY_FORMAT_AUTO, &cpy));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_parse_file(tmp_cpy, (cobol_orm_u32_t)strlen(tmp_cpy),
                                     (cobol_orm_cpy_format_t)99, &cpy));
  ASSERT_EQ(COBOL_ORM_ERROR_IO,
            cobol_orm_cpy_parse_file("/nonexistent/x.cpy", 18,
                                     COBOL_ORM_CPY_FORMAT_FIXED, &cpy));

  fp = fopen(tmp_cpy, "wb");
  ASSERT(fp != NULL);
  ASSERT_EQ(strlen(k_cpy), fwrite(k_cpy, 1, strlen(k_cpy), fp));
  ASSERT_EQ(0, fclose(fp));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_parse_file(tmp_cpy, (cobol_orm_u32_t)strlen(tmp_cpy),
                                     COBOL_ORM_CPY_FORMAT_AUTO, &cpy));
  ASSERT_EQ(0, remove(tmp_cpy));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_cpy_info(NULL, &info));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_cpy_info(cpy, NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_info(cpy, &info));
  ASSERT_EQ(6u, info.field_count);

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_field_info(NULL, 0, &col));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_field_info(cpy, 0, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND, cobol_orm_cpy_field_info(cpy, 99, &col));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_field_info(cpy, 0, &col));
  ASSERT_EQ(1u, col.is_pk);

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_cpy_set_pk(NULL, "X", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_cpy_set_pk(cpy, NULL, 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND, cobol_orm_cpy_set_pk(cpy, "NOPE", 4));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_set_pk(cpy, "ACCT-ID", 7));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_set_pk(cpy, "acct_id", 7));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_emit_ddl(NULL, COBOL_ORM_DIALECT_SQLITE, ddl,
                                   sizeof(ddl), &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_emit_ddl(cpy, (cobol_orm_dialect_t)99, ddl,
                                   sizeof(ddl), &out_len));
  for (d = 0; d <= 4; d++) {
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_emit_ddl(cpy, (cobol_orm_dialect_t)d,
                                                   ddl, sizeof(ddl), &out_len));
    ASSERT(out_len > 0);
  }

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_create_table(NULL, cpy, COBOL_ORM_DIALECT_SQLITE));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_create_table(db, NULL, COBOL_ORM_DIALECT_SQLITE));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_create_table(db, cpy, (cobol_orm_dialect_t)99));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_create_table(db, cpy, COBOL_ORM_DIALECT_SQLITE));

  /* Build a valid native-endian ASCII COBOL 01 record */
  memset(rec_in, 0, sizeof(rec_in));
  {
    cobol_orm_i32_t id = 101;
    cobol_orm_i16_t tier = 3;
    cobol_orm_decimal_t bal;
    cobol_orm_u32_t cw = 0;
    double rate = 1.5;
    memcpy(rec_in + 0, &id, 4);
    rec_in[4] = ' ';
    rec_in[5] = 'B';
    memcpy(rec_in + 6, &tier, 2);
    memcpy(rec_in + 8, "ALICE   ", 8);
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_str("123.45", 6, &bal));
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_dec_to_comp3(&bal, 5, 2, 1, rec_in + 16, 4, &cw));
    memcpy(rec_in + 20, &rate, 8);
  }

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_validate_88(NULL, rec_in, info.total_byte_size,
                                      COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_validate_88(cpy, NULL, info.total_byte_size,
                                      COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_cpy_validate_88(cpy, rec_in, info.total_byte_size,
                                      (cobol_orm_codepage_t)99, 0));
  ASSERT_NEQ(COBOL_ORM_OK,
             cobol_orm_cpy_validate_88(cpy, rec_in, 2, COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_validate_88(cpy, rec_in, info.total_byte_size,
                                      COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'X';
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_validate_88(cpy, rec_in, info.total_byte_size,
                                      COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'Z';
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_validate_88(cpy, rec_in, info.total_byte_size,
                                      COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'A';

  /* Insert, Find, Update, FindAll, Delete */
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_insert(NULL, cpy, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_insert(db, NULL, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_insert(db, cpy, NULL, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_cpy_insert(db, cpy, rec_in, info.total_byte_size,
                                 (cobol_orm_codepage_t)99, 0));
  ASSERT_NEQ(COBOL_ORM_OK,
             cobol_orm_cpy_insert(db, cpy, rec_in, 2, COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'Z';
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_insert(db, cpy, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'A';
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_insert(db, cpy, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_find_i32(NULL, cpy, 101, COBOL_ORM_CP_ASCII, 0,
                                   rec_out, 64));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_find_i32(db, NULL, 101, COBOL_ORM_CP_ASCII, 0,
                                   rec_out, 64));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NULL_POINTER,
      cobol_orm_cpy_find_i32(db, cpy, 101, COBOL_ORM_CP_ASCII, 0, NULL, 64));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_cpy_find_i32(db, cpy, 101, (cobol_orm_codepage_t)99, 0,
                                   rec_out, 64));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NOT_FOUND,
      cobol_orm_cpy_find_i32(db, cpy, 999, COBOL_ORM_CP_ASCII, 0, rec_out, 64));
  ASSERT_EQ(
      COBOL_ORM_OK,
      cobol_orm_cpy_find_i32(db, cpy, 101, COBOL_ORM_CP_ASCII, 0, rec_out, 64));
  ASSERT_EQ(0, memcmp(rec_out + 8, "ALICE   ", 8));

  /* Update */
  memcpy(rec_in + 8, "BOB     ", 8);
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_update(NULL, cpy, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_update(db, NULL, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_update(db, cpy, NULL, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_cpy_update(db, cpy, rec_in, info.total_byte_size,
                                 (cobol_orm_codepage_t)99, 0));
  ASSERT_NEQ(COBOL_ORM_OK,
             cobol_orm_cpy_update(db, cpy, rec_in, 2, COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'Z';
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_update(db, cpy, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));
  rec_in[5] = 'B';
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_update(db, cpy, rec_in, info.total_byte_size,
                                 COBOL_ORM_CP_ASCII, 0));

  /* Single-field copybook rejects update (needs >= 2 columns) */
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_cpy_parse_str(k_single, (cobol_orm_u32_t)strlen(k_single),
                                    COBOL_ORM_CPY_FORMAT_FREE, &one));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_update(db, one, rec_in, 4, COBOL_ORM_CP_ASCII, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(one));

  /* Find all & Delete */
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_find_all(NULL, cpy, COBOL_ORM_CP_ASCII, 0, rec_out, 2,
                                   &row_cnt));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_find_all(db, NULL, COBOL_ORM_CP_ASCII, 0, rec_out, 2,
                                   &row_cnt));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_cpy_find_all(db, cpy, COBOL_ORM_CP_ASCII, 0, NULL, 2,
                                   &row_cnt));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_cpy_find_all(db, cpy, (cobol_orm_codepage_t)99, 0,
                                   rec_out, 2, &row_cnt));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_find_all(db, cpy, COBOL_ORM_CP_ASCII, 0,
                                                 rec_out, 2, &row_cnt));
  ASSERT_EQ(1u, row_cnt);
  ASSERT_EQ(0, memcmp(rec_out + 8, "BOB     ", 8));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_delete_i32(NULL, cpy, 101));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_cpy_delete_i32(db, NULL, 101));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_delete_i32(db, cpy, 101));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NOT_FOUND,
      cobol_orm_cpy_find_i32(db, cpy, 101, COBOL_ORM_CP_ASCII, 0, rec_out, 64));

  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_cpy_free(NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(cpy));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
  PASS();
}

/**
 * @brief Exercises migrations, enterprise ODBC/Db2 helpers, legacy COMMAREA /
 * DISPLAY dispatchers, and generated C89 ABI shim helpers.
 */
TEST test_migrations_enterprise_legacy_shim(void) {
  cobol_orm_db_t *db = NULL;
  cobol_orm_mig_t *mig = NULL;
  cobol_orm_u32_t applied = 0;
  cobol_orm_u32_t out_len = 0;
  char sbuf[32];
  cobol_orm_commarea_t ca;
  char dbuf[COBOL_ORM_DISPLAY_COMMAREA_SIZE];
  int i;

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));

  /* Migrations */
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_mig_init(NULL, "/tmp", 4, &mig));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_mig_init(db, "/tmp", 4, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_mig_init(db, NULL, 4, &mig));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_mig_up(NULL, 0, &applied));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_mig_down(NULL, 1, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_mig_free(NULL));

  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_mig_init(db, "/nonexistent_cobol_mig", 22, &mig));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_mig_up(mig, 0, NULL));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_mig_up(mig, 0, &applied));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_mig_down(mig, 1, 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_free(mig));

  /* Enterprise helpers (invalid handles + non-ODBC/Db2 driver errors) */
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_odbc_sqlstate(NULL, sbuf, sizeof(sbuf), &out_len));
  ASSERT_NEQ(COBOL_ORM_OK,
             cobol_orm_odbc_sqlstate(db, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_db2_set_isolation(NULL, COBOL_ORM_ISO_UR));
  ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_db2_set_isolation(db, (cobol_orm_isolation_t)99));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_db2_set_isolation(db, COBOL_ORM_ISO_UR));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_db2_set_isolation(db, COBOL_ORM_ISO_CS));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_db2_set_isolation(db, COBOL_ORM_ISO_RS));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_db2_set_isolation(db, COBOL_ORM_ISO_RR));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
            cobol_orm_db2_set_schema(NULL, "S", 1));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_db2_set_schema(db, NULL, 1));
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_db2_set_schema(db, "MY_SCHEMA", 9));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));

  /* Legacy binary COMMAREA & DISPLAY dispatcher */
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_commarea_dispatch(NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER, cobol_orm_display_dispatch(NULL));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_legacy_reset());

  memset(&ca, 0, sizeof(ca));
  ca.opcode = 999;
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_OPCODE, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_DISCONNECT;
  ca.db_id = 0;
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_STMT_FINALIZE;
  ca.stmt_id = 99;
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_commarea_dispatch(&ca));

  ca.opcode = COBOL_ORM_OP_CONNECT;
  memcpy(ca.data1, "sqlite://:memory:", 17);
  ca.data1_len = 17;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_EXEC_SQL;
  memcpy(ca.data1, "CREATE TABLE L (ID INT, NM TEXT)", 32);
  ca.data1_len = 32;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_TX_BEGIN;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_STMT_PREPARE;
  memcpy(ca.data1, "INSERT INTO L VALUES (?, ?)", 27);
  ca.data1_len = 27;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_STMT_BIND_I32;
  ca.param_idx = 1;
  ca.val_i32 = -5;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_STMT_BIND_STR;
  ca.param_idx = 2;
  memcpy(ca.data1, "NEG", 3);
  ca.data1_len = 3;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_STMT_STEP;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_LAST_ROWID;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_STMT_FINALIZE;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_TX_COMMIT;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_LAST_ERROR;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  ca.opcode = COBOL_ORM_OP_VERSION;
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));

  /* Negative integer roundtrip through USAGE DISPLAY dispatcher */
  memset(dbuf, ' ', sizeof(dbuf));
  memcpy(dbuf, "00070000000100000000+0000000000000230000", 40);
  memcpy(dbuf + 40, "SELECT ID, NM FROM L   ", 23);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_display_dispatch(dbuf));
  memcpy(dbuf, "0010", 4);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_display_dispatch(dbuf));
  memcpy(dbuf, "0011", 4);
  memcpy(dbuf + 16, "0000", 4);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_display_dispatch(dbuf));
  ASSERT_EQ('-', dbuf[20]);
  memcpy(dbuf, "0012", 4);
  memcpy(dbuf + 16, "0001", 4);
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_display_dispatch(dbuf));
  ASSERT_EQ(0, memcmp(dbuf + 296, "NEG", 3));
  /* Also exercise negative input parsing in display_dispatch */
  dbuf[20] = '-';
  memcpy(dbuf, "0008", 4);
  ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_display_dispatch(dbuf));

  /* Exhaust legacy DB & statement handle tables (64 slots) */
  for (i = 1; i < COBOL_ORM_LEGACY_MAX_HANDLES; i++) {
    ca.opcode = COBOL_ORM_OP_CONNECT;
    memcpy(ca.data1, "sqlite://:memory:", 17);
    ca.data1_len = 17;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  }
  ca.opcode = COBOL_ORM_OP_CONNECT;
  ASSERT_EQ(COBOL_ORM_ERROR_HANDLE_TABLE_FULL,
            cobol_orm_commarea_dispatch(&ca));
  for (i = 1; i < COBOL_ORM_LEGACY_MAX_HANDLES; i++) {
    ca.opcode = COBOL_ORM_OP_STMT_PREPARE;
    ca.db_id = 1;
    memcpy(ca.data1, "SELECT 1", 8);
    ca.data1_len = 8;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
  }
  ca.opcode = COBOL_ORM_OP_STMT_PREPARE;
  ASSERT_EQ(COBOL_ORM_ERROR_HANDLE_TABLE_FULL,
            cobol_orm_commarea_dispatch(&ca));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_legacy_reset());

  /* Generated C89 shim helper 100% branch coverage */
  ASSERT_EQ(-1, cdd_cobol_str_to_pic_x("HI", NULL, 4));
  ASSERT_EQ(0, cdd_cobol_str_to_pic_x("HI", sbuf, 0));
  ASSERT_EQ(0, cdd_cobol_str_to_pic_x(NULL, sbuf, 4));
  ASSERT_EQ(0, cdd_cobol_str_to_pic_x("HI", sbuf, 4));
  ASSERT_EQ(0, memcmp(sbuf, "HI  ", 4));
  ASSERT_EQ(0, cdd_cobol_str_to_pic_x("HELLO", sbuf, 2));
  ASSERT_EQ(0, memcmp(sbuf, "HE", 2));

  PASS();
}

/**
 * @brief Deterministic OOM fault-injection sweep hitting allocation failure
 * paths across all cobol-orm C89 modules with zero leaks.
 */
TEST test_oom_fault_injection(void) {
  int k;
  cobol_orm_db_t *db = NULL;
  cobol_orm_pool_t *pool = NULL;
  cobol_orm_stmt_t *stmt = NULL;
  cobol_orm_rs_t *rs = NULL;
  cobol_orm_ast_t *ast = NULL;
  cobol_orm_cpy_t *cpy = NULL;
  cobol_orm_mig_t *mig = NULL;
  char sbuf[64];
  cobol_orm_u32_t out_len = 0;

  for (k = 1; k <= 3; k++) {
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
    if (cobol_orm_connect("sqlite://:memory:", 17, &db) == COBOL_ORM_OK) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
      db = NULL;
      break;
    }
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  }

  for (k = 1; k <= 3; k++) {
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
    if (cobol_orm_pool_init("sqlite://:memory:", 17, 1, 1, 5, &pool) ==
        COBOL_ORM_OK) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_destroy(pool));
      pool = NULL;
      break;
    }
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  }

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY, cobol_orm_exec_sql(db, "SELECT 1", 8));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));

  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY, cobol_orm_set_timezone(db, 0, "UTC", 3));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));

  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY, cobol_orm_ast_new(&ast));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(2));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY, cobol_orm_ast_new(&ast));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));

  for (k = 1; k <= 2; k++) {
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
    if (cobol_orm_stmt_prepare(db, "SELECT 1", 8, &stmt) == COBOL_ORM_OK) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_finalize(stmt));
      stmt = NULL;
      break;
    }
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  }

  for (k = 1; k <= 2; k++) {
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
    if (cobol_orm_query_abstract(db, "SELECT 1", 8, &rs) == COBOL_ORM_OK) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_rs_free(rs));
      rs = NULL;
      break;
    }
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  }

  for (k = 1; k <= 2; k++) {
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
    if (cobol_orm_mig_init(db, "/tmp", 4, &mig) == COBOL_ORM_OK) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_free(mig));
      mig = NULL;
      break;
    }
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  }

  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
            cobol_orm_ebcdic_to_utf8(COBOL_ORM_CP_IBM037,
                                     (const cobol_orm_u8_t *)"\xC1", 1, sbuf,
                                     sizeof(sbuf), &out_len));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));

  {
    cobol_orm_u16_t u16[1] = {0x0041u};
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
    ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
              cobol_orm_utf16_to_utf8(u16, 1, 0, sbuf, sizeof(sbuf), &out_len));
    ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  }

  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
            cobol_orm_cpy_parse_str("01 R. 05 X PIC X(2).", 20,
                                    COBOL_ORM_CPY_FORMAT_FREE, &cpy));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));

  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
  PASS();
}

/** @brief Mock ODBC handle allocation callback returning SQL_SUCCESS. */
static c_orm_sqlreturn_t C_ORM_SQL_API
mock_odbc_alloc(c_orm_sqlsmallint_t htype, c_orm_sqlhandle_t inp,
                c_orm_sqlhandle_t *out_h) {
  static int g_dummy_h = 1;
  if (htype < 0 && inp == NULL) {
    return C_ORM_SQL_ERROR;
  }
  *out_h = &g_dummy_h;
  return C_ORM_SQL_SUCCESS;
}

/** @brief Mock ODBC free handle callback returning SQL_SUCCESS. */
static c_orm_sqlreturn_t C_ORM_SQL_API mock_odbc_free(c_orm_sqlsmallint_t htype,
                                                      c_orm_sqlhandle_t h) {
  return (htype >= 0 && h != NULL) ? C_ORM_SQL_SUCCESS : C_ORM_SQL_SUCCESS;
}

/** @brief Mock ODBC SetEnvAttr callback returning SQL_SUCCESS. */
static c_orm_sqlreturn_t C_ORM_SQL_API
mock_odbc_set_env(c_orm_sqlhenv_t env, c_orm_sqlinteger_t attr,
                  c_orm_sqlpointer_t val, c_orm_sqlinteger_t slen) {
  return (env || attr || val || slen) ? C_ORM_SQL_SUCCESS : C_ORM_SQL_SUCCESS;
}

/** @brief Mock ODBC SetConnectAttr callback returning SQL_SUCCESS. */
static c_orm_sqlreturn_t C_ORM_SQL_API
mock_odbc_set_conn(c_orm_sqlhdbc_t dbc, c_orm_sqlinteger_t attr,
                   c_orm_sqlpointer_t val, c_orm_sqlinteger_t slen) {
  return (dbc || attr || val || slen) ? C_ORM_SQL_SUCCESS : C_ORM_SQL_SUCCESS;
}

/** @brief Mock ODBC DriverConnect callback returning SQL_SUCCESS. */
static c_orm_sqlreturn_t C_ORM_SQL_API mock_odbc_drv_connect(
    c_orm_sqlhdbc_t dbc, c_orm_sqlhwnd_t hwnd, c_orm_sqlchar_t *in_s,
    c_orm_sqlsmallint_t in_l, c_orm_sqlchar_t *out_s, c_orm_sqlsmallint_t cap,
    c_orm_sqlsmallint_t *out_l, c_orm_sqlusmallint_t comp) {
  if (out_l) {
    *out_l = 0;
  }
  return (dbc || hwnd || in_s || in_l || out_s || cap || comp)
             ? C_ORM_SQL_SUCCESS
             : C_ORM_SQL_SUCCESS;
}

/** @brief Mock ODBC Disconnect callback returning SQL_SUCCESS. */
static c_orm_sqlreturn_t C_ORM_SQL_API
mock_odbc_disconnect(c_orm_sqlhdbc_t dbc) {
  return dbc ? C_ORM_SQL_SUCCESS : C_ORM_SQL_SUCCESS;
}

/** @brief Mock vtable error-injector controlling failing SQLite-like calls. */
static int g_mock_step_has_row = 0;
static int g_mock_fail_prepare = 0;
static int g_mock_fail_bind = 0;
static int g_mock_fail_step = 0;
static int g_mock_fail_is_null = 0;
static int g_mock_fail_get = 0;

/** @brief Original SQLite prepare callback for delegating migration test. */
static c_orm_error_t (*g_real_sqlite_prepare)(c_orm_db_t *, const char *,
                                              c_orm_query_t **) = NULL;

/** @brief Delegating prepare that fails only on migration get_applied query. */
static c_orm_error_t mock_mig_orderby_fail_prepare(c_orm_db_t *d,
                                                   const char *sql,
                                                   c_orm_query_t **out_q) {
  if (strstr(sql, "SELECT version, name, hash") != NULL) {
    return C_ORM_ERROR_SQL;
  }
  return g_real_sqlite_prepare(d, sql, out_q);
}

/** @brief Mock vtable prepare method. */
static c_orm_error_t mock_vt_prepare(c_orm_db_t *db, const char *sql,
                                     c_orm_query_t **out_q) {
  static int g_q_stub = 1;
  if (g_mock_fail_prepare == 1 || !db || !sql) {
    return C_ORM_ERROR_SQL;
  }
  if (g_mock_fail_prepare == 2 && strstr(sql, "ORDER BY") != NULL) {
    return C_ORM_ERROR_SQL;
  }
  *out_q = (c_orm_query_t *)&g_q_stub;
  return C_ORM_OK;
}

/** @brief Mock vtable bind_int32 method. */
static c_orm_error_t mock_vt_bind_i32(c_orm_query_t *q, int idx, int32_t v) {
  if (g_mock_fail_bind || !q || idx < 0) {
    return C_ORM_ERROR_BIND;
  }
  return (v == 0) ? C_ORM_OK : C_ORM_OK;
}

/** @brief Mock vtable bind_int64 method. */
static c_orm_error_t mock_vt_bind_i64(c_orm_query_t *q, int idx, int64_t v) {
  if (g_mock_fail_bind || !q || idx < 0) {
    return C_ORM_ERROR_BIND;
  }
  return (v == 0) ? C_ORM_OK : C_ORM_OK;
}

/** @brief Mock AST lit callback returning OOM. */
static c_orm_error_t mock_ast_lit_fail(c_orm_ast_query_t *q, const char *v,
                                       int is_s, c_orm_ast_node_t **out) {
  return (!q || !v || is_s < 0 || !out) ? C_ORM_ERROR_MEMORY
                                        : C_ORM_ERROR_MEMORY;
}

/** @brief Mock AST eq callback returning OOM. */
static c_orm_error_t mock_ast_eq_fail(c_orm_ast_query_t *q, const char *c,
                                      const char *v, int is_s,
                                      c_orm_ast_node_t **out) {
  return (!q || !c || !v || is_s < 0 || !out) ? C_ORM_ERROR_MEMORY
                                              : C_ORM_ERROR_MEMORY;
}

/** @brief Mock AST where callback returning OOM. */
static c_orm_error_t mock_ast_where_fail(c_orm_ast_query_t *q,
                                         c_orm_ast_node_t *p) {
  return (!q || !p) ? C_ORM_ERROR_MEMORY : C_ORM_ERROR_MEMORY;
}

/** @brief Mock AST raw callback returning OOM. */
static c_orm_error_t mock_ast_raw_fail(c_orm_ast_query_t *q, const char *s,
                                       c_orm_ast_node_t **out) {
  return (!q || !s || !out) ? C_ORM_ERROR_MEMORY : C_ORM_ERROR_MEMORY;
}

/** @brief Mock vtable bind_int64 method that unconditionally returns bind
 * error. */
static c_orm_error_t mock_vt_bind_i64_always_fail(c_orm_query_t *q, int idx,
                                                  int64_t v) {
  return (!q || idx < 0 || v == 0) ? C_ORM_ERROR_BIND : C_ORM_ERROR_BIND;
}

/** @brief Mock vtable bind_double method. */
static c_orm_error_t mock_vt_bind_f64(c_orm_query_t *q, int idx, double v) {
  if (g_mock_fail_bind || !q || idx < 0) {
    return C_ORM_ERROR_BIND;
  }
  return (v == 0.0) ? C_ORM_OK : C_ORM_OK;
}

/** @brief Mock vtable bind_string method. */
static c_orm_error_t mock_vt_bind_str(c_orm_query_t *q, int idx,
                                      const char *v) {
  if (g_mock_fail_bind || !q || idx < 0 || !v) {
    return C_ORM_ERROR_BIND;
  }
  return C_ORM_OK;
}

/** @brief Mock vtable bind_blob method. */
static c_orm_error_t mock_vt_bind_blob(c_orm_query_t *q, int idx, const void *v,
                                       size_t sz) {
  if (g_mock_fail_bind || !q || idx < 0) {
    return C_ORM_ERROR_BIND;
  }
  return (v || sz == 0) ? C_ORM_OK : C_ORM_OK;
}

/** @brief Mock vtable bind_null method. */
static c_orm_error_t mock_vt_bind_null(c_orm_query_t *q, int idx) {
  if (g_mock_fail_bind || !q || idx < 0) {
    return C_ORM_ERROR_BIND;
  }
  return C_ORM_OK;
}

/** @brief Mock vtable bind_decimal method. */
static c_orm_error_t mock_vt_bind_dec(c_orm_query_t *q, int idx,
                                      const c_orm_decimal_t *d) {
  if (g_mock_fail_bind || !q || idx < 0 || !d) {
    return C_ORM_ERROR_BIND;
  }
  return C_ORM_OK;
}

/** @brief Mock vtable step method. */
static c_orm_error_t mock_vt_step(c_orm_query_t *q, int *out_has_row) {
  if (g_mock_fail_step || !q) {
    return C_ORM_ERROR_STEP;
  }
  *out_has_row = g_mock_step_has_row;
  return C_ORM_OK;
}

/** @brief Mock vtable is_null method. */
static c_orm_error_t mock_vt_is_null(c_orm_query_t *q, int idx, int *out_n) {
  if (g_mock_fail_is_null || !q || idx < 0) {
    return C_ORM_ERROR_SQL;
  }
  *out_n = 0;
  return C_ORM_OK;
}

/** @brief Mock vtable get_int32 method. */
static c_orm_error_t mock_vt_get_i32(c_orm_query_t *q, int idx, int32_t *out) {
  if (g_mock_fail_get || !q || idx < 0 || !out) {
    return C_ORM_ERROR_SQL;
  }
  *out = 1;
  return C_ORM_OK;
}

/** @brief Mock vtable get_int64 method. */
static c_orm_error_t mock_vt_get_i64(c_orm_query_t *q, int idx, int64_t *out) {
  if (g_mock_fail_get || !q || idx < 0 || !out) {
    return C_ORM_ERROR_SQL;
  }
  *out = 1;
  return C_ORM_OK;
}

/** @brief Mock vtable get_double method. */
static c_orm_error_t mock_vt_get_f64(c_orm_query_t *q, int idx, double *out) {
  if (g_mock_fail_get || !q || idx < 0 || !out) {
    return C_ORM_ERROR_SQL;
  }
  *out = 1.0;
  return C_ORM_OK;
}

/** @brief Mock vtable get_string method. */
static c_orm_error_t mock_vt_get_str(c_orm_query_t *q, int idx,
                                     const char **out) {
  if (g_mock_fail_get || !q || idx < 0 || !out) {
    return C_ORM_ERROR_SQL;
  }
  *out = "OK";
  return C_ORM_OK;
}

/** @brief Mock vtable get_blob method. */
static c_orm_error_t mock_vt_get_blob(c_orm_query_t *q, int idx,
                                      const void **out, size_t *sz) {
  if (g_mock_fail_get || !q || idx < 0 || !out || !sz) {
    return C_ORM_ERROR_SQL;
  }
  *out = NULL;
  *sz = 0;
  return C_ORM_OK;
}

/** @brief Mock vtable get_decimal method. */
static c_orm_error_t mock_vt_get_dec(c_orm_query_t *q, int idx,
                                     c_orm_decimal_t *out) {
  if (g_mock_fail_get || !q || idx < 0 || !out) {
    return C_ORM_ERROR_SQL;
  }
  memset(out, 0, sizeof(*out));
  return C_ORM_OK;
}

/** @brief Mock vtable get_column_count method. */
static c_orm_error_t mock_vt_col_cnt(c_orm_query_t *q, int *out) {
  if (g_mock_fail_get || !q || !out) {
    return C_ORM_ERROR_SQL;
  }
  *out = 0;
  return C_ORM_OK;
}

/** @brief Mock vtable get_column_name method. */
static c_orm_error_t mock_vt_col_name(c_orm_query_t *q, int idx,
                                      const char **out) {
  if (g_mock_fail_get || !q || idx < 0 || !out) {
    return C_ORM_ERROR_SQL;
  }
  *out = "C";
  return C_ORM_OK;
}

/** @brief Mock vtable get_last_insert_rowid method. */
static c_orm_error_t mock_vt_rowid(c_orm_db_t *db, int64_t *out) {
  if (!db || !out) {
    return C_ORM_ERROR_SQL;
  }
  return C_ORM_ERROR_SQL;
}

/** @brief Mock vtable finalize method. */
static c_orm_error_t mock_vt_finalize(c_orm_query_t *q) {
  return q ? C_ORM_OK : C_ORM_OK;
}

/**
 * @brief Exercises every remaining branch across all 14 C89 source modules
 * (bad-magic handles, mock driver vtable errors, mock ODBC SQLSTATE, real
 * migration up/down, full legacy opcode error matrix, and Copybook edge/OOM
 * paths) to lock 100.0% function, line, and branch coverage.
 */
TEST test_branch_and_mock_vtable_coverage(void) {
  cobol_orm_db_t bad_db;
  cobol_orm_stmt_t bad_stmt;
  cobol_orm_pool_t bad_pool;
  cobol_orm_ast_t bad_ast;
  cobol_orm_rs_t bad_rs;
  cobol_orm_mig_t bad_mig;
  cobol_orm_cpy_t bad_cpy;
  cobol_orm_u8_t bbuf[8];
  cobol_orm_u16_t u16[8];
  char sbuf[64];
  cobol_orm_u32_t out_len = 0;
  cobol_orm_i32_t i32v = 0;
  cobol_orm_i64_t i64v = 0;
  double f64v = 0.0;
  cobol_orm_decimal_t dec;
  cobol_orm_u8_t comp3[5];
  cobol_orm_db_t *db = NULL;
  cobol_orm_pool_t *pool = NULL;
  cobol_orm_ast_t *ast = NULL;
  cobol_orm_cpy_t *cpy = NULL;
  cobol_orm_mig_t *mig = NULL;
  c_orm_driver_vtable_t mock_vt;
  c_orm_db_t mock_raw_db;
  cobol_orm_db_t mock_db;
  cobol_orm_stmt_t mock_stmt;
  int dummy_q = 1;
  int k;

  memset(&bad_db, 0, sizeof(bad_db));
  memset(&bad_stmt, 0, sizeof(bad_stmt));
  memset(&bad_pool, 0, sizeof(bad_pool));
  memset(&bad_ast, 0, sizeof(bad_ast));
  memset(&bad_rs, 0, sizeof(bad_rs));
  memset(&bad_mig, 0, sizeof(bad_mig));
  memset(&bad_cpy, 0, sizeof(bad_cpy));
  memset(&dec, 0, sizeof(dec));
  memset(comp3, 0, sizeof(comp3));
  memset(bbuf, 0, sizeof(bbuf));
  memset(u16, 0, sizeof(u16));

  /* 1. Non-NULL bad-magic handles & str/shim edge branches */
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_disconnect(&bad_db));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_stmt_reset(&bad_stmt));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_pool_destroy(&bad_pool));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_ast_free(&bad_ast));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_rs_free(&bad_rs));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_mig_free(&bad_mig));
  ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE, cobol_orm_cpy_free(&bad_cpy));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_bytes_to_buf(NULL, 3, bbuf, 4, &out_len));
  ASSERT_EQ(0, cdd_cobol_str_to_pic_x("", sbuf, 4));

  /* 2. DB disconnect on from_pool=1 & set_timezone(tz_name!=NULL, tz_len=0) */
  {
    cobol_orm_db_t *pooled_stub = NULL;
    ASSERT_EQ(C_ORM_OK, c_orm_system_calloc(1, sizeof(cobol_orm_db_t),
                                            (void **)&pooled_stub));
    pooled_stub->magic = COBOL_ORM_MAGIC_DB;
    pooled_stub->from_pool = 1;
    pooled_stub->raw = NULL;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(pooled_stub));
  }
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_set_timezone(db, 0, "UTC", 0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
  db = NULL;

  /* 3. Pool: OOM on pool_acquire + release with tz_name == NULL */
  ASSERT_EQ(COBOL_ORM_OK,
            cobol_orm_pool_init("sqlite://:memory:", 17, 1, 1, 5, &pool));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
  ASSERT_EQ(COBOL_ORM_ERROR_MEMORY, cobol_orm_pool_acquire(pool, &db));
  ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_acquire(pool, &db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_release(pool, db));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_pool_destroy(pool));

  /* 4. EBCDIC & UTF-16 individual NULL arg branches + ebcdic_to_utf8 err */
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_ebcdic_to_utf8(COBOL_ORM_CP_IBM037, bbuf, 1, NULL, 8,
                                     &out_len));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NULL_POINTER,
      cobol_orm_ebcdic_to_utf8(COBOL_ORM_CP_IBM037, bbuf, 1, sbuf, 8, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_CODEPAGE,
            cobol_orm_ebcdic_to_utf8(COBOL_ORM_CP_UTF8,
                                     (const cobol_orm_u8_t *)"\xFF", 1, sbuf,
                                     sizeof(sbuf), &out_len));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NULL_POINTER,
      cobol_orm_utf8_to_ebcdic(COBOL_ORM_CP_IBM037, "A", 1, NULL, 8, &out_len));
  ASSERT_EQ(
      COBOL_ORM_ERROR_NULL_POINTER,
      cobol_orm_utf8_to_ebcdic(COBOL_ORM_CP_IBM037, "A", 1, bbuf, 8, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_utf8_to_utf16("A", 1, 1, NULL, 8, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_utf8_to_utf16("A", 1, 1, u16, 8, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_utf16_to_utf8(u16, 1, 1, NULL, 8, &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_utf16_to_utf8(u16, 1, 1, sbuf, 8, NULL));

  /* 5. Mock ODBC driver -> cobol_orm_odbc_sqlstate success path */
  {
    c_orm_odbc_api_t odbc_api;
    cobol_orm_db_t *odbc_db = NULL;
    memset(&odbc_api, 0, sizeof(odbc_api));
    odbc_api.SQLAllocHandle = mock_odbc_alloc;
    odbc_api.SQLFreeHandle = mock_odbc_free;
    odbc_api.SQLSetEnvAttr = mock_odbc_set_env;
    odbc_api.SQLSetConnectAttr = mock_odbc_set_conn;
    odbc_api.SQLDriverConnect = mock_odbc_drv_connect;
    odbc_api.SQLDisconnect = mock_odbc_disconnect;
    ASSERT_EQ(C_ORM_OK, c_orm_odbc_set_mock_api(&odbc_api));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("odbc://DSN=MOCK", 15, &odbc_db));
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_odbc_sqlstate(odbc_db, sbuf, sizeof(sbuf), &out_len));
    ASSERT_EQ(5u, out_len);
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(odbc_db));
    /* Exercise legacy OP_LAST_ROWID error branch via ODBC mock (unsupported) */
    {
      cobol_orm_commarea_t oca;
      memset(&oca, 0, sizeof(oca));
      oca.opcode = COBOL_ORM_OP_CONNECT;
      memcpy(oca.data1, "odbc://DSN=MOCK", 15);
      oca.data1_len = 15;
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&oca));
      oca.opcode = COBOL_ORM_OP_LAST_ROWID;
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
      ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&oca));
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      oca.opcode = COBOL_ORM_OP_DISCONNECT;
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&oca));
    }
    ASSERT_EQ(C_ORM_OK, c_orm_odbc_set_mock_api(NULL));
  }

  /* 6. Real migration directory: up + down + OOM on get_applied */
  {
    const char *mdir = "/tmp/cobol_orm_mig_cov_dir";
    const char *mup = "/tmp/cobol_orm_mig_cov_dir/001_init.up.sql";
    const char *mdn = "/tmp/cobol_orm_mig_cov_dir/001_init.down.sql";
    FILE *fp = NULL;
    cobol_orm_u32_t applied = 0;
    int mk_rc;
#if defined(_WIN32)
    mk_rc = _mkdir(mdir);
#else
    mk_rc = mkdir(mdir, (mode_t)0755);
#endif
    ASSERT(mk_rc == 0 || mk_rc == -1);
    fp = fopen(mup, "wb");
    ASSERT(fp != NULL);
    ASSERT(fputs("CREATE TABLE MT (ID INT);\n", fp) >= 0);
    ASSERT_EQ(0, fclose(fp));
    fp = fopen(mdn, "wb");
    ASSERT(fp != NULL);
    ASSERT(fputs("DROP TABLE MT;\n", fp) >= 0);
    ASSERT_EQ(0, fclose(fp));

    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_init(
                                db, mdir, (cobol_orm_u32_t)strlen(mdir), &mig));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_up(mig, 0, &applied));
    ASSERT_EQ(1u, applied);
    /* Test cobol_orm_mig_up when c_orm_migrate_up succeeds and
     * c_orm_migration_get_applied fails (delegating real SQLite vtable) */
    {
      const c_orm_driver_vtable_t *orig_vt = db->raw->vtable;
      c_orm_driver_vtable_t wrap_vt = *orig_vt;
      g_real_sqlite_prepare = orig_vt->prepare;
      wrap_vt.prepare = mock_mig_orderby_fail_prepare;
      db->raw->vtable = &wrap_vt;
      ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_mig_up(mig, 0, &applied));
      db->raw->vtable = orig_vt;
    }
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_down(mig, 1, 0));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_up(mig, 0, &applied));
    /* Re-run mig_up when already up-to-date while injecting OOM */
    for (k = 1; k <= 25; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_mig_up(mig, 0, &applied) == COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }

    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_mig_free(mig));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
    ASSERT_EQ(0, remove(mup));
    ASSERT_EQ(0, remove(mdn));
#if defined(_WIN32)
    _rmdir(mdir);
#else
    ASSERT_EQ(0, rmdir(mdir));
#endif
  }

  /* 7. Mock vtable error branches for db (rowid) + stmt (all 11 getters) */
  memset(&mock_vt, 0, sizeof(mock_vt));
  mock_vt.prepare = mock_vt_prepare;
  mock_vt.bind_int32 = mock_vt_bind_i32;
  mock_vt.bind_int64 = mock_vt_bind_i64;
  mock_vt.bind_double = mock_vt_bind_f64;
  mock_vt.bind_string = mock_vt_bind_str;
  mock_vt.bind_blob = mock_vt_bind_blob;
  mock_vt.bind_null = mock_vt_bind_null;
  mock_vt.bind_decimal = mock_vt_bind_dec;
  mock_vt.step = mock_vt_step;
  mock_vt.is_null = mock_vt_is_null;
  mock_vt.get_int32 = mock_vt_get_i32;
  mock_vt.get_int64 = mock_vt_get_i64;
  mock_vt.get_double = mock_vt_get_f64;
  mock_vt.get_string = mock_vt_get_str;
  mock_vt.get_blob = mock_vt_get_blob;
  mock_vt.get_decimal = mock_vt_get_dec;
  mock_vt.get_column_count = mock_vt_col_cnt;
  mock_vt.get_column_name = mock_vt_col_name;
  mock_vt.get_last_insert_rowid = mock_vt_rowid;
  mock_vt.finalize = mock_vt_finalize;

  memset(&mock_raw_db, 0, sizeof(mock_raw_db));
  mock_raw_db.vtable = &mock_vt;
  memset(&mock_db, 0, sizeof(mock_db));
  mock_db.magic = COBOL_ORM_MAGIC_DB;
  mock_db.raw = &mock_raw_db;
  memset(&mock_stmt, 0, sizeof(mock_stmt));
  mock_stmt.magic = COBOL_ORM_MAGIC_STMT;
  mock_stmt.db = &mock_db;
  mock_stmt.raw = (c_orm_query_t *)&dummy_q;

  g_mock_fail_step = 1;
  g_mock_fail_is_null = 1;
  g_mock_fail_get = 1;
  ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_last_insert_rowid(&mock_db, &i64v));
  ASSERT_EQ(COBOL_ORM_OK, cobol_orm_stmt_bind_blob(&mock_stmt, 1, NULL, 0));
  ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
            cobol_orm_stmt_col_comp3(&mock_stmt, 0, 5, 2, 1,
                                     COBOL_ORM_ROUND_HALF_UP, comp3, 5, NULL));
  ASSERT_EQ(COBOL_ORM_ERROR_STEP, cobol_orm_stmt_step(&mock_stmt, &i32v));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_stmt_col_count(&mock_stmt, &i32v));
  ASSERT_EQ(
      COBOL_ORM_ERROR_SQL,
      cobol_orm_stmt_col_name(&mock_stmt, 0, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL,
            cobol_orm_stmt_col_is_null(&mock_stmt, 0, &i32v));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_stmt_col_i32(&mock_stmt, 0, &i32v));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_stmt_col_i64(&mock_stmt, 0, &i64v));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_stmt_col_f64(&mock_stmt, 0, &f64v));
  ASSERT_EQ(
      COBOL_ORM_ERROR_SQL,
      cobol_orm_stmt_col_str(&mock_stmt, 0, sbuf, sizeof(sbuf), &out_len));
  ASSERT_EQ(
      COBOL_ORM_ERROR_SQL,
      cobol_orm_stmt_col_blob(&mock_stmt, 0, bbuf, sizeof(bbuf), &out_len));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL,
            cobol_orm_stmt_col_decimal(&mock_stmt, 0, &dec));
  ASSERT_EQ(COBOL_ORM_ERROR_SQL,
            cobol_orm_stmt_col_comp3(&mock_stmt, 0, 5, 2, 1,
                                     COBOL_ORM_ROUND_HALF_UP, comp3, 5,
                                     &out_len));

  /* 8. Query AST error branches (lit/eq/where/raw/to_sql) via callback
   * injection */
  {
    c_orm_error_t (*orig_lit)(c_orm_ast_query_t *, const char *, int,
                              c_orm_ast_node_t **);
    c_orm_error_t (*orig_eq)(c_orm_ast_query_t *, const char *, const char *,
                             int, c_orm_ast_node_t **);
    c_orm_error_t (*orig_where)(c_orm_ast_query_t *, c_orm_ast_node_t *);
    c_orm_error_t (*orig_raw)(c_orm_ast_query_t *, const char *,
                              c_orm_ast_node_t **);

    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_new(&ast));
    orig_lit = ast->raw->lit;
    ast->raw->lit = mock_ast_lit_fail;
    ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
              cobol_orm_ast_set_col(ast, "C", 1, "1", 1, 0));
    ast->raw->lit = orig_lit;

    orig_eq = ast->raw->eq;
    ast->raw->eq = mock_ast_eq_fail;
    ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
              cobol_orm_ast_where_eq(ast, "C", 1, "1", 1, 0));
    ast->raw->eq = orig_eq;

    orig_where = ast->raw->where;
    ast->raw->where = mock_ast_where_fail;
    ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
              cobol_orm_ast_where_eq(ast, "C", 1, "1", 1, 0));
    ast->raw->where = orig_where;

    orig_raw = ast->raw->raw;
    ast->raw->raw = mock_ast_raw_fail;
    ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
              cobol_orm_ast_join(ast, COBOL_ORM_JOIN_INNER, "B", 1, "1=1", 3));
    ast->raw->raw = orig_raw;

    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_select(ast, "A", 1));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_from(ast, "T", 1));
    for (k = 1; k <= 10; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_ast_to_sql(ast, COBOL_ORM_DIALECT_SQLITE, sbuf,
                               sizeof(sbuf), &out_len) == COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_ast_free(ast));
  }

  /* 9. Legacy dispatcher: EVERY opcode invalid-handle + rollback/disconnect/err
   */
  {
    cobol_orm_commarea_t ca;
    char dbuf[COBOL_ORM_DISPLAY_COMMAREA_SIZE];
    int ops_db[] = {COBOL_ORM_OP_DISCONNECT,  COBOL_ORM_OP_EXEC_SQL,
                    COBOL_ORM_OP_TX_BEGIN,    COBOL_ORM_OP_TX_COMMIT,
                    COBOL_ORM_OP_TX_ROLLBACK, COBOL_ORM_OP_STMT_PREPARE,
                    COBOL_ORM_OP_LAST_ERROR,  COBOL_ORM_OP_LAST_ROWID};
    int ops_st[] = {COBOL_ORM_OP_STMT_BIND_I32, COBOL_ORM_OP_STMT_BIND_STR,
                    COBOL_ORM_OP_STMT_STEP,     COBOL_ORM_OP_STMT_COL_I32,
                    COBOL_ORM_OP_STMT_COL_STR,  COBOL_ORM_OP_STMT_FINALIZE};
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_legacy_reset());
    for (k = 0; k < (int)(sizeof(ops_db) / sizeof(ops_db[0])); k++) {
      memset(&ca, 0, sizeof(ca));
      ca.opcode = ops_db[k];
      ca.db_id = 99;
      ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
                cobol_orm_commarea_dispatch(&ca));
      ca.db_id = 5;
      ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
                cobol_orm_commarea_dispatch(&ca));
    }
    for (k = 0; k < (int)(sizeof(ops_st) / sizeof(ops_st[0])); k++) {
      memset(&ca, 0, sizeof(ca));
      ca.opcode = ops_st[k];
      ca.stmt_id = 0;
      ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
                cobol_orm_commarea_dispatch(&ca));
      ca.stmt_id = 99;
      ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
                cobol_orm_commarea_dispatch(&ca));
      ca.stmt_id = 5;
      ASSERT_EQ(COBOL_ORM_ERROR_INVALID_HANDLE,
                cobol_orm_commarea_dispatch(&ca));
    }
    /* Connect failure + data1_len=0 and >256 */
    memset(&ca, 0, sizeof(ca));
    ca.opcode = COBOL_ORM_OP_CONNECT;
    memcpy(ca.data1, "badscheme://x", 13);
    ca.data1_len = 0;
    ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    ca.data1_len = 999;
    ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    /* Valid connect + bad prepare + rollback + disconnect */
    memset(&ca, 0, sizeof(ca));
    ca.opcode = COBOL_ORM_OP_CONNECT;
    memcpy(ca.data1, "sqlite://:memory:", 17);
    ca.data1_len = 17;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    ca.opcode = COBOL_ORM_OP_STMT_PREPARE;
    memcpy(ca.data1, "BAD SQL", 7);
    ca.data1_len = 7;
    ASSERT_NEQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    ca.opcode = COBOL_ORM_OP_TX_BEGIN;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    ca.opcode = COBOL_ORM_OP_TX_ROLLBACK;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    ca.opcode = COBOL_ORM_OP_DISCONNECT;
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_commarea_dispatch(&ca));
    /* Display dispatch with non-digit character hits parse_disp_u32 branch */
    memset(dbuf, ' ', sizeof(dbuf));
    memcpy(dbuf, "0015", 4);
    dbuf[8] = 'X';
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_display_dispatch(dbuf));
  }

  /* 10. Copybook edge cases: FILLER-only, REDEFINES, NULL hydration, 2 rows
   * with max_rows=1, DCLGEN PK, numeric non-range 88, mock vtable errors, OOM
   */
  {
    static const char k_filler_only[] = "01 F-ONLY. 05 FILLER PIC X(4).";
    static const char k_rich[] = "01 RICH-REC.\n"
                                 "   05 R-ID    PIC S9(9) COMP-5.\n"
                                 "   05 R-ALIAS REDEFINES R-ID PIC X(4).\n"
                                 "   05 R-NUM   PIC S9(4) COMP-5.\n"
                                 "      88 N-OK VALUE 7.\n"
                                 "   05 R-STR   PIC X(4).\n"
                                 "      88 S-OK VALUE 'A' THRU 'C'.\n"
                                 "   05 R-FLT   COMP-1.\n"
                                 "   05 R-DEC   PIC S9(5)V99 COMP-3.\n"
                                 "   66 R-REN   RENAMES R-ID.\n";
    cobol_orm_u8_t rbuf[64];
    cobol_orm_u8_t rout[128];
    cobol_orm_u32_t rcnt = 0;

    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_cpy_parse_str(k_filler_only,
                                      (cobol_orm_u32_t)strlen(k_filler_only),
                                      COBOL_ORM_CPY_FORMAT_FREE, &cpy));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(cpy));

    /* OOM on wrap_cpy_record calloc #1 and #2 */
    {
      static const char k_small[] = "01 S-REC. 05 S-ID PIC S9(9) COMP-5.";
      cobol_orm_cpy_t *sc = NULL;
      for (k = 1; k <= 80; k++) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
        if (cobol_orm_cpy_parse_str(k_small, (cobol_orm_u32_t)strlen(k_small),
                                    COBOL_ORM_CPY_FORMAT_FREE,
                                    &sc) == COBOL_ORM_OK) {
          ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
          ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(sc));
          break;
        }
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      }
    }

    cpy = NULL;
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_cpy_parse_str(k_rich, (cobol_orm_u32_t)strlen(k_rich),
                                      COBOL_ORM_CPY_FORMAT_FREE, &cpy));
    ASSERT(cpy != NULL);

    /* Prefix mismatch in str_eq_ci & sql_name match in cpy_set_pk */
    ASSERT_EQ(COBOL_ORM_ERROR_NOT_FOUND, cobol_orm_cpy_set_pk(cpy, "R", 1));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_set_pk(cpy, "R_ID", 4));

    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_cpy_create_table(db, cpy, COBOL_ORM_DIALECT_SQLITE));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_exec_sql(db, "DROP TABLE RICH_REC", 19));
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_exec_sql(
                  db,
                  "CREATE TABLE RICH_REC (R_ID INT, R_NUM INT, R_STR TEXT, "
                  "R_FLT REAL, R_DEC NUMERIC)",
                  83));
    /* Insert row with NULL columns via raw SQL to exercise NULL hydration */
    ASSERT_EQ(
        COBOL_ORM_OK,
        cobol_orm_exec_sql(
            db, "INSERT INTO RICH_REC VALUES (1, 7, NULL, 1.5, 10.25)", 52));
    ASSERT_EQ(
        COBOL_ORM_OK,
        cobol_orm_exec_sql(
            db, "INSERT INTO RICH_REC VALUES (2, 7, 'B', 2.5, 20.50)", 51));
    ASSERT_EQ(COBOL_ORM_OK,
              cobol_orm_cpy_find_i32(db, cpy, 1, COBOL_ORM_CP_ASCII, 0, rout,
                                     sizeof(rout)));
    ASSERT_EQ(
        COBOL_ORM_ERROR_NULL_POINTER,
        cobol_orm_cpy_find_all(db, cpy, COBOL_ORM_CP_ASCII, 0, rout, 1, NULL));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_find_all(db, cpy, COBOL_ORM_CP_ASCII,
                                                   0, rout, 1, &rcnt));
    ASSERT_EQ(1u, rcnt);

    /* Build valid rbuf for rich copybook (R-ID=3, R-NUM=7, R-STR='B   ',
     * R-FLT=1.0f, R-DEC=12.34) and test numeric-88 fail + valid insert */
    memset(rbuf, 0, sizeof(rbuf));
    {
      cobol_orm_i32_t idv = 3;
      cobol_orm_i16_t numv = 9;
      float fv = 1.25f;
      cobol_orm_decimal_t dv;
      cobol_orm_u32_t cw = 0;
      memcpy(rbuf + 0, &idv, 4);
      memcpy(rbuf + 4, &numv, 2);
      memcpy(rbuf + 6, "B   ", 4);
      memcpy(rbuf + 10, &fv, 4);
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_dec_from_str("12.34", 5, &dv));
      ASSERT_EQ(COBOL_ORM_OK,
                cobol_orm_dec_to_comp3(&dv, 5, 2, 1, rbuf + 14, 4, &cw));
      ASSERT_EQ(
          COBOL_ORM_ERROR_VALIDATION,
          cobol_orm_cpy_validate_88(cpy, rbuf, 18, COBOL_ORM_CP_ASCII, 0));
      numv = 7;
      memcpy(rbuf + 4, &numv, 2);
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_validate_88(cpy, rbuf, 18,
                                                        COBOL_ORM_CP_ASCII, 0));
    }

    /* Mock vtable error branches inside copybook CRUD */
    g_mock_fail_prepare = 1;
    ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_cpy_insert(&mock_db, cpy, rbuf, 18,
                                                        COBOL_ORM_CP_ASCII, 0));
    ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_cpy_update(&mock_db, cpy, rbuf, 18,
                                                        COBOL_ORM_CP_ASCII, 0));
    ASSERT_EQ(COBOL_ORM_ERROR_SQL,
              cobol_orm_cpy_find_i32(&mock_db, cpy, 1, COBOL_ORM_CP_ASCII, 0,
                                     rout, sizeof(rout)));
    ASSERT_EQ(COBOL_ORM_ERROR_SQL,
              cobol_orm_cpy_find_all(&mock_db, cpy, COBOL_ORM_CP_ASCII, 0, rout,
                                     2, &rcnt));
    ASSERT_EQ(COBOL_ORM_ERROR_SQL, cobol_orm_cpy_delete_i32(&mock_db, cpy, 1));

    g_mock_fail_prepare = 0;
    g_mock_fail_bind = 1;
    ASSERT_EQ(
        COBOL_ORM_ERROR_BIND,
        cobol_orm_cpy_insert(&mock_db, cpy, rbuf, 18, COBOL_ORM_CP_ASCII, 0));
    ASSERT_EQ(
        COBOL_ORM_ERROR_BIND,
        cobol_orm_cpy_update(&mock_db, cpy, rbuf, 18, COBOL_ORM_CP_ASCII, 0));
    ASSERT_EQ(COBOL_ORM_ERROR_BIND,
              cobol_orm_cpy_find_i32(&mock_db, cpy, 1, COBOL_ORM_CP_ASCII, 0,
                                     rout, sizeof(rout)));
    ASSERT_EQ(COBOL_ORM_ERROR_BIND, cobol_orm_cpy_delete_i32(&mock_db, cpy, 1));

    g_mock_fail_bind = 0;
    g_mock_fail_step = 1;
    ASSERT_EQ(COBOL_ORM_ERROR_STEP,
              cobol_orm_cpy_find_i32(&mock_db, cpy, 1, COBOL_ORM_CP_ASCII, 0,
                                     rout, sizeof(rout)));
    ASSERT_EQ(COBOL_ORM_ERROR_STEP,
              cobol_orm_cpy_find_all(&mock_db, cpy, COBOL_ORM_CP_ASCII, 0, rout,
                                     2, &rcnt));

    g_mock_fail_step = 0;
    g_mock_step_has_row = 1;
    g_mock_fail_is_null = 1;
    ASSERT_EQ(COBOL_ORM_ERROR_SQL,
              cobol_orm_cpy_find_i32(&mock_db, cpy, 1, COBOL_ORM_CP_ASCII, 0,
                                     rout, sizeof(rout)));
    ASSERT_EQ(COBOL_ORM_ERROR_SQL,
              cobol_orm_cpy_find_all(&mock_db, cpy, COBOL_ORM_CP_ASCII, 0, rout,
                                     2, &rcnt));

    g_mock_fail_is_null = 0;
    g_mock_fail_get = 1;
    ASSERT_EQ(COBOL_ORM_ERROR_SQL,
              cobol_orm_cpy_find_i32(&mock_db, cpy, 1, COBOL_ORM_CP_ASCII, 0,
                                     rout, sizeof(rout)));

    /* OOM sweeps on copybook CRUD operations */
    for (k = 1; k <= 20; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_emit_ddl(cpy, COBOL_ORM_DIALECT_SQLITE, sbuf,
                                 sizeof(sbuf), &out_len) == COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 20; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_create_table(db, cpy, COBOL_ORM_DIALECT_SQLITE) ==
          COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 20; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_validate_88(cpy, rbuf, 18, COBOL_ORM_CP_ASCII, 0) ==
          COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 25; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_insert(db, cpy, rbuf, 18, COBOL_ORM_CP_ASCII, 0) ==
          COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 25; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_update(db, cpy, rbuf, 18, COBOL_ORM_CP_ASCII, 0) ==
          COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 25; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_find_i32(db, cpy, 2, COBOL_ORM_CP_ASCII, 0, rout,
                                 sizeof(rout)) == COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 25; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_find_all(db, cpy, COBOL_ORM_CP_ASCII, 0, rout, 2,
                                 &rcnt) == COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }
    for (k = 1; k <= 15; k++) {
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
      if (cobol_orm_cpy_delete_i32(db, cpy, 3) == COBOL_ORM_OK) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
        break;
      }
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
    }

    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(cpy));
    ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));

    /* 11. DCLGEN copybook (PK + VARCHAR + FOR BIT DATA BLOB + DISPLAY V99 +
     * level-88 numeric on DECIMAL + range low/high bounds + parse_file NULL/OOM
     * + PK bind fail on update) */
    {
      static const char k_dcl[] = "EXEC SQL DECLARE DCL_TBL TABLE (\n"
                                  "  D_CODE INT,\n"
                                  "  D_PK INT PRIMARY KEY,\n"
                                  "  D_RAW CHAR(4) FOR BIT DATA,\n"
                                  "  D_VTXT VARCHAR(8),\n"
                                  "  D_AMT DECIMAL(5,2)\n"
                                  ") END-EXEC.\n"
                                  "01 DCL-REC.\n"
                                  "   05 D-CODE   PIC S9(9) COMP-5.\n"
                                  "      88 DC-OK VALUE 5 THRU 10.\n"
                                  "   05 D-PK     PIC S9(9) COMP-5.\n"
                                  "   05 D-RAW    PIC X(4).\n"
                                  "   05 D-VTXT.\n"
                                  "      49 D-VTXT-LEN  PIC S9(4) COMP-5.\n"
                                  "      49 D-VTXT-TEXT PIC X(8).\n"
                                  "   05 D-AMT    PIC S9(3)V99.\n"
                                  "      88 AMT-ZERO VALUE 0.\n";
      cobol_orm_cpy_t *dcpy = NULL;
      cobol_orm_u8_t dbuf2[64];
      cobol_orm_u8_t dout2[64];
      cobol_orm_cpy_info_t dinfo;
      cobol_orm_i32_t dcode = 7;
      cobol_orm_i32_t dpk = 42;
      cobol_orm_i16_t vlen = 2;
      size_t orig_nc = 0;

      ASSERT_EQ(COBOL_ORM_ERROR_NULL_POINTER,
                cobol_orm_cpy_parse_file("/tmp/x.cpy", 10,
                                         COBOL_ORM_CPY_FORMAT_AUTO, NULL));
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(1));
      ASSERT_EQ(COBOL_ORM_ERROR_MEMORY,
                cobol_orm_cpy_parse_file("/tmp/x.cpy", 10,
                                         COBOL_ORM_CPY_FORMAT_AUTO, &dcpy));
      ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));

      ASSERT_EQ(COBOL_ORM_OK,
                cobol_orm_cpy_parse_str(k_dcl, (cobol_orm_u32_t)strlen(k_dcl),
                                        COBOL_ORM_CPY_FORMAT_FREE, &dcpy));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_info(dcpy, &dinfo));
      ASSERT_EQ(1, dinfo.has_dclgen);

      /* Exercise str_eq_ci eq3 (sql_name distinct from cobol_name & c_name) */
      {
        char *orig_c = dcpy->elem_fields[1]->c_name;
        ((c_orm_cobol_field_t *)(size_t)dcpy->elem_fields[1])->c_name =
            (char *)(size_t)"other_c";
        ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_set_pk(dcpy, "D_PK", 4));
        ((c_orm_cobol_field_t *)(size_t)dcpy->elem_fields[1])->c_name = orig_c;
      }

      /* Build record buffer & test low/high range bounds + numeric-on-decimal
       */
      memset(dbuf2, 0, sizeof(dbuf2));
      dcode = 1;
      memcpy(dbuf2 + 0, &dcode, 4);
      memcpy(dbuf2 + 4, &dpk, 4);
      memcpy(dbuf2 + 8, "\x01\x02\x03\x04", 4);
      memcpy(dbuf2 + 12, &vlen, 2);
      memcpy(dbuf2 + 14, "HI      ", 8);
      memcpy(dbuf2 + 22, "00125", 5);
      ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
                cobol_orm_cpy_validate_88(dcpy, dbuf2, dinfo.total_byte_size,
                                          COBOL_ORM_CP_ASCII, 0));
      dcode = 99;
      memcpy(dbuf2 + 0, &dcode, 4);
      ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
                cobol_orm_cpy_validate_88(dcpy, dbuf2, dinfo.total_byte_size,
                                          COBOL_ORM_CP_ASCII, 0));
      dcode = 7;
      memcpy(dbuf2 + 0, &dcode, 4);
      /* AMT-ZERO has numeric 88 on DECIMAL (not INT) -> hits branch 351/358 */
      ASSERT_EQ(COBOL_ORM_ERROR_VALIDATION,
                cobol_orm_cpy_validate_88(dcpy, dbuf2, dinfo.total_byte_size,
                                          COBOL_ORM_CP_ASCII, 0));
      /* Temporarily clear conditions on D-AMT so insert/find exercise BLOB +
       * DISPLAY V99 */
      orig_nc = dcpy->elem_fields[4]->num_conditions;
      ((c_orm_cobol_field_t *)(size_t)dcpy->elem_fields[4])->num_conditions = 0;

      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_connect("sqlite://:memory:", 17, &db));
      ASSERT_EQ(COBOL_ORM_OK,
                cobol_orm_cpy_create_table(db, dcpy, COBOL_ORM_DIALECT_SQLITE));
      ASSERT_EQ(COBOL_ORM_OK,
                cobol_orm_cpy_insert(db, dcpy, dbuf2, dinfo.total_byte_size,
                                     COBOL_ORM_CP_ASCII, 0));
      ASSERT_EQ(COBOL_ORM_OK,
                cobol_orm_cpy_find_i32(db, dcpy, 42, COBOL_ORM_CP_ASCII, 0,
                                       dout2, sizeof(dout2)));
      /* Insert 0-byte BLOB row to exercise blen == 0 branch in
       * hydrate_row_for_cpy */
      ASSERT_EQ(
          COBOL_ORM_OK,
          cobol_orm_exec_sql(
              db, "INSERT INTO DCL_TBL VALUES (7, 43, X'', 'HI', 1.25)", 52));
      ASSERT_EQ(COBOL_ORM_OK,
                cobol_orm_cpy_find_i32(db, dcpy, 43, COBOL_ORM_CP_ASCII, 0,
                                       dout2, sizeof(dout2)));
      /* OOM sweep on find_i32 over DCLGEN row (hits BLOB & STRING malloc OOM)
       */
      for (k = 1; k <= 30; k++) {
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(k));
        if (cobol_orm_cpy_find_i32(db, dcpy, 42, COBOL_ORM_CP_ASCII, 0, dout2,
                                   sizeof(dout2)) == COBOL_ORM_OK) {
          ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
          break;
        }
        ASSERT_EQ(COBOL_ORM_OK, set_oom_at(0));
      }
      /* Mock get_blob error branch on DCLGEN copybook */
      g_mock_fail_prepare = 0;
      g_mock_fail_bind = 0;
      g_mock_fail_step = 0;
      g_mock_step_has_row = 1;
      g_mock_fail_is_null = 0;
      g_mock_fail_get = 0;
      mock_vt.get_blob = mock_vt_get_blob;
      /* Fail only get_blob while int64/double/string succeed */
      {
        static const char k_b1[] =
            "EXEC SQL DECLARE B1_T TABLE (B1 CHAR(4) FOR BIT DATA) END-EXEC.\n"
            "01 B1-R. 05 B1 PIC X(4).";
        static const char k_s1[] = "01 S1-R. 05 S1 PIC X(4).";
        cobol_orm_cpy_t *bcpy = NULL;
        ASSERT_EQ(COBOL_ORM_OK,
                  cobol_orm_cpy_parse_str(k_b1, (cobol_orm_u32_t)strlen(k_b1),
                                          COBOL_ORM_CPY_FORMAT_FREE, &bcpy));
        g_mock_fail_get = 1;
        ASSERT_EQ(COBOL_ORM_ERROR_SQL,
                  cobol_orm_cpy_find_i32(&mock_db, bcpy, 1, COBOL_ORM_CP_ASCII,
                                         0, dout2, sizeof(dout2)));
        ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(bcpy));
        ASSERT_EQ(COBOL_ORM_OK,
                  cobol_orm_cpy_parse_str(k_s1, (cobol_orm_u32_t)strlen(k_s1),
                                          COBOL_ORM_CPY_FORMAT_FREE, &bcpy));
        ASSERT_EQ(COBOL_ORM_ERROR_SQL,
                  cobol_orm_cpy_find_i32(&mock_db, bcpy, 1, COBOL_ORM_CP_ASCII,
                                         0, dout2, sizeof(dout2)));
        g_mock_fail_get = 0;
        ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(bcpy));
      }
      ((c_orm_cobol_field_t *)(size_t)dcpy->elem_fields[4])->num_conditions =
          orig_nc;

      /* Test string range lower-bound failure ('A' < 'B') in validate_88 */
      {
        static const char k_sr[] =
            "01 SR-REC. 05 SR-CH PIC X(1). 88 SR-AC VALUE 'B' THRU 'D'.";
        cobol_orm_cpy_t *srcpy = NULL;
        cobol_orm_u8_t ch = (cobol_orm_u8_t)'A';
        ASSERT_EQ(COBOL_ORM_OK,
                  cobol_orm_cpy_parse_str(k_sr, (cobol_orm_u32_t)strlen(k_sr),
                                          COBOL_ORM_CPY_FORMAT_FREE, &srcpy));
        ASSERT_EQ(
            COBOL_ORM_ERROR_VALIDATION,
            cobol_orm_cpy_validate_88(srcpy, &ch, 1, COBOL_ORM_CP_ASCII, 0));
        ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(srcpy));
      }

      /* Exercise PK bind failure in cpy_update (non-PK binds OK, PK bind fails)
       */
      g_mock_fail_prepare = 0;
      g_mock_fail_bind = 0;
      {
        static const char k_two[] =
            "01 TWO-REC. 05 T-PK PIC S9(9) COMP-5. 05 T-STR PIC X(4).";
        cobol_orm_cpy_t *tcpy = NULL;
        cobol_orm_u8_t tbuf[8];
        memset(tbuf, 0, sizeof(tbuf));
        memcpy(tbuf + 4, "ABCD", 4);
        ASSERT_EQ(COBOL_ORM_OK,
                  cobol_orm_cpy_parse_str(k_two, (cobol_orm_u32_t)strlen(k_two),
                                          COBOL_ORM_CPY_FORMAT_FREE, &tcpy));
        mock_vt.bind_int64 = mock_vt_bind_i64_always_fail;
        ASSERT_EQ(COBOL_ORM_ERROR_BIND,
                  cobol_orm_cpy_update(&mock_db, tcpy, tbuf, 8,
                                       COBOL_ORM_CP_ASCII, 0));
        mock_vt.bind_int64 = mock_vt_bind_i64;
        ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(tcpy));
      }

      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_cpy_free(dcpy));
      ASSERT_EQ(COBOL_ORM_OK, cobol_orm_disconnect(db));
    }
  }

  PASS();
}

/**
 * @brief Registers and executes all cobol-orm C89 test cases.
 */
SUITE(cobol_orm_c_suite) {
  RUN_TEST(test_abi_str_and_errors);
  RUN_TEST(test_db_and_tx);
  RUN_TEST(test_pool);
  RUN_TEST(test_stmt_and_abstract);
  RUN_TEST(test_query_ast);
  RUN_TEST(test_decimal_and_ebcdic);
  RUN_TEST(test_copybook_crud);
  RUN_TEST(test_migrations_enterprise_legacy_shim);
  RUN_TEST(test_oom_fault_injection);
  RUN_TEST(test_branch_and_mock_vtable_coverage);
}

GREATEST_MAIN_DEFS();

/**
 * @brief Main test runner entry point.
 *
 * @param[in] argc CLI argument count.
 * @param[in] argv CLI argument vector.
 * @return 0 if all tests pass, non-zero otherwise.
 */
int main(int argc, char **argv) {
  GREATEST_MAIN_BEGIN();
  RUN_SUITE(cobol_orm_c_suite);
  GREATEST_MAIN_END();
}
