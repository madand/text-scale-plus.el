#!/usr/bin/env sh

# See https://github.com/mgalgs/make-readme-markdown
download_url='https://raw.github.com/mgalgs/make-readme-markdown/master/make-readme-markdown.el'

if [ ! -f make-readme-markdown.el ]; then
    echo 'make-readme-markdown.el not found in current directory!'
    echo 'You may download it with the following command:'
    echo "wget -q '${download_url}'"
    exit 1
fi

emacs -q --script make-readme-markdown.el <'text-scale+.el' >README.md
