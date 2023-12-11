(defvar elpaca-installer-version 0.5)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(defun my-prog-mode-setup ()
  (electric-pair-mode 1) 
  (setq tab-always-indent 'complete)
  (setq tab-first-completion 'word)
  (global-set-key (kbd "C-q") 'save-buffer)
	(global-corfu-mode)
  (setq tab-width 2))

(add-hook 'prog-mode-hook #'my-prog-mode-setup)


(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying t        ; Don't delink hardlinks
      version-control t          ; Use version numbers on backups
      delete-old-versions t      ; Automatically delete excess backups
      kept-new-versions 20       ; How many of the newest versions to keep
      kept-old-versions 5        ; and how many of the old
      )

(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/auto-save-list/" t)))

(setq inhibit-startup-screen t)

(use-package meow
  :config
  (meow-global-mode)
  (meow-setup))

(defun my-split-window-and-open-term ()
  "Split the window vertically and open an Eshell terminal in the new window."
  (interactive)
  (split-window-right)  ; Split window vertically
  (other-window 1)      ; Move to the new window
  (let ((current-prefix-arg 15))  ; C-u 10
    (call-interactively 'shrink-window-horizontally))
  (eat-project)             ; Open Eshell terminal
  )

(defun my-close-window ()
  "Close a window based on the current window configuration."
  (interactive)
  (let ((window-count (length (window-list))))
    (cond
     ((= window-count 1) (message "Only one window, can't close it"))
     ((= window-count 2) (delete-other-windows))
     (t (ace-delete-window))))) ; Assuming you've set up ace-window
  

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . "H-j")
   '("k" . "H-k")
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . consult-line)
   '("t" . treemacs)
   '("f" . projectile-find-file)
   '("b" . switch-to-buffer)
   '("y" . yas-insert-snippet)
   '("s" . persp-switch)
   '("o" . my-close-window)
   '("p" . projectile-command-map)
   '("e" . my-split-window-and-open-term)
   '("?" . meow-cheatsheet)
   '("i" . magit)
   '("a" . eglot-code-actions))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '(">" . meow-indent)
   '("'" . repeat)
   '("<escape>" . ignore)))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(use-package vundo
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols)
  (global-set-key (kbd "C-r") 'vundo))

;; Use puni-mode globally and disable it for term-mode.
(use-package puni
  :defer t
  :init
  ;; The autoloads of Puni are set up so you can enable `puni-mode` or
  ;; `puni-global-mode` before `puni` is actually loaded. Only after you press
  ;; any key that calls Puni commands, it's loaded.
  (puni-global-mode)
  (add-hook 'term-mode-hook #'puni-disable-puni-mode))

(with-eval-after-load 'puni
  (define-key puni-mode-map (kbd "M-)") 'puni-slurp-forward)
  (define-key puni-mode-map (kbd "M-(") 'puni-slurp-backward)
  (define-key puni-mode-map (kbd "M-}") 'puni-barf-forward)
  (define-key puni-mode-map (kbd "M-{") 'puni-barf-backward)
  (define-key puni-mode-map (kbd "M-^") 'puni-splice)
  (define-key puni-mode-map (kbd "M-\"") 'puni-split)
  (define-key puni-mode-map (kbd "M-?") 'puni-raise)
  )

(setq scroll-conservatively 101)  ;; move minimum 1 line when cursor exits view, instead of recentering
(setq scroll-margin 8)  ;; start scrolling when within 3 lines of top/bottom

(use-package vertico
  :config (vertico-mode)
  :elpaca  (:defaults "extensions/*"))

(use-package avy
  :config
  (global-set-key (kbd "M-j") 'avy-goto-char-timer))

(use-package consult)

(use-package orderless
  :custom (completion-styles '(orderless)))

(use-package projectile
  :after vertico
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-opera t))

  ;; Corrects (and improves) org-mode's native fontification.
  ;; (doom-themes-org-config))

(use-package solaire-mode
  :demand t
  :init
  (solaire-global-mode +1))

(use-package ace-window
  :config
  ;;(setq aw-dispatch-always t)
  (global-set-key (kbd "M-o") 'ace-window)
  (setq aw-dispatch-alist
	'((?x aw-delete-window "Delete Window")
	  (?m aw-swap-window "Swap Windows")
	  (?M aw-move-window "Move Window")
	  (?c aw-copy-window "Copy Window")
	  (?j aw-switch-buffer-in-window "Select Buffer")
	  (?n aw-flip-window)
	  (?u aw-switch-buffer-other-window "Switch Buffer Other Window")
	  (?c aw-split-window-fair "Split Fair Window")
	  (?v aw-split-window-vert "Split Vert Window")
	  (?b aw-split-window-horz "Split Horz Window")
	  (?o delete-other-windows "Delete Other Windows")
	  (?? aw-show-dispatch-help))
        aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(defun avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

(with-eval-after-load 'avy
  (setf (alist-get ?. avy-dispatch-alist) 'avy-action-embark))

(setq visible-bell nil)

(setq ring-bell-function 'ignore)

(use-package rg
  :config
  (global-set-key (kbd "C-c r") 'rg-menu))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package fzf
  :bind
    ;; Don't forget to set keybinds!
  :config
  (setq fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; command used for `fzf-grep-*` functions
        ;; example usage for ripgrep:
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "grep -nrH"
        ;; If nil, the fzf buffer will appear at the top of the window
        fzf/position-bottom t
        fzf/window-height 15))

(use-package
  copilot :elpaca
  (:host github
	 :repo "zerolfx/copilot.el" :files ("dist" "*.el"))
  :ensure t
  :hook (prog-mode . copilot-mode)
  :config
  (with-eval-after-load 'copilot
    (global-unset-key (kbd "C-t"))
    (define-key copilot-completion-map (kbd "C-t") 'copilot-accept-completion)
    (define-key copilot-completion-map (kbd "C-S-t") 'copilot-accept-completion-by-word)))

(use-package which-key
  :config
  (which-key-mode))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package envrc
  :config
  (envrc-global-mode))

(use-package magit
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (defun my-treemacs-font-config ()
    (set-face-attribute 'treemacs-file-face nil :family "Roboto Condensed" :weight 'normal :height 110)
    (set-face-attribute 'treemacs-directory-face nil :family "Roboto Condensed" :weight 'semi-bold :height 110)
    (set-face-attribute 'treemacs-root-face nil :family "Roboto Condensed" :weight 'semi-bold :height 120))
  (add-hook 'treemacs-mode-hook 'my-treemacs-font-config)
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-perspective ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after (treemacs perspective) ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package perspective
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-z"))  ; pick your own prefix key here
  :init
  (persp-mode))

(elpaca
 (eat :type git
       :host codeberg
       :repo "akib/emacs-eat"
       :files ("*.el" ("term" "term/*.el") "*.texi"
               "*.ti" ("terminfo/e" "terminfo/e/*")
               ("terminfo/65" "terminfo/65/*")
               ("integration" "integration/*")
               (:exclude ".dir-locals.el" "*-tests.el"))))

(use-package nix-mode
  :mode "\\.nix\\'")

(add-to-list 'display-buffer-alist
             '("\\*Buffer List\\*" . (display-buffer-same-window)))

(use-package haskell-mode
  :config
  (add-to-list 'display-buffer-alist
             '("\\*haskell\\*"
               (display-buffer-reuse-window
                display-buffer-in-side-window)
               (side . bottom)
               (reusable-frames . visible)
               (window-height . 0.3))))

(use-package lsp-haskell)

(add-hook 'pdf-view-mode-hook (lambda ()
                                (pdf-view-midnight-minor-mode)))

(defun get-doom-theme-color (key)
  (caddr (assoc key doom-themes--colors)))

(use-package org
  :bind
  ("C-M-<return>" . org-insert-subheading)
  :config
  (setq org-blank-before-new-entry '((heading . 1) (plain-list-item . nil))))

(use-package org-modern
  :config
  (setq org-modern-star nil)
  (setq org-modern-hide-stars t)
  :hook (org-mode . org-modern-mode))

(use-package writeroom-mode
  :config
  (setq writeroom-width 100)
  (setq writeroom-major-modes '(org-mode))
  (setq writeroom-extra-line-spacing 4)
  :hook (org-mode . writeroom-mode))

(setq org-directory "~/Documents/notes/")
(setq org-default-notes-file (concat org-directory "/inbox.org"))

(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Documents/notes/inbox.org" "Tasks")
         "* TODO %?\n  %u\n  %a")
        ("n" "Note" entry (file+headline "~/Documents/notes/inbox.org" "Notes")
         "* %? :NOTE:\n  %u\n  %a")))

(setq org-agenda-files (directory-files-recursively "~/Documents/notes/" "\\.org$"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(i)" "|" "DONE(d)" "CANCELED(c)")))

(setq org-tag-alist '(("@work" . ?w) ("@home" . ?h) ("emacs" . ?e)))

(setq org-refile-targets '((nil :maxlevel . 3)
                           (org-agenda-files :maxlevel . 3)))

(defun my-custom-backspace ()
  "Delete the last path component if in a file prompt; otherwise, delete a character backward."
  (interactive)
  (if (and minibuffer-completing-file-name
           (string-match-p "/.+$" (minibuffer-contents)))
      (let ((new-path (file-name-directory (directory-file-name (minibuffer-contents)))))
        (delete-minibuffer-contents)
        (insert new-path))
    (call-interactively 'backward-delete-char)))

(define-key minibuffer-local-map (kbd "DEL") 'my-custom-backspace)

(use-package dirvish
  :config
  (dirvish-override-dired-mode))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs `(elixir-mode . ("/etc/profiles/per-user/tomek/bin/elixir-ls")))
  (add-to-list 'eglot-server-programs `(clojure-mode . ("/etc/profiles/per-user/tomek/bin/clojure-lsp")))
  (add-to-list 'eglot-server-programs `(rust-mode . ("/etc/profiles/per-user/tomek/bin/rust-analyzer")))
	(add-to-list 'eglot-server-programs `(scala-mode . ("/home/tomek/.local/share/coursier/bin/metals")))
  (setq eglot-confirm-server-initiated-edits nil))

(add-hook 'prog-mode-hook 'eglot-ensure)

(use-package corfu
  :elpaca (:files (:defaults "extensions/*"))
  :ensure t
  :custom
  (corfu-preselect 'prompt)
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
	("S-TAB" . corfu-previous))
  :config
  ;; Enable auto completion and configure quitting
  (load-file "~/.emacs.d/elpaca/builds/corfu/extensions/corfu-history.el")
  (load-file "~/.emacs.d/elpaca/builds/corfu/extensions/corfu-popupinfo.el")
  (setq completion-category-overrides '((eglot (styles orderless))))
  (setq corfu-auto t
	corfu-quit-no-match 'separator
	corfu-auto-delay 0.4
	corfu-auto-prefix 3) ;; or t
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)) ;; Enable Corfu globally

(defun corfu-enable-always-in-minibuffer ()
  "Enable Corfu in the minibuffer if Vertico/Mct are not active."
  (unless (or (bound-and-true-p mct--active) ; Useful if I ever use MCT
              (bound-and-true-p vertico--input))
    (setq-local corfu-auto nil)       ; Ensure auto completion is disabled
    (corfu-mode 1)))

(add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets)

(use-package cider)

(use-package clojure-mode)

(fringe-mode -1)

;; change flymake underline colors to something less intrusive
(with-eval-after-load 'flycheck
  (set-face-attribute 'flycheck-error nil :underline '(:color "#dd8844" :style wave))
  (set-face-attribute 'flycheck-warning nil :underline '(:color "#979797" :style wave))
  (set-face-attribute 'flycheck-info nil :underline '(:color "#A2BF8A" :style wave)))

(use-package kind-icon
  :ensure t
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default) ; to compute blended backgrounds correctly
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package cape
  :bind (("C-c c p" . completion-at-point) ;; capf
         ("C-c c t" . complete-tag)        ;; etags
         ("C-c c d" . cape-dabbrev)        ;; or dabbrev-completion
         ("C-c c h" . cape-history)
         ("C-c c f" . cape-file)
         ("C-c c k" . cape-keyword)
         ("C-c c s" . cape-elisp-symbol)
         ("C-c c e" . cape-elisp-block)
         ("C-c c a" . cape-abbrev)
         ("C-c c l" . cape-line)
         ("C-c c w" . cape-dict)
         ("C-c c \\" . cape-tex)
         ("C-c c _" . cape-tex)
         ("C-c c ^" . cape-tex)
         ("C-c c &" . cape-sgml)
         ("C-c c r" . cape-rfc1345))
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  ;; (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  ;; (add-to-list 'completion-at-point-functions #'cape-file)
  ;; (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;; (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  ;; (add-to-list 'completion-at-point-functions #'cape-keyword) 
  ;;(add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  :hook
  (eglot-managed-mode . (lambda ()
                          (setq-local completion-at-point-functions
                                      (list (cape-super-capf
                                             #'eglot-completion-at-point
                                             #'cape-file)))))
  )

(use-package helpful
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-h x") #'helpful-command))

;; install hledger-mode and activate it for journal files
(use-package hledger-mode
  :mode "\\.journal\\'"
  :config
  (setq hledger-jfile "~/Documents/finances/2023.journal")
  (setq hledger-currency-string "PLN"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#323334" :foreground "#eceff4" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight semi-bold :height 110 :width normal :foundry "ADBO" :family "Iosevka Nerd Font"))))
 '(ansi-color-italic ((t (:inherit italic :foreground "light gray"))))
 '(eglot-diagnostic-tag-unnecessary-face ((t (:foreground "#8EBCBB" :underline (:color "#979797" :style wave)))))
 '(fixed-pitch ((t (:family "Roboto"))))
 '(org-level-1 ((t (:inherit org-default :height 1.4 :weight bold :foreground "#7AB9CD" :underline t))))
 '(org-level-2 ((t (:inherit org-level-1 :height 0.92 :weight semi-bold :foreground "#97C9D8"))))
 '(org-level-3 ((t (:inherit org-level-2 :height 0.92 :weight normal :foreground "#B5D8E3"))))
 '(org-level-4 ((t (:inherit org-level-3 :height 0.92 :weight normal :foreground "#C9E3EB"))))
 '(org-link ((t (:inherit org-default :foreground "#E1EEF2" :underline t))))
 '(variable-pitch ((t (:family "Roboto Condensed" :height 1.1 :weight normal)))))

(use-package alchemist)

(defun my-custom-set-faces ()
  "Set custom faces depending on the current major mode."
  (if (derived-mode-p 'org-mode)
      (progn
        (make-face 'my-org-mode-default)
        (set-face-attribute 'my-org-mode-default nil
                            :family "Roboto"
                            :height 120
                            :weight 'normal)
        (setq buffer-face-mode-face 'my-org-mode-default)
        (buffer-face-mode))
    (progn
      (make-face 'my-prog-mode-default)
      (set-face-attribute 'my-prog-mode-default nil
                          :family "Iosevka Nerd Font Mono"
                          :height 110
                          :weight 'semi-bold)
      (setq buffer-face-mode-face 'my-prog-mode-default)
      (buffer-face-mode))))

(add-hook 'buffer-list-update-hook 'my-custom-set-faces)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("1a1ac598737d0fcdc4dfab3af3d6f46ab2d5048b8e72bc22f50271fd6d393a00" "2e05569868dc11a52b08926b4c1a27da77580daa9321773d92822f7a639956ce" "c865644bfc16c7a43e847828139b74d1117a6077a845d16e71da38c8413a5aaa" "1cae4424345f7fe5225724301ef1a793e610ae5a4e23c023076dc334a9eb940a" "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" default))
 '(eat-semi-char-non-bound-keys
   '([24]
     [28]
     [17]
     [7]
     [8]
     [27 3]
     [21]
     [27 120]
     [27 58]
     [27 33]
     [27 38]
     [C-insert]
     [M-insert]
     [S-insert]
     [C-M-insert]
     [C-S-insert]
     [M-S-insert]
     [C-M-S-insert]
     [C-delete]
     [M-delete]
     [S-delete]
     [C-M-delete]
     [C-S-delete]
     [M-S-delete]
     [C-M-S-delete]
     [C-deletechar]
     [M-deletechar]
     [S-deletechar]
     [C-M-deletechar]
     [C-S-deletechar]
     [M-S-deletechar]
     [C-M-S-deletechar]
     [C-up]
     [C-down]
     [C-right]
     [C-left]
     [M-up]
     [M-down]
     [M-right]
     [M-left]
     [S-up]
     [S-down]
     [S-right]
     [S-left]
     [C-M-up]
     [C-M-down]
     [C-M-right]
     [C-M-left]
     [C-S-up]
     [C-S-down]
     [C-S-right]
     [C-S-left]
     [M-S-up]
     [M-S-down]
     [M-S-right]
     [M-S-left]
     [C-M-S-up]
     [C-M-S-down]
     [C-M-S-right]
     [C-M-S-left]
     [C-home]
     [M-home]
     [S-home]
     [C-M-home]
     [C-S-home]
     [M-S-home]
     [C-M-S-home]
     [C-end]
     [M-end]
     [S-end]
     [C-M-end]
     [C-S-end]
     [M-S-end]
     [C-M-S-end]
     [C-prior]
     [M-prior]
     [S-prior]
     [C-M-prior]
     [C-S-prior]
     [M-S-prior]
     [C-M-S-prior]
     [C-next]
     [M-next]
     [S-next]
     [C-M-next]
     [C-S-next]
     [M-S-next]
     [C-M-S-next]
     [M-o]))
 '(nerd-icons-scale-factor 1.15)
 '(org-agenda-files
   '("/home/tomek/Documents/notes/projects/fantasizer.org" "/home/tomek/Documents/notes/projects/forest.org" "/home/tomek/Documents/notes/projects/lox.org" "/home/tomek/Documents/notes/projects/portfolio.org" "/home/tomek/Documents/notes/emacs.org" "/home/tomek/Documents/notes/inbox.org" "/home/tomek/Documents/notes/music.org" "/home/tomek/Documents/notes/test.org") t)
 '(package-selected-packages
   '(dhall-mode eglot org-superstar marginalia kind-icon embark-consult eat corfu)))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :config
  (nerd-icons-completion-mode))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package treemacs-nerd-icons
  :config
  (treemacs-load-theme "nerd-icons"))

(define-abbrev-table 'purescript-mode-abbrev-table
  '(("forall" "∀" nil 0)))

(add-hook 'purescript-mode-hook #'abbrev-mode)

(use-package purescript-mode
  :hook
  (purescript-mode . turn-on-purescript-indentation)
  (purescript-mode . turn-on-purescript-font-lock))

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

(use-package dhall-mode
  :ensure t
  :mode "\\.dhall\\'")

(use-package lean4-mode
  :elpaca (lean4-mode
	     :type git
	     :host github
	     :repo "leanprover/lean4-mode"
	     :files ("*.el" "data"))
  ;; to defer loading the package until required
  :commands (lean4-mode))

(use-package dumb-jump
  :config
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read)
  (setq dumb-jump-prefer-searcher 'rg)
  :hook
  (xref-backend-functions . dumb-jump-xref-activate))

(use-package denote)

(use-package ess)

(use-package ess-view-data)

(use-package multiple-cursors
  :config
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
		 (haskell "https://github.com/tree-sitter/tree-sitter-haskell")
		 (yaml "https://github.com/ikatyang/tree-sitter-yaml")
		 (nix "https://github.com/nix-community/tree-sitter-nix")
		 (zig "https://github.com/maxxnino/tree-sitter-zig")
		 (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
		 (scala "https://github.com/tree-sitter/tree-sitter-scala")
		 (purescript "https://github.com/postsolar/tree-sitter-purescript")))

(use-package rustic)

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package sly)

(use-package sly-asdf)

(use-package sly-quicklisp)

(use-package geiser-racket)

(use-package scala-mode
  :interpreter ("scala" . scala-mode))

(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false")))
