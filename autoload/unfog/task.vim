function! s:exec(cmd, args)
  let cmd = call("printf", [a:cmd] + a:args)
  let result = eval(system(cmd))

  if result.ok
    return result.data
  else
    throw result.data
  endif
endfunction

function! unfog#task#show(id)
  return s:exec("unfog show %s --json", [a:id])
endfunction

function! unfog#task#list()
  return s:exec("unfog list --json", [])
endfunction

function! unfog#task#create(task)
  let tags = join(map(a:task.tags, "'+' . v:val"), " ")
  return s:exec("unfog create %s %s --json", [a:task.desc, tags])
endfunction

function! unfog#task#replace(task)
  let tags = join(map(a:task.tags, "'+' . v:val"), " ")
  return s:exec("unfog replace %d %s %s --json", [a:task.id, a:task.desc, tags])
endfunction

function! unfog#task#toggle(id)
  return s:exec("unfog toggle %d --json", [a:id])
endfunction

function! unfog#task#remove(id)
  return s:exec("unfog remove %d --json", [a:id])
endfunction

function! unfog#task#context(context)
  return s:exec("unfog context %s --json", [a:context])
endfunction

function! unfog#task#worktime(tags)
  return s:exec("unfog worktime %s --json", [a:tags])
endfunction

function! unfog#task#format_for_show(task)
  let task = copy(a:task)

  let task.tags     = join(task.tags, " ")
  let task.active   = task.active ? "✔" : ""
  let task.wtime = empty(task.wtime.micro) ? "" : task.wtime.human

  return task
endfunction

function! unfog#task#format_for_list(task)
  let now = localtime()
  let task = copy(a:task)

  let task.tags     = join(task.tags, " ")
  let task.active   = task.active ? "✔" : ""
  let task.wtime = empty(task.wtime.micro) ? "" : task.wtime.approx

  return task
endfunction
