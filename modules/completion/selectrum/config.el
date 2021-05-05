;;; completion/selectrum/config.el -*- lexical-binding: t; -*-

(use-package! selectrum
  :hook (doom-first-input . selectrum-mode)
  :init
  (setq selectrum-display-action nil
        selectrum-num-candidates-displayed 15
        selectrum-extend-current-candidate-highlight t)
  (when (featurep! +prescient)
    (setq completion-styles '(substring partial-completion)))
  :config
  (setq selectrum-fix-vertical-window-height 17
        selectrum-max-window-height 17)
  (defadvice! +selectrum-refresh-on-cycle (&rest _)
    :after 'marginalia-cycle
    (when (bound-and-true-p selectrum-mode) (selectrum-exhibit)))

  (defun +selectrum/backward-updir ()
    "Delete char before or go up directory for file cagetory selectrum buffers."
    (interactive)
    (if (and (eq (char-before) ?/)
             (eq (selectrum--get-meta 'category) 'file))
        (let ((new-path (minibuffer-contents)))
          (delete-region (minibuffer-prompt-end) (point-max))
          (insert (abbreviate-file-name
                   (file-name-directory
                    (directory-file-name
                     (expand-file-name new-path))))))
      (call-interactively 'backward-delete-char)))

  (map! :map selectrum-minibuffer-map
        "C-o"       #'embark-act
        "C-c C-o"   #'embark-export
        [backspace] #'+selectrum/backward-updir))

(use-package! selectrum-prescient
  :when (featurep! +prescient)
  :hook (selectrum-mode . selectrum-prescient-mode)
  :hook (selectrum-mode . prescient-persist-mode)
  :config
  (setq selectrum-preprocess-candidates-function #'selectrum-prescient--preprocess)
  (add-hook 'selectrum-candidate-selected-hook #'selectrum-prescient--remember)
  (add-hook 'selectrum-candidate-inserted-hook #'selectrum-prescient--remember))

(use-package! orderless
  :when (not (featurep! +prescient))
  :demand t
  :config
  (defun +selectrum-orderless-dispatch (pattern _index _total)
    (cond
     ;; Support $ as regexp end-of-line
     ((string-suffix-p "$" pattern) `(orderless-regexp . ,(concat (substring pattern 0 -1) "[\x100000-\x10FFFD]*$")))
     ;; Ignore single !
     ((string= "!" pattern) `(orderless-literal . ""))
     ;; Without literal
     ((string-prefix-p "!" pattern) `(orderless-without-literal . ,(substring pattern 1)))
     ;; Literal
     ((string-suffix-p "=" pattern) `(orderless-literal . ,(substring pattern 0 -1)))
     ;; Flex matching
     ((string-suffix-p "~" pattern) `(orderless-flex . ,(substring pattern 0 -1)))))
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        ;; note that despite override in the name orderless can still be used in find-file etc.
        completion-category-overrides '((file (styles . (partial-completion))))
        orderless-style-dispatchers '(+selectrum-orderless-dispatch)
        orderless-component-separator "[ &]"
        selectrum-refine-candidates-function #'orderless-filter
        selectrum-highlight-candidates-function #'orderless-highlight-matches))

(use-package! consult
  :defer t
  :init
  (fset 'multi-occur #'consult-multi-occur)
  (define-key!
    [remap apropos]                       #'consult-apropos
    [remap bookmark-jump]                 #'consult-bookmark
    [remap evil-show-marks]               #'consult-mark
    [remap goto-line]                     #'consult-goto-line
    [remap imenu]                         #'consult-imenu
    [remap locate]                        #'consult-locate
    [remap load-theme]                    #'consult-theme
    [remap man]                           #'consult-man
    [remap recentf-open-files]            #'consult-recent-file
    [remap switch-to-buffer]              #'consult-buffer
    [remap switch-to-buffer-other-window] #'consult-buffer-other-window
    [remap switch-to-buffer-other-frame]  #'consult-buffer-other-frame
    [remap yank-pop]                      #'consult-yank-pop
    [remap describe-bindings]             #'embark-bindings)
  (setq completion-in-region-function #'consult-completion-in-region)
  :config
  (recentf-mode)
  (setq consult-project-root-function #'doom-project-root)
  (setq completion-in-region-function #'consult-completion-in-region)
  (setq consult-narrow-key "<")
  (setf (alist-get #'consult-bookmark consult-config) (list :preview-key (kbd "C-SPC")))
  (setf (alist-get #'consult-recent-file consult-config) (list :preview-key (kbd "C-SPC")))
  (setf (alist-get #'consult--grep consult-config) (list :preview-key (kbd "C-SPC")))
  (setq consult-line-numbers-widen t)
  (setq consult-async-input-debounce 0.5)
  (setq consult-async-input-throttle 0.8))

(use-package! consult-xref
  :defer t
  :init
  (setq xref-show-xrefs-function       #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package! consult-flycheck
  :when (featurep! :checkers syntax)
  :after (consult flycheck))

(use-package! embark
  :init
  (setq embark-action-indicator #'+embark-which-key-action-indicator
        embark-become-indicator embark-action-indicator)
  :config
  (map!
   :map embark-file-map
   :desc "Open Dired on target" "j" #'ffap-dired
   :desc "Open target with sudo" "s" #'sudo-edit
   :desc "Open target with vlf" "l" #'vlf
   :map embark-file-map
   :desc "Cycle marginalia views" "A" #'marginalia-cycle))

(use-package! marginalia
  :hook (doom-first-input . marginalia-mode)
  :init
  (setq-default marginalia-annotators '(marginalia-annotators-heavy))
  :config
  (add-to-list 'marginalia-command-categories '(persp-switch-to-buffer . buffer)))

(use-package! embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))
