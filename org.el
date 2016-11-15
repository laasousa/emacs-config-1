;; TODO use org 8.3
(use-package org
  :load-path ("~/.emacs.d/private/org-mode")
  :defer t
  :commands (org-mode
             org-agenda-list
             org-capture
             org-store-link)

  :bind*
  (:map dired-mode-map
   ("C-c C-l" . org-store-link))

  :config

;;;* Use-package

;;;** ox-tufte
  (use-package ox-tufte :ensure t)

;;;** org-bullets
  (use-package org-bullets :ensure t
    :init
    (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

    :config
    (setq org-bullets-bullet-list  '("➡" "➠" "➟" "➝" "↪")))
;;;** org-indent
  (use-package org-indent
    :diminish "")

;;;** org-magit
  (use-package orgit :ensure t)


;;;** org-gfm
  (use-package ox-gfm :ensure t)

;;;* babel
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((R . t)
                                 (python . t)
                                 ;; (clojure . t)
                                 (shell . t)
                                 (emacs-lisp . t)
                                 (dot . t)
                                 (makefile . t)
                                 ;; (js . t)
                                 ))

  (defun org-babel-tangle-all-block-same-file ()
    "tangle all blocks which belong to the same file."
    (interactive)
    (let ((current-prefix-arg '(16)))
      (call-interactively #'org-babel-tangle)))

  (general-define-key
   :keymaps 'org-mode-map
    "s-e" 'org-babel-tangle-all-block-same-file
    "s-l" 'org-latex-export-to-latex
    )

;;;* sane default

  (require 'org-agenda)

  ;; inspired from  http://pages.sachachua.com/.emacs.d/Sacha.html#orgce6f46d
  (setq org-agenda-files
        (delq nil
              (mapcar (lambda (x) (and (file-exists-p x) x))
                      '("~/Org/TODO"))))
  (setq org-agenda-span 7)
  (setq org-agenda-tags-column -100) ; take advantage of the screen width
  (setq org-agenda-sticky nil)
  (setq org-agenda-inhibit-startup t)
  (setq org-agenda-use-tag-inheritance t)
  (setq org-agenda-show-log t)
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-skip-deadline-if-done t)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled)
  (setq org-agenda-time-grid
        '((daily today require-timed)
          "----------------"
          (800 1000 1200 1400 1600 1800)))
  ;; agenda start on mondays
  (setq org-agenda-start-on-weekday 1)

  (org-add-link-type "ebib" 'ebib-open-org-link)

  (setq
   org-modules '(org-crypt)
;;;*** gtd with org
   org-tags-column 80	     ; aligne les tags très loin sur la droite
   org-hide-block-startup t  ; cache les blocks par défaut.
   org-refile-targets '(("~/Org/TODO" :level . 2)
                        ("~/stage/TODO" :level . 1)
                        ("~/Org/someday.org" :level . 1)
                        ("~/Org/knowledge.org" :level . 2))
   org-default-notes-file "~/Org/notes.org"
   org-capture-templates
   '(("c" "collecte" entry (file+headline "~/Org/TODO" "Collecte") "** TODO %? %^G\n%U \n%i")
     ("s" "stage" entry (file+headline "~/stage/TODO" "capture")   "** TODO %? %^G\n%U \n%i")
     ("j" "journal" entry (file+datetree "~/Org/journal.org")      "* %?\nAjouté le %U\n %i\n  %a")
     ("n" "notes" entry (file+headline "~/Org/notes.org" "Notes")  "** %U  %^g\n%?")
     ("J" "lab-journal" entry (file+datetree "~/these/meta/nb/journal.org") "* %(hour-minute-timestamp) %?\n" )))

  (defun hour-minute-timestamp ()
    (format-time-string "%H:%M" (current-time)))

  (add-to-list 'org-modules 'org-mac-iCal)
  (setq org-agenda-include-diary t)
;;;*** src block and babel
  (setq
   org-src-preserve-indentation t
;;;*** footnotes
   org-footnote-auto-adjust t
   org-footnote-define-inline nil
   org-footnote-fill-after-inline-note-extraction t
   org-footnote-section nil
;;;*** export
   org-export-with-todo-keywords nil
   org-export-default-language "fr"
   org-export-backends '(ascii html icalendar latex md koma-letter)
;;;*** latex
   ;; moyen d'export latex
   org-latex-pdf-process
   (list "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
         "bibtex %f"
         "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
         "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f")
   org-latex-image-default-width "1\\linewidth"
   org-highlight-latex-and-related '(latex entities) ; colore les macro LaTeX
   ;; tufte-handout class by default.
   org-latex-default-class "tufte-handout"
   ;; default package list with sensible options
   org-latex-default-packages-alist
   (quote (("AUTO" "inputenc" t)
           ("T1" "fontenc" t)
           ("" "graphicx" t)
           ("" "longtable" t)
           ("" "float" nil)
           ("" "hyperref" nil)
           ("" "wrapfig" nil)
           ("" "rotating" nil)
           ("normalem" "ulem" t)
           ("" "amsmath" t)
           ("" "textcomp" t)
           ("" "marvosym" t)
           ("" "wasysym" t)
           ("" "amssymb" t)
           ("scaled=0.9" "zi4" t)
           ("x11names, dvipsnames" "xcolor" t)
           ("protrusion=true, expansion=alltext, tracking=true, kerning=true" "microtype" t)
           ("" "siunitx" t)
           ("french" "babel" t)))
   ;; extensions that listings packages in latex recognize.
   org-latex-listings-langs '((emacs-lisp "Lisp")
                              (lisp "Lisp")
                              (clojure "Lisp")
                              (c "C")
                              (cc "C++")
                              (fortran "fortran")
                              (perl "Perl")
                              (cperl "Perl")
                              (python "Python")
                              (ruby "Ruby")
                              (html "HTML")
                              (xml "XML")
                              (tex "TeX")
                              (latex "[LaTeX]TeX")
                              (shell-script "bash")
                              (gnuplot "Gnuplot")
                              (ocaml "Caml")
                              (caml "Caml")
                              (sql "SQL")
                              (sqlite "sql")
                              (makefile "make")
                              (R "r"))
   ;; files extensions that org considers as latex byproducts.
   org-latex-logfiles-extensions '("aux" "bcf" "blg" "fdb_latexmk" "fls" "figlist" "idx"
                                   "log" "nav" "out" "ptc" "run.xml" "snm" "toc" "vrb" "xdv" "bbl")
   org-latex-minted-langs '((emacs-lisp "common-lisp")
                            (cc "c++")
                            (cperl "perl")
                            (shell-script "bash")
                            (caml "ocaml")
                            (python "python")
                            (ess "R"))
   org-latex-remove-logfiles t
   org-src-fontify-natively t
   org-latex-table-caption-above nil
   org-latex-tables-booktabs t
   org-startup-with-inline-images nil
   org-startup-indented t
   )

  (with-eval-after-load 'ox-latex
    (append-to-list
     'org-latex-classes
     '(("tufte-book"
        "\\documentclass[a4paper, sfsidenotes, justified, notitlepage]{tufte-book}
       \\input{/Users/samuelbarreto/.templates/tufte-book.tex}"
        ("\\part{%s}" . "\\part*{%s}")
        ("\\chapter{%s}" . "\\chapter*{%s}")
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}"))
       ("tufte-handout"
        "\\documentclass[a4paper, justified]{tufte-handout}
       \\input{/Users/samuelbarreto/.templates/tufte-handout.tex}"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}"))
       ("rapport" "\\documentclass[11pt, oneside]{scrartcl}"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")
        ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))
       ("beamer" "\\documentclass[presentation]{beamer}"
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")
        ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))
       ("journal"
        "\\documentclass[9pt, oneside, twocolumn]{scrartcl}
       \\input{/Users/samuelbarreto/.templates/journal.tex}"
        ("\\part{%s}" . "\\section*{%s}")
        ("\\section{%s}" . "\\section*{%s}")
        ("\\subsection{%s}" . "\\subsection*{%s}")
        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
        ("\\paragraph{%s}" . "\\paragraph*{%s}")))))

  (defun org-insert-heading-with-date-after-current ()
    "Insert a new heading with current date same level as current,
     after current subtree."
    (interactive)
    (org-back-to-heading)
    (org-insert-heading)
    (insert-timestamp)
    (org-move-subtree-down)
    (end-of-line 1))

  ;; FIXME. does not work.
  (defun orgpy-italicize (arg)
    (interactive "p")
    (cond ((looking-back "[a-zA-z]\\>")
           (insert "/")
           (save-excursion
             (backward-word)
             (insert "/")))
          (t
           (self-insert-command arg))))

;;;* Keybindings
  (general-define-key
   :keymaps 'org-mode-map
    "/" 'orgpy-italicize
    (general-chord ",c") 'org-shiftcontrolleft
    (general-chord ",t") 'org-shiftcontroldown
    (general-chord ",s") 'org-shiftcontrolup
    (general-chord ",r") 'org-shiftcontrolright
    (general-chord ";C") 'org-metaleft
    (general-chord ";T") 'org-metadown
    (general-chord ";S") 'org-metaup
    (general-chord ";R") 'org-metaright))

;;;* Keybindings


;; TODO j'ai eu l'idée d'un snippet qui permettrait de splitter les
;; chunks en deux. au moment où je dois choisir le file to tangle in,
;; la fonction parserai le script pour construire une liste de tous
;; les :tangle file, de façon à pouvoir choisir le fichier dans lequel
;; je veux que ça aille. par défault, il devrait choisir le file dans
;; le chunk juste au dessus.
