
function! dbg#mi#handleCommOutput(chan, data, name)

    " Have statemachine here to handle incomplete lines
    call writefile(a:data, '/tmp/commoutput', 'a')
endf

" TODO: The state should be injected so that the location configuration can be
" injected
function! dbg#mi#start(cmd, job_init = 'dbg#job#init')
    let state = {}

    let dummy_process = 'tail -f /dev/null'

    let state.dbgee = call(a:job_init, [dummy_process,
                \ #{term: v:true, location: 'tab'}])
    if empty(state.dbgee) || !state.dbgee->has_key("pty")
        call dbg#log#warning("Failed to init job for debuggee")
        return state
    endif

    let state.comm = call(a:job_init, [dummy_process,
                \ #{pty: v:true, on_stdout: function('dbg#mi#handleCommOutput')}])
    if empty(state.comm) || !state.comm->has_key("pty")
        call dbg#log#warning("Failed to init job for debugger communication")
        call DeinitJob(state.dbgee)
        return state
    endif

    let state.dbger = call(a:job_init, [a:cmd, #{term: v:true, location: 'tab'}])
    if empty(state.dbger) || !state.dbgee->has_key("pty")
        call dbg#log#warning("Failed to init job for debugger")
        call DeinitJob(state.dbgee)
        call DeinitJob(state.comm)
        return state
    endif

    let new_mi_ui_cmd = $"server new-ui mi {state.comm.pty}\r"
    call chansend(state.dbger.job, new_mi_ui_cmd)

    let set_tty = $"server set inferior-tty {state.dbgee.pty}\r"
    call chansend(state.dbger.job, set_tty)

    return state
endf

" TODO: :DbgStop cleans up all leftover processes
function! dbg#mi#stop(state)
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

function! dbg#mi#running(state)
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
