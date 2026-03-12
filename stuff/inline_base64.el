(setq love-struck-image-data "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII="
      love-struck-base64 (cadr (split-string love-struck-image-data ",")))

(defun img-file-to-base64 (file)
  (interactive (read-file-name "Image: "))
  (with-temp-buffer
    (insert-file-contents-literally file nil nil nil t)
    (base64-encode-region (point-min) (point-max))
    ;; TODO Check for max image file size?
    (buffer-string)))

;; instead of read-string read the base64 from the kill ring
(defun base64-to-image (base64 file)
  "Decode BASE64 string and save it as an image file named FILE."
  (interactive (list (completing-read "Base64: "  kill-ring) (read-file-name "Save as: ")))
  (let ((decoded-bytes (base64-decode-string base64)))
    (with-temp-buffer
      (insert decoded-bytes)
      (write-region (point-min) (point-max) file))))

(base64-to-image love-struck-base64 "/tmp/test.png")

(setq image-file "/tmp/test.png"
      image-from-file (create-image image-file)
      image-file-base64 (img-file-to-base64 image-file)
      image-from-base64 (create-image (base64-decode-string love-struck-base64) nil t))


(cl-defun maschm/find-string-backwards-range (&optional (string "test"))
  (save-excursion
    (let ((search-string string))
      (when (search-backward search-string nil t)
        (let ((beg (point))
              (end (+ (point) (length search-string))))
          (cons beg end))))))

;; test  

(setq pos-beg-end (maschm/find-string-backwards-range))


(put-text-property (car pos-beg-end) (cdr pos-beg-end) 'display image-from-file)
                                        ; can i make car cdr simpler
(remove-text-properties (car pos-beg-end) (cdr pos-beg-end) '(display nil))

;; (get-text-property (car pos-beg-end) 'display)
;; (get-char-property (car pos-beg-end) 'display)
;; (get-pos-property (car pos-beg-end) 'display) ;; nil ???
;; (get-char-property-and-overlay (car pos-beg-end) 'display)
;; (text-properties-at (car pos-beg-end))
;; (get-display-property (car pos-beg-end))


;; with image keymap
;; (insert-image image-from-file)

(url-generic-parse-url love-struck-image-data)
(shr-image-from-data love-struck-image-data)
(insert-image (create-image (shr-image-from-data love-struck-image-data) nil t))

(defun maschm/do-for-all-matches (regex fn)
  "Apply FN to all matches of REGEX in current buffer."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward regex nil t)
      (funcall fn (match-beginning 0) (match-end 0)))))


(setq data-uri-image-base64-regex
      (rx-let ((base64-chars (any alpha num "+" "/" "=")))
        (rx "data" ;; scheme
            ":"
            "image" ;; media type
            "/"
            (group (or "png" "jpg"))
            ";"
            "base64"
            ","
            (group (* base64-chars)))))

;; Example usage:
(defun maschm/replace-data-images ()
  (interactive)
  (maschm/do-for-all-matches data-uri-image-base64-regex
                             (lambda (beg end)
                               (put-text-property beg end 'display (create-image (shr-image-from-data (match-string-no-properties 0)) nil t))
                               )))
