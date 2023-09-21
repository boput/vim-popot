vim9script

const is_win = has('win32')

# Functions

# Move to next untransled or translated `msgstr` FORWARD
if !exists('*NextStringFwd')
  export def NextStringFwd()
    search('^msgstr\(\[\d\]\)\=')
    @/ = ""
    call histdel('/', -1)
    normal z.f"
  enddef
endif

# Move to next untransled or translated `msgstr` BACKWARD
if !exists('*NextStringBwd')
  export def NextStringBwd()
      normal! k
    search('^msgstr\(\[\d\]\)\=', 'b')
    @/ = ''
    call histdel('/', -1)
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
if !exists('*NextTransFwd')
  export def NextTransFwd()
    search('^msgstr\(\[\d\]\)\=\s*""\(\n\n\)\|\%$')
    @/ = ""
    call histdel('/', -1)
    normal z.f"
  enddef
endif

# Move to next untranslated `msgstr` BACKWARD
if !exists('*NextTransBwd')
  export def NextTransBwd()
    normal! k
    search('^msgstr\(\[\d\]\)\=\s*""\(\n\n\)\|\%$', 'b')
    @/ = ""
    call histdel('/', -1)
    normal z.f"
  enddef
endif

# Copy current `msgid` to `msgstr`
if !exists('*CopyMsgid')
  export def CopyMsgid()
    normal }
    search('^msgid', 'b')
    @/ = ""
    call histdel('/', -1)
    normal f"
    onoremap __ /msgstr<CR>
    normal y__
    @/ = ''
    call histdel('/', -1)
    normal jf""_d$p
    normal 0f"l
  enddef
endif

# Delete current `msgstr` string
if !exists('*DeleteTrans')
  export def DeleteTrans()
    normal }  
    search('^msgstr', 'b')
    @/ = ''
    call histdel('/', -1)
    normal f"
    normal lc}"
  enddef
endif

# Move to the next fuzzy translation
if !exists('*NextFuzzy')
  export def NextFuzzy()
    if search('^#,\(.*,\)\=\s*fuzzy') > 0
      @a/ = ''
      call histdel('/', -1)
      search('^msgstr')
      @a = ''
      call histdel('/', -1)
      normal z.f"l
    else
      echomsg 'No more `fuzzy` flags'
    endif
  enddef
endif

# Move to the previous fuzzy translation
if !exists('*PreviousFuzzy')
  export def PreviousFuzzy()
    normal {
    if search('^#,\(.*,\)\=\s*fuzzy', 'b') > 0
      @a/ = ''
      call histdel('/', -1)
      search('^msgstr')
      @a = ''
      call histdel('/', -1)
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
    var firstline = line('.')
    normal }k
    var lastline = line('.')
    for i in range(firstline, lastline)
      if getline(i) =~ '^#,.*fuzzy'
        return
      elseif getline(i) =~ '^#,'
        setline(i, substitute(getline(i), '#,', '#, fuzzy,', ""))
        return
      elseif getline(i) !~ '^#'
        append(i - 1, '#, fuzzy')
        return
      endif
    endfor
  enddef
endif

# Clear `fuzzy` flag from current entry
if !exists('*RemoveFuzzy')
  export def RemoveFuzzy()
    normal {  
    var firstline = line('.')
    normal }k
    search('^#, fuzzy\|^#,\(.*,\)\=\s*fuzzy', 'b', firstline)
    if getline(".") =~ '^#,\s*fuzzy$'
      normal! dd
    elseif getline('.') =~ '^#,\(.*,\)\=\s*fuzzy'
      setline(line('.'), substitute(getline('.'), '^#,\(.*,\)\=\s*fuzzy', '#', ''))
    endif
    search('^msgstr')
    @a = ''
    call histdel('/', -1)
    normal z.f"l
  enddef
endif

# Remove previous (now fuzzy) translation from current entry
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
    call histdel('/', -1)
    normal z.f"l
  enddef
endif

# Show msgfmt statistics for current .po file
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
    if action == 'person'
      if exists('g:po_translator')
        search_for = 'Last-Translator'
        add = g:po_translator
      endif
    elseif action == 'team'
      if exists('g:po_lang_team')
        search_for = 'Language-Team'
        add = g:po_lang_team
      endif
    elseif action == 'lang'
      if exists('g:po_language')
        search_for = 'Language'
        add = g:po_language
      endif
    elseif action == 'plural'
      if exists('g:po_plural_form')
        search_for = 'Plural-Forms'
        add = g:po_plural_form
      endif
     else
      return
    endif
    search_for = '"' .. search_for .. ':'
    add = add .. '\\n"'
    normal! 1G
    if search('^' .. search_for) >= 0
      silent! exe 's/^\(' .. search_for .. '\).*$/\1 ' .. add
      call histdel('/', -1)
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
    var old_report = 'set report=' .. &report
    &report = 100
    var cursor_pos_cmd = line('.') .. 'normal! ' .. virtcol('.')
    normal! H
    var scrn_pos = line('.') .. 'normal! zt'
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
      call histdel("/", -1)
    endwhile
    #
    normal :scrn_pos
    normal :cursor_pos_cmd
  enddef
endif

# Format the whole file(wrap the lines etc.)
# TODO

