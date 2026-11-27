" OpenAI Responses API transport.
" curl reads its configuration from stdin so the API key is not included
" in curl's process arguments. The JSON request body is passed separately.

function! chat#api#Request(messages) abort "{
  if !executable('curl')
    return {'ok': 0, 'error': 'curl executable not found'}
  endif
  if !exists('*json_encode') || !exists('*json_decode')
    return {'ok': 0, 'error': 'This Vim build has no JSON support'}
  endif

  let l:credential = chat#cryp#Decrypt(g:chat_credential_file)
  if !l:credential.ok
    return {'ok': 0, 'error': l:credential.error}
  endif

  let l:body = {
        \ 'model': g:chat_model,
        \ 'input': a:messages,
        \ 'max_output_tokens': g:chat_max_output_tokens
        \ }

  let l:body_file = tempname()
  let l:response_file = tempname()
  if writefile([json_encode(l:body)], l:body_file, 'b') != 0
    call delete(l:body_file)
    return {'ok': 0, 'error': 'Could not write temporary request body'}
  endif

  let l:curl_config = [
        \ 'silent',
        \ 'show-error',
        \ 'fail-with-body',
        \ 'request = "POST"',
        \ 'url = "' . substitute(g:chat_api_url, '"', '\\"', 'g') . '"',
        \ 'header = "Content-Type: application/json"',
        \ 'header = "Authorization: Bearer ' . substitute(l:credential.token, '"', '\\"', 'g') . '"',
        \ 'data-binary = "@' . substitute(l:body_file, '"', '\\"', 'g') . '"',
        \ 'output = "' . substitute(l:response_file, '"', '\\"', 'g') . '"'
        \ ]

  let l:config = join(l:curl_config, "\n") . "\n"
  let l:curl_output = system('curl --config -', l:config)
  let l:curl_status = v:shell_error

  let l:credential.token = ''
  call delete(l:body_file)

  if !filereadable(l:response_file)
    call delete(l:response_file)
    return {'ok': 0, 'error': empty(l:curl_output)
          \ ? 'curl failed (exit ' . l:curl_status . ')'
          \ : l:curl_output}
  endif

  let l:raw = join(readfile(l:response_file, 'b'), "\n")
  call delete(l:response_file)

  try
    let l:data = json_decode(l:raw)
  catch
    return {'ok': 0, 'error': 'Could not parse API response: ' . l:raw}
  endtry

  if l:curl_status != 0 || has_key(l:data, 'error')
    let l:message = get(get(l:data, 'error', {}), 'message', '')
    if empty(l:message)
      let l:message = !empty(l:curl_output) ? l:curl_output
            \ : 'API request failed (curl exit ' . l:curl_status . ')'
    endif
    return {'ok': 0, 'error': l:message}
  endif

  let l:text = ''
  for l:item in get(l:data, 'output', [])
    if get(l:item, 'type', '') ==# 'message'
      for l:part in get(l:item, 'content', [])
        if get(l:part, 'type', '') ==# 'output_text'
          let l:text .= get(l:part, 'text', '')
        endif
      endfor
    endif
  endfor

  if empty(l:text)
    return {'ok': 0, 'error': 'API returned no output text'}
  endif

  return {'ok': 1, 'text': l:text}
endfunction "}
