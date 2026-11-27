" Decrypt a GPG-encrypted credential file without creating plaintext files.
" The passphrase is supplied on stdin, not in the process argument list.

function! chat#cryp#Decrypt(path) abort "{
  if !executable('gpg')
    return {'ok': 0, 'error': 'gpg executable not found'}
  endif
  if !filereadable(a:path)
    return {'ok': 0, 'error': 'Credential file not found: ' . a:path}
  endif

  let password = inputsecret('GPG passphrase: ')
  if empty(password)
    return {'ok': 0, 'error': 'Credential decryption cancelled'}
  endif

  let cmd = 'gpg --quiet --no-symkey-cache --batch '
        \ . '--pinentry-mode loopback --passphrase-fd 0 '
        \ . '--decrypt ' . shellescape(a:path)

  let output = system(cmd, password . "\n")
  let status = v:shell_error
  let password = ''

  if status != 0
    return {'ok': 0, 'error': 'GPG decryption failed'}
  endif

  let token = substitute(output, '[\r\n]\+$', '', '')
  if empty(token)
    return {'ok': 0, 'error': 'Decrypted credential is empty'}
  endif

  return {'ok': 1, 'token': token}
endfunction "}
