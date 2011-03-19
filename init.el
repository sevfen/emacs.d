(server-start)
;;Done at start to load faster
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;------------------------------------------------
;;== LOAD PATH AND AUTOLOADS
;;------------------------------------------------
;;*****ELPA****
;;early in .emacs to be able to use plugins later down
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))
;;Add the original Emacs Lisp Package Archive
(add-to-list 'package-archives '("elpa" . "http://tromey.com/elpa/"))
;;Add the user-contributed repository
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("sunrise-commander" . "http://joseito.republika.pl/sunrise-commander/"))

(add-to-list 'load-path "~/.emacs.d/elisp/org-mode/lisp/")
(add-to-list 'load-path "~/.emacs.d/elisp/org-mode/contrib/lisp/")

(require 'ido)
(require 'tramp)
(require 'color-theme)
(require 'org)
;(require 'starter-kit-defuns)
(require 'org-protocol)
(require 'org-install)
(require 'org-habit)
(require 'easymenu) ;for ERC

;;------------------------------------------------
;== INIT & CONFIG
;;------------------------------------------------
;(autoload 'php-mode "php-mode" "Major mode for editing php code." t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))

;; We never want to edit Rubinius bytecode
(add-to-list 'completion-ignored-extensions ".rbc")

(ido-mode 'both) ; User ido mode for both buffers and files
(recentf-mode 1)
;(iswitchb-mode 1)
(setq backup-directory-alist (list (cons ".*" (expand-file-name "~/bak/emacs/")))) ; Temp files
(setq x-select-enable-clipboard t) ; Integrate with X11s clipboard
(setq-default indent-tabs-mode nil) ; Dont indent with tabs
(setq c-basic-offset 3) ; Indenting is 3 spaces
;(set-language-environment "UTF-8");"Latin-1") ; Default would be utf8
(setq browse-url-browser-function 'browse-url-generic browse-url-generic-program "/usr/bin/conkeror")

(load "~/.emacs.d/colors/color-theme-wombat")
(color-theme-wombat)
;(load "~/.emacs.d/colors/zenburn")
;(color-theme-zenburn)
(global-font-lock-mode 1) ;; Enable syntax highlighting when editing code.
(show-paren-mode 1) ; Highlight the matching paren
;(tool-bar-mode -1) ; Remove bloat
;(menu-bar-mode -1) ; --- || ---
;(scroll-bar-mode -1)
(setq transient-mark-mode t) ; Highlight selected regions
;(setq visible-bell t) ; Flash program border on beep
(setq inhibit-startup-screen t) ; Dont load the about screen on load
(setq scroll-step 1) ; Only scroll down 1 line at a time
;(setq font-use-system-font t)
(fset 'yes-or-no-p 'y-or-n-p)
(column-number-mode t) ; Show cursors X + Y coordinates in modeline
(display-time-mode t)
(display-battery-mode t)
(setq scroll-conservatively 10) ; make scroll less jumpy
(setq scroll-margin 7) ; scroll will start b4 getting to top/bottom of page

;(put 'narrow-to-page 'disabled nil)
;(put 'narrow-to-region 'disabled nil)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(ido-create-new-buffer (quote always))
  '(speedbar-hide-button-brackets-flag t)
 '(speedbar-indentation-width 2)
 '(speedbar-show-unknown-files t)
 '(speedbar-update-flag nil t)
 '(speedbar-use-images nil)
 )
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "unknown" :family "Droid Sans Mono"))))
 '(org-upcoming-deadline ((t (:foreground "yellow"))))
 '(sr-directory-face ((t (:foreground "yellow" :weight bold))))
 '(sr-symlink-directory-face ((t (:foreground "yellow4" :slant italic)))))



;;------------------------------------------------
;;== Custom Functions
;;------------------------------------------------
(defmacro bind (key fn)
  "shortcut for global-set-key"
  `(global-set-key (kbd ,key)
                   ;; handle unquoted function names and lambdas
                   ,(if (listp fn)
                        fn 
                      `',fn)))

(defmacro cmd (name &rest body)
  "declare an interactive command without all the boilerplate"
  `(defun ,name ()
     ,(if (stringp (car body)) (car body))
     ;; tried (let (documented (stringp (first body))) but didn't know gensym
     ;; and couldn't get it to work. should be possible
     (interactive)
     ,@(if (stringp (car body)) (cdr `,body) body)))

(cmd scroll-down-keep-cursor
  "Scroll the text one line down while keeping the cursor"
  (scroll-down 1))

(cmd scroll-up-keep-cursor
  "Scroll the text one line up while keeping the cursor"
  (scroll-up 1))

(cmd isearch-other-window
     ;; thank you leo2007!
     (save-selected-window
       (other-window 1)
       (isearch-forward)))

(cmd comment-or-uncomment-current-line-or-region
  "Comments or uncomments current current line or whole lines in region."
  (save-excursion
    (let (min max)
      (if (and transient-mark-mode mark-active)
          (setq min (region-beginning) max (region-end))
        (setq min (point) max (point)))
      (comment-or-uncomment-region
       (progn (goto-char min) (line-beginning-position))
       (progn (goto-char max) (line-end-position))))))

(cmd xsteve-ido-choose-from-recentf
  "Use ido to select a recently opened file from the `recentf-list'"
  (let ((home (expand-file-name (getenv "HOME"))))
    (find-file
     (ido-completing-read "Recentf open: "
                          (mapcar (lambda (path)
                                    (replace-regexp-in-string home "~" path))
                                  recentf-list)
                          nil t))))

(defun org-gcal-sync ()
  "Export org to ics to be uploaded to Google Calendar and import
an .ics file that has been downloaded from Google Calendar "
  (org-export-icalendar-combine-agenda-files)
  (icalendar-import-file "~/tmp/.basic.ics" "~/tmp/.gcal"))

    (defun ido-goto-symbol (&optional symbol-list)
      ;;http://www.emacswiki.org/cgi-bin/wiki/ImenuMode#toc10
      "Refresh imenu and jump to a place in the buffer using Ido."
      (interactive)
      (unless (featurep 'imenu)
        (require 'imenu nil t))
      (cond
       ((not symbol-list)
        (let ((ido-mode ido-mode)
              (ido-enable-flex-matching
               (if (boundp 'ido-enable-flex-matching)
                   ido-enable-flex-matching t))
              name-and-pos symbol-names position)
          (unless ido-mode
            (ido-mode 1)
            (setq ido-enable-flex-matching t))
          (while (progn
                   (imenu--cleanup)
                   (setq imenu--index-alist nil)
                   (ido-goto-symbol (imenu--make-index-alist))
                   (setq selected-symbol
                         (ido-completing-read "Symbol? " symbol-names))
                   (string= (car imenu--rescan-item) selected-symbol)))
          (unless (and (boundp 'mark-active) mark-active)
            (push-mark nil t nil))
          (setq position (cdr (assoc selected-symbol name-and-pos)))
          (cond
           ((overlayp position)
            (goto-char (overlay-start position)))
           (t
            (goto-char position)))))
       ((listp symbol-list)
        (dolist (symbol symbol-list)
          (let (name position)
            (cond
             ((and (listp symbol) (imenu--subalist-p symbol))
              (ido-goto-symbol symbol))
             ((listp symbol)
              (setq name (car symbol))
              (setq position (cdr symbol)))
             ((stringp symbol)
              (setq name symbol)
              (setq position
                    (get-text-property 1 'org-imenu-marker symbol))))
            (unless (or (null position) (null name)
                        (string= (car imenu--rescan-item) name))
              (add-to-list 'symbol-names name)
              (add-to-list 'name-and-pos (cons name position))))))))

(cmd indent-whole-buffer ()
  "indent whole buffer"
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))
(defalias 'iwb 'indent-whole-buffer)

(defun add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(defun toggle-fullscreen ()
  (interactive)
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0))
)

 (defun switch-full-screen (&optional ii)
   (interactive "p")
  (if (> ii 0)
      (shell-command "wmctrl -r :ACTIVE: -badd,fullscreen"))
  (if (< ii 0)
      (shell-command "wmctrl -r :ACTIVE: -bremove,fullscreen"))
  (if (equal ii 0)
      (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen")))

(defun switch-full-screen-toggle ()
(interactive)
(set-frame-parameter nil 'fullscreen
(if (frame-parameter nil 'fullscreen) nil 'fullboth)))

  (defun darkroom-mode ()
	"Make things simple-looking by removing decoration 
	 and choosing a simple theme."
        (interactive)
        (switch-full-screen 1)     ;; requires above function 
	;;(color-theme-retro-green)  ;; requires color-theme
        (setq left-margin 30)
        (setq fill-column 100)
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (transient-mark-mode 1)
        (move-to-left-margin 0 1)
        (auto-fill-mode)
        (setq text-mode-hook 'darkroom-mode))


 (defun darkroom-mode-reset ()
   (interactive)
   (switch-full-screen -1)
   ;;(color-theme-subtle-hacker) ;; Choose your favorite theme
   (menu-bar-mode 1)
   (tool-bar-mode 1)
   (scroll-bar-mode 1)
   (auto-fill-mode 0)
   (setq left-margin 0))

(defun write-room ()
  "Make a frame without any bling."
  (interactive)
  ;; to restore:
  ;; (setq mode-line-format (default-value 'mode-line-format))
  (let ((frame (make-frame '((minibuffer . nil)
			     (vertical-scroll-bars . nil)
			     (left-fringe . 0); no fringe
			     (right-fringe . 0)
			     (background-mode . dark)
			     (background-color . "black")
			     (foreground-color . "green")
			     (cursor-color . "green")
			     (border-width . 0)
			     (border-color . "black"); should be unnecessary
			     (internal-border-width . 64); whitespace!
			     (cursor-type . box)
			     (menu-bar-lines . 0)
			     (tool-bar-lines . 0)
;			     (mode-line-format . nil) ; dream on... has no effect
			     (fullscreen . fullboth)  ; this should work
			     (unsplittable . t)))))
    (select-frame frame)
    (find-file "~/emacs.d/NOTES")
    (setq mode-line-format nil); is buffer local unfortunately
    ;; maximize window if fullscreen above had no effect
    (when (fboundp 'w32-send-sys-command)
      (w32-send-sys-command 61488 frame))))

    (defun run-theater (command)
      "Open an Emacs frame with nothing other than the executed command."
      (interactive "CEnter command: ")
      (select-frame (new-frame '((width . 72) (height . 20)
                                 (menu-bar-lines . 0)
                                 (minibuffer . nil)
                                 (toolbar . nil))))
      (setq-default mode-line-format nil)
      (call-interactively command))

(defun gnome-open-file (filename)
  "gnome-opens the specified file."
  (interactive "fFile to open: ")
  (let ((process-connection-type nil))
    (start-process "" nil "/usr/bin/gnome-open" filename)))

;;------------------------------------------------
;;==Plugins
;;------------------------------------------------

;;*****Dired & Tramp*****
(setq tramp-default-method "ssh")
(add-hook 'dired-mode-hook (lambda () (local-set-key "E" 'dired-gnome-open-file)))

(defun dired-gnome-open-file ()
  "Opens the current file in a Dired buffer."
  (interactive)
  (gnome-open-file (dired-get-file-for-visit)))

;;*****ORG-MODE*****
;;Checkout the latest version of org mode, if I don't already have it.
(unless (file-exists-p "~/.emacs.d/elisp/org-mode/")
  (let ((default-directory "~/.emacs.d/elisp/"))
    (shell-command "git clone git://repo.or.cz/org-mode.git")
    (shell-command "make -C org-mode/")
    (normal-top-level-add-subdirs-to-load-path)))

(defun planner ()
    (interactive)
    (find-file "~/Dropbox/doc/planner.org")
)
(defun journal()
    (interactive)
    (find-file "~/Dropbox/doc/journal.org")
)

(setq org-habit-graph-column 60)
(setq org-log-done 'time)
(setq org-agenda-include-diary nil)
(setq org-deadline-warning-days 14)
(setq org-timeline-show-empty-dates t)
(setq org-insert-mode-line-in-empty-file t)
(setq org-clock-into-drawer t)
(setq org-show-notifications t)
(setq org-timer-default-timer 25)
(setq org-agenda-files (quote ("~/Dropbox/doc/planner.org")))
(setq org-agenda-ndays 7)
(setq org-agenda-restore-windows-after-quit t)
(setq org-agenda-show-all-dates t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-sorting-strategy (quote ((agenda time-up priority-down tag-up) (todo tag-up))))
(setq org-agenda-start-on-weekday nil)
(setq org-agenda-todo-ignore-deadlinens t)
(setq org-agenda-todo-ignore-scheduled t)
(setq org-agenda-todo-ignore-with-date t)
(setq org-deadline-warning-days 14)
(setq org-export-html-style "<link rel=\"stylesheet\" type=\"text/css\" href=\"mystyles.css\">")
(setq org-fast-tag-selection-single-key nil)
(setq org-log-done (quote (done)))
(setq org-reverse-note-order t)
(setq org-tags-column -78)
(setq org-tags-match-list-sublevels nil)
;(setq org-time-stamp-rounding-minutes 5)
(setq org-use-fast-todo-selection t)
(setq org-use-tag-inheritance nil)
(setq org-fontify-done-headline t) ;;newly added
;; Show all future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all t)
;; Resume clocking tasks when emacs is restarted
(setq org-clock-persistence-insinuate)
;; Yes it's long... but more is better ;)
(setq org-clock-history-length 35)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task state to STARTED when clocking in
(setq org-clock-in-switch-to-state "STARTED")
;; Save clock data and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes
;; clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Don't clock out when moving task to a done state
;(setq org-clock-out-when-done nil)
;; Save the running clock and all clock history when exiting Emacs,
;; load it on startup
(setq org-clock-persist t)
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK" "CLOCK")))
;; Save clock data in the CLOCK drawer and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer "CLOCK")
(setq org-log-into-drawer t)



;; Custom keywords
(setq org-todo-keyword-faces
      '(("TODO"  . (:foreground "red" :weight bold))
        ("STARTED" :foreground "blue" :weight bold)
        ("GOAL"  . (:foreground "purple" :weight bold))
        ("WAITING"  . (:foreground "orange" :weight bold))
        ("DELEGATED"  . (:foreground "orange" :weight bold))
        ("SOMEDAY"  . (:foreground "orange" :weight bold))
        ("ONGOING"  . (:foreground "orange" :weight bold))
        ("DONE"  . (:foreground "forest green" :weight bold))
        ("DISMISSED"  . (:foreground "forest green" :weight bold))
        ("CANCELLED"  . (:foreground "forest green" :weight bold))
))

(setq org-agenda-custom-commands'(
;("P" "Projects" 
 ;    ((tags "PROJECT")))

("H" "Office and Home Lists"
     ((agenda)
          (tags-todo "OFFICE")
          (tags-todo "HOME")
          (tags-todo "COMPUTER")
          (tags-todo "DVD")
          (tags-todo "READING")))

("d" "Daily Action List"
     ((agenda "" ((org-agenda-ndays 1)
                      (org-agenda-sorting-strategy
                       (quote ((agenda time-up priority-down tag-up) )))
                    ;;  (org-deadline-warning-days 0)
                      ))))

;("c" todo "DONE|DEFERRED|CANCELLED" nil)

;("w" todo "WAITING" nil)

("A" agenda ""
        ((org-agenda-skip-function
          (lambda nil
        (org-agenda-skip-entry-if (quote notregexp) "\\=.*\\[#A\\]")))
         (org-agenda-ndays 1)
         (org-agenda-overriding-header "Today's Priority #A tasks: ")))

("P" "Projects" tags "/!PROJECT" ((org-use-tag-inheritance nil)))
("s" "Started Tasks" todo "STARTED" ((org-agenda-todo-ignore-with-date nil)))
("Q" "Questions" tags "QUESTION" nil)
("w" "Tasks waiting on something" tags "WAITING" ((org-use-tag-inheritance nil)))
("r" "Refile New Notes and Tasks" tags "REFILE" ((org-agenda-todo-ignore-with-date nil)))
("n" "Notes" tags "NOTES" nil)
("c" "Schedule" agenda ""
        ((org-agenda-ndays 7)
         (org-agenda-start-on-weekday 1)
         (org-agenda-time-grid nil)
         (org-agenda-prefix-format " %12:t ")
         (org-agenda-include-all-todo nil)
         (org-agenda-repeating-timekstamp-show-all t)
         (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
("u" "Upcoming deadlines (6 months)" agenda ""
        ((org-agenda-skip-function '(org-agenda-skip-entry-if 'notdeadline))
         (org-agenda-ndays 1)
         (org-agenda-include-all-todo nil)
         (org-deadline-warning-days 180)
         (org-agenda-time-grid nil)))
))

;;*****Capture*****
(setq org-capture-templates
     '(("t" "Todo" entry (file+headline "~/Dropbox/doc/planner.org" "Tasks")
;             "* TODO %?\n----Entered on %U\n  %i")
             "* TODO %?  %i")
        ("j" "Journal" entry (file+datetree "~/Dropbox/doc/journal.org"))
            ; "** %?")
        ("l" "Log Time" entry (file+datetree "~/Dropbox/doc/timelog.org" ) 
             "** %U - %^{Activity}  :TIME:")
        ("r" "Tracker" entry (file+datetree "~/Dropbox/doc/journal.org") 
             "* Tracker \n| Item | Count |
              %?|-+-|
              | Pull||
              | Push||
              | Crunch||
              | Back||\n#+BEGIN: clocktable :maxlevel 5 :scope agenda :block today\n#+END:"
             )
        ("w" "" entry ;; 'w' for 'org-protocol'
         (file+headline "~/Dropbox/doc/www.org" "Notes`")
         "* %^{Title}\n\n  Source: %u, %c\n\n  %i")
        ("m" "movie" entry (file+headline "~/Dropbox/doc/media.org" "Movies")
         "* %? \n----Entered on %U\n  %i")
        ("b" "book" entry (file+headline "~/Dropbox/doc/media.org" "Books")
                 "* %? \n----Entered on %U\n  %i")
        ))
;(setq org-capture-templates
;      (quote (("w" "web note" entry (file+headline "~/org/web.org" "Notes") "* Source: %u, %c\n  %i")
;              ("l" "scriptjure political or economic references" entry (file+headline "~/org/scripture-study.org" "Politics or Economic")
;               "* %c %^{Type|descriptive|prescriptive|other} %U\n  %i\n\n   Notes: %^{Notes}")
;              ("s" "scripture" entry (file+headline "~/org/scripture-study.org" "Notes") "* %c %U\n  %i")
;              ("x" "co template" entry (file+headline "~/org/co.org" "co") "* %c\n" :immediate-finish 1)
;              ("b" "book" entry (file+headline "~/www/org/truth.org" "Notes") "* %U\n  %?")
 ;             ("t" "todo" entry (file+headline "~/org/todo.org" "Tasks") "* TODO %?")
  ;            ("c" "calendar" entry (file+headline "~/org/calendar.org" "Events") "* %?\n  %^t")
   ;           ("p" "phone-calls" entry (file+headline "~/doc/phone-calls.org" "Phone Calls") "* %T %?")
;              ("j" "journal" entry (file+headline "~/doc/personal/journal.org" "Journal") "* %U\n%?")
;              ("m" "music" entry (file+headline "~/org/music.org" "Music to checkout") "* :%^{Field|song|artist|album} %^{Value} :%^{Field|song|artist|album} %^{Value}")
;              ("v" "movie" entry (file+headline "~/org/movies.org" "Movies to see") "* %^{Movie name}")
;              ("n" "note" entry (file+headline "~/org/notes.org" "Notes") "* %U\n  %?")
;              ("f" "food" entry (file+headline "~/org/food.org" "Food") "* %U\n  - %?")
;              ("f" "programming" entry (file+headline "~/org/programming.org" "Questions") "* %U\n  - %?")
;              ("e" "exercise" entry (file+headline "~/org/exercise.org" "Exercise") "* %U\n  - %?")
;              ("o" "other" entry (file+headline "~/remember.org" "") "* %a\n%i"))))


;;*****CALENDAR/DIARY MODE*****
 (setq view-diary-entries-initially t
         mark-diary-entries-in-calendar t
	        number-of-diary-entries 7)
  (add-hook 'diary-display-hook 'fancy-diary-display)
  (add-hook 'today-visible-calendar-hook 'calendar-mark-today)


;;*****ERC STUFF*****
(easy-menu-add-item  nil '("tools") ["IRC with ERC" erc t])

;; joining && autojoing

;; make sure to use wildcards for e.g. freenode as the actual server
;; name can be be a bit different, which would screw up autoconnect
(erc-autojoin-mode t)
(setq erc-autojoin-channels-alist
  '((".*\\.freenode.net" "#emacs" "#conkeror" "#org-mode")))
;     (".*\\.gimp.org" "#gimp" "#gimp-users")))

;; check channels
(erc-track-mode t)
(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"

                                 "324" "329" "332" "333" "353" "477"))
;; don't show any of this
(setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))

(defun djcb-erc-start-or-switch ()
  "Connect to ERC, or switch to last active buffer"
  (interactive)
  (if (get-buffer "irc.freenode.net:6667") ;; ERC already active?

    (erc-track-switch-buffer 1) ;; yes: switch to last active
    (when (y-or-n-p "Start ERC? ") ;; no: maybe start ERC
      (erc :server "irc.freenode.net" :port 6667 :nick "sevfen")
;      (erc :server "irc.gimp.org" :port 6667 :nick "sevfen"))))

;;*****SPEEDBAR*****
;(setq speedbar-use-imenu-flag nil)
;(setq speedbar-fetch-etags-command "/usr/bin/ctags-exuberant")
;(setq speedbar-fetch-etags-arguments '("-e" "-f" "-"))

;;Setup speedbar, an additional frame for viewing source files
(autoload 'speedbar-frame-mode "speedbar" "Popup a speedbar frame" t)
(autoload 'speedbar-get-focus "speedbar" "Jump to speedbar frame" t)
(autoload 'speedbar-toggle-etags "speedbar" "Add argument to etags command" t)
(setq speedbar-frame-plist '(minibuffer nil
                             border-width 0
                             internal-border-width 0
                             menu-bar-lines 0
                             modeline t
                             name "SpeedBar"
                             width 24
                             unsplittable t))


;;------------------------------------------------
;== GLOBAL KEYBINDS
;;------------------------------------------------

;;-----------------------------------------------------------------------------
;; F2: files
;;-----------------------------------------------------------------------------
(defmacro set-key-find-file (key file)
  "Defines a shortcut key to open a file."
  (let ((fname (intern (concat "open-" file))))
    `(progn (defun ,fname () (interactive) (find-file ,file))
            (global-set-key (kbd ,key) ',fname))))

(set-key-find-file "<f2> e" "~/.emacs")
(set-key-find-file "<f2> g" "~/.gnus.el")
(set-key-find-file "<f2> t" "~/org/todo.org")
(set-key-find-file "<f2> n" "~/org/notes.org")
(set-key-find-file "<f2> f" "~/org/feeds.org")
(set-key-find-file "<f2> z" "~/.zshrc")
(set-key-find-file "<f2> b" "~/.xbindkeysrc")
(set-key-find-file "<f2> r" "~/.Xresources")
(set-key-find-file "<f2> m" "~/.Xmodmap")

(global-set-key (kbd "<f2> w") 'webjump)

;;-----------------------------------------------------------------------------
;; F5: Org functions
;;-----------------------------------------------------------------------------
(bind "<f5> a" org-toggle-archive-tag)
(bind "<f5> b" org-ido-switchb)
(bind "<f5> i" org-clock-in)
(bind "<f5> o" org-clock-out)
(bind "<f5> r" org-refile)
(bind "<f5> f" org-occur)
;(bind "<f5> r" org-remember)
(bind "<f5> v" org-archive-subtree)
(bind "<f5> t" my-org-todo)
(bind "<f5> w" widen)
(bind "<f5> u" org-feed-update-all)
;;-----------------------------------------------------------------------------
;; F6: Emacs functions
;;-----------------------------------------------------------------------------
;(bind "<f6> t" 'visit-tags-table)
;(bind "<f6> h" 'jao-toggle-selective-display)
;(bind "<f6> h" 'hs-org/minor-mode)
;(bind "<f6> d" 'color-theme-wombat)
;(bind "<f6> l" 'color-theme-active)
;(bind "<f6> n" 'linum-mode)

;;-----------------------------------------------------------------------------
;; F9: Emacs programs
;;-----------------------------------------------------------------------------
;(bind "<f9> e" eshell)
;(bind "<f9> f" rgrep)
;(bind "<f9> h" (lambda () (interactive) (dired "~")))
;(bind "<f9> c" calendar)
;(bind "<f9> r" org-remember)
;(bind "<f9> g" gnus)
;(bind "<f9> M-g" gnus-unplugged)


;;-----------------------------------------------------------------------------
;; F11:
;;-----------------------------------------------------------------------------

(bind "<M-f11>" recentf-open-files)

;;-----------------------------------------------------------------------------
;; F12: Agenda
;;-----------------------------------------------------------------------------
(bind "<f12>" org-agenda)
(bind "C-<f12>" org-clock-goto)

;;---------------------------------------------------------
;; Random bindings
;;---------------------------------------------------------
(global-set-key (kbd "C-c p") 'planner)
(global-set-key (kbd "C-c j") 'journal)
(global-set-key [f7] 'ansi-term)
(global-set-key [f8] 'org-agenda-clock-cancel)
(global-set-key [f9] 'org-agenda-clock-in)
(global-set-key [f10] 'org-agenda-clock-out)
(global-set-key [f11] 'switch-full-screen-toggle)
(global-set-key [f12]         'org-capture)
(global-set-key (kbd "C-c e") 'djcb-erc-start-or-switch) ;; switch to ERC
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key (kbd "M-n") 'next-buffer)
(global-set-key (kbd "M-p") 'previous-buffer)
(global-set-key (kbd "M-/") 'hippie-expand)
;(global-set-key (kbd "C-z") 'set-mark-command)
;(global-set-key [C-tab] 'other-window)
(global-set-key "\r" 'newline-and-indent)
;(global-set-key (kbd "C-M-p") 'enlarge-window-horizontally)
;(global-set-key (kbd "C-M-o") 'shrink-window-horizontally)
;(global-set-key "\C-xq" 'anything)
(global-set-key "\C-xj" 'join-line)
(global-set-key "\C-xi" 'ido-goto-symbol) ;own func
(global-set-key "\C-xf" 'xsteve-ido-choose-from-recentf)
(global-set-key "\C-xc" 'calendar)
(global-set-key "\C-xt" 'eshell)
(global-set-key "\C-xs" 'flyspell-on)
;(global-set-key "\C-xc" 'search)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
;(global-set-key "\C-cb" 'org-iswitchb)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-x\C-b" 'ibuffer)


(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)

(bind "C-x M-f" find-file-other-window)
(global-set-key "\M-?" 'comment-or-uncomment-current-line-or-region)

(bind "C-M-S" isearch-other-window)
(bind "C-S-p" scroll-down-keep-cursor)
(bind "C-S-n" scroll-up-keep-cursor)