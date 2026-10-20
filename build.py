#!/usr/bin/env python3
"""Build main.pdf with the fonts in ./fonts (plus Typst's built-ins) only."""
import pathlib
import typst

ROOT = pathlib.Path(__file__).resolve().parent

typst.compile(
    str(ROOT / "main.typ"),
    output=str(ROOT / "main.pdf"),
    font_paths=[str(ROOT / "fonts")],
    ignore_system_fonts=True,
)
print("Wrote", ROOT / "main.pdf")
