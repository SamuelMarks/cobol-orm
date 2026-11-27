/**
 * @file cobol_orm_ebcdic.c
 * @brief Mainframe EBCDIC (IBM037/1047/500/1140) and UTF-16 GRAPHIC/NATIONAL
 * transcoder FFI wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ebcdic_to_utf8(cobol_orm_codepage_t cp,
                         const cobol_orm_u8_t *in_bytes, cobol_orm_u32_t in_len,
                         char *out_utf8, cobol_orm_u32_t out_cap,
                         cobol_orm_u32_t *out_len) {
  c_orm_codepage_t core_cp;
  char *tmp = NULL;
  size_t tmp_cap;
  size_t written = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!in_bytes || !out_utf8 || !out_len) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  tmp_cap = ((size_t)in_len * 3) + 1;
  crc = c_orm_system_malloc(tmp_cap, (void **)&tmp);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_ebcdic_to_utf8(core_cp, in_bytes, (size_t)in_len, tmp, tmp_cap,
                             &written);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(tmp)));
  }
  rc = cobol_orm_cstr_to_picx(tmp, out_utf8, out_cap, out_len);
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(tmp)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_utf8_to_ebcdic(cobol_orm_codepage_t cp, const char *in_utf8,
                         cobol_orm_u32_t in_len, cobol_orm_u8_t *out_bytes,
                         cobol_orm_u32_t out_cap, cobol_orm_u32_t *out_len) {
  c_orm_codepage_t core_cp;
  size_t written = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!in_utf8 || !out_bytes || !out_len) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_map_codepage(cp, &core_cp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_utf8_to_ebcdic(core_cp, in_utf8, (size_t)in_len, out_bytes,
                             (size_t)out_cap, &written);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_len = (cobol_orm_u32_t)written;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_utf8_to_utf16(const char *in_utf8, cobol_orm_u32_t in_len,
                        cobol_orm_i32_t big_endian, cobol_orm_u16_t *out_u16,
                        cobol_orm_u32_t out_cap, cobol_orm_u32_t *out_units) {
  size_t units = 0;
  c_orm_error_t crc;

  if (!in_utf8 || !out_u16 || !out_units) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_utf8_to_utf16(in_utf8, (size_t)in_len, (int)big_endian, out_u16,
                            (size_t)out_cap, &units);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_units = (cobol_orm_u32_t)units;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_utf16_to_utf8(const cobol_orm_u16_t *in_u16, cobol_orm_u32_t in_units,
                        cobol_orm_i32_t big_endian, char *out_utf8,
                        cobol_orm_u32_t out_cap, cobol_orm_u32_t *out_len) {
  char *tmp = NULL;
  size_t tmp_cap;
  size_t written = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!in_u16 || !out_utf8 || !out_len) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  tmp_cap = ((size_t)in_units * 4) + 1;
  crc = c_orm_system_malloc(tmp_cap, (void **)&tmp);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_utf16_to_utf8(in_u16, (size_t)in_units, (int)big_endian, tmp,
                            tmp_cap, &written);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(tmp)));
  }
  rc = cobol_orm_cstr_to_picx(tmp, out_utf8, out_cap, out_len);
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(tmp)));
}
