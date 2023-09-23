Vim ftplugin for PO file (GNU gettext) editing.

This script is a fork version of Aleksandar Jelenak's script. Since the
last change by the original creator is long time ago and I failed to get in
tough with him via email, I started this project by myself. Nearly 90% of
the script is written by Aleksandar Jelenak. I fixed two bugs and add three
other functions and remapped the keys. Thanks to Aleksandar Jelenak a lot.

Original Creator:	Aleksandar Jelenak <ajelenak AT yahoo.com>
Modifier: Grissiom <chaos.proton AT gmail.com>
Last Change by Original Creator:	Tue, 12 Apr 2005 13:49:55 -0400
*** Latest version of original script: http://www.vim.org/scripts/script.php?script_id=695 ***
*** Latest version of modified verion:
http://repo.or.cz/w/grissiom.projects.git?a=blob_plain;f=vim/ftplugin/po.vim ***

# Package vim-popot
## vim-popot is produced by packing Grissiom's latest version into package using exclusively vim9script.

## Description
    This file is a Vim package for editing PO files (GNU gettext -- the GNU
    i18n and l10n system). It automates over a dozen frequent tasks that
    occur while editing files of this type.

Remarks:
- "S" in the above key mappings stands for the <Shift> key and "\" in
  fact means "<LocalLeader>" (:help <LocalLeader>), which is "\" by
  Vim's default.
- Information about the translator and language team is supplied by two
  global variables: 'g:po_translator' and 'g:po_lang_team'. They should
  be defined in the ".vimrc" (UNIX) or "_vimrc" (Windows) file. If they
  are not defined, the default values (descriptive strings) are put
  instead.
- Vim's "gf" Normal mode command is remapped (local to the PO buffer, of
  course). It will only function on lines starting with "#: ". Search
  for the file is performed in the directories specified by the 'path'
  option. The user can supply its own addition to this option via the
  'g:po_path' global variable. Its default value for PO files can be
  found by typing ":set path?" from within a PO buffer. For the correct
  format please see ":help 'path'". Warning messages are printed if no
  or more than one file is found.
- Vim's Quickfix mode (see ":help quickfix") is used for browsing
  through msgfmt-reported errors for the file. No MO file is created
  when running the msgfmt program since its output is directed to
  "/dev/null". The user can supply command-line arguments to the msgfmt
  program via the global variable 'g:po_msgfmt_args'. All arguments are
  allowed except the "-o" for output file. The default value is
  "-vv -c".
- Format the whole file is actually using msgmerge a.po a.po -o a.po.
  Since we must reload the file that has been modified, you could not
  do any Undo once you run this function.
But there's even more!
Every time the PO file is saved, a PO-formatted time stamp is
automatically added to the file header.

INSTALLATION
    Put this file in a Vim ftplugin directory. On UNIX computers it is
    usually either "~/.vim/ftplugin" or "~/.vim/after/ftplugin". On Windows
    computers, the defaults are "$VIM\vimfiles\ftplugin" or
    "$VIM\vimfiles\after\ftplugin". For more information consult the Vim
    help, ":help 'ftplugin'" and ":help 'runtimepath'".

REMOVAL
    Just delete the bloody file!