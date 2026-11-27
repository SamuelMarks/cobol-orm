#!/usr/bin/env python3
"""
@file header_to_cdd_ir.py
@module cobol_orm_codegen
@brief Parses cobol-orm C89 FFI headers via libclang into cdd-c's lossless
normalized FFI IR JSON schema for consumption by `cdd-c bind -l cobol`.
"""

import argparse
import json
import os
import re
import sys
from clang.cindex import Config, CursorKind, Index, TypeKind


def configure_libclang():
    """Locate libclang shared library across macOS, Linux, and custom envs."""
    candidates = []
    if os.environ.get("LIBCLANG_PATH"):
        candidates.append(os.environ["LIBCLANG_PATH"])
    candidates.extend(
        [
            "/Library/Developer/CommandLineTools/usr/lib/libclang.dylib",
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib",
            "/opt/homebrew/opt/llvm/lib/libclang.dylib",
            "/usr/local/opt/llvm/lib/libclang.dylib",
            "/usr/lib/llvm-18/lib/libclang.so",
            "/usr/lib/llvm-17/lib/libclang.so",
            "/usr/lib/x86_64-linux-gnu/libclang-18.so.1",
            "/usr/lib/x86_64-linux-gnu/libclang.so",
        ]
    )
    for cand in candidates:
        if os.path.isfile(cand):
            Config.set_library_file(cand)
            return
        if os.path.isdir(cand):
            Config.set_library_path(cand)
            return


# cdd_ffi_node_kind_t
NODE_STRUCT = 0
NODE_UNION = 1
NODE_ENUM = 2
NODE_FUNCTION = 3
NODE_TYPEDEF = 4
NODE_MACRO = 5

# cdd_ffi_primitive_kind_t
KIND_VOID = 0
KIND_BOOL = 1
KIND_INT8 = 2
KIND_UINT8 = 3
KIND_INT16 = 4
KIND_UINT16 = 5
KIND_INT32 = 6
KIND_UINT32 = 7
KIND_INT64 = 8
KIND_UINT64 = 9
KIND_FLOAT32 = 10
KIND_FLOAT64 = 11
KIND_STRUCT_REF = 12
KIND_ENUM_REF = 14
KIND_TYPEDEF_REF = 15
KIND_OPAQUE_PTR = 16

# cdd_ffi_param_intent_t
INTENT_UNKNOWN = 0
INTENT_IN = 1
INTENT_OUT = 2
INTENT_INOUT = 3

# cdd_ffi_macro_type_t
MACRO_INT = 1
MACRO_STRING = 3


def clean_doc(raw_comment):
    """Strip C Doxygen comment delimiters into clean multi-line prose."""
    if not raw_comment:
        return None
    lines = []
    for line in raw_comment.splitlines():
        s = line.strip()
        if s.startswith("/**<"):
            s = s[4:]
        elif s.startswith("/**"):
            s = s[3:]
        elif s.startswith("/*"):
            s = s[2:]
        if s.endswith("*/"):
            s = s[:-2]
        s = s.lstrip("*").strip()
        if s:
            lines.append(s)
    return "\n".join(lines) if lines else None


def map_clang_type(ctype, known_structs, known_enums):
    """Map a libclang Type into a cdd_ffi_type_t dictionary."""
    pointer_depth = 0
    array_size = 0
    is_const = 0

    t = ctype
    if t.kind == TypeKind.CONSTANTARRAY:
        array_size = int(t.element_count)
        t = t.element_type

    while t.kind == TypeKind.POINTER:
        pointer_depth += 1
        t = t.get_pointee()

    if t.is_const_qualified():
        is_const = 1

    # Unwrap typedefs while honoring named enums/structs and fixed-width ints
    canon = t.get_canonical()
    decl_name = t.get_declaration().spelling if t.get_declaration() else ""

    if canon.kind == TypeKind.ENUM:
        enum_name = decl_name or canon.get_declaration().spelling
        return {
            "kind": KIND_ENUM_REF if enum_name in known_enums else KIND_INT32,
            "is_const": is_const,
            "pointer_depth": pointer_depth,
            "ref_name": enum_name if enum_name in known_enums else None,
            "array_size": array_size,
        }

    if canon.kind == TypeKind.RECORD:
        rec_name = canon.get_declaration().spelling or decl_name
        if rec_name in known_structs:
            return {
                "kind": KIND_STRUCT_REF,
                "is_const": is_const,
                "pointer_depth": pointer_depth,
                "ref_name": rec_name,
                "array_size": array_size,
            }
        return {
            "kind": KIND_OPAQUE_PTR,
            "is_const": is_const,
            "pointer_depth": max(pointer_depth, 1),
            "array_size": array_size,
        }

    kind_map = {
        TypeKind.VOID: KIND_VOID,
        TypeKind.BOOL: KIND_BOOL,
        TypeKind.CHAR_S: KIND_INT8,
        TypeKind.SCHAR: KIND_INT8,
        TypeKind.CHAR_U: KIND_UINT8,
        TypeKind.UCHAR: KIND_UINT8,
        TypeKind.SHORT: KIND_INT16,
        TypeKind.USHORT: KIND_UINT16,
        TypeKind.INT: KIND_INT32,
        TypeKind.UINT: KIND_UINT32,
        TypeKind.LONG: KIND_INT64 if canon.get_size() == 8 else KIND_INT32,
        TypeKind.ULONG: KIND_UINT64 if canon.get_size() == 8 else KIND_UINT32,
        TypeKind.LONGLONG: KIND_INT64,
        TypeKind.ULONGLONG: KIND_UINT64,
        TypeKind.FLOAT: KIND_FLOAT32,
        TypeKind.DOUBLE: KIND_FLOAT64,
    }
    ffi_kind = kind_map.get(canon.kind, KIND_OPAQUE_PTR)

    # Note: for `const char *` input buffers that take explicit `len` parameter,
    # treat as raw pointer unless single-string; keep pointer_depth intact.
    return {
        "kind": ffi_kind,
        "is_const": is_const,
        "pointer_depth": pointer_depth,
        "array_size": array_size,
    }


def extract_param_intents(raw_doc):
    """Parse @param[in|out|inout] annotations from a function docstring."""
    intents = {}
    if not raw_doc:
        return intents
    for m in re.finditer(
        r"@param\[(in|out|in,out)\]\s+([A-Za-z_][A-Za-z0-9_]*)", raw_doc
    ):
        mode, pname = m.group(1), m.group(2)
        if mode == "in":
            intents[pname] = INTENT_IN
        elif mode == "out":
            intents[pname] = INTENT_OUT
        else:
            intents[pname] = INTENT_INOUT
    return intents


def extract_ir(header_path, include_dir):
    """Extract normalized cdd-c FFI IR dictionary from cobol-orm headers."""
    configure_libclang()
    idx = Index.create()
    tu = idx.parse(
        header_path,
        args=["-std=c90", f"-I{include_dir}"],
    )
    inc_abs = os.path.abspath(include_dir)

    nodes = []
    known_structs = set()
    known_enums = set()
    seen_funcs = set()
    seen_structs = set()
    seen_enums = set()

    # Pass 0: emit key integer/string macro constants from headers
    macro_defs = [
        (
            "COBOL_ORM_DECIMAL_MAX_DIGITS",
            MACRO_INT,
            "38",
            "Maximum decimal digits in cobol_orm_decimal_t.",
        ),
        (
            "COBOL_ORM_COMMAREA_DATA_CAP",
            MACRO_INT,
            "256",
            "Fixed COMMAREA string buffer capacity.",
        ),
        (
            "COBOL_ORM_DISPLAY_COMMAREA_SIZE",
            MACRO_INT,
            "552",
            "Fixed USAGE DISPLAY COMMAREA byte length.",
        ),
        (
            "COBOL_ORM_LEGACY_MAX_HANDLES",
            MACRO_INT,
            "64",
            "Maximum concurrent legacy handle slots.",
        ),
        (
            "COBOL_ORM_VERSION_STR",
            MACRO_STRING,
            '"0.1.0"',
            "Library semantic version string.",
        ),
    ]
    for mname, mtype, mval, mdoc in macro_defs:
        nodes.append(
            {
                "kind": NODE_MACRO,
                "name": mname,
                "doc": mdoc,
                "inferred_type": mtype,
                "evaluated_value": mval,
                "variants": [{"name": mname, "value": mval}],
            }
        )

    # Pass 1: collect enums and structs defined in include_dir
    for cur in tu.cursor.get_children():
        if not cur.location.file:
            continue
        fpath = os.path.abspath(cur.location.file.name)
        if not fpath.startswith(inc_abs):
            continue

        if cur.kind == CursorKind.ENUM_DECL and cur.is_definition():
            ename = cur.spelling
            if not ename or ename in seen_enums:
                continue
            seen_enums.add(ename)
            known_enums.add(ename)
            variants = []
            for child in cur.get_children():
                if child.kind == CursorKind.ENUM_CONSTANT_DECL:
                    vstr = str(child.enum_value)
                    variants.append(
                        {
                            "name": child.spelling,
                            "value": vstr,
                            "doc": clean_doc(child.raw_comment),
                            "raw_spelling": vstr,
                        }
                    )
            nodes.append(
                {
                    "kind": NODE_ENUM,
                    "name": ename,
                    "doc": clean_doc(cur.raw_comment),
                    "variants": variants,
                }
            )

        elif cur.kind == CursorKind.STRUCT_DECL:
            sname = cur.spelling
            if not sname or sname in seen_structs:
                continue
            if cur.is_definition():
                seen_structs.add(sname)
                known_structs.add(sname)
                fields = []
                for fld in cur.get_children():
                    if fld.kind == CursorKind.FIELD_DECL:
                        fields.append(
                            {
                                "name": fld.spelling,
                                "doc": clean_doc(fld.raw_comment),
                                "type": map_clang_type(
                                    fld.type, known_structs, known_enums
                                ),
                                "intent": INTENT_UNKNOWN,
                            }
                        )
                nodes.append(
                    {
                        "kind": NODE_STRUCT,
                        "name": sname,
                        "doc": clean_doc(cur.raw_comment),
                        "fields": fields,
                    }
                )
            else:
                # Forward-declared opaque handle struct
                seen_structs.add(sname)
                known_structs.add(sname)
                nodes.append(
                    {
                        "kind": NODE_STRUCT,
                        "name": sname,
                        "doc": clean_doc(cur.raw_comment),
                        "fields": [],
                    }
                )

    # Pass 2: collect all public exported functions
    for cur in tu.cursor.get_children():
        if not cur.location.file:
            continue
        fpath = os.path.abspath(cur.location.file.name)
        if not fpath.startswith(inc_abs):
            continue

        if cur.kind == CursorKind.FUNCTION_DECL:
            fname = cur.spelling
            if not fname.startswith("cobol_orm_") or fname in seen_funcs:
                continue
            seen_funcs.add(fname)
            intents = extract_param_intents(cur.raw_comment)
            params = []
            for arg in cur.get_arguments():
                aname = arg.spelling or f"arg_{len(params)}"
                atype = map_clang_type(arg.type, known_structs, known_enums)
                # Explicit-length char buffers must be passed as raw pointer
                # rather than cdd-c's 256-byte NUL-terminated cstr shorthand
                # when pointer_depth == 1 and kind == INT8 with is_const.
                # Keep `is_const` only if we want automatic PIC X(256) trim;
                # clear intent to UNKNOWN for raw pointer buffers with length.
                pintent = intents.get(aname, INTENT_UNKNOWN)
                if atype["kind"] == KIND_INT8 and atype["pointer_depth"] == 1:
                    atype["kind"] = KIND_VOID
                    atype["is_const"] = 0
                    pintent = INTENT_UNKNOWN
                params.append(
                    {
                        "name": aname,
                        "type": atype,
                        "intent": pintent,
                    }
                )
            nodes.append(
                {
                    "kind": NODE_FUNCTION,
                    "name": fname,
                    "doc": clean_doc(cur.raw_comment),
                    "return_or_base_type": map_clang_type(
                        cur.result_type, known_structs, known_enums
                    ),
                    "fields": params,
                }
            )

    return {"nodes": nodes}


def main():
    """CLI entry point for header_to_cdd_ir.py."""
    parser = argparse.ArgumentParser(
        description="Extract cdd-c FFI IR JSON from C89 headers."
    )
    parser.add_argument("-i", "--input", required=True, help="Umbrella C header path")
    parser.add_argument(
        "-I", "--include-dir", required=True, help="Header include directory"
    )
    parser.add_argument(
        "-o", "--output", required=True, help="Output IR JSON file path"
    )
    args = parser.parse_args()

    ir = extract_ir(args.input, args.include_dir)
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as fp:
        json.dump(ir, fp, indent=2)
        fp.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
