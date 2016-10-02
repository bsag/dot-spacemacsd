;;; packages.el --- bsag-hugo layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: BSAG butshesagirl@rousette.org.uk
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
;; added to `bsag-hugo-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `bsag-hugo/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `bsag-hugo/pre-init-PACKAGE' and/or
;;   `bsag-hugo/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst bsag-hugo-packages
  '()
  "The list of Lisp packages required by the bsag-hugo layer.

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


  (defvar *blog-root*   "~/git/bitbucket/hugoblog/content/archives/")

  (defun strip-nonfile-chars (s)
    (replace-regexp-in-string "[^0-9a-zA-Z_ ]" "" s))

  (defun space-to-dash (s)
    (replace-regexp-in-string " " "-" s))

  (defun title-to-blog-filename (title)
    (concat (format-time-string "%Y-%m-%d") "-" (title-to-slug title)
            ".md"))
  (defun title-to-slug (title)
    (downcase (space-to-dash (strip-nonfile-chars title))))

  (defun date-to-tzstamp ()
      (concat (format-time-string "%Y-%m-%dT%T")
              ((lambda (x) (concat (substring x 0 3) ":" (substring x 3 5)))
               (format-time-string "%z"))))

  (defun start-blog-entry ()
    "Creates a new markdown blog entry for pelican"
    (interactive)
    (let ((title (read-from-minibuffer "Title of new blog entry? ")))
      (find-file (concat *blog-root* (title-to-blog-filename title)))
      (insert (format (concat "---\n"
                              "title: \"%s\"\n"
                              "date: %s\n"
                              "tags: [\"\"]\n"
                              "slug: \"%s\"\n"
                              "---\n\n")
                      title
                      (date-to-tzstamp)
                      (title-to-slug title)
                      ))))
;;; packages.el ends here
