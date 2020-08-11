setlocal buftype=acwrite
setlocal cursorline
setlocal nowrap
setlocal startofline

let mappings = [
  \["n", "<cr>",    "toggle"        ],
  \["n", "K",       "show"          ],
  \["n", "gc",      "context"       ],
  \["n", "gw",      "worktime"      ],
  \["n", "<c-n>",   "next-cell"     ],
  \["n", "<c-p>",   "prev-cell"     ],
  \["n", "dic",     "delete-in-cell"],
  \["n", "cic",     "change-in-cell"],
  \["n", "vic",     "visual-in-cell"],
\]

nnoremap <silent> <plug>(unfog-toggle)     :call unfog#ui#toggle()    <cr>
nnoremap <silent> <plug>(unfog-show)       :call unfog#ui#show()      <cr>
nnoremap <silent> <plug>(unfog-context)    :call unfog#ui#context()   <cr>
nnoremap <silent> <plug>(unfog-worktime)   :call unfog#ui#worktime()  <cr>

nnoremap <silent> <plug>(unfog-next-cell)  :call unfog#ui#select_next_cell()<cr>
nnoremap <silent> <plug>(unfog-prev-cell)  :call unfog#ui#select_prev_cell()<cr>
vnoremap <silent> <plug>(unfog-next-cell)  :call unfog#ui#select_next_cell()<cr>
vnoremap <silent> <plug>(unfog-prev-cell)  :call unfog#ui#select_prev_cell()<cr>

nnoremap <silent> <plug>(unfog-delete-in-cell) :call unfog#ui#delete_in_cell()<cr>
nnoremap <silent> <plug>(unfog-change-in-cell) :call unfog#ui#change_in_cell()<cr>
nnoremap <silent> <plug>(unfog-visual-in-cell) :call unfog#ui#visual_in_cell()<cr>

for [mode, key, plug] in mappings
  let plug = printf("<plug>(unfog-%s)", plug)

  if !hasmapto(plug, mode)
    execute printf("%smap <nowait> <buffer> %s %s", mode, key, plug)
  endif
endfor

augroup unfog-list
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call unfog#ui#parse_buffer()
augroup end
