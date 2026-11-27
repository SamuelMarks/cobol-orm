#!/usr/bin/env bash
# @file generate_bindings.sh
# @module cobol_orm_codegen
# @brief Reproducibly extracts cobol-orm FFI IR via libclang, invokes cdd-c
# (`cdd-c bind -l cobol`) to generate free-format Copybooks, subprograms, C89
# ABI shims, and ABI layout tests, and emits strict fixed 80-column variants.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_MODE=0
if [ "${1:-}" = "--check" ]; then
  CHECK_MODE=1
fi

CDD_BIN="${COBOL_ORM_CDD_C_BIN:-}"
if [ -z "$CDD_BIN" ]; then
  if [ -x "$ROOT_DIR/../cdd-c/bin/cdd-c" ]; then
    CDD_BIN="$ROOT_DIR/../cdd-c/bin/cdd-c"
  elif command -v cdd-c >/dev/null 2>&1; then
    CDD_BIN="$(command -v cdd-c)"
  else
    echo "Error: cdd-c binary not found (set COBOL_ORM_CDD_C_BIN or build ../cdd-c)" >&2
    exit 1
  fi
fi

WORK_DIR="$ROOT_DIR"
TMP_STAGE=""
if [ "$CHECK_MODE" -eq 1 ]; then
  TMP_STAGE="$(mktemp -d)"
  trap 'rm -rf "$TMP_STAGE"' EXIT
  WORK_DIR="$TMP_STAGE"
fi

mkdir -p "$WORK_DIR/ffi" "$WORK_DIR/generated/free" "$WORK_DIR/generated/fixed" "$WORK_DIR/src/generated"

# Step 1: Extract lossless normalized FFI IR JSON from C89 headers
python3 "$ROOT_DIR/scripts/header_to_cdd_ir.py" \
  -i "$ROOT_DIR/include/cobol_orm_ffi.h" \
  -I "$ROOT_DIR/include" \
  -o "$WORK_DIR/ffi/cobol_orm_ffi.json"

# Step 2: Run cdd-c bind -l cobol on the normalized FFI IR
"$CDD_BIN" bind \
  -i "$WORK_DIR/ffi/cobol_orm_ffi.json" \
  -o "$WORK_DIR/generated/free" \
  -l cobol \
  -n cobol_orm \
  -m cobol_orm \
  --generate-tests

# Step 3: Annotate & copy strict C89 ABI shim into src/generated/
python3 "$ROOT_DIR/scripts/doc_cobol_shim.py" \
  --ir "$WORK_DIR/ffi/cobol_orm_ffi.json" \
  --header "$WORK_DIR/generated/free/cobol_orm_cobol_shim.h"
cp "$WORK_DIR/generated/free/cobol_orm_cobol_shim.h" "$WORK_DIR/src/generated/cobol_orm_cobol_shim.h"
cp "$WORK_DIR/generated/free/cobol_orm_cobol_shim.c" "$WORK_DIR/src/generated/cobol_orm_cobol_shim.c"

# Step 4: Emit strict 80-column fixed-format variants for IBM Enterprise / MF / Legacy COBOL
python3 "$ROOT_DIR/scripts/free_to_fixed80.py" \
  -i "$WORK_DIR/generated/free/cobol_orm.cpy" \
  -o "$WORK_DIR/generated/fixed/cobol_orm.cpy"
python3 "$ROOT_DIR/scripts/free_to_fixed80.py" \
  -i "$WORK_DIR/generated/free/cobol_orm.cbl" \
  -o "$WORK_DIR/generated/fixed/cobol_orm.cbl"
python3 "$ROOT_DIR/scripts/free_to_fixed80.py" \
  -i "$WORK_DIR/generated/free/cobol_orm_test.cbl" \
  -o "$WORK_DIR/generated/fixed/cobol_orm_test.cbl"

if [ "$CHECK_MODE" -eq 1 ]; then
  diff -ru "$ROOT_DIR/ffi/cobol_orm_ffi.json" "$WORK_DIR/ffi/cobol_orm_ffi.json"
  diff -ru "$ROOT_DIR/generated/free" "$WORK_DIR/generated/free"
  diff -ru "$ROOT_DIR/generated/fixed" "$WORK_DIR/generated/fixed"
  diff -ru "$ROOT_DIR/src/generated" "$WORK_DIR/src/generated"
  echo "OK: generated COBOL FFI bindings match live cdd-c output byte-for-byte."
else
  echo "Generated COBOL FFI bindings via $CDD_BIN successfully."
fi
