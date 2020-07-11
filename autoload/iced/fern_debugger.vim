let s:save_cpo = &cpoptions
set cpoptions&vim

function! iced#fern_debugger#open(url) abort
  silent! execute printf(':Fern iced_tapped:///%s -drawer -width=%d',
        \ a:url,
        \ g:vim_iced_fern_drawer_width,
        \ )
endfunction

function! iced#fern_debugger#open_last() abort
  return iced#promise#call('iced#nrepl#op#iced#list_tapped', [])
        \.then({resp -> has_key(resp, 'error')
        \               ? iced#promise#reject(resp['error'])
        \               : resp})
        \.then({resp -> len(get(resp, 'tapped', [])) - 1})
        \.then({idx -> (idx >= 0) ? iced#fern_debugger#open(idx) : iced#promise#reject('not found')})
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
