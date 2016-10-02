;;; packages.el --- bsag-misc layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: BSAG <butshesagirl@rousette.org.uk>
;; URL: https://github.com/bsag
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `bsag-misc-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `bsag-misc/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `bsag-misc/pre-init-PACKAGE' and/or
;;   `bsag-misc/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst bsag-misc-packages
  '()
  "The list of Lisp packages required by the bsag-misc layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")


;; Reading a PDF while taking notes in another window (2 window setup)
;; Hit M-[/M-] to go up/down while keeping cursor in current window.
;; http://www.idryman.org/blog/2013/05/20/emacs-and-pdf/
(fset 'doc-prev "\C-xo\C-u\C-xo")
(fset 'doc-next "\C-xo\C-d\C-xo")
(global-set-key (kbd "M-[") 'doc-prev)
(global-set-key (kbd "M-]") 'doc-next)

;; Marked.app integration
(defun bsag-misc/markdown-preview-file ()
  "Open current buffer in Marked 2.app"
  (interactive)
  (shell-command
   (format "open -a '/Applications/Marked 2.app' %s"
           (shell-quote-argument (buffer-file-name))))
  )

;; Set a global key to open Marked: <SPC> om
(evil-leader/set-key "om" 'bsag-misc/markdown-preview-file)
;;; packages.el ends here
