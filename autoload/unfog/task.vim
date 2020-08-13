function! s:exec(cmd, args)
  let cmd = call("printf", [a:cmd] + a:args)
  let result = eval(system(cmd))

  if result.success == 0
    throw result.message
  endif

  return result
endfunction

function! unfog#task#info(id)
  return s:exec("unfog info %s --json", [shellescape(a:id)]).task
endfunction

function! unfog#task#list()
  return s:exec("unfog list --json", []).tasks
endfunction

function! unfog#task#list_done()
  return s:exec("unfog list --done --json", []).tasks
endfunction

function! unfog#task#list_deleted()
  return s:exec("unfog list --deleted --json", []).tasks
endfunction

function! unfog#task#add(task)
  let desc = shellescape(a:task.desc)
  let proj = shellescape(a:task.project)
  let due = shellescape(a:task.due)

  return s:exec("unfog add %s --project %s --due %s --json", [desc, proj, due]).message
endfunction

function! unfog#task#edit(task)
  let args = [a:task.id]
  if !empty(a:task.desc) | call add(args, shellescape(a:task.desc)) | endif
  if !empty(a:task.project) | call add(args, "--project " . shellescape(a:task.project)) | endif
  if !empty(a:task.due) | call add(args, "--due " . shellescape(a:task.due)) | endif

  return s:exec("unfog edit %s --json", [join(args, " ")]).message
endfunction

function! unfog#task#toggle(id)
  return s:exec("unfog toggle %s --json", [shellescape(a:id)]).message
endfunction

function! unfog#task#do(id)
  return s:exec("unfog do %s --json", [shellescape(a:id)]).message
endfunction

function! unfog#task#context(context)
  return s:exec("unfog context %s --json", [a:context]).message
endfunction

function! unfog#task#worktime(proj)
  return s:exec("unfog worktime %s --json", [shellescape(a:proj)])
endfunction

function! unfog#task#format_for_list(task)
  let task = copy(a:task)
  let task.active = empty(task.active.micro) ? "" : task.active.approx
  let task.due = empty(task.due.micro) ? "" : task.due.approx
  let task.worktime = empty(task.worktime.micro) ? "" : task.worktime.approx

  return task
endfunction
