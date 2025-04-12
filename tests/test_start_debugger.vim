
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
