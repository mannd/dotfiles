;;; -*- lexical-binding: t; -*-

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
	     t)

;; Prioritize ELPA repositories over MELPA.
(setq package-archive-priorities
      '(("gnu" . 30)
	("nongnu" . 20)
	("melpa" . 10)))

;; Define and create directories for Emacs backup files.
(defconst dem-backup-directory
  (expand-file-name "backups/" dem-var-directory))

(make-directory dem-backup-directory t)

;; Configure backup files.
(setq backup-directory-alist
      `(("." . ,dem-backup-directory))
      version-control t
      kept-new-versions 5
      kept-old-versions 2
      delete-old-versions t
      backup-by-copying t)

;; Define and create directory for auto-save files.
(defconst dem-auto-save-directory
  (expand-file-name "auto-save/" dem-var-directory))

  (make-directory dem-auto-save-directory t)

  (setq auto-save-file-name-transforms
	`((".*" ,dem-auto-save-directory t)))

;; Setup custom.el but don't load it on startup.
(setq custom-file
      (expand-file-name "custom.el" dem-var-directory))

;; Preserve minibuffer history between Emacs sessions.
(setq savehist-file
     (expand-file-name "savehist" dem-var-directory))

(savehist-mode 1)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(use-package abbrev
  :ensure nil
  :hook
  (text-mode . abbrev-mode)
  :custom
  (save-abbrevs 'silently)
  (abbrev-file-name
   (expand-file-name "abbrev_defs" dem-var-directory)))

;; Refresh file and non-file buffers when their underlying data changes.
(setq global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

(set-frame-font "Aporetic Sans Mono-18" nil t)

(use-package modus-themes
  :ensure t)

(use-package ef-themes
  :ensure t)

(use-package doric-themes
  :ensure t)

(use-package standard-themes
  :ensure t
  :demand t
  :config
  (load-theme 'standard-light-tinted t)) ; preferred theme at the moment

;; Smooth trackpad scrolling.
(pixel-scroll-precision-mode 1)

;; Deleted files and directories go to the trash.
(setq delete-by-moving-to-trash t)

(use-package windmove
  :ensure nil
  :if (eq system-type 'darwin)
  :config
  (windmove-default-keybindings 'super))

(global-set-key (kbd "C-x C-n") #'other-window)

(global-set-key
 (kbd "C-x C-p")
 (lambda ()
   (interactive)
   (other-window -1)))

(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package bookmark
  :ensure nil
  :custom
  (bookmark-default-file
   (expand-file-name "bookmarks" dem-var-directory)))

;; Quick register shortcut to this file's symbolic link
(set-register ?c `(file . ,(expand-file-name "dem-emacs.org" user-emacs-directory)))

;; Make Dired better behaved.
(use-package dired
  :ensure nil
  :hook
  ((dired-mode . dired-hide-details-mode)
   (dired-mode . hl-line-mode))
  :custom
  (dired-dwim-target t)) ; used for copying from one dired buffer to another

;; Use evil-mode for Vim-like editing in text and prog-mode buffers.
;; Note that I use C-u for scrolling, like in Vim.  However,
;; in Insert mode, C-u acts like it does in Emacs, which is handy.
(use-package evil
  :ensure t
  :init
  (setq 
   evil-want-integration t
   evil-want-keybinding nil
   evil-want-C-u-scroll t 
   evil-want-C-i-jump nil
   evil-undo-system 'undo-redo)

  ;; Work around Evil 1.15.0 bug under Emacs 31.
  ;; Remove when a fixed Evil release reaches GNU/NonGNU ELPA.
  (defvar evil-mode-buffers nil)
  
  :config
  ;; Make vertical movement keys follow visual rather than logical lines.
  (define-key evil-normal-state-map [remap evil-next-line] #'evil-next-visual-line)
  (define-key evil-normal-state-map [remap evil-previous-line]  #'evil-previous-visual-line)
  (define-key evil-motion-state-map [remap evil-next-line] #'evil-next-visual-line)
  (define-key evil-motion-state-map [remap evil-previous-line]  #'evil-previous-visual-line)
  
  (setq-default evil-cross-lines t) ; motion keys go to next line
  
  (defun dem-toggle-evil-local-mode ()
    "Toggle Evil in the current buffer."
    (interactive)
    (if evil-local-mode
        (progn
          (evil-local-mode -1)
          (message "Evil disabled in this buffer"))
      (evil-local-mode 1)
      (message "Evil enabled in this buffer")))

  (global-set-key (kbd "C-c e") #'dem-toggle-evil-local-mode)

  (defun dem-enable-evil-for-selected-modes ()
    "Enable Evil only in buffers derived from text or programming modes."
    (when (derived-mode-p 'text-mode 'prog-mode)
      (evil-local-mode 1)))

  (add-hook 'after-change-major-mode-hook #'dem-enable-evil-for-selected-modes))

;; use evil-matchit to match more tags with "%"
(use-package evil-matchit
  :ensure t
  :config
  (global-evil-matchit-mode 1))

;; implement number functions
(use-package evil-numbers
  :ensure t
  :bind
  (:map evil-normal-state-map
  	("C-=" . evil-numbers/inc-at-pt)
  	("C--" . evil-numbers/dec-at-pt)))

(use-package org
  :ensure nil
  
  :init
  ;; We must define org-directory here even though it is the
  ;; default, to avoid an uninitialized variable error on startup.
  (setq org-directory "~/org" 
      org-default-notes-file
        (expand-file-name "inbox.org" org-directory))
  (setq org-agenda-files
        '("inbox.org"
          "personal.org"
          "home.org"
          "epstudios.org"
          "family.org"
          "org.org"))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "PENDING(p)" "WAITING(w@/!)" "HOLD(h@/!)" "SOMEDAY(s@/!)" "|" "CANCELLED(c@/!)")))
  (setq org-capture-templates
        '(("t" "todo" entry
           (file+headline org-default-notes-file "Tasks")
           "* TODO %?\n%U\n%a\n")))

  :bind
  (("C-c l" . org-store-link)
   ("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   ("C-c b" . org-switchb))

  :hook
  (org-mode . visual-line-mode)

  :custom
  (org-agenda-include-diary t)
  (org-hide-leading-stars t)
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-log-done 'time)
  (org-log-into-drawer "LOGBOOK")
  (org-tags-column 0)) ; tags are just after headline
;; Other options
;; to be tested to see if these are indeed useful
;; (org-M-RET-may-split-line '((default . nil)))
;; (org-insert-heading-respect-content t)

;; org-appear-mode shows and hides emphasis delimiters
(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode))

(use-package htmlize
  :ensure t
  :after org)

(use-package olivetti
  :ensure t)

(use-package denote
  :ensure t
  :hook
  (dired-mode . denote-dired-mode)
  :config
  (denote-rename-buffer-mode 1)) 

;; Oddly, denote seems to lack a function to just open the notes directory.
(defun dem-denote-open-denote-dir ()
  "Open the Denote directory."
  (interactive)
  (require 'denote)
  (dired denote-directory))

(use-package jinx
  :ensure t
  :hook (text-mode . jinx-mode)
  :bind
  (("M-$" . jinx-correct)
   ("C-M-$" . jinx-languages)
   ("M-n" . jinx-next)
   ("M-p" . jinx-previous)))

(use-package pdf-tools
  :ensure t
  :init
  (pdf-loader-install)

  :hook
  (pdf-view-mode . pdf-view-roll-minor-mode) ; smoother PDF scrolling

  :config
  (keymap-set pdf-view-mode-map "C-s" #'isearch-forward)
  (keymap-set pdf-view-mode-map "C-r" #'isearch-backward))

(use-package org-pdftools
  :ensure t
  :after (org pdf-tools)
  :hook
  (org-mode . org-pdftools-setup-link))

(use-package org-roam
  :ensure t
  :after org

  :custom
  (org-roam-directory
   (file-truename "~/Documents/org-roam")) ; default is ~/org-roam
  (org-roam-db-location
   (expand-file-name "org-roam.db" dem-var-directory))

  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert))

  :config
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target
           (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                      "#+title: ${title}\n#+filetags: ")
           :unnarrowed t)
          ("r" "bibliography reference" plain "%?"
           :target
           (file+head "references/${citekey}.org"
                      "#+title: ${title}\n")
           :unnarrowed t)))

  (setq org-roam-node-display-template
        (concat "${title} "
                (propertize "${tags}" 'face 'org-tag)))

  (org-roam-db-autosync-mode 1))

(use-package magit
  :ensure t
  :bind
  ("C-x g" . magit-status))

(use-package transient
  :ensure nil
  :custom
  (transient-history-file
   (expand-file-name "transient/history.el" dem-var-directory))
  (transient-values-file
   (expand-file-name "transient/values.el" dem-var-directory))
  (transient-levels-file
   (expand-file-name "transient/levels.el" dem-var-directory)))

(use-package project
  :ensure nil
  :init
  (setq project-list-file
	(expand-file-name "projects.eld" dem-var-directory))
  
  :config
  (keymap-set project-prefix-map "m" #'magit-project-status)
  (add-to-list 'project-switch-commands
               '(magit-project-status "Magit")
               t))

(use-package citar
 :ensure t
 :after org

 :custom
 (org-cite-global-bibliography
  '("~/Documents/Bibtex/My Library.bib"))
 (org-cite-csl-styles-dir
  (expand-file-name "~/Zotero/styles/"))

 (org-cite-insert-processor 'citar)
 (org-cite-follow-processor 'citar)
 (org-cite-activate-processor 'citar)

 (org-cite-export-processors
  '((t . (csl "american-medical-association.csl"))))

 (citar-bibliography org-cite-global-bibliography)

 :bind
 (:map org-mode-map
       ("C-c C-b" . org-cite-insert)))

(use-package citar-denote
  :ensure t
  :after (citar denote)
  :config
  (citar-denote-mode 1))

(use-package consult
  :ensure t
  :bind
  (("M-g M-g" . consult-goto-line)
   ("C-x b" . consult-buffer)
   ("M-s r" . consult-ripgrep)
   ("C-s" . consult-line)))

(use-package consult-denote
  :ensure t
  :after (consult denote)
  :config
  (consult-denote-mode 1))

(use-package consult-notes
  :ensure t
  :custom
  (consult-notes-file-dir-sources
   '(("Org Roam" ?r "~/Documents/org-roam")
     ("Bibliographic References" ?b "~/Documents/org-roam/references")
     ("Denote" ?d "~/Documents/notes"))))

(use-package ledger-mode
  :ensure t
  :custom
  (ledger-clear-whole-transactions 1)
  :hook
  (ledger-mode . ledger-flymake-enable)

  :mode
  (("\\.ledger\\'" . ledger-mode)
   ("\\.dat\\'" . ledger-mode)))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  :init
  (global-corfu-mode 1))

;; Objective-C and Java support are built in.
(use-package cc-mode
  :ensure nil)

;; C# has built-in support in modern Emacs.
(use-package csharp-mode
  :ensure nil)

(use-package kotlin-mode
  :ensure t)

(use-package swift-mode
  :ensure t) 

(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs
	       '(swift-mode . ("sourcekit-lsp"))))

(use-package geiser
  :ensure t)

(use-package geiser-racket
  :ensure t)

(load (expand-file-name "private/private.el" user-emacs-directory)
    'noerror)
