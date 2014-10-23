;;(global-set-key "\M-[1;5D"    'backward-word)     ; Ctrl+left    => backward word
;;(global-set-key "\M-[1;5C"    'forward-word)      ; Ctrl+right   => forward word
;;(global-set-key "\M-[1;10C"   'forward-word)      ; Ctrl+right   => forward word
;;(global-set-key "\M-[1;10D"   'backward-word)      ; Ctrl+right   => forward word
(global-set-key "\M-[1;5B"    'scroll-up)      ; Ctrl+up
(global-set-key "\M-[1;5A"    'scroll-down)      ; Ctrl+up

(global-set-key (kbd "C-f") 'isearch-forward)
(global-set-key (kbd "C-g") 'goto-line)

(add-hook 'isearch-mode-hook
 (lambda ()
 (define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)
 )
)

(cua-mode t)
    (setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
    (transient-mark-mode 1) ;; No region when it is not highlighted
    (setq cua-keep-region-after-copy t) ;; Standard Windows behaviour
(global-unset-key "\C-z") (global-set-key "\C-z" 'advertised-undo)
(global-set-key [C-delete] 'kill-line)      ; KEraseEndLine cDel

(defvar CUA-movement-keys
  '((forward-char (right))
    (backward-char  (left))
    (next-line    (down))
    (previous-line  (up))
    (forward-word (control right))
    (backward-word  (control left))
    (end-of-line  (end))
    (beginning-of-line  (home))
    (end-of-buffer  (control end))
    (beginning-of-buffer (control home))
    (scroll-up    (next))
    (scroll-down  (prior))
    (forward-paragraph  (control down))
    (backward-paragraph (control up))))

