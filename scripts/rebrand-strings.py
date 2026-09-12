#!/usr/bin/env python3
"""Rebrand the Canvas text a server operator actually reads.

Only the contents of double-quoted string literals are touched, so class names
(CanvasCommands), the io.canvasmc.canvas package and the Weaver plugin id are
left alone. Literals that name upstream — canvasmc.io, CraftCanvasMC — are
skipped too: those are attribution and links that must stay correct.

Patch files are rewritten by substitution only, never by adding or removing
lines, so every hunk header stays valid.
"""
import re, sys, pathlib

SKIP = ("canvasmc.io", "CraftCanvasMC", "io.canvasmc", "canvas-supported")

def fix_literal(body: str) -> str:
    if any(s in body for s in SKIP):
        return body
    body = body.replace("CanvasMC", "Aurora")
    body = re.sub(r"\bCanvas\b", "Aurora", body)
    body = body.replace("/canvas", "/aurora")
    return body

LITERAL = re.compile(r'"((?:[^"\\]|\\.)*)"')

def process(path: pathlib.Path) -> int:
    text = path.read_text()
    is_patch = path.suffix == ".patch"
    out, changed = [], 0
    for line in text.split("\n"):
        # In a patch, only ever rewrite lines the fork adds.
        if is_patch and not line.startswith("+"):
            out.append(line); continue
        if is_patch and line.startswith("+++"):
            out.append(line); continue
        new = LITERAL.sub(lambda m: '"' + fix_literal(m.group(1)) + '"', line)
        if new != line:
            changed += 1
        out.append(new)
    if changed:
        path.write_text("\n".join(out))
    return changed

total = 0
for arg in sys.argv[1:]:
    p = pathlib.Path(arg)
    n = process(p)
    if n:
        print(f"  {n:4d} lines  {p}")
        total += n
print(f"rewrote {total} lines")
