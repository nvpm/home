function! chat#buffer#OpenQuestion() abort
  let l:conversation = chat#history#Current()
  if empty(l:conversation) || !filereadable(l:conversation)
    echoerr 'Chat: open a conversation first with :OpenChat {name}'
    return
  endif

  "botright new
  execute 'hide edit' fnameescape(tempname())

  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal modifiable
  setlocal filetype=chatquestion
  let b:chat_type = 'question'
  let b:chat_conversation = l:conversation
  file ChatQuestion
  call setline(1, [''])
  setlocal modified
  echo 'Write your question, then submit it with chat#SubmitQuestion()'
endfunction

function! chat#buffer#OpenResponse(text, conversation) abort

  "botright new
  execute 'hide edit' fnameescape(tempname())

  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal filetype=markdown
  let b:chat_type = 'response'
  let b:chat_conversation = a:conversation
  let l:title = fnamemodify(a:conversation, ':t')
  let l:lines = ['# ' . l:title, '', a:text]
  call setline(1, l:lines)
  setlocal nomodified
  setlocal nomodifiable
  execute 'file' fnameescape('ChatResponse-' . strftime('%Y%m%d-%H%M%S') . '-' . bufnr('%'))
endfunction

function! chat#buffer#OpenError(message, conversation) abort

  "botright new
  execute 'hide edit' fnameescape(tempname())

  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal filetype=markdown
  let b:chat_type = 'error'
  let b:chat_conversation = a:conversation
  call setline(1, ['# Chat API error', '', a:message,
        \ '', 'Conversation was not modified.'])
  setlocal nomodified
  setlocal nomodifiable
  execute 'file' fnameescape('ChatError-' . strftime('%Y%m%d-%H%M%S') . '-' . bufnr('%'))
endfunction

function! chat#buffer#OpenList(paths) abort

  "botright new
  execute 'hide edit' fnameescape(tempname())

  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal noswapfile
  setlocal filetype=chatlist
  let b:chat_type = 'list'
  let b:chat_paths = copy(a:paths)
  let l:lines = empty(a:paths) ? ['No conversations found.'] : []
  for l:path in a:paths
    call add(l:lines, fnamemodify(l:path, ':t:r'))
  endfor
  call setline(1, l:lines)
  setlocal nomodified
  nnoremap <silent><buffer> <CR> :call chat#buffer#SelectConversation()<CR>
  echo 'Select a conversation and press Enter'
endfunction

function! chat#buffer#SelectConversation() abort
  let l:index = line('.') - (empty(get(b:, 'chat_paths', [])) ? 0 : 1)
  if l:index < 0 || l:index >= len(get(b:, 'chat_paths', []))
    return
  endif
  let l:path = b:chat_paths[l:index]
  execute 'edit' fnameescape(l:path)
  let b:chat_type = 'conversation'
  setlocal filetype=chat
endfunction
