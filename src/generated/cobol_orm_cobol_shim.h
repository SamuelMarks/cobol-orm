/**
 * @file cobol_orm_cobol_shim.h
 * @brief Strict ISO C89 COBOL ABI shim declarations.
 */
/**
 * @defgroup cobol_shim_cobol_orm COBOL C89 ABI Shims
 * @brief COBOL C89 ABI Shims.
 * @{
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
/** @brief Portable 64-bit signed integer for COBOL ABI shims. */
typedef __int64 cdd_cob_i64;
/** @brief Portable 64-bit unsigned integer for COBOL ABI shims. */
typedef unsigned __int64 cdd_cob_u64;
#elif defined(__GNUC__) || defined(__clang__)
/** @brief Portable 64-bit signed integer for COBOL ABI shims. */
__extension__ typedef long long cdd_cob_i64;
/** @brief Portable 64-bit unsigned integer for COBOL ABI shims. */
__extension__ typedef unsigned long long cdd_cob_u64;
#else
/** @brief Portable 64-bit signed integer for COBOL ABI shims. */
typedef long cdd_cob_i64;
/** @brief Portable 64-bit unsigned integer for COBOL ABI shims. */
typedef unsigned long cdd_cob_u64;
#endif

/**
 * @brief Copies a NUL-terminated C string into a space-padded COBOL PIC X buffer.
 * @param[in] c_str Optional source C string (NULL space-fills cob_buf).
 * @param[out] cob_buf Destination COBOL PIC X character buffer.
 * @param[in] cob_len Capacity of cob_buf in bytes.
 * @return 0 on success, or -1 if cob_buf is NULL.
 */
int cdd_cobol_str_to_pic_x(const char *c_str, char *cob_buf,
                           unsigned int cob_len);

/**
 * @brief ABI layout mirror for C struct cobol_orm_decimal.
 */
struct cobol_orm_decimal {
  unsigned char sign; /**< Field sign. */
  unsigned char precision; /**< Field precision. */
  unsigned char scale; /**< Field scale. */
  unsigned char digits[38]; /**< Field digits. */
};

/**
 * @brief ABI layout mirror for C struct cobol_orm_pool_stats.
 */
struct cobol_orm_pool_stats {
  unsigned int active_connections; /**< Field active_connections. */
  unsigned int idle_connections; /**< Field idle_connections. */
  unsigned int exhaustion_count; /**< Field exhaustion_count. */
  unsigned int slow_queries_logged; /**< Field slow_queries_logged. */
  double average_wait_time_ms; /**< Field average_wait_time_ms. */
};

/**
 * @brief ABI layout mirror for C struct cobol_orm_cpy_info.
 */
struct cobol_orm_cpy_info {
  unsigned int total_byte_size; /**< Field total_byte_size. */
  unsigned int field_count; /**< Field field_count. */
  int has_dclgen; /**< Field has_dclgen. */
};

/**
 * @brief ABI layout mirror for C struct cobol_orm_col_info.
 */
struct cobol_orm_col_info {
  unsigned int byte_offset; /**< Field byte_offset. */
  unsigned int byte_size; /**< Field byte_size. */
  int usage; /**< Field usage. */
  unsigned char total_digits; /**< Field total_digits. */
  unsigned char frac_digits; /**< Field frac_digits. */
  unsigned char is_signed; /**< Field is_signed. */
  unsigned char is_pk; /**< Field is_pk. */
};

/**
 * @brief ABI layout mirror for C struct cobol_orm_commarea.
 */
struct cobol_orm_commarea {
  int opcode; /**< Field opcode. */
  int status; /**< Field status. */
  int db_id; /**< Field db_id. */
  int stmt_id; /**< Field stmt_id. */
  int param_idx; /**< Field param_idx. */
  int val_i32; /**< Field val_i32. */
  unsigned int data1_len; /**< Field data1_len. */
  unsigned int data2_len; /**< Field data2_len. */
  signed char data1[256]; /**< Field data1. */
  signed char data2[256]; /**< Field data2. */
};


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* CDD_COBOL_SHIM_COBOL_ORM_H */
/** @} */
