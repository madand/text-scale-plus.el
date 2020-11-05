<a href="https://github.com/madand/text-scale+.el"><img src="https://www.gnu.org/software/emacs/images/emacs.png" alt="Emacs Logo" width="80" height="80" align="right"></a>
## text-scale+.el
*Hot-patch text-scale-mode with multi-face support*

---
[![License GPLv3](https://img.shields.io/badge/license-GPL_v3-green.svg)](http://www.gnu.org/licenses/gpl-3.0.html)

`text-scale+` hot-patches `text-scale-mode` with support for adjusting
the font size of multiple faces at once.

The vanilla Emacs' `text-scale-mode` only adjusts the `default` face. So when
you use `text-scale-mode` in a buffer that happens to contain some text
fragments displayed with non-`default` face (e.g. `variable-pitch`), you'll
notice that their font size won't change. Things become ugly if you happen to
use `eww` (the Emacs' built-in web browser) with proportional fonts rendering
enabled (the default) — the entire EWW buffer just won't scale at all.

`text-scale+` solves the aforementioned issue of the current
`text-scale-mode` implementation by hot-patching. Hot-patching in this case
means that after you have loaded this package, `text-scale-mode` will be
"fixed" completely transparently to you. All your keybindings and custom
settings (e.g. `text-scale-mode-step`) will work the same as before.

### Installation


### Manual installation

Download the file `text-scale+.el` from this repo and put it somewhere in
your `load-path`.

```shell
# Download the latest version of the package
mkdir -p ~/path/to/text-scale+
cd ~/path/to/text-scale+
wget -q 'https://github.com/madand/text-scale+.el/raw/master/text-scale+.el'

# Or clone the whole repo with Git
git clone 'https://github.com/madand/text-scale+.el.git' ~/path/to/text-scale+
```

Now update the load path in your `init.el`:

```elisp
(add-to-load-path (expand-file-name "~/path/to/text-scale+"))
```

### Installation from MELPA

Not yet there.

### Loading

Add one of the follwing to your `init.el`.

#### With `require`

```elisp
(with-eval-after-load 'face-remap
  (require 'text-scale+))
```

#### With `use-package`

```elisp
(use-package text-scale+
  :after face-remap
```

### Configuration


### Variable `text-scale+-faces-list`

**Default**: `(default fixed-pitch fixed-pitch-serif variable-pitch)`

List of the faces to be adjusted by the `text-scale-mode`.

Customize: `M-x customize-variable RET text-scale+-faces-list RET`.

Examples with elisp:
```elisp
;; Change the global value
(setq text-scale+-faces-list '(default fixed-pitch))

;; Change the value only in `custom-mode` buffers
(add-hook 'custom-mode-hook
           (lambda ()
             (setq-local text-scale+-faces-list '(default))))
```

### Function Documentation


#### `(text-scale+-install)`

Patch the `text-scale-mode` with multi-face support.

This functions will be called automatically once you've loaded
the `text-scale+` package.

#### `(text-scale+-uninstall)`

Un-patch the `text-scale-mode`.

Revert all changes applied by `text-scale+-install`.

-----
<div style="padding-top:15px;color: #d0d0d0;">
Markdown README file generated by
<a href="https://github.com/mgalgs/make-readme-markdown">make-readme-markdown.el</a>
</div>