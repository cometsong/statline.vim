" ============================================================================
" File:        statline.vim
" Maintainer:  Miller Medeiros <http://blog.millermedeiros.com/>
" Description: Add useful info to the statusline and basic error checking.
" Last Change: 2011-11-10
" License:     This program is free software. It comes without any warranty,
"              to the extent permitted by applicable law. You can redistribute
"              it and/or modify it under the terms of the Do What The Fuck You
"              Want To Public License, Version 2, as published by Sam Hocevar.
"              See http://sam.zoy.org/wtfpl/COPYING for more details.
" ============================================================================

if exists("g:loaded_statline_plugin")
    finish
endif
let g:loaded_statline_plugin = 1


" always display statusline (iss #3)
set laststatus=2


" ====== colors ====== {{{

" using link instead of named highlight group inside the statusline to make it
" easier to customize, reseting the User[n] highlight will remove the link.
" Another benefit is that colors will adapt to colorscheme.

"filename
hi default link User1 Identifier
" flags
hi default link User2 Statement
" errors
hi default link User3 Error
" fugitive
hi default link User4 Special
" mode alert
hi default link User5 ErrorMsg

"}}}


" ====== basic info ======

" ---- set default value of variable ---- {{{
function s:SetDefaultVal(var, val)
    if !exists({'a:var'})
        let {a:var} = a:val
    endif
endfunction
"}}}

" ---- number of buffers : buffer number ---- {{{
call s:SetDefaultVal('g:statline_show_n_buffers', '1')

function! StatlineBufCount()
    if !exists("s:statline_n_buffers")
        let s:statline_n_buffers = len(filter(range(1,bufnr('$')), 'buflisted(v:val)'))
    endif
    return s:statline_n_buffers
endfunction

if g:statline_show_n_buffers
    set statusline=[%{StatlineBufCount()}\:%n]\ %<
    " only calculate buffers after adding/removing buffers
    augroup statline_nbuf
        autocmd!
        autocmd BufAdd,BufDelete * unlet! s:statline_n_buffers
    augroup END
else
    set statusline=[%n]\ %<
endif
"}}}

" ---- filepath ---- {{{
call s:SetDefaultVal('g:statline_show_filepath', '0')
if g:statline_show_filepath
    set statusline+=[%{getcwd()}]\ 
endif
"}}}

" ---- filename (relative or tail) ---- {{{
call s:SetDefaultVal('g:statline_filename_relative', '0')
call s:SetDefaultVal('g:statline_filename_absolute', '0')

if exists('g:statline_filename_relative')
    set statusline+=%1*[%f]%*
elseif exists('g:statline_filename_absolute')
    set statusline+=%1*[%F]%*
else
    set statusline+=%1*[%t]%*
endif
"}}}

" ---- flags ---- {{{
call s:SetDefaultVal('g:statline_show_flags', '1')
" (h:help:[help], w:window:[Preview], m:modified:[+][-], r:readonly:[RO])
if g:statline_show_flags
    set statusline+=%2*%h%w%m%r%*
endif
"}}}

" ---- file modified time ---- {{{
call s:SetDefaultVal('g:statline_show_savetime', '0')

if g:statline_show_savetime
    set statusline+=\ %{strftime(\"%c\",getftime(expand(\"%:p\")))}
endif
"}}}

" ---- vim-virtualenv ---- "{{{
call s:SetDefaultVal('g:statline_virtualenv', '0')
if g:statline_virtualenv
    set statusline+=%4*%{exists('g:virtualenv_loaded')?virtualenv#statusline():''}%*
endif
  "}}}

" ---- filetype ---- {{{
call s:SetDefaultVal('g:statline_show_filetype', '1')
set statusline+=\ %y
"}}}

" ---- file format → file encoding ---- {{{
call s:SetDefaultVal('g:statline_show_encoding', '1')
call s:SetDefaultVal('g:statline_no_encoding_string', 'No Encoding')
call s:SetDefaultVal('g:statline_show_filetype', '1')

if &encoding == 'utf-8'
    let g:statline_encoding_separator = '→'
else
    let g:statline_encoding_separator = ':'
endif

if g:statline_show_encoding
    set statusline+=[%{&ff}%{g:statline_encoding_separator}%{strlen(&fenc)?&fenc:g:statline_no_encoding_string}]
endif
"}}}

" ---- paste mode --- {{{
call s:SetDefaultVal('g:statline_show_paste', '1')
call s:SetDefaultVal('g:statline_show_paste_string', '[PASTE!]')
if g:statline_show_paste
    set statusline+=\ %5*%{&paste?(g:statline_show_paste_string):''}%*
endif
"}}}

" ---- list mode --- {{{
call s:SetDefaultVal('g:statline_show_list', '1')
call s:SetDefaultVal('g:statline_show_list_string', '[LIST!]')
if g:statline_show_list
    set statusline+=%5*%{&list?(g:statline_show_list_string):''}%*
endif
"}}}

" ---- separation between left/right aligned items ---- {{{
set statusline+=%=
"}}}

" ---- current line and column ---- {{{
" (-:left align, 14:minwid, l:line, L:nLines, c:column or virtual column)
call s:SetDefaultVal('g:statline_show_line_col_numbers', '1')
if g:statline_show_line_col_numbers
    set statusline+=%-14(\ L%l/%L:C%c%V\ %)
endif
"}}}

" ----  scroll percent ---- {{{
call s:SetDefaultVal('g:statline_show_scroll_percent','1')
if g:statline_show_scroll_percent
    set statusline+=%P
endif
"}}}

" ---- code of character under cursor ---- {{{
call s:SetDefaultVal('g:statline_show_charcode','0')
if g:statline_show_charcode
    " (b:num, B:hex)
    set statusline+=%9(\ \%b/0x\%B%)
endif
"}}}


" ====== plugins ======

" ---- RVM ---- {{{
call s:SetDefaultVal('g:statline_rvm','0')
if g:statline_rvm
    set statusline+=%{exists('g:loaded_rvm')?rvm#statusline():''}
endif
"}}}

" ---- rbenv ---- {{{
call s:SetDefaultVal('g:statline_rbenv', '0')
if g:statline_rbenv
    set statusline+=%{exists('g:loaded_rbenv')?rbenv#statusline():''}
endif
"}}}

" ---- Fugitive ---- {{{
call s:SetDefaultVal('g:statline_fugitive', '0')
if g:statline_fugitive
    set statusline+=%4*%{exists('g:loaded_fugitive')?fugitive#statusline():''}%*
endif
"}}}

" ---- ScmFrontEnd ---- {{{
call s:SetDefaultVal('g:statline_scmfrontend', '0')
function! SfeStatus()
    let s:sfe = g:sfe_getStatus()
    if s:sfe
      let sfe = "[" s:sfe "]"
    endif
    return s:sfe
endfunction
if g:statline_scmfrontend
    set statusline+=\ %4*%{exists('g:sfe_availableScms')?SfeStatus():''}%*
endif
"}}}

" ---- Syntastic errors ---- {{{
call s:SetDefaultVal('g:statline_syntastic', '1')
if g:statline_syntastic
    set statusline+=\ %3*%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}%*
endif
"}}}

" ====== custom errors ======


" based on @scrooloose whitespace flags
" http://got-ravings.blogspot.com/2008/10/vim-pr0n-statusline-whitespace-flags.html


" ---- mixed indenting ---- {{{

if !exists('g:statline_mixed_indent')
    let g:statline_mixed_indent = 1
endif

if !exists('g:statline_mixed_indent_string')
    let g:statline_mixed_indent_string = '[mix]'
endif

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatlineTabWarning()
    if !exists("b:statline_indent_warning")
        let b:statline_indent_warning = ''

        if !&modifiable
            return b:statline_indent_warning
        endif

        let tabs = search('^\t', 'nw') != 0

        "find spaces that arent used as alignment in the first indent column
        let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw') != 0

        if tabs && spaces
            let b:statline_indent_warning = g:statline_mixed_indent_string
        elseif (spaces && !&et) || (tabs && &et)
            let b:statline_indent_warning = '[&et]'
        endif
    endif
    return b:statline_indent_warning
endfunction

if g:statline_mixed_indent
    set statusline+=%3*%{StatlineTabWarning()}%*

    " recalculate when idle and after writing
    augroup statline_indent
        autocmd!
        autocmd cursorhold,bufwritepost * unlet! b:statline_indent_warning
    augroup END
endif
"}}}

" --- trailing white space --- {{{

if !exists('g:statline_trailing_space')
    let g:statline_trailing_space = 1
endif

function! StatlineTrailingSpaceWarning()
    if !exists("b:statline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statline_trailing_space_warning = '[\s]'
        else
            let b:statline_trailing_space_warning = ''
        endif
    endif
    return b:statline_trailing_space_warning
endfunction

if g:statline_trailing_space
    set statusline+=%3*%{StatlineTrailingSpaceWarning()}%*

    " recalculate when idle, and after saving
    augroup statline_trail
        autocmd!
        autocmd cursorhold,bufwritepost * unlet! b:statline_trailing_space_warning
    augroup END
endif
"}}}

