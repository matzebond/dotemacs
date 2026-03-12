;;; lmtdata-mode.el --- major mode for lmtdata(z) files at DeepL  -*- lexical-binding: t; -*-

(eval-when-compile
  (require 'rx))


;;;###autoload
(define-derived-mode lmtdata-mode text-mode "lmtdata"
  "Major mode for lmtdata(z) files."

  (set-char-table-range glyphless-char-display
                        (char-from-name "ZERO WIDTH SPACE") 'zero-width)

  (set-char-table-range glyphless-char-display
                        (char-from-name "ZERO WIDTH NON-JOINER") 'zero-width)

  ;; :abbrev-table nps-mode-abbrev-table
  ;; (setq font-lock-defaults nps--font-lock-defaults)
  ;; (setq-local comment-start "#")
  ;; (setq-local comment-start-skip "#+[\t ]*")
  ;; (setq-local indent-line-function #'nps-indent-line)
  ;; (setq-local indent-tabs-mode t)
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.lmtdataz?" . lmtdata-mode))
