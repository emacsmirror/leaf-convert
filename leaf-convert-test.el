;;; leaf-convert-test.el --- Test definitions for leaf-convert  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>
;; URL: https://github.com/conao3/leaf-convert.el

;; Copyright (C) 2020  Naoya Yamashita

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Test definitions for `leaf-convert'.


;;; Code:

(require 'cort)
(require 'leaf-convert)
(require 'use-package)
(require 'use-package-chords)


;;; test definitions

(cort-deftest-generate :equal leaf-convert/convert-contents
  '(
    ;; leaf-covnert from nil generates empty leaf
    ((leaf-convert-from-contents
      nil)
     '(leaf leaf-convert))

    ;; leaf-convert--name also accepts symbol
    ((leaf-convert-from-contents
      '((leaf-convert--name . some-package)))
     '(leaf some-package))

    ;; leaf-convert could handle symbol t
    ((leaf-convert-from-contents
      '((disabled . (t))))
     '(leaf leaf-convert
        :disabled t))

    ;; leaf-convert could handle symbol nil
    ((leaf-convert-from-contents
      '((disabled . (nil))))
     '(leaf leaf-convert
        :disabled nil))

    ;; leaf-convert splice values
    ((leaf-convert-from-contents
      '((config . ((leaf-keywords-init)))))
     '(leaf leaf-convert
        :config
        (leaf-keywords-init)))

    ;; leaf-convert splice values (in multi values)
    ((leaf-convert-from-contents
      '((config . ((leaf-keywords-init)
                   (leaf-keywords-teardown)))))
     '(leaf leaf-convert
        :config
        (leaf-keywords-teardown)
        (leaf-keywords-init)))))

(cort-deftest-generate :equal leaf-convert/use-package--getting-started
  '(
    ;; simplest use-package
    ((leaf-convert
      (use-package foo))
     '(leaf foo
        :require t))

    ;; :init keyword
    ((leaf-convert
      (use-package foo
        :init
        (setq foo-variable t)))
     '(leaf foo
        :pre-setq ((foo-variable . t))
        :require t))

    ;; :config keyword
    ((leaf-convert
      (use-package foo
        :init
        (setq foo-variable t)
        :config
        (foo-mode 1)))
     '(leaf foo
        :pre-setq ((foo-variable . t))
        :require t
        :config (foo-mode 1)))

    ;; :comands keyword
    ((leaf-convert    ; TODO
      (use-package color-moccur
        :commands isearch-moccur
        :config
        (use-package moccur-edit)))
     '(leaf color-moccur
        :commands isearch-moccur
        :config
        (with-eval-after-load 'color-moccur
          (use-package moccur-edit))))

    ;; init, :config, :bind
    ((leaf-convert
      (use-package color-moccur
        :commands (isearch-moccur isearch-all)
        :bind (("M-s O" . moccur)
               :map isearch-mode-map
               ("M-o" . isearch-moccur)
               ("M-O" . isearch-moccur-all))
        :init
        (setq isearch-lazy-highlight t)
        :config
        (use-package moccur-edit)))
     '(leaf color-moccur
        :commands isearch-all
        :bind (("M-s O" . moccur)
               (isearch-mode-map
                ("M-o" . isearch-moccur)
                ("M-O" . isearch-moccur-all)))
        :setq ((isearch-lazy-highlight . t))
        :config
        (with-eval-after-load 'color-moccur
          (use-package moccur-edit))))))

(cort-deftest-generate :equal leaf-convert/use-package--keybinding
  '(
    ((leaf-convert
      (use-package ace-jump-mode
        :bind ("C-." . ace-jump-mode)))
     '(leaf ace-jump-mode
        :bind (("C-." . ace-jump-mode))))

    ((leaf-convert
      (use-package hi-lock
        :bind (("M-o l" . highlight-lines-matching-regexp)
               ("M-o r" . highlight-regexp)
               ("M-o w" . highlight-phrase))))
     '(leaf hi-lock
        :bind (("M-o l" . highlight-lines-matching-regexp)
               ("M-o r" . highlight-regexp)
               ("M-o w" . highlight-phrase))))

    ((leaf-convert
      (use-package helm
        :bind (("M-x" . helm-M-x)
               ("M-<f5>" . helm-find-files)
               ([f10] . helm-buffers-list)
               ([S-f10] . helm-recentf))))
     '(leaf helm
        :bind (("M-x" . helm-M-x)
               ("M-<f5>" . helm-find-files)
               ([f10] . helm-buffers-list)
               ([S-f10] . helm-recentf))))

    ((leaf-convert
      (use-package unfill
        :bind ([remap fill-paragraph] . unfill-toggle)))
     '(leaf unfill
        :bind (([remap fill-paragraph] . unfill-toggle))))

    ((leaf-convert
      (use-package helm
        :bind (:map helm-command-map
                    ("C-c h" . helm-execute-persistent-action))))
     '(leaf helm
        :bind ((helm-command-map
                ("C-c h" . helm-execute-persistent-action)))))

    ((leaf-convert
      (use-package term
        :bind (("C-c t" . term)
               :map term-mode-map
               ("M-p" . term-send-up)
               ("M-n" . term-send-down)
               :map term-raw-map
               ("M-o" . other-window)
               ("M-p" . term-send-up)
               ("M-n" . term-send-down))))
     '(leaf term
        :bind (("C-c t" . term)
               (term-mode-map
                ("M-p" . term-send-up)
                ("M-n" . term-send-down))
               (term-raw-map
                ("M-o" . other-window)
                ("M-p" . term-send-up)
                ("M-n" . term-send-down)))))))

(cort-deftest-generate :equal leaf-convert/use-package--modes-and-interpreters
  '(
    ((leaf-convert
      (use-package ruby-mode
        :mode "\\.rb\\'"
        :interpreter "ruby"))
     '(leaf ruby-mode
        :mode ("\\.rb\\'")
        :interpreter ("ruby")))

    ((leaf-convert
      (use-package python
        :mode ("\\.py\\'" . python-mode)
        :interpreter ("python" . python-mode)))
     '(leaf python
        :mode ("\\.py\\'")
        :interpreter ("python")))))

(cort-deftest-generate :equal leaf-convert/use-package--magic-handlers
  '(
    ((leaf-convert
      (use-package pdf-tools
        :magic ("%PDF" . pdf-view-mode)
        :config
        (pdf-tools-install :no-query)))
     '(leaf pdf-tools
        :magic (("%PDF" . pdf-view-mode))
        :config
        (with-eval-after-load 'pdf-tools
          (pdf-tools-install :no-query))))

    ((leaf-convert
      (use-package pdf-tools
        :magic-fallback ("%PDF" . pdf-view-mode)
        :config
        (pdf-tools-install :no-query)))
     '(leaf pdf-tools
        :magic-fallback (("%PDF" . pdf-view-mode))
        :config
        (with-eval-after-load 'pdf-tools
          (pdf-tools-install :no-query))))))

(cort-deftest-generate :equal leaf-convert/use-package--hooks
  '(((leaf-convert
      (use-package ace-jump-mode
        :hook prog-mode))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook)))

    ((leaf-convert
      (use-package ace-jump-mode
        :hook (prog-mode . ace-jump-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook)))

    ((leaf-convert
      (use-package ace-jump-mode
        :commands ace-jump-mode
        :init
        (add-hook 'prog-mode-hook #'ace-jump-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook)))

    ((leaf-convert
      (use-package ace-jump-mode
        :hook (prog-mode text-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook text-mode-hook)))

    ((leaf-convert
      (use-package ace-jump-mode
        :hook ((prog-mode text-mode) . ace-jump-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook text-mode-hook)))

    ((leaf-convert
      (use-package ace-jump-mode
        :hook ((prog-mode . ace-jump-mode)
               (text-mode . ace-jump-mode))))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook text-mode-hook)))

    ((leaf-convert
      (use-package ace-jump-mode
        :commands ace-jump-mode
        :init
        (add-hook 'prog-mode-hook #'ace-jump-mode)
        (add-hook 'text-mode-hook #'ace-jump-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook text-mode-hook)))))

(cort-deftest-generate :equal leaf-convert/use-package--package-customization
  '(
    ((leaf-convert
      (use-package comint
        :custom
        (comint-prompt-regexp "^")
        (comint-buffer-maximum-size 20000 "Increase comint buffer size.")
        (comint-prompt-read-only t "Make the prompt read only.")))
     ;; '(leaf comint
     ;;    :custom ((comint-prompt-regexp . "^"))
     ;;    :custom* ((comint-buffer-maximum-size 20000 "Increase comint buffer size.")
     ;;              (comint-prompt-read-only t "Make the prompt read only."))
     ;;    :require t)
     '(leaf comint
        :custom ((comint-prompt-regexp . "^")
                 (comint-buffer-maximum-size . 20000)
                 (comint-prompt-read-only . t))
        :require t))

    ((leaf-convert
      (use-package eruby-mode
        :custom-face
        (eruby-standard-face ((t (:slant italic))))))
     '(leaf eruby-mode
        :custom-face ((eruby-standard-face . '((t (:slant italic)))))
        :require t))

    ((leaf-convert
      (use-package eruby-mode
        :custom-face
        (eruby-standard-face ((t (,(or :slant) italic))))
        (org-level-1 ((t (:bold t :foreground "dodger blue" :height 1.0))))
        (org-level-2 ((t (:bold t :foreground "#edd400" :height 1.0))))))
     '(leaf eruby-mode
        :custom-face
        ((org-level-1 . '((t (:bold t :foreground "dodger blue" :height 1.0))))
         (org-level-2 . '((t (:bold t :foreground "#edd400" :height 1.0)))))
        :init (custom-set-faces
               (backquote (eruby-standard-face ((t ((\, (or :slant)) italic))))))
        :require t))))

(cort-deftest-generate :equal leaf-convert/use-package--condition-loading
  '(
    ((leaf-convert
      (use-package edit-server
        :if window-system
        :init
        (add-hook 'after-init-hook 'server-start t)
        (add-hook 'after-init-hook 'edit-server-start t)))
     '(leaf edit-server
        :when window-system
        :hook ((after-init-hook . server-start)
               (after-init-hook . edit-server-start))
        :require t))

    ((leaf-convert
      (use-package exec-path-from-shell
        :if (memq window-system '(mac ns))
        :ensure t
        :config
        (exec-path-from-shell-initialize)))
     '(leaf exec-path-from-shell
        :ensure t
        :config
        (when (memq window-system '(mac ns))
          (require 'exec-path-from-shell nil nil)
          (exec-path-from-shell-initialize)
          t)))

    ((leaf-convert
      (use-package ess-site
        :disabled
        :commands R))
     '(leaf ess-site))

    ((leaf-convert
      (use-package abbrev
        :requires foo))
     '(leaf abbrev
        :when (featurep 'foo)
        :require t))

    ((leaf-convert
      (use-package abbrev
        :requires (foo bar baz)))
     '(leaf abbrev
        :unless (member nil (mapcar (function featurep) '(foo bar baz)))
        :require t))))

(cort-deftest-generate :equal leaf-convert/use-package--byte-compiling-your-emacs
  '(
    ((leaf-convert
      (use-package texinfo
        :defines texinfo-section-list
        :commands texinfo-mode
        :init
        (add-to-list 'auto-mode-alist '("\\.texi$" . texinfo-mode))))
     '(leaf texinfo
        :defvar texinfo-section-list
        :mode ("\\.texi$")))

    ((leaf-convert
      (use-package ruby-mode
        :mode "\\.rb\\'"
        :interpreter "ruby"
        :functions inf-ruby-keys
        :config
        (defun my-ruby-mode-hook ()
          (require 'inf-ruby)
          (inf-ruby-keys))

        (add-hook 'ruby-mode-hook 'my-ruby-mode-hook)))
     '(leaf ruby-mode
        :mode ("\\.rb\\'")
        :interpreter ("ruby")
        :config
        (with-eval-after-load 'ruby-mode
          (defun my-ruby-mode-hook ()
            (require 'inf-ruby)
            (inf-ruby-keys))

          (add-hook 'ruby-mode-hook 'my-ruby-mode-hook))))

    ((leaf-convert
      (use-package foo
        :no-require t
        :config
        (message "This is evaluated when `foo' is loaded")))
     '(leaf foo
        :config
        (message "This is evaluated when `foo' is loaded")))))

(cort-deftest-generate :equal leaf-convert/use-package--extending-the-load-path
  '(
    ((leaf-convert
      (use-package ess-site
        :load-path "site-lisp/ess/lisp/"
        :commands R))
     '(leaf ess-site
        :load-path* "site-lisp/ess/lisp/"
        :commands R))))

;; unsupported for now...
;; (cort-deftest-generate :equal leaf-convert/use-package--catching-errors-during-use-package-expansion
;;   '())

(cort-deftest-generate :equal leaf-convert/use-package--diminishing-and-delighting-minor-modes
  '(((leaf-convert
      (use-package abbrev
        :diminish abbrev-mode
        :config
        (if (file-exists-p abbrev-file-name)
            (quietly-read-abbrev-file))))
     '(leaf abbrev
        :require t
        :diminish abbrev-mode
        :config
        (when (file-exists-p abbrev-file-name)
          (quietly-read-abbrev-file))))

    ((leaf-convert
      (use-package rainbow-mode
        :delight))
     '(leaf rainbow-mode
        :require t
        :delight (rainbow-mode nil rainbow-mode)))

    ((leaf-convert
      (use-package autorevert
        :delight auto-revert-mode))
     '(leaf autorevert
        :require t
        :delight (auto-revert-mode nil autorevert)))

    ((leaf-convert
      (use-package projectile
        :delight '(:eval (concat " " (projectile-project-name)))))
     '(leaf projectile
        :require t
        :delight (projectile-mode '(:eval (concat " " (projectile-project-name))) projectile)))

    ((leaf-convert
      (use-package emacs
        :delight
        (auto-fill-function " AF")
        (visual-line-mode)))
     '(leaf emacs
        :require t
        :delight
        (auto-fill-function " AF" emacs)
        (visual-line-mode nil emacs)))))

(cort-deftest-generate :equal leaf-convert/use-package--package-installation
  '(((leaf-convert
      (use-package magit
        :ensure t))
     '(leaf magit
        :ensure t
        :require t))

    ((leaf-convert
      (use-package tex
        :ensure auctex))
     '(leaf tex
        :ensure auctex
        :require t))

    ((leaf-convert
      (use-package auto-package-update
        :config
        (setq auto-package-update-delete-old-versions t)
        (setq auto-package-update-hide-results t)
        (auto-package-update-maybe)))
     '(leaf auto-package-update
        :require t
        :setq ((auto-package-update-delete-old-versions . t)
               (auto-package-update-hide-results . t))
        :config (auto-package-update-maybe)))))

(cort-deftest-generate :equal leaf-convert/use-package--chords
  '(((leaf-convert
      (use-package use-package-chords
        :ensure t
        :config (key-chord-mode 1)))
     '(leaf use-package-chords
        :ensure t
        :require t
        :config (key-chord-mode 1)))

    ((leaf-convert
      (use-package ace-jump-mode
        :chords (("jj" . ace-jump-char-mode)
                 ("jk" . ace-jump-word-mode)
                 ("jl" . ace-jump-line-mode))))
     '(leaf ace-jump-mode
        :commands ace-jump-char-mode ace-jump-word-mode ace-jump-line-mode
        :chord (("jj" . ace-jump-char-mode)
                ("jk" . ace-jump-word-mode)
                ("jl" . ace-jump-line-mode))))))

(cort-deftest-generate :equal leaf-convert/progn
  '(
    ;; accept progn
    ((leaf-convert
      (progn
        (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf"))
        (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf-keywords"))))
     '(leaf leaf-convert
        :load-path*
        "site-lisp/leaf"
        "site-lisp/leaf-keywords"))

    ;; also accept prog1 and pick up 2th argument as leaf--name if symbol
    ((leaf-convert
      (prog1 'leaf
        (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf"))
        (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf-keywords"))))
     '(leaf leaf
        :load-path*
        "site-lisp/leaf"
        "site-lisp/leaf-keywords"))

    ;; also accept prog1 and pick up 2th argument as leaf--name if string
    ((leaf-convert
      (prog1 "leaf"
        (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf"))
        (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf-keywords"))))
     '(leaf leaf
        :load-path*
        "site-lisp/leaf"
        "site-lisp/leaf-keywords"))))

(cort-deftest-generate :equal leaf-convert/load-path
  '(
    ;; add-to-list load-path convert to :load-path keyword
    ((leaf-convert
      (add-to-list 'load-path "~/.emacs.d/local/26.3/site-lisp"))
     '(leaf leaf-convert
        :load-path* "local/26.3/site-lisp"))

    ;; add-to-list load-path using locate-user-emacs-file convert to :load-path*
    ((leaf-convert
      (add-to-list 'load-path (locate-user-emacs-file "site-lisp")))
     '(leaf leaf-convert
        :load-path* "site-lisp"))

    ;; add-to-list load-path using concat user-emacs-directory convert to :load-path*
    ((leaf-convert
      (add-to-list 'load-path (concat user-emacs-directory "site-lisp")))
     '(leaf leaf-convert
        :load-path* "site-lisp"))

    ;; could convert multi add-to-list sexps
    ((leaf-convert
      (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf"))
      (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf-keywords"))
      (add-to-list 'load-path (locate-user-emacs-file "site-lisp/leaf-convert")))
     '(leaf leaf-convert
        :load-path*
        "site-lisp/leaf"
        "site-lisp/leaf-keywords"
        "site-lisp/leaf-convert"))))

(cort-deftest-generate :equal leaf-convert/config
  '(
    ;; unknown sexp convert to :config
    ((leaf-convert
      (leaf-keywords-init))
     '(leaf leaf-convert
        :config
        (leaf-keywords-init)))))

(cort-deftest-generate :equal leaf-convert/defun
  '(
    ;; declare-function convert to :defun
    ((leaf-convert
      (declare-function leaf "leaf"))
     '(leaf leaf-convert
        :defun (leaf . leaf)))))

(cort-deftest-generate :equal leaf-convert/defvar
  '(
    ;; empty defvar convert to :defvar
    ((leaf-convert
      (defvar leaf-keywords))
     '(leaf leaf-convert
        :defvar leaf-keywords))

    ;; define variable and initialize convert to :setq
    ((leaf-convert
      (defvar leaf-keywords-optional '(:doc :url :tag)))
     '(leaf leaf-convert
        :setq ((leaf-keywords-optional . '(:doc :url :tag)))))))

(cort-deftest-generate :equal leaf-convert/after
  '(
    ;; eval-after-load convert to :after
    ((leaf-convert
      (eval-after-load 'leaf
        '(progn
           (leaf-browser-init))))
     '(leaf leaf
        :after t
        :config
        (leaf-browser-init)))

    ;; with-eval-after-load also convert to :after
    ((leaf-convert
      (with-eval-after-load 'leaf
        (leaf-browser-init)))
     '(leaf leaf
        :after t
        :config
        (leaf-browser-init)))

    ;; eval-after-load chain convert to :after symbols
    ((leaf-convert
      (eval-after-load 'orglyth
        '(eval-after-load 'org
           '(eval-after-load 'leaf
              '(progn
                 (leaf-browser-init))))))
     '(leaf orglyth
        :after t org leaf
        :config
        (leaf-browser-init)))

    ;; if the eval-after-load chain breaks, it will not be converted to the :after keyword
    ((leaf-convert
      (eval-after-load 'orglyth
        '(progn
           (orglyth-setup)
           (eval-after-load 'org
             '(eval-after-load 'leaf
                '(progn
                   (leaf-browser-init)))))))
     '(leaf orglyth
        :after t
        :config
        (orglyth-setup)
        (with-eval-after-load 'org
          (eval-after-load 'leaf
            '(progn
               (leaf-browser-init))))))))

(cort-deftest-generate :equal leaf-convert/setq
  '(
    ;; empty defvar convert to :defvar
    ((leaf-convert
      (defvar leaf-keywords))
     '(leaf leaf-convert
        :defvar leaf-keywords))

    ;; define variable and initialize convert to :setq
    ((leaf-convert
      (defvar leaf-keywords-optional '(:doc :url :tag)))
     '(leaf leaf-convert
        :setq ((leaf-keywords-optional . '(:doc :url :tag)))))

    ;; setq sexp convert to :setq keyword
    ((leaf-convert
      (prog1 'alloc
        (setq gc-cons-threshold 536870912)
        (setq garbage-collection-messages t)))
     '(leaf alloc
        :setq ((gc-cons-threshold . 536870912)
               (garbage-collection-messages . t))))

    ;; right value is non-atom, convert to :config
    ((leaf-convert
      (prog1 'alloc
        (setq gc-cons-threshold (* 512 1024 1024))
        (setq garbage-collection-messages t)))
     '(leaf alloc
        :setq ((garbage-collection-messages . t))
        :config (setq gc-cons-threshold (* 512 1024 1024))))

    ;; support multiple setq
    ((leaf-convert
      (prog1 'alloc
        (setq gc-cons-threshold 536870912
              garbage-collection-messages t)))
     '(leaf alloc
        :setq ((gc-cons-threshold . 536870912)
               (garbage-collection-messages . t))))))

(cort-deftest-generate :equal leaf-convert/setq-default
  '(
    ;; setq-default sexp convert to :setq-default keyword
    ((leaf-convert
      (prog1 'alloc
        (setq-default gc-cons-threshold 536870912)
        (setq-default garbage-collection-messages t)))
     '(leaf alloc
        :setq-default ((gc-cons-threshold . 536870912)
                       (garbage-collection-messages . t))))

    ;; right value is non-atom, convert to :config
    ((leaf-convert
      (prog1 'alloc
        (setq-default gc-cons-threshold (* 512 1024 1024))
        (setq-default garbage-collection-messages t)))
     '(leaf alloc
        :setq-default ((garbage-collection-messages . t))
        :config (setq-default gc-cons-threshold (* 512 1024 1024))))))

(cort-deftest-generate :equal leaf-convert/diminish
  '(
    ;; hide minor-mode lighter
    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode)))
     '(leaf rainbow-mode
        :diminish rainbow-mode))

    ;; right value is string, converted cons-cell
    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode "Rbow")))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . "Rbow")))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode 'rainbow-mode-lighter)))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . 'rainbow-mode-lighter)))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode '(" " "R-" "bow"))))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . '(" " "R-" "bow"))))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode '((" " "R-") "/" "bow"))))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . '((" " "R-") "/" "bow"))))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode '(:eval (format " Rbow/%s" (+ 2 3))))))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . '(:eval (format " Rbow/%s" (+ 2 3))))))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode '(:propertize " Rbow" face '(:foreground "green")))))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . '(:propertize " Rbow" face '(:foreground "green")))))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode '(rainbow-mode-mode-linep " Rbow/t" " Rbow/nil"))))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . '(rainbow-mode-mode-linep " Rbow/t" " Rbow/nil"))))

    ((leaf-convert
      (prog1 'rainbow-mode
        (diminish 'rainbow-mode '(2 " Rbow" "/" "s"))))
     '(leaf rainbow-mode
        :diminish (rainbow-mode . '(2 " Rbow" "/" "s"))))))

(cort-deftest-generate :equal leaf-convert/ensure
  '(
    ;; package-install will convert :ensure keyword
    ((leaf-convert
      (prog1 'leaf
        (package-install 'leaf)))
     '(leaf leaf
        :ensure t))

    ;; could convert use-package :ensure t
    ((leaf-convert
      (use-package leaf
        :ensure t))
     '(leaf leaf
        :ensure t
        :require t))

    ;; could convert use-package :ensure argument
    ((leaf-convert
      (use-package tex
        :ensure auctex))
     '(leaf tex
        :ensure auctex
        :require t))

    ;; could convert use-package :ensure arguments
    ((leaf-convert
      (use-package tex
        :ensure t
        :ensure auctex))
     '(leaf tex
        :ensure t auctex
        :require t))))

(cort-deftest-generate :equal leaf-convert/require
  '(
    ;; require will convert :require keyword
    ((leaf-convert
      (prog1 'leaf
        (require 'leaf)))
     '(leaf leaf
        :require t))

    ;; require with no-error will convert :require keyword
    ((leaf-convert
      (prog1 'leaf
        (require 'leaf nil t)))
     '(leaf leaf
        :require t))

    ;; empty use-package will convert :require keyword
    ((leaf-convert
      (use-package tex))
     '(leaf tex
        :require t))

    ;; if second argument is non-nil, cannot convert :require keyword
    ((leaf-convert
      (prog1 'leaf
        (require 'leaf "~/.emacs.d/site-lisp/leaf.el/leaf.el" t)))
     '(leaf leaf
        :config
        (require 'leaf "~/.emacs.d/site-lisp/leaf.el/leaf.el" t)))

    ;; Sexps that are executed before require are placed in the appropriate place
    ((leaf-convert
      (use-package foo
        :init
        (setq foo-variable t)
        (foo-init)
        :config
        (foo-enable)))
     '(leaf foo
        :pre-setq ((foo-variable . t))
        :init (foo-init)
        :require t
        :config (foo-enable)))))

(cort-deftest-generate :equal leaf-convert/commands
  '(
    ;; autoload will convert :commands keyword
    ((leaf-convert
      (autoload #'moccur "color-moccur"))
     '(leaf leaf-convert
        :commands moccur))

    ;; autoload second argumemnt may be symbol
    ((leaf-convert
      (autoload #'moccur 'color-moccur))
     '(leaf leaf-convert
        :commands moccur))

    ;; autoload third, fourth argument are ignored
    ((leaf-convert
      (autoload #'moccur 'color-moccur nil t))
     '(leaf leaf-convert
        :commands moccur))

    ;; unless-autoload pattern also converted :commands
    ((leaf-convert
      (unless (fboundp 'moccur)
        (autoload #'moccur "color-moccur" nil t)))
     '(leaf leaf-convert
        :commands moccur))

    ;; use-package :commands converted :commands
    ((leaf-convert
      (use-package color-moccur
        :commands (isearch-moccur isearch-all)
        :init
        (setq isearch-lazy-highlight t)))
     '(leaf color-moccur
        :commands isearch-moccur isearch-all
        :setq ((isearch-lazy-highlight . t))))))

(cort-deftest-generate :equal leaf-convert/bind
  '(
    ;; global-set-key convert :bind keyword
    ((leaf-convert
      (prog1 'simple
        (global-set-key (kbd "C-h") 'delete-backward-char)))
     '(leaf simple
        :bind (("C-h" . delete-backward-char))))

    ;; global-unset-key convert :bind keyword
    ((leaf-convert
      (prog1 'simple
        (global-unset-key (kbd "M-o"))))
     '(leaf simple
        :bind (("M-o"))))

    ;; define-key to global-map convert :bind keyword
    ((leaf-convert
      (prog1 'simple
        (define-key global-map (kbd "C-h") 'delete-backward-char)))
     '(leaf simple
        :bind (("C-h" . delete-backward-char))))

    ;; define-key nil to unset keybind
    ((leaf-convert
      (prog1 'simple
        (define-key global-map (kbd "C-h") nil)))
     '(leaf simple
        :bind (("C-h" . nil))))

    ;; define-key to specific keymap convert :bind keyword
    ((leaf-convert
      (prog1 'dired
        (define-key dired-mode-map (kbd "C-t") nil)))
     '(leaf dired
        :bind ((dired-mode-map
                ("C-t" . nil)))))

    ;; define-key remap convert :bind keyword
    ((leaf-convert
      (prog1 'dired
        (define-key dired-mode-map [remap next-line] 'dired-next-line)))
     '(leaf dired
        :bind ((dired-mode-map
                ([remap next-line] . dired-next-line)))))

    ;; bind-key convert :bind keyword
    ((leaf-convert
      (prog1 'simple
        (bind-key "C-h" 'delete-backward-char)))
     '(leaf simple
        :bind (("C-h" . delete-backward-char))))

    ;; bind-key specific keymap convert :bind keyword
    ((leaf-convert
      (prog1 'simple
        (bind-key "C-h" 'delete-backward-char prog-mode-map)))
     '(leaf simple
        :bind ((prog-mode-map
                ("C-h" . delete-backward-char)))))

    ;; simple bind-keys convert :bind keyword
    ((leaf-convert
      (prog1 'dired
        (bind-keys :map dired-mode-map
                   ("o" . dired-omit-mode)
                   ("a" . some-custom-dired-function))))
     '(leaf dired
        :bind ((dired-mode-map
                ("o" . dired-omit-mode)
                ("a" . some-custom-dired-function)))))

    ((leaf-convert
      (prog1 'custom
        (defun my-leaf-convert-command ()
          (message "hi"))
        (bind-key "M-*" 'my-leaf-convert-command)))
     '(leaf custom
        :preface
        (defun my-leaf-convert-command ()
          (message "hi"))
        :bind (("M-*" . my-leaf-convert-command))))

    ((leaf-convert
      (global-set-key (kbd "C-c l") '(lambda () (interactive)
                                       (ispell-change-dictionary "american"))))
     '(leaf leaf-convert
        :config
        (global-set-key (kbd "C-c l") '(lambda () (interactive)
                                         (ispell-change-dictionary "american")))))

    ((leaf-convert
      (global-set-key "\C-x\i" 'indent-region))
     '(leaf leaf-convert
        :bind (("\C-x\i" . indent-region))))))

(cort-deftest-generate :equal leaf-convert/bind*
  '(
    ;; bind-key* convert :bind* keyword
    ((leaf-convert
      (prog1 'simple
        (bind-key* "C-h" 'delete-backward-char)))
     '(leaf simple
        :bind* (("C-h" . delete-backward-char))))))

(cort-deftest-generate :equal leaf-convert/leaf-key
  '(
    ;; leaf-key convert :bind keyword
    ((leaf-convert
      (leaf-key "M-s O" #'moccur)
      (leaf-key "M-o" #'isearch-moccur))
     '(leaf leaf-convert
        :bind (("M-s O" . moccur)
               ("M-o" . isearch-moccur))))

    ;; leaf-keys convert :bind keyword
    ((leaf-convert
      (leaf-keys ("M-s O" . moccur)))
     '(leaf leaf-convert
        :bind (("M-s O" . moccur))))

    ;; leaf-keys convert :bind keyword
    ((leaf-convert
      (leaf-keys (("M-s O" . moccur)
                  ("M-o"   . isearch-moccur))))
     '(leaf leaf-convert
        :bind (("M-s O" . moccur)
               ("M-o" . isearch-moccur))))

    ;; leaf :bind keyword convert :bind keyword again
    ((leaf-convert
      (leaf term
        :bind (("C-c t" . term)
               (term-mode-map
                ("M-p" . term-send-up)
                ("M-n" . term-send-down))
               (term-raw-map
                ("M-o" . other-window)
                ("M-p" . term-send-up)
                ("M-n" . term-send-down)))))
     '(leaf term
        :bind (("C-c t" . term)
               (term-mode-map
                :package term
                ("M-p" . term-send-up)
                ("M-n" . term-send-down))
               (term-raw-map
                :package term
                ("M-o" . other-window)
                ("M-p" . term-send-up)
                ("M-n" . term-send-down)))))))

(cort-deftest-generate :equal leaf-convert/mode
  '(
    ;; add-to-list 'auto-mode-alist to :mode keyword
    ((leaf-convert
      (prog1 'ruby-mode
        (add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))))
     '(leaf ruby-mode
        :mode ("\\.rb\\'")))))

(cort-deftest-generate :equal leaf-convert/interpreter
  '(
    ;; add-to-list 'interpreter-alist to :interpreter keyword
    ((leaf-convert
      (prog1 'ruby-mode
        (add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))))
     '(leaf ruby-mode
        :interpreter ("ruby")))))

(cort-deftest-generate :equal leaf-convert/magic
  '(
    ;; add-to-list 'magic-mode-alist to :magic keyword
    ((leaf-convert
      (prog1 'pdf-tools
        (add-to-list 'magic-mode-alist '("%PDF" . pdf-view-mode))))
     '(leaf pdf-tools
        :magic (("%PDF" . pdf-view-mode))))))

(cort-deftest-generate :equal leaf-convert/magic-fallback
  '(
    ;; add-to-list 'magic-fallback-mode-alist to :magic-fallback keyword
    ((leaf-convert
      (prog1 'pdf-tools
        (add-to-list 'magic-fallback-mode-alist '("%PDF" . pdf-view-mode))))
     '(leaf pdf-tools
        :magic-fallback (("%PDF" . pdf-view-mode))))))

(cort-deftest-generate :equal leaf-convert/hook
  '(
    ;; add-hook convert to :hook keyword
    ((leaf-convert
      (prog1 'ace-jump-mode
        (add-hook 'prog-mode-hook #'ace-jump-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook)))

    ;; add-hook symbol also convert to :hook keyword
    ((leaf-convert
      (prog1 'ace-jump-mode
        (add-hook 'prog-mode-hook 'ace-jump-mode)))
     '(leaf ace-jump-mode
        :hook (prog-mode-hook)))))

(cort-deftest-generate :equal leaf-convert/custom
  '(
    ;; customize-set-variable convert to :custom keyword
    ((leaf-convert
      (prog1 'comint
        (customize-set-variable 'comint-prompt-regexp "^")))
     '(leaf comint
        :custom ((comint-prompt-regexp . "^"))))

    ;; ignore use-package template comment
    ((leaf-convert
      (prog1 'comint
        (customize-set-variable 'comint-prompt-regexp "^" "Customized with use-package comint")))
     '(leaf comint
        :custom ((comint-prompt-regexp . "^"))))

    ;; custom-set-variables also convert :custom keyword
    ((leaf-convert
      (prog1 'comint
        (custom-set-variables
         '(comint-buffer-maximum-size 20000)
         '(comint-prompt-read-only t))))
     '(leaf comint
        :custom ((comint-buffer-maximum-size . 20000)
                 (comint-prompt-read-only . t))))

    ((leaf-convert
      (prog1 'comint
        (custom-set-variables
         `(comint-buffer-maximum-size ,(* 256 256))
         `(comint-prompt-read-only t)
         `(leaf-keywords-optional '(:doc :url :tag)))))
     '(leaf comint
        :custom ((comint-prompt-read-only . t)
                 (leaf-keywords-optional . '(:doc :url :tag)))
        :config
        (customize-set-variables
         `(comint-buffer-maximum-size ,(* 256 256)))))))

(cort-deftest-generate :equal leaf-convert/custom*
  '(
    ;; if comment is non-nil, convert to custom*
    ((leaf-convert
      (prog1 'comint
        (customize-set-variable 'comint-buffer-maximum-size 20000 "Increase comint buffer size.")))
     '(leaf comint
        :custom* ((comint-buffer-maximum-size 20000 "Increase comint buffer size.")))

     ;; custom-set-variables also convert :custom* keyword
     ((leaf-convert
       (prog1 'comint
         (custom-set-variables
          '(comint-buffer-maximum-size 20000 "Increase comint buffer size.")
          '(comint-prompt-read-only t "Make the prompt read only."))))
      '(leaf comint
         :custom* ((comint-buffer-maximum-size 20000 "Increase comint buffer size.")
                   (comint-prompt-read-only t "Make the prompt read only.")))))))

(cort-deftest-generate :equal leaf-convert/custom-face
  '(
    ;; if comment is non-nil, convert to custom*
    ((leaf-convert
      (prog1 'auto-complete
        (custom-set-faces
         '(ac-candidate-face ((t (:background "dark orange" :foreground "white"))))
         '(ac-selection-face ((t (:background "blue" :foreground "white")))))))
     '(leaf auto-complete
        :custom-face ((ac-candidate-face . '((t (:background "dark orange" :foreground "white"))))
                      (ac-selection-face . '((t (:background "blue" :foreground "white")))))))))

(cort-deftest-generate :equal leaf-convert/when
  '(
    ;; when convert to :when keyword
    ((leaf-convert
      (prog1 'jupyter
        (when (executable-find "jupyter")
          (package-install 'jupyter)
          (require 'jupyter))))
     '(leaf jupyter
        :when (executable-find "jupyter")
        :ensure t
        :require t))

    ;; when and convert to multi value :when keyword
    ((leaf-convert
      (prog1 'jupyter
        (when (and (executable-find "python") (executable-find "jupyter"))
          (package-install 'jupyter)
          (require 'jupyter))))
     '(leaf jupyter
        :when (executable-find "python") (executable-find "jupyter")
        :ensure t
        :require t))))

(cort-deftest-generate :equal leaf-convert/unless
  '(
    ;; unless convert to :unless keyword
    ((leaf-convert
      (prog1 'servert
        (unless (server-running-p)
          (server-start))))
     '(leaf servert
        :unless (server-running-p)
        :config (server-start)))))

(cort-deftest-generate :equal leaf-convert/if
  '(
    ;; if convert to :when keyword only second argument
    ((leaf-convert
      (prog1 'jupyter
        (if (executable-find "jupyter")
            (progn
              (package-install 'jupyter)
              (require 'jupyter)))))
     '(leaf jupyter
        :when (executable-find "jupyter")
        :ensure t
        :require t))

    ;; if with not convert to :unless keyword only second argument
    ((leaf-convert
      (prog1 'jupyter
        (if (not (executable-find "jupyter"))
            (progn
              (package-install 'jupyter)
              (require 'jupyter)))))
     '(leaf jupyter
        :unless (executable-find "jupyter")
        :ensure t
        :require t))

    ;; if second argument is nil convert to leaf keyword
    ((leaf-convert
      (prog1 'jupyter
        (if (not (executable-find "jupyter"))
            nil
          (package-install 'jupyter)
          (require 'jupyter))))
     '(leaf jupyter
        :when (executable-find "jupyter")
        :ensure t
        :require t))

    ;; if second, theird argument is non-nil, convert to :config
    ((leaf-convert
      (prog1 'jupyter
        (if (executable-find "jupyter")
            (progn
              (package-install 'jupyter)
              (require 'jupyter))
          (warn "jupyter is not found"))))
     '(leaf jupyter
        :config
        (if (executable-find "jupyter")
            (progn
              (package-install 'jupyter)
              (require 'jupyter))
          (warn "jupyter is not found"))))))

(cort-deftest-generate :equal leaf-convert/diminish
  '(
    ;; simple diminish convert just symbol in :diminish
    ((leaf-convert
      (diminish 'jiggle-mode))
     '(leaf leaf-convert
        :diminish jiggle-mode))

    ;; if specify custom string convert cons cell in :diminish
    ((leaf-convert
      (diminish 'abbrev-mode "Abv"))
     '(leaf leaf-convert
        :diminish (abbrev-mode . "Abv")))))

(cort-deftest-generate :equal leaf-convert/delight
  '(
    ;; simple delight convert just symbol in :delight
    ((leaf-convert
      (delight 'jiggle-mode))
     '(leaf leaf-convert
        :delight jiggle-mode))

    ;; if specify custom string convert list in :diminish
    ((leaf-convert
      (delight 'abbrev-mode " Abv" "abbrev"))
     '(leaf leaf-convert
        :delight (abbrev-mode " Abv" "abbrev")))

    ;; modify majro-mode string is well converted
    ((leaf-convert
      (delight 'emacs-lisp-mode "Elisp" :major))
     '(leaf leaf-convert
        :delight (emacs-lisp-mode "Elisp" :major)))

    ;; multiple arg is well converted
    ((leaf-convert
      (delight '((abbrev-mode " Abv" "abbrev")
                 (smart-tab-mode " \\t" "smart-tab")
                 (eldoc-mode nil "eldoc")
                 (rainbow-mode)
                 (overwrite-mode " Ov" t)
                 (emacs-lisp-mode "Elisp" :major))))
     '(leaf leaf-convert
        :delight
        (abbrev-mode " Abv" "abbrev")
        (smart-tab-mode " \\t" "smart-tab")
        (eldoc-mode nil "eldoc")
        rainbow-mode
        (overwrite-mode " Ov" t)
        (emacs-lisp-mode "Elisp" :major)))))

(cort-deftest-generate :equal leaf-convert/chord
  '(
    ;; key-chord-define-global convert :chord
    ((leaf-convert
      (key-chord-define-global "hj" 'undo))
     '(leaf leaf-convert
        :chord (("hj" . undo))))

    ;; key-chord-define vector convert :chord
    ((leaf-convert
      (key-chord-define-global [?h ?j]  'undo))
     '(leaf leaf-convert
        :chord (([104 106] . undo))))

    ;; bind-chord convert :chord
    ((leaf-convert
      (bind-chord "jj" 'ace-jump-char-mode))
     '(leaf leaf-convert
        :chord (("jj" . ace-jump-char-mode))))))

(cort-deftest-generate :equal leaf-convert/mode-line-structp
  ;; see https://github.com/myrjola/diminish.el
  '(((leaf-convert--mode-line-structp " Rbow") t)
    ((leaf-convert--mode-line-structp ''rainbow-mode-lighter) t)
    ((leaf-convert--mode-line-structp ''(" " "R-" "bow")) t)
    ((leaf-convert--mode-line-structp ''((" " "R") "/" "bow")) t)
    ((leaf-convert--mode-line-structp ''(:eval (format " Rbow/%s" (+ 2 3)))) t)
    ((leaf-convert--mode-line-structp ''(:propertize " Rbow" face '(:foreground "green"))) t)
    ((leaf-convert--mode-line-structp ''(rainbow-mode-mode-linep " Rbow/t" " Rbow/nil")) t)
    ((leaf-convert--mode-line-structp ''(3 " Rbow" "/" "s")) t)))

;; (provide 'leaf-convert-test)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; leaf-convert-test.el ends here
