if !exists('NVPMTEST')&&exists('_GBOXAUTO_')|finish|endif
let _GBOXAUTO_=1

fu! gbox#init(...) abort "{

  let g:gbox_safefile = get(g:,'gbox_safefile','')
  let g:gbox_pushcmd  = get(g:,'gbox_pushcmd','push origin main')

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

  let content = 'url='.safe.content."\n\n"
  let pushcmd = s:cache..' '..g:gbox_pushcmd
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
  let stdout = system(pushcmd)

  " catches shell's error
  let fail = v:shell_error != 0

  " rejects temporary credentials
  call system(reject,content)

  return gbox#echo({'fail':fail,'echo':stdout})

endfu "}
fu! gbox#echo(...) abort "{

  let obj = a:1

  echo "\n"
  exec 'echohl '.(obj.fail ? 'WarningMsg' : 'Normal')
  echon obj.echo
  echohl None

  return obj.fail

endfu "}
