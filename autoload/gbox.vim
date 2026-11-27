if !exists('NVPMTEST')&&exists('_GBOXAUTO_')|finish|endif
let _GBOXAUTO_=1

fu! gbox#init(...) abort "{

  let g:gbox_safefile = get(g:,'gbox_safefile','')

  " TODO: user defined timeout
  let cache = "git -c credential.helper= "
        \ . "-c 'credential.helper=cache --timeout=300'"
  let g:gbox_cachecmd = get(g:,'gbox_cachecmd',cache)
  let g:gbox_pushcmd  = get(g:,'gbox_pushcmd','push origin main')


endfu "}
fu! gbox#push(...) abort "{

  " retrieves safe's content
  let safe = safe#open(g:gbox_safefile)

  if safe.fail|return gbox#echo(safe)|endif
  if safe.empty
    return gbox#echo({'fail':1,'echo':'nvpm/gbox: safe file is empty'})
  endif

  " TODO: regex-check if URL is well-formed
  let url = safe.content

  let approved = 0
  try "{
    call system(g:gbox_cachecmd.' credential approve','url='.url."\n\n")

    if v:shell_error
      throw 'gbox#push: credential approval failed'
    endif

    let approved = 1

    let output = system(g:gbox_cachecmd.' '.g:gbox_pushcmd)

  finally
    if approved
      call system(g:gbox_cachecmd.' credential reject','url='.url."\n\n")
    endif
  endtry "}

  return gbox#echo({'fail':!v:shell_error,'echo':output})

endfu "}
fu! gbox#echo(...) abort "{

  let obj = a:1
  echo "\n"
  exec 'echohl '..['Normal','WarningMsg'][obj.fail]
  echon obj.echo
  echohl None
  return obj.fail

endfu "}
