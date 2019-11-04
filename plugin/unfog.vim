if exists('g:unfog_loaded') | finish | endif
let g:unfog_loaded = 1

if !executable('unfog')
  throw 'unfog not found, please install unfog.cli first'
endif

command! Unfog call unfog#ui#list()
