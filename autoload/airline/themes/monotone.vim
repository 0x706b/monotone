let g:airline#themes#monotone#palette = {}


function! airline#themes#monotone#refresh()

  let s:SL = airline#themes#get_highlight2(['StatusLine', 'fg'], ['LineNr', 'bg'])
  let s:SLNC = airline#themes#get_highlight2(['StatusLineNC', 'fg'], ['StatusLineNC', 'bg'])

  let s:SLWARN = airline#themes#get_highlight2(['WarningMsg', 'bg'], ['WarningMsg', 'fg'])
  let s:SLERR  = airline#themes#get_highlight2(['ErrorMsg', 'bg'], ['ErrorMsg', 'fg'])

  let s:Normal = airline#themes#get_highlight2(['CursorLineNr', 'fg'], ['CursorLineNr', 'bg'])
  let s:Insert = airline#themes#get_highlight2(['CursorLineNrIt', 'fg'], ['CursorLineNrIt', 'bg'], 'italic')

  let g:airline#themes#monotone#palette.normal = airline#themes#generate_color_map(s:Normal, s:SL, s:SL)
  let g:airline#themes#monotone#palette.normal.airline_error   = s:SLERR
  let g:airline#themes#monotone#palette.normal.airline_warning = s:SLWARN
  let g:airline#themes#monotone#palette.normal.airline_term    = s:SL

  let g:airline#themes#monotone#palette.insert = airline#themes#generate_color_map(s:Insert, s:SL, s:SL)
  let g:airline#themes#monotone#palette.insert.airline_error   = s:SLERR
  let g:airline#themes#monotone#palette.insert.airline_warning = s:SLWARN
  let g:airline#themes#monotone#palette.insert.airline_term    = s:SL

  let g:airline#themes#monotone#palette.replace = g:airline#themes#monotone#palette.normal
  let g:airline#themes#monotone#palette.visual = g:airline#themes#monotone#palette.normal

  let g:airline#themes#monotone#palette.inactive = airline#themes#generate_color_map(s:SLNC, s:SLNC, s:SLNC)

    
endfunction

call airline#themes#monotone#refresh()
