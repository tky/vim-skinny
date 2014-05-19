command! -nargs=0 SkinnyViewIndex call skinny#view("index.html")
command! -nargs=0 SkinnyViewEdit call skinny#view("edit.html")
command! -nargs=0 SkinnyViewNew call skinny#view("new.html")
command! -nargs=0 SkinnyViewShow call skinny#view("show.html")

command! -nargs=0 SkinnyListModels call skinny#listAllModels()

