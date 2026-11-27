if !exists('NVPMTEST')&&exists('_SAFEAUTO_')|finish|endif
let _SAFEAUTO_=1

fu! safe#open(...) abort "{

  if !a:0|return {'fail':1,'echo':'nvpm/safe: requires a file path'}|endif

  if !executable('gpg')
    return {'fail': 1,'echo':'nvpm/safe: "gpg" executable not found'}
  endif
    
  let file = a:1
  if !filereadable(file)
    return {'fail': 1, 'echo': 'nvpm/safe: safe file "'.file.'" not found'}
  endif
  let key = inputsecret('Input safe key: ')

  if empty(key)
    unlet key
    return {'fail': 1, 'echo': 'nvpm/safe: safe opening cancelled'}
  endif

  let open = 'gpg --quiet --no-symkey-cache --batch '
        \ . '--pinentry-mode loopback --passphrase-fd 0 '
        \ . '--decrypt ' . shellescape(file)

  let content = system(open, key . "\n")

  if v:shell_error
    return {'fail': 1, 'echo': "nvpm/safe: safe opening failed. Wrong key?"}
  endif

  unlet key

  "let content = substitute(content, '[\r\n]\+$', '', '')

  return {'fail': 0, 'content': content,'empty':empty(content)}

endfu "}
