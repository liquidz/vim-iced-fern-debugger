let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:reload_root() abort
  let pos = getpos('.')
  normal! gg
  silent! execute "normal \<Plug>(fern-action-reload)"
  call setpos('.', pos)
  return iced#message#info_str('Reloaded.')
endfunction

function! fern#scheme#iced_tapped#mapping#init(disable_default_mappings) abort
  call fern#scheme#dict#mapping#init(a:disable_default_mappings)

  if !a:disable_default_mappings
    nnoremap <buffer><nowait> <C-l> :<C-u>call <SID>reload_root()<CR>
  endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
