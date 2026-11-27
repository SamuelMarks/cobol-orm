# Memory Ownership & OOM Safety

## Handle Lifecycle Rules

Every opaque handle allocated by `cobol-orm` has an explicit destructor that scrubs its 32-bit magic tag before freeing memory, neutralizing double-free and use-after-free bugs:

| Handle Type | Constructor | Destructor |
| :--- | :--- | :--- |
| `cobol_orm_db_t *` | `cobol_orm_connect` | `cobol_orm_disconnect` |
| `cobol_orm_db_t *` (pooled) | `cobol_orm_pool_acquire` | `cobol_orm_pool_release` |
| `cobol_orm_pool_t *` | `cobol_orm_pool_init` | `cobol_orm_pool_destroy` |
| `cobol_orm_stmt_t *` | `cobol_orm_stmt_prepare[_cached]` | `cobol_orm_stmt_finalize` |
| `cobol_orm_rs_t *` | `cobol_orm_query_abstract` | `cobol_orm_rs_free` |
| `cobol_orm_ast_t *` | `cobol_orm_ast_new` | `cobol_orm_ast_free` |
| `cobol_orm_cpy_t *` | `cobol_orm_cpy_parse_{str,file}` | `cobol_orm_cpy_free` |
| `cobol_orm_mig_t *` | `cobol_orm_mig_init` | `cobol_orm_mig_free` |
| Legacy COMMAREA slots (`1..64`) | `OP_CONNECT` / `OP_STMT_PREPARE` | `OP_DISCONNECT` / `OP_STMT_FINALIZE` / `cobol_orm_legacy_reset` |

## Deterministic OOM & Sanitizer Guarantees

- All heap allocations route through `c_orm_system_malloc` / `c_orm_system_calloc` / `c_orm_system_free` so `test_cobol_orm_c` deterministically injects allocation failures at every allocation site via `c_orm_set_allocators`.
- Every error-return path unwinds all partially-allocated buffers and combines cleanup errors via `cobol_orm_keep_err`.
- Verified leak-free and UB-free under `-fsanitize=address,undefined` (`-DCOBOL_ORM_ENABLE_ASAN=ON`).
