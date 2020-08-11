let s:compose = function('unfog#utils#compose')
let s:trim = function('unfog#utils#trim')
let s:print_msg = function('unfog#utils#print_msg')
let s:print_err = function('unfog#utils#print_err')

let s:max_widths = []
let s:buff_name = 'Unfog'
let s:tasks = []

" ------------------------------------------------------------------- # Config #

let s:config = {
  \'info': {
    \'columns': ['key', 'value'],
    \'keys': ['id', 'desc', 'project', 'active', 'due', 'worktime', 'done', 'deleted'],
  \},
  \'list': {
    \'columns': ['id', 'desc', 'project', 'active', 'due'],
  \},
  \'worktime': {
    \'columns': ['date', 'worktime'],
  \},
  \'labels': {
    \'active': 'ACTIVE',
    \'date': 'DATE',
    \'deleted': 'DELETED',
    \'desc': 'DESC',
    \'done': 'DONE',
    \'due': 'DUE',
    \'id': 'ID',
    \'key': 'KEY',
    \'project': 'PROJECT',
    \'total': 'TOTAL',
    \'total_raw': 'TOTAL RAW',
    \'total_wday': 'TOTAL WDAY',
    \'value': 'VALUE',
    \'worktime': 'WORKTIME',
  \},
\}

" --------------------------------------------------------------------- # Show #

function! unfog#ui#show()
  try
    let id = s:get_focused_task_id()
    let task = unfog#task#info(id)
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
    let s:tasks = unfog#task#list()
    let lines = map(copy(s:tasks), 'unfog#task#format_for_list(v:val)')

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
    let proj = input('Worktime for: ')
    let wtimes = unfog#task#worktime(proj)
    let wtimes_lines = map(
      \copy(wtimes.worktimes),
      \'{"date": v:val.date, "worktime": v:val.total.full}',
    \)
    let empty_line = {"date": "---", "worktime": "---"}
    let total_raw_line = {
      \"date": s:config.labels.total_raw,
      \"worktime": wtimes.total.full,
    \}
    let total_wday_line = {
      \"date": s:config.labels.total_wday,
      \"worktime": wtimes.totalWday.full,
    \}
    let lines = wtimes_lines + [empty_line, total_raw_line, total_wday_line]

    silent! bwipeout 'Unfog wtime'
    silent! botright new Unfog wtime

    call append(0, s:render('worktime', lines))
    normal! ddgg
    setlocal filetype=unfog-wtime
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
  " try
    let lines = filter(getline(2, "$"), "!empty(s:trim(v:val))")
    let prev_tasks = copy(s:tasks)
    let next_tasks = map(lines, "s:parse_buffer_line(v:key, v:val)")
    let tasks_to_add = filter(copy(next_tasks), "empty(v:val.id)")
    let tasks_to_edit = []
    let tasks_to_do = []
    let msgs = []

    for prev_task in prev_tasks
      let next_task = filter(copy(next_tasks), "v:val.id == prev_task.id")

      if empty(next_task)
        let tasks_to_do += [prev_task.id]
      elseif prev_task.desc != next_task[0].desc || prev_task.project != next_task[0].project || prev_task.due.approx != next_task[0].due
        let tasks_to_edit += [next_task[0]]
      endif
    endfor

    for task in tasks_to_add  | let msgs += [unfog#task#add(task)]  | endfor
    for task in tasks_to_edit | let msgs += [unfog#task#edit(task)] | endfor
    for id in tasks_to_do     | let msgs += [unfog#task#do(id)]     | endfor 

    call unfog#ui#list()
    let &modified = 0
    for msg in msgs | call s:print_msg(msg) | endfor
  " catch
  "   call s:print_err(v:exception)
  " endtry
endfunction

function! s:parse_buffer_line(index, line)
  if match(a:line, '^|[0-9a-f\-]\{-} *|.* *|.\{-} *|.\{-} *|.\{-} *|$') != -1
    let cells = split(a:line, "|")
    let id = s:trim(cells[0])
    let desc = s:trim(join(cells[1:-4], ""))
    let project = s:trim(cells[-3])
    let due = s:trim(cells[-1])

    return {
      \"id": id,
      \"desc": desc,
      \"project": project,
      \"due": due,
    \}
  else
    let [desc, project, due] = s:parse_args(s:trim(a:line))

    return {
      \"id": "",
      \"desc": desc,
      \"project": project,
      \"due": due,
    \}
  endif
endfunction

function! s:uniq_by_id(a, b)
  if a:a.id > a:b.id | return 1
  elseif a:a.id < a:b.id | return -1
  else | return 0 | endif
endfunction

function! s:parse_args(args)
  let args = split(a:args, ' ')

  let idx = 0
  let desc = []
  let project = ""
  let due = ""

  while idx < len(args)
    let arg = args[idx]

    if arg == "-p" || arg == "--project"
      let project = get(args, idx + 1, "")
      let idx = idx + 1
    elseif arg == "-d" || arg == "--due"
      let due = get(args, idx + 1, "")
      let idx = idx + 1
    else
      call add(desc, arg)
    endif

    let idx = idx + 1
  endwhile

  return [join(desc, ' '), project, due]
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
    return s:trim(split(getline("."), "|")[0])
  catch
    throw "task not found"
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
