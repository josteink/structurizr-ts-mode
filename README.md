# structurizr-ts-mode

[![CI](https://github.com/josteink/structurizr-ts-mode/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/josteink/structurizr-ts-mode/actions/workflows/ci.yml)

[Structurizr DSL](https://structurizr.com)-support for C4 models in
[GNU Emacs](https://www.gnu.org/software/emacs/), powered by the
[tree-sitter](https://tree-sitter.github.io/tree-sitter/) parser library.

## Features supported

- basic fontification for most common statements (workspaces, models,
  views, tags, styles)
- indentation & nesting

## Prerequisites

To use this package with GNU Emacs you need the following
prerequisites:

- GNU Emacs built with tree-sitter support enabled
- [Structurizr language grammar for tree-sitter](https://github.com/josteink/tree-sitter-structurizr/)

## Installation

Right now neither the tree-sitter grammar, not the major-mode is
published or distributed in any official or semi-official
package-manager, so you will have to install both manually.

1. Verify Emacs has tree-sitter support enabled. In `C-h v
   system-configuration-features` look for `TREE_SITTER`.
2. Install the tree-sitter grammar `M-x
   treesit-install-language-grammar`, and provide `structurizr` as
   name and `https://github.com/josteink/tree-sitter-structurizr/` as
   source repo. Use defaults for everything else.
3. Clone the repo somewhere locally and load it from there. The
   following use-package statement might work:

```lisp
(use-package structurizr-ts-mode
  :ensure t
  :vc ( :url "https://github.com/josteink/structurizr-ts-mode"
        :rev :newest))
```

If you have any issues or corrections, feel free to provide a PR to
help others :)

