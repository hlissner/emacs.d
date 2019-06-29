;;; core/cli/env.el -*- lexical-binding: t; -*-

(dispatcher! env
  (let ((env-file (abbreviate-file-name doom-env-file)))
    (pcase (car args)
      ((or "refresh" "re")
       (doom-reload-env-file 'force))
      ((or "enable" "auto")
       (setenv "DOOMENV" "1")
       (print! (green "Enabling auto-reload of %S") env-file)
       (doom-reload-env-file 'force)
       (print! (green "Done! `doom refresh' will now refresh your envvar file.")))
      ("clear"
       (setenv "DOOMENV" nil)
       (unless (file-exists-p env-file)
         (user-error "%S does not exist to be cleared" env-file))
       (delete-file env-file)
       (print! (green "Disabled envvar file by deleting %S") env-file))
      (_
       (print! "%s\n\n%s"
               (bold (red "No valid subcommand provided."))
               "See `doom help env` to see available commands."))))
  "Manages your envvars file.

  env [SUBCOMMAND]

Available subcommands:

  refresh  Create or regenerate your envvar file
  auto     enable auto-reloading of your envvars file (on `doom refresh`)
  clear    deletes your envvar file (if it exists) and disables auto-reloading

An envvars file (its location is controlled by the `doom-env-file' variable)
will contain a list of environment variables scraped from your shell environment
and loaded when Doom starts (if it exists). This is necessary when Emacs can't
be launched from your shell environment (e.g. on MacOS or certain app launchers
on Linux).

To generate a file, run `doom env refresh`. If you'd like this file to be
auto-reloaded when running `doom refresh`, run `doom env enable` instead (only
needs to be run once).")


;;
;; Helpers

(defvar doom-env-ignored-vars
  '("DBUS_SESSION_BUS_ADDRESS"
    "GPG_AGENT_INFO"
    "SSH_AGENT_PID"
    "SSH_AUTH_SOCK"
    ;; Doom envvars
    "INSECURE"
    "DEBUG"
    "YES")
  "Environment variables to not save in `doom-env-file'.

Each string is a regexp, matched against variable names to omit from
`doom-env-file'.")

(defvar doom-env-executable
  (if IS-WINDOWS
      "set"
    (executable-find "env"))
  "The program to use to scrape your shell environment with.
It is rare that you'll need to change this.")

(defvar doom-env-switches
  (if IS-WINDOWS
      "-c"
    "-ic") ; Execute in an interactive shell
  "The `shell-command-switch'es to use on `doom-env-executable'.
This is a list of strings. Each entry is run separately and in sequence with
`doom-env-executable' to scrape envvars from your shell environment.")

;; Borrows heavily from Spacemacs' `spacemacs//init-spacemacs-env'.
(defun doom-reload-env-file (&optional force-p)
  "Generates `doom-env-file', if it doesn't exist (or if FORCE-P).

This scrapes the variables from your shell environment by running
`doom-env-executable' through `shell-file-name' with `doom-env-switches'. By
default, on Linux, this is '$SHELL -ic /usr/bin/env'. Variables in
`doom-env-ignored-vars' are removed."
  (when (or force-p (not (file-exists-p doom-env-file)))
    (with-temp-file doom-env-file
      (message "%s envvars file at %S"
               (if (file-exists-p doom-env-file)
                   "Regenerating"
                 "Generating")
               (abbreviate-file-name doom-env-file))
      (let ((process-environment doom-site-process-environment))
        (insert
         (concat
          "# -*- mode: dotenv -*-\n"
          (format "# Generated with: %s %s %s\n"
                  shell-file-name
                  doom-env-switches
                  doom-env-executable)
          "# ---------------------------------------------------------------------------\n"
          "# This file was auto-generated by `doom env refresh'. It contains a list of\n"
          "# environment variables scraped from your default shell (excluding variables\n"
          "# blacklisted in doom-env-ignored-vars).\n"
          "#\n"
          "# It is NOT safe to edit this file. Changes will be overwritten next time that\n"
          "# `doom env refresh` is executed. Alternatively, create your own env file and\n"
          "# load it with `(doom-load-env-vars FILE)`.\n"
          "#\n"
          "# To auto-regenerate this file when `doom reload` is run, use `doom env auto' or\n"
          "# set DOOMENV=1 in your shell environment/config.\n"
          "# ---------------------------------------------------------------------------\n\n"))
        (let ((shell-command-switch doom-env-switches))
          (message "Scraping env from '%s %s %s'"
                   shell-file-name
                   shell-command-switch
                   doom-env-executable)
          (save-excursion
            (insert (shell-command-to-string doom-env-executable)))
          ;; Remove undesireable variables
          (dolist (regexp doom-env-ignored-vars)
            (save-excursion
              (when (re-search-forward (format "\n\\(%s+\\)=" regexp) nil t)
                (let ((var (match-string 1)))
                  (message "Ignoring %s" var)
                  (delete-region
                   (match-beginning 0)
                   (1- (or (save-excursion
                             (when (re-search-forward "^\\([^= ]+\\)=" nil t)
                               (line-beginning-position)))
                           (point-max))))))))
          (print! (green "Envvar successfully generated")))))))
