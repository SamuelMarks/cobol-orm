/**
 * @file cobol_orm_migrations.c
 * @brief Versioned SQL schema migration runner FFI wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
#include <string.h>
/* clang-format on */

/**
 * @brief Validates a `cobol_orm_mig_t` handle pointer and magic tag.
 *
 * @param[in] mig Candidate migration runner handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
check_mig(const cobol_orm_mig_t *mig) {
  if (!mig || mig->magic != COBOL_ORM_MAGIC_MIG) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_mig_init(cobol_orm_db_t *db, const char *dir_path,
                   cobol_orm_u32_t dir_len, cobol_orm_mig_t **out_mig) {
  char *dir_c = NULL;
  cobol_orm_mig_t *handle = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_mig) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_mig = NULL;

  rc = cobol_orm_picx_to_cstr(dir_path, dir_len, &dir_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_system_calloc(1, sizeof(cobol_orm_mig_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(dir_c)));
  }

  handle->magic = COBOL_ORM_MAGIC_MIG;
  handle->db = db;
  handle->dir_path = dir_c;
  *out_mig = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_mig_up(cobol_orm_mig_t *mig, cobol_orm_i32_t dry_run,
                 cobol_orm_u32_t *out_applied) {
  c_orm_migration_options_t opts;
  c_orm_migration_t *applied = NULL;
  size_t count = 0;
  cobol_orm_error_t rc = check_mig(mig);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (!out_applied) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  memset(&opts, 0, sizeof(opts));
  opts.dry_run = (int)dry_run;
  crc = c_orm_migrate_up(mig->db->raw, mig->dir_path, &opts);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_migration_get_applied(mig->db->raw, &applied, &count);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_applied = (cobol_orm_u32_t)count;
  return cobol_orm_from_c_orm(c_orm_migration_free_array(applied, count));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_mig_down(
    cobol_orm_mig_t *mig, cobol_orm_u32_t steps, cobol_orm_i32_t dry_run) {
  c_orm_migration_options_t opts;
  cobol_orm_error_t rc = check_mig(mig);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  memset(&opts, 0, sizeof(opts));
  opts.dry_run = (int)dry_run;
  return cobol_orm_from_c_orm(
      c_orm_migrate_down(mig->db->raw, mig->dir_path, (size_t)steps, &opts));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_mig_free(cobol_orm_mig_t *mig) {
  cobol_orm_error_t rc = check_mig(mig);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_system_free(mig->dir_path);
  mig->dir_path = NULL;
  mig->db = NULL;
  mig->magic = 0;
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(mig)));
}
