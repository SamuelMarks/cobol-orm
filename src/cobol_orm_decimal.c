/**
 * @file cobol_orm_decimal.c
 * @brief Lossless 38-digit fixed-point decimal arithmetic, COMP-3 packed
 * decimal, Zoned Decimal, and big-endian COMP/COMP-5 FFI wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_dec_from_str(
    const char *str, cobol_orm_u32_t str_len, cobol_orm_decimal_t *out_dec) {
  char *str_c = NULL;
  c_orm_decimal_t core;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!out_dec) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_picx_to_cstr(str, str_len, &str_c);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_from_str(str_c, &core);
  rc = cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                          cobol_orm_from_c_orm(c_orm_system_free(str_c)));
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_dec_from_core(&core, out_dec);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_to_str(const cobol_orm_decimal_t *dec, char *out_buf,
                     cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_len) {
  c_orm_decimal_t core;
  char tmp[64];
  size_t len = 0;
  cobol_orm_error_t rc = cobol_orm_dec_to_core(dec, &core);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_to_str(&core, tmp, sizeof(tmp), &len);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_cstr_to_picx(tmp, out_buf, buf_cap, out_len);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_add(const cobol_orm_decimal_t *a, const cobol_orm_decimal_t *b,
                  cobol_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_dec_to_core(a, &ca);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_dec_to_core(b, &cb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_add(&ca, &cb, &cr);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&cr, out_res);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_sub(const cobol_orm_decimal_t *a, const cobol_orm_decimal_t *b,
                  cobol_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_dec_to_core(a, &ca);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_dec_to_core(b, &cb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_sub(&ca, &cb, &cr);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&cr, out_res);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_mul(const cobol_orm_decimal_t *a, const cobol_orm_decimal_t *b,
                  cobol_orm_u8_t max_scale, cobol_orm_round_mode_t mode,
                  cobol_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  c_orm_round_mode_t rmode;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_dec_to_core(a, &ca);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_dec_to_core(b, &cb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_map_round_mode(mode, &rmode);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_mul(&ca, &cb, max_scale, rmode, &cr);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&cr, out_res);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_div(const cobol_orm_decimal_t *a, const cobol_orm_decimal_t *b,
                  cobol_orm_u8_t result_scale, cobol_orm_round_mode_t mode,
                  cobol_orm_decimal_t *out_res) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  c_orm_decimal_t cr;
  c_orm_round_mode_t rmode;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_dec_to_core(a, &ca);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_dec_to_core(b, &cb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_map_round_mode(mode, &rmode);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_div(&ca, &cb, result_scale, rmode, &cr);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&cr, out_res);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_cmp(const cobol_orm_decimal_t *a, const cobol_orm_decimal_t *b,
                  cobol_orm_i32_t *out_cmp) {
  c_orm_decimal_t ca;
  c_orm_decimal_t cb;
  int cmp_val = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!out_cmp) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_dec_to_core(a, &ca);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_dec_to_core(b, &cb);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_cmp(&ca, &cb, &cmp_val);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_cmp = (cobol_orm_i32_t)cmp_val;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_to_comp3(const cobol_orm_decimal_t *dec,
                       cobol_orm_u8_t int_digits, cobol_orm_u8_t frac_digits,
                       cobol_orm_i32_t is_signed, cobol_orm_u8_t *out_buf,
                       cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_written) {
  c_orm_decimal_t core;
  size_t written = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!out_written) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_dec_to_core(dec, &core);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_to_comp3(&core, int_digits, frac_digits, (int)is_signed,
                               out_buf, (size_t)buf_cap, &written);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_written = (cobol_orm_u32_t)written;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_from_comp3(const cobol_orm_u8_t *buf, cobol_orm_u32_t buf_len,
                         cobol_orm_u8_t frac_digits,
                         cobol_orm_decimal_t *out_dec) {
  c_orm_decimal_t core;
  c_orm_error_t crc;

  if (!out_dec) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_decimal_from_comp3(buf, (size_t)buf_len, frac_digits, &core);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&core, out_dec);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_dec_to_zoned(
    const cobol_orm_decimal_t *dec, cobol_orm_u8_t int_digits,
    cobol_orm_u8_t frac_digits, cobol_orm_i32_t is_signed,
    cobol_orm_i32_t sign_leading, cobol_orm_i32_t sign_separate,
    cobol_orm_i32_t use_ebcdic, cobol_orm_u8_t *out_buf,
    cobol_orm_u32_t buf_cap, cobol_orm_u32_t *out_written) {
  c_orm_decimal_t core;
  size_t written = 0;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  if (!out_written) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  rc = cobol_orm_dec_to_core(dec, &core);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_decimal_to_zoned(
      &core, int_digits, frac_digits, (int)is_signed, (int)sign_leading,
      (int)sign_separate, (int)use_ebcdic, out_buf, (size_t)buf_cap, &written);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_written = (cobol_orm_u32_t)written;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_dec_from_zoned(const cobol_orm_u8_t *buf, cobol_orm_u32_t buf_len,
                         cobol_orm_u8_t frac_digits, cobol_orm_i32_t is_signed,
                         cobol_orm_i32_t sign_leading,
                         cobol_orm_i32_t sign_separate,
                         cobol_orm_i32_t use_ebcdic,
                         cobol_orm_decimal_t *out_dec) {
  c_orm_decimal_t core;
  c_orm_error_t crc;

  if (!out_dec) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_decimal_from_zoned(buf, (size_t)buf_len, frac_digits,
                                 (int)is_signed, (int)sign_leading,
                                 (int)sign_separate, (int)use_ebcdic, &core);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_dec_from_core(&core, out_dec);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_i64_to_comp(cobol_orm_i64_t val, cobol_orm_u32_t byte_width,
                      cobol_orm_i32_t is_big_endian, cobol_orm_u8_t *out_buf,
                      cobol_orm_u32_t buf_cap) {
  return cobol_orm_from_c_orm(
      c_orm_int64_to_cobol_comp((c_orm_int64_t)val, (size_t)byte_width,
                                (int)is_big_endian, out_buf, (size_t)buf_cap));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_i64_from_comp(
    const cobol_orm_u8_t *buf, cobol_orm_u32_t byte_width,
    cobol_orm_i32_t is_signed, cobol_orm_i32_t is_big_endian,
    cobol_orm_i64_t *out_val) {
  c_orm_int64_t val = 0;
  c_orm_error_t crc;

  if (!out_val) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  crc = c_orm_int64_from_cobol_comp(buf, (size_t)byte_width, (int)is_signed,
                                    (int)is_big_endian, &val);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  *out_val = (cobol_orm_i64_t)val;
  return COBOL_ORM_OK;
}
