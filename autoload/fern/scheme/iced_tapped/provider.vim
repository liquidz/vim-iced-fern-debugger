let s:save_cpo = &cpoptions
set cpoptions&vim

let s:provider = {
      \ '_update_tree': {-> 0},
      \ '_default_leaf': {-> ''},
      \ '_default_branch': {-> {}},
      \ '_encode': {s -> substitute(s, '/', '%2f', 'g')},
      \ '_decode': {s -> substitute(s, '%2f', '/', 'g')},
      \ }

function! s:provider._parse_path(path) abort dict
  let path = split(a:path, '/')
  let path = map(path, {_, v ->
        \ (type(v) == v:t_string && match(v, '^\d\+$') == 0) ? str2nr(v) : self._decode(v)})
  " Add single quote for symbol
  let path = map(path, {i, v ->
        \ (i != 0 && type(v) == v:t_string && match(v, "^[^:']") == 0) ? printf("'%s", v) : v})
  return path
endfunction

function! s:provider._parse_url(url) abort dict
  return self._parse_path(matchstr(a:url, '^iced_tapped:\zs.*$'))
endfunction

function! s:provider.get_root(url) abort dict
  let path = self._parse_url(a:url)
  return self._node(self, path, 'root', {'name': 'root', 'has-children?': 'true'}, v:null)
endfunction

function! s:provider.get_parent(node, ...) abort dict
  let parent = a:node.concealed._parent
  let parent = parent is# v:null ? copy(a:node) : parent
  return iced#promise#resolve(parent)
endfunction

function! s:provider.get_children(node, ...) abort dict
  try
    if a:node.status is# 0 | throw printf("%s node is leaf", a:node.name) | endif

    let keys = self._parse_path(a:node._path)
    if empty(keys)
      return iced#promise#call('iced#nrepl#op#iced#list_tapped', [])
            \.then({resp -> has_key(resp, 'error') ? iced#promise#reject(resp['error']) : resp})
            \.then({resp -> map(get(resp, 'tapped', []), {_, v ->
            \                   self._node(self, [get(v, 'unique-id')], get(v, 'unique-id'), {'name': get(v, 'value', ''), 'has-children?': 'true'}, a:node)
            \               })})
    else
      return iced#promise#call('iced#nrepl#op#iced#fetch_tapped_children', [keys])
            \.then({resp -> has_key(resp, 'error') ? iced#promise#reject(resp['error']) : resp})
            \.then({resp -> map(get(resp, 'children', []), {_, v -> self._node(self, keys + [v.name], v.name, v, a:node)})})
    endif
  catch
    return iced#promise#reject(v:exception)
  endtry
endfunction

function! s:provider._node(provider, path, name, value, parent) abort
  let path = map(copy(a:path), {_, v -> self._encode(v)})
  let path = '/' . join(path, '/')
  let status = (type(a:value) == v:t_dict && get(a:value, 'has-children?', 'false') ==# 'true')
  let bufname = status ? printf('iced_tapped://%s', path) : v:null
  return {
        \ 'name': a:name,
        \ 'label': a:value.name,
        \ 'status': status,
        \ 'bufname': bufname,
        \ 'concealed': {'_value': a:value, '_parent': a:parent},
        \ '_path': path,
        \}
endfunction

function! fern#scheme#iced_tapped#provider#new() abort
  return s:provider
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
