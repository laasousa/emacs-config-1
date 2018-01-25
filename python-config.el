;;; * Licence

;; Copyright (C) 2017 Samuel Barreto <samuel.barreto8@gmail.com>
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;

;;; * Code

(use-package elpy
  :ensure t
  :config
  (elpy-enable))

;; (use-package anaconda-mode
;;   :quelpa (anaconda-mode :fetcher github :repo "proofit404/anaconda-mode")
;;   :config

;;   (add-hook 'python-mode-hook 'anaconda-mode)
;;   (add-hook 'python-mode-hook 'anaconda-eldoc-mode)

;;   (bind-keys :map python-mode-map
;;     ("C-M-i" . anaconda-mode-complete)
;;     ("M-." . anaconda-mode-find-definitions)
;;     ("M-?" . anaconda-mode-show-doc)
;;     ("M-," . anaconda-mode-go-back)
;;     ("M-*" . anaconda-mode-find-assignments)
;;     ("M-SPC" . hydra-python/body))

;;   (use-package company-anaconda
;;     :quelpa (company-anaconda :fetcher github :repo "proofit404/company-anaconda")
;;     :config
;;     (add-to-list 'company-backends '(company-anaconda :with company-capf))))

;; (use-package py-yapf
;;   :quelpa (py-yapf :fetcher github :repo "paetzke/py-yapf.el")
;;   :commands py-yapf-buffer)

;; (use-package pyenv-mode :ensure t
;;   :commands pyenv-mode
;;   :init (add-hook 'python-mode-hook 'pyenv-mode))

;; (use-package pyvenv :ensure t
;;   :config
;;   (setenv "WORKON_HOME" "/Users/samuelbarreto/")
;;   (pyvenv-workon "anaconda"))

;; (use-package lpy
;;   :disabled t
;;   :quelpa (lpy :fetcher github :repo "abo-abo/lpy")
;;   :init
;;   (use-package function-args
;;     :quelpa (function-args :fetcher github :repo "abo-abo/function-args"))
;;   (use-package soap
;;     :quelpa (soap :fetcher github :repo "abo-abo/soap"))
;;   :config
;;   (add-hook 'python-mode-hook (lambda () (lpy-mode 1) (lispy-mode 1))))

;; (use-package py-isort :ensure t
;;   :commands (py-isort-buffer
;;              py-isort-region))

;; ---------- defaults ----------------------------------------------------
(setq-default indent-tabs-mode nil)
(setq-default python-indent-offset 4)
(if (executable-find "ipython")
    (setq python-shell-interpreter "ipython"
          python-shell-interpreter-args "--simple-prompt -i --pprint")
  (setq python-shell-interpreter "python"))

;; ---------- Function definitions ----------------------------------------
(defun python-shell-send-line (&optional vis)
  "send the current line to the inferior python process"
  (interactive "P")
  (save-excursion
    (end-of-line)
    (let ((end (point)))
      (beginning-of-line)
      (python-shell-send-region (point) end vis "eval line"))))

(defun current-line-empty-p ()
  (save-excursion
    (beginning-of-line)
    (looking-at "[[:space:]]*$")))

(defun python-shell-send-block (&optional vis)
  "send the current block of text to inferior python process.
If not in a block, send the upper block.
"
  (interactive "P")
  (save-excursion
    (unless (current-line-empty-p) (python-nav-end-of-block))
    (let ((end (point)))
      (python-nav-beginning-of-block)
      (python-shell-send-region (point) end vis "eval line"))))

(defun python-shell-send-block-switch ()
  (interactive)
  (python-shell-send-block)
  (python-shell-switch-to-shell))

(defun python-shell-send-line-switch ()
  (interactive)
  (python-shell-send-line)
  (python-shell-switch-to-shell))

;; from https://github.com/syl20bnr/spacemacs/blob/master/layers/%2Blang/python/packages.el
(defun python-shell-send-buffer-switch ()
  "Send buffer content to shell and switch to it in insert mode"
  (interactive)
  (python-shell-send-buffer)
  (python-shell-switch-to-shell))

(defun python-shell-send-defun-switch ()
  "send function content to shell and switch to it in insert mode"
  (interactive)
  (python-shell-send-defun nil)
  (python-shell-switch-to-shell))

(defun python-shell-send-region-switch (start end)
  "Send region content to shell and switch to it in insert mode."
  (interactive "r")
  (python-shell-send-region start end)
  (python-shell-switch-to-shell))



;; ---------- Keybindings -------------------------------------------------
(general-define-key
 :keymaps 'python-mode-map
  "s-e" 'python-shell-send-defun
  "C-<return>" 'python-shell-send-line
  "«" 'python-indent-shift-left
  "»" 'python-indent-shift-right
  (general-chord ",l") 'python-shell-send-line
  (general-chord ";L") 'python-shell-send-line-switch
  (general-chord ",b") 'python-shell-send-block
  (general-chord ";B") 'python-shell-send-block-switch
  (general-chord ",t") 'python-shell-send-defun
  (general-chord ";T") 'python-shell-send-defun-switch
  (general-chord ",r") 'python-shell-send-region
  (general-chord ";R") 'python-shell-send-region-switch
  (general-chord "xq") 'hydra-python/body)

(defhydra hydra-python (:hint nil :color teal)
  "
^Send^         ^  ^                ^Navigation^   ^Code^         ^Actions^
^----^         ^  ^                ^----------^   ^----^         ^-------^
_sl_: line     _st_: function      _._: def       _>_: indent    _y_: yapf
_SL_: line →   _ST_: function →    _*_: assign    _<_: outdent
_sr_: region   _sb_: buffer        _,_: back
_SR_: region → _SB_: buffer →      ^ ^
"
  ;; shell send
  ("sl" python-shell-send-line)
  ("SL" python-shell-send-line-switch)
  ("sr" python-shell-send-region)
  ("SR" python-shell-send-region-switch)
  ("st" python-shell-send-defun)
  ("ST" python-shell-send-defun-switch)
  ("sb" python-shell-send-buffer)
  ("SB" python-shell-send-buffer-switch)
  ;; code nav
  ("." anaconda-mode-find-definitions)
  ("," anaconda-mode-find-assignments :color red)
  ("*" anaconda-mode-go-back :color red)
  ;; code editing
  ("<" python-indent-shift-left)
  (">" python-indent-shift-right)
  ;; test
  ;; TODO python test via nose
  ;; actions
  ("y" py-yapf-buffer)
  ("q" nil "quit" :color blue))
