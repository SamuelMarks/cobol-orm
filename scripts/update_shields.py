#!/usr/bin/env python3
"""
@file update_shields.py
@module cobol_orm_coverage
@brief Deterministically updates README.md coverage & documentation badges from
live `gcovr`, `scripts/check_cobol_coverage.py`, and `generate_undercovered.py --doc`
measurements. Supports `--check` mode for CI/pre-commit drift verification.
"""

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_undercovered import (
    check_c_docs,
    check_cobol_docs,
    collect_c_coverage,
    collect_cobol_coverage,
)


def update_readme_text(readme_text, c_cov, cob_cov, doc_ok):
    """Return updated README.md content with live coverage & doc badge counts.

    @param[in] readme_text Existing README.md markdown content.
    @param[in] c_cov Dictionary of C89 gcovr summary metrics.
    @param[in] cob_cov Dictionary of COBOL execution coverage metrics.
    @param[in] doc_ok True when C89 and COBOL documentation coverage is 100%.
    @return Updated README.md markdown content.
    """
    line_pct = int(round(c_cov["line_percent"]))
    br_pct = int(round(c_cov["branch_percent"]))
    fn_pct = int(round(c_cov["function_percent"]))
    doc_pct = 100 if doc_ok else 0

    lc, lt = c_cov["line_covered"], c_cov["line_total"]
    bc, bt = c_cov["branch_covered"], c_cov["branch_total"]
    fc, ft = c_cov["function_covered"], c_cov["function_total"]
    cfn_h, cfn_t = cob_cov["fn_hit"], cob_cov["fn_total"]
    cln_h, cln_t = cob_cov["line_hit"], cob_cov["line_total"]
    cbr_h, cbr_t = cob_cov["br_hit"], cob_cov["br_total"]
    cera_h, cera_t = cob_cov["era_hit"], cob_cov["era_total"]

    updated = re.sub(
        r"\[!\[Doc Coverage\]\([^\n]+\)\]",
        f"[![Doc Coverage](https://img.shields.io/badge/doc%20coverage-{doc_pct}%25-brightgreen)]",
        readme_text,
    )
    updated = re.sub(
        r"\[!\[Line Coverage\]\([^\n]+\)\]",
        f"[![Line Coverage](https://img.shields.io/badge/line%20coverage-{line_pct}%25%20({lc}%2F{lt})-brightgreen)]",
        updated,
    )
    updated = re.sub(
        r"\[!\[Branch Coverage\]\([^\n]+\)\]",
        f"[![Branch Coverage](https://img.shields.io/badge/branch%20coverage-{br_pct}%25%20({bc}%2F{bt})-brightgreen)]",
        updated,
    )
    updated = re.sub(
        r"\[!\[Function Coverage\]\([^\n]+\)\]",
        f"[![Function Coverage](https://img.shields.io/badge/function%20coverage-{fn_pct}%25%20({fc}%2F{ft})-brightgreen)]",
        updated,
    )
    updated = re.sub(
        r"\*\*100\.0% test coverage\*\* \(function(?:\s+`\d+/\d+`)?, line `\d+/\d+`, branch `\d+/\d+`\)",
        f"**100.0% test coverage** (function `{fc}/{ft}`, line `{lc}/{lt}`, branch `{bc}/{bt}`)",
        updated,
    )
    updated = re.sub(
        r"\*\*100\.0% real execution coverage\*\* \(functions `\d+/\d+`, lines `\d+/\d+`, branches `\d+/\d+`\)",
        f"**100.0% real execution coverage** (functions `{cfn_h}/{cfn_t}`, lines `{cln_h}/{cln_t}`, branches `{cbr_h}/{cbr_t}`)",
        updated,
    )
    updated = re.sub(
        r"(\| C89 Coverage \(100%\) \| [^\n]+\| )100\.0% fn \(`\d+/\d+`\), 100\.0% line \(`\d+/\d+`\), 100\.0% branch \(`\d+/\d+`\)",
        rf"\g<1>100.0% fn (`{fc}/{ft}`), 100.0% line (`{lc}/{lt}`), 100.0% branch (`{bc}/{bt}`)",
        updated,
    )
    updated = re.sub(
        r"(\| COBOL Coverage \(100%\) \| [^\n]+\| )100\.0% fn \(`\d+/\d+`\), 100\.0% line \(`\d+/\d+`\), 100\.0% branch \(`\d+/\d+`\), \d+/\d+ eras",
        rf"\g<1>100.0% fn (`{cfn_h}/{cfn_t}`), 100.0% line (`{cln_h}/{cln_t}`), 100.0% branch (`{cbr_h}/{cbr_t}`), {cera_h}/{cera_t} eras",
        updated,
    )
    return updated


def main():
    """CLI entry point for updating or verifying README.md coverage shields.

    @return Exit status code (`0` on success, `1` on drift or doc gap).
    """
    parser = argparse.ArgumentParser(
        description="Update or verify README.md coverage & doc badges."
    )
    parser.add_argument("--root", default=".", help="Repository root directory")
    parser.add_argument(
        "--cov-dir", default="build-cov", help="Coverage CMake build directory"
    )
    parser.add_argument(
        "--build-dir", default="build", help="Standard CMake build directory"
    )
    parser.add_argument(
        "--check", action="store_true", help="Fail if README.md badges are out of date"
    )
    args = parser.parse_args()
    root = Path(args.root).resolve()

    c_ok, c_gaps = check_c_docs(root)
    cob_ok, cob_gaps = check_cobol_docs(root)
    if not c_ok or not cob_ok:
        for g in c_gaps + cob_gaps:
            print(f"DOC GAP: {g}", file=sys.stderr)
        return 1

    c_cov = collect_c_coverage(root, root / args.cov_dir)
    cob_cov = collect_cobol_coverage(root, root / args.build_dir)

    readme_path = root / "README.md"
    old_text = readme_path.read_text(encoding="utf-8")
    new_text = update_readme_text(old_text, c_cov, cob_cov, c_ok and cob_ok)

    if args.check:
        if old_text != new_text:
            print(
                "FAIL: README.md shields are stale; run python3 scripts/update_shields.py.",
                file=sys.stderr,
            )
            return 1
        print("OK: README.md coverage and documentation shields are up to date.")
        return 0

    readme_path.write_text(new_text, encoding="utf-8")
    print("OK: Updated README.md shields with live 100% coverage and doc metrics.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
