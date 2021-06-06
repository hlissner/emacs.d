(when (and EMACS28+
           (or (featurep 'ns)
               (string-match-p "HARFBUZZ" system-configuration-features))
           (featurep 'composite))
  (package! ligature
    :recipe (:host github
             :repo "mickeynp/ligature.el"
             :files ("*.el"))
    :pin "3923baf1fb9bf509cc95b4b14d7d0e2f7c88e53c"))
