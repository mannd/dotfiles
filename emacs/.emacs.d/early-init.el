;;; -*- lexical-binding: t; -*-

(setq frame-resize-pixelwise t ; makes frame resizing smoother
      frame-title-format '("%b") ; just the buffer name
      ring-bell-function #'ignore ; ignore function returns nil
      use-dialog-box t ; mouse functions use dialogs...
      use-file-dialog nil ; ...except for file dialogs
      use-short-answers nil ; I don't mind typing long answers
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-startup-buffer-menu t)

(menu-bar-mode t)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; We don't set menu-bar-lines to 0 because we keep the menu.
(setq initial-frame-alist `((horizontal-scroll-bars . nil)
                            (tool-bar-lines . 0)
                            (vertical-scroll-bars . nil)
                            (width . (text-pixels . 800))
                            (height . (text-pixels . 600))
                            (border-width . 0)))

;; Define the var directory, for multiple uses
(defconst dem-var-directory
  (expand-file-name "var/" user-emacs-directory))

(make-directory dem-var-directory t)

(defconst dem-cache-directory
  (expand-file-name "cache/" user-emacs-directory))

(make-directory dem-cache-directory t)

;; Create auto-save-list directory
(let ((dir (expand-file-name "auto-save-list/" dem-var-directory)))
  (make-directory dir t)
  (setq auto-save-list-file-prefix
        (expand-file-name ".saves-" dir)))

;; Package files installed by package.el
(setq package-user-dir
      (expand-file-name "elpa/" user-emacs-directory))

;; Native-compilation cache
(startup-redirect-eln-cache
 (expand-file-name "cache/eln/" user-emacs-directory))
