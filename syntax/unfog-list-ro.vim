if exists("b:current_syntax") | finish | endif
runtime! syntax/unfog-list.vim
let b:current_syntax = "unfog-list-ro"
