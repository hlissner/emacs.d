;;; module-php.el

(use-package php-mode
  :mode "\\.\\(php\\|inc\\)$"
  :init
  (define-docset! php-mode "php,laravel")
  (define-company-backend! php-mode '(php-extras-company))

  (add-hook! php-mode 'flycheck-mode)
  (setq php-template-compatibility nil
        php-extras-eldoc-functions-file (concat narf-temp-dir "php-extras-eldoc-functions"))
  :config
  (require 'php-extras)
  (defun php-extras-company-setup ()) ;; company will set up itself

  (unless (file-exists-p (concat php-extras-eldoc-functions-file ".el"))
    (async-start `(lambda ()
                    ,(async-inject-variables "\\`\\(load-path\\|php-extras-eldoc-functions-file\\)$")
                    (require 'php-extras-gen-eldoc)
                    (php-extras-generate-eldoc-1 t))
                 (lambda (_)
                   (load (concat php-extras-eldoc-functions-file ".el"))
                   (message "PHP eldoc updated!"))))

  ;; TODO Tie into emr
  (require 'php-refactor-mode)
  (add-hook! php-mode '(turn-on-eldoc-mode emr-initialize php-refactor-mode)))

(use-package php-boris :defer t
  :init
  (define-repl! php-mode php-boris)
  :config
  (evil-set-initial-state 'php-boris-mode 'emacs)
  (setq php-boris-command "~/.dotfiles/scripts/run-boris"))

(use-package hack-mode :mode "\\.hh$")

(define-minor-mode php-laravel-mode
  ""
  :init-value nil
  :lighter " Laravel"
  :keymap (make-sparse-keymap)
  (add-yas-minor-mode! 'php-laravel-mode))
(associate! php-laravel-mode
  :in (php-mode json-mode yaml-mode web-mode nxml-mode js2-mode scss-mode)
  :files ("artisan" "server.php"))

(provide 'module-php)
;;; module-php.el ends here
