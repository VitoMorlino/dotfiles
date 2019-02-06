;; NOTE_TO_SELF ;;
;; ----------------------------------------------------------------------------
;; As of Emacs 25.1, there's a new variable called package-selected-packages.
;; This variable keeps track of all packages explicitely installed.
;; Explicitely installed = not including packages installed from dependencies
;;
;; This is useful because the command package-install-selected-packages will
;; install all packages listed within the variable package-selected-packages
;;
;; It will be beneficial to let the contents of this variable be automatically
;; generated because it will automatically update when a new package is
;; explicitely installed
;;
;; NOTECEPTION: Maybe there's a way, that I don't know yet, to put this
;; variable somewhere manually, but still have it update automatically
;; when a new package is explicitely installed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (org-bullets smex ido-vertical-mode use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
