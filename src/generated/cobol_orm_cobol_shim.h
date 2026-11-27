/**
 * @file cobol_orm_cobol_shim.h
 * @brief Strict ISO C89 COBOL ABI shim declarations.
 */
#ifndef CDD_COBOL_SHIM_COBOL_ORM_H
/** @brief Header guard for generated shim (CDD_COBOL_SHIM_COBOL_ORM_H). */
#define CDD_COBOL_SHIM_COBOL_ORM_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/* clang-format off */
#include <stddef.h>
/* clang-format on */

#if defined(_MSC_VER)
/** @brief Portable 64-bit signed integer type for COBOL ABI shims. */
typedef __int64 cdd_cob_i64;
/** @brief Portable 64-bit unsigned integer type for COBOL ABI shims. */
typedef unsigned __int64 cdd_cob_u64;
#elif defined(__GNUC__) || defined(__clang__)
/** @brief Portable 64-bit signed integer type for COBOL ABI shims. */
__extension__ typedef long long cdd_cob_i64;
/** @brief Portable 64-bit unsigned integer type for COBOL ABI shims. */
__extension__ typedef unsigned long long cdd_cob_u64;
#else
/** @brief Portable 64-bit signed integer type for COBOL ABI shims. */
typedef long cdd_cob_i64;
/** @brief Portable 64-bit unsigned integer type for COBOL ABI shims. */
typedef unsigned long cdd_cob_u64;
#endif

/**
 * @brief Copies a NUL-terminated C string into a space-padded COBOL PIC X buffer.
 *
 * @param[in] c_str Source NUL-terminated C string (or NULL for blank-fill).
 * @param[out] cob_buf Destination COBOL PIC X character buffer.
 * @param[in] cob_len Capacity of `cob_buf` in bytes.
 * @return `0` on success, or `-1` if `cob_buf` is NULL.
 */
int cdd_cobol_str_to_pic_x(const char *c_str, char *cob_buf,
                           unsigned int cob_len);

/** @brief ABI shim mirror of struct cobol_orm_decimal. */
struct cobol_orm_decimal {
  /** @brief ABI field `sign` of `cobol_orm_decimal`. */
  unsigned char sign;
  /** @brief ABI field `precision` of `cobol_orm_decimal`. */
  unsigned char precision;
  /** @brief ABI field `scale` of `cobol_orm_decimal`. */
  unsigned char scale;
  /** @brief ABI field `digits` of `cobol_orm_decimal`. */
  unsigned char digits[38];
};

/** @brief ABI shim mirror of struct cobol_orm_pool_stats. */
struct cobol_orm_pool_stats {
  /** @brief ABI field `active_connections` of `cobol_orm_pool_stats`. */
  unsigned int active_connections;
  /** @brief ABI field `idle_connections` of `cobol_orm_pool_stats`. */
  unsigned int idle_connections;
  /** @brief ABI field `exhaustion_count` of `cobol_orm_pool_stats`. */
  unsigned int exhaustion_count;
  /** @brief ABI field `slow_queries_logged` of `cobol_orm_pool_stats`. */
  unsigned int slow_queries_logged;
  /** @brief ABI field `average_wait_time_ms` of `cobol_orm_pool_stats`. */
  double average_wait_time_ms;
};

/** @brief ABI shim mirror of struct cobol_orm_cpy_info. */
struct cobol_orm_cpy_info {
  /** @brief ABI field `total_byte_size` of `cobol_orm_cpy_info`. */
  unsigned int total_byte_size;
  /** @brief ABI field `field_count` of `cobol_orm_cpy_info`. */
  unsigned int field_count;
  /** @brief ABI field `has_dclgen` of `cobol_orm_cpy_info`. */
  int has_dclgen;
};

/** @brief ABI shim mirror of struct cobol_orm_col_info. */
struct cobol_orm_col_info {
  /** @brief ABI field `byte_offset` of `cobol_orm_col_info`. */
  unsigned int byte_offset;
  /** @brief ABI field `byte_size` of `cobol_orm_col_info`. */
  unsigned int byte_size;
  /** @brief ABI field `usage` of `cobol_orm_col_info`. */
  int usage;
  /** @brief ABI field `total_digits` of `cobol_orm_col_info`. */
  unsigned char total_digits;
  /** @brief ABI field `frac_digits` of `cobol_orm_col_info`. */
  unsigned char frac_digits;
  /** @brief ABI field `is_signed` of `cobol_orm_col_info`. */
  unsigned char is_signed;
  /** @brief ABI field `is_pk` of `cobol_orm_col_info`. */
  unsigned char is_pk;
};

/** @brief ABI shim mirror of struct cobol_orm_commarea. */
struct cobol_orm_commarea {
  /** @brief ABI field `opcode` of `cobol_orm_commarea`. */
  int opcode;
  /** @brief ABI field `status` of `cobol_orm_commarea`. */
  int status;
  /** @brief ABI field `db_id` of `cobol_orm_commarea`. */
  int db_id;
  /** @brief ABI field `stmt_id` of `cobol_orm_commarea`. */
  int stmt_id;
  /** @brief ABI field `param_idx` of `cobol_orm_commarea`. */
  int param_idx;
  /** @brief ABI field `val_i32` of `cobol_orm_commarea`. */
  int val_i32;
  /** @brief ABI field `data1_len` of `cobol_orm_commarea`. */
  unsigned int data1_len;
  /** @brief ABI field `data2_len` of `cobol_orm_commarea`. */
  unsigned int data2_len;
  /** @brief ABI field `data1` of `cobol_orm_commarea`. */
  signed char data1[256];
  /** @brief ABI field `data2` of `cobol_orm_commarea`. */
  signed char data2[256];
};


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CDD_COBOL_SHIM_COBOL_ORM_H */
