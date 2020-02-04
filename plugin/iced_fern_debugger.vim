if exists('g:vim_iced_fern_debugger_loaded')
  finish
endif
let g:vim_iced_fern_debugger_loaded = 1

let g:iced#debug#debugger = 'fern'
