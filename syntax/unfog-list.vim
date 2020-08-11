if exists("b:current_syntax")
  finish
endif

syntax match unfog_separator        /|/
syntax match unfog_table_id         /^|.\{-}|/                            contains=unfog_separator
syntax match unfog_table_desc       /^|.\{-}|.\{-}|/                      contains=unfog_table_id,unfog_separator
syntax match unfog_table_project    /^|.\{-}|.\{-}|.\{-}|/                contains=unfog_table_id,unfog_table_desc,unfog_separator
syntax match unfog_table_active     /^|.\{-}|.\{-}|.\{-}|.\{-}|/          contains=unfog_table_id,unfog_table_desc,unfog_table_project,unfog_separator
syntax match unfog_table_due        /^|.\{-}|.\{-}|.\{-}|.\{-}|.\{-}|/    contains=unfog_table_id,unfog_table_desc,unfog_table_project,unfog_table_active,unfog_separator
syntax match unfog_table_due_alert  /^|.\{-}|.\{-}|.\{-}|.\{-}|.*ago.*|/  contains=unfog_table_id,unfog_table_desc,unfog_table_project,unfog_table_active,unfog_separator
syntax match unfog_table_head       /.*\%1l/                              contains=unfog_separator

highlight default link unfog_separator        VertSplit
highlight default link unfog_table_id         Identifier
highlight default link unfog_table_desc       Comment
highlight default link unfog_table_project    Tag
highlight default link unfog_table_active     String
highlight default link unfog_table_due        Structure
highlight default link unfog_table_due_alert  Error

highlight unfog_table_head term=bold,underline cterm=bold,underline gui=bold,underline

let b:current_syntax = "unfog-list"
