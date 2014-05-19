function! skinny#view(pattern)
  for posibility in skinny#lsitPossibilityModelName(skinny#getModel())
    let a:file = skinny#findView(posibility, a:pattern)
    if (!empty(a:file)) 
      execute 'split ' . a:file
      return
    endif
  endfor
endfunction

function! skinny#lsitPossibilityModelName(model)
  let a:lowerModel = tolower(a:model)
  let a:chopModel = strpart(a:lowerModel, 0, strlen(a:lowerModel)-1)
  return [a:chopModel, a:lowerModel]
endfunction

function! skinny#findView(target, pattern)
  let filelist  = glob("**/" . a:target . "*/*")
  let splitted = split(filelist, "\n")
  for file in splitted
    if (file =~ a:pattern)
      return file
    endif
  endfor
endfunction


function! skinny#getCurrentLocation()
  let a:path = expand("%:p")
  if (a:path =~ "model")
    return "model"
  elseif (a:path =~ "views")
    return "view"
  else 
    " TODO
    return "unknown"
  endif
endfunction

function! skinny#getModel()
  let a:path = expand("%:p")
  if (a:path =~ "model")
      return expand("%:t:r")
  else
      " TODO
      echo a:path
  endif
endfunction
