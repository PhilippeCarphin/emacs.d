#!/usr/bin/env -S emacs --batch -l

;; Run this file with `emacs --batch -l <this-file>`

;; Emacs has some kind of key that comes with it that it uses when installing
;; elpa packages.  If you are on an old version of Emacs, then the key that
;; your emacs has won't work with the current key on elpa.  We need to update
;; our key.

;; We do this by installing the package `gnu-elpa-keyring-update`.  Since we
;; can't verify package because we don't have the right key, we need to disable
;; key checking temporarily while we do that.

;; Show Elisp debugger output on errors
(setq debug-on-error t)

;; Import the 'package' package and initialize it;
(require 'package)
(package-initialize)

;; Set TLS1.3 as our preferred algorithm (our old emacs would use 1.2 or
;; something which would be rejected on the other end)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; With key checking disabled, install the update
(setq package-check-signature nil)         ;; disable key checking for packages
(package-refresh-contents)                 ;; Update the package registry
(package-install 'gnu-elpa-keyring-update) ;; Install a package that gives us the new key
(setq package-check-signature t)           ;; Re-enable key checking for packages
