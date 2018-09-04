(setq user-emacs-directory "~/.emacs.d.old/")

(setq gc-cons-threshold 400000000)

;;; Begin initialization
;; Turn off mouse interface early in startup to avoid momentary display
(when window-system
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))

(setq inhibit-startup-message t)
(setq initial-scratch-message "")


;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))



(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-compute-statistics t)
(setq use-package-verbose t)




(load-theme 'wombat t)

;;Backup

(defvar --backup-directory (concat user-emacs-directory "tmp/backup"))
(if (not (file-exists-p --backup-directory))
        (make-directory --backup-directory t))

(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t
      backup-by-copying t
      version-control t
      delete-old-versions t)

;;Indent

(use-package clean-aindent-mode
 :config (progn
	   (setq clean-aindent-is-simple-indent t)))


;;Spelling

(cond
 ((executable-find "aspell")
  ;; you may also need `ispell-extra-args'
  (setq ispell-program-name "aspell")
  (setq-default ispell-local-dictionary "de_DE")
  ;; (setq-default ispell-local-dictionary "en_US")
  ;; (setq ispell-local-dictionary "en_US" "de_DE")
  (setq ispell-local-dictionary "de_DE")
  (setq ispell-list-command "--list"))
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell")

  ;; Please note that `ispell-local-dictionary` itself will be passed to hunspell cli with "-d"
  ;; it's also used as the key to lookup ispell-local-dictionary-alist
  ;; if we use different dictionary
  (setq-default ispell-local-dictionary "en_US")
  (setq ispell-local-dictionary-alist
        '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8))))
 (t (setq ispell-program-name nil)))


(use-package flyspell
  :config (progn
	    ;; ommit error messages on spell checking for performance sake
	    (setq flyspell-issue-message-flag nil)))


(use-package diminish)

(use-package general
  :config (progn
            (general-evil-setup t)))

(use-package which-key
  :diminish which-key-mode
  :config (progn
            (which-key-mode)))


;;; abo-abo goodness

(use-package ivy
  :defer t
  :diminish ivy-mode
  :general (:states 'normal
                    "SPC TAB" 'mode-line-other-buffer
                    "SPC b" 'ivy-switch-buffer
                    "SPC g" nil)
  :config (progn
            (ivy-mode 1)
            (setq ivy-use-virtual-buffers t)
            (setq enable-recursive-minibuffers t)))

(use-package prescient
  :after (ivy))

(use-package ivy-prescient
  :after (ivy prescient)
  :config (progn
	    (ivy-prescient-mode t)))

;; (use-package 'company-prescient)

(use-package counsel
  :diminish counsel-mode
  :general (:states 'normal
		    "SPC f" 'counsel-find-file
		    "SPC F" 'counsel-find-file
		    "SPC SPC" 'counsel-M-x)

  :config (progn
            (counsel-mode)))

(use-package swiper
  :general (:keymaps '(normal insert emacs)
		     :prefix "SPC"
		     :non-normal-prefix "M-SPC"
		     "/" 'swiper))

(use-package avy
  :defer 5)

(use-package hydra
  :defer 5)


(use-package undo-tree
  :diminish undo-tree-mode
  :general (:states 'normal
		    "U" 'undo-tree-visualize))

(use-package evil
  :init (progn
	  (setq evil-want-C-w-delete nil)
	  (setq evil-want-C-w-in-emacs-state t)
	  (evil-mode 1))
  :config (progn
	    (cl-loop for (mode . state) in '((haskell-interactive-mode . emacs)
					     (haskell-error-mode . emacs)
					     (term-mode . emacs)
					     )
		     do (evil-set-initial-state mode state))
	    ))

(use-package evil-magit
  :after (evil magit))

(use-package evil-org
  :after (evil org))

(use-package evil-commentary
  :after (evil)
  :diminish (evil-commentary-mode)
	:config (evil-commentary-mode))

(use-package evil-surround
  :after (evil)
	:config (global-evil-surround-mode 1))

(use-package smartparens
  :config (progn
            (add-hook 'smartparens-enabled-hook #'evil-smartparens-mode)))

(use-package evil-smartparens
  :after (evil smartparens))



(use-package helpful
  :general (:states 'normal
		    "SPC h" 'helpful-at-point
		    "SPC H" 'helpful-at-point)
  :config (progn
	    (general-define-key
	     :keymaps 'helpful-mode-map
	     "q" 'bury-buffer)))


(use-package org
  :defer 15)

(use-package magit
  :defer 15
  :general (:states 'normal
		    "SPC g s" 'magit-status))

(use-package yasnippet
  :defer 5
  :diminish yas-minor-mode
  :config (yas-global-mode 1)

(use-package yasnippet-snippets
  :after yasnippet
  :config (yasnippet-snippets-initialize))

(use-package auto-yasnippets
  :after yasnippet)

;; (use-package haskell-mode
;;   :defer t
;;   :bind (:map haskell-mode-map
;; 	      ("C-c C-c" . haskell-compile))
;;   )

;; (use-package haskell-process
;;   :after haskell-mode)

;; (use-package haskell-interactive-mode
;;   :after haskell-mode
;;   :contig (add-hook 'haskell-mode-hook 'interactive-haskell-mode))

(use-package auctex
  :defer t
  :hook (latex-mode)
  :config (progn
	    (setq TeX-parse-self t) ;; enable parse on load
	    (setq TeX-auto-safe t) ;; enable parse on safe
	    (setq TeX-safe-query nil)
	    (setq-default TeX-master nil)
	    (setq TeX-PDF-mode t)
	    (add-hook 'TeX-mode-hook 'flyspell-mode)
	    (if (executable-find "latexmk")
		)))

(use-package auctex-latexmk
  :after (auctex)
  :config (progn
	    (auctex-latexmk-setup)
	    (setq auctex-latexmk-inherit-TeX-PDF-mode t)))

;; (use-package latex-preview-pane
;;   :defer t)

(use-package rust-mode
  :defer t
  :hook (rust-mode))

(use-package rustfmt
  :after (rust-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (evil-smartparens flymd markdown-mode markdown-preview-mode markdownfmt latex-preview-pane use-package rustfmt rust-mode helm-fuzzy-find haskell-snippets haskell-mode evil-surround evil-org evil-matchit evil-magit evil-commentary auctex clean-aindent-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
