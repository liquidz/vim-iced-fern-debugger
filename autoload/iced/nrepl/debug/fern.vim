let s:save_cpo = &cpoptions
set cpoptions&vim

let s:buf = []
let s:res = {}
let s:last_bufnr = -1

let s:using_keys = ['column', 'coor', 'debug-value', 'file', 'line', 'locals']
"let g:iced#debug#fern_traverse_input = get(g:, 'iced#debug#fern_traverse_input', ':continue')
let g:iced#debug#fern_traverse_input = get(g:, 'iced#debug#fern_traverse_input', ':next')

function! s:ensure_dict(x) abort
  let t = type(a:x)
  if t == v:t_dict
    return a:x
  elseif t == v:t_list
    let result = {}
    for x in a:x
      call extend(result, s:ensure_dict(x))
    endfor
    return result
  else
    return {}
  endif
endfunction

function! iced#nrepl#debug#fern#start(resp) abort
  let resp = s:ensure_dict(a:resp)
  call add(s:buf, copy(resp))
  call iced#nrepl#op#cider#debug#input(resp['key'], g:iced#debug#fern_traverse_input)
endfunction

function! iced#nrepl#debug#fern#quit() abort
  if empty(s:buf) | return | endif

  let s = printf('%%0%dd: val = %%s', len(string(len(s:buf))))
  let i = 1
  for step in copy(s:buf)
    let label = printf(s, i, step['debug-value'])
    let s:res[label] = iced#util#select_keys(step, s:using_keys)
    let i += 1
  endfor

  let s:buf = []
  let s:last_bufnr = bufnr('%')

  silent! execute ':Fern iced_debug:/// -drawer'
endfunction

function! iced#nrepl#debug#fern#result() abort
  return copy(s:res)
endfunction

function! iced#nrepl#debug#fern#last_bufnr() abort
  return s:last_bufnr
endfunction

function! iced#nrepl#debug#fern#clear() abort
	"if stridx(bufname('%'), 'fern://') == 0 | return | endif
	call iced#highlight#clear()
  call iced#nrepl#debug#default#close_popup()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
