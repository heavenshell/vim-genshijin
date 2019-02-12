set encoding=utf-8
let s:save_cpo = &cpo
set cpo&vim

let g:cotoha_client_id = get(g:, 'cotoha_client_id', '')
let g:cotoha_client_secret = get(g:, 'cotoha_client_secret', '')
let s:base_url = 'https://api.ce-cotoha.com/api/dev/nlp/'
let s:token_url = 'https://api.ce-cotoha.com/v1/oauth/accesstokens'
let s:parse_url = s:base_url . 'v1/parse'

let s:headers = {
  \ 'Content-Type': 'application/json',
  \ 'charset': 'UTF-8',
  \ }
let s:auth_data = {
  \ 'grantType': 'client_credentials',
  \ 'clientId': g:cotoha_client_id,
  \ 'clientSecret': g:cotoha_client_secret,
  \ }

function! s:get_text()
  let mode = visualmode(1)
  if mode == 'v' || mode == 'V' || mode == ''
    let [start_lnum, start_colnum] = getpos("'<")[1 : 2]
    let [end_lnum, end_colnum] = getpos("'>")[1 : 2]
    let lines = getline(start_lnum, end_lnum)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: end_colnum - 2]
    let lines[0] = lines[0][start_colnum - 1:]
    let text = join(lines, "\n")
    return { 'text': text, 'start_lnum': start_lnum, 'end_lnum': end_lnum, 'start_colnum': start_colnum, 'end_colnum': end_colnum }
  endif

  return {}
endfunction

function! s:auth() abort
  let r = webapi#http#post(s:token_url, json_encode(s:auth_data), s:headers)
  if r['status'] == 201
    return json_decode(r['content'])['access_token']
  endif
  return ''
endfunction

function! s:send(sentence, access_token) abort
  let headers = {
    \ 'Content-Type': 'application/json',
    \ 'charset': 'UTF-8',
    \ 'Authorization': printf('Bearer %s', a:access_token),
    \ }
  let data = {
    \ 'sentence': a:sentence,
    \ 'type': 'default'
    \ }

  let r = webapi#http#post(s:parse_url, json_encode(data), headers)
  if r['status'] == 200
    return json_decode(r['content'])
  endif
  return {}
endfunction

function! s:parse(content) abort
  let results = []
  for chunks in a:content['result']
    for token in chunks['tokens']
      if token['pos'] != '格助詞'
          \ && token['pos'] != '連用助詞'
          \ && token['pos'] != '引用助詞'
          \ && token['pos'] != '終助詞'
        call add(results, token['kana'])
      endif
    endfor
  endfor
  return results
endfunction

function! genshijin#run(...) abort
  let data = s:get_text()
  let text = has_key(data, 'text') ? data['text'] : a:000[0]
  if text == ''
    return
  endif

  let access_token = s:auth()
  if access_token == ''
    return
  endif

  let content = s:send(text, access_token)
  if content == {}
    return
  endif

  let results = s:parse(content)
  if has_key(data, 'start_lnum')
    " Replace current
    let sentence = split(join(results, ' '), '  ')
    call setline(data['start_lnum'], sentence)
  else
    echomsg join(results, ' ')
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
