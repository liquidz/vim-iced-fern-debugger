let s:save_cpo = &cpoptions
set cpoptions&vim

let s:hidden_prefixes = ['coor', 'line', 'column']

function! fern#scheme#iced_debug#provider#new() abort
  let tree = iced#nrepl#debug#fern#result()
  let provider = fern#scheme#dict#provider#new(tree)
  let provider = extend(provider, {
       \ '_extend_node': funcref('s:extend_node'),
       \ })
  return provider
endfunction

function! s:extend_node(node) abort
  for prefix in s:hidden_prefixes
    if stridx(a:node.name, prefix) == 0
      return extend(a:node, {'hidden': 1})
    endif
  endfor

  return a:node
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
