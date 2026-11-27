if exists('g:loaded_chat_plugin')
  finish
endif
let g:loaded_chat_plugin = 1

" Chat plugin defaults.
if !exists('g:chat_directory')
  let g:chat_directory = '/iasj/proj/chat/conversations'
endif

if !exists('g:chat_credential_file')
  let g:chat_credential_file = '/iasj/cryp/openai.gpg'
endif

if !exists('g:chat_api_url')
  let g:chat_api_url = 'https://api.openai.com/v1/responses'
endif

if !exists('g:chat_model')
  let g:chat_model = 'gpt-4.1-mini'
endif

if !exists('g:chat_max_output_tokens')
  let g:chat_max_output_tokens = 2048
endif

command! -nargs=1 -complete=file ChatOpen call chat#Open(<q-args>)
"command! -nargs=? -complete=file Chat call chat#Chat(<q-args>)
command! -nargs=* -complete=file Chat call chat#Chat(<q-args>)
command! -nargs=1 -complete=file ChatFile call chat#ChatFile(<q-args>)
command! -nargs=0 Chats call chat#List()
command! -nargs=0 ChatSubmit call chat#SubmitQuestion()
command! -nargs=0 ChatCancel call chat#CancelQuestion()

" ---------------------------------------------------------------------------
" Suggested mappings only. Customize or remove these in your own config.
" ---------------------------------------------------------------------------
" nnoremap <leader>cs :call chat#SubmitQuestion()<CR>
" nnoremap <leader>cc :call chat#CancelQuestion()<CR>
