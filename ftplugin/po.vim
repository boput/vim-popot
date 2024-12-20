vim9script noclear

# Only do this when not done yet for this buffer
if exists('b:did_ftplugin')
  finish
endif
b:did_ftplugin = true

g:save_cpo = &cpo
setlocal cpo&vim

# comments string for po, pot files
setlocal commentstring=#\ %s
setlocal errorformat=%f:%l:\ %m

g:maplocalleader = ";"

# setlocal makeprg=msgfmt

# Make `f` of vim-sneak search for one character
# map f <Plug>Sneak_f
# nmap ? <Plug>Sneak_f

# import autoload 'po.vim'
import autoload '../autoload/po.vim'

# TODO
# b:po_path = '.,..,../src,../src/*'
# if exists("g:po_path")
#   b:po_path = b:po_path .. ',' .. g:po_path
# endif
# exe "setlocal path=" .. b:po_path


# Move to next untransled or translated `msgstr` FORWARD
if empty(maparg('<LocalLeader>m', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>m <ScriptCmd>po.NextStringFwd()<CR>
endif
if empty(maparg('<LocalLeader>m', 'i'))
  inoremap <buffer> <unique> <LocalLeader>m <Esc><ScriptCmd>po.NextStringFwd()<CR>z.f"a
endif
# or BACKWARD
if empty(maparg('<LocalLeader>M', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>M <ScriptCmd>po.NextStringBwd()<CR>
endif
if empty(maparg('<LocalLeader>M', 'i'))
  inoremap <buffer> <unique> <LocalLeader>M <Esc><ScriptCmd>po.NextStringBwd()<CR>z.f"a
endif

# Begin to comment current entry
if empty(maparg('<LocalLeader>C', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>C <ScriptCmd>po.CommentEntry()<CR>i
endif
if empty(maparg('<LocalLeader>C', 'i'))
  inoremap <buffer> <unique> <LocalLeader>C <Esc><ScriptCmd>po.CommentEntry()<CR>i
endif

# Move to next untranslated `msgstr` FORWARD...
if empty(maparg('<LocalLeader>u', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>u <ScriptCmd>po.NextTransFwd()<CR>z.f"
endif
if empty(maparg('<LocalLeader>u', 'i'))
  inoremap <buffer> <unique> <LocalLeader>u <Esc><ScriptCmd>po.NextTransFwd()<CR>z.f"
endif
# or BACKWARD.
if empty(maparg('<LocalLeader>U', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>U <ScriptCmd>po.NextTransBwd()<CR>z.f"
endif
if empty(maparg('<LocalLeader>U', 'i'))
  inoremap <buffer> <unique> <LocalLeader>U <Esc><ScriptCmd>po.NextTransBwd()<CR>z.f"
endif

# Copy current `msgid` to `msgstr`
if empty(maparg('<LocalLeader>c', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>c <ScriptCmd>po.CopyMsgid()<CR>
endif
if empty(maparg('<LocalLeader>c', 'i'))
  inoremap <buffer> <unique> <LocalLeader>c <Esc><ScriptCmd>po.CopyMsgid()<CR>
endif

# Erase the translation string.
if empty(maparg('<LocalLeader>d', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>d <ScriptCmd>po.DeleteTrans()<CR>i
endif
if empty(maparg('<LocalLeader>d', 'i'))
  inoremap <buffer> <unique> <LocalLeader>d <Esc><ScriptCmd>po.DeleteTrans()<CR><Esc>i
endif

# FUZZY
# Move to the first fuzzy translation forward
if empty(maparg('<LocalLeader>f', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>f <ScriptCmd>po.NextFuzzy()<CR>
endif
if empty(maparg('<LocalLeader>f', 'i'))
  inoremap <buffer> <unique> <LocalLeader>f <Esc><ScriptCmd>po.NextFuzzy()<CR>
endif

# Move to the first fuzzy descriptor backward.
if empty(maparg('<LocalLeader>F', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>F <ScriptCmd>po.PreviousFuzzy()<CR>
endif
if empty(maparg('<LocalLeader>F', 'i'))
  inoremap <buffer> <unique> <LocalLeader>F <Esc><ScriptCmd>po.PreviousFuzzy()<CR>
endif

# Mark current entry with `fuzzy` flag
if empty(maparg('<LocalLeader>Z', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>Z <ScriptCmd>po.InsertFuzzy()<CR>
endif
if empty(maparg('<LocalLeader>Z', 'i'))
  inoremap <buffer> <unique> <LocalLeader>Z <Esc><ScriptCmd>po.InsertFuzzy()<CR>
endif

# Clear `fuzzy` flag from current entry
if empty(maparg('<LocalLeader>z', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>z <ScriptCmd>po.RemoveFuzzy()<CR>
endif
if empty(maparg('<LocalLeader>z', 'i'))
  inoremap <buffer> <unique> <LocalLeader>z <Esc><ScriptCmd>po.RemoveFuzzy()<CR>
endif

# Clear previous (now fuzzy) translation from current entry
if empty(maparg('<LocalLeader>r', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>r <ScriptCmd>po.RemovePrevious()<CR>
endif
if empty(maparg('<LocalLeader>r', 'i'))
  inoremap <buffer> <unique> <LocalLeader>r <Esc><ScriptCmd>po.RemovePrevious()<CR>
endif

# # # Clear `fuzzy` and `previous` flag from current entry
if empty(maparg('<LocalLeader>d', 'n'))
  nnoremap <buffer> <unique> <LocalLeader>dd <ScriptCmd>po.RemoveFuzzy()<CR> <bar>  <ScriptCmd>po.RemovePrevious()<CR>
endif
if empty(maparg('<LocalLeader>d', 'i'))
  inoremap <buffer> <unique> <LocalLeader>dd <Esc><ScriptCmd>po.RemoveFuzzy()<CR> <bar> <ScriptCmd>po.RemovePrevious()<CR>
endif

# TIMESTAMP: Every time file is saved PO-Revision-Date is updated
# augroup PoFileTimestamp |  autocmd!
#   autocmd BufWritePre *.po :call po#PoFileTimestamp()
# augroup END

command! -nargs=0 PoAddHeaderAll
  \ call po#AddHeaderInfo('person') |
  \ call po#AddHeaderInfo('team') |
  \ call po#AddHeaderInfo('plural') |
  \ call po#AddHeaderInfo('xgen') |
  \ call po#AddHeaderInfo('charset')

command! -nargs=0 PoTimestampUpdate call po#PoFileTimestamp()

b:undo_ftplugin = (get(b:, 'undo_ftplugin') ?? 'execute')
    .. '| set commentstring<'

&cpo = g:save_cpo
unlet g:save_cpo

