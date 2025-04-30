" dbg.vim - Debugger plugin inspired by termdebug.vim
"
" Author:    Anakin Childerhose
" Copyright: Vim license applies, see ":help license"
" Version:   0.1

"if exists('g:loaded_dbg')
"    finish
"endif
"let g:loaded_dbg = 1

function! HandleCommStdout(chan, data, name)

    " Have statemachine here to handle incomplete lines
    call writefile(a:data, '/tmp/commoutput', 'a')
endf

" TODO: The state should be injected so that the location configuration can be
" injected
function! StartDebugger(cmd, InitJob = 'InitJob')
    let state = {}

    let dummy_process = 'tail -f /dev/null'

    let state.dbgee = call(a:InitJob, [dummy_process,
                \ #{term: v:true, location: 'tab'}])
    if empty(state.dbgee) || !state.dbgee->has_key("pty")
        echohl WarningMsg
        echom "Failed to init job for debuggee"
        echohl None
        return state
    endif

    let state.comm = call(a:InitJob, [dummy_process,
                \ #{pty: v:true, on_stdout: function('HandleCommStdout')}])
    if empty(state.comm) || !state.comm->has_key("pty")
        echohl WarningMsg
        echom "Failed to init job for debugger communication"
        echohl None
        call DeinitJob(state.dbgee)
        return state
    endif

    let state.dbger = call(a:InitJob, [a:cmd, #{term: v:true, location: 'tab'}])
    if empty(state.dbger) || !state.dbgee->has_key("pty")
        echohl WarningMsg
        echom "Failed to init job for debugger"
        echohl None
        call DeinitJob(state.dbgee)
        call DeinitJob(state.comm)
        return state
    endif

    return state
endf

" TODO: :DbgStop cleans up all leftover processes
function! StopDebugger(state)
    if a:state->has_key('dbgee')
        call DeinitJob(a:state.dbgee)
        let a:state.dbgee = {}
    endif

    if a:state->has_key('dbger')
        call DeinitJob(a:state.dbger)
        let a:state.dbger = {}
    endif

    if a:state->has_key('comm')
        call DeinitJob(a:state.comm)
        let a:state.comm = {}
    endif
endf

function! Running(state)
    if empty(a:state)
        return v:false
    endif

    try
        call jobpid(a:state.dbgee.job)
        let debuggee_running = v:true
    catch
        let debuggee_running = v:false
    endtry

    try
        call jobpid(a:state.dbger.job)
        let debugger_running = v:true
    catch
        let debugger_running = v:false
    endtry

    try
        call jobpid(a:state.comm.job)
        let comm_running = v:true
    catch
        let comm_running = v:false
    endtry

    return debuggee_running || debugger_running || comm_running
endf

" TODO: smarter tab completion
command! -nargs=* -complete=file Dbg call s:Dbg("<args>")
command! -nargs=0 DbgStop call StopDebugger(g:DbgState)
command! -nargs=0 DbgCleanConfig call CleanConfig()
command! -nargs=0 DbgShowConfig echom GetOrInitConfig()
command! -nargs=0 DbgLogToggle call ToggleDbgLogging()

if !exists("g:DbgState")
    let DbgState = {}
endif

function! PrintUsage()
    echohl Title
    echom 'Try one of:'
    echom ' :Dbg /path/to/program'
    "echo ' :Dbg <pid>'
    "echo ' :Dbg <name of process>'
    "echo ' :Dbg <ip> <port>'
    echom 'Then:'
    echom ' :Dbg'
    echohl None
endf

function! s:Dbg(args = "") abort

    let config = GetOrInitConfig()

    call LogDebug($"config: {config}")

    let last_action = GetLastAction(config)
    call LogDebug($"last_action: {last_action}")

    " Determine which action to take based on config and args
    let action = GetAction(last_action, a:args)
    call LogDebug($"action: {action}")

    if empty(action)
        call LogWarning($"unable to perform any action")
        call PrintUsage()
        return
    endif

    call UpdateConfig(action)

    if Running(g:DbgState)
        call LogInfo("Restarting debugging session")
        call StopDebugger(g:DbgState)
    endif

    let cmd = BuildDebuggerCmd(action, "gdb", g:default_gdb_args)
    call LogDebug($"cmd: {cmd}")
    if empty(cmd)
        call LogError($"Failed to build debgger command: {action} {g:default_gdb_args}")
        return
    endif

    let g:DbgState = StartDebugger(cmd)

    let new_mi_ui_cmd = $"server new-ui mi {g:DbgState.comm.pty}\r"
    call chansend(g:DbgState.dbger.job, new_mi_ui_cmd)

    let set_tty = $"server set inferior-tty {g:DbgState.dbgee.pty}\r"
    call chansend(g:DbgState.dbger.job, set_tty)
endf
