
function TestStartDebugger()

    let actual = StartDebugger("gdb")

    " Assert that it created a job and stop the job
    call assert_equal(1, jobstop(actual.dbgee.job),
                \ 'StartDebugger did not start debuggee job')
    call assert_equal(1, jobstop(actual.comm.job),
                \ 'StartDebugger did not start debugee communication job')
    call assert_equal(1, jobstop(actual.dbger.job),
                \ 'StartDebugger did not start debugger job')

    " Destroy the created buffers
    execute $"silent! bwipeout! {actual.dbgee.buf}"
    execute $"silent! bwipeout! {actual.dbger.buf}"
endf

function TestFailToStartDebugee()

    function! ReturnEmptyDict(cmd, opts)
        return {}
    endf

    let actual = StartDebugger("gdb", 'ReturnEmptyDict')

    call assert_equal({}, actual.dbgee)
endf

" Test that they are able to configure the locations of the debugger and
" debuggee
"function TestStartDebuggerLocationConfig()
"endf

function TestStopDebugger()

    let expected = #{dbgee: {}, dbger: {}, comm: {}}

    let state = StartDebugger("gdb")
    let debuggee_id = state.dbgee.job
    let debugger_id = state.dbger.job
    let comm_id = state.comm.job

    call StopDebugger(state)

    " Assert that it that all the jobs have already been stopped
    call assert_equal(0, jobstop(debuggee_id),
                \ 'StopDebugger did not stop debuggee job')
    call assert_equal(0, jobstop(debugger_id),
                \ 'StopDebugger did not stop debugger job')
    call assert_equal(0, jobstop(comm_id),
                \ 'StopDebugger did not stop debuggee communication job')
endf

function TestNotRunning()
    call assert_false(Running({}))
    call assert_false(Running(#{test: "test"}))
endf

function TestRunning()

    let state = StartDebugger("gdb")

    call assert_true(Running(state))

    call StopDebugger(state)

    call assert_false(Running(state))

    let state = StartDebugger("gdb")

    call assert_true(Running(state))

    call StopDebugger(state)

    call assert_false(Running(state))
endf
