if exists('b:current_syntax') | finish | endif

syntax match unfog_wtime_separator  /[|-]/
syntax match unfog_wtime_time       /\(|.*|\)\@<=.*|/ contains=unfog_wtime_separator
syntax match unfog_wtime_date       /|.\{-}|/         contains=unfog_wtime_separator
syntax match unfog_wtime_total      /|.\{-}|\%$/      contains=unfog_wtime_separator,unfog_wtime_time
syntax match unfog_wtime_head       /.*\%1l/          contains=unfog_wtime_separator

highlight default link unfog_wtime_separator  VertSplit
highlight default link unfog_wtime_date       Comment
highlight default link unfog_wtime_time       String
highlight default link unfog_wtime_total      Tag

highlight unfog_wtime_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = 'unfog-wtime'
