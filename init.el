(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(when window-system 
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))

;;; Bootstrap use-package
;; Install use-package if it's not already installed.
;; use-package is used to configure the rest of the packages.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; From use-package README
(eval-when-compile
  (require 'use-package))
(require 'diminish)                ;; if you use :diminish
(require 'bind-key)

;;--------------------------------------------------------------------

(global-linum-mode nil)
(global-unset-key "\C-z")

(setq TeX-auto-safe t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(setq TeX-PDF-mode t)

;; (evil-commentary-mode)

;; (global-evil-leader-mode)
;; (evil-leader/set-leader ",")

(use-package org)

(use-package evil
  :ensure t
  :init (progn
	  (evil-mode 1)
	  (setq evil-want-C-w-delete nil)
	  (setq evil-want-C-w-in-emacs-state nil))
  :config (progn
;;	    (setq evil-emacs-state-modes (append evil-emacs-state-modes
;;						 'interactive-haskell)
	    (use-package evil-magit)
	    (use-package evil-org)
	    (use-package evil-commentary
	      :ensure t
	      :config (evil-commentary-mode))))


(use-package yasnippet
  :ensure t
  :defer t
  :diminish yas-minor-mode
  :config
  (yas-global-mode))

(use-package haskell-mode
  :bind (:map haskell-mode-map
	      ("C-c C-c" . haskell-compile))
  :config (progn
	    (use-package haskell-interactive-mode)
	    (use-package haskell-process)
	    (add-hook 'haskell-mode-hook 'interactive-haskell-mode)))

(use-package helm
  :ensure t
  :demand
  :diminish helm-mode
  :init (progn
          (require 'helm-config)
          ;; (use-package helm-projectile
          ;;   :ensure t
          ;;   :commands helm-projectil
          ;;   :bind ("C-c p h" . helm-projectile))
          ;; (use-package helm-ag :defer 10  :ensure t)
          (setq helm-locate-command "mdfind -interpret -name %s %s"
                helm-ff-newfile-prompt-p nil
                helm-M-x-fuzzy-match t)
          (helm-mode))
          ;; (use-package helm-swoop
          ;;   :ensure t
          ;;   :bind ("H-w" . helm-swoop)))
  :bind (("C-c h" . helm-command-prefix)
         ("C-x b" . helm-mini)
         ("C-`" . helm-resume)
         ("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)))

(use-package magit
  :ensure t
  :demand
  :bind (("C-x g" . magit-status)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-enabled-themes (quote (wombat)))
 '(package-selected-packages
   (quote
    (use-package org helm helm-fuzzy-find rust-mode rustfmt evil-matchit haskell-mode haskell-snippets haskell-tab-indent yasnippet evil evil-commentary evil-leader evil-magit evil-org evil-surround magit auctex))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
