;;; text-scale+.el --- Hot-patch text-scale-mode with multi-face support  -*- lexical-binding: t -*-

;; Copyright (C) 2020 Andriy B. Kmit'

;; Author: Andriy B. Kmit' <dev@madand.net>
;; Keywords: faces, text scale, display, user commands
;; URL: https://github.com/madand/text-scale+.el
;; Package-Requires: ((emacs "24.4"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; `text-scale+' hot-patches `text-scale-mode' with support for adjusting
;; the font size of multiple faces at once.

;; The vanilla Emacs' `text-scale-mode' only adjusts the `default' face. So when
;; you use `text-scale-mode' in a buffer that happens to contain some text
;; fragments displayed with non-`default' face (e.g. `variable-pitch'), you'll
;; notice that their font size won't change. Things become ugly if you happen to
;; use `eww' (the Emacs' built-in web browser) with proportional fonts rendering
;; enabled (the default) — the entire EWW buffer just won't scale at all.

;; `text-scale+' solves the aforementioned issue of the current
;; `text-scale-mode' implementation by hot-patching. Hot-patching in this case
;; means that after you have loaded this package, `text-scale-mode' will be
;; "fixed" completely transparently to you. All your keybindings and custom
;; settings (e.g. `text-scale-mode-step') will work the same as before.

;;; Installation

;; ### Manual installation

;; Download the file `text-scale+.el` from this repo and put it somewhere in
;; your `load-path'.

;; ```shell
;; # Download the latest version of the package
;; mkdir -p ~/path/to/text-scale+
;; cd ~/path/to/text-scale+
;; wget -q 'https://github.com/madand/text-scale+.el/raw/master/text-scale+.el'

;; # Or clone the whole repo with Git
;; git clone 'https://github.com/madand/text-scale+.el.git' ~/path/to/text-scale+
```

;; Now update the load path in your `init.el':

;; ```elisp
;; (add-to-load-path (expand-file-name "~/path/to/text-scale+"))
;; ```

;; ### Installation from MELPA

;; Not yet there.

;; ### Loading

;; Add one of the follwing to your `init.el'.

;; #### With `require'

;; ```elisp
;; (with-eval-after-load 'face-remap
;;   (require 'text-scale+))
;; ```

;; #### With `use-package'

;; ```elisp
;; (use-package text-scale+
;;   :after face-remap
;; ```

;;; Configuration

;; ### Variable `text-scale+-faces-list'

;; **Default**: `(default fixed-pitch fixed-pitch-serif variable-pitch)`

;; List of the faces to be adjusted by the `text-scale-mode'.

;; Customize: `M-x customize-variable RET text-scale+-faces-list RET`.

;; Examples with elisp:
;; ```elisp
;; ;; Change the global value
;; (setq text-scale+-faces-list '(default fixed-pitch))
;;
;; ;; Change the value only in `custom-mode' buffers
;; (add-hook 'custom-mode-hook
;;            (lambda ()
;;              (setq-local text-scale+-faces-list '(default))))
;; ```

;;; Code:

;; This is needed to prevent the "error: void variable text-scale+-faces-list".
(eval-when-compile
  (require 'custom))

(defcustom text-scale+-faces-list '(default fixed-pitch fixed-pitch-serif
                                     variable-pitch)
  "List of faces to be adjusted by the `text-scale-mode'.

This variable is only taken into account if the overrides by
`text-scale+' are in effect. See `text-scale+-install'."
  :type '(repeat face)
  :group 'display)

;; List of remapping cookies for handled faces
(defvar text-scale+--remappings '())
(make-variable-buffer-local 'text-scale+--remappings)

;; Silence the byte compiler
(defvar text-scale-mode)
(defvar text-scale-mode-amount)
(defvar text-scale-mode-lighter)
(defvar text-scale-mode-step)
(defvar text-scale-mode-hook)
(declare-function face-remap-remove-relative "face-remap" (cookie))
(declare-function text-scale-max-amount "face-remap" ())
(declare-function text-scale-min-amount "face-remap" ())

(define-minor-mode text-scale+--text-scale-mode
  "Minor mode for enhancing the `text-scale-mode' behavior.

You SHOULD NOT use this mode directly. Instead, call the command
`text-scale+-install' in order to augment the `text-scale-mode'
behavior.

This mode makes multiple faces' font size adjustable with
`text-scale-mode'. See `text-scale+-faces-list'."
  :lighter (" " text-scale-mode-lighter)
  :require 'face-remap
  :variable text-scale-mode
  (when text-scale+--remappings
    (dolist (remapping text-scale+--remappings)
      (face-remap-remove-relative remapping))
    (setq text-scale+--remappings '()))
  (setq text-scale-mode-lighter
	      (format (if (>= text-scale-mode-amount 0) "+%d" "%d")
		            text-scale-mode-amount))
  (when text-scale-mode
    (dolist (face text-scale+-faces-list)
      (push (face-remap-add-relative face
					                           :height (expt text-scale-mode-step
						                                       text-scale-mode-amount))
            text-scale+--remappings)))
  (force-window-update (current-buffer)))

(defun text-scale+--run-text-scale-mode-hooks ()
  "Run hooks from `text-scale-mode-hook'."
  (run-hooks text-scale-mode-hook))

;;;###autoload
(defun text-scale+-install ()
  "Patch the `text-scale-mode' with multi-face support.

This functions will be called automatically once you've loaded
the `text-scale+' package."
  (interactive)
  (add-hook 'text-scale+--text-scale-mode-hook
            #'text-scale+--run-text-scale-mode-hooks)
  (advice-add 'text-scale-mode :override #'text-scale+--text-scale-mode))

;;;###autoload
(defun text-scale+-uninstall ()
  "Un-patch the `text-scale-mode'.

Revert all changes applied by `text-scale+-install'."
  (interactive)
  (remove-hook 'text-scale+--text-scale-mode-hook
               #'text-scale+--run-text-scale-mode-hooks)
  (advice-remove 'text-scale-mode #'text-scale+--text-scale-mode))

(defun text-scale+-unload-function ()
  (text-scale+-uninstall)
  (unintern 'text-scale+--text-scale-mode-hook nil)
  (unintern 'text-scale+--remappings nil))

;; Path the `text-scale-mode' immediately after we loaded.
(text-scale+-install)

(provide 'text-scale+)

;;; text-scale+.el ends here
