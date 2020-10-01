;;; email/mu4e/doctor.el -*- lexical-binding: t; -*-

(unless (executable-find "mu")
  (warn! "Couldn't find mu command. Mu4e requires this to work."))

(unless (or (executable-find "mbsync")
            (executable-find "offlineimap"))
  (wan! "Couldn't find mbsync or offlineimap command. \
You may not have a way of fetching mail."))

(when (and (featurep! :lang org)
           (not IS-WINDOWS))
  (unless (executable-find "identify")
    (warn! "Couldn't find the identify command from imagemagik. \
LaTeX fragment re-scaling with org-msg will not work.")))
