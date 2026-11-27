" Public commands and conversation workflow.

function! chat#Open(name) abort "{
  let l:name = trim(a:name)
  if empty(l:name)
    echoerr 'Chat: conversation name cannot be empty'
    return
  endif

  call mkdir(g:chat_directory, 'p')
  let l:path = chat#history#Path(l:name)

  if filereadable(l:path)
    execute 'edit' fnameescape(l:path)
    setlocal filetype=chat
    let b:chat_type = 'conversation'
    let b:chat_conversation = expand('%:p')
    return
  endif

  let l:title = input('Conversation title: ', l:name)
  if empty(trim(l:title))
    echo 'Chat: creation cancelled'
    return
  endif

  let l:lines = [l:title, '']
  if writefile(l:lines, l:path) != 0
    echoerr 'Chat: could not create ' . l:path
    return
  endif

  execute 'edit' fnameescape(l:path)
  setlocal filetype=chat
  let b:chat_type = 'conversation'
  let b:chat_conversation = expand('%:p')
  setlocal buftype=
  setlocal bufhidden=
  setlocal noswapfile
  call cursor(1, 1)
endfunction "}
function! chat#Chat(argument) abort "{
  if !empty(trim(a:argument))
    call chat#Submit(trim(a:argument))
    return
  endif

  call chat#buffer#OpenQuestion()
endfunction "}
function! chat#SubmitQuestion() abort "{
  if &l:filetype !=# 'chatquestion'
    echoerr 'Chat: current buffer is not a question buffer'
    return
  endif

  let l:question = join(getline(1, '$'), "\n")
  let l:question = trim(l:question)
  if empty(l:question)
    echoerr 'Chat: question is empty'
    return
  endif

  let l:conversation = get(b:, 'chat_conversation', '')
  if empty(l:conversation) || !filereadable(l:conversation)
    echoerr 'Chat: no active conversation. Run :OpenChat first.'
    return
  endif

  let l:question_buf = bufnr('%')
  call chat#Submit(l:question, l:conversation, l:question_buf)
endfunction "}
function! chat#CancelQuestion() abort "{
  if &l:filetype !=# 'chatquestion'
    echoerr 'Chat: current buffer is not a question buffer'
    return
  endif
  bdelete!
endfunction "}
function! chat#Submit(question, ...) abort "{
  let l:conversation = a:0 >= 1 ? a:1 : chat#history#Current()
  let l:question_buf = a:0 >= 2 ? a:2 : -1

  if empty(l:conversation) || !filereadable(l:conversation)
    echoerr 'Chat: no active conversation. Run :OpenChat {name} first.'
    return
  endif

  let l:question = trim(a:question)
  if empty(l:question)
    echoerr 'Chat: question is empty'
    return
  endif

  let l:history = chat#history#Read(l:conversation)
  if empty(l:history)
    echoerr 'Chat: conversation file has no title'
    return
  endif

  let l:messages = chat#history#Messages(l:history)
  call add(l:messages, {'role': 'user', 'content': l:question})

  echo 'Chat: contacting API...'
  let l:result = chat#api#Request(l:messages)

  if !l:result.ok
    call chat#buffer#OpenError(l:result.error, l:conversation)
    " Keep the question buffer intact so the user can retry.
    return
  endif

  if chat#history#AppendExchange(l:conversation, l:question, l:result.text) != 0
    echoerr 'Chat: response received, but conversation could not be updated'
    call chat#buffer#OpenResponse(l:result.text, l:conversation)
    return
  endif

  if l:question_buf > 0 && bufexists(l:question_buf)
    execute 'silent! bwipeout' l:question_buf
  endif

  call chat#buffer#OpenResponse(l:result.text, l:conversation)
endfunction "}
function! chat#ChatFile(path) abort "{
  let l:path = expand(a:path)
  if !filereadable(l:path)
    echoerr 'Chat: file is not readable: ' . l:path
    return
  endif

  let l:content = join(readfile(l:path, 'b'), "\n")
  let l:question = 'Please consider the following file:' . "\n\n"
        \ . 'File: ' . l:path . "\n\n"
        \ . l:content . "\n\n"
        \ . 'Please help me with this file.'
  call chat#Submit(l:question)
endfunction "}
function! chat#List() abort "{
  call chat#buffer#OpenList(chat#history#Files())
endfunction "}
