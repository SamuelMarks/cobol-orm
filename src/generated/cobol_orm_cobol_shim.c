/**
 * @file cobol_orm_cobol_shim.c
 * @brief Strict ISO C89 COBOL ABI shim implementation.
 */
/* clang-format off */
#include "cobol_orm_cobol_shim.h"
#include <string.h>
/* clang-format on */

int cdd_cobol_str_to_pic_x(const char *c_str, char *cob_buf,
                           unsigned int cob_len) {
  unsigned int copy_n;
  size_t s_len;
  if (!cob_buf)
    return -1;
  if (cob_len == 0)
    return 0;
  memset(cob_buf, ' ', (size_t)cob_len);
  if (!c_str)
    return 0;
  s_len = strlen(c_str);
  copy_n = (s_len < (size_t)cob_len) ? (unsigned int)s_len : cob_len;
  if (copy_n > 0) {
#if defined(_MSC_VER)
    memcpy_s(cob_buf, (size_t)cob_len, c_str, (size_t)copy_n);
#else
    memcpy(cob_buf, c_str, (size_t)copy_n);
#endif
  }
  return 0;
}

