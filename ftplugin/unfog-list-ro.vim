setlocal bufhidden=wipe
setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <buffer> <silent> q     :bwipeout<cr>
nnoremap <buffer> <silent> <cr>  :bwipeout<cr>
nnoremap <buffer> <silent> <esc> :bwipeout<cr>

let mappings = [
  \['n', 'K',       'show'          ],
  \['n', '<c-n>',   'next-cell'     ],
  \['n', '<c-p>',   'prev-cell'     ],
  \['n', 'vic',     'visual-in-cell'],
\]

nnoremap <silent> <plug>(unfog-show)            :call unfog#ui#show()             <cr>
nnoremap <silent> <plug>(unfog-next-cell)       :call unfog#ui#select_next_cell() <cr>
nnoremap <silent> <plug>(unfog-prev-cell)       :call unfog#ui#select_prev_cell() <cr>
nnoremap <silent> <plug>(unfog-visual-in-cell)  :call unfog#ui#visual_in_cell()   <cr>

for [mode, key, plug] in mappings
  let plug = printf('<plug>(unfog-%s)', plug)

  if !hasmapto(plug, mode)
    execute printf('%smap <nowait> <buffer> %s %s', mode, key, plug)
  endif
endfor
