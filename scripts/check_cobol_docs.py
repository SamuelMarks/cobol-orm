#!/usr/bin/env python3
"""
@file check_cobol_docs.py
@module cobol_orm_docs
@brief Enforces 100% documentation coverage across COBOL Copybooks (.cpy) and
programs (.cbl): file (@file/@module/@brief), record/class (@class/@field),
data items (@field), level-88 conditions (@cond), and PROGRAM-IDs
(@program/@brief/@param).
"""

import argparse
import os
import re
import sys
from pathlib import Path

COMMENT_RE = re.compile(r"^\s*(?:\*>|\*)\s?(.*)$")
FIXED_COMMENT_RE = re.compile(r"^.{6}\*(.*)$")
PROGRAM_ID_RE = re.compile(r"\bPROGRAM-ID\.\s+([A-Z0-9_-]+)\.", re.IGNORECASE)
DATA_ITEM_RE = re.compile(
    r"^\s*(01|05|10|15|20|77|88)\s+([A-Z0-9_-]+)\b", re.IGNORECASE
)
USING_RE = re.compile(r"PROCEDURE\s+DIVISION\s+USING\s+([^.]+)\.", re.IGNORECASE)


def extract_comment_text(line):
    """Return comment payload if `line` is a free or fixed COBOL comment, else None."""
    if (
        len(line) >= 7
        and line[6] == "*"
        and (line[:6].strip() == "" or line[:6].strip().isdigit())
    ):
        return line[7:].strip()
    m = COMMENT_RE.match(line)
    if m:
        return m.group(1).strip()
    return None


def check_cobol_file(path):
    """Validate 100% doc coverage in a single COBOL .cpy or .cbl file."""
    errors = []
    with open(path, "r", encoding="utf-8") as fp:
        lines = fp.readlines()

    full_text = "".join(lines)
    for tag in ("@file", "@module", "@brief"):
        if tag not in full_text:
            errors.append(f"{path}:1: missing required file-header tag {tag}")

    recent_comments = []
    in_data_div = path.suffix.lower() == ".cpy"
    in_proc_div = False
    program_doc_block = []

    for lineno, raw in enumerate(lines, start=1):
        line = raw.rstrip("\r\n")
        ctext = extract_comment_text(line)
        if ctext is not None:
            recent_comments.append(ctext)
            continue

        stripped = line.strip()
        if not stripped or stripped.startswith(">>"):
            continue

        # Strip fixed-format sequence area if present
        code = (
            line[6:72].strip()
            if (len(line) >= 7 and line[:6].strip() == "" and line[6] == " ")
            else stripped
        )
        upper = code.upper()

        if "DATA DIVISION" in upper:
            in_data_div = True
            in_proc_div = False
            recent_comments = []
            continue
        if "PROCEDURE DIVISION" in upper:
            in_data_div = False
            in_proc_div = True
            # Check @param tags for every USING parameter
            # Join continuation lines up to period if needed
            proc_stmt = code
            look = lineno
            while "." not in proc_stmt and look < len(lines):
                nxt = lines[look].rstrip("\r\n")
                nxt_code = (
                    nxt[6:72].strip()
                    if (len(nxt) >= 7 and nxt[:6].strip() == "" and nxt[6] == " ")
                    else nxt.strip()
                )
                proc_stmt += " " + nxt_code
                look += 1
            um = USING_RE.search(proc_stmt)
            if um:
                raw_params = um.group(1).split()
                skip_kw = {"BY", "REFERENCE", "VALUE", "CONTENT", "OPTIONAL"}
                params = [p.strip(",") for p in raw_params if p.upper() not in skip_kw]
                doc_joined = "\n".join(program_doc_block)
                for p in params:
                    if (
                        f"@param {p}" not in doc_joined
                        and f"@param[in] {p}" not in doc_joined
                        and f"@param[out] {p}" not in doc_joined
                        and f"@param[in,out] {p}" not in doc_joined
                    ):
                        errors.append(
                            f"{path}:{lineno}: missing @param doc for USING parameter '{p}'"
                        )
            recent_comments = []
            continue

        if "IDENTIFICATION DIVISION" in upper:
            program_doc_block = list(recent_comments)
            recent_comments = []
            continue

        pm = PROGRAM_ID_RE.search(code)
        if pm:
            prog_name = pm.group(1)
            doc_joined = "\n".join(program_doc_block + recent_comments)
            if (
                f"@program {prog_name}" not in doc_joined
                and "@program" not in doc_joined
            ):
                errors.append(
                    f"{path}:{lineno}: missing @program doc for PROGRAM-ID '{prog_name}'"
                )
            if "@brief" not in doc_joined:
                errors.append(
                    f"{path}:{lineno}: missing @brief doc for PROGRAM-ID '{prog_name}'"
                )
            program_doc_block = list(program_doc_block + recent_comments)
            recent_comments = []
            continue

        if in_data_div and not in_proc_div:
            dm = DATA_ITEM_RE.match(code)
            if dm:
                lvl = dm.group(1)
                name = dm.group(2)
                if name.upper() == "FILLER":
                    recent_comments = []
                    continue
                doc_joined = "\n".join(recent_comments)
                if lvl == "88":
                    if "@cond" not in doc_joined:
                        errors.append(
                            f"{path}:{lineno}: missing @cond doc for level-88 '{name}'"
                        )
                elif lvl == "01":
                    if "@class" not in doc_joined and "@field" not in doc_joined:
                        errors.append(
                            f"{path}:{lineno}: missing @class or @field doc for level-01 '{name}'"
                        )
                else:
                    if "@field" not in doc_joined and "@class" not in doc_joined:
                        errors.append(
                            f"{path}:{lineno}: missing @field doc for level-{lvl} '{name}'"
                        )
                recent_comments = []
                continue

        if not stripped.startswith(
            (
                "COPY ",
                "WORKING-STORAGE",
                "LINKAGE",
                "LOCAL-STORAGE",
                "ENVIRONMENT",
                "CONFIGURATION",
                "SOURCE-COMPUTER",
                "OBJECT-COMPUTER",
            )
        ):
            recent_comments = []

    return errors


def main():
    """CLI entry point for COBOL documentation coverage checks."""
    parser = argparse.ArgumentParser(
        description="Enforce 100% COBOL documentation coverage."
    )
    parser.add_argument("paths", nargs="+", help="COBOL files or directories to audit")
    args = parser.parse_args()

    files = []
    for p in args.paths:
        path = Path(p)
        if path.is_file():
            files.append(path)
        elif path.is_dir():
            for ext in ("*.cpy", "*.cbl"):
                files.extend(sorted(path.rglob(ext)))

    all_errors = []
    for f in sorted(set(files)):
        all_errors.extend(check_cobol_file(f))

    if all_errors:
        for e in all_errors:
            print(e, file=sys.stderr)
        print(
            f"FAIL: {len(all_errors)} COBOL documentation coverage gaps found.",
            file=sys.stderr,
        )
        return 1

    print(f"OK: {len(files)} COBOL files achieved 100% documentation coverage.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
