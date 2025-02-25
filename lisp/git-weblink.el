;;
;; Create links to various types of links to files at a particular commit and a
;; particular line on popular git hosting services.
;;
;; Links can be stored similarly to 'org-store-link' to be inserted using
;; 'org-insert-link'
;;
;; Or a
;; - markdown link '(DESC)[URL]'
;; - plain URL
;; - hyperlink '<a href="URL">DESC</a>'
;; can be copied to the clipboard (kill ring).
;;
;; There are four main interactive commands and a keymap 'git-weblink-map'
;; - 'git-weblink-store-org-link' ('s')
;; - 'git-weblink-copy-markdown-link' ('m')
;; - 'git-weblink-copy-url' ('u')
;; - 'git-weblink-copy-hyperlink' ('h')
;; and two other commands that give interactive access to functions used for the
;; implementation of the above commands:
;; - 'git-weblink-copy-repo-url' ('r')
;; - 'git-weblink-copy-path-within-repo' ('p')
;;
;; The 'git-weblink-map' may be bound to a key
;; - (keymap-global-set "C-c g" 'git-weblink-map)
;; which would allow "C-c g m" to do 'git-weblink-copy-markdown-link' and so on.
;;
;; Individual bindings may also be made either globally
;; - (keymap-global-set "C-c u" #'git-weblink-copy-url)
;; or in a particular mode map
;; - (keymap-set org-mode-map "C-c o" #'git-weblink-copy-url)
;; to be active in particular modes, or to a generic map or prefix command
;; - (keymap-set help-map "g" 'git-weblink-map)
;; note that these functions replace the legacy functions 'global-set-key' and
;; 'define-key' and that the new functions understand key sequences that would
;; need to be processed by 'kbd' for the legacy functions.
;;
;; And in evil-mode, use
;; - 'evil-define-key' To define keys for states in particular modes
;; - 'evil-global-set-key' To define keys for states in all modes
;;

(defun git-weblink-split-remote-url (url)
  "Split a git remote URL of the form 'git@<DOMAIN>:<NAMESPACE>/<REPO>'i
or of the form 'https://<DOMAIN>/<NAMESPACE>/<REPO>

Returns a three element list '(list DOMAIN NAMESPACE REPO)'"
  (let ((split (string-split
                (cond ((string-prefix-p "git@" url)
                       (substring url 4))
                      ((string-prefix-p "https://" url)
                       (substring url 8))
                      (_ (error "URL '%s' does not start with 'git@' or 'https://'" url)))
                "[:/]")))
    (when (not (eq (length split) 3))
      (error "Could not split git URL '%s' into 3 parts" url))
    split))

(defun git-weblink-strip.git (repo)
  "Removes trailing '.git' from repo name.  This is needed to compose URLs that
visit a particular file in a repo"
  (if (string-suffix-p ".git" repo)
      (substring repo 0 -4)
    repo))

(defun git-weblink-compose-ref-url (domain namespace repo ref file lineno)
  "Compose a URL to visit a line of a file at a particular ref (branch name or
commit hash) in the web interface of the site hosting a git repository."
  (pcase domain
    ("github.com"
     (format "https://%s/%s/%s/blob/%s/%s?plain=1#L%s"
             domain namespace (git-weblink-strip.git repo) ref file lineno))
    ((or "gitlab.science.gc.ca" "gitlab.com")
     (format "https://%s/%s/%s/-/blob/%s/%s#L%s"
             domain namespace (git-weblink-strip.git repo) ref file lineno))
    (_ (error (format "No URL formation method known for domain '%s'" domain)))))

(defun git-weblink-path-within-repo (filename)
  "Get the path of a file in a repository.  This uses 'git ls-files FILE
--full-name' to get the path relative to the repo root.  It does not work on
untracked files."
  (let ((default-directory (file-name-directory filename)))
    (condition-case err
        (car (process-lines "git" "ls-files" "--full-name" filename))
      (t (error "Error in getting path of file '%s' within repo: '%s'" filename err)))))

(defun git-weblink-push-default-url ()
  "Get the URL of the default push remote"
  (condition-case err
      (let ((default-push-remote (car (process-lines "git" "config" "--get" "remote.pushDefault"))))
        (car (process-lines "git" "config" "--get" (format "remote.%s.url" default-push-remote))))
    (t (error "Could not get default git push url in default-directory '%s': %s" default-directory err))))

(defun git-weblink-to-point (exact-commit)
  "Return a link to the current line of the current file at the current revision
in the web interface of the remote repository

Returns '(link desc domain)' to compose various types of links.

If EXACT-COMMIT is not nil or if there is no current branch, the link will be to
the current commit, otherwise the current branch is used."
  (let* ((lineno (line-number-at-pos))
         (file (or (git-weblink-path-within-repo (buffer-file-name))
                   (error "Could not get path of file '%s' within repo (may be an untracked file)" (buffer-file-name))))
         (branch (ignore-errors (car (process-lines "git" "symbolic-ref" "--short" "HEAD")))))
    (pcase (git-weblink-split-remote-url (git-weblink-push-default-url))
      (`(,domain ,namespace ,repo)
       (pcase (process-lines "git" "rev-parse" "HEAD" "--short" "HEAD")
         (`(,long-hash ,short-hash)
          (let ((link (git-weblink-compose-ref-url domain namespace repo
                                                   (if (or exact-commit (not branch)) long-hash branch)
                                                   file lineno))
                (desc (format "<%s:%s>%s:%s" (git-weblink-strip.git repo)
                              (if (or exact-commit (not branch)) short-hash branch)
                              file lineno )))
            (list link desc domain))))))))

(defun git-weblink-store-org-link (arg)
  "Store web link to current line of current file at current revision for org
insert link

With prefix argument of if the repo is in detached HEAD, use exact commit,
otherwise use the current branch"
  (interactive "P")
  (pcase (git-weblink-to-point arg)
    (`(,link ,desc ,domain)
     (push (list link (format "=%s=" desc)) org-stored-links)
     (message "Stored org link %s on %s" desc domain))))

(defun git-weblink-copy-url (arg)
  "Copy web link to current line of current file at current revision as plain
URL.

With prefix argument of if the repo is in detached HEAD, use exact commit,
otherwise use the current branch"
  (interactive "P")
  (pcase (git-weblink-to-point arg)
    (`(,link ,desc, domain)
     (kill-new link)
     (message "Stored: link to %s on %s in kill ring" desc domain))))

(defun git-weblink-copy-markdown-link (arg)
  "Copy web link to current line of current file at current revision as a
markdown link '(DESC)[URL]'

With prefix argument of if the repo is in detached HEAD, use exact commit,
otherwise use the current branch"
  (interactive "P")
  (pcase (git-weblink-to-point arg)
    (`(,link ,desc, domain)
     (kill-new (format "(%s)[%s]" desc link))
     (message "Stored: Markdown link (%s)[...] on %s in kill ring" desc domain))))

(defun git-weblink-copy-hyperlink (arg)
  "Copy web link to current line of current file at current revision as a
HTML hyperlink link '<a href=\"URL\">DESC</a>'.

With prefix argument of if the repo is in detached HEAD, use exact commit,
otherwise use the current branch"
  (interactive "P")
  (pcase (git-weblink-to-point arg)
    (`(,link ,desc, domain)
     (let ((html-desc (string-replace "<" "&lt;" (string-replace ">" "&gt;" desc)))))
     (kill-new (format "<a href=\"%s\">%s</a>" link html-desc))
     (message "Copied hyperlink <a href=\"https://%s/...\">%s" domain html-desc))))

(defun git-weblink-copy-path-within-repo ()
  "Copy the path of the current file relative to the root of the git repository"
  (interactive)
  (let ((path-within-repo (git-weblink-path-within-repo (buffer-file-name))))
    (kill-new path-within-repo)
    (message "Copied path within repo: %s" path-within-repo)))

(defun git-weblink-copy-repo-url ()
  "Copy web URL for the remote of the current repository (this converts
'git@DOMAIN:NAMESPACE/REPO' to 'https://DOMAIN/NAMESPACE/REPO'"
  (interactive)
  (pcase (git-weblink-split-remote-url (git-weblink-push-default-url))
    (`(,domain ,namespace ,repo)
     (kill-new (format "https://%s/%s/%s" domain namespace repo)))))

(define-prefix-command 'git-weblink-map)
(define-key 'git-weblink-map (kbd "s") #'git-weblink-store-org-link)
(define-key 'git-weblink-map (kbd "u") #'git-weblink-copy-url)
(define-key 'git-weblink-map (kbd "m") #'git-weblink-copy-markdown-link)
(define-key 'git-weblink-map (kbd "h") #'git-weblink-copy-hyperlink)
(define-key 'git-weblink-map (kbd "r") #'git-weblink-copy-repo-url)
(define-key 'git-weblink-map (kbd "p") #'git-weblink-copy-path-within-repo)

(provide 'git-weblink)
