;; -*- no-byte-compile: t; -*-
;;; tools/magit/packages.el

(when (package! magit :pin "fa604f2c5ae86f8117c3bdf3b322ef4c32af1816")
  (when (featurep! +forge)
    (package! forge :pin "b4fd0666a4d3987fc41e08eda3f6b1db7b404697"))
  (package! magit-gitflow :pin "cc41b561ec6eea947fe9a176349fb4f771ed865b")
  (package! magit-todos :pin "78d24cf419138b543460f40509c8c1a168b52ca0")
  (package! github-review :pin "341b7a1352e4ee1f1119756360ac0714abbaf460"))
