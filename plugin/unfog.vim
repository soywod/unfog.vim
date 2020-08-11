if exists("g:unfog_loaded")
  finish
endif

let g:unfog_loaded = 1

if !executable("unfog")
  throw "unfog not found, see https://github.com/soywod/unfog#installation"
endif

command! Unfog call unfog#ui#list()
