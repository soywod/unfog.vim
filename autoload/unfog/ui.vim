let s:assign = function('unfog#utils#assign')
let s:compose = function('unfog#utils#compose')
let s:sum = function('unfog#utils#sum')
let s:trim = function('unfog#utils#trim')
let s:approx_due = function('unfog#utils#date#approx_due')
let s:parse_due = function('unfog#utils#date#parse_due')
let s:worktime = function('unfog#utils#date#worktime')
let s:duration = function('unfog#utils#date#duration')
let s:print_msg = function('unfog#utils#print_msg')
let s:print_err = function('unfog#utils#print_err')
let s:match_one = function('unfog#utils#match_one')

let s:max_widths = []
let s:buff_name = 'Unfog'

" ------------------------------------------------------------------- # Config #

let s:config = {
  \'info': {
    \'columns': ['key', 'value'],
    \'keys': ['id', 'desc', 'tags', 'active', 'wtime'],
  \},
  \'list': {
    \'columns': ['id', 'desc', 'tags', 'active', 'wtime'],
  \},
  \'worktime': {
    \'columns': ['date', 'worktime'],
  \},
  \'labels': {
    \'active': 'ACTIVE',
    \'date': 'DATE',
    \'desc': 'DESC',
    \'done': 'DONE',
    \'due': 'DUE',
    \'id': 'ID',
    \'key': 'KEY',
    \'tags': 'TAGS',
    \'total': 'TOTAL',
    \'value': 'VALUE',
    \'wtime': 'WORKTIME',
  \},
\}

" --------------------------------------------------------------------- # Show #

function! unfog#ui#show()
  try
    let id = s:get_focused_task_id()
    let task = unfog#task#show(id)
    let task = unfog#task#format_for_show(task)
    let lines = map(
      \copy(s:config.info.keys),
      \'{"key": s:config.labels[v:val], "value": task[v:val]}',
    \)

    silent! bwipeout 'Unfog show'
    silent! botright new Unfog show

    call append(0, s:render('info', lines))
    normal! ddgg
    setlocal filetype=unfog-show
  catch
    call s:print_err(v:exception)
  endtry
endfunction

" --------------------------------------------------------------------- # List #

function! unfog#ui#list()
  try
    let prev_pos = getpos('.')
    let tasks = unfog#task#list()
    let lines = map(copy(tasks), 'unfog#task#format_for_list(v:val)')

    redir => buf_list | silent! ls | redir END
    execute 'silent! edit ' . s:buff_name

    if match(buf_list, '"Unfog') > -1
      execute '0,$d'
    endif

    call append(0, s:render('list', lines))
    execute '$d'
    call setpos('.', prev_pos)
    setlocal filetype=unfog-list
    let &modified = 0
    echo
  catch
    call s:print_err(v:exception)
  endtry
endfunction

" ------------------------------------------------------------------- # Toggle #

function! unfog#ui#toggle()
  try
    let id = s:get_focused_task_id()
    let msg = unfog#task#toggle(id)
    call unfog#ui#list()
    call s:print_msg(msg)
  catch
    call s:print_err(v:exception)
  endtry
endfunction

" ------------------------------------------------------------------ # Context #

function! unfog#ui#context()
  try
    let ctx = input('Go to context: ')
    let msg = unfog#task#context(ctx)
    call unfog#ui#list()
    call s:print_msg(msg)
  catch
    call s:print_err(v:exception)
  endtry
endfunction

" ----------------------------------------------------------------- # Worktime #

function! unfog#ui#worktime()
  try
    let tags = input('Worktime for: ')
    let msg = unfog#task#worktime(tags)
    redraw
    call s:print_msg(msg)
  catch
    call s:print_err(v:exception)
  endtry
endfunction

" ---------------------------------------------------------- # Cell management #

function! unfog#ui#select_next_cell()
  normal! f|l

  if col('.') == col('$') - 1
    if line('.') == line('$')
      normal! T|
    else
      normal! j0l
    endif
  endif
endfunction

function! unfog#ui#select_prev_cell()
  if col('.') == 2 && line('.') > 2
    normal! k$T|
  else
    normal! 2T|
  endif
endfunction

function! unfog#ui#delete_in_cell()
  execute printf('normal! %sdt|', col('.') == 1 ? '' : 'T|')
endfunction

function! unfog#ui#change_in_cell()
  call unfog#ui#delete_in_cell()
  startinsert
endfunction

function! unfog#ui#visual_in_cell()
  execute printf('normal! %svt|', col('.') == 1 ? '' : 'T|')
endfunction

" -------------------------------------------------------------- # Parse utils #

function! unfog#ui#parse_buffer()
  try
    let prev_tasks = unfog#task#list()
    let next_tasks = map(getline(2, "$"), "s:parse_buffer_line(v:key, v:val)")
    let tasks_to_create = filter(copy(next_tasks), "v:val.id == 0")
    let tasks_to_update = []
    let tasks_to_remove = []
    let msgs = []

    for prev_task in prev_tasks
      let next_task = filter(copy(next_tasks), "v:val.id == prev_task.id")

      if empty(next_task)
        let tasks_to_remove += [prev_task.id]
      elseif prev_task.desc != next_task[0].desc || prev_task.tags != next_task[0].tags
        let tasks_to_update += [next_task[0]]
      endif
    endfor

    for task in tasks_to_create | let msgs += [unfog#task#create(task)]   | endfor
    for task in tasks_to_update | let msgs += [unfog#task#replace(task)]  | endfor
    for id in tasks_to_remove   | let msgs += [unfog#task#remove(id)]     | endfor 

    call unfog#ui#list()
    let &modified = 0
    for msg in msgs | call s:print_msg(msg) | endfor
  catch
    call s:print_err(v:exception)
  endtry
endfunction

function! s:parse_buffer_line(index, line)
  if match(a:line, '^|-\=\d\{-1,}\s\{-}|.*|.\{-}|.\{-}|.\{-}|$') != -1
    let cells = split(a:line, "|")
    let id = +s:trim(cells[0])
    let desc = s:trim(join(cells[1:-4], ""))
    let tags = split(s:trim(cells[-3]), " ")

    return {
      \"id": id,
      \"desc": desc,
      \"tags": tags,
    \}
  else
    let [desc, tags] = s:parse_args(localtime(), s:trim(a:line))

    return {
      \"id": 0,
      \"desc": desc,
      \"tags": tags,
    \}
  endif
endfunction

function! s:uniq_by_id(a, b)
  if a:a.id > a:b.id | return 1
  elseif a:a.id < a:b.id | return -1
  else | return 0 | endif
endfunction

function! s:parse_args(date_ref, args)
  let args = split(a:args, ' ')

  let desc     = []
  let tags     = []
  let tags_old = []
  let tags_new = []

  for arg in args
    if arg =~ '^+\w'
      call add(tags_new, arg[1:])
    elseif arg =~ '^-\w'
      call add(tags_old, arg[1:])
    else
      call add(desc, arg)
    endif
  endfor

  for tag in tags_new
    if index(tags, tag) == -1 | call add(tags, tag) | endif
  endfor

  for tag in tags_old
    let index = index(tags, tag)
    if  index != -1 | call remove(tags, index) | endif
  endfor

  return [join(desc, ' '), tags]
endfunction

" ------------------------------------------------------------------ # Renders #

function! s:render(type, lines)
  let s:max_widths = s:get_max_widths(a:lines, s:config[a:type].columns)
  let header = [s:render_line(s:config.labels, s:max_widths, a:type)]
  let line = map(copy(a:lines), 's:render_line(v:val, s:max_widths, a:type)')

  return header + line
endfunction

function! s:render_line(line, max_widths, type)
  return '|' . join(map(
    \copy(s:config[a:type].columns),
    \'s:render_cell(a:line[v:val], a:max_widths[v:key])',
  \), '')
endfunction

function! s:render_cell(cell, max_width)
  let cell_width = strdisplaywidth(a:cell[:a:max_width])
  return a:cell[:a:max_width] . repeat(' ', a:max_width - cell_width) . ' |'
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:get_max_widths(tasks, columns)
  let max_widths = map(copy(a:columns), 'strlen(s:config.labels[v:val])')

  for task in a:tasks
    let widths = map(copy(a:columns), 'strlen(task[v:val])')
    call map(max_widths, 'max([widths[v:key], v:val])')
  endfor

  return max_widths
endfunction

function! s:get_focused_task_id()
  try
    return split(getline("."), "|")[0]
  catch
    throw 'task not found'
  endtry
endfunction

function! s:refresh_buff_name()
  let buff_name = 'Unfog'

  if !g:unfog_hide_done
    let buff_name .= '*'
  endif

  if len(g:unfog_context) > 0
    let tags = map(copy(g:unfog_context), 'printf(" +%s", v:val)')
    let buff_name .= join(tags, '')
  endif

  if buff_name != s:buff_name
    execute 'silent! enew'
    execute 'silent! bwipeout ' . s:buff_name
    let s:buff_name = buff_name
  endif
endfunction

function! s:exists_in(list, item)
  return index(a:list, a:item) > -1
endfunction
