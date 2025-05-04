
function TestStartDebugger()

    let actual = dbg#mi#start("gdb")

    " Assert that it created a job and stop the job
    call assert_equal(1, jobstop(actual.dbgee.job),
                \ 'dbg#mi#start did not start debuggee job')
    call assert_equal(1, jobstop(actual.comm.job),
                \ 'dbg#mi#start did not start debugee communication job')
    call assert_equal(1, jobstop(actual.dbger.job),
                \ 'dbg#mi#start did not start debugger job')

    " Destroy the created buffers
    execute $"silent! bwipeout! {actual.dbgee.buf}"
    execute $"silent! bwipeout! {actual.dbger.buf}"
endf

function TestFailToStartDebugee()

    function! ReturnEmptyDict(cmd, opts)
        return {}
    endf

    let actual = dbg#mi#start("gdb", 'ReturnEmptyDict')

    call assert_equal({}, actual.dbgee)
endf

" Test that they are able to configure the locations of the debugger and
" debuggee
"function TestStartDebuggerLocationConfig()
"endf

function TestStopDebugger()

    let expected = #{dbgee: {}, dbger: {}, comm: {}}

    let state = dbg#mi#start("gdb")
    let debuggee_id = state.dbgee.job
    let debugger_id = state.dbger.job
    let comm_id = state.comm.job

    call dbg#mi#stop(state)

    " Assert that it that all the jobs have already been stopped
    call assert_equal(0, jobstop(debuggee_id),
                \ 'dbg#mi#stop did not stop debuggee job')
    call assert_equal(0, jobstop(debugger_id),
                \ 'dbg#mi#stop did not stop debugger job')
    call assert_equal(0, jobstop(comm_id),
                \ 'dbg#mi#stop did not stop debuggee communication job')
endf

function TestNotRunning()
    call assert_false(dbg#mi#running({}))
    call assert_false(dbg#mi#running(#{test: "test"}))
endf

function TestRunning()

    let state = dbg#mi#start("gdb")

    call assert_true(dbg#mi#running(state))

    call dbg#mi#stop(state)

    call assert_false(dbg#mi#running(state))

    let state = dbg#mi#start("gdb")

    call assert_true(dbg#mi#running(state))

    call dbg#mi#stop(state)

    call assert_false(dbg#mi#running(state))
endf
