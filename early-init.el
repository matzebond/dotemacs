;; Disabling GC (by setting `gc-cons-threshold' to a very large value)
(setq gc-cons-threshold most-positive-fixnum) ;;gc-cons-percentage 0.6)
(add-hook 'after-init-hook
          (lambda ()
            (run-with-idle-timer 5 nil
                                 (lambda ()
                                   (interactive)
                                   (message "Reset gc threshold after init and idle")
                                   (setq gc-cons-threshold 50000000)))))

(setq package-enable-at-startup nil ; don't auto-initialize!
      ;; don't add that `custom-set-variables' block to my init.el!
      package--init-file-ensured t)


(menu-bar-mode -1) ; Turn off mouse interface early in startup to avoid momentary display.
(tool-bar-mode -1)
(scroll-bar-mode -1)
