if !exists('NVPMTEST')&&exists('_GBOXAUTO_')|finish|endif
let _GBOXAUTO_=1

fu! gbox#init(...) abort "{

  let g:gbox_safefile = get(g:,'gbox_safefile','')
  let g:gbox_remote   = get(g:,'gbox_remote','origin')
  let g:gbox_branch   = get(g:,'gbox_branch','main')
  let g:gbox_pushcmd  = get(g:,'gbox_pushcmd','push')

  " TODO: user defined timeout
  let s:cache = "git -c credential.helper= "
  let s:cache.= "-c 'credential.helper=cache --timeout=300'"

endfu "}
fu! gbox#push(...) abort "{

  " retrieves safe's content
  let safe = safe#open(g:gbox_safefile)

  if safe.fail|return gbox#echo(safe)|endif

  if safe.empty
    return gbox#echo({
          \ 'fail':1,
          \ 'echo':"nvpm/gbox: safe file's empty",
          \ })
  endif

  let remote = g:gbox_remote
  let branch = g:gbox_branch

  " checks for commits to push
  let ahead = system('git rev-list --count '.remote.'/'.branch.'..'.branch)

  if v:shell_error
    return gbox#echo({
          \ 'fail':1,
          \ 'echo':'nvpm/gbox: unable to compare branches'
          \ })
  elseif !str2nr(ahead)
    return gbox#echo({
          \ 'fail':0,
          \ 'echo':'nvpm/gbox: nothing to push'
          \ })
  endif

  let pushcmd = s:cache..' '.g:gbox_pushcmd.' '.remote.' '.branch
  let content = 'url='.safe.content."\n\n"
  let approve = s:cache..' credential approve'
  let reject  = s:cache..' credential reject'

  " approves temporary credentials
  call system(approve,content)

  if v:shell_error
    return gbox#echo({
          \ 'fail':1,
          \ 'echo':'gbox: git credential approval failed'
          \ })
  endif

  " pushes
  let echo = {}
  let echo.echo = system(pushcmd)
  let echo.fail = v:shell_error

  " rejects temporary credentials
  call system(reject,content)

  return gbox#echo(echo)

endfu "}
fu! gbox#echo(...) abort "{

  let obj = a:1

  echo "\n"
  exec 'echohl '.(obj.fail ? 'WarningMsg' : 'Normal')
  echon obj.echo
  echohl None

  return obj.fail

endfu "}
