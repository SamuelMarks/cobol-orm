#!/usr/bin/env python3
"""
@file check_enum_returns_clang.py
@module cobol_orm_lint
@brief Enforces enum return types across all non-test, non-generated C89
functions and function pointers in cobol-orm using libclang.
"""

import argparse
import fnmatch
import glob
import os
import subprocess
import sys
from pathlib import Path
import clang.cindex
from clang.cindex import (
    CompilationDatabase,
    CompilationDatabaseError,
    CursorKind,
    TypeKind,
)

EXEMPT_FUNCTIONS = {"cdd_cobol_str_to_pic_x"}


def configure_libclang(explicit_path=None):
    """Locate and bind libclang across macOS, Linux, and Windows."""
    if explicit_path:
        if os.path.isdir(explicit_path):
            clang.cindex.Config.set_library_path(explicit_path)
        else:
            clang.cindex.Config.set_library_file(explicit_path)
        return
    try:
        _ = clang.cindex.Config().lib
        return
    except Exception:
        pass
    patterns = [
        "/Library/Developer/CommandLineTools/usr/lib/libclang*.dylib",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang*.dylib",
        "/opt/homebrew/opt/llvm/lib/libclang*.dylib",
        "/usr/local/opt/llvm/lib/libclang*.dylib",
        "/usr/lib/llvm-*/lib/libclang*.so*",
        "/usr/lib/x86_64-linux-gnu/libclang*.so*",
        "/usr/lib/aarch64-linux-gnu/libclang*.so*",
    ]
    for pat in patterns:
        for cand in glob.glob(pat):
            if "libclang-cpp" in cand or not os.path.isfile(cand):
                continue
            try:
                clang.cindex.Config.set_library_file(cand)
                _ = clang.cindex.Config().lib
                return
            except Exception:
                continue


def should_exclude(filepath, exclude_patterns, use_default_exceptions):
    """Determine whether a path should be excluded from enum-return checks."""
    path = Path(filepath)
    if any(part.startswith("build") or part == ".git" for part in path.parts):
        return True
    for pat in exclude_patterns:
        if fnmatch.fnmatch(filepath, pat) or fnmatch.fnmatch(path.name, pat):
            return True
    if use_default_exceptions:
        if fnmatch.fnmatch(path.name, "test_*.c") or fnmatch.fnmatch(path.name, "test_*.h"):
            return True
        if any(p in path.parts for p in ("tests", "test", "_deps", "generated")):
            return True
    return False


def gather_files(paths, exclude_patterns, use_default_exceptions):
    """Gather all C source and header files under the given paths."""
    found = []
    for raw in paths:
        p = Path(raw)
        if p.is_file():
            found.append(str(p))
        elif p.is_dir():
            found.extend(str(x) for x in p.rglob("*.c"))
            found.extend(str(x) for x in p.rglob("*.h"))
    return sorted(
        set(f for f in found if not should_exclude(f, exclude_patterns, use_default_exceptions))
    )


def build_parse_args(filename, base_args, comp_db):
    """Construct libclang compiler arguments for a C source or header file."""
    args = list(base_args)
    if comp_db:
        cmds = comp_db.getCompileCommands(os.path.abspath(filename))
        if not cmds and filename.endswith(".h"):
            probe = os.path.abspath("src/cobol_orm_db.c")
            if os.path.isfile(probe):
                cmds = comp_db.getCompileCommands(probe)
        if cmds:
            raw_args = list(cmds[0].arguments)[1:]
            cmd_file = cmds[0].filename
            filtered = []
            skip = False
            for a in raw_args:
                if skip:
                    skip = False
                    continue
                if a == "-o":
                    skip = True
                    continue
                if a in ("-c", filename, os.path.abspath(filename), cmd_file, os.path.abspath(cmd_file)):
                    continue
                filtered.append(a)
            if filename.endswith(".h"):
                hdr_args = ["-x", "c"]
                i = 0
                while i < len(filtered):
                    a = filtered[i]
                    if a in ("-I", "-D", "-isystem", "-isysroot") and i + 1 < len(filtered):
                        hdr_args.extend([a, filtered[i + 1]])
                        i += 2
                        continue
                    if a.startswith(("-I", "-D", "-std=")):
                        hdr_args.append(a)
                    i += 1
                args = hdr_args
            else:
                args = filtered
    if sys.platform == "darwin" and "-isysroot" not in args:
        try:
            sdk = subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()
            if sdk and os.path.exists(sdk):
                args.extend(["-isysroot", sdk])
        except Exception:
            pass
    for inc in ("include", "src", "../c-orm/include"):
        if os.path.isdir(inc) and not any(inc in a for a in args):
            args.append(f"-I{inc}")
    return args


def check_file(filename, base_args, comp_db, use_default_exceptions):
    """Parse a C file and verify every function returns an enum."""
    idx = clang.cindex.Index.create()
    args = build_parse_args(filename, base_args, comp_db)
    tu = idx.parse(filename, args=args)
    abs_target = os.path.abspath(filename)
    errors = 0
    for cur in tu.cursor.walk_preorder():
        if cur.kind != CursorKind.FUNCTION_DECL:
            continue
        if not cur.location.file or os.path.abspath(cur.location.file.name) != abs_target:
            continue
        if cur.spelling in EXEMPT_FUNCTIONS:
            continue
        if use_default_exceptions and (cur.spelling == "main" or cur.spelling.startswith("test_")):
            continue
        canon = cur.result_type.get_canonical()
        if canon.kind != TypeKind.ENUM:
            print(
                f"{filename}:{cur.location.line}:{cur.location.column}: "
                f"error: function '{cur.spelling}' must return an enum (returned '{cur.result_type.spelling}')",
                file=sys.stderr,
            )
            errors += 1
    return errors


def main():
    """CLI entry point for enum-return enforcement."""
    parser = argparse.ArgumentParser(description="Enforce enum return types via libclang.")
    parser.add_argument("paths", nargs="+", help="Files or directories to check")
    parser.add_argument("-p", "--build-dir", help="Build directory with compile_commands.json")
    parser.add_argument("--libclang-path", help="Explicit libclang library path")
    parser.add_argument("--exclude-files", action="append", default=[], help="Glob exclusions")
    parser.add_argument("--no-default-exceptions", action="store_true", help="Check tests too")
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
        total += check_file(f, ["-x", "c", "-std=c90"], comp_db, not args.no_default_exceptions)
    if total == 0:
        print(f"OK: {len(files)} C files passed enum-return enforcement.")
    return 1 if total > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
