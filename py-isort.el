;;; py-isort.el --- Use isort to sort the imports in a Python buffer

;; Copyright (C) 2014, Friedrich Paetzke <paetzke@fastmail.fm>

;; Author: Friedrich Paetzke <paetzke@fastmail.fm>
;; URL: http://paetzke.me/project/py-isort.el
;; Version: 0.7

;;; Commentary:

;; Provides the `py-isort' command, which uses the external "isort"
;; tool to tidy up the imports in the current buffer.

;; To automatically sort imports when saving a python file, use the
;; following code:

;;   (add-hook 'before-save-hook 'py-isort-before-save)

;; To customize the behaviour of "isort" you can set the
;; py-isort-options e.g.

;;   (setq py-isort-options '("--lines=100"))

;;; Code:

(defgroup py-isort nil
  "Use isort to sort the imports in a Python buffer."
  :group 'convenience
  :prefix "py-isort-")


(defcustom py-isort-options nil
  "Options used for isort."
  :group 'py-isort
  :type '(repeat (string :tag "option")))


(defun py-isort--apply-rcs-patch (patch-buffer)
  "Apply an RCS-formatted diff from PATCH-BUFFER to the current buffer."
  (let ((target-buffer (current-buffer))
        (line-offset 0))
    (save-excursion
      (with-current-buffer patch-buffer
        (goto-char (point-min))
        (while (not (eobp))
          (unless (looking-at "^\\([ad]\\)\\([0-9]+\\) \\([0-9]+\\)")
            (error "invalid rcs patch or internal error in py-isort--apply-rcs-patch"))
          (forward-line)
          (let ((action (match-string 1))
                (from (string-to-number (match-string 2)))
                (len  (string-to-number (match-string 3))))
            (cond
             ((equal action "a")
              (let ((start (point)))
                (forward-line len)
                (let ((text (buffer-substring start (point))))
                  (with-current-buffer target-buffer
                    (setq line-offset (- line-offset len))
                    (goto-char (point-min))
                    (forward-line (- from len line-offset))
                    (insert text)))))
             ((equal action "d")
              (with-current-buffer target-buffer
                (goto-char (point-min))
                (forward-line (- from line-offset 1))
                (setq line-offset (+ line-offset len))
                (kill-whole-line len)))
             (t
              (error "invalid rcs patch or internal error in py-isort--apply-rcs-patch")))))))))


(defun py-isort--replace-region (filename)
    (delete-region (region-beginning) (region-end))
    (insert-file-contents filename))


(defun py-isort--sort (&optional only-on-region)
  "Uses the \"isort\" tool to reformat the current buffer."
  (interactive "r")
  (unless (executable-find "isort")
    (error "\"isort\" command not found. Install isort with \"pip install isort\""))
  (let ((default-directory (file-name-directory buffer-file-name))
        (tmpfile (make-temp-file "isort" nil ".py"))
        (patchbuf (get-buffer-create "*isort patch*"))
        (errbuf (get-buffer-create "*isort Errors*"))
        (coding-system-for-read 'utf-8)
        (coding-system-for-write 'utf-8))

    (with-current-buffer errbuf
      (setq buffer-read-only nil)
      (erase-buffer))
    (with-current-buffer patchbuf
      (erase-buffer))

    (if (and only-on-region (use-region-p))
        (write-region (region-beginning) (region-end) tmpfile)
      (write-region nil nil tmpfile))

    (if (zerop (apply 'call-process "isort" nil errbuf nil
                      (append `(" " , tmpfile, " ",
                                (concat "--settings-path=" default-directory))
                              py-isort-options)))
        (if (zerop (call-process-region (point-min) (point-max) "diff" nil patchbuf nil "-n" "-" tmpfile))
            (progn
              (kill-buffer errbuf)
              (message "Buffer is already isorted"))

          (if only-on-region
              (py-isort--replace-region tmpfile)
            (py-isort--apply-rcs-patch patchbuf))

          (kill-buffer errbuf)
          (message "Applied isort."))
      (error "Could not apply isort. Check *isort Errors* for details"))
    (kill-buffer patchbuf)
    (delete-file tmpfile)))


;;;###autoload
(defun py-isort-region ()
  "Uses the \"isort\" tool to reformat the current region."
  (interactive)
  (py-isort--sort t))


;;;###autoload
(defun py-isort-buffer ()
  "Uses the \"isort\" tool to reformat the current buffer."
  (interactive)
  (py-isort--sort nil))


;;;###autoload
(defun py-isort-before-save ()
  (interactive)
  (when (eq major-mode 'python-mode)
    (condition-case err (py-isort--sort)
      (error (message "%s" (error-message-string err))))))


;; BEGIN GENERATED -----------------
;; !!! This file is generated !!!
;; buftra.el
;; Copyright (C) 2015, Friedrich Paetzke <paetzke@fastmail.fm>
;; Author: Friedrich Paetzke <paetzke@fastmail.fm>
;; URL: https://github.com/paetzke/buftra.el
;; Version: 0.3


(defun py-isort-bf--apply-rcs-patch (patch-buffer)
  "Apply an RCS-formatted diff from PATCH-BUFFER to the current buffer."
  (let ((target-buffer (current-buffer))
        (line-offset 0))
    (save-excursion
      (with-current-buffer patch-buffer
        (goto-char (point-min))
        (while (not (eobp))
          (unless (looking-at "^\\([ad]\\)\\([0-9]+\\) \\([0-9]+\\)")
            (error "invalid rcs patch or internal error in py-isort-bf--apply-rcs-patch"))
          (forward-line)
          (let ((action (match-string 1))
                (from (string-to-number (match-string 2)))
                (len  (string-to-number (match-string 3))))
            (cond
             ((equal action "a")
              (let ((start (point)))
                (forward-line len)
                (let ((text (buffer-substring start (point))))
                  (with-current-buffer target-buffer
                    (setq line-offset (- line-offset len))
                    (goto-char (point-min))
                    (forward-line (- from len line-offset))
                    (insert text)))))
             ((equal action "d")
              (with-current-buffer target-buffer
                (goto-char (point-min))
                (forward-line (- from line-offset 1))
                (setq line-offset (+ line-offset len))
                (kill-whole-line len)))
             (t
              (error "invalid rcs patch or internal error in py-isort-bf-apply--rcs-patch")))))))))


(defun py-isort-bf--replace-region (filename)
  (delete-region (region-beginning) (region-end))
  (insert-file-contents filename))


(defun py-isort-bf--apply-executable-to-buffer (executable-name executable-call only-on-region)
  "Formats the current buffer according to the executable"
  (when (not (executable-find executable-name))
    (error (format "%s command not found." executable-name)))
  (let ((tmpfile (make-temp-file executable-name nil ".py"))
        (patchbuf (get-buffer-create (format "*%s patch*" executable-name)))
        (errbuf (get-buffer-create (format "*%s Errors*" executable-name)))
        (coding-system-for-read buffer-file-coding-system)
        (coding-system-for-write buffer-file-coding-system))
    (with-current-buffer errbuf
      (setq buffer-read-only nil)
      (erase-buffer))
    (with-current-buffer patchbuf
      (erase-buffer))

    (if (and only-on-region (use-region-p))
        (write-region (region-beginning) (region-end) tmpfile)
      (write-region nil nil tmpfile))

    (if (funcall executable-call errbuf tmpfile)
        (if (zerop (call-process-region (point-min) (point-max) "diff" nil
                                        patchbuf nil "-n" "-" tmpfile))
            (progn
              (kill-buffer errbuf)
              (message (format "Buffer is already %sed" executable-name)))

          (if only-on-region
              (py-isort-bf--replace-region tmpfile)
            (py-isort-bf--apply-rcs-patch patchbuf))

          (kill-buffer errbuf)
          (message (format "Applied %s" executable-name)))
      (error (format "Could not apply %s. Check *%s Errors* for details"
                     executable-name executable-name)))
    (kill-buffer patchbuf)
    (delete-file tmpfile)))


;; py-isort-bf.el ends here
;; END GENERATED -------------------


(provide 'py-isort)


;;; py-isort.el ends here
