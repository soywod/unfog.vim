setlocal buftype=acwrite
setlocal cursorline
setlocal nowrap
setlocal startofline

let mappings = [
  \['n', '<space>', 'list'          ],
  \['n', '<cr>',    'toggle'        ],
  \['n', 'K',       'info'          ],
  \['n', 'gc',      'context'       ],
  \['n', 'gh',      'hide-done'     ],
  \['n', 'gw',      'worktime'      ],
  \['n', 'gs',      'sort-asc'      ],
  \['n', 'gS',      'sort-desc'     ],
  \['n', '<c-n>',   'next-cell'     ],
  \['n', '<c-p>',   'prev-cell'     ],
  \['n', 'dic',     'delete-in-cell'],
  \['n', 'cic',     'change-in-cell'],
  \['n', 'vic',     'visual-in-cell'],
\]

nnoremap <silent> <plug>(unfog-list)       :call unfog#ui#list()      <cr>
nnoremap <silent> <plug>(unfog-toggle)     :call unfog#ui#toggle()    <cr>
nnoremap <silent> <plug>(unfog-info)       :call unfog#ui#info()      <cr>
nnoremap <silent> <plug>(unfog-context)    :call unfog#ui#context()   <cr>
nnoremap <silent> <plug>(unfog-hide-done)  :call unfog#ui#hide_done() <cr>
nnoremap <silent> <plug>(unfog-worktime)   :call unfog#ui#worktime()  <cr>
nnoremap <silent> <plug>(unfog-sort-asc)   :call unfog#ui#sort(1)     <cr>
nnoremap <silent> <plug>(unfog-sort-desc)  :call unfog#ui#sort(-1)    <cr>

nnoremap <silent> <plug>(unfog-next-cell)  :call unfog#ui#select_next_cell()<cr>
nnoremap <silent> <plug>(unfog-prev-cell)  :call unfog#ui#select_prev_cell()<cr>
vnoremap <silent> <plug>(unfog-next-cell)  :call unfog#ui#select_next_cell()<cr>
vnoremap <silent> <plug>(unfog-prev-cell)  :call unfog#ui#select_prev_cell()<cr>

nnoremap <silent> <plug>(unfog-delete-in-cell) :call unfog#ui#delete_in_cell()<cr>
nnoremap <silent> <plug>(unfog-change-in-cell) :call unfog#ui#change_in_cell()<cr>
nnoremap <silent> <plug>(unfog-visual-in-cell) :call unfog#ui#visual_in_cell()<cr>

for [mode, key, plug] in mappings
  let plug = printf('<plug>(unfog-%s)', plug)

  if !hasmapto(plug, mode)
    execute printf('%smap <nowait> <buffer> %s %s', mode, key, plug)
  endif
endfor

augroup klist
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call unfog#ui#parse_buffer()
augroup end
