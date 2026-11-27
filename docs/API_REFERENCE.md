# cobol-orm API Reference

All public C89 FFI functions are declared in [include/cobol_orm_ffi.h](../include/cobol_orm_ffi.h), return `cobol_orm_error_t` with `COBOL_ORM_NO_DISCARD`, and have 1:1 `cdd-c`-generated COBOL bindings in `generated/free/cobol_orm.cbl` and `generated/fixed/cobol_orm.cbl`.

## Module A — Connection & Lifecycle
- `cobol_orm_connect(url, url_len, out_db)` — Connect via URL (`sqlite://`, `memory://`, `postgres://`, `mysql://`, `odbc://`, `db2://`).
- `cobol_orm_disconnect(db)` — Close and free a database handle.
- `cobol_orm_exec_sql(db, sql, sql_len)` — Execute raw DDL/DML SQL.
- `cobol_orm_last_error(db, out_buf, buf_cap, out_len)` — Retrieve last driver error string.
- `cobol_orm_last_trace(db, out_buf, buf_cap, out_len)` — Retrieve last diagnostic trace.
- `cobol_orm_last_insert_rowid(db, out_rowid)` — Retrieve last inserted row ID.
- `cobol_orm_enable_stmt_cache(db, capacity)` — Enable (`>0`) or disable (`0`) LRU prepared statement cache.
- `cobol_orm_set_timezone(db, offset_minutes, tz_name, tz_len)` — Configure session timezone.
- `cobol_orm_set_slow_query_ms(db, threshold_ms)` — Set slow-query threshold in milliseconds.
- `cobol_orm_version(out_buf, buf_cap, out_len)` — Write library semantic version (`"0.1.0"`).
- `cobol_orm_error_name(err, out_buf, buf_cap, out_len)` — Format canonical error symbol name.

## Module B — Connection Pooling
- `cobol_orm_pool_init(url, url_len, min_conns, max_conns, timeout_ms, out_pool)`
- `cobol_orm_pool_acquire(pool, out_db)` / `cobol_orm_pool_release(pool, db)`
- `cobol_orm_pool_telemetry(pool, out_stats)` — Populates 24-byte `cobol_orm_pool_stats_t`.
- `cobol_orm_pool_destroy(pool)`

## Module C — Transactions & Savepoints
- `cobol_orm_tx_begin(db)` / `cobol_orm_tx_commit(db)` / `cobol_orm_tx_rollback(db)`
- `cobol_orm_tx_savepoint(db, name, name_len)` / `cobol_orm_tx_release_sp(db, name, name_len)` / `cobol_orm_tx_rollback_sp(db, name, name_len)`

## Module D — Prepared & Cached Statements
- `cobol_orm_stmt_prepare(db, sql, sql_len, out_stmt)` / `cobol_orm_stmt_prepare_cached(...)`
- `cobol_orm_stmt_bind_i32` / `i64` / `f64` / `str` / `blob` / `decimal` / `comp3` / `null`
- `cobol_orm_stmt_step(stmt, out_has_row)` / `cobol_orm_stmt_reset(stmt)` / `cobol_orm_stmt_finalize(stmt)`
- `cobol_orm_stmt_col_count` / `col_name` / `col_is_null` / `col_i32` / `col_i64` / `col_f64` / `col_str` / `col_blob` / `col_decimal` / `col_comp3`

## Module E — Dynamic Abstract Result Sets
- `cobol_orm_query_abstract(db, sql, sql_len, out_rs)`
- `cobol_orm_rs_row_count` / `col_count` / `col_name` / `get_type` / `get_i64` / `get_f64` / `get_str` / `free`

## Module F — Fluent SQL AST Query Builder
- `cobol_orm_ast_new` / `select` / `distinct` / `from` / `insert_into` / `update_table` / `delete_from` / `set_col` / `where_eq` / `join` / `group_by` / `order_by` / `limit_offset` / `with_lock` / `to_sql` / `exec` / `free`

## Module G — 38-Digit Exact Decimal & COBOL Numeric Wire Codecs
- `cobol_orm_dec_from_str` / `to_str` / `add` / `sub` / `mul` / `div` / `cmp`
- `cobol_orm_dec_to_comp3` / `from_comp3` / `to_zoned` / `from_zoned`
- `cobol_orm_i64_to_comp` / `from_comp`

## Module H — Mainframe EBCDIC & UTF-16 GRAPHIC Transcoders
- `cobol_orm_ebcdic_to_utf8` / `utf8_to_ebcdic` (`IBM037`, `IBM1047`, `IBM500`, `IBM1140`)
- `cobol_orm_utf8_to_utf16` / `utf16_to_utf8`

## Module I — COBOL Copybook (.cpy / DCLGEN) & 01-Record CRUD
- `cobol_orm_cpy_parse_str` / `parse_file` / `info` / `field_info` / `set_pk`
- `cobol_orm_cpy_emit_ddl` / `create_table` / `validate_88`
- `cobol_orm_cpy_insert` / `update` / `find_i32` / `find_all` / `delete_i32` / `free`

## Module J — Schema Migrations
- `cobol_orm_mig_init` / `mig_up` / `mig_down` / `mig_free`

## Module K — Enterprise IBM Db2 & ODBC Helpers
- `cobol_orm_odbc_sqlstate` / `cobol_orm_db2_set_isolation` / `cobol_orm_db2_set_schema`

## Module L — Legacy Integer-Handle & COMMAREA Dispatchers
- `cobol_orm_commarea_dispatch` (544-byte native binary COMMAREA)
- `cobol_orm_display_dispatch` (552-byte endian-independent `USAGE DISPLAY` COMMAREA for `COBOL-60`..`COBOL-85`)
- `cobol_orm_legacy_reset` (deterministic cleanup of all 64 DB and 64 statement slots)

## Idiomatic COBOL Wrapper Subprograms (`cobol/{free,fixed}/cobol_orm_lib.cbl`)
- Connections & Diagnostics: `CORM-CONNECT`, `CORM-DISCONNECT`, `CORM-EXEC-SQL`, `CORM-LAST-ERROR`, `CORM-VERSION`
- Transactions & Savepoints: `CORM-TX-BEGIN`, `CORM-TX-COMMIT`, `CORM-TX-ROLLBACK`, `CORM-TX-SAVEPOINT`, `CORM-TX-REL-SP`, `CORM-TX-RB-SP`
- Connection Pooling: `CORM-POOL-INIT`, `CORM-POOL-ACQUIRE`, `CORM-POOL-RELEASE`, `CORM-POOL-STATS`, `CORM-POOL-DESTROY`
- Schema Migrations: `CORM-MIG-INIT`, `CORM-MIG-UP`, `CORM-MIG-DOWN`, `CORM-MIG-FREE`
- Legacy Bridge: `CORM-COMMAREA`
