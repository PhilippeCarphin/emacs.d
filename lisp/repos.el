;;; This package is gives emacs functions for interacting with the repos
;;; command.
;;; TODO I have a few (let ((rfc repos-config-file)) (erase-buffer) (setq repos-config-file))
;;;      to keep the local value of repos-config-file so I think I should
;;;      probably rethink how all that works so that I don't have to do that.

;;; It provides two sets of things.
;;; 1. Functions to find files from repos
;;; 2. A repos-overview: a buffer for the output.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Configuration variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar repos-buffer nil "The buffer of the repos overview")
(defvar repos-errors nil "The buffer for the STDERR of the repos command")
(defvar repos-buffer-other nil "The buffer of the repos overview other")
(defvar repos-errors-other nil "The buffer for the STDERR of the repos command other")
(defvar repos-command "repos")

(defvar repos-remote-host nil "Host to run repos on.  In contexts with a shared
filesystem where only some nodes have outside internet access, this should be
set to the hostname of such a node.

When this is non-nil, the repos command constructing the repos overview buffer
will be (list \"ssh\" repos-remote-host (format repos-remote-command-fmt ...))

See `repos-remote-command-fmt', `repos-shell-in-repo', and
`repos-local-shell-in-repo'")

(defvar repos-remote-command-fmt "/bin/bash -c '%s'" "When `repos-remote-host'
is not nil, this format string is used to create the command to run on the
remote host.  The value must constain exactly one format specifier which is
where the repos command will be put.")

(defvar repos-overview-n-jobs 8 "Number of parallel jobs for the repos process.
Since most of the time is spent in git fetch commands, this number can be high
without taking much processing power.")

(defvar repos-overview-fetch t "Run git fetch for each repo.  If this is on, a
high value of `repos-over-view-n-jobs' like 8 or more is worth it.")

(defvar repos-overview-all t "Show all repos.  Normally repos filters out repos
that
- Are up-to-date with the remote (not ahead or behind)
- No unstaged changes
- No staged changes
- No untracked files ")

(defvar repos-overview-ignore t "Repos that are marked to be ignored are not
show if the only thing that is not 'clean' about them is that we are behind the
remote.

This is so that open-source repos that we don't work on don't needlessly show up
in the overview.

If we do want to see repos that are marked as ignored anyway we can set this to `nil'")

(defvar repos-shell-send-cd-command nil "Use `vterm-send-string' to send keys to
`cd' to the directory of the repo when creating shells.

The directory is normally set by locally setting `default-directory' before
launching `vterm' but depending on the value ov `vterm-shell' this may not go to
the no have any effect.  For example, if `vterm-shell' has the value `ssh localhost'

If `repos-remote-host' is set to `t', the commands `repos-shell-in-repo*' will
allways send the `cd' command to the shell regardless of the value
`repos-shell-send-cd-command' because doing so is necessary. ")

(defvar-local repos-config-file (expand-file-name "~/.config/repos.yml")
  "The location of the YAML config file for repos")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Base functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos-list-names ()
  "Return a list of repo names"
  (process-lines "repos" "-F" repos-config-file "-list-names"))

(defun repos-get-dir (repo-name)
  "Get the directory of a repo"
  (message "running 'repos -f %s -get-dir %s'" repos-config-file repo-name)
  (car (process-lines "repos" "-F" repos-config-file "-get-dir" repo-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Find files in repos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos-find-files ()
  "Find files from repos using helm."
  (interactive)
  (let ((repo-name (helm-comp-read
                    "Select a repos (fuzzy): "
                    (sort (repos-list-names) 'string<)
                    :fuzzy t)))
    (let ((repo-dir (repos-get-dir repo-name)))
      (helm-find-files-1 (concat repo-dir "/")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Launching vterm shells in repos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos--shell-in-directory (dir name)
  (let ((buf (get-buffer vterm-buffer-name)))
    (if buf
        (switch-to-buffer buf)
      (let ((default-directory dir))
        (message "default-directory: %s" default-directory)
        (if (or repos-remote-host repos-shell-send-cd-command)
            (let ((vterm-shell (concat "ssh " repos-remote-host)))
              (with-current-buffer (vterm name)
                (vterm-send-string
                 (concat "cd " (shell-quote-argument dir) (kbd "RET")))))
          (vterm name))))))

(defun repos-shell-in-repo (repo-name)
  "Open Vterm shell in repo named `repo-name'.

If `repos-remote-host' is a string, then this will be done `vterm-shell' locally
set to \"ssh <repos-remote-host>\" and in that case, `cd <repo-dir>' will be
sent to the shell via `vterm-send-string'.
"
  (let ((vterm-buffer-name (concat "Vterm:repo: " repo-name)))
    (repos--shell-in-directory (repos-get-dir repo-name) vterm-buffer-name)))


(defun repos-local-shell-in-repo (repo-name)
  "Open a local vterm shell in repo regardless of `repos-remote-host'

See `repos-shell-in-repo'"
  (let ((repos-remote-host nil)
        (vterm-buffer-name (concat "Vterm:repo: " repo-name "<local>")))
    (repos--shell-in-directory (repos-get-dir repo-name) vterm-buffer-name)))


(defun repos-shell () 
  "Open a shell inside a repo selected with `helm-comp-read'."
  (interactive)
  (let ((repo-name (helm-comp-read
                    "Select a repos (fuzzy): "
                    (sort (repos-list-names) 'string<)
                    :fuzzy t)))
    (repos-shell-in-repo repo-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Creating the repos-overview buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Creating the command argument list
(defun repos--create-base-command ()
  ;; Add-to-list adds to the front
  ;; Also some guy who looks like he gets LISP says add-to-list isn't good
  ;; for building a list the way I want.
  (let ((l (list)))
    (when repos-overview-all (add-to-list 'l "-all"))
    (when repos-overview-n-jobs
      (add-to-list 'l (number-to-string repos-overview-n-jobs))
      (add-to-list 'l "-j"))
    (unless repos-overview-fetch
      (add-to-list 'l "-no-fetch"))
    (if (boundp 'other-config-file)
        (add-to-list 'l other-config-file)
      (add-to-list 'l repos-config-file))
    (add-to-list 'l "-F")
    (add-to-list 'l repos-command)
    l))

(defun repos--create-command ()
  "Create command "
  (if repos-remote-host
      (repos--create-command-remote-command)
    (repos--create-base-command)))
(defun repos--create-command-remote-command ()
  (list "ssh"
        repos-remote-host
        (format repos-remote-command-fmt
                (mapconcat
                 'shell-quote-argument
                 (repos--create-base-command)
                 " "))))

;;; Creating and updating the buffer
(defun create-repos-buffer ()
  "Create the repos buffers and update them"
  (let ((repos-out-buf (generate-new-buffer "repos-out-buf"))
        (repos-err-buf (generate-new-buffer "repos-err-buf"))
        (cur (current-buffer)))
    (setq repos-buffer repos-out-buf)
    (setq repos-errors repos-err-buf)
    (repos--update-buffers repos-buffer repos-errors)))

(defun create-repos-buffer-other ()
  "Create the repos buffers and update them"
  (let ((repos-out-buf (generate-new-buffer "repos-out-buf-other"))
        (repos-err-buf (generate-new-buffer "repos-err-buf-other"))
        (cur (current-buffer)))
    (setq repos-buffer-other repos-out-buf)
    (setq repos-errors-other repos-err-buf)
    (repos--update-buffers repos-buffer-other repos-errors-other)))

;; TODO What if this function is called and the buffers
;; have not been created yet?
;; Maybe get rid of this function and just kill all the buffers and restart
(defun repos-update ()
  "Update the repos buffer by re-running the repos command"
  (interactive)
  (repos--update-buffers repos-buffer repos-errors))

(defun repos--update-buffers (target-buffer errors-buffer)
  "Internal function to update the buffers"
  (with-current-buffer target-buffer
    (read-only-mode -1)
    (let ((rfc repos-config-file))
      (erase-buffer)
      (setq repos-config-file rfc))
    (when (boundp 'other-config-file)
      (message "Setting repos-config-file to %s" other-config-file)
      (setq repos-config-file other-config-file)))
  (with-current-buffer errors-buffer
    (erase-buffer))
  (let ((proc (make-process
               :name "REPOS"
               :buffer target-buffer ;; Output goes in here
               :command (repos--create-command)
               :sentinel 'repos-process-sentinel
               :stderr errors-buffer)))
    (message "Constructing repos-buffer")))

(defun repos-overview ()
  (interactive)
  (if (not (buffer-live-p repos-buffer))
      (create-repos-buffer)
    (view-buffer repos-buffer)
    (message "Repos buffer already exists (run repos-update to update it)"))
  )

(defun repos-overview-other () (interactive)
       (let ((other-config-file (read-file-name
                                 "Select a repos config-file "
                                 (expand-file-name "~/.config/repos/")))
             (repos-overview-fetch nil))
         (if (not (buffer-live-p repos-buffer-other))
             (create-repos-buffer-other)
           (view-buffer repos-buffer))))

(defun repos-process-sentinel (proc event-string)
  (interactive) ;; Only interactive for testing
  (message "Repos process ended: %s" event-string)
  ;; I should also check (process-status proc) because this function
  ;; can get called for other things than process ending but in this
  ;; particular case it's the only event that can trigger this function.
  (let ((code (process-exit-status proc)))
    (when (equal code 0)
      (with-current-buffer repos-buffer
        ;; Activating repos-mode seems to undo the local buffer value
        ;; so I do this let to store the value, then set it after
        ;; enabling repos-mode
        (let ((rcf repos-config-file))
          (read-only-mode -1)
          (ansi-color-apply-on-region (point-min) (point-max))
          (read-only-mode)
          (beginning-of-buffer)
          (repos-mode)
          (setq repos-config-file rcf))
        (message "Repos buffer ready!")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repos overview major mode functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro repos-make-buffer-function (n func &rest body)
  "Make a function that operates on the repo on the line containing the cursor"
  `(defun ,n ()
     ,(format "Run `%s' in repo on the current line in the `repos-overview'
     buffer.

See `%s'" (symbol-name func) (symbol-name func))
     (interactive)
     (unless (= (line-number-at-pos) 1)
       (save-excursion
         (beginning-of-line)
         (let ((repo-name (thing-at-point 'filename)))
           (message "You have clicked repo: '%s'" repo-name)
           (,func (repos-get-dir repo-name))))))
  )

(repos-make-buffer-function repos-magit-in-repo-at-point magit-status)
(repos-make-buffer-function repos-dired-in-repo-at-point dired)

(defun repos-find-files-in-repo-at-point ()
  (interactive)
  (unless (= (line-number-at-pos) 1)
    (save-excursion
      (beginning-of-line)
      (let ((repo-name (thing-at-point 'filename)))
        (message "You have clicked repo: '%s'" repo-name)
        (helm-find-files-1 (concat (repos-get-dir repo-name) "/"))))))

(defun repos-find-files-at-point ()
  (interactive)
  (unless (= (line-number-at-pos) 1)
    (save-excursion
      (beginning-of-line)
      (let ((repo-name (thing-at-point 'filename)))
        (message "You have clicked repo: '%s'" repo-name)
        (helm-find-files-1 (concat (repos-get-dir repo-name) "/"))))))

(defun repos-shell-in-repo-at-point ()
  "Open Vterm shell in the directory of the repo of the current line in the
repos-overview buffer"
  (interactive)
  (unless (= (line-number-at-pos) 1)
    (save-excursion
      (beginning-of-line)
      (let ((repo-name (thing-at-point 'filename)))
        (message "You have clicked repo: '%s'" repo-name)
        (repos-shell-in-repo repo-name)))))

(defun repos-local-shell-in-repo-at-point ()
  "Open Vterm shell in the directory of the repo of the current line in the
repos-overview buffer"
  (interactive)
  (unless (= (line-number-at-pos) 1)
    (save-excursion
      (beginning-of-line)
      (let ((repo-name (thing-at-point 'filename)))
        (message "You have clicked repo: '%s'" repo-name)
        (repos-local-shell-in-repo repo-name)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repos overview major mode and keymap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-derived-mode repos-mode special-mode "Repos"
  "This is my major mode"
  :interactive t
  :group 'repos)
(add-hook 'repos-mode-hook (lambda () (toggle-truncate-lines 1)))
(add-hook 'repos-mode-hook (lambda () (visual-line-mode -1)))
(add-hook 'repos-mode-hook (lambda () (hl-line-mode 1)))

(defvar-keymap repos-mode-map
  :doc "Keymap for `repos-mode'."
  :parent nil
  "RET" #'repos-magit-in-repo-at-point
  "g" #'repos-magit-in-repo-at-point
  "d" #'repos-dired-in-repo-at-point
  "f" #'repos-find-files-in-repo-at-point
  "s" #'repos-shell-in-repo-at-point
  "l" #'repos-local-shell-in-repo-at-point
  "q" #'quit-window)

(evil-define-key 'motion repos-mode-map
  (kbd "RET") 'repos-magit-in-repo-at-point
  (kbd "f") 'repos-find-files-in-repo-at-point)
(evil-define-key 'normal repos-mode-map
  (kbd "g") 'repos-magit-in-repo-at-point
  (kbd "d") 'repos-dired-in-repo-at-point
  (kbd "s") 'repos-shell-in-repo-at-point
  (kbd "l") 'repos-local-shell-in-repo-at-point
  (kbd "q") 'quit-window)
;; Magit does this, not sure what it does
(add-hook 'repos-mode-hook 'evil-normalize-keymaps)

(provide 'repos)

