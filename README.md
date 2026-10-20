# typst-doctorate-template

A two-sided book template for doctoral theses in [Typst](https://typst.app),
written for a physics PhD thesis at the University of Amsterdam. It is a single
self-contained file (`template/thesis.typ`) with no package dependencies.

See [`example.pdf`](example.pdf) for the rendered example thesis.

## Features

- Front, main and back matter with roman and arabic folios
- Full-page part dividers that do not disturb the page numbering
- Chapter thumb tabs on the page edge (one colour per chapter) and a running header
- Per-chapter numbering of equations, figures and tables, `(2.4)`, and of
  per-chapter appendices, `(2.A.4)`, with cross-references that stay correct
  from anywhere in the document
- A styled table of contents and an automatic "In this chapter" mini-TOC
- Equation handling in the LaTeX tradition: numbers kept clear of wide formulas,
  ordinary displays kept whole across page breaks, and `breakeq[..]` for long
  displays that may split (the number is set once, beside the last line)
- Running-text maths kept on the line grid of the text
- Physics helpers: `ket`, `bra`, `braket`, `expval`, `dket`, `bigO`,
  `compact-sums`, `smashop`, `substack`, `flush-sets`
- Extras: highlight boxes (`concept`), boxed and unnumbered equations,
  subfigures, booktabs-style tables (`btable`), a coauthor-contributions page,
  and an optional flip-book animation in the page corner
- APS citation style with DOI links (`template/aps-doi.csl`)

## Layout

```
main.typ            the whole thesis: render this
preview.typ         render one chapter alone, with the real styling
meta.typ            shared settings and macros; every file imports this
template/           the template itself and the citation style
frontmatter/        title pages, preface
chapters/           one file per chapter
backmatter/         contributions, summaries, acknowledgements
references.bib      bibliography
fonts/              optional fonts (not included, see below)
```

Fonts, paper size, margins, colours and numbering are arguments of `thesis()`,
set once in `meta.typ` (`conf`). The comments at the top of
`template/thesis.typ` list every option.

## Building

```sh
typst compile --font-path fonts --ignore-system-fonts main.typ
typst compile --font-path fonts preview.typ --input file=chapters/ch1_example.typ
```

or `python3 build.py` (needs `pip install typst`). The VS Code settings in
`.vscode/` point the Tinymist preview at the same fonts.

## Fonts

The template builds with Typst's built-in fonts alone. The defaults in
`meta.typ` prefer the following free fonts when they are placed in `fonts/`:

- [KpMath](https://ctan.org/pkg/kpfonts-otf) (maths)
- [STIX Two](https://github.com/stipub/stixfonts) (headings and calligraphic letters)

## License

The template is released under the
[Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/)
license (see `LICENSE`). Please credit "typst-doctorate-template by Suvendu Kumar Barik".

`template/aps-doi.csl` is adapted from the American Physical Society style of
the [Citation Style Language](https://citationstyles.org) project and remains
under its original
[CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) license.
