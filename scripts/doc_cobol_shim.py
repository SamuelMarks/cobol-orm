#!/usr/bin/env python3
"""
@file doc_cobol_shim.py
@module cobol_orm_codegen
@brief Enriches cdd-c generated C89 COBOL ABI shim headers and sources with
100% Doxygen documentation pulled deterministically from the normalized FFI IR
JSON so `src/generated/` passes `doxygen Doxyfile.in` (`WARN_AS_ERROR=YES`).
"""

import argparse
import json
import re
import sys
from pathlib import Path


def load_ir_docs(ir_path):
    """Build lookup tables for struct and field docstrings from FFI IR JSON."""
    data = json.loads(Path(ir_path).read_text(encoding="utf-8"))
    struct_docs = {}
    field_docs = {}
    for node in data.get("nodes", []):
        name = node.get("name")
        if not name:
            continue
        doc = (node.get("doc_comment") or "").strip()
        if doc:
            struct_docs[name] = doc
        fmap = {}
        for f in node.get("fields", []):
            fname = f.get("name")
            fdoc = (f.get("doc_comment") or "").strip()
            if fname and fdoc:
                fmap[fname] = fdoc
        if fmap:
            field_docs[name] = fmap
    return struct_docs, field_docs


def format_doxygen_brief(text, indent=""):
    """Format a single-line or multi-line docstring as a Doxygen block."""
    clean = " ".join(line.strip() for line in text.splitlines() if line.strip())
    if "@brief" in clean:
        return f"{indent}/** {clean} */\n"
    return f"{indent}/** @brief {clean} */\n"


def annotate_shim_header(hdr_text, struct_docs, field_docs):
    """Inject complete Doxygen comments into a cdd-c COBOL shim header."""
    lines = hdr_text.splitlines(keepends=True)
    out = []
    cur_struct = None
    in_struct = False

    guard_re = re.compile(r"^#define\s+(CDD_COBOL_SHIM_[A-Z0-9_]+)\s*$")
    struct_re = re.compile(r"^(struct|union)\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{\s*$")
    field_re = re.compile(r"^  .*?\b([A-Za-z_][A-Za-z0-9_]*)(?:\[\d+\])?;\s*$")

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        gm = guard_re.match(stripped)
        if gm:
            out.append(f"/** @brief Header guard for generated shim ({gm.group(1)}). */\n")
            out.append(line)
            i += 1
            continue

        if "typedef __int64 cdd_cob_i64;" in line or "typedef long long cdd_cob_i64;" in line or "typedef long cdd_cob_i64;" in line:
            out.append("/** @brief Portable 64-bit signed integer type for COBOL ABI shims. */\n")
            out.append(line)
            i += 1
            continue

        if "typedef unsigned __int64 cdd_cob_u64;" in line or "typedef unsigned long long cdd_cob_u64;" in line or "typedef unsigned long cdd_cob_u64;" in line:
            out.append("/** @brief Portable 64-bit unsigned integer type for COBOL ABI shims. */\n")
            out.append(line)
            i += 1
            continue

        if stripped.startswith("int cdd_cobol_str_to_pic_x("):
            out.append(
                "/**\n"
                " * @brief Copies a NUL-terminated C string into a space-padded COBOL PIC X buffer.\n"
                " *\n"
                " * @param[in] c_str Source NUL-terminated C string (or NULL for blank-fill).\n"
                " * @param[out] cob_buf Destination COBOL PIC X character buffer.\n"
                " * @param[in] cob_len Capacity of `cob_buf` in bytes.\n"
                " * @return `0` on success, or `-1` if `cob_buf` is NULL.\n"
                " */\n"
            )
            out.append(line)
            i += 1
            continue

        sm = struct_re.match(stripped)
        if sm:
            cur_struct = sm.group(2)
            in_struct = True
            sdoc = struct_docs.get(cur_struct, f"ABI shim mirror of {sm.group(1)} {cur_struct}.")
            out.append(format_doxygen_brief(sdoc))
            out.append(line)
            i += 1
            continue

        if in_struct and stripped == "};":
            in_struct = False
            cur_struct = None
            out.append(line)
            i += 1
            continue

        if in_struct and cur_struct:
            fm = field_re.match(line)
            if fm:
                fname = fm.group(1)
                fdoc = field_docs.get(cur_struct, {}).get(
                    fname, f"ABI field `{fname}` of `{cur_struct}`."
                )
                out.append(format_doxygen_brief(fdoc, indent="  "))
                out.append(line)
                i += 1
                continue

        out.append(line)
        i += 1

    return "".join(out)


def main():
    """CLI entry point for annotating generated C89 COBOL ABI shim headers."""
    parser = argparse.ArgumentParser(description="Annotate cdd-c COBOL shim header with Doxygen comments.")
    parser.add_argument("--ir", required=True, help="Path to normalized FFI IR JSON")
    parser.add_argument("--header", required=True, help="Path to *_cobol_shim.h to annotate in place")
    args = parser.parse_args()

    struct_docs, field_docs = load_ir_docs(args.ir)
    hdr_path = Path(args.header)
    annotated = annotate_shim_header(hdr_path.read_text(encoding="utf-8"), struct_docs, field_docs)
    hdr_path.write_text(annotated, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
