if exists('g:vim_iced_fern_debugger_loaded')
  finish
endif

if empty(globpath(&rtp, 'autoload/fern.vim'))
	echoe 'lambdalisue/fern.vim is required.'
  finish
endif

if !exists('g:vim_iced_version')
      \ || g:vim_iced_version < 20101
  echoe 'iced-fern-debugger requires vim-iced v2.1.1 or later.'
  finish
endif

let g:vim_iced_fern_debugger_loaded = 1

if !exists('g:vim_iced_fern_drawer_width')
	let g:vim_iced_fern_drawer_width = 30
endif

let s:last_debugger = 'default'
function! s:toggle_debugger() abort
  if g:iced#debug#debugger !=# 'fern'
    let s:last_debugger = g:iced#debug#debugger
    let g:iced#debug#debugger = 'fern'
  else
    let g:iced#debug#debugger = s:last_debugger
  endif

  return iced#message#info_str(printf('Switch debugger to "%s".', g:iced#debug#debugger))
endfunction

command! IcedBrowseTappedFern call iced#fern_debugger#open('')
command! IcedBrowseLastTappedFern call iced#fern_debugger#open_last()
command! IcedToggleFernDebugger call s:toggle_debugger()

if !exists('g:iced#palette')
  let g:iced#palette = {}
endif
call extend(g:iced#palette, {
      \ 'BrowseTappedFern': ':IcedBrowseTappedFern',
      \ 'BrowseLastTappedFern': ':IcedBrowseLastTappedFern',
      \ 'ToggleFernDebugger': ':IcedToggleFernDebugger',
      \ })
