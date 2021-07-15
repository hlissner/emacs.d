;; -*- no-byte-compile: t; -*-
;;; tools/biblio/packages.el

(package! bibtex-completion :pin "9f6ea920a49457d85096caa0e61f086a42b2908e")
(package! citeproc :pin "0857973409e3ef2ef0238714f2ef7ff724230d1c")

(when (featurep! :completion ivy)
  (package! ivy-bibtex :pin "9f6ea920a49457d85096caa0e61f086a42b2908e"))
(when (featurep! :completion helm)
  (package! helm-bibtex :pin "9f6ea920a49457d85096caa0e61f086a42b2908e"))
(when (featurep! :completion vertico)
  (package! bibtex-actions :pin "98ab10cbfc377695b2ca33550e761ae0e762e3a5"))
