;;; packages.el --- bsag-org layer packages file for Spacemacs.
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
;; added to `bsag-org-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `bsag-org/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `bsag-org/pre-init-PACKAGE' and/or
;;   `bsag-org/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code: modelled on https://github.com/CestDiego/spacemacs_conf/blob/master/org-cestdiego/packages.el

(defconst bsag-org-packages
  '(org
    ox-ioslide
    ox-cv
    ;; (ob                        :location built-in)
    (org-protocol              :location built-in)
    (org-capture               :location built-in)
    (org-agenda                :location built-in)
    )
  "The list of Lisp packages required by the bsag-org layer.

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

(defun ensure-in-vc-or-checkin ()
  (interactive)
  (if (file-exists-p (format "%s" (buffer-file-name)))
      (progn (vc-next-action nil) (message "Committed"))
    (ding) (message "File not checked in.")))

(defun export-bibtex ()
  "Exports Papers library using a custom applescript."
  (interactive)
  (message "Exporting papers library...")
  (shell-command "osascript ~/Dropbox/bin/export-papers-as-bibtex.scpt"))

(define-minor-mode lab-notebook-mode
  "Toggle lab notebook mode"
  ;; initial value
  nil
  ;; indicator
  :lighter " LN"
  ;; keybindings
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<f5>") 'export-bibtex)
            map)
  ;; body
  ;; (add-hook 'buffer-list-update-hook 'ensure-in-vc-or-checkin nil 'make-it-local)
)

(defun bsag-org/init-ox-ioslide ()
  (use-package ox-ioslide
    :config
    (require 'ox-ioslide-helper)))

(defun bsag-org/init-org-protocol ()
  (use-package org-protocol))

(defun bsag-org/init-org-capture ()
  (use-package org-capture
    :commands org-capture
    :defer t
    :init
    (add-hook 'org-capture-mode-hook 'evil-insert-state)
    :config
    (defadvice org-switch-to-buffer-other-window
        (after make-full-capture-window-frame activate)
      "Agenda to be the sole window when it is in a popup frame"
      (when (equal "emacs-capture" (frame-parameter nil 'name))
        (delete-other-windows)
        (hidden-mode-line-mode)))

    ;;;; Thank you random guy from StackOverflow
    ;;;; http://goo.gl/OOWIVp
    (defadvice org-capture
        (after make-full-window-frame activate)
      "Advise capture to be the sole window when in a popup frame"
      (when (equal "emacs-capture" (frame-parameter nil 'name))
        (delete-other-windows)))

    ;; alfred-org-capture
    (defun make-orgcapture-frame ()
      "Create a new frame and run org-capture."
      (interactive)
      (make-frame '((name . "emacs-capture") (width . 80) (height . 16)
                    (top . 400) (left . 300)
                    ))
      (select-frame-by-name "emacs-capture")
      (org-capture))

    (defadvice org-capture-finalize
        (after delete-capture-frame activate)
      "Advise capture-finalize to close the frame"
      (if (equal "emacs-capture" (frame-parameter nil 'name))
          (delete-frame)))

    ;;; Capture Templates
    (setq org-capture-templates
          '(("a" "Todo" entry
             (file+headline "inbox.org" "Tasks")
             "* TODO %? %^g \n %i\n")
            ("i" "For jotting quick ideas" entry
             (file+headline "work.org" "Ideas")
             "* %?\n %i\n%t\n%A")
            ("b" "Bookmark links" entry
             (file+headline "links.org" "Bookmarks")
             "* %?%^g")
            ("l" "Links to read" entry
             (file+headline "links.org" "Links")
             "* TO-READ %c %^g\n Entered on: %U\n %?\n%i\n"
             :empy-lines 1)
            ("e" "Lab Notebook entry"
             entry (file+datetree (concat org-directory "lab-notebook.org"))
             "**** %T %?"
             :empty-lines 1)
            ("c" "Lab Notebook with context"
             entry (file+datetree (concat org-directory "lab-notebook.org"))
             "**** %T %? \n\n %i \n %a"
             :empty-lines 1)
            ("t" "Lab Notebook todo"
             entry (file+datetree (concat org-directory "lab-notebook.org"))
             "**** %T TODO %?"
             :empty-lines 1)
            ("d" "Lab Notebook log completed"
             entry (file+datetree (concat org-directory "lab-notebook.org"))
             "**** %T DONE %c %?"
             :empty-lines 1)
            ))))

(defun bsag-org/pre-init-org-agenda ()
  (spacemacs|use-package-add-hook org-agenda
    :post-config
    (progn

      (defadvice org-switch-to-buffer-other-window (after make-full-agenda-window-frame activate)
        "Advice this function inside the agenda to be the sole window when in a popup frame"
        (when (equal "emacs-agenda" (frame-parameter nil 'name))
          (delete-other-windows)
          (hidden-mode-line-mode)))

      (defadvice org-agenda-quit (after make-full-window-frame activate)
        "Advise org-agenda to be the sole window when in a popup frame"
        (if (equal "emacs-agenda" (frame-parameter nil 'name))
            (delete-frame)))

      (setq org-agenda-custom-commands
            (append '(("l" tags "links"
                       ((org-agenda-overriding-header "Links that I have to read: ")
                        (org-agenda-skip-function
                         '(org-agenda-skip-entry-if 'todo '("reading" "read")))))
                      ("e" tags-todo "Events"))
                    org-agenda-custom-commands)))))


(defun bsag-org/post-init-org()
  "Initialize my package"
  (setq org-directory "~/Dropbox/org/")
  (setq org-agenda-files (quote ("~/Dropbox/org")))
  (setq org-default-notes-file (quote (concat org-directory "inbox.org")))
  (setq org-refile-targets (quote ((nil :maxlevel . 10)
                                   (org-agenda-files :maxlevel . 10))))

  (setq org-refile-use-outline-path t)
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-allow-creating-parent-nodes (quote confirm))
  (setq org-todo-keywords
        '((sequence "TODO" "STARTED" "|" "DONE")))
  (setq org-agenda-include-diary nil)
  (setq org-icalendar-timezone "Europe/London")
  (setq org-cycle-separator-lines 0)
  ;; Throw error if you try to delete hidden/folded text
  (setq org-catch-invisible-edits 'error)
  ;; export settings
  (setq org-html-head-include-default-scripts nil)
  (setq org-html-head-include-default-style nil)

  ;; ox-pandoc options
  (setq org-pandoc-options '((standalone . t)
                             (smart . t)
                             (parse-raw . t)
                             (bibliography . "~/Dropbox/Documents/bibtex/all-refs.bib")
                             ))
  (setq org-pandoc-options-for-beamer-pdf '((latex-engine . "xelatex")))
  (setq org-pandoc-options-for-latex-pdf '((latex-engine . "xelatex")
                                           (template . "~/.pandoc/templates/memoir2.latex" )))
  (setq org-pandoc-options-for-latex '((latex-engine . "xelatex")
                                       (template . "~/.pandoc/templates/memoir2.latex" )))
  (setq org-pandoc-options-for-html5 '((section-divs . t)))
  ;; org-babel stuff
  (setq org-startup-folded nil)
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-confirm-babel-evaluate nil)
  (setq org-ditaa-jar-path "/usr/local/bin/ditaa")

 ;; Org clock config
 ;; Resume clocking task when emacs is restarted
(org-clock-persistence-insinuate)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))
(setq org-clock-into-drawer t)
(setq org-clock-out-remove-zero-time-clocks t)
(setq org-clock-out-when-done t)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)
(setq org-clock-report-include-clocking-task t)
 )

;; Other random config: open lab-notebook with Spc ol
(defun bsag-org/open-lab-notebook ()
  "Open lab-notebook.org"
  (interactive)
  (find-file "~/Dropbox/org/lab-notebook.org"))

(evil-leader/set-key "ol" 'bsag-org/open-lab-notebook)

;; Open special url-handler links with macOS `open' command
;; This means you can open DevonThink and Papers links in org files
(defun org-pass-link-to-system (link)
  (if (string-match "^[a-zA-Z0-9\-]+:" link)
      (shell-command (concat "open " (shell-quote-argument link)))
    nil)
  )

(add-hook 'org-open-link-functions 'org-pass-link-to-system)

;;; packages.el ends here
