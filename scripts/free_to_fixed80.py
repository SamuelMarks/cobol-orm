#!/usr/bin/env python3
"""
@file free_to_fixed80.py
@module cobol_orm_codegen
@brief Converts GnuCOBOL free-format (.cpy/.cbl) files into strict 80-column
fixed-format COBOL (cols 1-6 blank, col 7 indicator, Area A 8-11, Area B 12-72)
compatible with IBM Enterprise COBOL, Micro Focus, and GnuCOBOL -fixed, and
verifies strict 72/80-column margin compliance.
"""

import argparse
import os
import re
import sys

AREA_A_RE = re.compile(
    r"^(IDENTIFICATION\s+DIVISION|ENVIRONMENT\s+DIVISION|DATA\s+DIVISION|"
    r"PROCEDURE\s+DIVISION|WORKING-STORAGE\s+SECTION|LINKAGE\s+SECTION|"
    r"LOCAL-STORAGE\s+SECTION|FILE\s+SECTION|CONFIGURATION\s+SECTION|"
    r"INPUT-OUTPUT\s+SECTION|PROGRAM-ID\.|END\s+PROGRAM\b|"
    r"01\s+|77\s+|FD\s+|SD\s+|RD\s+)",
    re.IGNORECASE,
)


def wrap_comment(text):
    """Wrap comment text into col-7 '*' fixed-format lines (<= 72 chars)."""
    text = text.strip()
    if not text:
        return ["      *"]
    out = []
    max_body = 64  # cols 8..72 -> "      * " is 8 chars, leaving 64 chars
    words = text.split()
    cur = ""
    for w in words:
        if not cur:
            cur = w
        elif len(cur) + 1 + len(w) <= max_body:
            cur = cur + " " + w
        else:
            out.append("      * " + cur[:max_body])
            cur = w
    if cur:
        out.append("      * " + cur[:max_body])
    return out


def wrap_code_line(indent_col, text):
    """Wrap a COBOL statement cleanly within columns [indent_col..72]."""
    max_col = 72
    prefix = " " * indent_col
    if indent_col + len(text) <= max_col:
        return [prefix + text]

    # Split at token boundaries outside quotes
    tokens = []
    cur = ""
    in_q = None
    for ch in text:
        if in_q:
            cur += ch
            if ch == in_q:
                in_q = None
        else:
            if ch in ('"', "'"):
                in_q = ch
                cur += ch
            elif ch.isspace():
                if cur:
                    tokens.append(cur)
                    cur = ""
            else:
                cur += ch
    if cur:
        tokens.append(cur)

    lines = []
    line = prefix
    cont_prefix = " " * 15
    for tok in tokens:
        sep = "" if line.strip() == "" else " "
        if len(line) + len(sep) + len(tok) <= max_col:
            line = line + sep + tok
        else:
            if line.strip():
                lines.append(line)
            line = cont_prefix + tok
    if line.strip():
        lines.append(line)
    return lines


def convert_lines(lines):
    """Convert free-format COBOL source lines into strict fixed-80 lines."""
    out = []
    for raw in lines:
        line = raw.rstrip("\r\n")
        stripped = line.strip()
        if not stripped:
            out.append("")
            continue
        if stripped.upper().startswith(">>SOURCE FORMAT"):
            continue
        if stripped.startswith("*>"):
            out.extend(wrap_comment(stripped[2:]))
            continue

        # Strip inline *> comments safely outside quoted strings
        code_part = stripped
        comment_part = None
        in_q = None
        for idx in range(len(stripped) - 1):
            ch = stripped[idx]
            if in_q:
                if ch == in_q:
                    in_q = None
            else:
                if ch in ('"', "'"):
                    in_q = ch
                elif ch == "*" and stripped[idx + 1] == ">":
                    code_part = stripped[:idx].rstrip()
                    comment_part = stripped[idx + 2 :].strip()
                    break

        if comment_part:
            out.extend(wrap_comment(comment_part))
        if not code_part:
            continue

        if AREA_A_RE.match(code_part):
            out.extend(wrap_code_line(7, code_part))
        elif re.match(r"^(05|10|15|20|49|88)\s+", code_part):
            out.extend(wrap_code_line(11, code_part))
        elif code_part.upper().startswith("COPY "):
            out.extend(wrap_code_line(7, code_part))
        else:
            out.extend(wrap_code_line(11, code_part))
    return out


def verify_fixed_file(path):
    """Verify strict 72/80-column fixed-format compliance on a single file."""
    errors = []
    with open(path, "r", encoding="utf-8") as fp:
        for lineno, raw in enumerate(fp, 1):
            line = raw.rstrip("\r\n")
            if len(line) > 72:
                errors.append(f"{path}:{lineno}: exceeds column 72 ({len(line)} chars)")
            if "*>" in line or ">>SOURCE FORMAT" in line.upper():
                errors.append(
                    f"{path}:{lineno}: forbidden free-format token in fixed file"
                )
            if line and len(line) >= 7:
                ind = line[6]
                if ind not in (" ", "*", "/", "-", "D", "d"):
                    errors.append(
                        f"{path}:{lineno}: invalid column 7 indicator '{ind}'"
                    )
    return errors


def main():
    """CLI entry point for free_to_fixed80.py."""
    parser = argparse.ArgumentParser(
        description="Convert or verify fixed 80-column COBOL."
    )
    parser.add_argument(
        "--verify", nargs="+", help="Verify fixed-format compliance on files/dirs"
    )
    parser.add_argument("-i", "--input", help="Input free-format .cpy/.cbl file")
    parser.add_argument("-o", "--output", help="Output fixed-format .cpy/.cbl file")
    args = parser.parse_args()

    if args.verify:
        all_errs = []
        for target in args.verify:
            if os.path.isdir(target):
                for root, _, files in os.walk(target):
                    for fn in sorted(files):
                        if fn.endswith((".cpy", ".cbl", ".cob")):
                            all_errs.extend(verify_fixed_file(os.path.join(root, fn)))
            else:
                all_errs.extend(verify_fixed_file(target))
        if all_errs:
            for e in all_errs:
                print(e, file=sys.stderr)
            return 1
        return 0

    if not args.input or not args.output:
        parser.error("Provide either --verify or both --input and --output")

    with open(args.input, "r", encoding="utf-8") as fp:
        src_lines = fp.readlines()
    fixed_lines = convert_lines(src_lines)
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as fp:
        for ln in fixed_lines:
            fp.write(ln + "\n")
    errs = verify_fixed_file(args.output)
    if errs:
        for e in errs:
            print(e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
