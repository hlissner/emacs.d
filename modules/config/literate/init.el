;;; config/literate/init.el -*- lexical-binding: t; -*-

;;; config/literate/config.el -*- lexical-binding: t; -*-

;;; config/literate/packages.el -*- lexical-binding: t; -*-

(defvar +literate-config-file
  (expand-file-name "config.org" doom-private-dir)
  "The file path of your literate config file.")

(defvar +literate-config-dest-file
  (expand-file-name "config.el" doom-private-dir)
  "The file path that `+literate-config-file' will be tangled to, then
byte-compiled from.")

(defvar +literate-packages-file
  (expand-file-name "packages.org" doom-private-dir)
  "The file path of your literate packages file.")

(defvar +literate-packages-dest-file
  (expand-file-name "packages.el" doom-private-dir)
  "The file path that `+literate-packages-file' will be tangled to, then
byte-compiled from.")

;;
(defun +literate-compile (&optional load)
  "Tangles & compiles `+literate-config-file' and `+literate-packages-file' if
 it has changed. If LOAD is non-nil, load it too!"
  (let ((org-conf +literate-config-file)
        (org-pack +literate-packages-file)
        (el-conf  +literate-config-dest-file)
        (el-pack +literate-packages-dest-file))
    (when  (file-newer-than-file-p org-conf el-conf)
      (message "Compiling your literate config...")

      ;; We tangle in a separate, blank process because loading it here would
      ;; load all of :lang org (very expensive!). We only need ob-tangle.
      (or (zerop (call-process
                  "emacs" nil nil nil
                  "-q" "--batch" "-l" "ob-tangle" "--eval"
                  (format "(org-babel-tangle-file \"%s\" \"%s\" \"emacs-lisp\")"
                          org-conf el-conf)))
          (warn "There was a problem tangling your literate config!"))

      (message "Done!"))
    (when  (file-newer-than-file-p org-pack el-pack)
      (message "Compiling your literate packages...")

      ;; We tangle in a separate, blank process because loading it here would
      ;; load all of :lang org (very expensive!). We only need ob-tangle.
      (or (zerop (call-process
                  "emacs" nil nil nil
                  "-q" "--batch" "-l" "ob-tangle" "--eval"
                  (format "(org-babel-tangle-file \"%s\" \"%s\" \"emacs-lisp\")"
                          org-pack el-pack)))
          (warn "There was a problem tangling your literate packages!"))

      (message "Done!"))))

;; Let 'er rip!
(+literate-compile)

;; No need to load the resulting file. Doom will do this for us after all
;; modules have finished loading.
