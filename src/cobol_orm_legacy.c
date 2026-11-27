/**
 * @file cobol_orm_legacy.c
 * @brief Legacy integer-handle registry, binary COMMAREA dispatcher, and
 * endian-independent 552-byte USAGE DISPLAY COMMAREA dispatcher supporting
 * COBOL-60, COBOL-61, COBOL-61 Extended, COBOL-65, COBOL-68, COBOL-74, and
 * COBOL-85 callers without `USAGE POINTER` or `BY VALUE`.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
#include <string.h>
/* clang-format on */

/** @brief Registry of integer-indexed database handles (`1..64`). */
static cobol_orm_db_t *g_legacy_dbs[COBOL_ORM_LEGACY_MAX_HANDLES];

/** @brief Registry of integer-indexed statement handles (`1..64`). */
static cobol_orm_stmt_t *g_legacy_stmts[COBOL_ORM_LEGACY_MAX_HANDLES];

/**
 * @brief Resolves a 1-based legacy DB handle ID to a `cobol_orm_db_t *`.
 *
 * @param[in] id 1-based DB handle slot ID.
 * @param[out] out_db Receives live DB handle pointer.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_INVALID_HANDLE`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
legacy_get_db(cobol_orm_i32_t id, cobol_orm_db_t **out_db) {
  if (id < 1 || id > COBOL_ORM_LEGACY_MAX_HANDLES || !g_legacy_dbs[id - 1]) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  *out_db = g_legacy_dbs[id - 1];
  return COBOL_ORM_OK;
}

/**
 * @brief Resolves a 1-based legacy statement handle ID to a
 * `cobol_orm_stmt_t *`.
 *
 * @param[in] id 1-based statement handle slot ID.
 * @param[out] out_stmt Receives live statement handle pointer.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_INVALID_HANDLE`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
legacy_get_stmt(cobol_orm_i32_t id, cobol_orm_stmt_t **out_stmt) {
  if (id < 1 || id > COBOL_ORM_LEGACY_MAX_HANDLES || !g_legacy_stmts[id - 1]) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  *out_stmt = g_legacy_stmts[id - 1];
  return COBOL_ORM_OK;
}

/**
 * @brief Returns effective input length for `commarea->data1`.
 *
 * @param[in] req COMMAREA request structure.
 * @param[out] out_len Receives effective length clamped to
 * `COBOL_ORM_COMMAREA_DATA_CAP`.
 * @return `COBOL_ORM_OK`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
legacy_data1_len(const cobol_orm_commarea_t *req, cobol_orm_u32_t *out_len) {
  cobol_orm_u32_t n = req->data1_len;
  if (n == 0 || n > COBOL_ORM_COMMAREA_DATA_CAP) {
    n = COBOL_ORM_COMMAREA_DATA_CAP;
  }
  *out_len = n;
  return COBOL_ORM_OK;
}

/**
 * @brief Allocates a free slot in the DB registry (`1..64`).
 *
 * @param[out] out_slot Receives 1-based slot ID.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_HANDLE_TABLE_FULL`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
legacy_alloc_db_slot(cobol_orm_i32_t *out_slot) {
  int i;
  for (i = 0; i < COBOL_ORM_LEGACY_MAX_HANDLES; i++) {
    if (!g_legacy_dbs[i]) {
      *out_slot = (cobol_orm_i32_t)(i + 1);
      return COBOL_ORM_OK;
    }
  }
  return COBOL_ORM_ERROR_HANDLE_TABLE_FULL;
}

/**
 * @brief Allocates a free slot in the statement registry (`1..64`).
 *
 * @param[out] out_slot Receives 1-based slot ID.
 * @return `COBOL_ORM_OK` or `COBOL_ORM_ERROR_HANDLE_TABLE_FULL`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
legacy_alloc_stmt_slot(cobol_orm_i32_t *out_slot) {
  int i;
  for (i = 0; i < COBOL_ORM_LEGACY_MAX_HANDLES; i++) {
    if (!g_legacy_stmts[i]) {
      *out_slot = (cobol_orm_i32_t)(i + 1);
      return COBOL_ORM_OK;
    }
  }
  return COBOL_ORM_ERROR_HANDLE_TABLE_FULL;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_commarea_dispatch(cobol_orm_commarea_t *commarea) {
  cobol_orm_error_t rc = COBOL_ORM_OK;
  cobol_orm_db_t *db = NULL;
  cobol_orm_stmt_t *stmt = NULL;
  cobol_orm_u32_t d1_len = 0;
  cobol_orm_i32_t slot = 0;

  if (!commarea) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }

  rc = legacy_data1_len(commarea, &d1_len);
  switch ((cobol_orm_legacy_op_t)commarea->opcode) {
  case COBOL_ORM_OP_CONNECT:
    rc = legacy_alloc_db_slot(&slot);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_connect(commarea->data1, d1_len, &db);
      if (rc == COBOL_ORM_OK) {
        g_legacy_dbs[slot - 1] = db;
        commarea->db_id = slot;
      }
    }
    break;
  case COBOL_ORM_OP_DISCONNECT:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      g_legacy_dbs[commarea->db_id - 1] = NULL;
      commarea->db_id = 0;
      rc = cobol_orm_disconnect(db);
    }
    break;
  case COBOL_ORM_OP_EXEC_SQL:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_exec_sql(db, commarea->data1, d1_len);
    }
    break;
  case COBOL_ORM_OP_TX_BEGIN:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_tx_begin(db);
    }
    break;
  case COBOL_ORM_OP_TX_COMMIT:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_tx_commit(db);
    }
    break;
  case COBOL_ORM_OP_TX_ROLLBACK:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_tx_rollback(db);
    }
    break;
  case COBOL_ORM_OP_STMT_PREPARE:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      rc = legacy_alloc_stmt_slot(&slot);
      if (rc == COBOL_ORM_OK) {
        rc = cobol_orm_stmt_prepare(db, commarea->data1, d1_len, &stmt);
        if (rc == COBOL_ORM_OK) {
          g_legacy_stmts[slot - 1] = stmt;
          commarea->stmt_id = slot;
        }
      }
    }
    break;
  case COBOL_ORM_OP_STMT_BIND_I32:
    rc = legacy_get_stmt(commarea->stmt_id, &stmt);
    if (rc == COBOL_ORM_OK) {
      rc =
          cobol_orm_stmt_bind_i32(stmt, commarea->param_idx, commarea->val_i32);
    }
    break;
  case COBOL_ORM_OP_STMT_BIND_STR:
    rc = legacy_get_stmt(commarea->stmt_id, &stmt);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_stmt_bind_str(stmt, commarea->param_idx, commarea->data1,
                                   d1_len);
    }
    break;
  case COBOL_ORM_OP_STMT_STEP:
    rc = legacy_get_stmt(commarea->stmt_id, &stmt);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_stmt_step(stmt, &commarea->val_i32);
    }
    break;
  case COBOL_ORM_OP_STMT_COL_I32:
    rc = legacy_get_stmt(commarea->stmt_id, &stmt);
    if (rc == COBOL_ORM_OK) {
      rc =
          cobol_orm_stmt_col_i32(stmt, commarea->param_idx, &commarea->val_i32);
    }
    break;
  case COBOL_ORM_OP_STMT_COL_STR:
    rc = legacy_get_stmt(commarea->stmt_id, &stmt);
    if (rc == COBOL_ORM_OK) {
      rc = cobol_orm_stmt_col_str(stmt, commarea->param_idx, commarea->data2,
                                  COBOL_ORM_COMMAREA_DATA_CAP,
                                  &commarea->data2_len);
    }
    break;
  case COBOL_ORM_OP_STMT_FINALIZE:
    rc = legacy_get_stmt(commarea->stmt_id, &stmt);
    if (rc == COBOL_ORM_OK) {
      g_legacy_stmts[commarea->stmt_id - 1] = NULL;
      commarea->stmt_id = 0;
      rc = cobol_orm_stmt_finalize(stmt);
    }
    break;
  case COBOL_ORM_OP_LAST_ERROR:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      rc =
          cobol_orm_last_error(db, commarea->data2, COBOL_ORM_COMMAREA_DATA_CAP,
                               &commarea->data2_len);
    }
    break;
  case COBOL_ORM_OP_VERSION:
    rc = cobol_orm_version(commarea->data2, COBOL_ORM_COMMAREA_DATA_CAP,
                           &commarea->data2_len);
    break;
  case COBOL_ORM_OP_LAST_ROWID:
    rc = legacy_get_db(commarea->db_id, &db);
    if (rc == COBOL_ORM_OK) {
      cobol_orm_i64_t rowid = 0;
      rc = cobol_orm_last_insert_rowid(db, &rowid);
      commarea->val_i32 = (cobol_orm_i32_t)rowid;
    }
    break;
  default:
    rc = COBOL_ORM_ERROR_INVALID_OPCODE;
    break;
  }

  commarea->status = (cobol_orm_i32_t)rc;
  return rc;
}

/**
 * @brief Parses a fixed-width unsigned ASCII digit field into `out_val`.
 *
 * @param[in] p Pointer to ASCII digits.
 * @param[in] width Number of digit characters.
 * @param[out] out_val Receives parsed unsigned value.
 * @return `COBOL_ORM_OK`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
parse_disp_u32(const char *p, size_t width, cobol_orm_u32_t *out_val) {
  cobol_orm_u32_t acc = 0;
  size_t i;
  for (i = 0; i < width; i++) {
    if (p[i] >= '0' && p[i] <= '9') {
      acc = (acc * 10u) + (cobol_orm_u32_t)(p[i] - '0');
    }
  }
  *out_val = acc;
  return COBOL_ORM_OK;
}

/**
 * @brief Formats an unsigned integer into zero-padded fixed-width ASCII digits.
 *
 * @param[in] val Value to format.
 * @param[out] out Destination buffer of at least `width` bytes.
 * @param[in] width Exact number of digits to write.
 * @return `COBOL_ORM_OK`.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t fmt_disp_u32(cobol_orm_u32_t val,
                                                           char *out,
                                                           size_t width) {
  size_t i = width;
  while (i > 0) {
    i--;
    out[i] = (char)('0' + (val % 10u));
    val /= 10u;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_display_dispatch(char *display_buf) {
  cobol_orm_commarea_t ca;
  cobol_orm_u32_t u_op = 0;
  cobol_orm_u32_t u_db = 0;
  cobol_orm_u32_t u_st = 0;
  cobol_orm_u32_t u_idx = 0;
  cobol_orm_u32_t u_mag = 0;
  cobol_orm_u32_t u_d1 = 0;
  cobol_orm_u32_t abs_val;
  cobol_orm_error_t rc;
  cobol_orm_error_t frc;

  if (!display_buf) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }

  /* Layout (552 bytes):
   * [0..3] opcode, [4..7] status, [8..11] db_id, [12..15] stmt_id,
   * [16..19] param_idx, [20] val_sign, [21..31] val_num (11 digits),
   * [32..35] d1_len, [36..39] d2_len, [40..295] data1, [296..551] data2.
   */
  memset(&ca, 0, sizeof(ca));
  frc = parse_disp_u32(display_buf + 0, 4, &u_op);
  frc = cobol_orm_keep_err(frc, parse_disp_u32(display_buf + 8, 4, &u_db));
  frc = cobol_orm_keep_err(frc, parse_disp_u32(display_buf + 12, 4, &u_st));
  frc = cobol_orm_keep_err(frc, parse_disp_u32(display_buf + 16, 4, &u_idx));
  frc = cobol_orm_keep_err(frc, parse_disp_u32(display_buf + 21, 11, &u_mag));
  frc = cobol_orm_keep_err(frc, parse_disp_u32(display_buf + 32, 4, &u_d1));

  ca.opcode = (cobol_orm_i32_t)u_op;
  ca.db_id = (cobol_orm_i32_t)u_db;
  ca.stmt_id = (cobol_orm_i32_t)u_st;
  ca.param_idx = (cobol_orm_i32_t)u_idx;
  ca.val_i32 = (display_buf[20] == '-') ? -(cobol_orm_i32_t)u_mag
                                        : (cobol_orm_i32_t)u_mag;
  ca.data1_len = u_d1;
  memcpy(ca.data1, display_buf + 40, COBOL_ORM_COMMAREA_DATA_CAP);
  memcpy(ca.data2, display_buf + 296, COBOL_ORM_COMMAREA_DATA_CAP);

  rc = cobol_orm_keep_err(frc, cobol_orm_commarea_dispatch(&ca));

  frc = fmt_disp_u32((cobol_orm_u32_t)ca.status, display_buf + 4, 4);
  frc = cobol_orm_keep_err(
      frc, fmt_disp_u32((cobol_orm_u32_t)ca.db_id, display_buf + 8, 4));
  frc = cobol_orm_keep_err(
      frc, fmt_disp_u32((cobol_orm_u32_t)ca.stmt_id, display_buf + 12, 4));
  if (ca.val_i32 < 0) {
    display_buf[20] = '-';
    abs_val = (cobol_orm_u32_t)(-ca.val_i32);
  } else {
    display_buf[20] = '+';
    abs_val = (cobol_orm_u32_t)ca.val_i32;
  }
  frc = cobol_orm_keep_err(frc, fmt_disp_u32(abs_val, display_buf + 21, 11));
  frc =
      cobol_orm_keep_err(frc, fmt_disp_u32(ca.data2_len, display_buf + 36, 4));
  memcpy(display_buf + 296, ca.data2, COBOL_ORM_COMMAREA_DATA_CAP);
  return cobol_orm_keep_err(rc, frc);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_legacy_reset(void) {
  cobol_orm_error_t rc = COBOL_ORM_OK;
  int i;

  for (i = 0; i < COBOL_ORM_LEGACY_MAX_HANDLES; i++) {
    if (g_legacy_stmts[i]) {
      cobol_orm_stmt_t *s = g_legacy_stmts[i];
      g_legacy_stmts[i] = NULL;
      rc = cobol_orm_keep_err(rc, cobol_orm_stmt_finalize(s));
    }
  }
  for (i = 0; i < COBOL_ORM_LEGACY_MAX_HANDLES; i++) {
    if (g_legacy_dbs[i]) {
      cobol_orm_db_t *d = g_legacy_dbs[i];
      g_legacy_dbs[i] = NULL;
      rc = cobol_orm_keep_err(rc, cobol_orm_disconnect(d));
    }
  }
  return rc;
}
