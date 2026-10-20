#import "../meta.typ": *

#heading(numbering: none)[Preface]

This guide describes `typst-doctorate-template`, a two-sided book template for doctoral theses written in Typst. It was made for a thesis in theoretical physics and therefore cares about mathematics: equation numbering per chapter and per appendix, displays that break and number as in LaTeX, running text that keeps its line spacing around notation, and macros for Dirac notation.

The guide is itself set with the template, so its pages show the result of every setting it describes. Part I explains how to write a thesis with it; Part II explains how it is built, for those who want to change it. To start your own thesis, keep the structure of the folder, delete the guide chapters and `chapters/_guide.typ`, and write your chapters in their place.
