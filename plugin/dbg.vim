" dbg.vim - Debugger plugin inspired by termdebug.vim
"
" Author:   Anakin Childerhose
" Copyright: Vim license applies, see ":help license"
" Version:      0.1

"if exists('g:loaded_dbg')
"    finish
"endif
"let g:loaded_dbg = 1

" TODO: The state should be injected so that the location configuration can be
" injected
function! StartDebugger(cmd, InitJob = 'InitJob')
    let state = {}

    let dummy_process = 'tail -f /dev/null'

    let state.dbgee = call(a:InitJob,
                \ [dummy_process, #{term: v:true, location: 'tab'}])
    if empty(state.dbgee) || !state.dbgee->has_key("pty")
        echohl WarningMsg
        echo "Failed to init job for debuggee"
        echohl None
        return state
    endif

    let state.comm = call(a:InitJob, [dummy_process, #{pty: v:true}])
    if empty(state.comm) || !state.comm->has_key("pty")
        echohl WarningMsg
        echo "Failed to init job for debugger communication"
        echohl None
        call DeinitJob(state.dbgee)
        return state
    endif

    let cmd = $"{a:cmd} -tty {state.comm.pty} -ex 'echo startupdone\n'"

    let state.dbger = call(a:InitJob, [cmd, #{term: v:true, location: 'tab'}])
    if empty(state.dbger) || !state.dbgee->has_key("pty")
        echohl WarningMsg
        echo "Failed to init job for debugger"
        echohl None
        call DeinitJob(state.dbgee)
        call DeinitJob(state.comm)
        return state
    endif

    return state
endf

" TODO: smarter tab completion
command! -nargs=* -complete=file Dbg call s:Dbg("<args>")

function! s:Dbg(args = "")

    " Config logic goes around here
    "
    " TODO: Make sure to account for being in a terminal buffer
    let remote = GetRemote(expand("%"))

    " TODO: Figure out how to handle running :Dbg during a debug

    " Determine which action to take based on config and args
    let action = GetAction({}, a:args)

    if empty(action)
        echohl WarningMsg
        echo $"No program setup to debug for remote: {remote}"
        echohl Title
        echo 'Try one of:'
        echo ' :Dbg /path/to/program'
        echo ' :Dbg <pid>'
        echo ' :Dbg <name of process>'
        echo ' :Dbg <ip> <port>'
        echo 'Then:'
        echo ' :Dbg'
        echohl None
        return
    endif

    let cmd = BuildDebuggerCmd(action, "gdb", g:default_gdb_args)
    if empty(cmd)
        " TODO: Clean up error message
        echoerr "Failed to build debgger command"
        echo $"{action} gdb {g:default_gdb_args}"
        return
    endif

    let state = StartDebugger(cmd)
endf
