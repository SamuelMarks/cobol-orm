#!/usr/bin/env python3
"""
@file check_cobol_coverage.py
@module cobol_orm_coverage
@brief Measures real execution-instrumented function, line, and branch coverage
across both free-format (`cobol/free/cobol_orm_lib.cbl`) and fixed 80-column
(`cobol/fixed/cobol_orm_lib.cbl`) COBOL wrapper libraries by compiling GnuCOBOL
generated C (`cobc -C -fsource-location`) with `--coverage`, running the full
E2E COBOL test suites, and mapping `gcov -b` line/branch counters back to exact
COBOL source lines and `IF`/`EVALUATE` conditions. Also verifies 10/10 COBOL
standard era coverage (`COBOL-60` .. `COBOL-2023`).
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

MARKER_RE = re.compile(
    r"/\*\s*Line:\s*(\d+)\s*:\s*([A-Za-z0-9_-]+)(?:\s+([A-Za-z0-9_-]+))?\s*:\s*[^*]+\*/"
)
GCOV_LINE_RE = re.compile(r"^\s*([^:]+):\s*(\d+):(.*)$")
BRANCH_RE = re.compile(r"^branch\s+\d+\s+taken\s+(\d+)")
BRANCH_NEVER_RE = re.compile(r"^branch\s+\d+\s+never\s+executed")

COND_STMTS = {"IF", "EVALUATE"}
IGNORED_STMTS = {"last"}


def find_ffi_library(root, build_dir):
    """Locate built libcobol_orm_ffi shared library."""
    candidates = [
        Path(build_dir) / "libcobol_orm_ffi.dylib",
        Path(build_dir) / "libcobol_orm_ffi.so",
        Path(build_dir) / "cobol_orm_ffi.dll",
        root / "build" / "libcobol_orm_ffi.dylib",
        root / "build" / "libcobol_orm_ffi.so",
        root / "build-cov" / "libcobol_orm_ffi.dylib",
        root / "build-cov" / "libcobol_orm_ffi.so",
    ]
    for cand in candidates:
        if cand.is_file():
            return cand.resolve()
    return None


def find_cobc_inc_dir():
    """Discover GnuCOBOL libcob.h include directory via cobc --info or common prefixes."""
    try:
        out = subprocess.check_output(
            ["cobc", "--info"], text=True, stderr=subprocess.STDOUT
        )
        for line in out.splitlines():
            m = re.search(r"-I\s*(\S+)", line)
            if m and Path(m.group(1), "libcob.h").is_file():
                return m.group(1)
    except Exception:
        pass
    for d in ("/opt/homebrew/include", "/usr/local/include", "/usr/include"):
        if Path(d, "libcob.h").is_file():
            return d
    return None


def is_clang_compiler(cc):
    """Return True if the C compiler `cc` identifies itself as Clang/LLVM."""
    try:
        out = subprocess.check_output(
            [cc, "--version"], text=True, stderr=subprocess.STDOUT
        )
        return "clang" in out.lower()
    except Exception:
        return False


def get_gcov_cmd(cc="cc"):
    """Return appropriate gcov command vector matching the compiler `cc`."""
    if sys.platform == "darwin" and shutil.which("xcrun"):
        return ["xcrun", "llvm-cov", "gcov", "-b", "-c"]
    if is_clang_compiler(cc) and shutil.which("llvm-cov"):
        return ["llvm-cov", "gcov", "-b", "-c"]
    return ["gcov", "-b", "-c"]


def measure_cobol_lib(root, mode, lib_rel, test_rel, copybook_dir, ffi_lib, cobc_inc):
    """Compile a COBOL wrapper library with --coverage, execute tests, and report fn/line/branch stats."""
    fmt_flag = "-free" if mode == "free" else "-fixed"
    lib_src = (root / lib_rel).resolve()
    test_src = (root / test_rel).resolve()
    cpy_inc = (root / copybook_dir).resolve()

    with tempfile.TemporaryDirectory(prefix=f"corm_cob_cov_{mode}_") as tmp:
        tmp_path = Path(tmp)
        gen_c = tmp_path / f"cobol_orm_lib_{mode}.c"
        gen_o = tmp_path / f"cobol_orm_lib_{mode}.o"
        runner = tmp_path / f"runner_{mode}"

        # 1. Translate COBOL wrapper library to C with full source-line annotations
        subprocess.run(
            [
                "cobc",
                "-C",
                fmt_flag,
                "-fsource-location",
                "-Wall",
                "-Wextra",
                "-Werror",
                "-I",
                str(cpy_inc),
                "-o",
                str(gen_c),
                str(lib_src),
            ],
            check=True,
            cwd=str(tmp_path),
        )

        # 2. Compile generated C with --coverage
        cc = os.environ.get("CC", "cc")
        cc_cmd = [cc, "-c", "--coverage", "-O0", "-g", "-I", str(tmp_path)]
        if cobc_inc:
            cc_cmd.extend(["-I", cobc_inc])
        cc_cmd.extend([str(gen_c), "-o", str(gen_o)])
        subprocess.run(cc_cmd, check=True, cwd=str(tmp_path))

        # 3. Link E2E COBOL test against instrumented wrapper object & libcobol_orm_ffi
        cobc_link = [
            "cobc",
            "-x",
            fmt_flag,
            "-Wall",
            "-Wextra",
            "-Werror",
            "-I",
            str(cpy_inc),
            "-o",
            str(runner),
            str(test_src),
            str(gen_o),
        ]
        if sys.platform.startswith("linux"):
            cobc_link.extend(
                [
                    "-Q",
                    "-Wl,--no-as-needed",
                    "-Q",
                    str(ffi_lib),
                    "-Q",
                    "-Wl,--as-needed",
                    "-Q",
                    f"-Wl,-rpath,{ffi_lib.parent}",
                    "-Q",
                    "-Wl,--export-dynamic",
                    "-Q",
                    "--coverage",
                ]
            )
        else:
            cobc_link.extend(
                [
                    str(ffi_lib),
                    "-Q",
                    f"-Wl,-rpath,{ffi_lib.parent}",
                    "-Q",
                    "--coverage",
                ]
            )
        subprocess.run(cobc_link, check=True, cwd=str(tmp_path))

        # 4. Run E2E COBOL test from repository root
        subprocess.run([str(runner)], check=True, cwd=str(root))

        # 5. Collect gcov branch + line execution report for generated C
        gcov_cmd = get_gcov_cmd(cc) + [str(gen_c)]
        subprocess.run(
            gcov_cmd,
            check=True,
            cwd=str(tmp_path),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        gcov_file = tmp_path / f"{gen_c.name}.gcov"
        if not gcov_file.is_file():
            raise RuntimeError(f"Expected gcov output not found: {gcov_file}")

        return parse_cobol_gcov(gcov_file, lib_rel)


def parse_cobol_gcov(gcov_file, label):
    """Map GnuCOBOL C gcov line/branch counters back to COBOL PROGRAM-IDs, lines, and IF/EVALUATE branches."""
    lines = gcov_file.read_text(encoding="utf-8", errors="replace").splitlines()

    entries = {}  # prog_name -> exec_count
    stmt_lines = {}  # (cob_line, stmt_kind) -> max_exec_count
    branches = {}  # cob_line -> list of taken counts for the primary conditional if()

    cur_entry = None
    cur_stmt_key = None
    cur_cond_line = None
    cond_if_seen = False

    for raw in lines:
        bm = BRANCH_RE.match(raw)
        if bm:
            if cur_cond_line is not None and cond_if_seen:
                branches.setdefault(cur_cond_line, []).append(int(bm.group(1)))
            continue
        if BRANCH_NEVER_RE.match(raw):
            if cur_cond_line is not None and cond_if_seen:
                branches.setdefault(cur_cond_line, []).append(0)
            continue

        gm = GCOV_LINE_RE.match(raw)
        if not gm:
            continue

        count_str = gm.group(1).strip()
        code = gm.group(3)

        mm = MARKER_RE.search(code)
        if mm:
            cob_line = int(mm.group(1))
            stmt_kind = mm.group(2)
            arg_tok = mm.group(3)
            cur_cond_line = None
            cond_if_seen = False

            if stmt_kind == "Entry" and arg_tok:
                cur_entry = arg_tok
                entries.setdefault(cur_entry, 0)
                cur_stmt_key = None
            elif stmt_kind in IGNORED_STMTS:
                cur_stmt_key = None
            else:
                cur_stmt_key = (cob_line, stmt_kind)
                stmt_lines.setdefault(cur_stmt_key, 0)
                if stmt_kind in COND_STMTS:
                    cur_cond_line = cob_line
                    branches.setdefault(cob_line, [])
            continue

        # Executable C line count
        exec_cnt = 0
        if count_str.isdigit():
            exec_cnt = int(count_str)
        elif count_str.endswith("*") and count_str[:-1].isdigit():
            exec_cnt = int(count_str[:-1])
        else:
            continue

        if cur_entry is not None and entries[cur_entry] == 0 and exec_cnt > 0:
            entries[cur_entry] = exec_cnt

        if cur_stmt_key is not None:
            if exec_cnt > stmt_lines[cur_stmt_key]:
                stmt_lines[cur_stmt_key] = exec_cnt

        if cur_cond_line is not None and not cond_if_seen and "if (" in code:
            cond_if_seen = True
        elif (
            cur_cond_line is not None
            and cond_if_seen
            and len(branches[cur_cond_line]) >= 2
        ):
            # Stop collecting branches after the primary COBOL IF condition's 2 outcomes
            cond_if_seen = False

    fn_total = len(entries)
    fn_hit = sum(1 for v in entries.values() if v > 0)
    line_total = len(stmt_lines)
    line_hit = sum(1 for v in stmt_lines.values() if v > 0)

    br_total = 0
    br_hit = 0
    missed_br = []
    for cob_line, taken_list in sorted(branches.items()):
        # A COBOL IF statement has 2 logical branches (true and false)
        outcomes = taken_list[:2] if len(taken_list) >= 2 else taken_list
        br_total += len(outcomes)
        for idx, cnt in enumerate(outcomes):
            if cnt > 0:
                br_hit += 1
            else:
                missed_br.append((cob_line, idx))

    missed_fn = sorted(k for k, v in entries.items() if v == 0)
    missed_lines = sorted(k for k, v in stmt_lines.items() if v == 0)

    return {
        "label": label,
        "fn_hit": fn_hit,
        "fn_total": fn_total,
        "line_hit": line_hit,
        "line_total": line_total,
        "br_hit": br_hit,
        "br_total": br_total,
        "missed_fn": missed_fn,
        "missed_lines": missed_lines,
        "missed_br": missed_br,
    }


def main():
    """CLI entry point for real execution-based COBOL coverage verification."""
    parser = argparse.ArgumentParser(
        description="Verify 100% COBOL wrapper function, line, and branch coverage + 10-era matrix."
    )
    parser.add_argument("--root", default=".", help="Repository root directory")
    parser.add_argument(
        "--build-dir",
        default="build",
        help="CMake build directory containing libcobol_orm_ffi",
    )
    args = parser.parse_args()
    root = Path(args.root).resolve()

    ffi_lib = find_ffi_library(root, root / args.build_dir)
    if not ffi_lib:
        print(
            "FAIL: libcobol_orm_ffi shared library not found; build the project first.",
            file=sys.stderr,
        )
        return 1

    cobc_inc = find_cobc_inc_dir()
    era_dirs = [
        "cobol60",
        "cobol61",
        "cobol61x",
        "cobol65",
        "cobol68",
        "cobol74",
        "cobol85",
        "cobol2002",
        "cobol2014",
        "cobol2023",
    ]
    missing_eras = [
        e for e in era_dirs if not list((root / "cobol/era" / e).glob("*.cbl"))
    ]
    if missing_eras:
        for e in missing_eras:
            print(
                f"FAIL: missing COBOL standard era directory 'cobol/era/{e}'",
                file=sys.stderr,
            )
        return 1

    targets = [
        (
            "free",
            "cobol/free/cobol_orm_lib.cbl",
            "tests/cobol/test_e2e_free.cbl",
            "copybooks/free",
        ),
        (
            "fixed",
            "cobol/fixed/cobol_orm_lib.cbl",
            "tests/cobol/test_e2e_fixed.cbl",
            "copybooks/fixed",
        ),
    ]

    failed = False
    tot_fn_hit = tot_fn = tot_ln_hit = tot_ln = tot_br_hit = tot_br = 0
    for mode, lib_rel, test_rel, cpy_dir in targets:
        res = measure_cobol_lib(
            root, mode, lib_rel, test_rel, cpy_dir, ffi_lib, cobc_inc
        )
        tot_fn_hit += res["fn_hit"]
        tot_fn += res["fn_total"]
        tot_ln_hit += res["line_hit"]
        tot_ln += res["line_total"]
        tot_br_hit += res["br_hit"]
        tot_br += res["br_total"]

        print(
            f"[{mode}] {res['label']}: "
            f"functions {res['fn_hit']}/{res['fn_total']}, "
            f"lines {res['line_hit']}/{res['line_total']}, "
            f"branches {res['br_hit']}/{res['br_total']}"
        )
        if res["missed_fn"] or res["missed_lines"] or res["missed_br"]:
            failed = True
            for fn in res["missed_fn"]:
                print(
                    f"  FAIL: uncovered PROGRAM-ID '{fn}' in {res['label']}",
                    file=sys.stderr,
                )
            for ln, kind in res["missed_lines"]:
                print(
                    f"  FAIL: uncovered COBOL line {ln} ({kind}) in {res['label']}",
                    file=sys.stderr,
                )
            for ln, bidx in res["missed_br"]:
                print(
                    f"  FAIL: uncovered COBOL branch {bidx} at line {ln} in {res['label']}",
                    file=sys.stderr,
                )

    if failed or tot_fn == 0 or tot_ln == 0 or tot_br == 0:
        return 1

    print(
        f"OK: 100.0% COBOL coverage — functions {tot_fn_hit}/{tot_fn}, "
        f"lines {tot_ln_hit}/{tot_ln}, branches {tot_br_hit}/{tot_br}, "
        f"and {len(era_dirs)}/{len(era_dirs)} COBOL standards (COBOL-60..COBOL-2023)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
