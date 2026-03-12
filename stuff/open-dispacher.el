;; ==== DETECTION CONFIGURATION ====
(defvar maschm/target-detector-alist
  '((dired-mode . dired-file)
    (pdf-view-mode . buffer-file)
    (image-mode . buffer-file)
    (doc-view-mode . buffer-file)
    (org-mode . thing-at-point)
    (markdown-mode . thing-at-point)
    (text-mode . buffer-file)
    (prog-mode . buffer-file)
    (fundamental-mode . buffer-file))
  "Alist mapping major modes to their preferred target detection strategy.
Strategies can be:
- `dired-file': Use file under dired cursor
- `buffer-file': Use current buffer's file
- `thing-at-point': Use thing at point (URL, file, etc.)
- A function: Custom function that returns the target to open")

(defvar-local maschm/target-detector-strategy nil
  "Buffer-local variable specifying how to determine what to open externally.
If nil, uses `maschm/target-detector-alist' based on major mode.")

;; ==== OPENER CONFIGURATION ====
(defvar maschm/external-opener-alist
  `((exteral-default . ,(pcase system-type
                          ('darwin "open")
                          ('cygwin "cygstart")
                          ('windows-nt . w32-shell-execute)
                          (_ "xdg-open")))
    (mode-based . ,(pcase system-type
                     ('darwin "open")
                     ('windows-nt . browse-url)
                     (_ "xdg-open")))
    (pdf . ,(pcase system-type
              ('darwin "open")
              ('windows-nt . w32-shell-execute)
              (_ "evince")))
    (image . ,(pcase system-type
                ('darwin "open")
                ('windows-nt . w32-shell-execute)
                (_ "feh")))
    (text . ,(pcase system-type
               ('darwin "open")
               ('windows-nt . w32-shell-execute)
               (_ "gedit")))
    (video . ,(pcase system-type
                ('darwin "open")
                ('windows-nt . w32-shell-execute)
                (_ "mpv"))))
  "Alist mapping file types to their preferred external opener.
Values can be:
- String: Command to execute
- Function: Function to call with target as argument
- Symbol `w32-shell-execute': Use Windows shell execute
- Symbol `browse-url': Use Emacs browse-url function")

(defvar-local maschm/external-opener-strategy nil
  "Buffer-local variable specifying which opener to use.
If nil, determines opener based on file type.")

;; ==== DETECTION FUNCTIONS ====
(defun maschm/detect-target (&optional strategy)
  "Detect the target to open externally based on STRATEGY or buffer-local configuration."
  (let ((strategy (or strategy
                      maschm/target-detector-strategy
                      (maschm/derive-detector-strategy))))
    (pcase strategy
      ('dired-file
       (if (eq major-mode 'dired-mode)
           (dired-get-file-for-visit)
         (user-error "Not in dired mode")))

      ('buffer-file
       (or (buffer-file-name)
           (user-error "Current buffer is not visiting a file")))

      ('thing-at-point
       (or (thing-at-point 'url)
           (thing-at-point 'filename)
           (thing-at-point 'symbol)
           (user-error "No recognizable thing at point")))

      ((pred functionp)
       (funcall strategy))

      (_
       (user-error "Unknown detector strategy: %s" strategy)))))

(defun maschm/derive-detector-strategy ()
  "Derive the detector strategy from major mode using `maschm/target-detector-alist'."
  (or (alist-get major-mode maschm/target-detector-alist)
      ;; Try parent modes
      (cl-loop for (mode . strategy) in maschm/target-detector-alist
               when (derived-mode-p mode)
               return strategy)
      ;; Default fallback
      'buffer-file))

;; ==== OPENER FUNCTIONS ====
(defun maschm/classify-target (target)
  "Classify TARGET to determine appropriate opener type."
  (cond
   ((string-match-p "\\`https?://" target) 'url)
   ((string-match-p "\\.\\(pdf\\|PDF\\)\\'" target) 'pdf)
   ((string-match-p "\\.\\(png\\|jpg\\|jpeg\\|gif\\|bmp\\|tiff\\|webp\\)\\'" target) 'image)
   ((string-match-p "\\.\\(mp4\\|avi\\|mkv\\|mov\\|webm\\|flv\\)\\'" target) 'video)
   ((string-match-p "\\.\\(txt\\|md\\|org\\|rst\\)\\'" target) 'text)
   (t 'default)))

(defun maschm/get-opener (target &optional strategy)
  "Get the appropriate opener for TARGET based on STRATEGY or classification."
  (let* ((type (or strategy (maschm/classify-target target)))
         (opener (alist-get type maschm/external-opener-alist)))
    (or opener
        (alist-get 'default maschm/external-opener-alist)
        (user-error "No opener configured for type: %s" type))))

(defun maschm/execute-opener (opener target)
  "Execute OPENER with TARGET."
  (when target
    ;; Convert to absolute path if it's a relative file path
    (unless (string-match-p "\\`[a-z]+://" target)
      (setq target (expand-file-name target)))

    (message "Opening `%s' externally with %s..." target opener)

    (pcase opener
      ('w32-shell-execute
       (if (and (eq system-type 'windows-nt)
                (fboundp 'w32-shell-execute))
           (w32-shell-execute "open" target)
         (user-error "w32-shell-execute not available")))

      ('browse-url
       (browse-url target))

      ((pred functionp)
       (funcall opener target))

      ((pred stringp)
       (start-process "open-external" nil opener target))

      (_
       (user-error "Unknown opener type: %s" opener)))))

;; ==== MAIN INTERFACE ====
(defun maschm/open-externally (&optional target opener-strategy)
  "Open TARGET externally using appropriate opener.
If TARGET is nil, detect target based on buffer-local configuration.
If OPENER-STRATEGY is provided, use that specific opener type."
  (interactive)
  (let* ((target (or target (maschm/detect-target)))
         (opener (maschm/get-opener target opener-strategy)))
    (maschm/execute-opener opener target)))

(defun maschm/open-with-prefix (arg)
  "Open file externally with prefix argument handling.
No prefix: Use buffer-local strategy
C-u (4): Force dired-file detection
C-u C-u (16): Force thing-at-point detection
C-u C-u C-u (64): Prompt for opener type"
  (interactive "P")
  (let ((detector-strategy (pcase arg
                             ('nil nil)  ; Use buffer-local/default
                             ('(4) 'dired-file)
                             ('(16) 'thing-at-point)
                             (_ nil)))
        (opener-strategy (when (equal arg '(64))
                           (intern (completing-read "Opener type: "
                                                    (mapcar #'car maschm/external-opener-alist)
                                                    nil t)))))
    (let ((target (maschm/detect-target detector-strategy)))
      (maschm/open-externally target opener-strategy))))

;; ==== CONFIGURATION HELPERS ====
(defun maschm/set-detector-strategy (strategy)
  "Set the buffer-local detector strategy to STRATEGY."
  (interactive (list (intern (completing-read "Detector strategy: "
                                              '("dired-file" "buffer-file" "thing-at-point")
                                              nil t))))
  (setq-local maschm/target-detector-strategy strategy)
  (message "Target detector strategy set to: %s" strategy))

(defun maschm/set-opener-for-type (type opener)
  "Set OPENER for file TYPE in `maschm/external-opener-alist'."
  (interactive (list (intern (completing-read "File type: "
                                              (mapcar #'car maschm/external-opener-alist)
                                              nil t))
                     (read-string "Opener command: ")))
  (setf (alist-get type maschm/external-opener-alist) opener)
  (message "Opener for %s set to: %s" type opener))

;; Hook to automatically set strategy based on major mode
(defun maschm/setup-external-opener ()
  "Set up external opener strategy for the current buffer based on major mode."
  (unless maschm/target-detector-strategy
    (setq-local maschm/target-detector-strategy (maschm/derive-detector-strategy))))

(add-hook 'after-change-major-mode-hook #'maschm/setup-external-opener)

;; ==== EXAMPLE CONFIGURATIONS ====
;; Custom detector for org-mode
(defun maschm/org-link-detector ()
  "Custom detector for org-mode that prefers links over files."
  (or (when (org-in-regexp org-link-bracket-re)
        (org-link-unescape (match-string-no-properties 1)))
      (buffer-file-name)
      (user-error "No link or file to open")))

;; Custom opener function example
(defun maschm/custom-pdf-opener (target)
  "Custom PDF opener that uses specific viewer."
  (start-process "pdf-viewer" nil "okular" target))

;; Configuration examples:
;; (add-to-list 'maschm/target-detector-alist '(org-mode . maschm/org-link-detector))
;; (add-to-list 'maschm/external-opener-alist '(pdf . maschm/custom-pdf-opener))
;; (add-to-list 'maschm/external-opener-alist '(pdf . "zathura"))
