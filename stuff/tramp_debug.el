(setq tramp-verbose 6)
;; (doom-modeline-mode -1)
;; (debug-on-entry 'tramp-send-command)
;; (debug-on-entry 'tramp-debug-message)

(defun execute-only-local-advice (orig-fun &rest args)
  (unless (file-remote-p default-directory)
    (apply orig-fun args)))

(advice-add 'magit-turn-on-auto-revert-mode-if-desired :around 'execute-only-local-advice)

(let (;; (find-file-hook)
      ;; (doom-modeline-project-detection)
      )
  ;; (add-hook 'find-file-hook #'tramp-set-connection-local-variables-for-buffer)
  (find-file "/scp:pi:/etc/default/ebusd"))
