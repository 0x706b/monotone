"
" m o n o t o n e
"
"
" Copyright 2018 Kim Silkebækken
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.

if exists('g:loaded_monotone')
  finish
endif
if !exists('g:monotone_color')
  let g:monotone_color = [5, 3, 82]
endif
if !exists('g:monotone_secondary_hue_offset')
  let g:monotone_secondary_hue_offset = 0
endif
if !exists('g:monotone_emphasize_comments')
  let g:monotone_emphasize_comments = 0
endif
if !exists('g:monotone_emphasize_whitespace')
  let g:monotone_emphasize_whitespace = 0
endif
if !exists('g:monotone_contrast_factor')
  let g:monotone_contrast_factor = 1
endif
if !exists('g:monotone_brightness_factor')
  let g:monotone_brightness_factor = 1
endif

let g:loaded_monotone = 1

function s:HSLToHex(h, s, l)
  " http://www.easyrgb.com/en/math.php#text19
  " normalize the angle into the 0-360 range
  " see: http://www.w3.org/TR/css3-color/#hsl-color
  let h = a:h >= 0 && a:h <= 360 ? a:h/360.0 : (((a:h % 360) + 360) % 360)/360.0
  let s = a:s/100.0
  let l = a:l/100.0

  let rgb = {}
  let var_2 = l < 0.5 ? l * (1.0 + s) : (l + s) - (s * l)
  let var_1 = 2 * l - var_2

  let rgb.r = s:Hue2RGB(var_1, var_2, h + (1.0/3))
  let rgb.g = s:Hue2RGB(var_1, var_2, h)
  let rgb.b = s:Hue2RGB(var_1, var_2, h - (1.0/3))

  let rgb = map(rgb, 'float2nr((v:val < 0 ? 0 : v:val) * 255)')

  return printf('#%02x%02x%02x', rgb.r, rgb.g, rgb.b)
endfunction

function s:Hue2RGB(v1, v2, vH)
  let H = a:vH
  if H < 0 | let H += 1 | endif
  if H > 1 | let H -= 1 | endif
  if (6 * H) < 1 | return a:v1 + (a:v2 - a:v1) * 6 * H | endif
  if (2 * H) < 1 | return a:v2 | endif
  if (3 * H) < 2 | return a:v1 + (a:v2 - a:v1) * ((2.0/3) - H) * 6 | endif
  return a:v1
endfunction

function s:Shade(color, offset, brightness_factor)
  let h = a:color[0]
  let s = a:color[1]
  let l = (a:color[2] - a:offset) * a:brightness_factor
  let l = l < 1 ? 1 : l > 100 ? 100 : l
  return s:HSLToHex(h, s, l)
endfunction

function s:MonotoneColors(color, secondary_hue_offset, emphasize_comments, emphasize_whitespace, contrast_factor, brightness_factor)
  let s:color_normal   = s:Shade(a:color, 0, a:brightness_factor - 0.1)
  let s:color_dark_0   = s:Shade(a:color, 60 * a:contrast_factor, 1)
  let s:color_dark_1   = s:Shade(a:color, 69 * a:contrast_factor, 1)
  let s:color_dark_2   = s:Shade(a:color, 73 * a:contrast_factor, 1)
  let s:color_dark_3   = s:Shade(a:color, 75 * a:contrast_factor, 1)
  let s:color_bright_0 = s:Shade(a:color, 46, a:brightness_factor)
  let s:color_bright_1 = s:Shade(a:color, 36, a:brightness_factor)
  let s:color_bright_2 = s:Shade(a:color, 22, a:brightness_factor)

  let s:color_hl_1   = s:HSLToHex(a:secondary_hue_offset,       90 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)
  let s:color_hl_2   = s:HSLToHex(a:secondary_hue_offset + 35,  90 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)
  let s:color_hl_3   = s:HSLToHex(a:secondary_hue_offset + 200, 90 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)
  let s:color_eob    = s:HSLToHex(a:secondary_hue_offset,       40 * a:brightness_factor, (a:color[2] - 50) * a:brightness_factor)
  let s:color_nt     = s:HSLToHex(a:secondary_hue_offset + 10,  45 * a:brightness_factor, (a:color[2] - 40) * a:brightness_factor)

  let s:color_em_1   = s:HSLToHex(a:secondary_hue_offset + 35,  60 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)
  let s:color_em_2   = s:HSLToHex(a:secondary_hue_offset + 115, 20 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)
  let s:color_em_3   = s:HSLToHex(a:secondary_hue_offset,       60 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)
  let s:color_em_4   = s:HSLToHex(a:secondary_hue_offset + 200, 30 * a:brightness_factor, (a:color[2] - 20) * a:brightness_factor)

  hi clear
  syntax reset
  let g:colors_name = 'monotone'

  function! s:Hi(group, guifg, guibg, ctermfg, ctermbg, attr)
    exec printf('hi %s guifg=%s guibg=%s gui=%s ctermfg=%s ctermbg=%s cterm=%s',
      \ a:group, a:guifg, a:guibg, a:attr, a:ctermfg, a:ctermbg, a:attr)
  endfunction

  function! s:HiFG(group, guifg, ctermfg, attr)
    exec printf('hi %s guifg=%s gui=%s ctermfg=%s cterm=%s',
      \ a:group, a:guifg, a:attr, a:ctermfg, a:attr)
  endfunction

  function! s:HiBG(group, guibg, ctermbg, attr)
    exec printf('hi %s guibg=%s gui=%s ctermbg=%s cterm=%s',
      \ a:group, a:guibg, a:attr, a:ctermbg, a:attr)
  endfunction

  call s:HiFG('NormalTransparent', s:color_normal, 'NONE', 'NONE')

  " Main colors
  call s:Hi('Normal', s:color_normal, s:color_dark_3, 252, 233, 'NONE')
  call s:Hi('Visual', s:color_dark_3, s:color_normal, 16, 248, 'NONE')

  " Cursors
  call s:HiBG('Cursor', s:color_hl_1, 203, 'NONE') " Normal cursor
  call s:HiBG('CursorI', '#ffffff', 255, 'NONE') " Insert cursor
  call s:HiBG('CursorR', s:color_hl_2, 203, 'NONE') " Replace cursor
  call s:HiBG('CursorO', s:color_hl_3, 39, 'NONE') " Operator-pending cursor

  " UI/special
  call s:Hi('ColorColumn', 'NONE', s:color_dark_2, 'NONE', 234, 'NONE')
  call s:Hi('CursorLine', 'NONE', s:color_dark_1, 'NONE', 234, 'NONE')
  call s:Hi('CursorLineNr', s:color_bright_2, s:color_dark_1, 'NONE', 235, 'NONE')
  call s:Hi('CursorLineNrIt', s:color_bright_2, s:color_dark_1, 'NONE', 235, 'italic')
  call s:Hi('Folded', s:color_normal, s:color_dark_1, 252, 235, 'italic')
  call s:Hi('Search', s:color_dark_3, s:color_hl_2, 16, 214, 'bold')
  call s:Hi('IncSearch', s:color_dark_3, s:color_hl_2, 16, 214, 'bold,reverse')
  call s:Hi('LineNr', s:color_bright_0, 'NONE', 240, 'NONE', 'NONE')
  call s:Hi('VertSplit', s:color_bright_0, 'NONE', 240, 'NONE', 'NONE')
  call s:Hi('WildMenu', s:color_dark_3, s:color_normal, 16, 248, 'NONE')
  hi SpecialKey    guifg=NONE     guibg=NONE     gui=bold    ctermfg=NONE  ctermbg=NONE  cterm=bold
  hi clear         FoldColumn
  hi clear         SignColumn

  " Messages
  call s:Hi('Error', s:color_hl_1, 'NONE', 203, 'NONE', 'bold')
  call s:Hi('ErrorMsg', s:color_hl_1, 'NONE', 203, 'NONE', 'bold')
  call s:Hi('Warning', s:color_hl_2, 'NONE', 214, 'NONE', 'NONE')
  call s:Hi('WarningMsg', s:color_hl_2, 'NONE', 214, 'NONE', 'bold')
  call s:Hi('MoreMsg', s:color_hl_3, 'NONE', 153, 'NONE', 'bold')

  " Parens
  call s:Hi('MatchParen', s:color_dark_3, s:color_hl_2, 16, 214, 'NONE')
  hi link ParenMatch MatchParen

  " Popup menu
  call s:Hi('Pmenu', s:color_bright_1, s:color_dark_2, 246, 235, 'NONE')
  call s:Hi('PmenuSbar', 'NONE', s:color_dark_2, 'NONE', 235, 'NONE')
  call s:Hi('PmenuSel', s:color_dark_2, s:color_bright_2, 252, 235, 'NONE')
  call s:Hi('PmenuThumb', 'NONE', s:color_dark_0, 'NONE', 235, 'NONE')

  " Statusline
  call s:Hi('StatusLine', s:color_bright_2, s:color_dark_1, 248, 'NONE', 'NONE')
  call s:Hi('StatusLineNC', s:color_bright_0, 'NONE', 240, 'NONE', 'NONE')

  " Tabline
  call s:Hi('TabLine', s:color_bright_0, 'NONE', 240, 'NONE', 'NONE')
  call s:Hi('TabLineFill', s:color_bright_0, 'NONE', 240, 'NONE', 'NONE')
  call s:Hi('TabLineSel', s:color_bright_2, 'NONE', 248, 'NONE', 'bold')

  " Highlighted syntax items
  call s:HiFG('Comment', a:emphasize_comments ? s:color_hl_2 : s:color_bright_1, 243, 'italic')
  
  call s:HiFG('String', s:color_em_2, 247, 'NONE')
  call s:HiFG('Number', s:color_em_1, 'NONE', 'NONE')
  call s:HiFG('Type', s:color_em_4, 'NONE', 'bold')
  call s:HiFG('Delimiter', s:color_em_3, 'NONE', 'NONE')
  hi! link Operator Delimiter

  call s:Hi('EndOfBuffer', s:color_eob, 'NONE', 95, 'NONE', 'NONE')
  call s:Hi('NonText', s:color_nt, 'NONE', 95, 'NONE', 'NONE')
  call s:Hi('Todo', s:color_hl_2, 'NONE', 214, 'NONE', 'bold,italic')
  if a:emphasize_whitespace
    call s:Hi('Whitespace', s:color_hl_1, 'NONE', 203, 'NONE', 'bold')
  else
    call s:Hi('Whitespace', s:color_dark_0, 'NONE', 236, 'NONE', 'NONE')
  endif

  " Font style syntax items
  hi Function     guifg=NONE     guibg=NONE  gui=NONE       ctermfg=NONE  ctermbg=NONE  cterm=NONE
  hi Identifier   guifg=NONE     guibg=NONE  gui=italic       ctermfg=NONE  ctermbg=NONE  cterm=italic
  hi Include      guifg=NONE     guibg=NONE  gui=italic       ctermfg=NONE  ctermbg=NONE  cterm=italic
  hi Keyword      guifg=NONE     guibg=NONE  gui=bold         ctermfg=NONE  ctermbg=NONE  cterm=bold
  hi Question     guifg=NONE     guibg=NONE  gui=italic         ctermfg=NONE  ctermbg=NONE  cterm=italic
  hi Statement    guifg=NONE     guibg=NONE  gui=bold         ctermfg=NONE  ctermbg=NONE  cterm=bold
  hi Special      guifg=NONE     guibg=NONE  gui=bold         ctermfg=NONE  ctermbg=NONE  cterm=bold
  hi Underlined   guifg=NONE     guibg=NONE  gui=underline    ctermfg=NONE  ctermbg=NONE  cterm=underline
  hi Title        guifg=NONE     guibg=NONE  gui=bold         ctermfg=NONE  ctermbg=NONE  cterm=bold

  " Diff highlighting
  hi DiffAdd     guifg=#88aa77  guibg=NONE  gui=NONE       ctermfg=107  ctermbg=NONE  cterm=NONE
  hi DiffDelete  guifg=#aa7766  guibg=NONE  gui=NONE       ctermfg=137  ctermbg=NONE  cterm=NONE
  hi DiffChange  guifg=#7788aa  guibg=NONE  gui=NONE       ctermfg=67   ctermbg=NONE  cterm=NONE
  hi DiffText    guifg=#7788aa  guibg=NONE  gui=underline  ctermfg=67   ctermbg=NONE  cterm=underline

  " Quickfix window (some groups need custom 'winhl')
  hi QuickFixLine guibg=#333333
  hi QFNormal guibg=#222222
  hi QFEndOfBuffer guifg=#222222

  " Non-highlighted syntax items
  hi clear Conceal
  hi clear Constant
  hi clear Define
  hi clear Directory
  hi clear Label
  " hi clear Operator
  " hi clear Special
  hi clear PreProc
  hi clear Noise

  " Plugin-specific highlighting
  hi link CursorWordHighlight Underlined
  hi link CocHighlightText Underlined

  " ALE
  hi ALEError       guisp=#ff4444 gui=undercurl ctermfg=203 cterm=underline
  hi ALEWarning     guisp=#dd9922 gui=undercurl ctermfg=214 cterm=underline
  hi ALEErrorSign   guifg=#ff4444 ctermfg=203
  hi ALEWarningSign guifg=#dd9922 ctermfg=214

  " Spelling
  hi clear SpellBad
  hi clear SpellCap
  hi clear SpellRare
  hi clear SpellLocal
  hi link SpellBad   ALEError
  hi link SpellCap   ALEError
  hi link SpellRare  ALEError
  hi link SpellLocal ALEWarning

  " COC
  hi CocErrorHighlight   guisp=#ff4444 gui=undercurl ctermfg=203 cterm=underline
  hi CocWarningHighlight guisp=#dd9922 gui=undercurl ctermfg=214 cterm=underline
  hi CocInfoHighlight    guisp=#00afff gui=undercurl ctermfg=153 cterm=underline
  hi CocHintHighlight    guisp=#00afff gui=undercurl ctermfg=153 cterm=underline
  hi CocErrorSign        guifg=#ff4444 ctermfg=203
  hi CocWarningSign      guifg=#dd9922 ctermfg=214
  hi CocInfoSign         guifg=#00afff ctermfg=153
  hi CocHintSign         guifg=#00afff ctermfg=153

  call s:HiFG('CocUnderline', s:color_normal, 'NONE', 'bold,underline')

  " Sneak
  call s:Hi('Sneak', '#000000', s:color_hl_3, 16, 153, 'NONE')
  call s:Hi('SneakLabel', '#000000', s:color_hl_3, 16, 153, 'bold')
  call s:Hi('SneakLabelMask', s:color_hl_3, s:color_hl_3, 153, 153, 'NONE')

  " QuickScope
  hi QuickScopePrimary gui=underline guisp=#ff4444
  hi QuickScopeSecondary gui=underline guisp=#ff4444

  " Highlightedyank
  hi link HighlightedyankRegion Warning

  " yats.vim syntax
  call s:HiFG('typescriptObjectLabel', s:color_normal, 'NONE', 'NONE')
  call s:HiFG('typescriptCall', s:color_normal, 'NONE', 'italic')
  call s:HiFG('typescriptOperator', s:color_em_3, 'NONE', 'bold')
  hi! link typescriptTypeReference Type
  hi! link typescriptTypeParameter Type
  hi! link typescriptArrowFunc Statement
  hi! link typescriptParens Delimiter
  hi! link typescriptBraces Delimiter
  hi! link typescriptArrowFuncArg typescriptCall
  hi! link typescriptTypeBrackets Delimiter
  hi! link typescriptDotNotation Delimiter
  hi! link typescriptTypeAnnotation Delimiter
  hi! link typescriptBinaryOp typescriptOperator
  hi! link typescriptTernaryOp typescriptOperator
  hi! link typescriptTypeQuery typescriptOperator
  hi! link typescriptMappedIn typescriptOperator
  hi! link typescriptAssign typescriptOperator
  hi! link typescriptUnaryOp typescriptOperator
  hi! link typescriptBracket Delimiter
  hi! link typescriptPredefinedType Special
  hi! link typescriptTypeArguments Delimiter
  hi! link typescriptInterfaceName Type
  hi! link typescriptClassName Type
  hi! link typescriptAliasDeclaration Type
  hi! link typescriptNull Number
  hi! link typescriptBoolean Number
  hi! link tsxIntrinsicTagName Special
  hi! link tsxTagName Type
  hi! link tsxTag Delimiter
  hi! link tsxCloseTag Delimiter
  hi! link tsxCloseString Delimiter
  hi! link tsxAttrib NormalTransparent
  hi! link tsxEqual Delimiter
  call s:HiFG('typescriptDocNotation', s:color_bright_1, 'NONE', 'bolditalic')
  hi! link typescriptDocTags typescriptDocNotation

  hi! link jsxTagName Special
  hi! link jsxComponentName Type
  hi! link jsxOpenPunct Delimiter
  hi! link jsxClosePunct Delimiter
  hi! link jsxCloseString Delimiter
  hi! link jsxAttrib NormalTransparent

  "scala syntax

  call s:HiFG('scalaSquareBracketBracket', s:color_em_3, 'NONE', 'NONE')
  call s:HiFG('scalaRoundBrackets', s:color_em_3, 'NONE', 'NONE')
  call s:HiFG('scalaTypeOperator', s:color_em_3, 'NONE', 'bold')
  call s:HiFG('scalaKeywordModifier', s:color_normal, 'NONE', 'bold')

  " lsp

  hi LspDiagnosticsUnderlineError   guisp=#ff4444 gui=undercurl ctermfg=203 cterm=underline
  hi LspDiagnosticsUnderlineWarning guisp=#dd9922 gui=undercurl ctermfg=214 cterm=underline
  hi LspDiagnosticsUnderlineInfo    guisp=#00afff gui=undercurl ctermfg=153 cterm=underline
  hi LspDiagnosticsUnderlineHint    guisp=#00afff gui=undercurl ctermfg=153 cterm=underline
  hi LspDiagnosticsDefaultError     guifg=#ff4444 ctermfg=203
  hi LspDiagnosticsDefaultWarning   guifg=#dd9922 ctermfg=214
  hi LspDiagnosticsDefaultInfo      guifg=#00afff ctermfg=153
  hi LspDiagnosticsDefaultHint      guifg=#00afff ctermfg=153

  hi! link LspSagaDiagnosticBorder NormalTransparent
  hi! link LspSagaDiagnosticTruncateLine NormalTransparent
  hi! link LspSagaDiagnosticHeader WarningMsg
  hi! link LspSagaCodeActionTitle WarningMsg
  hi! link NormalFloat NormalTransparent
  hi! link LspSagaDiagnosticTruncateLine NormalTransparent
  hi! link LspSagaShTruncateLine NormalTransparent
  hi! link LspSagaDocTruncateLine NormalTransparent
  hi! link LspSagaCodeActionTitle NormalTransparent


  " telescope
  hi! link TelescopeSelection CursorLine

  hi! link LspReferenceText Underlined
  hi! link LspReferenceRead Underlined
  hi! link LspReferenceWrite Underlined

  hi! link TSTypeBuiltin Special
  hi! link TSInclude NormalTransparent
  hi! link TSProperty NormalTransparent

endfunction

call s:MonotoneColors(
  \ g:monotone_color,
  \ g:monotone_secondary_hue_offset,
  \ g:monotone_emphasize_comments,
  \ g:monotone_emphasize_whitespace,
  \ g:monotone_contrast_factor,
  \ g:monotone_brightness_factor)

function g:Monotone(h, s, l, ...)
  let l:secondary_hue_offset = a:0 > 0 ? a:1 : g:monotone_secondary_hue_offset
  let l:emphasize_comments = a:0 > 1 ? a:2 : g:monotone_emphasize_comments
  let l:emphasize_whitespace = a:0 > 2 ? a:3 : g:monotone_emphasize_whitespace
  let l:contrast_factor = a:0 > 3 ? str2float(a:4) : g:monotone_contrast_factor
  let l:brightness_factor = a:0 > 4 ? str2float(a:5) : g:monotone_brightness_factor
  call s:MonotoneColors(
    \ [a:h, a:s, a:l],
    \ l:secondary_hue_offset,
    \ l:emphasize_comments,
    \ l:emphasize_whitespace,
    \ l:contrast_factor,
    \ l:brightness_factor)
endfunction

command! -nargs=+ Monotone call g:Monotone(<f-args>)
