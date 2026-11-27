/**
 * @file cobol_orm_enterprise.c
 * @brief IBM Db2 and Generic ODBC 3.52 enterprise helper FFI wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_odbc_sqlstate(cobol_orm_db_t *db, char *out_state,
                        cobol_orm_u32_t cap, cobol_orm_u32_t *out_len) {
  char state6[6];
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_odbc_get_sqlstate(db->raw, state6);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_cstr_to_picx(state6, out_state, cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_db2_set_isolation(cobol_orm_db_t *db, cobol_orm_isolation_t iso) {
  c_orm_db2_isolation_t core_iso;
  cobol_orm_error_t rc = cobol_orm_check_db(db);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  switch (iso) {
  case COBOL_ORM_ISO_UR:
    core_iso = C_ORM_DB2_ISOLATION_UR;
    break;
  case COBOL_ORM_ISO_CS:
    core_iso = C_ORM_DB2_ISOLATION_CS;
    break;
  case COBOL_ORM_ISO_RS:
    core_iso = C_ORM_DB2_ISOLATION_RS;
    break;
  case COBOL_ORM_ISO_RR:
    core_iso = C_ORM_DB2_ISOLATION_RR;
    break;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
  return cobol_orm_from_c_orm(c_orm_db2_set_isolation(db->raw, core_iso));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_db2_set_schema(cobol_orm_db_t *db, const char *schema,
                         cobol_orm_u32_t schema_len) {
  char *schema_c = NULL;
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_picx_to_cstr(schema, schema_len, &schema_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_db2_set_current_schema(db->raw, schema_c);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(schema_c)));
}
