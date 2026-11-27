/**
 * @file cobol_orm_query.c
 * @brief Arena-backed fluent SQL AST query builder and multi-dialect SQL
 * compiler FFI wrappers.
 */

/* clang-format off */
#include "cobol_orm_internal.h"
/* clang-format on */

/**
 * @brief Validates a `cobol_orm_ast_t` handle pointer and magic tag.
 *
 * @param[in] ast Candidate AST builder handle.
 * @return `COBOL_ORM_OK` if valid, `COBOL_ORM_ERROR_INVALID_HANDLE` otherwise.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
check_ast(const cobol_orm_ast_t *ast) {
  if (!ast || ast->magic != COBOL_ORM_MAGIC_AST) {
    return COBOL_ORM_ERROR_INVALID_HANDLE;
  }
  return COBOL_ORM_OK;
}

/**
 * @brief Converts a COBOL `PIC X` buffer into an arena-owned C string inside
 * `ast->raw->arena`.
 *
 * @param[in] ast Validated AST handle.
 * @param[in] buf Source `PIC X` buffer.
 * @param[in] len Buffer length in bytes.
 * @param[out] out_arena_str Receives arena-owned NUL-terminated string.
 * @return `COBOL_ORM_OK` on success, or error code on failure.
 */
static COBOL_ORM_NO_DISCARD cobol_orm_error_t
ast_intern_picx(cobol_orm_ast_t *ast, const char *buf, cobol_orm_u32_t len,
                const char **out_arena_str) {
  char *tmp = NULL;
  cobol_orm_error_t rc;
  c_orm_error_t crc;

  rc = cobol_orm_picx_to_cstr(buf, len, &tmp);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_arena_strdup(ast->raw->arena, tmp, out_arena_str);
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(tmp)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_new(cobol_orm_ast_t **out_ast) {
  cobol_orm_ast_t *handle = NULL;
  c_orm_ast_query_t *raw = NULL;
  c_orm_error_t crc;

  if (!out_ast) {
    return COBOL_ORM_ERROR_NULL_POINTER;
  }
  *out_ast = NULL;

  crc = c_orm_system_calloc(1, sizeof(cobol_orm_ast_t), (void **)&handle);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  crc = c_orm_query_new(&raw);
  if (crc != C_ORM_OK) {
    return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                              cobol_orm_from_c_orm(c_orm_system_free(handle)));
  }

  handle->magic = COBOL_ORM_MAGIC_AST;
  handle->raw = raw;
  handle->has_where = 0;
  *out_ast = handle;
  return COBOL_ORM_OK;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_select(
    cobol_orm_ast_t *ast, const char *cols, cobol_orm_u32_t cols_len) {
  const char *cols_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, cols, cols_len, &cols_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->select_(ast->raw, cols_a));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_distinct(cobol_orm_ast_t *ast) {
  cobol_orm_error_t rc = check_ast(ast);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->distinct(ast->raw));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_from(
    cobol_orm_ast_t *ast, const char *table, cobol_orm_u32_t table_len) {
  const char *table_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, table, table_len, &table_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->from(ast->raw, table_a));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_insert_into(cobol_orm_ast_t *ast, const char *table,
                          cobol_orm_u32_t table_len) {
  const char *table_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, table, table_len, &table_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->insert_into(ast->raw, table_a));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_update_table(cobol_orm_ast_t *ast, const char *table,
                           cobol_orm_u32_t table_len) {
  const char *table_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, table, table_len, &table_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->update_table(ast->raw, table_a));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_delete_from(cobol_orm_ast_t *ast, const char *table,
                          cobol_orm_u32_t table_len) {
  const char *table_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, table, table_len, &table_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->delete_from(ast->raw, table_a));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_set_col(
    cobol_orm_ast_t *ast, const char *col, cobol_orm_u32_t col_len,
    const char *val, cobol_orm_u32_t val_len, cobol_orm_i32_t is_string) {
  const char *col_a = NULL;
  const char *val_a = NULL;
  c_orm_ast_node_t *lit = NULL;
  cobol_orm_error_t rc = check_ast(ast);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, col, col_len, &col_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, val, val_len, &val_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = ast->raw->lit(ast->raw, val_a, (int)is_string, &lit);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_from_c_orm(ast->raw->set_col(ast->raw, col_a, lit));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_where_eq(
    cobol_orm_ast_t *ast, const char *col, cobol_orm_u32_t col_len,
    const char *val, cobol_orm_u32_t val_len, cobol_orm_i32_t is_string) {
  const char *col_a = NULL;
  const char *val_a = NULL;
  c_orm_ast_node_t *pred = NULL;
  cobol_orm_error_t rc = check_ast(ast);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, col, col_len, &col_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, val, val_len, &val_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = ast->raw->eq(ast->raw, col_a, val_a, (int)is_string, &pred);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  if (!ast->has_where) {
    crc = ast->raw->where(ast->raw, pred);
    if (crc == C_ORM_OK) {
      ast->has_where = 1;
    }
  } else {
    crc = ast->raw->and_where(ast->raw, pred);
  }
  return cobol_orm_from_c_orm(crc);
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_join(
    cobol_orm_ast_t *ast, cobol_orm_join_type_t join_type, const char *table,
    cobol_orm_u32_t table_len, const char *on_sql, cobol_orm_u32_t on_len) {
  const char *table_a = NULL;
  const char *on_a = NULL;
  const char *jtype = NULL;
  c_orm_ast_node_t *on_node = NULL;
  cobol_orm_error_t rc = check_ast(ast);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  switch (join_type) {
  case COBOL_ORM_JOIN_INNER:
    jtype = "INNER";
    break;
  case COBOL_ORM_JOIN_LEFT:
    jtype = "LEFT";
    break;
  case COBOL_ORM_JOIN_RIGHT:
    jtype = "RIGHT";
    break;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
  rc = ast_intern_picx(ast, table, table_len, &table_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, on_sql, on_len, &on_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = ast->raw->raw(ast->raw, on_a, &on_node);
  if (crc != C_ORM_OK) {
    return cobol_orm_from_c_orm(crc);
  }
  return cobol_orm_from_c_orm(
      ast->raw->join(ast->raw, table_a, jtype, on_node));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_group_by(
    cobol_orm_ast_t *ast, const char *cols, cobol_orm_u32_t cols_len) {
  const char *cols_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, cols, cols_len, &cols_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(ast->raw->group_by(ast->raw, cols_a));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_order_by(cobol_orm_ast_t *ast, const char *col,
                       cobol_orm_u32_t col_len, cobol_orm_i32_t is_desc) {
  const char *col_a = NULL;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = ast_intern_picx(ast, col, col_len, &col_a);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(
      ast->raw->order_by(ast->raw, col_a, (int)is_desc));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_limit_offset(cobol_orm_ast_t *ast, cobol_orm_u32_t limit,
                           cobol_orm_u32_t offset) {
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  if (limit > 0) {
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(ast->raw->limit(ast->raw, (size_t)limit)));
  }
  if (offset > 0) {
    rc = cobol_orm_keep_err(
        rc, cobol_orm_from_c_orm(ast->raw->offset(ast->raw, (size_t)offset)));
  }
  return rc;
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_with_lock(cobol_orm_ast_t *ast, cobol_orm_isolation_t iso) {
  c_orm_ast_lock_mode_t mode;
  cobol_orm_error_t rc = check_ast(ast);

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  switch (iso) {
  case COBOL_ORM_ISO_UR:
    mode = C_ORM_AST_LOCK_WITH_UR;
    break;
  case COBOL_ORM_ISO_CS:
    mode = C_ORM_AST_LOCK_WITH_CS;
    break;
  case COBOL_ORM_ISO_RS:
    mode = C_ORM_AST_LOCK_WITH_RS;
    break;
  case COBOL_ORM_ISO_RR:
    mode = C_ORM_AST_LOCK_WITH_RR;
    break;
  default:
    return COBOL_ORM_ERROR_VALIDATION;
  }
  return cobol_orm_from_c_orm(ast->raw->with_lock(ast->raw, mode));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t cobol_orm_ast_to_sql(
    cobol_orm_ast_t *ast, cobol_orm_dialect_t dialect, char *out_sql,
    cobol_orm_u32_t sql_cap, cobol_orm_u32_t *out_len) {
  c_orm_dialect_t core_dialect;
  char *sql = NULL;
  c_orm_query_params_t params;
  cobol_orm_error_t rc = check_ast(ast);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = cobol_orm_map_dialect(dialect, &core_dialect);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_query_params_init(&params);
  rc = cobol_orm_from_c_orm(crc);
  crc = c_orm_query_to_sql(ast->raw, core_dialect, &sql, &params);
  rc = cobol_orm_keep_err(rc, cobol_orm_from_c_orm(crc));
  rc = cobol_orm_keep_err(
      rc, cobol_orm_from_c_orm(c_orm_query_params_cleanup(&params)));
  if (rc != COBOL_ORM_OK) {
    return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(sql)));
  }
  rc = cobol_orm_cstr_to_picx(sql, out_sql, sql_cap, out_len);
  return cobol_orm_keep_err(rc, cobol_orm_from_c_orm(c_orm_system_free(sql)));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_exec(cobol_orm_db_t *db, cobol_orm_ast_t *ast) {
  cobol_orm_error_t rc = cobol_orm_check_db(db);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  rc = check_ast(ast);
  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  return cobol_orm_from_c_orm(c_orm_query_execute(db->raw, ast->raw));
}

COBOL_ORM_EXPORT COBOL_ORM_NO_DISCARD cobol_orm_error_t
cobol_orm_ast_free(cobol_orm_ast_t *ast) {
  cobol_orm_error_t rc = check_ast(ast);
  c_orm_error_t crc;

  if (rc != COBOL_ORM_OK) {
    return rc;
  }
  crc = c_orm_query_free(ast->raw);
  ast->magic = 0;
  ast->raw = NULL;
  return cobol_orm_keep_err(cobol_orm_from_c_orm(crc),
                            cobol_orm_from_c_orm(c_orm_system_free(ast)));
}
