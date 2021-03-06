let s:init = 0

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
  let a:trimed = substitute(a:model, " ", "", "g")
  let filelist  = glob("**/" . a:trimed)
  let splitted = split(filelist, "\n")
  execute 'botright vsplit  ' .  splitted[0]
endfunction

function! skinny#openController(model)
  let a:trimed = substitute(a:model, " ", "", "g")
  let a:controller = skinny#findController(a:trimed)
  if (!empty(a:controller)) 
    execute 'botright vsplit  ' .  a:controller
  endif
endfunction

function! skinny#findController(model)
  for posibility in skinny#lsitPossibilityModelName(skinny#filterExtension(a:model))
    let a:filelist  = skinny#searchFile("**/controller/" . posibility . "*")
    if (!empty(a:filelist))
      return a:filelist[0]
    endif
  endfor
endfunction

function! skinny#filterExtension(model)
  let a:splitted = split(a:model, "\\.")
  return a:splitted[0]
endfunction

function! skinny#searchFile(pattern)
    let filelist  = glob(a:pattern)
    return split(filelist, "\n")
endfunction

function! skinny#lsitPossibilityModelName(model)
  let a:lowerModel = tolower(a:model)
  let a:chopModel = strpart(a:lowerModel, 0, strlen(a:lowerModel)-1)
  return [a:model, a:lowerModel, a:chopModel]
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
  call skinny#init()
  let s:listDisplayType = 'model'
  vsplit __SKINNY_MODELS__
  call skinny#openListPage()
endfunction

function! skinny#openListPage()
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal cursorline
  setlocal nofoldenable
  setlocal modifiable

  set filetype=skinnyvim

  "syntax region skinnyvimDirectory start='^ *+' end='$'
  syntax region skinnyvimRootDirectory start='^ *+' end='$'
  syntax region skinnyvimChildDirectory start='^ *|+' end='$'

  highlight def link skinnyvimRootDirectory Preproc
  highlight def link skinnyvimChildDirectory Preproc

  1,$delete
  call append(0, skinny#findToListPageObjects(s:listDisplayType))
  setlocal nomodifiable
  nnoremap <buffer> <silent> t :call skinny#toggleListPage()<CR>
  " pass select model (contains extension)
  nnoremap <buffer> <silent> m :call skinny#openModel(getline("."))<CR>
  nnoremap <buffer> <silent> c :call skinny#openController(getline("."))<CR>
endfunction

function! skinny#toggleListPage()
  if (s:listDisplayType == 'model')
    let s:listDisplayType = 'controller'
  else
    let s:listDisplayType = 'model'
  endif
  call skinny#openListPage()
endfunction

function! skinny#findToListPageObjects(displayType)
  if (a:displayType == 'model')
    let a:splitted = skinny#findAllModel()
    let a:prefixLength = len(s:modelPath) + 1
  elseif (a:displayType == 'controller')
    let a:splitted = skinny#findAllController()
    let a:prefixLength = len(s:controllerPath) + 1
  endif

  let a:models = []
  for model in a:splitted
    if (model !~ "test/" && model !~ "target/")
      if (isdirectory(model))
        let a:divided = split(model[a:prefixLength : ], "/")
        call add(a:models, skinny#getPrefix(model, a:prefixLength) . a:divided[len(a:divided) - 1])
      else
        let a:divided = split(model, "/")
        call add(a:models, skinny#getPrefix(model, a:prefixLength) . a:divided[len(a:divided) - 1])
      endif
    endif
  endfor
  return a:models
endfunction

function! skinny#getPrefix(file, prefixLength)
  let a:depth = len(split(a:file[a:prefixLength - 1 : ], '/')) - 1
  if (a:depth == 0 && isdirectory(a:file)) 
    return "+ "
  endif

  if (isdirectory(a:file)) 
    return "            "[0 : a:depth] .  "|+ "
  else 
    return "            "[0 : a:depth + 2]
  endif
endfunction

function! skinny#findAllController()
  return split(glob(s:controllerPath . "/**"), "\n")
endfunction

function! skinny#findAllModel()
  return split(glob(s:modelPath . "/**"), "\n")
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

function! skinny#init()
  if (s:init == 0) 
    call skinny#initPathSettings()
    let s:init = 1
  endif
endfunction

function! skinny#test()
  call skinny#init()
  let filelist  = glob(s:controllerPath . "/**")
  echo filelist
endfunction

function! skinny#initPathSettings()
  let s:controllerPath = ""
  let s:modelPath = ""
  let s:viewPath = ""
  let s:openDirectory = getcwd()
  let filelist  = glob(s:openDirectory . "/**")
  let splitted = split(filelist, "\n")
  for file in splitted
    if (file =~ "**/controller" && empty(s:controllerPath))
      let s:controllerPath = file
    elseif (file =~ "**/model" && empty(s:modelPath))
      let s:modelPath = file
    elseif (file =~ "**/WEB-INF/views" && empty(s:viewPath))
      let s:viewPath = file
    endif
  endfor
endfunction
