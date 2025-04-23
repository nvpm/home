"-- plug/line.vim --

if !NVPMTEST&&exists('__LINEPLUG__')|finish|endif

let __LINEPLUG__ = 1

call line#init()

"-- user commands --
command! Line call line#line()

"-- auto commands --
augroup LINE
  au!
  au BufEnter,ModeChanged,BufDelete * call line#draw()
  if g:line_gitinfo
    au BufWrite,CmdWinLeave,CmdWinEnter * call line#gitf()
    au CursorHold,CursorHoldI * call line#gitf()
    if has('nvim')
      au TermEnter,TermLeave,TermClose * call line#gitf()
    else
      au TerminalOpen,TerminalWinOpen  * call line#gitf()
    endif
  endif
augroup END

