let s:assign = function('unfog#utils#assign')
let s:sum = function('unfog#utils#sum')
let s:strftime = function('strftime', ['%c'])
let s:duration = function('unfog#utils#date#duration')
let s:relative = function('unfog#utils#date#relative')
let s:match_one = function('unfog#utils#match_one')

" --------------------------------------------------------------------- # CRUD #

function! unfog#task#create(ids, task)
  let task = copy(a:task)

  for tag in copy(g:unfog_context)
    if index(task.tags, tag) == -1
      call add(task.tags, tag)
    endif
  endfor

  let task.id = has_key(task, 'id') ? task.id : unfog#task#generate_id(a:ids)
  let task.index = -(localtime() . task.id)

  if g:unfog_backend == 'taskwarrior'
    let task.id = unfog#backends#taskwarrior#create(task)
  endif

  return task
endfunction

function! unfog#task#read(id)
  let tasks = unfog#database#read().tasks
  let position = unfog#task#get_position(tasks, a:id)

  return tasks[position]
endfunction

function! unfog#task#read_all()
  return unfog#database#read().tasks
endfunction

function! unfog#task#update(prev_task, next_task)
  if g:unfog_backend == 'taskwarrior'
    call unfog#backends#taskwarrior#update(a:prev_task, a:next_task)
  endif

  return s:assign(a:prev_task, a:next_task)
endfunction

" --------------------------------------------------------------------- # List #

function! unfog#task#list()
  return eval(system("unfog list --json"))
endfunction

" ------------------------------------------------------------------- # Toggle #

function! unfog#task#toggle(task)
  let update = a:task.active ? {
    \'active': 0,
    \'stop': a:task.stop + [localtime()],
  \} : {
    \'active': 1,
    \'start': a:task.start + [localtime()],
  \}

  if g:unfog_backend == 'taskwarrior'
    call unfog#backends#taskwarrior#toggle(a:task)
  endif

  return s:assign(a:task, update)
endfunction

" --------------------------------------------------------------------- # Done #

function! unfog#task#done(task)
  let date_ref = localtime()

  if g:unfog_backend == 'taskwarrior'
    call unfog#backends#taskwarrior#done(a:task.id)
  endif

  let task = s:assign(a:task, {
    \'done': date_ref,
    \'id': a:task.index,
  \})

  if a:task.active
    let task = s:assign(task, {
      \'active': 0,
      \'stop': task.stop + [localtime()],
    \})
  endif

  return task
endfunction

" -------------------------------------------------------------------- # Utils #

function! s:throw_if_exists(task, ids)
  for id in a:ids
    if a:task.id == id
      throw 'task already exist'
    endif
  endfor
endfunction

function! unfog#task#generate_id(ids)
  let id_new = 1

  while index(a:ids, id_new) != -1
    let id_new += 1
  endwhile

  return id_new
endfunction

function! unfog#task#get_position(tasks, id)
  let position = 0

  for task in a:tasks
    if  task.id == a:id | return position | endif
    let position += 1
  endfor

  throw 'task not found'
endfunction

function! unfog#task#to_info_string(task)
  let task = copy(a:task)

  let starts = task.start
  let stops  = task.active ? task.stop + [localtime()] : task.stop

  let task.tags   = join(task.tags, ' ')
  let task.active = task.active ? 'true' : 'false'
  let task.done = task.done ? s:strftime(task.done) : ''
  let task.due  = task.due  ? s:strftime(task.due)  : ''
  let task.worktime = s:duration(s:sum(stops) - s:sum(starts))

  return task
endfunction

function! unfog#task#to_list_string(task)
  let task = copy(a:task)
  let now = localtime()

  let task.tags   = join(task.tags, " ")
  let task.active = task.active ? "✔" : ""
  " let task.done   = task.done   ? s:relative(now, task.done)      : ''
  " let task.due    = task.due    ? s:relative(now, task.due)       : ''

  return task
endfunction
