let s:save_cpo = &cpoptions
set cpoptions&vim

function! fern#scheme#iced_tapped#mapping#init(disable_default_mappings) abort
  call fern#scheme#dict#mapping#init(a:disable_default_mappings)

  if !a:disable_default_mappings
    nnoremap <buffer><silent><nowait> <C-l> :<C-u>call <SID>call('reload')()<CR>
    nnoremap <buffer><silent><nowait> d :<C-u>call <SID>call('remove')<CR>
  endif
endfunction

function! s:reload_root() abort
  let pos = getpos('.')
  normal! gg
  silent! execute "normal \<Plug>(fern-action-reload)"
  call setpos('.', pos)
  return iced#message#info_str('Reloaded.')
endfunction

function! s:call(name, ...) abort
  return call(
        \ 'fern#mapping#call',
        \ [funcref(printf('s:map_%s', a:name))] + a:000,
        \)
endfunction

function! s:map_reload(helper) abort
  let nodes = a:helper.sync.get_selected_nodes()
  let root = a:helper.sync.get_root_node()
  return iced#promise#resolve(v:true)
       \.then({ -> a:helper.async.reload_node(root.__key) })
       \.then({ -> a:helper.async.redraw() })
endfunction

function! s:map_remove(helper) abort
  let provider = a:helper.fern.provider
  let nodes = a:helper.sync.get_selected_nodes()

  for path in map(copy(nodes), { _, v -> provider._parse_path(v._path) })
    let unique_id = path[0]
    call iced#promise#sync('iced#nrepl#op#iced#delete_tapped', [unique_id])
  endfor

  call s:map_reload(a:helper)
  "call s:reload_root()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
