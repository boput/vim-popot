vim9script noclear

const is_win = has('win32')

# Functions

# Move to next untransled or translated `msgstr` FORWARD
if !exists('*NextStringFwd')
  export def NextStringFwd()
    search('^msgstr\(\[\d\]\)\=')
    @/ = ''
    histdel('/', -1)
    normal z.f"
  enddef
endif

# Move to next untransled or translated `msgstr` BACKWARD
if !exists('*NextStringBwd')
  export def NextStringBwd()
      normal! k
    search('^msgstr\(\[\d\]\)\=', 'b')
    @/ = ''
    histdel('/', -1)
    normal z.f"
  enddef
endif

# Begin to comment current entry
if !exists('*CommentEntry')
  export def CommentEntry()
    exe 'normal {o#   '
  enddef
endif

# Move to next untranslated `msgstr` FORWARD
# if !exists('*NextTransFwd')
#   export def NextTransFwd()
#     search('^msgstr\(\[\d\]\)\=\s*""\(\n\n\)\|\%$')
#     @/ = ''
#     histdel('/', -1)
#     normal z.f"
#   enddef
# endif

# Move to next untranslated `msgstr` FORWARD
if !exists('*NextTransFwd')
  export def NextTransFwd()
    if search('^msgstr\(\[\d\]\)\=\s*""\(\n\n\)\|\%$') > 0
      @/ = ''
      histdel('/', -1)
      normal z.f"
    else
      echo  "No more  `untranslated' msgid's"
    endif
  enddef
endif
defcompile

# Move to next untranslated `msgstr` BACKWARD
if !exists('*NextTransBwd')
  export def NextTransBwd()
    normal! k
    search('^msgstr\(\[\d\]\)\=\s*""\(\n\n\)\|\%$', 'b')
    @/ = ''
    histdel('/', -1)
    normal z.f"
  enddef
endif

# Copy current `msgid` to `msgstr`
if !exists('*CopyMsgid')
  export def CopyMsgid()
    normal <Esc>
    normal }
    search('^msgid', 'b')
    @/ = ''
    histdel('/', -1)
    normal f"
    onoremap _ /msgstr<CR>
    normal y_
    search('^msgstr')
    normal f"
    normal "_d$p
    @/ = ''
    histdel('/', -1)
  enddef
endif


# Delete current `msgstr` string
if !exists('*DeleteTrans')
  export def DeleteTrans()
    normal }
    search('^msgstr', 'b')
    @/ = ''
    histdel('/', -1)
    normal f"
    normal lc}"
  enddef
endif

# Move to the next fuzzy (marked with fuzzy flag, `#, fuzzy`) translation
if !exists('*NextFuzzy')
  export def NextFuzzy()
    if search('^#,\(.*,\)\=\s*fuzzy') > 0
      @/ = ''
      histdel('/', -1)
      search('^msgstr')
      @/ = ''
      histdel('/', -1)
      normal z.f"l
    else
      echomsg 'No more `fuzzy` flags'
    endif
  enddef
endif
defcompile

# Move to the previous fuzzy (marked with fuzzy flag, `#, fuzzy`) translation
if !exists('*PreviousFuzzy')
  export def PreviousFuzzy()
    normal {
    if search('^#,\(.*,\)\=\s*fuzzy', 'b') > 0
      @a/ = ''
      histdel('/', -1)
      search('^msgstr')
      @a = ''
      histdel('/', -1)
      normal z.f"l
    else
      echomsg 'No more `fuzzy` flags'
    endif
  enddef
endif

# Mark current entry with `fuzzy` flag
if !exists('*InsertFuzzy')
  export def InsertFuzzy()
    normal {
    var firstline = line('.') + 1
    normal }k
    var lastline = line('.') - 1
    for i in range(lastline, firstline, -1)
      if getline(i) =~ '^#,.*fuzzy'
        return
      elseif getline(i) =~ '^#,.*'
        setline(i, substitute(getline(i), '#,', '#, fuzzy,', ""))
        return
      elseif getline(i) =~ '^#:'
        append(i, '#, fuzzy')
        return
      endif
    endfor
  enddef
endif

# Clear `fuzzy` flag from current entry
# if !exists('*RemoveFuzzy')
#   export def RemoveFuzzy()
#     normal {
#     var firstline = line('.')
#     normal }k
#     search('^#, fuzzy\|^#,\(.*,\)\=\s*fuzzy', 'b', firstline)
#     if getline(".") =~ '^#,\s*fuzzy$'
#       normal! dd
#     elseif getline('.') =~ '^#,\(.*,\)\=\s*fuzzy'
#       setline(line('.'), substitute(getline('.'), '^#,\(.*,\)\=\s*fuzzy', '#', ''))
#     endif
#     search('^msgstr')
#     @a = ''
#     histdel('/', -1)
#     normal z.f"l
#   enddef
# endif

if !exists('*RemoveFuzzy')
  export def RemoveFuzzy()
    normal {
    var firstline = line('.')
    normal }k
    search('^#, fuzzy\|^#,\(.*,\)\=\s*fuzzy', 'b', firstline)
    if getline(".") =~ '^#,\s*fuzzy$'
      :echo "`fuzzy' flag clerared"
      normal! dd
      search('^msgstr')
      @a = ''
      histdel('/', -1)
      normal z.f"l
    elseif getline('.') =~ '^#,\(.*,\)\=\s*fuzzy'
      setline(line('.'), substitute(getline('.'), '^#,\(.*,\)\=\s*fuzzy', '#', ''))
      search('^msgstr')
      @a = ''
      histdel('/', -1)
      normal z.f"l
    else
      # search('^msgstr')
      @a = ''
      histdel('/', -1)
      normal z.f"l
      echo "This `fuzzy' mark is cleared."
    endif
  enddef
endif



# Remove previous (fuzzy) translation from current entry
if !exists('*RemovePrevious')
  export def RemovePrevious()
    normal {
    var firstline = line('.')
    normal }k
    var lastline = line('.')
    for i in range(firstline, lastline)
    search('^#|', 'b', firstline)
       if getline('.') =~ '^#|'
         normal! dd
      endif
    endfor
    search('^msgstr')
    @a = ''
    histdel('/', -1)
    normal z.f"l
  enddef
endif

# export def ClearFuzzyPreviousMessges()
#   po#RemovePrevious()
#   po#RemoveFuzzy()
# enddef


# Show `msgfmt` statistics for current .po file
if !exists('*Msgfmt')
  export def Msgfmt()
    # Check if the file needs to be saved first.
    exe 'if &modified | w | endif'
    if is_win
      exe '!msgfmt.exe --statistics % -o /dev/null'
    else
      exe '!msgfmt --statistics % -o /dev/null'
    endif
  enddef
endif

# Browse through msgfmt errors for the file
# TODO

# Add (insert) translator info (person, team, lang, plural) in the file header
if !exists('AddHeaderInfo')
  export def AddHeaderInfo(action: string)
    var search_for: string
    var add: string
    # Adding 'Last-translator'
    if action == 'person'
      if exists('g:po_translator')
        search_for = 'Last-Translator'
        add = g:po_translator
      endif
    # Adding 'Language-Team'
    elseif action == 'team'
      if exists('g:po_lang_team')
        search_for = 'Language-Team'
        add = g:po_lang_team
      endif
    # Adding 'Language'
    elseif action == 'lang'
      if exists('g:po_language')
        search_for = 'Language'
        add = g:po_language
      endif
    # Adding 'Plural-Forms'
    elseif action == 'plural'
      if exists('g:po_plural_form')
        search_for = 'Plural-Forms'
        add = g:po_plural_form
      endif
    # Adding 'Content-Type'
    elseif action == 'charset'
      if exists('g:po_charset')
        search_for = 'Content-Type'
        add = g:po_charset
      endif
    # Adding 'X-Generator'
    elseif action == 'xgen'
      if exists('g:po_xgenerator')
        search_for = 'X-Generator'
        add = g:po_xgenerator
      endif
    else
      # Does nothing'
      return
    endif
    # Common script
    search_for = '"' .. search_for .. ':'
    add = add .. '\\n"'
    normal! 1G
    if search('^' .. search_for) >= 0
      silent! exe 's/^\(' .. search_for .. '\).*$/\1 ' .. add
      # we clear the line then insert corresponding text
      # silent! exe 's/^.*$/{search_for .. ' ' .. add}
      histdel('/', -1)
    endif
  enddef
endif

# Browse through msgfmt errors for the file
# TODO


# Write PO-formatted time stamp every time file is saved (see autocmd in
# ftplugin/po.vim)
if !exists('*PoFileTimestamp')
  export def PoFileTimestamp()
    var hist_search = histnr('/')
    var old_report = 'setlocal report=' .. &report
    &report = 100
    # var cursor_pos_cmd = line('.') .. 'normal! ' .. virtcol('.')
    # normal! H
    # var scrn_pos = line('.') .. 'normal! zt'
    # Remember position
    normal! md
    # Update revision time
    normal! 1G
    var topfuzzy = search('^#, fuzzy')
    if (!search('^#, fuzzy$', 'b', topfuzzy + 1))
      if (search('^"PO-Revision-Date:')) > 0
        silent! exe 's/^\("PO-Revision-Date:\).*$/\1 ' .. strftime("%Y-%m-%d %H:%M%z") .. '\\n"'
      endif
    endif
    #
    while histnr("/") > hist_search && histnr("/") > 0
      histdel("/", -1)
    endwhile
    #
    normal `d
    # normal :scrn_pos
    # normal :cursor_pos_cmd
  enddef
endif

# Format the whole file(wrap the lines etc.)
# TODO

