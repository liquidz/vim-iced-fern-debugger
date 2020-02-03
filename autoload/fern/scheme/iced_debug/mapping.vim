let s:save_cpo = &cpoptions
set cpoptions&vim

let s:Promise = vital#fern#import('Async.Promise')

function! fern#scheme#iced_debug#mapping#init(disable_default_mappings) abort
  call fern#scheme#dict#mapping#init(a:disable_default_mappings)

  "nnoremap <buffer><silent> <Plug>(fern-action-open:select) :<C-u>call <SID>call('preview')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-open:edit-or-error) :<C-u>call <SID>call('preview')<CR>
  nnoremap <buffer><silent> <Plug>(fern-action-enter)              :<C-u>call <SID>call('preview')<CR>
endfunction

function! s:call(name, ...) abort
  return call(
       \ "fern#internal#mapping#call",
       \ [funcref(printf('s:map_%s', a:name))] + a:000,
       \)
endfunction

function! s:map_preview(helper) abort
  let node = a:helper.sync.get_cursor_node()

  let value = node.concealed._value
  if type(value) != v:t_dict || !has_key(value, 'debug-value')
    let value = node.concealed._parent.concealed._value
  endif

  let current_bufnr = bufnr('%')
  try
    let bufnr = iced#nrepl#debug#fern#last_bufnr()

    call iced#buffer#focus(bufnr)
    call setpos('.', [bufnr, value.line, value.column, 0])

    call iced#nrepl#debug#default#move_cursor_and_set_highlight(value)

    let debug_texts = iced#nrepl#debug#default#generate_debug_text(value)
    call iced#nrepl#debug#default#show_popup(debug_texts)

  finally
    call iced#buffer#focus(current_bufnr)
  endtry

  return s:Promise.resolve()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
