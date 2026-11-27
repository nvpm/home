
function! chat#history#Path(name) abort
  let l:name = fnamemodify(a:name, ':t')
  let l:name = substitute(l:name, '[^[:alnum:]_.-]', '_', 'g')
  if empty(l:name)
    throw 'Chat: invalid conversation name'
  endif
  return g:chat_directory . '/' . (fnamemodify(l:name, ':e') ==# 'gpt'
        \ ? l:name : l:name . '.gpt')
endfunction

function! chat#history#Current() abort
  if get(b:, 'chat_type', '') ==# 'conversation'
    return expand('%:p')
  endif
  return get(b:, 'chat_conversation', '')
endfunction

function! chat#history#Read(path) abort
  if !filereadable(a:path)
    return []
  endif
  return readfile(a:path, 'b')
endfunction

function! chat#history#Messages(lines) abort
  let l:messages = []
  let l:role = ''
  let l:content = []

  for l:line in a:lines[1:]
    if l:line ==# '[[USER]]'
      if !empty(l:role)
        call add(l:messages, {'role': l:role, 'content': join(l:content, "\n")})
      endif
      let l:role = 'user'
      let l:content = []
    elseif l:line ==# '[[ASSISTANT]]'
      if !empty(l:role)
        call add(l:messages, {'role': l:role, 'content': join(l:content, "\n")})
      endif
      let l:role = 'assistant'
      let l:content = []
    elseif l:line ==# '[[END]]'
      if !empty(l:role)
        call add(l:messages, {'role': l:role, 'content': join(l:content, "\n")})
      endif
      let l:role = ''
      let l:content = []
    elseif !empty(l:role)
      call add(l:content, l:line)
    endif
  endfor

  if !empty(l:role)
    call add(l:messages, {'role': l:role, 'content': join(l:content, "\n")})
  endif

  return l:messages
endfunction

function! chat#history#AppendExchange(path, question, answer) abort
  let l:lines = [
        \ '',
        \ '[[USER]]',
        \ a:question,
        \ '',
        \ '[[ASSISTANT]]',
        \ a:answer,
        \ '',
        \ '[[END]]'
        \ ]
  return writefile(l:lines, a:path, 'a')
endfunction

function! chat#history#Files() abort
  call mkdir(g:chat_directory, 'p')
  return sort(glob(g:chat_directory . '/*.gpt', 0, 1))
endfunction
