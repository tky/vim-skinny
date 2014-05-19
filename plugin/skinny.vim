function! skinny#view(pattern)
  for posibility in skinny#lsitPossibilityModelName(skinny#getModel())
    let a:file = skinny#findView(posibility, a:pattern)
    if (!empty(a:file)) 
      execute 'split ' . a:file
      return
    endif
  endfor
endfunction

function! skinny#openModel(model)
  execute 'botright vsplit  ' .  glob("**/" . a:model)
endfunction

function! skinny#lsitPossibilityModelName(model)
  let a:lowerModel = tolower(a:model)
  let a:chopModel = strpart(a:lowerModel, 0, strlen(a:lowerModel)-1)
  return [a:lowerModel, a:chopModel]
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

function! skinny#listAllModels()
  vsplit __SKINNY_MODELS__
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal cursorline
  setlocal nofoldenable
  setlocal modifiable
  call append(0, skinny#findAllModelNames())
  setlocal nomodifiable
  nnoremap <buffer> <silent> m :call skinny#openModel(getline("."))<CR>
endfunction

function! skinny#findAllModelNames()
  let filelist  = glob("**/model/*")
  let splitted = split(filelist, "\n")
  let a:models = []
  for model in splitted
    if (model !~ "test/")
      let a:divided = split(model, "/")
      call add(a:models, a:divided[len(a:divided) - 1])
    endif
  endfor
  return a:models
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
  " modelの場合とcontrollerの場合で値が異なるのをなんとかしたい。
  let a:path = expand("%:p")
  if (a:path =~ "model")
      return expand("%:t:r")
  elseif (a:path =~ "controller")
      let a:filename = expand("%:t:r")[:10]
      return strpart(a:filename, 0, strlen(a:filename)-10)
  else
      " TODO
      echo a:path
  endif
endfunction
