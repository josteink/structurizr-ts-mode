;;; structurizr-ts-mode.el --- tree-sitter support for Structurizr  -*- lexical-binding: t; -*-

;; Copyright (C) 2023-2024 Free Software Foundation, Inc.

;; Author     : Jostein Kjønigsen <jostein@kjonigsen.net>
;; Maintainer : Jostein Kjønigsen <jostein@kjonigsen.net>
;; Created    : December 2023
;; Keywords   : structurizr languages tree-sitter
;; Version    : 0.1.3
;; X-URL      : https://github.com/josteink/structurizr-ts-mode

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;

;;; Code:

(require 'treesit)

(declare-function treesit-parser-create "treesit.c")
(declare-function treesit-induce-sparse-tree "treesit.c")
(declare-function treesit-node-start "treesit.c")
(declare-function treesit-node-type "treesit.c")
(declare-function treesit-node-child "treesit.c")
(declare-function treesit-node-child-by-field-name "treesit.c")

(defgroup structurizr nil
  "Major-mode for editing Structurizr-files"
  :group 'languages)

(defcustom structurizr-ts-mode-indent-offset 4
  "Number of spaces for each indentation step in `structurizr-ts-mode'."
  :type 'natnum
  :safe 'natnump
  :group 'structurizr)

(defvar structurizr-ts-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?=  "."   table)
    (modify-syntax-entry ?\n "> b" table)
    table)
  "Syntax table for `structurizr-ts-mode'.")

(defvar structurizr-ts-mode--indent-rules
  `((structurizr
     ((parent-is "dsl") column-0 0)
     ((node-is "}") parent-bol 0)
     ((parent-is "workspace_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "model_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "software_system_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "container_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "person_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "views_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "styles_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "element_declaration") parent-bol structurizr-ts-mode-indent-offset)
     ((parent-is "configuration_declaration") parent-bol structurizr-ts-mode-indent-offset)
     )))

(setq structurizr-ts-mode--font-lock-settings
      (treesit-font-lock-rules
       :language 'structurizr
       :feature 'comment
       '((comment) @font-lock-comment-face)

       :language 'structurizr
       :feature 'string
       '((string) @font-lock-string-face)

       :language 'structurizr
       :feature 'number
       '((number) @font-lock-number-face)

       :language 'structurizr
       :feature 'delimiter
       '(("=") @font-lock-delimiter-face
         ("->") @font-lock-delimiter-face
         ("{") @font-lock-delimiter-face
         ("}") @font-lock-delimiter-face)

       :language 'structurizr
       :feature 'keyword
       `(["workspace" "!identifiers" "model" "views" "styles" "configuration" "scope"] @font-lock-keyword-face
         ["element" "softwaresystem" "container" "person" "systemcontext"] @font-lock-function-name-face
         ["include" "exclude" "autolayout" "tag" "tags"] @font-lock-type-face
         )

       :language 'structurizr
       :feature 'definition
       '((element_property
          key: (identifier) @font-lock-type-face)
         (element_property
          value: (identifier) @default)

         (identifier) @font-lock-variable-name-face
         (wildcard_identifier) @font-lock-variable-name-face
         )

       :language 'structurizr
       :feature 'error
       :override t
       '((ERROR) @font-lock-warning-face))
      ;;"Font-lock settings for STRUCTURIZR."
      )

(defun structurizr-ts-mode--defun-name (node)
  "Return the defun name of NODE.
Return nil if there is no name or if NODE is not a defun node."
  (if (member (treesit-node-type node) '("decorator" "decorators"))
      (let* ((node_end (treesit-node-end node))
             (start_next (+ 1 node_end))
             (end_next (+ 100 start_next)))
        (structurizr-ts-mode--defun-name (treesit-node-on start_next end_next 'structurizr)))
    (treesit-node-text node)))

;; (defun structurizr-ts-mode--first-identifier (node)
;;   (car
;;    (treesit-node-children node "identifier")))

;;;###autoload
(define-derived-mode structurizr-ts-mode prog-mode "Structurizr"
  "Major mode for editing STRUCTURIZR, powered by tree-sitter."
  :group 'structurizr-mode

  (when (treesit-ready-p 'structurizr)
    (treesit-parser-create 'structurizr)

    ;; Comments
    (setq-local comment-start "// ")
    (setq-local comment-end "")

    (setq-local electric-indent-chars
                (append "{}" electric-indent-chars))
    (setq-local electric-layout-rules
                '((?\{ . after) (?\} . before)))


    ;; Indent.
    (setq-local treesit-simple-indent-rules structurizr-ts-mode--indent-rules)

    ;; Navigation.
    (setq-local treesit-defun-type-regexp
                (rx (or "workspace_declaration"
                        "model_declaration"
                        "variable_declaration"
                        "sotware_system_declaration"
                        "containainer_declaration"
                        "person_declaration"
                        "views_declaration"
                        "system_context_view_declaration" "container_view_declaration" "dynamic_view_declaration")))
    (setq-local treesit-defun-name-function #'structurizr-ts-mode--defun-name)

    ;; Font-lock.
    (setq-local treesit-font-lock-settings structurizr-ts-mode--font-lock-settings)
    (setq-local treesit-font-lock-feature-list
                '((comment delimiter keyword)
                  (definition number string)
                  (error)))

    ;; Imenu.
    (setq-local treesit-simple-imenu-settings
                '(("Workspaces" "\\`workspace_declaration\\'" nil nil)
                  ("Model" "\\`model_declaration\\'" nil nil)
                  ("Views" "\\`views_declaration\\'" nil nil)
                  ("Configuration" "\\`configuratiojn_declaration\\'" nil nil)))

    (treesit-major-mode-setup)))

;;;###autoload
(and (fboundp 'treesit-ready-p)
     (treesit-ready-p 'structurizr)
     (progn
       (add-to-list 'auto-mode-alist '("\\.structurizr\\(param\\)?\\'"
                                       . structurizr-ts-mode))))

;; Our treesit-font-lock-rules expect this version of the grammar:
(add-to-list 'treesit-language-source-alist
             '(structurizr . ("https://github.com/josteink/tree-sitter-structurizr/" "master")))

(provide 'structurizr-ts-mode)

;;; structurizr-ts-mode.el ends here
