(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Consolas" :foundry "outline" :slant normal :weight normal :height 120 :width normal))))
 '(highlight ((t (:background "#073642"))))
 '(linum-highlight-face ((t (:inherit default :foreground "yellow"))))
 '(show-paren-match ((t (:background "gray" :foreground "snow" :inverse-video nil :underline nil :slant normal :weight bold)))))
(require 'package)
(setq package-archives '(("ELPA" . "http://tromey.com/elpa/")
			 ("gnu" . "http://elpa.gnu.org/packages/")
			 ))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/")
             t)

(setq ring-bell-function 'ignore)
;;----------------------------------------------------------------------------
;; Less GC, more memory
;;----------------------------------------------------------------------------
;; By default Emacs will initiate GC every 0.76 MB allocated
;; (gc-cons-threshold == 800000).
;; we increase this to 512MB
;; @see http://www.gnu.org/software/emacs/manual/html_node/elisp/Garbage-Collection.html
(setq-default gc-cons-threshold (* 1024 1024 512)
              gc-cons-percentage 0.5)

(setq package-enable-at-startup nil)
(package-initialize)

(setq frame-title-format "emacs@%b")  
(defalias 'yes-or-no-p 'y-or-n-p)
;;theme congif
(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized")
(set-frame-parameter nil 'background-mode 'dark)
(load-theme 'solarized t)

;;vim config
(global-evil-leader-mode 1)
(require 'evil-leader)
(setq evil-leader/leader ",")
(setq evil-leader/in-all-states t)
(evil-leader/set-key
  "e" 'ido-find-file
  "b" 'ido-switch-buffer
  "B" 'ibuffer
  "k" 'kill-this-buffer
  "K" 'kill-buffer
  "x" 'smex
  "rm" 'bookmark-set
  "rl" 'bookmark-bmenu-list
  "rb" 'bookmark-jump
  "w" 'switch-window)
(require 'evil)
(setq evil-motion-state-modes (append evil-emacs-state-modes evil-motion-state-modes))
(setq evil-emacs-state-modes nil)
(evil-mode 1)

;;line number config
(require 'linum)
(global-linum-mode t)
(global-hl-line-mode 1)
(require 'hlinum)
(hlinum-activate)

;;smex config
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; speical grep config for windows
(setq grep-find-command '("findstr /spinr  *" . 16))

;; turn off tool bar
(tool-bar-mode 0)

;;aspell config
(add-to-list 'exec-path "~/.emacs.d/aspell/bin/")
(setq ispell-program-name "aspell")
(ispell-change-dictionary "american" t)

;; company mode 
(add-hook 'after-init-hook 'global-company-mode)

;;flyspell config
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))
(add-hook 'c++-mode-hook
  (lambda () (flyspell-prog-mode) 
             ;...
   ))

;;smart tab
(setq-default indent-tabs-mode nil)
(add-hook 'c-mode-common-hook 
	  (lambda () (setq indent-tabs-mode t)))
;;smart tab for CCMode
(setq-default tab-width 4) ; or any other preferred value
(setq cua-auto-tabify-rectangles nil)
(defadvice align (around smart-tabs activate)
    (let ((indent-tabs-mode nil)) ad-do-it))
(defadvice align-regexp (around smart-tabs activate)
    (let ((indent-tabs-mode nil)) ad-do-it))
(defadvice indent-relative (around smart-tabs activate)
    (let ((indent-tabs-mode nil)) ad-do-it))
(defadvice indent-according-to-mode (around smart-tabs activate)
    (let ((indent-tabs-mode indent-tabs-mode))
    (if (memq indent-line-function
                '(indent-relative
                indent-relative-maybe))
        (setq indent-tabs-mode nil))
    ad-do-it))
(defmacro smart-tabs-advice (function offset)
    `(progn
        (defvaralias ',offset 'tab-width)
        (defadvice ,function (around smart-tabs activate)
        (cond
        (indent-tabs-mode
            (save-excursion
            (beginning-of-line)
            (while (looking-at "\t*\\( +\\)\t+")
                (replace-match "" nil nil nil 1)))
            (setq tab-width tab-width)
            (let ((tab-width fill-column)
                (,offset fill-column)
                (wstart (window-start)))
            (unwind-protect
                (progn ad-do-it)
                (set-window-start (selected-window) wstart))))
        (t
            ad-do-it)))))
(smart-tabs-advice c-indent-line c-basic-offset)
(smart-tabs-advice c-indent-region c-basic-offset)


;;org mode
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;;require mode
(setq racket-racket-program "C:/Racket/Racket.exe")
(setq racket-raco-program "C:/Racket/raco.exe")
(require 'racket-mode)
(add-hook 'racket-mode-hook
  (lambda ()
    (paredit-mode 1)))

(add-hook 'racket-mode-hook #'rainbow-delimiters-mode)
(add-hook 'racket-mode-hook
          (lambda ()
            (define-key racket-mode-map (kbd "C-c r") 'racket-run)))

;;NeoTree config
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)


;;Dirs 
(setq dired-dwim-target t)
;; allow dired to be able to delete or copy a whole dir.
(setq dired-recursive-copies (quote always)) ; ¡°always¡± means no asking
(setq dired-recursive-deletes (quote top)) ; ¡°top¡± means ask once
(require 'dired-x)

;;switch-windows
(global-set-key (kbd"C-x o") 'switch-window)

;;ido 
(ido-mode 1)
(setq ido-enable-flex-matching t)

;;Recentf config
(recentf-mode 1)
(global-set-key (kbd "<f7>") 'recentf-open-files)

;;bookmark
(require 'bookmark)
(setq bookmark-save-flag 1) ; everytime bookmark is changed, automatically save it
(setq bookmark-save-flag t) 
;;open book mark
;;(setq inhibit-splash-screen t)
;;(bookmark-bmenu-list)
;;(switch-to-buffer "*Bookmark List*")


;; save/restore opened files and windows config
(desktop-save-mode 1) ; 0 for off
