" dbg.vim - Debugger plugin inspired by termdebug.vim
"
" Author:   Anakin Childerhose
" Copyright: Vim license applies, see ":help license"
" Version:      0.1


"if exists('g:loaded_dbg')
"    finish
"endif
"let g:loaded_dbg = 1


" repo local configs need to be stored in a file somewhere
"
" like have one file that stores the repos root dir in the first column and the
" second column is just the config vimscript dict

" TODO
" Given the current file, I want to be able to get the configuration stored in
" the internal storage for
function! GetConfig(cfg_dir, file)
    " Have the repo configs just be a list of all the previous settings
    "
    " They do not grow upon each other, they are independent
    "
    " Anytime it is started with new different args to the current repo config
    " then a new one is added to the beginning of the config
endf

runtime actions.vim
runtime cmd.vim
runtime remote.vim

" TODO: smarter tab completion
command! -nargs=* -complete=file Dbg call s:Dbg("<args>")

function! s:Dbg(args = "")

    let remote = GetRemote(expand("%"))

    let action = GetAction({}, a:args)

    if empty(action)
        echohl WarningMsg
        echo $"No program setup to debug for remote: {remote}"
        echohl Title
        echo 'Try one of:'
        echo ' :DbgStart /path/to/program'
        echo ' :DbgStart <pid>'
        echo ' :DbgStart <name of process>'
        echo ' :DbgStart <ip> <port>'
        echo 'Then:'
        echo ' :DbgStart'
        echohl None
        return
    endif

    let cmd = BuildDebuggerCmd(action, "gdb", g:default_gdb_args)
    if empty(cmd)
        echoerr "Failed to build debgger command"
        echo $"{action} gdb {g:default_gdb_args}"
        return
    endif

    new
    let id = termopen(cmd)

endf

