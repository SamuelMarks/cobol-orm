#!/usr/bin/env python3
"""
@file check_no_discard_void_clang.py
@module cobol_orm_lint
@brief AST checker using libclang that forbids discarding function return values
via `(void)func(...)` casts or ignored enum-returning call expressions.
"""

import argparse
import os
import sys
from pathlib import Path
import clang.cindex
from clang.cindex import CompilationDatabase, CompilationDatabaseError, CursorKind, TypeKind

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_enum_returns_clang import build_parse_args, configure_libclang, gather_files


def check_file(filename, base_args, comp_db):
    """Walk AST of `filename` and report any `(void)` cast of a function call."""
    idx = clang.cindex.Index.create()
    args = build_parse_args(filename, base_args, comp_db)
    tu = idx.parse(filename, args=args)
    abs_target = os.path.abspath(filename)
    errors = 0

    for cur in tu.cursor.walk_preorder():
        if not cur.location.file or os.path.abspath(cur.location.file.name) != abs_target:
            continue
        if cur.kind == CursorKind.CSTYLE_CAST_EXPR:
            if cur.type.get_canonical().kind == TypeKind.VOID:
                for child in cur.walk_preorder():
                    if child.kind == CursorKind.CALL_EXPR:
                        print(
                            f"{filename}:{cur.location.line}:{cur.location.column}: "
                            f"error: forbidden (void) cast discarding call result '{child.spelling}'",
                            file=sys.stderr,
                        )
                        errors += 1
                        break
    return errors


def main():
    """CLI entry point for no-discard `(void)` cast verification."""
    parser = argparse.ArgumentParser(description="Forbid (void) return-value discards via libclang.")
    parser.add_argument("paths", nargs="+", help="Files or directories to check")
    parser.add_argument("-p", "--build-dir", help="Build directory with compile_commands.json")
    parser.add_argument("--libclang-path", help="Explicit libclang library path")
    parser.add_argument("--exclude-files", action="append", default=[], help="Glob exclusions")
    parser.add_argument("--no-default-exceptions", action="store_true", help="Include test files")
    args = parser.parse_args()

    configure_libclang(args.libclang_path)
    comp_db = None
    if args.build_dir:
        try:
            comp_db = CompilationDatabase.fromDirectory(args.build_dir)
        except CompilationDatabaseError as exc:
            print(f"Error loading compile_commands.json from {args.build_dir}: {exc}", file=sys.stderr)
            return 1

    files = gather_files(args.paths, args.exclude_files, not args.no_default_exceptions)
    total = 0
    for f in files:
        total += check_file(f, ["-x", "c", "-std=c90"], comp_db)
    if total == 0:
        print(f"OK: {len(files)} C files passed no-discard (void) cast check.")
    return 1 if total > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
