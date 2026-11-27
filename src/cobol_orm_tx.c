/**
 * @file cobol_orm_tx.c
 * @brief Database transaction and nested savepoint FFI wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_tx_begin(cobol_orm_db_t *db) {
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(c_orm_transaction_begin(db->raw));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_tx_commit(cobol_orm_db_t *db) {
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(c_orm_transaction_commit(db->raw));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_tx_rollback(cobol_orm_db_t *db) {
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(c_orm_transaction_rollback(db->raw));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_tx_savepoint(
    cobol_orm_db_t *db, const char *name, cobol_orm_u32_t name_len) {
  char *name_c = NULL;
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(name, name_len, &name_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_savepoint_create(db->raw, name_c);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(name_c)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_tx_release_sp(
    cobol_orm_db_t *db, const char *name, cobol_orm_u32_t name_len) {
  char *name_c = NULL;
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(name, name_len, &name_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_savepoint_release(db->raw, name_c);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(name_c)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_tx_rollback_sp(cobol_orm_db_t *db, const char *name,
                         cobol_orm_u32_t name_len) {
  char *name_c = NULL;
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(name, name_len, &name_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_savepoint_rollback(db->raw, name_c);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(name_c)));
}
