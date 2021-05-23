;;; ui/ligatures/autoload/ligatures.el -*- lexical-binding: t; -*-

;; DEPRECATED
;;;###autodef
(define-obsolete-function-alias 'set-pretty-symbols! 'set-ligatures! "3.0.0")

;;;###autodef
(defun set-ligatures! (modes &rest plist)
  "Associates string patterns with icons in certain major-modes.

  MODES is a major mode symbol or a list of them.
  PLIST is a property list whose keys must either:

  - match keys in
`+ligatures-extra-symbols', and whose values are strings representing the text
to be replaced with that symbol, or
 - be one of two special properties:

  :alist ALIST
    Appends ALIST to `prettify-symbols-alist' literally, without mapping text to
    `+ligatures-extra-symbols'.

  :font-ligatures LIST
    Sets the list of strings that should get transformed by the font into ligatures,
    like \"==\" or \"-->\". LIST is a list of strings.

If the car of PLIST is nil, then unset any
pretty symbols and ligatures previously defined for MODES.

For example, the rule for emacs-lisp-mode is very simple:

  (set-ligatures! 'emacs-lisp-mode
    :lambda \"lambda\")

This will replace any instances of \"lambda\" in emacs-lisp-mode with the symbol
assicated with :lambda in `+ligatures-extra-symbols'.

Pretty symbols can be unset for emacs-lisp-mode with:

  (set-ligatures! 'emacs-lisp-mode nil)

Note that this will keep all ligatures in `+ligatures-prog-mode-list' active, as
`emacs-lisp-mode' is derived from `prog-mode'."
  (declare (indent defun))
  (if (null (car-safe plist))
      (dolist (mode (doom-enlist modes))
        (delq! mode +ligatures-extra-alist 'assq)
        (add-to-list 'ligature-ignored-major-modes mode))
    (let ((results)
          (font-ligatures))
      (while plist
        (let ((key (pop plist)))
          (cond
           ((eq key :alist)
            (prependq! results (pop plist)))
           ((eq key :font-ligatures)
            (setq font-ligatures (pop plist)))
           (t
            (when-let (char (plist-get +ligatures-extra-symbols key))
              (push (cons (pop plist) char) results))))))
      (when (and (fboundp #'ligature-set-ligatures) font-ligatures)
        (ligature-set-ligatures (doom-enlist modes) font-ligatures))
      (dolist (mode (doom-enlist modes))
        (setf (alist-get mode +ligatures-extra-alist)
              (if-let (old-results (alist-get mode +ligatures-extra-alist))
                  (dolist (cell results old-results)
                    (setf (alist-get (car cell) old-results) (cdr cell)))
                results))))))
